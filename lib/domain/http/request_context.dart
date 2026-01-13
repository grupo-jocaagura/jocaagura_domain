part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Describe an outbound request in a transport-agnostic way.
///
/// Stores the HTTP-like method and target [uri], plus optional [headers],
/// request [body], and a per-request [timeout].
///
/// The [metadata] field is intended for testing and diagnostics only
/// (e.g. forcing a fake client to return a malformed response).
///
/// Notes:
/// - This type does not perform validation (e.g. allowed methods, required headers).
/// - Map fields are stored by reference. If you pass a mutable map, later mutations
///   will be observable through this instance.
///
/// Functional example:
/// ```dart
/// void main() {
///   final RequestContext ctx = RequestContext(
///     method: 'GET',
///     uri: Uri.parse('https://example.com/health'),
///     headers: <String, String>{'accept': 'application/json'},
///     timeout: const Duration(seconds: 3),
///     metadata: <String, dynamic>{'testMode': true},
///   );
///
///   print('${ctx.method} ${ctx.uri}');
/// }
/// ```
class RequestContext {
  const RequestContext({
    required this.method,
    required this.uri,
    this.headers,
    this.body,
    this.timeout,
    this.metadata = const <String, dynamic>{},
  });

  /// HTTP-like method name (e.g. `GET`, `POST`, `PUT`, `DELETE`).
  final String method;

  /// Target endpoint.
  final Uri uri;

  /// Optional request headers.
  final Map<String, String>? headers;

  /// Optional request body (already decoded as a JSON-like map).
  final Map<String, dynamic>? body;

  /// Optional per-request timeout override.
  final Duration? timeout;

  /// Arbitrary test-only flags (e.g. force malformed response).
  final Map<String, dynamic> metadata;
}
