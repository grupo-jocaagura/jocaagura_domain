part of '../../../../jocaagura_domain.dart';

class LogOutUsecase {
  const LogOutUsecase(this._repository);
  final RepositoryAuth _repository;

  Future<Either<ErrorItem, void>> call(UserModel user) {
    return _repository.logOutUser(user);
  }
}
