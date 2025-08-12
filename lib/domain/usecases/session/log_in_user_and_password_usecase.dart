part of '../../../../jocaagura_domain.dart';

/// Use case for logging in a user with Google authentication.
class LogInUserAndPasswordUsecase
    implements UseCase<Either<ErrorItem, UserModel>, UserModel> {
  const LogInUserAndPasswordUsecase(this.repository);
  static const String passwordKey = 'password';
  final RepositoryAuth repository;

  @override
  Future<Either<ErrorItem, UserModel>> call(
    UserModel user,
  ) async {
    final String password = Utils.getStringFromDynamic(user.jwt[passwordKey]);
    final String email = user.email;

    return repository.logInUserAndPassword(email, password);
  }
}
