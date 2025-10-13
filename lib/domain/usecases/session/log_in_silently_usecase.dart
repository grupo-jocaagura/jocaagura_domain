part of '../../../../jocaagura_domain.dart';

/// Attempts to restore a session without user interaction.
///
/// Delegates to [RepositoryAuth.logInSilently].
///
/// Returns:
/// - `Right(UserModel)` when the session can be restored (token/session still valid).
/// - `Left(ErrorItem)` when restoration fails (expired, revoked, etc.).
///
/// Contracts:
/// - [user] must represent a previously authenticated identity (as defined by the repository).
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryAuth repo = MyAuthRepository();
///   final LogInSilentlyUsecase usecase = LogInSilentlyUsecase(repo);
///
///   final UserModel lastUser = UserModel(email: 'a@b.com');
///   final result = await usecase(lastUser);
///   result.fold(
///     (e) => print('silent login failed: ${e.message}'),
///     (u) => print('session restored for ${u.email}'),
///   );
/// }
/// ```
class LogInSilentlyUsecase
    implements UseCase<Either<ErrorItem, UserModel>, UserModel> {
  const LogInSilentlyUsecase(this.repository);
  final RepositoryAuth repository;

  @override
  Future<Either<ErrorItem, UserModel>> call(UserModel user) {
    return repository.logInSilently(user);
  }
}
