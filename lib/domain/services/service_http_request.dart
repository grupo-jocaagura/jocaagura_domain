part of 'package:jocaagura_domain/jocaagura_domain.dart';

abstract class ServiceHttpRequest {
  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata,
  });

  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    Map<String, dynamic> metadata,
  });

  Future<Map<String, dynamic>> put(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    Map<String, dynamic> metadata,
  });

  Future<Map<String, dynamic>> delete(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata,
  });
}
