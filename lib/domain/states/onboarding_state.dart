part of '../../jocaagura_domain.dart';

/// Status for the onboarding flow.
enum OnboardingStatus {
  /// Nothing configured or not started yet.
  idle,

  /// Flow is in progress.
  running,

  /// Flow finished successfully.
  completed,

  /// Flow was skipped by the user.
  skipped,
}

/// Reactive state for the onboarding flow.
class OnboardingState {
  /// Returns a new initial state (idle, no steps).
  const OnboardingState._({
    required this.status,
    required this.stepIndex,
    required this.totalSteps,
    required this.error,
  });

  /// Creates the default idle state.
  factory OnboardingState.idle() {
    return const OnboardingState._(
      status: OnboardingStatus.idle,
      stepIndex: 0,
      totalSteps: 0,
      error: null,
    );
  }

  /// Current status.
  final OnboardingStatus status;

  /// Zero-based index of the current step (valid when [status] is [OnboardingStatus.running]).
  final int stepIndex;

  /// Total number of steps configured.
  final int totalSteps;

  /// Optional domain error (if any orchestration fails).
  final ErrorItem? error;

  /// Convenience: true when there is a current step to show.
  bool get hasStep => status == OnboardingStatus.running && totalSteps > 0;

  /// Convenience: 1-based progress (for UI).
  int get stepNumber => hasStep ? stepIndex + 1 : 0;

  static const Unit _u = Unit.value;

  /// Returns a copy with overrides; use [Unit.value] sentinel to keep fields.
  ///
  /// ### Example
  /// ```dart
  /// final OnboardingState s2 = s1.copyWith(
  ///   status: OnboardingStatus.running,
  ///   stepIndex: 0,
  ///   totalSteps: 3,
  /// );
  /// ```
  OnboardingState copyWith({
    OnboardingStatus? status,
    int? stepIndex,
    int? totalSteps,
    Object? error = _u,
  }) {
    return OnboardingState._(
      status: status ?? this.status,
      stepIndex: stepIndex ?? this.stepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      error: identical(error, _u) ? this.error : error as ErrorItem?,
    );
  }
}
