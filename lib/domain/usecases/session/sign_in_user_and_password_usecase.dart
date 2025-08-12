part of '../../../../jocaagura_domain.dart';

class SignInUserAndPasswordUsecase
    implements UseCase<Either<ErrorItem, UserModel>, UserModel> {
  const SignInUserAndPasswordUsecase(this.repository);
  final RepositoryAuth repository;

  @override
  Future<Either<ErrorItem, UserModel>> call(
    UserModel user,
  ) async {
    final String password = Utils.getStringFromDynamic(
      user.jwt[LogInUserAndPasswordUsecase.passwordKey],
    );
    final String email = user.email;
    return repository.signInUserAndPassword(email, password);
  }
}
