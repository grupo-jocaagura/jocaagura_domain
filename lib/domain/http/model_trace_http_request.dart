part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enum keys used for [ModelTraceHttpRequest] JSON serialization.
///
/// Keys:
/// - [requestId]: Identifier of the tracked HTTP request.
/// - [steps]: List of serialized [ModelTraceHttpRequestStep] entries.
enum ModelTraceHttpRequestEnum {
  requestId,
  steps,
}

final ModelTraceHttpRequest defaultHttpTrace = ModelTraceHttpRequest(
  requestId: 'REQ-123',
  steps: <ModelTraceHttpRequestStep>[
    ModelTraceHttpRequestStep(
      state: StateHttpRequestCreated(
        requestId: 'REQ-123',
        method: HttpMethodEnum.get,
        uri: Uri.parse('https://api.example.com'),
      ),
      timestamp: DateTime.now().toUtc(),
    ),
  ],
);

/// In-memory trace of a single HTTP request lifecycle.
///
/// This model is intended for debugging/telemetry. It stores the sequence of
/// [ModelTraceHttpRequestStep] instances observed for a given [requestId].
///
/// Notes:
/// - The trace is purely in-memory; it is not intended for full JSON round-trip
///   while [StateHttpRequest] remains non-serializable.
/// - [toJson] is provided for logging/telemetry exports.
/// - Derived properties [startedAt], [finishedAt] and [totalDuration] help
///   summarize timing information.
///
/// Example:
/// ```dart
/// void main() {
///   final ModelTraceHttpRequest trace = ModelTraceHttpRequest(
///     requestId: 'REQ-123',
///     steps: <ModelTraceHttpRequestStep>[
///       ModelTraceHttpRequestStep(
///         state: StateHttpRequestCreated(
///           requestId: 'REQ-123',
///           method: HttpMethodEnum.get,
///           uri: Uri.parse('https://api.example.com'),
///           createdAt: DateTime.now().toUtc(),
///         ),
///         timestamp: DateTime.now().toUtc(),
///       ),
///     ],
///   );
///
///   // Read derived info
///   final DateTime? started = trace.startedAt;
///   final DateTime? finished = trace.finishedAt;
///   final Duration? total = trace.totalDuration;
///
///   // Export for logs
///   final Map<String, dynamic> json = trace.toJson();
///   debugPrint(json.toString());
/// }
/// ```
class ModelTraceHttpRequest extends Model {
  /// Creates a new immutable [ModelTraceHttpRequest] instance.
  const ModelTraceHttpRequest({
    required this.requestId,
    required this.steps,
  });

  /// Identifier of the tracked request.
  final String requestId;

  /// Ordered list of observed steps (from `created` to a terminal state).
  ///
  /// The list is expected to be ordered by [ModelTraceHttpRequestStep.timestamp].
  final List<ModelTraceHttpRequestStep> steps;

  /// Returns the first timestamp in the trace, or `null` when empty.
  DateTime? get startedAt => steps.isEmpty ? null : steps.first.timestamp;

  /// Returns the last timestamp in the trace, or `null` when empty.
  DateTime? get finishedAt => steps.isEmpty ? null : steps.last.timestamp;

  /// Total duration from [startedAt] to [finishedAt], or `null` when
  /// timestamps are not available.
  Duration? get totalDuration {
    final DateTime? s = startedAt;
    final DateTime? f = finishedAt;
    if (s == null || f == null) {
      return null;
    }
    return f.difference(s);
  }

  /// Serializes this trace to JSON for diagnostics/telemetry.
  ///
  /// Schema:
  /// ```json
  /// {
  ///   "requestId": "REQ-123",
  ///   "steps": [
  ///     {
  ///       "state": "StateHttpRequestCreated(...)",
  ///       "timestamp": "2025-01-01T12:00:00.000Z"
  ///     }
  ///   ]
  /// }
  /// ```
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelTraceHttpRequestEnum.requestId.name: requestId,
      ModelTraceHttpRequestEnum.steps.name: steps
          .map<Map<String, dynamic>>(
            (ModelTraceHttpRequestStep s) => s.toJson(),
          )
          .toList(),
    };
  }

  /// Returns a copy with selected fields replaced.
  @override
  ModelTraceHttpRequest copyWith({
    String? requestId,
    List<ModelTraceHttpRequestStep>? steps,
  }) {
    return ModelTraceHttpRequest(
      requestId: requestId ?? this.requestId,
      steps: steps ?? this.steps,
    );
  }

  /// Human-friendly string for debugging.
  @override
  String toString() => 'ModelTraceHttpRequest('
      'requestId: $requestId, '
      'stepsCount: ${steps.length}, '
      'totalDuration: $totalDuration'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelTraceHttpRequest &&
          runtimeType == other.runtimeType &&
          requestId == other.requestId &&
          Utils.listEquals<ModelTraceHttpRequestStep>(steps, other.steps);

  @override
  int get hashCode => Object.hash(
        requestId,
        Utils.listHash<ModelTraceHttpRequestStep>(steps),
      );
}
