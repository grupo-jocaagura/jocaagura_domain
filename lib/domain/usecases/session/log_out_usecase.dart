part of '../../../../jocaagura_domain.dart';

/// Logs the current user out from the system.
///
/// Returns:
/// - `Right(void)` on success.
/// - `Left(ErrorItem)` on failure.
///
/// Contracts:
/// - [user] must be the currently authenticated user as tracked by the repository.
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryAuth repo = MyAuthRepository();
///   final LogOutUsecase usecase = LogOutUsecase(repo);
///
///   final UserModel current = UserModel(email: 'a@b.com');
///   final result = await usecase(current);
///   result.fold(
///     (e) => print('logout failed: ${e.message}'),
///     (_) => print('logged out'),
///   );
/// }
/// ```
class LogOutUsecase {
  const LogOutUsecase(this._repository);
  final RepositoryAuth _repository;

  Future<Either<ErrorItem, void>> call(UserModel user) {
    return _repository.logOutUser(user);
  }
}
