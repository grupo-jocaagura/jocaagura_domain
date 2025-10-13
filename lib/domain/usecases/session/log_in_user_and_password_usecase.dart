part of '../../../../jocaagura_domain.dart';

/// Logs a user in using email and password.
///
/// Reads the email from [UserModel.email] and the password from
/// `user.jwt[LogInUserAndPasswordUsecase.passwordKey]` (defaults to `'password'`).
///
/// Returns:
/// - `Right(UserModel)` on success with the authenticated user.
/// - `Left(ErrorItem)` on failure (invalid credentials, network issues, etc.).
///
/// Contracts:
/// - `user.email` must be a non-empty string.
/// - `user.jwt['password']` must be a non-empty string.
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryAuth repo = MyAuthRepository(); // implements RepositoryAuth
///   final LogInUserAndPasswordUsecase usecase = LogInUserAndPasswordUsecase(repo);
///
///   final UserModel input = UserModel(
///     email: 'a@b.com',
///     jwt: <String, dynamic>{LogInUserAndPasswordUsecase.passwordKey: 'secret'},
///   );
///
///   final result = await usecase(input);
///   result.fold(
///     (e) => print('login failed: ${e.message}'),
///     (u) => print('welcome ${u.email}'),
///   );
/// }
/// ```
class LogInUserAndPasswordUsecase
    implements UseCase<Either<ErrorItem, UserModel>, UserModel> {
  const LogInUserAndPasswordUsecase(this.repository);
  static const String passwordKey = 'password';
  final RepositoryAuth repository;

  @override
  Future<Either<ErrorItem, UserModel>> call(
    UserModel user,
  ) async {
    final String password = Utils.getStringFromDynamic(user.jwt[passwordKey]);
    final String email = user.email;

    return repository.logInUserAndPassword(email, password);
  }
}
