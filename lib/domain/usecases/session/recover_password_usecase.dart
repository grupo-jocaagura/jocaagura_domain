part of '../../../../jocaagura_domain.dart';

class RecoverPasswordUsecase implements UseCase<void, UserModel> {
  const RecoverPasswordUsecase(this._repository);
  final RepositoryAuth _repository;

  @override
  Future<Either<ErrorItem, void>> call(UserModel user) {
    return _repository.recoverPassword(user.email);
  }
}
