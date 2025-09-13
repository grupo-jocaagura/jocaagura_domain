part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the properties of [OnboardingState] for stable JSON contracts.
enum OnboardingStateEnum {
  status,
  stepIndex,
  totalSteps,
  error,
}

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

/// Immutable state for the onboarding flow.
///
/// Encapsulates current [status], step position, total steps and possible [error].
///
/// ### Example
/// ```dart
/// final OnboardingState state = OnboardingState.idle()
///     .copyWith(status: OnboardingStatus.running, totalSteps: 3);
///
/// print(state.toJson());
/// // {status: running, stepIndex: 0, totalSteps: 3, error: null}
/// ```
class OnboardingState extends Model {
  /// Internal constructor.
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

  /// Creates an [OnboardingState] from JSON.
  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    final OnboardingStatus status = _statusFromString(
      Utils.getStringFromDynamic(json[OnboardingStateEnum.status.name]),
    );

    final int stepIndex = Utils.getIntegerFromDynamic(
      json[OnboardingStateEnum.stepIndex.name],
    );

    final int totalSteps = Utils.getIntegerFromDynamic(
      json[OnboardingStateEnum.totalSteps.name],
    );

    ErrorItem? restoredError;
    final Object? rawError = json[OnboardingStateEnum.error.name];
    if (rawError == null) {
      restoredError = null;
    } else if (rawError is Map<String, dynamic>) {
      restoredError = ErrorItem.fromJson(rawError);
    } else if (rawError is Map) {
      restoredError = ErrorItem.fromJson(
        rawError.map(
          (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
        ),
      );
    } else if (rawError is String) {
      try {
        final Map<String, dynamic> m = Utils.mapFromDynamic(rawError);
        restoredError = m.isEmpty ? defaultErrorItem : ErrorItem.fromJson(m);
      } catch (_) {
        restoredError = defaultErrorItem;
      }
    } else {
      restoredError = defaultErrorItem;
    }

    return OnboardingState._(
      status: status,
      stepIndex: stepIndex,
      totalSteps: totalSteps,
      error: restoredError,
    );
  }

  /// Current status of the flow.
  final OnboardingStatus status;

  /// Zero-based index of the current step (valid when [status] is running).
  final int stepIndex;

  /// Total number of steps configured.
  final int totalSteps;

  /// Optional error if orchestration fails.
  final ErrorItem? error;

  /// Convenience: true when there is a current step to show.
  bool get hasStep => status == OnboardingStatus.running && totalSteps > 0;

  /// Convenience: 1-based progress (for UI).
  int get stepNumber => hasStep ? stepIndex + 1 : 0;

  static const Unit _u = Unit.value;

  /// Returns a copy with overrides; use [Unit.value] sentinel to keep fields.
  @override
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

  /// Serializes this [OnboardingState] into JSON.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        OnboardingStateEnum.status.name: status.name,
        OnboardingStateEnum.stepIndex.name: stepIndex,
        OnboardingStateEnum.totalSteps.name: totalSteps,
        OnboardingStateEnum.error.name: error?.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          stepIndex == other.stepIndex &&
          totalSteps == other.totalSteps &&
          error == other.error;

  @override
  int get hashCode => Object.hash(status, stepIndex, totalSteps, error);

  @override
  String toString() => 'OnboardingState(${toJson()})';

  /// Parse [OnboardingStatus] from string with fallback.
  static OnboardingStatus _statusFromString(String? value) {
    return OnboardingStatus.values.firstWhere(
      (OnboardingStatus e) => e.name == value,
      orElse: () => OnboardingStatus.idle,
    );
  }
}
