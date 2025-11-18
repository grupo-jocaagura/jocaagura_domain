part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enum keys used for [ModelTraceHttpRequestStep] JSON serialization.
///
/// Keys:
/// - [state]: String representation of the HTTP state (debug/log only).
/// - [timestamp]: ISO-8601 string of the observation moment (UTC).
enum ModelTraceHttpRequestStepEnum {
  state,
  timestamp,
}

final ModelTraceHttpRequestStep defaultStep = ModelTraceHttpRequestStep(
  state: StateHttpRequestRunning(
    requestId: 'REQ-123',
    method: HttpMethodEnum.get,
    uri: Uri.parse('https://api.example.com'),
    startedAt: DateTime.now().toUtc(),
  ),
  timestamp: DateTime.now().toUtc(),
);

/// Single step in an HTTP request lifecycle trace.
///
/// Each step contains the [state] observed at a given [timestamp].
///
/// Serialization notes:
/// - `state` is serialized using `state.toString()` for **diagnostics only**.
///   There is currently **no JSON round-trip** for [StateHttpRequest].
/// - `timestamp` is serialized as ISO-8601 via [DateUtils.dateTimeToString].
///
/// Example:
/// ```dart
/// void main() {
///   final ModelTraceHttpRequestStep step = ModelTraceHttpRequestStep(
///     state: StateHttpRequestRunning(
///       requestId: 'REQ-123',
///       method: HttpMethodEnum.get,
///       uri: Uri.parse('https://api.example.com'),
///       startedAt: DateTime.now().toUtc(),
///     ),
///     timestamp: DateTime.now().toUtc(),
///   );
///
///   final Map<String, dynamic> json = step.toJson();
///   print(json);
/// }
/// ```
class ModelTraceHttpRequestStep extends Model {
  /// Creates a new immutable [ModelTraceHttpRequestStep] instance.
  const ModelTraceHttpRequestStep({
    required this.state,
    required this.timestamp,
  });

  /// HTTP request state at this step.
  ///
  /// This is a rich, in-memory domain object. It is **not** JSON-serializable
  /// at the moment; only `toString()` is used when exporting traces.
  final StateHttpRequest state;

  /// Timestamp (UTC) when this [state] was observed.
  final DateTime timestamp;

  /// Serializes this step to JSON.
  ///
  /// Schema:
  /// ```json
  /// {
  ///   "state": "StateHttpRequestRunning(...)",
  ///   "timestamp": "2025-01-01T12:00:00.000Z"
  /// }
  /// ```
  ///
  /// Notes:
  /// - `state` is **not** guaranteed to be deserializable; it is intended
  ///   for logs/telemetry only.
  /// - `timestamp` uses [DateUtils.dateTimeToString] to ensure ISO-8601 format.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelTraceHttpRequestStepEnum.state.name: state.toString(),
        ModelTraceHttpRequestStepEnum.timestamp.name:
            DateUtils.dateTimeToString(timestamp),
      };

  /// Returns a copy with selected fields replaced.
  @override
  ModelTraceHttpRequestStep copyWith({
    StateHttpRequest? state,
    DateTime? timestamp,
  }) {
    return ModelTraceHttpRequestStep(
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Human-friendly string for debugging.
  @override
  String toString() =>
      'ModelTraceHttpRequestStep(state: $state, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelTraceHttpRequestStep &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(state, timestamp);
}
