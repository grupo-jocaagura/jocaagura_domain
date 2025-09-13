part of '../../jocaagura_domain.dart';

/// BLoC to orchestrate an onboarding flow (sequence of steps).
///
/// ### Purpose
/// Coordinates step transitions (`start`, `next`, `back`, `skip`, `complete`),
/// executes optional `onEnter` side-effects, captures errors into
/// [OnboardingState.error], and schedules **auto-advance** only when a step
/// enters successfully.
///
/// ### Error handling contract
/// - `onEnter` must **not throw** (return `Left(ErrorItem)` on failure).
/// - If `onEnter` **throws** unexpectedly, the exception is mapped to an
///   [ErrorItem] through the injected [ErrorMapper] (defaults to
///   [DefaultErrorMapper]) and stored in `state.error`.
/// - On `Left(ErrorItem)`, the flow **stays** on the current step (no auto-advance).
///
/// ### Concurrency and race-safety
/// - Uses an internal **epoch** (`_epoch`) plus identity checks
///   (`identical(step, currentStep)`) to ignore stale async completions when
///   the step changes during a pending `onEnter`.
/// - Timers are cancelled on every transition to prevent orphan callbacks.
///
/// ### Auto-advance policy
/// - Auto-advance is scheduled **only** when `onEnter` completes with success
///   (`Right(unit)`), and only if the step defines a positive
///   `autoAdvanceAfter`.
/// - Steps without `onEnter` are treated as **immediate success** for the
///   purpose of auto-advance: the delay is scheduled if present.
/// - **After `back()`** the orchestrator **does not auto-advance**, even if the
///   step defines `autoAdvanceAfter`. This prevents surprising jumps right
///   after a manual back action. Callers can still navigate forward explicitly
///   or re-run logic via [retryOnEnter].
///
/// ### State invariants (responsibility split)
/// - This BLoC relies on [OnboardingState] invariants being ensured by the
///   orchestrator/flow itself when moving between steps:
///   - When `status == running`, callers should ensure:
///     - `totalSteps > 0`
///     - `0 ≤ stepIndex < totalSteps`
/// - The public API updates state consistently (`idle` on `configure`, `running`
///   on `start`, etc.). Any domain validation beyond that must be handled in
///   higher layers if required.
///
/// ### Error persistence on terminal states
/// - [complete] and [skip] do **not** clear `error` automatically. If the UI
///   must present terminal screens without previous errors, call [clearError]
///   before or after these transitions.
///
/// ### Minimal usage
/// ```dart
/// final BlocOnboarding bloc = BlocOnboarding();
/// bloc.configure(<OnboardingStep>[/* steps */]);
/// bloc.start(); // emits running + executes onEnter for step 0
/// // listen on bloc.stateStream for updates
/// ```
///
/// ### Copy-paste runnable example (pure Dart)
/// ```dart
/// import 'dart:async';
/// import 'package:jocaagura_domain/jocaagura_domain.dart';
///
/// Future<void> main() async {
///   final BlocOnboarding bloc = BlocOnboarding();
///
///   final List<OnboardingStep> steps = <OnboardingStep>[
///     OnboardingStep(
///       title: 'Welcome',
///       description: 'Shows a welcome message',
///       autoAdvanceAfter: const Duration(milliseconds: 100),
///       // No onEnter: treated as immediate success for auto-advance.
///     ),
///     OnboardingStep(
///       title: 'Permissions',
///       description: 'Request critical permissions',
///       onEnter: () async {
///         // Simulate async work
///         await Future<void>.delayed(const Duration(milliseconds: 50));
///         final bool granted = true;
///         return granted
///             ? Right<ErrorItem, Unit>(Unit.value)
///             : Left<ErrorItem, Unit>(ErrorItem(
///                 title: 'Permission Denied',
///                 code: 'ERR_PERM',
///                 description: 'User did not grant permissions',
///               ));
///       },
///       autoAdvanceAfter: const Duration(milliseconds: 100),
///     ),
///     OnboardingStep(
///       title: 'Finalize',
///       description: 'Finishes the setup',
///       onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
///     ),
///   ];
///
///   // Observe state changes
///   final StreamSubscription<OnboardingState> sub =
///       bloc.stateStream.listen((OnboardingState s) {
///     print('[STATE] $s');
///   });
///
///   bloc.configure(steps);
///   bloc.start();
///
///   // Wait enough for first auto-advance (Welcome -> Permissions)
///   await Future<void>.delayed(const Duration(milliseconds: 200));
///
///   // Demonstrate back(): it will NOT auto-advance after going back
///   bloc.back(); // Go back from Permissions to Welcome
///   await Future<void>.delayed(const Duration(milliseconds: 200));
///
///   // Move forward explicitly
///   bloc.next(); // Welcome -> Permissions
///   await Future<void>.delayed(const Duration(milliseconds: 200));
///
///   // Complete flow
///   bloc.complete();
///
///   await sub.cancel();
///   bloc.dispose();
/// }
/// ```
class BlocOnboarding extends BlocModule {
  /// Create a [BlocOnboarding] with an optional [ErrorMapper].
  ///
  /// If none is provided, a [DefaultErrorMapper] instance is used.
  BlocOnboarding({ErrorMapper? errorMapper})
      : _errorMapper = errorMapper ?? const DefaultErrorMapper();

