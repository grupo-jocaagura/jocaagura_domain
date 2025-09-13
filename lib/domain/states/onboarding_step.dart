part of '../../jocaagura_domain.dart';

/// Expected result when entering an onboarding step.
///
/// Contract:
/// - Must **not throw** exceptions. Use `Left(ErrorItem)` instead of throwing.
/// - Should be **fast**; heavy work must be delegated to use cases invoked here.
/// - On success, return `Right(unit)` (no payload).
///
/// Flow semantics:
/// - On `Left`, the flow **remains** on the current step and the error should
///   be propagated (e.g., into `OnboardingState.error`).
typedef OnEnterResult = FutureOr<Either<ErrorItem, Unit>>;

/// Immutable model describing a single step in the onboarding flow.
///
/// Each step provides human-friendly metadata (title, description), an optional
/// auto-advance rule, and an optional side-effect callback (`onEnter`) that runs
/// when the step becomes active.
///
/// ### `onEnter` contract
/// - Must **not throw**; signal errors with `Left(ErrorItem)`.
/// - Should be **fast** (delegate heavy work to external use cases).
/// - On `Left`, the flow **stays** on the same step and propagates the error.
/// - If `onEnter` is `null`, the step is considered an **immediate success**.
///
/// ### Auto-advance (`autoAdvanceAfter`)
/// - If defined and `onEnter` completed with success (`Right(unit)`), the
///   orchestrator **may** auto-advance after the specified [Duration].
/// - This class does **not** handle timers or transitions itself; that belongs
///   to the onboarding controller/orchestrator.
///
/// ### Example
/// ```dart
/// void main() async {
///   // Step with a successful side-effect
///   final OnboardingStep stepOk = OnboardingStep(
///     title: 'Permissions',
///     description: 'Request essential permissions',
///     autoAdvanceAfter: const Duration(milliseconds: 300),
///     onEnter: () async {
///       final bool granted = true; // simulate granted permissions
///       return granted
///           ? Right(unit)
///           : Left(ErrorItem(code: 'PERMISSION_DENIED', message: 'Permissions not granted'));
///     },
///   );
///
///   // Step without side-effect: assumed immediate success
///   final OnboardingStep stepNoOp = OnboardingStep(
///     title: 'Welcome',
///     description: 'Shows a welcome message',
///   );
///
///   final Either<ErrorItem, Unit> r1 = stepOk.onEnter == null ? Right(unit) : await stepOk.onEnter!();
///   final Either<ErrorItem, Unit> r2 = stepNoOp.onEnter == null ? Right(unit) : await stepNoOp.onEnter!();
///
///   print('stepOk:  ${r1.isRight}'); // true
///   print('stepNoOp:${r2.isRight}'); // true
/// }
/// ```
///
/// Notes:
/// - Errors must be modeled with [ErrorItem].
/// - The orchestrator is responsible for applying the auto-advance delay only
///   on success.
class OnboardingStep {
  /// Creates an onboarding step.
  ///
  /// - [title]: required human-friendly title.
  /// - [description]: optional description for UI or logs.
  /// - [autoAdvanceAfter]: if provided, the orchestrator may advance
  ///   automatically after a **successful** [onEnter].
  /// - [onEnter]: optional side-effect executed when the step becomes active.
  const OnboardingStep({
    required this.title,
    this.description,
    this.autoAdvanceAfter,
    this.onEnter,
  });

  /// Human-friendly title (UI/logs).
  final String title;

  /// Optional description (UI/logs).
  final String? description;

  /// Optional auto-advance delay.
  ///
  /// Effective only after a **successful** [onEnter].
  final Duration? autoAdvanceAfter;

  /// Optional side-effect executed when the step becomes active.
  ///
  /// Contract:
  /// - Must **not throw**; return `Left(ErrorItem)` on failure.
  /// - Should remain fast; heavy work belongs to external use cases.
  /// - On `Left`, the flow **remains** on the current step.
  /// - `null` means the step is assumed successful immediately.
  final OnEnterResult Function()? onEnter;
}
