part of 'package:jocaagura_domain/jocaagura_domain.dart';

abstract class ServiceHttpRequest {
  /// Performs an HTTP GET request and returns a JSON-like payload on success.
  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, String> metadata,
  });

  /// Performs an HTTP POST request and returns a JSON-like payload on success.
  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, String>? body,
    Duration? timeout,
    Map<String, Map<String, String>?> metadata,
  });

  /// Performs an HTTP PUT request and returns a JSON-like payload on success.
  Future<Map<String, dynamic>> put(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, String>? body,
    Duration? timeout,
    Map<String, Map<String, String>?> metadata,
  });

  /// Performs an HTTP DELETE request and returns a JSON-like payload on success.
  Future<Map<String, dynamic>> delete(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, Map<String, String>?> metadata,
  });
}