  /// Reactive state holder. Starts from [OnboardingState.idle].
  final BlocGeneral<OnboardingState> _state =
      BlocGeneral<OnboardingState>(OnboardingState.idle());

  /// Logical name for diagnostics and registries.
  static const String name = 'blocOnboarding';

  /// Error mapper for unexpected thrown exceptions in `onEnter`.
  final ErrorMapper _errorMapper;

  List<OnboardingStep> _steps = <OnboardingStep>[];
  Timer? _timer;
  bool _disposed = false;

  /// Exposes the current scheduled timer (debug-only).
  Timer? get timer => _timer;

  /// Whether the bloc has been disposed.
  bool get isDisposed => _disposed;

  // Guards to ignore stale async completions when the step changes.
  int _epoch = 0;

  /// Monotonically increasing token to guard async completions.
  int get epoch => _epoch;

  /// Reactive state stream.
  Stream<OnboardingState> get stateStream => _state.stream;

  /// Current snapshot of the state.
  OnboardingState get state => _state.value;

  /// Convenience: whether the flow is currently running.
  bool get isRunning => state.status == OnboardingStatus.running;

  /// Configure the list of steps and reset to `idle` with `totalSteps`.
  ///
  /// Preconditions:
  /// - The bloc **must not** be disposed.
  ///
  /// Postconditions:
  /// - Cancels any pending timer.
  /// - Stores an **unmodifiable** copy of [steps].
  /// - Emits `idle()` with `totalSteps = steps.length` and `error = null`.
  void configure(List<OnboardingStep> steps) {
    assert(!isDisposed, 'BlocOnboarding has been disposed.');
    _cancelTimer();
    _steps = List<OnboardingStep>.unmodifiable(steps);
    _emit(
      OnboardingState.idle().copyWith(totalSteps: _steps.length, error: null),
    );
  }

  /// Start the flow.
  ///
  /// Behavior:
  /// - If there are no steps, emits `completed` immediately.
  /// - Otherwise emits `running` with `stepIndex = 0`, then executes `onEnter`
  ///   and maybe schedules auto-advance.
  void start() {
    assert(!isDisposed, 'BlocOnboarding has been disposed.');
    if (_steps.isEmpty) {
      _emit(
        state.copyWith(
          status: OnboardingStatus.completed,
          totalSteps: 0,
          error: null,
        ),
      );
      return;
    }
    _cancelTimer();
    _epoch++;
    _emit(
      state.copyWith(
        status: OnboardingStatus.running,
        stepIndex: 0,
        totalSteps: _steps.length,
        error: null,
      ),
    );
    _runOnEnterAndMaybeSchedule(epoch);
  }

  /// Move to the next step or `complete()` if already at the last step.
  void next() {
    assert(!isDisposed, 'BlocOnboarding has been disposed.');
    if (!isRunning) {
      return;
    }
    _cancelTimer();
    if (state.stepIndex + 1 < state.totalSteps) {
      _epoch++;
      _emit(state.copyWith(stepIndex: state.stepIndex + 1, error: null));
      _runOnEnterAndMaybeSchedule(epoch);
    } else {
      complete();
    }
  }

  /// Move to the previous step if possible.
  ///
  /// Policy:
  /// - Cancels any pending timer.
  /// - Executes `onEnter` of the previous step, but **does not** auto-schedule
  ///   an advance (even if `autoAdvanceAfter` is set). This prevents surprising
  ///   jumps right after a manual back action. Callers can still navigate forward
  ///   explicitly or re-run logic via [retryOnEnter].
  void back() {
    assert(!isDisposed, 'BlocOnboarding has been disposed.');
    if (!isRunning) {
      return;
    }
    _cancelTimer();
    if (state.stepIndex > 0) {
      _epoch++;
      _emit(state.copyWith(stepIndex: state.stepIndex - 1, error: null));
      _runOnEnterAndMaybeSchedule(epoch, allowAutoAdvance: false);
    }
  }

