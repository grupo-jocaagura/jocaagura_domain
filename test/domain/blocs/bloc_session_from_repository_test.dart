import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// -------------------------
/// Fakes artesanales
/// -------------------------

class _RepoFake implements RepositoryAuth {
  _RepoFake({
    Stream<Either<ErrorItem, UserModel?>>? authStream,
  }) : _authCtrl = StreamController<Either<ErrorItem, UserModel?>>.broadcast() {
    if (authStream != null) {
      _authSub = authStream.listen(
        _authCtrl.add,
        onError: _authCtrl.addError,
        onDone: _authCtrl.close,
      );
    }
  }

  final StreamController<Either<ErrorItem, UserModel?>> _authCtrl;
  StreamSubscription<Either<ErrorItem, UserModel?>>? _authSub;

  Either<ErrorItem, UserModel>? signInResp;
  Either<ErrorItem, UserModel>? loginResp;
  Either<ErrorItem, UserModel>? googleResp;
  Either<ErrorItem, UserModel>? silentResp;
  Either<ErrorItem, UserModel>? refreshResp;
  Either<ErrorItem, void>? recoverResp;
  Either<ErrorItem, void>? logoutResp;
  Either<ErrorItem, UserModel>? currentResp;
  Either<ErrorItem, bool>? isSignedInResp;

  // Helpers para empujar eventos al stream de auth
  void addAuth(Either<ErrorItem, UserModel?> e) => _authCtrl.add(e);

  Future<void> closeAuth() async {
    await _authCtrl.close();
    await _authSub?.cancel();
  }

