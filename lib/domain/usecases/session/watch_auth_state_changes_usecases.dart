part of '../../../../jocaagura_domain.dart';

/// Exposes the repository's auth state changes as a stream.
///
/// Emits:
/// - `Right(UserModel?)` where `null` means "signed out".
/// - `Left(ErrorItem)` on stream errors.
///
/// Contracts:
/// - No input parameters.
/// - The repository defines the emission policy (initial value, behavior on errors, etc.).
///
/// Example:
/// ```dart
/// void main() {
///   final RepositoryAuth repo = MyAuthRepository();
///   final WatchAuthStateChangesUsecase usecase = WatchAuthStateChangesUsecase(repo);
///
///   final StreamSubscription sub = usecase().listen((either) {
///     either.fold(
///       (e) => print('auth stream error: ${e.message}'),
///       (u) => print(u == null ? 'signed out' : 'signed in as ${u.email}'),
///     );
///   });
///
///   // Remember to cancel in your app's dispose:
///   // sub.cancel();
/// }
/// ```
class WatchAuthStateChangesUsecase {
  const WatchAuthStateChangesUsecase(this._repository);
  final RepositoryAuth _repository;

  Stream<Either<ErrorItem, UserModel?>> call() {
    return _repository.authStateChanges();
  }
}
