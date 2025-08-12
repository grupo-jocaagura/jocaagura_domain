part of '../../../../jocaagura_domain.dart';

class RefreshSessionUsecase
    implements UseCase<Either<ErrorItem, UserModel>, UserModel> {
  const RefreshSessionUsecase(this._repository);
  final RepositoryAuth _repository;

  @override
  Future<Either<ErrorItem, UserModel>> call(UserModel currentUser) {
    return _repository.refreshSession(currentUser);
  }
}
