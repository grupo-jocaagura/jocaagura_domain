part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Low-level HTTP client adapter used by the transversal HTTP system.
///
/// Implementations may rely on `dart:io`, `package:http`, Dio or other
/// clients, but those details must stay outside the domain layer.
///
/// Contract:
/// - Must return a [ModelResponseHttpRaw] for every successful transport.
/// - Should throw for network/timeouts, which will be mapped by the
///   higher-level [ServiceHttpRequest] into [ErrorItem] instances.
abstract class AdapterHttpClient {
  /// Sends the given [request] and returns a raw HTTP response.
  ///
  /// Implementations must never swallow errors; instead they should throw
  /// exceptions for network failures or timeouts, allowing the caller to
  /// map them via [ErrorMapper.fromException].
  Future<ModelResponseHttpRaw> send(ModelConfigHttpRequest request);
}

/// Sink for HTTP request telemetry.
///
/// Implementations can push [StateHttpRequest] transitions into logs,
/// metrics or external observability tools.
///
/// Example:
/// ```dart
/// class ConsoleTelemetryHttpRequestSink implements TelemetryHttpRequestSink {
///   @override
///   void onState(StateHttpRequest state) {
///     debugPrint('[HTTP ${state.lifecycle.name}] ${state.requestId}');
///   }
/// }
/// ```
abstract class TelemetryHttpRequestSink {
  /// Called every time a request transitions to a new [StateHttpRequest].
  void onState(StateHttpRequest state);
}
