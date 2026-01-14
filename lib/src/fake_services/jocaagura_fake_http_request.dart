import '../../jocaagura_domain.dart';

/// In-memory fake HTTP client intended for tests and POCs.
///
/// Dispatch rules (in order):
/// 1) Validate not disposed.
/// 2) Apply global method failures (e.g. [FakeHttpRequestConfig.throwOnGet]).
/// 3) Apply per-route failures via [FakeHttpRequestConfig.errorRoutes].
/// 4) Apply artificial latency via [FakeHttpRequestConfig.latency].
/// 5) Return a canned response if configured (responses/configs).
/// 6) Dispatch to the first [VirtualCrudService] whose [VirtualCrudService.canHandle]
///    returns `true`.
///
/// If no route matches any of the above, a [StateError] is thrown.
///
/// Notes:
/// - This fake is transport-agnostic; it returns JSON-like maps.
/// - Services are checked in the order they were provided.
/// - [resetAll] is a convenience helper to keep tests isolated.
///
/// This type implements [ServiceHttp] to plug into gateways without external deps.
class JocaaguraFakeHttpRequest implements ServiceHttp {
  /// Creates a new fake HTTP request dispatcher.
  ///
  /// - [services] are evaluated in order; the first that can handle a request wins.
  /// - [config] controls latency, canned responses, and forced failures.
  JocaaguraFakeHttpRequest({
    required List<VirtualCrudService> services,
    FakeHttpRequestConfig config = FakeHttpRequestConfig.none,
  })  : _services = List<VirtualCrudService>.unmodifiable(services),
        _config = config;

  final List<VirtualCrudService> _services;
  final FakeHttpRequestConfig _config;

  bool _isDisposed = false;

  @override
  Future<Map<String, dynamic>> get({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final Uri uri = _buildUri(url: url, queryParameters: queryParameters);
    final RequestContext ctx = RequestContext(
      method: 'GET',
      uri: uri,
      headers: headers,
    );
    return _dispatch(ctx);
  }

  @override
  Future<Map<String, dynamic>> post({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final Uri uri = _buildUri(url: url, queryParameters: null);
    final Map<String, dynamic>? mapBody = _coerceJsonMapBody(body);

    final RequestContext ctx = RequestContext(
      method: 'POST',
      uri: uri,
      headers: headers,
      body: mapBody,
    );
    return _dispatch(ctx);
  }

  @override
  Future<Map<String, dynamic>> put({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final Uri uri = _buildUri(url: url, queryParameters: null);
    final Map<String, dynamic>? mapBody = _coerceJsonMapBody(body);

    final RequestContext ctx = RequestContext(
      method: 'PUT',
      uri: uri,
      headers: headers,
      body: mapBody,
    );
    return _dispatch(ctx);
  }

  @override
  Future<void> delete({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final Uri uri = _buildUri(url: url, queryParameters: queryParameters);
    final RequestContext ctx = RequestContext(
      method: 'DELETE',
      uri: uri,
      headers: headers,
    );
    await _dispatch(ctx);
  }

  @override
  void dispose() {
    _isDisposed = true;
  }

  /// Calls [VirtualCrudService.reset] on every registered service.
  void resetAll() {
    for (final VirtualCrudService service in _services) {
      service.reset();
    }
  }

  Future<Map<String, dynamic>> _dispatch(RequestContext ctx) async {
    _ensureNotDisposed();

    _maybeThrowGlobalMethodError(ctx.method);
    _maybeThrowRouteError(ctx.method, ctx.uri);

    await _maybeDelay();

    final String key = _routeKey(ctx.method, ctx.uri);

    final Map<String, dynamic>? canned = _config.cannedResponses[key];
    if (canned != null) {
      return _copyJsonMap(canned);
    }

    final ModelConfigHttpRequest? cannedCfg = _config.cannedConfigs[key];
    if (cannedCfg != null) {
      // Assumes ModelConfigHttpRequest exposes toJson().
      final Map<String, dynamic> json = cannedCfg.toJson();
      return _copyJsonMap(json);
    }

    for (final VirtualCrudService service in _services) {
      if (service.canHandle(ctx)) {
        final Map<String, dynamic> result = await service.handle(ctx);
        return _copyJsonMap(result);
      }
    }

    throw StateError('No VirtualCrudService could handle: $key');
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('JocaaguraFakeHttpRequest is disposed.');
    }
  }

  Future<void> _maybeDelay() async {
    final Duration latency = _config.latency;
    if (latency == Duration.zero) {
      return;
    }
    await Future<void>.delayed(latency);
  }

  void _maybeThrowGlobalMethodError(String method) {
    final String m = method.toUpperCase();
    if (m == 'GET' && _config.throwOnGet) {
      throw StateError('Forced GET failure by config.');
    }
    if (m == 'POST' && _config.throwOnPost) {
      throw StateError('Forced POST failure by config.');
    }
    if (m == 'PUT' && _config.throwOnPut) {
      throw StateError('Forced PUT failure by config.');
    }
    if (m == 'DELETE' && _config.throwOnDelete) {
      throw StateError('Forced DELETE failure by config.');
    }
  }

  Uri _normalizeUri(Uri uri) {
    final List<String> keys = uri.queryParameters.keys.toList()..sort();
    final Map<String, String> qp = <String, String>{
      for (final String k in keys) k: uri.queryParameters[k] ?? '',
    };
    return uri.replace(queryParameters: qp.isEmpty ? null : qp);
  }

  String _routeKey(String method, Uri uri) {
    final Uri u = _normalizeUri(uri);
    return '${method.toUpperCase()} $u';
  }

  void _maybeThrowRouteError(String method, Uri uri) {
    final String key = _routeKey(method, uri);
    final String? message = _config.errorRoutes[key];
    if (message != null) {
      throw StateError(message);
    }
  }

  Uri _buildUri({
    required String url,
    required Map<String, dynamic>? queryParameters,
  }) {
    final Uri base = Uri.parse(url);

    if (queryParameters == null || queryParameters.isEmpty) {
      return base;
    }

    final Map<String, String> qp = <String, String>{
      ...base.queryParameters,
      ...queryParameters
          .map((String k, dynamic v) => MapEntry<String, String>(k, '$v')),
    };

    return base.replace(queryParameters: qp);
  }

  Map<String, dynamic>? _coerceJsonMapBody(dynamic body) {
    if (body == null) {
      return null;
    }
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      // Safely coerce Map<dynamic, dynamic> into Map<String, dynamic>.
      final Map<String, dynamic> out = <String, dynamic>{};
      for (final MapEntry<dynamic, dynamic> entry in body.entries) {
        final Object? k = entry.key;
        if (k is! String) {
          throw ArgumentError.value(
            body,
            'body',
            'Body map keys must be String.',
          );
        }
        out[k] = entry.value;
      }
      return out;
    }

    throw ArgumentError.value(body, 'body', 'Body must be a JSON-like Map.');
  }

  Map<String, dynamic> _copyJsonMap(Map<String, dynamic> input) {
    // Shallow copy is usually enough for “JSON-like payload” contract.
    // If you need deep copy later, it can be added without changing callers.
    return Map<String, dynamic>.from(input);
  }
}

class FakeHttpBusinessException implements Exception {
  FakeHttpBusinessException(this.payload);

  final Map<String, dynamic> payload;

  @override
  String toString() {
    final Object? msg = payload['message'];
    return msg == null ? 'FakeHttpBusinessException' : '$msg';
  }
}
