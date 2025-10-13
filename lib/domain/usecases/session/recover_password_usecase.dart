part of '../../../../jocaagura_domain.dart';

/// Starts the password recovery process for the given user's email.
///
/// Returns:
/// - `Right(void)` when the recovery flow is initiated (e.g., email sent).
/// - `Left(ErrorItem)` on failure (unknown email, rate limits, etc.).
///
/// Contracts:
/// - [user.email] must be a valid, non-empty email.
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryAuth repo = MyAuthRepository();
///   final RecoverPasswordUsecase usecase = RecoverPasswordUsecase(repo);
///
///   final UserModel request = UserModel(email: 'a@b.com');
///   final result = await usecase(request);
///   result.fold(
///     (e) => print('recovery failed: ${e.message}'),
///     (_) => print('recovery started'),
///   );
/// }
/// ```
class RecoverPasswordUsecase implements UseCase<void, UserModel> {
  const RecoverPasswordUsecase(this._repository);
  final RepositoryAuth _repository;

  @override
  Future<Either<ErrorItem, void>> call(UserModel user) {
    return _repository.recoverPassword(user.email);
  }
}
