import '../../jocaagura_domain.dart';

/// In-memory fake implementation of [ServiceHttpRequest] for tests and POCs.
///
/// Behavior:
/// - Resolves HTTP methods (GET/POST/PUT/DELETE) using canned responses
///   registered in [FakeHttpRequestConfig].
/// - When no canned response exists for a route, it returns an "echo" payload
///   with the request parameters (useful for smoke tests).
/// - Can simulate latency and forced errors per method/route.
///
/// Route keys:
/// - Internally, this fake builds a route key as:
///   `"METHOD ${uri.toString()}"`, e.g. `"GET https://api.example.com/ping"`.
///
/// Error behavior:
/// - If the config flag `throwOnX` (per method) is `true`, a [StateError] is
///   thrown for **every** call of that method.
/// - If the route key is present in `errorRoutes`, a [StateError] is thrown
///   with the configured message.
/// - Gateways must catch these errors and map them into [ErrorItem] using
///   [ErrorMapper.fromException].
///
/// ### Example
/// ```dart
/// void main() async {
///   const FakeHttpRequestConfig config = FakeHttpRequestConfig(
///     latency: Duration(milliseconds: 10),
///     cannedResponses: <String, Map<String, dynamic>>{
///       'GET https://api.example.com/ping': <String, dynamic>{'ok': true},
///     },
///   );
///
///   final FakeHttpRequest service = FakeHttpRequest(config: config);
///
///   final Map<String, dynamic> ok = await service.get(
///     Uri.parse('https://api.example.com/ping'),
///     metadata: <String, dynamic>{'feature': 'healthcheck'},
///   );
///
///   assert(ok['ok'] == true);
/// }
/// ```
class FakeHttpRequest implements ServiceHttpRequest {
  /// Creates a new fake HTTP service with the provided [config].
  FakeHttpRequest({FakeHttpRequestConfig config = FakeHttpRequestConfig.none})
      : _config = config,
        _canned = _buildCanned(config),
        _errors = Map<String, String>.unmodifiable(config.errorRoutes);

  final FakeHttpRequestConfig _config;

  /// Normalized map of route key → canned JSON payload.
  final Map<String, Map<String, dynamic>> _canned;

  /// Map of route key → error message to be thrown as [StateError].
  final Map<String, String> _errors;

