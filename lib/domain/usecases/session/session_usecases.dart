part of '../../../../jocaagura_domain.dart';

/// Aggregates all session-related use cases for convenient injection.
///
/// This is a thin, immutable container that exposes each use case as a field.
/// It contains **no business logic**.
///
/// Example:
/// ```dart
/// void main() {
///   final RepositoryAuth repo = MyAuthRepository();
///   final SessionUsecases session = SessionUsecases(
///     logInUserAndPassword: LogInUserAndPasswordUsecase(repo),
///     logOutUsecase: LogOutUsecase(repo),
///     signInUserAndPassword: SignInUserAndPasswordUsecase(repo),
///     recoverPassword: RecoverPasswordUsecase(repo),
///     logInSilently: LogInSilentlyUsecase(repo),
///     loginWithGoogle: LoginWithGoogleUsecase(repo),
///     refreshSession: RefreshSessionUsecase(repo),
///     getCurrentUser: GetCurrentUserUsecase(repo),
///     watchAuthStateChangesUsecase: WatchAuthStateChangesUsecase(repo),
///   );
///
///   // Example usage:
///   // final res = await session.logInUserAndPassword(user);
/// }
/// ```
class SessionUsecases {
  const SessionUsecases({
    required this.logInUserAndPassword,
    required this.logOutUsecase,
    required this.signInUserAndPassword,
    required this.recoverPassword,
    required this.logInSilently,
    required this.loginWithGoogle,
    required this.refreshSession,
    required this.getCurrentUser,
    required this.watchAuthStateChangesUsecase,
  });

  final LogInUserAndPasswordUsecase logInUserAndPassword;
  final LogOutUsecase logOutUsecase;
  final SignInUserAndPasswordUsecase signInUserAndPassword;
  final RecoverPasswordUsecase recoverPassword;
  final LogInSilentlyUsecase logInSilently;
  final LoginWithGoogleUsecase loginWithGoogle;
  final RefreshSessionUsecase refreshSession;
  final GetCurrentUserUsecase getCurrentUser;
  final WatchAuthStateChangesUsecase watchAuthStateChangesUsecase;
}
