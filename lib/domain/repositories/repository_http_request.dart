part of 'package:jocaagura_domain/jocaagura_domain.dart';

abstract class RepositoryHttpRequest {
  Future<Either<ErrorItem, ModelConfigHttpRequest>> get(
    Uri uri, {
    Map<String, String> headers,
    Duration? timeout,
    Map<String, dynamic> metadata,
  });

  Future<Either<ErrorItem, ModelConfigHttpRequest>> post(
    Uri uri, {
    Map<String, String> headers,
    Map<String, dynamic> body,
    Duration? timeout,
    Map<String, dynamic> metadata,
  });

  Future<Either<ErrorItem, ModelConfigHttpRequest>> put(
    Uri uri, {
    Map<String, String> headers,
    Map<String, dynamic> body,
    Duration? timeout,
    Map<String, dynamic> metadata,
  });

  Future<Either<ErrorItem, ModelConfigHttpRequest>> delete(
    Uri uri, {
    Map<String, String> headers,
    Duration? timeout,
    Map<String, dynamic> metadata,
  });
}
