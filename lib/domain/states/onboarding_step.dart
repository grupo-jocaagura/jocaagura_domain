part of '../../jocaagura_domain.dart';

/// Result type for step-enter side-effects:
/// - Right(Unit) on success
/// - Left(ErrorItem) on recoverable failure (no throws)
typedef OnEnterResult = FutureOr<Either<ErrorItem, Unit>>;

/// Immutable description of a single onboarding step.
class OnboardingStep {
  /// Creates an onboarding step configuration.
  ///
  /// ### Example
  /// ```dart
  /// OnboardingStep(
  ///   title: 'Permissions',
  ///   onEnter: () async => Right(Unit.value),
  ///   autoAdvanceAfter: const Duration(milliseconds: 600),
  /// );
  /// ```
  const OnboardingStep({
    required this.title,
    this.description,
    this.autoAdvanceAfter,
    this.onEnter,
  });

  /// Human-friendly title.
  final String title;

  /// Optional description.
  final String? description;

  /// Optional auto-advance delay. If set, the step advances after this time
  /// (only after a **successful** [onEnter]).
  final Duration? autoAdvanceAfter;

  /// Optional async side-effect executed **when the step becomes active**.
  ///
  /// Contract:
  /// - Must **not throw**: return `Left(ErrorItem)` instead of throwing.
  /// - Should be fast; heavy work belongs to use cases, called from here.
  /// - On `Left`, the flow **stays** on the current step and sets [OnboardingState.error].
  final OnEnterResult Function()? onEnter;
}
