part of '../../jocaagura_domain.dart';

/// Abstract HTTP service for basic REST operations.
///
/// - [get] hace una petición GET y devuelve un JSON map.
/// - [post] hace una petición POST con body y devuelve un JSON map.
/// - [put] hace una petición PUT con body y devuelve un JSON map.
/// - [delete] hace una petición DELETE y no devuelve payload.
///
/// Ejemplo:
/// ```dart
/// final ServiceHttp http = FakeServiceHttp();
/// final user = await http.get(url: '/users/1');
/// await http.post(url: '/users', body: {'name':'Alice'});
/// await http.put(url: '/users/1', body: {'name':'Bob'});
/// await http.delete(url: '/users/1');
/// ```
abstract class ServiceHttp {
  /// Ejecuta GET sobre [url].
  ///
  /// - [headers]: cabeceras opcionales.
  /// - [queryParameters]: parámetros de URL.
  ///
  /// Retorna un `Map<String, dynamic>`.
  Future<Map<String, dynamic>> get({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });

  /// Ejecuta POST sobre [url] con body JSON-serializable.
  Future<Map<String, dynamic>> post({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  });

  /// Ejecuta PUT sobre [url] con body JSON-serializable.
  Future<Map<String, dynamic>> put({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  });

  /// Ejecuta DELETE sobre [url].
  Future<void> delete({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });

  /// Libera recursos internos.
  void dispose();
}
