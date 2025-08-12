part of '../../../jocaagura_domain.dart';

/// Repository: converts JSON payloads to domain models (`UserModel`) and
/// stabilizes errors using the same [ErrorMapper] used in Gateways.
abstract class RepositoryAuth {
  Future<Either<ErrorItem, UserModel>> signInUserAndPassword(
    String email,
    String password,
  );

  Future<Either<ErrorItem, UserModel>> logInUserAndPassword(
    String email,
    String password,
  );

  Future<Either<ErrorItem, UserModel>> logInWithGoogle();

  Future<Either<ErrorItem, UserModel>> logInSilently(UserModel currentUser);

  Future<Either<ErrorItem, UserModel>> refreshSession(UserModel currentUser);

  Future<Either<ErrorItem, void>> recoverPassword(String email);

  Future<Either<ErrorItem, void>> logOutUser(UserModel user);

  Future<Either<ErrorItem, UserModel>> getCurrentUser();

  Future<Either<ErrorItem, bool>> isSignedIn();

  Stream<Either<ErrorItem, UserModel?>> authStateChanges();
}
