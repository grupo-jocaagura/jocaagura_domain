part of '../../../../jocaagura_domain.dart';

/// Creates a new account using email and password.
///
/// Reads the email from [UserModel.email] and the password from
/// `user.jwt[LogInUserAndPasswordUsecase.passwordKey]`.
///
/// Returns:
/// - `Right(UserModel)` on success with the newly registered user.
/// - `Left(ErrorItem)` on failure (already registered, weak password, etc.).
///
/// Contracts:
/// - `user.email` must be a valid, non-empty email.
/// - Password must satisfy backend policies (length/complexity).
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryAuth repo = MyAuthRepository();
///   final SignInUserAndPasswordUsecase usecase = SignInUserAndPasswordUsecase(repo);
///
///   final UserModel input = UserModel(
///     email: 'new@user.com',
///     jwt: <String, dynamic>{LogInUserAndPasswordUsecase.passwordKey: 'Str0ngPass!'},
///   );
///
///   final result = await usecase(input);
///   result.fold(
///     (e) => print('sign-up failed: ${e.message}'),
///     (u) => print('registered: ${u.email}'),
///   );
/// }
/// ```
class SignInUserAndPasswordUsecase
    implements UseCase<Either<ErrorItem, UserModel>, UserModel> {
  const SignInUserAndPasswordUsecase(this.repository);
  final RepositoryAuth repository;

  @override
  Future<Either<ErrorItem, UserModel>> call(
    UserModel user,
  ) async {
    final String password = Utils.getStringFromDynamic(
      user.jwt[LogInUserAndPasswordUsecase.passwordKey],
    );
    final String email = user.email;
    return repository.signInUserAndPassword(email, password);
  }
}
