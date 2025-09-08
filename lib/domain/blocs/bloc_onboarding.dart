part of '../../jocaagura_domain.dart';

/// BLoC to orchestrate an onboarding flow (sequence of steps).
///
/// - Each step may run an async side-effect on enter returning
///   `FutureOr<Either<ErrorItem, Unit>>`.
/// - If `onEnter` returns `Left(ErrorItem)`, the flow stays on the step and
///   exposes `state.error`.
/// - If `onEnter` throws, the exception is mapped to `ErrorItem` using the
///   injected [ErrorMapper] (defaults to [DefaultErrorMapper]).
///
/// Auto-advance is scheduled **only** when `onEnter` succeeds (Right).
class BlocOnboarding extends BlocModule {
  /// Create a BlocOnboarding with an optional [ErrorMapper].
  ///
  /// If none is provided, a [DefaultErrorMapper] instance is used.
  BlocOnboarding({ErrorMapper? errorMapper})
      : _errorMapper = errorMapper ?? const DefaultErrorMapper();
  final BlocGeneral<OnboardingState> _state =
      BlocGeneral<OnboardingState>(OnboardingState.idle());

  static const String name = 'blocOnboarding';

  /// Error mapper for unexpected thrown exceptions in `onEnter`.
  final ErrorMapper _errorMapper;

  List<OnboardingStep> _steps = <OnboardingStep>[];
  Timer? _timer;
  bool _disposed = false;

  // Guards to ignore stale async completions when the step changes.
  int _epoch = 0;

  /// Reactive state access.
  Stream<OnboardingState> get stateStream => _state.stream;
  OnboardingState get state => _state.value;
  bool get isRunning => state.status == OnboardingStatus.running;

  void configure(List<OnboardingStep> steps) {
    assert(!_disposed, 'BlocOnboarding has been disposed.');
    _cancelTimer();
    _steps = List<OnboardingStep>.unmodifiable(steps);
    _emit(
      OnboardingState.idle().copyWith(totalSteps: _steps.length, error: null),
    );
  }

  void start() {
    assert(!_disposed, 'BlocOnboarding has been disposed.');
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
    _runOnEnterAndMaybeSchedule(_epoch);
  }

  void next() {
    assert(!_disposed, 'BlocOnboarding has been disposed.');
    if (!isRunning) {
      return;
    }
    _cancelTimer();
    if (state.stepIndex + 1 < state.totalSteps) {
      _epoch++;
      _emit(state.copyWith(stepIndex: state.stepIndex + 1, error: null));
      _runOnEnterAndMaybeSchedule(_epoch);
    } else {
      complete();
    }
  }

  void back() {
    assert(!_disposed, 'BlocOnboarding has been disposed.');
    if (!isRunning) {
      return;
    }
    _cancelTimer();
    if (state.stepIndex > 0) {
      _epoch++;
      _emit(state.copyWith(stepIndex: state.stepIndex - 1, error: null));
      _runOnEnterAndMaybeSchedule(_epoch);
    }
  }

  void skip() {
    assert(!_disposed, 'BlocOnboarding has been disposed.');
    _cancelTimer();
    _emit(state.copyWith(status: OnboardingStatus.skipped));
  }

  void complete() {
    assert(!_disposed, 'BlocOnboarding has been disposed.');
    _cancelTimer();
    _emit(state.copyWith(status: OnboardingStatus.completed));
  }

  /// Clears the error without changing the current step/status.
  void clearError() {
    if (_disposed) {
      return;
    }
    _emit(state.copyWith(error: null));
  }

  /// Re-runs `onEnter` for the current step (useful after showing an error).
  void retryOnEnter() {
    // No-op si el bloc ya no está vivo o si no está en ejecución.
    if (_disposed || !isRunning) {
      return;
    }

    _cancelTimer();
    _epoch++;
    // Evita assert de clearError; _emit ya protege contra _disposed.
    _emit(state.copyWith(error: null));
    _runOnEnterAndMaybeSchedule(_epoch);
  }

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
    if (!_disposed) {
      _state.value = newState;
    }
  }

  Future<void> _runOnEnterAndMaybeSchedule(int epochAtCall) async {
    final OnboardingStep? step = currentStep;
    if (step == null) {
      return;
    }

    // 1) Ejecuta onEnter si está definido
    if (step.onEnter != null) {
      Either<ErrorItem, Unit> result;

      try {
        result =
            await step.onEnter?.call() ?? Right<ErrorItem, Unit>(Unit.value);
      } catch (e, s) {
        if (_disposed ||
            epochAtCall != _epoch ||
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

      // Si cambió de paso mientras esperábamos, ignorar.
      if (_disposed || epochAtCall != _epoch || !identical(step, currentStep)) {
        return;
      }

      // 2) Maneja Either con `when`
      result.when(
        (ErrorItem err) {
          _emit(state.copyWith(error: err));
          // No auto-advance si hay error.
        },
        (Unit _) {
          _scheduleAutoAdvanceIfAny();
        },
      );
      return;
    }

    // 3) Sin onEnter → solo auto-advance si aplica
    if (_disposed || epochAtCall != _epoch || !identical(step, currentStep)) {
      return;
    }
    _scheduleAutoAdvanceIfAny();
  }

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
      if (!_disposed && isRunning && identical(step, currentStep)) {
        next();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimer();
    _state.dispose();
  }
}