  bool _disposed = false;

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('FakeHttpRequest has been disposed');
    }
  }

  /// Disposes this fake instance.
  ///
  /// Provided for API symmetry. Once disposed, further calls will throw
  /// a [StateError].
  void dispose() {
    _disposed = true;
  }

  // ---------------------------------------------------------------------------
  // ServiceHttpRequest
  // ---------------------------------------------------------------------------

  /// {@macro ServiceHttpRequest.get}
  @override
  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    _ensureNotDisposed();
    await _maybeDelay();

    if (_config.throwOnGet) {
      throw StateError('Simulated GET error');
    }

    final String key = _routeKey('GET', uri);
    _maybeThrowRouteError(key);

    final Map<String, dynamic>? canned = _canned[key];
    if (canned != null) {
      return _deepCopyMap(canned);
    }

    // Echo payload when no canned response is registered.
    return _buildEchoResponse(
      method: 'GET',
      uri: uri,
      headers: headers,
      timeout: timeout,
      metadata: metadata,
    );
  }

  /// {@macro ServiceHttpRequest.post}
  @override
  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    _ensureNotDisposed();
    await _maybeDelay();

    if (_config.throwOnPost) {
      throw StateError('Simulated POST error');
    }

    final String key = _routeKey('POST', uri);
    _maybeThrowRouteError(key);

    final Map<String, dynamic>? canned = _canned[key];
    if (canned != null) {
      return _deepCopyMap(canned);
    }

    return _buildEchoResponse(
      method: 'POST',
      uri: uri,
      headers: headers,
      body: body,
      timeout: timeout,
      metadata: metadata,
    );
  }

  /// {@macro ServiceHttpRequest.put}
  @override
  Future<Map<String, dynamic>> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    _ensureNotDisposed();
    await _maybeDelay();

    if (_config.throwOnPut) {
      throw StateError('Simulated PUT error');
    }

    final String key = _routeKey('PUT', uri);
    _maybeThrowRouteError(key);

    final Map<String, dynamic>? canned = _canned[key];
    if (canned != null) {
      return _deepCopyMap(canned);
    }

    return _buildEchoResponse(
      method: 'PUT',
      uri: uri,
      headers: headers,
      body: body,
      timeout: timeout,
      metadata: metadata,
    );
  }

  /// {@macro ServiceHttpRequest.delete}
  @override
  Future<Map<String, dynamic>> delete(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    _ensureNotDisposed();
    await _maybeDelay();

    if (_config.throwOnDelete) {
      throw StateError('Simulated DELETE error');
    }

    final String key = _routeKey('DELETE', uri);
    _maybeThrowRouteError(key);

    final Map<String, dynamic>? canned = _canned[key];
    if (canned != null) {
      return _deepCopyMap(canned);
    }

    return _buildEchoResponse(
      method: 'DELETE',
      uri: uri,
      headers: headers,
      timeout: timeout,
      metadata: metadata,
    );
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  static Map<String, Map<String, dynamic>> _buildCanned(
    FakeHttpRequestConfig config,
  ) {
    Map<String, dynamic> normalizeRaw(Map<String, dynamic> raw) {
      final String method = _pickMethod(raw) ?? 'GET';
      final dynamic rawUri = raw['uri'] ?? raw['url'];
      final String uri = rawUri is String
          ? rawUri
          : rawUri != null
              ? rawUri.toString()
              : '';

      final Map<String, dynamic> headers = raw['headers'] is Map
          ? Utils.mapFromDynamic(raw['headers'])
          : <String, dynamic>{};
      final Map<String, dynamic> body = raw['body'] is Map
          ? Utils.mapFromDynamic(raw['body'])
          : <String, dynamic>{};
      final Map<String, dynamic> metadata = raw['metadata'] is Map
          ? Utils.mapFromDynamic(raw['metadata'])
          : <String, dynamic>{};

      return <String, dynamic>{
        'method': method,
        'uri': uri,
        'statusCode': raw['statusCode'] is int
            ? raw['statusCode'] as int
            : raw['httpStatus'] is int
                ? raw['httpStatus'] as int
                : 200,
        'reasonPhrase': raw['reasonPhrase']?.toString() ?? 'OK',
        'headers': headers,
        'body': body,
        'metadata': metadata,
        'timeout': raw['timeout'] is int ? raw['timeout'] as int : null,
        'fake': true,
        'source': 'FakeHttpRequest',
      };
    }

    final Map<String, Map<String, dynamic>> fromResponses =
        Map<String, Map<String, dynamic>>.fromEntries(
      config.cannedResponses.entries.map(
        (MapEntry<String, Map<String, dynamic>> entry) =>
            MapEntry<String, Map<String, dynamic>>(
          entry.key,
          normalizeRaw(entry.value),
        ),
      ),
    );

    final Map<String, Map<String, dynamic>> fromConfigs =
        <String, Map<String, dynamic>>{};
    config.cannedConfigs.forEach(
      (String key, ModelConfigHttpRequest value) {
        fromConfigs[key] = normalizeRaw(
          <String, dynamic>{
            'method': value.method.name,
            'uri': value.uri.toString(),
            'statusCode': 200,
            'reasonPhrase': 'OK',
            'headers': value.headers,
            'body': value.body,
            'metadata': value.metadata,
            'timeout': value.timeout?.inMilliseconds,
          },
        );
      },
    );

    return Map<String, Map<String, dynamic>>.unmodifiable(
      <String, Map<String, dynamic>>{
        ...fromResponses,
        ...fromConfigs,
      },
    );
  }

  static String? _pickMethod(Map<String, dynamic> raw) {
    final dynamic method = raw['method'] ?? raw['httpMethod'];
    if (method is String && method.isNotEmpty) {
      return method.toUpperCase();
    }
    return null;
  }

  Future<void> _maybeDelay() async {
    if (_config.latency != Duration.zero) {
      await Future<void>.delayed(_config.latency);
    }
  }

  String _routeKey(String method, Uri uri) {
    return '$method $uri';
  }

  void _maybeThrowRouteError(String key) {
    final String? message = _errors[key];
    if (message != null) {
      throw StateError(message);
    }
  }

  Map<String, dynamic> _buildEchoResponse({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return <String, dynamic>{
      'method': method,
      'uri': uri.toString(),
      'headers': headers ?? <String, String>{},
      'body': body,
      'timeoutMs': timeout?.inMilliseconds,
      'metadata': metadata,
      'fake': true,
      'source': 'FakeHttpRequest',
    };
  }

  Map<String, dynamic> _deepCopyMap(Map<String, dynamic> src) {
    final Map<String, dynamic> out = <String, dynamic>{};
    src.forEach((String k, dynamic v) {
      out[k] = _deepCopyDynamic(v);
    });
    return out;
  }

  dynamic _deepCopyDynamic(dynamic v) {
    if (v is Map) {
      return _deepCopyMap(Utils.mapFromDynamic(v));
    } else if (v is List) {
      return <dynamic>[for (final dynamic x in v) _deepCopyDynamic(x)];
    }
    return v; // primitives
  }
}
