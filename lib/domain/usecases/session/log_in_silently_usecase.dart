part of '../../../../jocaagura_domain.dart';

class LogInSilentlyUsecase
    implements UseCase<Either<ErrorItem, UserModel>, UserModel> {
  const LogInSilentlyUsecase(this.repository);
  final RepositoryAuth repository;

  @override
  Future<Either<ErrorItem, UserModel>> call(UserModel user) {
    return repository.logInSilently(user);
  }
}
