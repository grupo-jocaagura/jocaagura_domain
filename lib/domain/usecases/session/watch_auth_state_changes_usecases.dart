part of '../../../../jocaagura_domain.dart';

/// Exposes the auth state stream from RepositoryAuth to upper layers.
///
/// - No params.
/// - Returns `Stream<Either<ErrorItem, UserModel?>>`.
class WatchAuthStateChangesUsecase {
  const WatchAuthStateChangesUsecase(this._repository);
  final RepositoryAuth _repository;

  Stream<Either<ErrorItem, UserModel?>> call() {
    return _repository.authStateChanges();
  }
}
