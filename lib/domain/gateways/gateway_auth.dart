part of '../../../jocaagura_domain.dart';

/// Maps raw service errors to domain `ErrorItem` and forwards payloads.
///
/// - **Input/Output**: primitives & JSON maps only; no domain models here.
/// - **Errors**: catch-all; convert throws into `Left(ErrorItem)`.
abstract class GatewayAuth {
  Future<Either<ErrorItem, Map<String, dynamic>>> signInUserAndPassword(
    String email,
    String password,
  );

  Future<Either<ErrorItem, Map<String, dynamic>>> logInUserAndPassword(
    String email,
    String password,
  );

  Future<Either<ErrorItem, Map<String, dynamic>>> logInWithGoogle();

  Future<Either<ErrorItem, Map<String, dynamic>>> logInSilently(
    Map<String, dynamic> sessionJson,
  );

  Future<Either<ErrorItem, Map<String, dynamic>>> refreshSession(
    Map<String, dynamic> sessionJson,
  );

  Future<Either<ErrorItem, Map<String, dynamic>>> recoverPassword(
    String email,
  );

  Future<Either<ErrorItem, Map<String, dynamic>>> logOutUser(
    Map<String, dynamic> sessionJson,
  );

  Future<Either<ErrorItem, Map<String, dynamic>>> getCurrentUser();

  Future<Either<ErrorItem, Map<String, dynamic>>> isSignedIn();

  Stream<Either<ErrorItem, Map<String, dynamic>?>> authStateChanges();
}
