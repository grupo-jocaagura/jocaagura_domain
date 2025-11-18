import '../../jocaagura_domain.dart';

/// Default implementation of [RepositoryHttpRequest].
///
/// Responsibilities:
/// - Delegate HTTP calls to a [GatewayHttpRequest].
/// - Propagate any [ErrorItem] produced by the gateway.
/// - Build a normalized [ModelConfigHttpRequest] that describes the executed
///   call (method, uri, headers, body, timeout, metadata).
///
/// This repository **does not** expose the raw JSON payload; that
/// responsibility belongs to feature-specific repositories that sit on top
/// of this transversal HTTP layer.
///
/// ### Functional example
/// ```dart
/// void main() async {
///   final ServiceHttpRequest service = FakeHttpRequest(); // test double
///   final GatewayHttpRequest gateway = GatewayHttpRequestImpl(service: service);
///   final RepositoryHttpRequest repository = RepositoryHttpRequestImpl(gateway);
///
///   final Uri uri = Uri.parse('https://api.example.com/v1/users/me');
///
///   final Either<ErrorItem, ModelConfigHttpRequest> result = await repository.get(
///     uri,
///     metadata: <String, Object?>{
///       'feature': 'userProfile',
///       'operation': 'fetchMe',
///     },
///   );
///
///   result.fold(
///     (ErrorItem error) {
///       // Handle domain error (network, payload, etc.)
///       debugPrint('HTTP GET failed: $error');
///     },
///     (ModelConfigHttpRequest config) {
///       // Config describes what was executed; can be logged or used for retry.
///       debugPrint('HTTP GET executed: $config');
///     },
///   );
/// }
/// ```
class RepositoryHttpRequestImpl implements RepositoryHttpRequest {
  /// Creates a new [RepositoryHttpRequestImpl] bound to a [GatewayHttpRequest].
  const RepositoryHttpRequestImpl(this._gateway);

  /// Gateway responsible for transport and error mapping.
  final GatewayHttpRequest _gateway;

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> get(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final Either<ErrorItem, Map<String, dynamic>> result = await _gateway.get(
      uri,
      headers: headers,
      timeout: timeout,
      metadata: metadata,
    );

    return result.fold(
      (ErrorItem error) => Left<ErrorItem, ModelConfigHttpRequest>(error),
      (Map<String, dynamic> _) => Right<ErrorItem, ModelConfigHttpRequest>(
        ModelConfigHttpRequest(
          method: HttpMethodEnum.get,
          uri: uri,
          headers: headers,
          timeout: timeout,
          metadata: metadata,
        ),
      ),
    );
  }

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> post(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final Either<ErrorItem, Map<String, dynamic>> result = await _gateway.post(
      uri,
      headers: headers,
      body: body,
      timeout: timeout,
      metadata: metadata,
    );

    return result.fold(
      (ErrorItem error) => Left<ErrorItem, ModelConfigHttpRequest>(error),
      (Map<String, dynamic> _) => Right<ErrorItem, ModelConfigHttpRequest>(
        ModelConfigHttpRequest(
          method: HttpMethodEnum.post,
          uri: uri,
          headers: headers,
          body: normalizeBody(body),
          timeout: timeout,
          metadata: metadata,
        ),
      ),
    );
  }

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> put(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final Either<ErrorItem, Map<String, dynamic>> result = await _gateway.put(
      uri,
      headers: headers,
      body: body,
      timeout: timeout,
      metadata: metadata,
    );

    return result.fold(
      (ErrorItem error) => Left<ErrorItem, ModelConfigHttpRequest>(error),
      (Map<String, dynamic> _) => Right<ErrorItem, ModelConfigHttpRequest>(
        ModelConfigHttpRequest(
          method: HttpMethodEnum.put,
          uri: uri,
          headers: headers,
          body: normalizeBody(body),
          timeout: timeout,
          metadata: metadata,
        ),
      ),
    );
  }

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> delete(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final Either<ErrorItem, Map<String, dynamic>> result =
        await _gateway.delete(
      uri,
      headers: headers,
      timeout: timeout,
      metadata: metadata,
    );

    return result.fold(
      (ErrorItem error) => Left<ErrorItem, ModelConfigHttpRequest>(error),
      (Map<String, dynamic> _) => Right<ErrorItem, ModelConfigHttpRequest>(
        ModelConfigHttpRequest(
          method: HttpMethodEnum.delete,
          uri: uri,
          headers: headers,
          timeout: timeout,
          metadata: metadata,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Normalizes [body] into a `Map<String, dynamic>?` compatible with
  /// [ModelConfigHttpRequest.body].
  ///
  /// Contracts:
  /// - `null` → `null`.
  /// - `Map` → normalized via [Utils.mapFromDynamic].
  /// - Any other type → wrapped into `{'value': body}` for traceability.
  Map<String, dynamic> normalizeBody(Object? body) {
    if (body == null) {
      return <String, dynamic>{};
    }
    if (body is Map) {
      return Utils.mapFromDynamic(body);
    }
    return <String, dynamic>{'value': body};
  }
}
