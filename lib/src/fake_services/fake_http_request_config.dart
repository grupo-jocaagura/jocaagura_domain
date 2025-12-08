import '../../jocaagura_domain.dart';

/// Runtime configuration for [FakeHttpRequest].
///
/// This config allows tests/POCs to:
/// - Register canned responses per `method + uri`.
/// - Simulate latency.
/// - Force transport-level failures per method.
///
/// Keys for [_cannedResponses] / [_errorRoutes] use the format:
/// `"GET https://api.example.com/v1/users/me"`.
class FakeHttpRequestConfig {
  /// Creates a new immutable [FakeHttpRequestConfig] instance.
  const FakeHttpRequestConfig({
    this.latency = Duration.zero,
    this.throwOnGet = false,
    this.throwOnPost = false,
    this.throwOnPut = false,
    this.throwOnDelete = false,
    this.cannedResponses = const <String, Map<String, dynamic>>{},
    this.cannedConfigs = const <String, ModelConfigHttpRequest>{},
    this.errorRoutes = const <String, String>{},
  });

  /// Artificial latency applied to every request.
  ///
  /// When `Duration.zero`, calls resolve immediately.
  final Duration latency;

  /// If `true`, every GET call throws a [StateError].
  final bool throwOnGet;

  /// If `true`, every POST call throws a [StateError].
  final bool throwOnPost;

  /// If `true`, every PUT call throws a [StateError].
  final bool throwOnPut;

  /// If `true`, every DELETE call throws a [StateError].
  final bool throwOnDelete;

  /// Predefined JSON-like responses per route key.
  ///
  /// Route key format:
  /// `"METHOD <uri.toString()>"`, e.g. `"GET https://api.example.com/ping"`.
  final Map<String, Map<String, dynamic>> cannedResponses;

  /// Predefined [ModelConfigHttpRequest] per route key.
  ///
  /// These configurations are converted to JSON via [ModelConfigHttpRequest.toJson]
  /// and used as canned responses, allowing tests to assert which configuration
  /// was used for a given call.
  final Map<String, ModelConfigHttpRequest> cannedConfigs;

  /// Map of route key → error message.
  ///
  /// When a route key is present here, the fake will throw a [StateError] with
  /// the associated message. Gateways are expected to map such errors to
  /// [ErrorItem] via [ErrorMapper.fromException].
  final Map<String, String> errorRoutes;

  /// Helper that builds a canned response emulating a typical `http.Response`.
  ///
  /// Use this factory to avoid shape mismatches when registering
  /// [cannedResponses]. All fields default to sensible HTTP values and can be
  /// overridden as needed.
  static Map<String, dynamic> cannedHttpResponse({
    required HttpMethodEnum method,
    required Uri uri,
    int statusCode = 200,
    String reasonPhrase = 'OK',
    Map<String, String> headers = const <String, String>{
      'content-type': 'application/json; charset=utf-8',
    },
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, dynamic> metadata = const <String, dynamic>{},
    Duration? timeout,
  }) {
    return <String, dynamic>{
      'method': method.name,
      'uri': uri.toString(),
      'statusCode': statusCode,
      'reasonPhrase': reasonPhrase,
      'headers': Map<String, String>.from(headers),
      'body': Map<String, dynamic>.from(body),
      'metadata': Map<String, dynamic>.from(metadata),
      'timeout': timeout?.inMilliseconds,
      'fake': true,
      'source': 'FakeHttpRequest',
    };
  }

  /// Default configuration with no latency and no canned routes.
  static const FakeHttpRequestConfig none = FakeHttpRequestConfig();
}
