part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Supported HTTP methods for the transversal HTTP system.
///
/// This enum is used instead of raw strings to keep method handling type-safe.
enum HttpMethodEnum {
  get,
  post,
  put,
  patch,
  delete,
}

/// High-level lifecycle bucket for HTTP requests.
///
/// Used for telemetry, dashboards and log aggregation. Concrete
/// [StateHttpRequest] implementations can be mapped into one of these
/// values via helper extensions.
enum HttpRequestLifecycleEnum {
  /// Request was created but not started yet.
  created,

  /// Request is in-flight, waiting for a response.
  running,

  /// Request completed successfully at HTTP level (typically 2xx).
  succeeded,

  /// Request failed (network error, non-2xx status, timeout, parsing, etc.).
  failed,

  /// Request was cancelled before completion.
  cancelled,
}

/// Technical failure classification for HTTP requests.
///
/// This enum focuses on transport/protocol-level failures, not business
/// errors encoded in a 2xx payload.
enum HttpRequestFailureEnum {
  /// Underlying network issue: no HTTP response was received.
  network,

  /// Server returned a non-success HTTP status code (4xx, 5xx, ...).
  httpStatus,

  /// Request exceeded its configured timeout.
  timeout,

  /// Response body could not be parsed/decoded.
  parsing,

  /// Any other error not covered by the specific kinds.
  unknown,
}
