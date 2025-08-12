part of '../../../../jocaagura_domain.dart';

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
