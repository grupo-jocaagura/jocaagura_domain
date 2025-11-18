import '../../jocaagura_domain.dart';

/// Default implementation of [GatewayHttpRequest] that delegates to a
/// low-level [ServiceHttpRequest] and uses an [ErrorMapper] to produce
/// domain-level [ErrorItem] instances.
///
/// Responsabilidades:
/// - Invocar al [ServiceHttpRequest] para cada servicio.
/// - Mapear errores de transporte (timeouts, sockets, etc.) vía
///   [ErrorMapper.fromException].
/// - Inspeccionar payloads exitosos vía [ErrorMapper.fromPayload] para
///   detectar errores de negocio.
///
/// Este gateway **nunca lanza**: todas las fallas se devuelven como
/// `Either.left(ErrorItem)`.
///
/// Convenciones de adaptación hacia [ServiceHttpRequest]:
/// - `metadata` (dominio, `Map<String, dynamic>`) se convierte en:
///   - GET: `Map<String, String>` plano (`key -> value.toString()`).
///   - POST/PUT/DELETE: `Map<String, Map<String, String>?>` con una entrada
///     `'tags'` que contiene el mapa plano anterior.
/// - `body`:
///   - Gateway recibe `Map<String, dynamic>`
///   - Service recibe `Map<String, String>?` → valores stringificados.
class GatewayHttpRequestImpl implements GatewayHttpRequest {
  /// Creates a new [GatewayHttpRequestImpl] instance.
  ///
  /// - [service]: Low-level HTTP service (platform-specific).
  /// - [errorMapper]: Optional mapper; if omitted, [DefaultErrorMapper] is used.
  /// - [location]: Logical name used in [ErrorItem.meta.location] to help
  ///   diagnostics and logging.
  const GatewayHttpRequestImpl({
    required ServiceHttpRequest service,
    ErrorMapper? errorMapper,
    this.location = 'GatewayHttpRequestImpl',
  })  : _service = service,
        _errorMapper = errorMapper ?? const DefaultErrorMapper();

  /// Underlying HTTP service used for actual transport.
  final ServiceHttpRequest _service;

  /// Error mapper used for exceptions and payload-based business errors.
  final ErrorMapper _errorMapper;

  /// Base location tag injected into [ErrorItem.meta.location].
  final String location;

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> get(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final Map<String, String> svcMetadata = _toFlatStringMap(metadata);

    return _wrap(
      methodLabel: 'GET',
      uri: uri,
      invoke: () => _service.get(
        uri,
        headers: headers.isEmpty ? null : headers,
        timeout: timeout,
        metadata: svcMetadata,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // POST
  // ---------------------------------------------------------------------------

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final Map<String, String>? svcBody = _toFlatStringMapNullable(body);
    final Map<String, Map<String, String>?> svcMetadata =
        _toNestedMetadata(metadata);

    return _wrap(
      methodLabel: 'POST',
      uri: uri,
      invoke: () => _service.post(
        uri,
        headers: headers,
        body: svcBody,
        timeout: timeout,
        metadata: svcMetadata,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PUT
  // ---------------------------------------------------------------------------

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> put(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final Map<String, String>? svcBody = _toFlatStringMapNullable(body);
    final Map<String, Map<String, String>?> svcMetadata =
        _toNestedMetadata(metadata);

    return _wrap(
      methodLabel: 'PUT',
      uri: uri,
      invoke: () => _service.put(
        uri,
        headers: headers,
        body: svcBody,
        timeout: timeout,
        metadata: svcMetadata,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> delete(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final Map<String, Map<String, String>?> svcMetadata =
        _toNestedMetadata(metadata);

    return _wrap(
      methodLabel: 'DELETE',
      uri: uri,
      invoke: () => _service.delete(
        uri,
        headers: headers,
        timeout: timeout,
        metadata: svcMetadata,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Internals: error mapping
  // ---------------------------------------------------------------------------

  Future<Either<ErrorItem, Map<String, dynamic>>> _wrap({
    required String methodLabel,
    required Uri uri,
    required Future<Map<String, dynamic>> Function() invoke,
  }) async {
    try {
      final Map<String, dynamic> payload = await invoke();

      final ErrorItem? businessError = _errorMapper.fromPayload(
        payload,
        location: _buildLocation(methodLabel, uri),
      );
      if (businessError != null) {
        return Left<ErrorItem, Map<String, dynamic>>(businessError);
      }

      return Right<ErrorItem, Map<String, dynamic>>(payload);
    } catch (error, stackTrace) {
      final ErrorItem mapped = _errorMapper.fromException(
        error,
        stackTrace,
        location: _buildLocation(methodLabel, uri),
      );
      return Left<ErrorItem, Map<String, dynamic>>(mapped);
    }
  }

  String _buildLocation(String methodLabel, Uri uri) {
    return '$location.$methodLabel($uri)';
  }

  // ---------------------------------------------------------------------------
  // Internals: adapters body/metadata
  // ---------------------------------------------------------------------------

  /// Convierte `Map<String, dynamic>` a `Map<String, String>`, usando
  /// [Utils.getStringFromDynamic] para cada valor.
  Map<String, String> _toFlatStringMap(Map<String, dynamic> source) {
    if (source.isEmpty) {
      return <String, String>{};
    }
    final Map<String, String> out = <String, String>{};
    source.forEach((String key, dynamic value) {
      out[key] = Utils.getStringFromDynamic(value);
    });
    return out;
  }

  /// Versión nullable para body.
  Map<String, String>? _toFlatStringMapNullable(Map<String, dynamic>? source) {
    if (source == null || source.isEmpty) {
      return null;
    }
    return _toFlatStringMap(source);
  }

  /// Convierte `metadata` de dominio a la forma esperada por
  /// `ServiceHttpRequest.post/put/delete`:
  ///
  /// ```dart
  /// {
  ///   'tags': <String, String>{ ...flattened... }
  /// }
  /// ```
  Map<String, Map<String, String>?> _toNestedMetadata(
    Map<String, dynamic> metadata,
  ) {
    final Map<String, String> flat = _toFlatStringMap(metadata);
    return <String, Map<String, String>?>{
      'tags': flat,
    };
  }
}