  /// Skip the flow and mark it as [OnboardingStatus.skipped].
  ///
  /// Note: does **not** clear [OnboardingState.error].
  void skip() {
    assert(!isDisposed, 'BlocOnboarding has been disposed.');
    _cancelTimer();
    _emit(state.copyWith(status: OnboardingStatus.skipped));
  }

  /// Mark the flow as [OnboardingStatus.completed].
  ///
  /// Note: does **not** clear [OnboardingState.error].
  void complete() {
    assert(!isDisposed, 'BlocOnboarding has been disposed.');
    _cancelTimer();
    _emit(state.copyWith(status: OnboardingStatus.completed));
  }

  /// Clears the error without changing the current step/status.
  void clearError() {
    if (isDisposed) {
      return;
    }
    _emit(state.copyWith(error: null));
  }

  /// Re-runs `onEnter` for the current step (useful after showing an error).
  ///
  /// No-op when disposed or not running.
  void retryOnEnter() {
    if (isDisposed || !isRunning) {
      return;
    }
    _cancelTimer();
    _epoch++;
    _emit(state.copyWith(error: null));
    _runOnEnterAndMaybeSchedule(epoch);
  }

  /// Current step or `null` when not running/out-of-range.
  OnboardingStep? get currentStep {
    if (!isRunning) {
      return null;
    }
    if (state.stepIndex < 0 || state.stepIndex >= _steps.length) {
      return null;
    }
    return _steps[state.stepIndex];
  }

  void _emit(OnboardingState newState) {
    if (!isDisposed) {
      _state.value = newState;
    }
  }

  /// Runs `onEnter` (if any) and schedules auto-advance on success.
  ///
  /// Race-safety:
  /// - Guards with [epochAtCall] and identity checks to ignore stale completions.
  Future<void> _runOnEnterAndMaybeSchedule(
    int epochAtCall, {
    bool allowAutoAdvance = true,
  }) async {
    final OnboardingStep? step = currentStep;
    if (step == null) {
      return;
    }

    // 1) Execute onEnter if present
    if (step.onEnter != null) {
      Either<ErrorItem, Unit> result;

      try {
        result =
            await step.onEnter?.call() ?? Right<ErrorItem, Unit>(Unit.value);
      } catch (e, s) {
        if (isDisposed ||
            epochAtCall != epoch ||
            !identical(step, currentStep)) {
          return;
        }
        final ErrorItem mapped = _errorMapper.fromException(
          e,
          s,
          location:
              'BlocOnboarding.onEnter(step=${state.stepIndex}, title=${step.title})',
        );
        _emit(state.copyWith(error: mapped));
        return;
      }

      // Step changed while awaiting? Ignore stale completion.
      if (isDisposed || epochAtCall != epoch || !identical(step, currentStep)) {
        return;
      }

      // 2) Handle Either
      result.when(
        (ErrorItem err) {
          _emit(state.copyWith(error: err));
          // No auto-advance on error.
        },
        (Unit _) {
          if (allowAutoAdvance) {
            _scheduleAutoAdvanceIfAny();
          }
        },
      );
      return;
    }

    // 3) No onEnter → only schedule auto-advance if defined
    if (isDisposed || epochAtCall != epoch || !identical(step, currentStep)) {
      return;
    }
    if (allowAutoAdvance) {
      _scheduleAutoAdvanceIfAny();
    }
  }

  /// Schedules auto-advance if the current step defines a positive delay.
  void _scheduleAutoAdvanceIfAny() {
    final OnboardingStep? step = currentStep;
    if (step == null) {
      return;
    }
    final Duration? d = step.autoAdvanceAfter;
    if (d == null || d <= Duration.zero) {
      return;
    }

    _timer = Timer(d, () {
      if (!isDisposed && isRunning && identical(step, currentStep)) {
        next();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes resources and stops the bloc.
  ///
  /// Postconditions:
  /// - `_disposed = true`
  /// - Pending timers cancelled
  /// - `_state` disposed
  @override
  void dispose() {
    if (!isDisposed) {
      _disposed = true;
      _cancelTimer();
      _state.dispose();
    }
  }
}
