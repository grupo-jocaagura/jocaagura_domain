part of '../../../../jocaagura_domain.dart';

/// Refreshes the current session (e.g., renews tokens or claims).
///
/// Returns:
/// - `Right(UserModel)` with the refreshed identity/session data.
/// - `Left(ErrorItem)` when refresh fails (expired/invalid/denied).
///
/// Contracts:
/// - [currentUser] must be the active identity to refresh.
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryAuth repo = MyAuthRepository();
///   final RefreshSessionUsecase usecase = RefreshSessionUsecase(repo);
///
///   final UserModel current = UserModel(email: 'a@b.com');
///   final result = await usecase(current);
///   result.fold(
///     (e) => print('refresh failed: ${e.message}'),
///     (u) => print('session refreshed for ${u.email}'),
///   );
/// }
/// ```
class RefreshSessionUsecase
    implements UseCase<Either<ErrorItem, UserModel>, UserModel> {
  const RefreshSessionUsecase(this._repository);
  final RepositoryAuth _repository;

  @override
  Future<Either<ErrorItem, UserModel>> call(UserModel currentUser) {
    return _repository.refreshSession(currentUser);
  }
}
