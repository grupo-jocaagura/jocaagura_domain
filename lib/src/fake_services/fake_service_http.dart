import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake HTTP service para dev/testing.
///
/// - Simula latencia y errores por la función.
/// - Permite inyectar respuestas personalizadas con [simulateResponse].
class FakeServiceHttp implements ServiceHttp {
  FakeServiceHttp({
    this.latency = Duration.zero,
    this.throwOnGet = false,
    this.throwOnPost = false,
    this.throwOnPut = false,
    this.throwOnDelete = false,
  });
  final Duration latency;
  final bool throwOnGet;
  final bool throwOnPost;
  final bool throwOnPut;
  final bool throwOnDelete;

  bool _disposed = false;

  /// Dentro de la clase FakeServiceHttp:
  static const String methodGet = 'GET';
  static const String methodPost = 'POST';
  static const String methodPut = 'PUT';
  static const String methodDelete = 'DELETE';

  /// Mapa de respuestas: clave = 'METHOD url', valor = cuerpo JSON.
  final Map<String, Map<String, dynamic>> _responses =
      <String, Map<String, dynamic>>{};

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('FakeServiceHttp has been disposed');
    }
  }

  void _validateUrl(String url) {
    if (url.isEmpty) {
      throw ArgumentError('url must not be empty');
    }
  }

  /// Define la respuesta JSON que devolverá `<method> <url>`.
  void simulateResponse(String method, String url, Map<String, dynamic> body) {
    _responses['$method $url'] = body;
  }

  @override
  Future<Map<String, dynamic>> get({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    _checkDisposed();
    if (throwOnGet) {
      throw StateError('Simulated GET error');
    }
    _validateUrl(url);
    await Future<void>.delayed(latency);
    return _responses['$methodGet $url'] ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> post({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    _checkDisposed();
    if (throwOnPost) {
      throw StateError('Simulated POST error');
    }
    _validateUrl(url);
    await Future<void>.delayed(latency);
    return _responses['$methodPost $url'] ??
        (body is Map<String, dynamic> ? body : <String, dynamic>{});
  }

  @override
  Future<Map<String, dynamic>> put({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    _checkDisposed();
    if (throwOnPut) {
      throw StateError('Simulated PUT error');
    }
    _validateUrl(url);
    await Future<void>.delayed(latency);
    return _responses['$methodPut $url'] ??
        (body is Map<String, dynamic> ? body : <String, dynamic>{});
  }

  @override
  Future<void> delete({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    _checkDisposed();
    if (throwOnDelete) {
      throw StateError('Simulated DELETE error');
    }
    _validateUrl(url);
    await Future<void>.delayed(latency);
    _responses.remove('$methodGet $url');
    _responses.remove('$methodPost $url');
    _responses.remove('$methodPut $url');
    _responses.remove('$methodDelete $url');
  }

  @override
  void dispose() {
    _disposed = true;
  }
}
