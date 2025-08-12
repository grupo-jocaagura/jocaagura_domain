part of '../../../../jocaagura_domain.dart';

class LoginWithGoogleUsecase {
  const LoginWithGoogleUsecase(this._repository);
  final RepositoryAuth _repository;

  Future<Either<ErrorItem, UserModel>> call() {
    return _repository.logInWithGoogle();
  }
}
