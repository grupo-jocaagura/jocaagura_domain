part of '../../../../jocaagura_domain.dart';

/// Initiates a Google sign-in flow through the repository.
///
/// No parameters are required; platform and scopes are handled at the repository/service layer.
///
/// Returns:
/// - `Right(UserModel)` on successful sign-in.
/// - `Left(ErrorItem)` on failure or user cancellation.
///
/// Notes:
/// - UI prompts and OAuth scopes are not handled here; they belong to the repository/service.
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryAuth repo = MyAuthRepository();
///   final LoginWithGoogleUsecase usecase = LoginWithGoogleUsecase(repo);
///
///   final result = await usecase();
///   result.fold(
///     (e) => print('google sign-in failed: ${e.message}'),
///     (u) => print('signed in as ${u.email}'),
///   );
/// }
/// ```
class LoginWithGoogleUsecase {
  const LoginWithGoogleUsecase(this._repository);
  final RepositoryAuth _repository;

  Future<Either<ErrorItem, UserModel>> call() {
    return _repository.logInWithGoogle();
  }
}