  // ---- RepositoryAuth ----
  @override
  Future<Either<ErrorItem, UserModel>> signInUserAndPassword(
    String email,
    String password,
  ) async {
    return signInResp ??
        Right<ErrorItem, UserModel>(
          UserModel.fromJson(<String, dynamic>{'id': email, 'email': email}),
        );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInUserAndPassword(
    String email,
    String password,
  ) async {
    return loginResp ??
        Right<ErrorItem, UserModel>(
          UserModel.fromJson(<String, dynamic>{'id': email, 'email': email}),
        );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInWithGoogle() async {
    return googleResp ??
        Right<ErrorItem, UserModel>(
          UserModel.fromJson(
            const <String, dynamic>{'id': 'g', 'email': 'g@x.com'},
          ),
        );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInSilently(
    UserModel currentUser,
  ) async {
    return silentResp ?? Right<ErrorItem, UserModel>(currentUser);
  }

  @override
  Future<Either<ErrorItem, UserModel>> refreshSession(
    UserModel currentUser,
  ) async {
    return refreshResp ??
        Right<ErrorItem, UserModel>(
          currentUser
              .copyWith(jwt: <String, dynamic>{'accessToken': 'refreshed'}),
        );
  }

  @override
  Future<Either<ErrorItem, void>> recoverPassword(String email) async {
    return recoverResp ?? Right<ErrorItem, void>(null);
  }

  @override
  Future<Either<ErrorItem, void>> logOutUser(UserModel user) async {
    return logoutResp ?? Right<ErrorItem, void>(null);
  }

  @override
  Future<Either<ErrorItem, UserModel>> getCurrentUser() async {
    return currentResp ??
        Left<ErrorItem, UserModel>(SessionErrorItems.notSignedIn);
  }

  @override
  Future<Either<ErrorItem, bool>> isSignedIn() async {
    return isSignedInResp ?? Right<ErrorItem, bool>(true);
  }

  @override
  Stream<Either<ErrorItem, UserModel?>> authStateChanges() => _authCtrl.stream;
}

/// Crea un usuario mínimo de pruebas
UserModel _u(String email) =>
    UserModel.fromJson(<String, dynamic>{'id': email, 'email': email});

void main() {
  group('BlocSession.fromRepository | boot & stream mapping', () {
    test(
        'Given repo stream Right(null) -> Right(user) -> Left(err) '
        'When boot Then states: Unauthenticated -> Authenticated -> SessionError',
        () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(repository: repo);

      // Observa el stream del bloc
      final List<SessionState> seen = <SessionState>[];
      final StreamSubscription<SessionState> sub =
          session.stream.listen(seen.add);

      await session.boot();

      // 1) signed-out
      repo.addAuth(Right<ErrorItem, UserModel?>(null));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      // 2) signed-in
      repo.addAuth(Right<ErrorItem, UserModel?>(_u('a@b.com')));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      // 3) error
      repo.addAuth(
        Left<ErrorItem, UserModel?>(SessionErrorItems.networkUnavailable),
      );
      await Future<void>.delayed(const Duration(milliseconds: 1));

      await sub.cancel();
      await repo.closeAuth();

      // Filtra duplicados o inicial dependiendo de tu BlocGeneral (normalmente inicia en Unauthenticated)
      // Verificamos que al menos contenga estas transiciones en orden relativo:
      expect(seen.whereType<Unauthenticated>(), isNotEmpty);
      expect(seen.any((SessionState s) => s is Authenticated), isTrue);
      expect(seen.any((SessionState s) => s is SessionError), isTrue);

      // Verifica el último estado sea SessionError
      expect(seen.last, isA<SessionError>());
    });
  });

  group('BlocSession.fromRepository | logIn & logOut flows', () {
    test('logIn success sets Authenticating then Authenticated', () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(repository: repo);

      // Captura dos estados: Authenticating -> Authenticated
      final List<SessionState> seen = <SessionState>[];
      final StreamSubscription<SessionState> sub =
          session.stream.listen(seen.add);

      final Either<ErrorItem, UserModel> r =
          await session.logIn(email: 'me@mail.com', password: 'secret');

      r.fold(
        (_) => fail('Expected Right'),
        (UserModel u) => expect(u.email, 'me@mail.com'),
      );

      // Da un tick al event loop para que el stream propague
      await Future<void>.delayed(const Duration(milliseconds: 1));

      await sub.cancel();

      // Debe contener Authenticating seguido de Authenticated
      final int idxAuthing =
          seen.indexWhere((SessionState s) => s is Authenticating);
      final int idxAuthed =
          seen.lastIndexWhere((SessionState s) => s is Authenticated);
      expect(idxAuthing, isNonNegative);
      expect(idxAuthed, greaterThan(idxAuthing));
    });

    test('logOut success from Authenticated leads to Unauthenticated',
        () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(repository: repo);

      await session.boot();

      // Emite signed-in primero
      repo.addAuth(Right<ErrorItem, UserModel?>(_u('user@mail.com')));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(session.state, isA<Authenticated>());

      final Either<ErrorItem, void>? r = await session.logOut();
      expect(r, isNotNull);
      r!.fold((_) => fail('Expected Right for logout'), (_) {});

      // Un tick para propagación
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(session.stateOrDefault, isA<Unauthenticated>());
    });

    test(
        'refreshSession when not authenticated returns null and leaves Unauthenticated',
        () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(repository: repo);

      expect(session.stateOrDefault, isA<Unauthenticated>());
      final Either<ErrorItem, UserModel>? r = await session.refreshSession();
      expect(r, isNull);
      expect(session.stateOrDefault, isA<Unauthenticated>());
    });
  });

  group('BlocSession.fromRepository | post-dispose policies', () {
    test('returnLastSnapshot returns last Authenticated snapshot after dispose',
        () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(
        repository: repo,
        postDisposePolicy: PostDisposePolicy.returnLastSnapshot,
      );

      await session.boot();
      // Haz signed-in
      final UserModel user = _u('snap@mail.com');
      repo.addAuth(Right<ErrorItem, UserModel?>(user));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(session.state, isA<Authenticated>());

      session.dispose();

      // Con política "returnLastSnapshot" los getters no lanzan y devuelven el último snapshot
      expect(session.state, isA<Authenticated>());
      expect(session.stateOrDefault, isA<Authenticated>());
      expect(session.currentUser.email, 'snap@mail.com');
      expect(session.isAuthenticated, isTrue);

      // El stream getter devuelve el mismo stream (ya cerrado); no lo probamos con emisiones.
    });

    test(
        'returnSessionError returns SessionError/Unauthenticated/defaultUser after dispose',
        () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(
        repository: repo,
        postDisposePolicy: PostDisposePolicy.returnSessionError,
      );

      await session.boot();
      session.dispose();

      // state -> SessionError(_disposedError)
      expect(session.state, isA<SessionError>());
      // stateOrDefault -> Unauthenticated
      expect(session.stateOrDefault, isA<Unauthenticated>());
      // currentUser -> defaultUserModel
      expect(session.currentUser, equals(defaultUserModel));
      // isAuthenticated -> false
      expect(session.isAuthenticated, isFalse);
    });
  });
}
