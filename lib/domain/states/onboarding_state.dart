part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the JSON keys of [OnboardingState] to keep a **stable contract**.
///
/// The `name` of each enum value is used as the JSON key in [toJson] and
/// consumed in [OnboardingState.fromJson].
enum OnboardingStateEnum {
  status,
  stepIndex,
  totalSteps,
  error,
}

/// Status for the onboarding flow.
///
/// Semantics:
/// - [idle]: nothing configured or not started yet.
/// - [running]: flow in progress; UI can render the current step.
/// - [completed]: flow finished successfully.
/// - [skipped]: user chose to skip the flow.
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
/// Encapsulates the current [status], the zero-based [stepIndex], the
/// [totalSteps] configured, and an optional domain [error].
///
/// ### Contracts & responsibility
/// - This model is **pure** and **immutable**: it does not validate business
///   invariants. Range checks (e.g. `0 ≤ stepIndex < totalSteps`) and semantic
///   coherence (e.g. `running ⇒ totalSteps > 0`) **must be ensured by the
///   orchestrator** (e.g. `BlocOnboarding`).
/// - JSON contract is **stable** and uses enum `name`s.
///
/// ### Convenience getters
/// - [hasStep]: `true` only when `status == running && totalSteps > 0`.
/// - [stepNumber]: user-facing 1-based index (`stepIndex + 1`) or `0` when
///   there is no current step.
///
/// ### JSON round trip (example)
/// ```dart
/// final OnboardingState state = OnboardingState.idle()
///     .copyWith(status: OnboardingStatus.running, totalSteps: 3);
///
/// print(state.toJson());
/// // {status: running, stepIndex: 0, totalSteps: 3, error: null}
///
/// final OnboardingState restored = OnboardingState.fromJson(state.toJson());
/// assert(restored == state);
/// ```
class OnboardingState extends Model {
  /// Internal constructor (use factories).
  const OnboardingState._({
    required this.status,
    required this.stepIndex,
    required this.totalSteps,
    required this.error,
  });

  /// Creates the default **idle** state.
  ///
  /// Defaults:
  /// - `status = idle`
  /// - `stepIndex = 0`
  /// - `totalSteps = 0`
  /// - `error = null`
  factory OnboardingState.idle() {
    return const OnboardingState._(
      status: OnboardingStatus.idle,
      stepIndex: 0,
      totalSteps: 0,
      error: null,
    );
  }

  /// Creates an [OnboardingState] from a JSON map.
  ///
  /// Parsing policy:
  /// - `status`: parsed by enum `name`; unknown values fallback to [OnboardingStatus.idle].
  /// - `stepIndex`/`totalSteps`: parsed with [Utils.getIntegerFromDynamic]; invalid inputs
  ///   become `0` (NaN/Infinity/strings not parseable).
  /// - `error`:
  ///   - `null` ⇒ `null`
  ///   - `Map<String,dynamic>` or loosely typed `Map` ⇒ [ErrorItem.fromJson]
  ///   - `String` (JSON) ⇒ parsed via [Utils.mapFromDynamic]; empty map ⇒ [defaultErrorItem]
  ///   - Any other type ⇒ [defaultErrorItem]
  ///
  /// > Nota: esta política busca **resiliencia** ante entradas inconsistentes;
  /// > las validaciones de negocio deben hacerse fuera de este modelo.
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

  /// Zero-based index of the current step (valid when [status] is [OnboardingStatus.running]).
  final int stepIndex;

  /// Total number of steps configured.
  final int totalSteps;

  /// Optional domain error describing orchestration failures.
  final ErrorItem? error;

  /// Convenience: `true` when there is a current step to render (`running` and `totalSteps > 0`).
  bool get hasStep => status == OnboardingStatus.running && totalSteps > 0;

  /// Convenience: 1-based progress for UI; `0` when there is no current step.
  int get stepNumber => hasStep ? stepIndex + 1 : 0;

  static const Unit _u = Unit.value;

  /// Returns a copy with overrides.
  ///
  /// Use the sentinel [Unit.value] in [error] (default) to **preserve** the current value.
  /// Pass `null` explicitly to **clear** the error.
  ///
  /// Examples:
  /// ```dart
  /// // Preserve current error (default sentinel)
  /// final s2 = s1.copyWith(status: OnboardingStatus.running);
  ///
  /// // Clear error
  /// final s3 = s1.copyWith(error: null);
  /// ```
  /// ### Preconditions
  /// - When [status] is [OnboardingStatus.running], the orchestrator must ensure:
  ///   - [totalSteps] > 0
  ///   - 0 ≤ [stepIndex] < [totalSteps]
  ///
  /// ### Postconditions
  /// - [hasStep] and [stepNumber] reflect these guarantees.
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

  /// Serializes this [OnboardingState] into a JSON map using stable keys and `enum.name`.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        OnboardingStateEnum.status.name: status.name,
        OnboardingStateEnum.stepIndex.name: stepIndex,
        OnboardingStateEnum.totalSteps.name: totalSteps,
        OnboardingStateEnum.error.name: error?.toJson(),
      };

  /// Value equality based on all fields.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          stepIndex == other.stepIndex &&
          totalSteps == other.totalSteps &&
          error == other.error;

  /// Combines all fields for hashing.
  @override
  int get hashCode => Object.hash(status, stepIndex, totalSteps, error);

  /// String representation delegating to JSON for developer-friendly output.
  @override
  String toString() => 'OnboardingState(${toJson()})';

  /// Parse [OnboardingStatus] from `enum.name` with [OnboardingStatus.idle] fallback.
  static OnboardingStatus _statusFromString(String? value) {
    return OnboardingStatus.values.firstWhere(
      (OnboardingStatus e) => e.name == value,
      orElse: () => OnboardingStatus.idle,
    );
  }
}
