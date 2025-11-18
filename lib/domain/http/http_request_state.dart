part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Base sealed state for a single HTTP request.
///
/// Implementations carry more specific information about the current step
/// of the request lifecycle. All states share a [requestId] which can be
/// used for log/telemetry correlation.
///
/// Example:
/// ```dart
/// void logState(StateHttpRequest state) {
///   debugPrint('[HTTP ${state.lifecycle.name}] ${state.requestId}');
/// }
/// ```
sealed class StateHttpRequest {
  const StateHttpRequest({
    required this.requestId,
  });

  /// Correlates logs/telemetry for this specific request.
  final String requestId;
}

/// Request has been created but not started yet.
///
/// Example:
/// ```dart
/// final StateHttpRequestCreated created = StateHttpRequestCreated(
///   requestId: 'req-123',
///   method: HttpMethodEnum.get,
///   uri: Uri.parse('https://api.example.com/users'),
/// );
/// ```
class StateHttpRequestCreated extends StateHttpRequest {
  const StateHttpRequestCreated({
    required super.requestId,
    required this.method,
    required this.uri,
  });

  final HttpMethodEnum method;
  final Uri uri;
}

/// Request is currently running and waiting for a response.
///
/// Example:
/// ```dart
/// final StateHttpRequestRunning running = StateHttpRequestRunning(
///   requestId: 'req-123',
///   method: HttpMethodEnum.get,
///   uri: Uri.parse('https://api.example.com/users'),
///   startedAt: DateTime.now().toUtc(),
/// );
/// ```
class StateHttpRequestRunning extends StateHttpRequest {
  const StateHttpRequestRunning({
    required super.requestId,
    required this.method,
    required this.uri,
    this.startedAt,
  });

  final HttpMethodEnum method;
  final Uri uri;
  final DateTime? startedAt;
}

/// Request completed successfully at HTTP level.
///
/// The payload is exposed as a generic JSON-like [body] map.
///
/// Example:
/// ```dart
/// final StateHttpRequestSuccess success = StateHttpRequestSuccess(
///   requestId: 'req-123',
///   method: HttpMethodEnum.get,
///   uri: Uri.parse('https://api.example.com/users/1'),
///   statusCode: 200,
///   body: <String, dynamic>{'id': 1, 'name': 'Alice'},
///   startedAt: started,
///   completedAt: DateTime.now().toUtc(),
/// );
/// print('Duration: ${success.duration}');
/// ```
class StateHttpRequestSuccess extends StateHttpRequest {
  const StateHttpRequestSuccess({
    required super.requestId,
    required this.method,
    required this.uri,
    required this.statusCode,
    required this.body,
    this.startedAt,
    this.completedAt,
  });

  final HttpMethodEnum method;
  final Uri uri;
  final int statusCode;

  /// Parsed payload from the HTTP response.
  final Map<String, dynamic> body;

  final DateTime? startedAt;
  final DateTime? completedAt;

  /// Elapsed time between [startedAt] and [completedAt], or `null` when
  /// timestamps are not available.
  Duration? get duration {
    if (startedAt == null || completedAt == null) {
      return null;
    }
    return completedAt!.difference(startedAt!);
  }
}

/// Request failed due to a technical error.
///
/// This state does **not** model business-level failures embedded in a 2xx
/// payload; those should be detected by [ErrorMapper.fromPayload] at the
/// Repository/Gateway layer.
///
/// Example:
/// ```dart
/// final StateHttpRequestFailure failure = StateHttpRequestFailure(
///   requestId: 'req-123',
///   method: HttpMethodEnum.get,
///   uri: Uri.parse('https://api.example.com/users'),
///   kind: HttpRequestFailureEnum.network,
///   error: const SocketException('No route to host'),
/// );
/// ```
class StateHttpRequestFailure extends StateHttpRequest {
  const StateHttpRequestFailure({
    required super.requestId,
    required this.method,
    required this.uri,
    required this.kind,
    this.statusCode,
    this.error,
    this.startedAt,
    this.failedAt,
    this.retryCount = 0,
  });

  final HttpMethodEnum method;
  final Uri uri;
  final HttpRequestFailureEnum kind;
  final int? statusCode;
  final Object? error;
  final DateTime? startedAt;
  final DateTime? failedAt;

  /// Number of attempts performed so far (for future retry support).
  final int retryCount;

  /// Elapsed time between [startedAt] and [failedAt], or `null` when
  /// timestamps are not available.
  Duration? get duration {
    if (startedAt == null || failedAt == null) {
      return null;
    }
    return failedAt!.difference(startedAt!);
  }
}

/// Request was cancelled before receiving a final response.
///
/// Example:
/// ```dart
/// final StateHttpRequestCancelled cancelled = StateHttpRequestCancelled(
///   requestId: 'req-123',
///   method: HttpMethodEnum.get,
///   uri: Uri.parse('https://api.example.com/users'),
///   startedAt: started,
///   cancelledAt: DateTime.now().toUtc(),
/// );
/// ```
class StateHttpRequestCancelled extends StateHttpRequest {
  const StateHttpRequestCancelled({
    required super.requestId,
    required this.method,
    required this.uri,
    this.startedAt,
    this.cancelledAt,
  });

  final HttpMethodEnum method;
  final Uri uri;
  final DateTime? startedAt;
  final DateTime? cancelledAt;

  Duration? get duration {
    if (startedAt == null || cancelledAt == null) {
      return null;
    }
    return cancelledAt!.difference(startedAt!);
  }
}
