import 'package:jocaagura_domain/jocaagura_domain.dart';

class FakeRepositoryAuth implements RepositoryAuth {
  FakeRepositoryAuth();

  // Contadores para validar debouncer / llamadas
  int logInUserAndPasswordCalls = 0;
  int signInUserAndPasswordCalls = 0;
  int logInWithGoogleCalls = 0;
  int logInSilentlyCalls = 0;
  int refreshSessionCalls = 0;
  int recoverPasswordCalls = 0;
  int logOutUserCalls = 0;
  int getCurrentUserCalls = 0;
  int isSignedInCalls = 0;

  // Respuestas configurables por test
  Either<ErrorItem, UserModel>? nextLoginResult;
  Either<ErrorItem, UserModel>? nextSignInResult;
  Either<ErrorItem, UserModel>? nextGoogleResult;
  Either<ErrorItem, UserModel>? nextSilentResult;
  Either<ErrorItem, UserModel>? nextRefreshResult;
  Either<ErrorItem, void>? nextRecoverResult;
  Either<ErrorItem, void>? nextLogoutResult;
  Either<ErrorItem, UserModel>? nextGetCurrentUserResult;
  Either<ErrorItem, bool>? nextIsSignedInResult;

  final BlocGeneral<Either<ErrorItem, UserModel?>> _authCtrl =
      BlocGeneral<Either<ErrorItem, UserModel?>>(
    Right<ErrorItem, UserModel?>(defaultUserModel),
  );

  void emitAuth(Either<ErrorItem, UserModel?> error) {
    if (_authCtrl.value.isLeft || _authCtrl.value.isRight) {
      _authCtrl.value = error;
    }
  }

  @override
  Stream<Either<ErrorItem, UserModel?>> authStateChanges() => _authCtrl.stream;

  @override
  Future<Either<ErrorItem, UserModel>> signInUserAndPassword(
    String email,
    String password,
  ) async {
    signInUserAndPasswordCalls++;
    return nextSignInResult ??
        Right<ErrorItem, UserModel>(
          UserModel(
            id: email,
            displayName: email.split('@').first,
            photoUrl: '',
            email: email,
            jwt: const <String, dynamic>{},
          ),
        );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInUserAndPassword(
    String email,
    String password,
  ) async {
    logInUserAndPasswordCalls++;
    return nextLoginResult ??
        Right<ErrorItem, UserModel>(
          UserModel(
            id: email,
            displayName: email.split('@').first,
            photoUrl: '',
            email: email,
            jwt: const <String, dynamic>{},
          ),
        );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInWithGoogle() async {
    logInWithGoogleCalls++;
    return nextGoogleResult ??
        Right<ErrorItem, UserModel>(
          const UserModel(
            id: 'google_user',
            displayName: 'Fake User',
            photoUrl: 'https://fake.com/photo.png',
            email: 'fake@fake.com',
            jwt: <String, dynamic>{},
          ),
        );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInSilently(
    UserModel currentUser,
  ) async {
    logInSilentlyCalls++;
    return nextSilentResult ??
        Right<ErrorItem, UserModel>(
          currentUser.copyWith(
            jwt: <String, dynamic>{'ref': 'silent'},
          ),
        );
  }

  @override
  Future<Either<ErrorItem, UserModel>> refreshSession(
    UserModel currentUser,
  ) async {
    refreshSessionCalls++;
    return nextRefreshResult ??
        Right<ErrorItem, UserModel>(
          currentUser.copyWith(
            jwt: <String, dynamic>{'ref': 'refresh'},
          ),
        );
  }

  @override
  Future<Either<ErrorItem, void>> recoverPassword(String email) async {
    recoverPasswordCalls++;
    return nextRecoverResult ?? Right<ErrorItem, void>(null);
  }

  @override
  Future<Either<ErrorItem, void>> logOutUser(UserModel user) async {
    logOutUserCalls++;
    return nextLogoutResult ?? Right<ErrorItem, void>(null);
  }

  @override
  Future<Either<ErrorItem, UserModel>> getCurrentUser() async {
    getCurrentUserCalls++;
    return nextGetCurrentUserResult ??
        Left<ErrorItem, UserModel>(
          const ErrorItem(
            title: 'No session',
            code: 'ERR_NOT_SIGNED_IN',
            description: 'There is no active session',
          ),
        );
  }

  @override
  Future<Either<ErrorItem, bool>> isSignedIn() async {
    isSignedInCalls++;
    return nextIsSignedInResult ?? Right<ErrorItem, bool>(false);
  }
}
