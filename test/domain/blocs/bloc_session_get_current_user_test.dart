import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Fake mínimo de RepositoryAuth para probar getCurrentUser().
class FakeRepositoryAuth implements RepositoryAuth {
  FakeRepositoryAuth({
    required this.getCurrentUserBehavior,
    Stream<Either<ErrorItem, UserModel?>>? authStream,
  }) : _authCtrl = StreamController<Either<ErrorItem, UserModel?>>.broadcast() {
    authStream?.listen(_authCtrl.add);
  }

  int getCurrentUserCalls = 0;
  final Future<Either<ErrorItem, UserModel>> Function() getCurrentUserBehavior;
  final StreamController<Either<ErrorItem, UserModel?>> _authCtrl;

  @override
  Future<Either<ErrorItem, UserModel>> getCurrentUser() async {
    getCurrentUserCalls++;
    return getCurrentUserBehavior();
  }

  // --- Stubs no usados por este test ---
  Stream<Either<ErrorItem, UserModel?>> watchAuthStateChanges() =>
      _authCtrl.stream;

  @override
  Future<Either<ErrorItem, UserModel>> logInSilently(UserModel user) async =>
      Left<ErrorItem, UserModel>(
        const ErrorItem(title: 'stub', code: 'STUB', description: ''),
      );

  @override
  Future<Either<ErrorItem, UserModel>> logInUserAndPassword(
    String email,
    String password,
  ) async =>
      Left<ErrorItem, UserModel>(
        const ErrorItem(title: 'stub', code: 'STUB', description: ''),
      );

  @override
  Future<Either<ErrorItem, UserModel>> logInWithGoogle() async =>
      Left<ErrorItem, UserModel>(
        const ErrorItem(title: 'stub', code: 'STUB', description: ''),
      );

  @override
  Future<Either<ErrorItem, void>> logOutUser(UserModel user) async =>
      Left<ErrorItem, UserModel>(
        const ErrorItem(title: 'stub', code: 'STUB', description: ''),
      );

  @override
  Future<Either<ErrorItem, void>> recoverPassword(String email) async =>
      Left<ErrorItem, UserModel>(
        const ErrorItem(title: 'stub', code: 'STUB', description: ''),
      );

  @override
  Future<Either<ErrorItem, UserModel>> refreshSession(
    UserModel currentUser,
  ) async =>
      Left<ErrorItem, UserModel>(
        const ErrorItem(title: 'stub', code: 'STUB', description: ''),
      );

  void dispose() {
    _authCtrl.close();
  }

  @override
  Stream<Either<ErrorItem, UserModel?>> authStateChanges() {
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorItem, bool>> isSignedIn() {
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorItem, UserModel>> signInUserAndPassword(
    String email,
    String password,
  ) {
    throw UnimplementedError();
  }
}

void main() {
  group('BlocSession.getCurrentUser', () {
    late FakeRepositoryAuth repo;
    late BlocSession bloc;

    tearDown(() {
      bloc.dispose();
      repo.dispose();
    });

    test(
        'Given repo success '
        'When getCurrentUser '
        'Then emits Authenticating then Authenticated and returns Right',
        () async {
      // Arrange
      const UserModel expected = UserModel(
        id: 'u1',
        email: 'user@mail.com',
        displayName: 'user',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );

      repo = FakeRepositoryAuth(
        getCurrentUserBehavior: () async =>
            Right<ErrorItem, UserModel>(expected),
      );
      bloc = BlocSession.fromRepository(repository: repo);

      final List<SessionState> observed = <SessionState>[];
      final StreamSubscription<SessionState> sub =
          bloc.stream.listen(observed.add);

      // Act
      final Either<ErrorItem, UserModel> res = await bloc.getCurrentUser();

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();

      // Assert retorno
      expect(res.isRight, isTrue);
      res.fold((_) {}, (UserModel u) => expect(u, equals(expected)));

      // Assert estados
      expect(observed.any((SessionState s) => s is Authenticating), isTrue);
      expect(
        observed
            .any((SessionState s) => s is Authenticated && s.user == expected),
        isTrue,
      );
    });

    test(
        'Given repo failure '
        'When getCurrentUser '
        'Then emits Authenticating then SessionError and returns Left',
        () async {
      // Arrange
      const ErrorItem expectedErr = ErrorItem(
        title: 'No session',
        code: 'NO_SESSION',
        description: 'No user is currently authenticated',
      );

      repo = FakeRepositoryAuth(
        getCurrentUserBehavior: () async =>
            Left<ErrorItem, UserModel>(expectedErr),
      );
      bloc = BlocSession.fromRepository(repository: repo);

      final List<SessionState> observed = <SessionState>[];
      final StreamSubscription<SessionState> sub =
          bloc.stream.listen(observed.add);

      // Act
      final Either<ErrorItem, UserModel> res = await bloc.getCurrentUser();

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();

      // Assert retorno
      expect(res.isLeft, isTrue);
      res.fold(
        (ErrorItem e) => expect(e.code, expectedErr.code),
        (_) => fail('Expected Left'),
      );

      // Assert estados
      expect(observed.any((SessionState s) => s is Authenticating), isTrue);
      expect(
        observed.any(
          (SessionState s) =>
              s is SessionError && s.error.code == expectedErr.code,
        ),
        isTrue,
      );
    });

    test(
        'Given disposed bloc '
        'When getCurrentUser '
        'Then throws StateError', () async {
      // Arrange
      repo = FakeRepositoryAuth(
        getCurrentUserBehavior: () async => Right<ErrorItem, UserModel>(
          const UserModel(
            id: 'u1',
            email: 'user@mail.com',
            displayName: 'user',
            photoUrl: '',
            jwt: <String, dynamic>{},
          ),
        ),
      );
      bloc = BlocSession.fromRepository(repository: repo);
      bloc.dispose();

      // Act & Assert
      expect(() => bloc.getCurrentUser(), throwsA(isA<StateError>()));
    });

    test(
        'Given quick double call '
        'When debounced '
        'Then repository called once', () async {
      // Arrange
      const UserModel expected = UserModel(
        id: 'u1',
        email: 'user@mail.com',
        displayName: 'user',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );

      repo = FakeRepositoryAuth(
        getCurrentUserBehavior: () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return Right<ErrorItem, UserModel>(expected);
        },
      );
      bloc = BlocSession.fromRepository(repository: repo);

      // Act: dos llamadas casi simultáneas
      final Future<Either<ErrorItem, UserModel>> f1 = bloc.getCurrentUser();
      final Future<Either<ErrorItem, UserModel>> f2 = bloc.getCurrentUser();
      await Future.wait(<Future<Either<ErrorItem, UserModel>>>[f1, f2]);

      // Assert: el fake repo solo fue invocado una vez (debounce efectivo)
      expect(repo.getCurrentUserCalls, equals(1));
    });

    test('double call shares the same future result', () async {
      // Arrange
      const UserModel expected = UserModel(
        id: 'u1',
        email: 'user@mail.com',
        displayName: 'user',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );

      repo = FakeRepositoryAuth(
        getCurrentUserBehavior: () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return Right<ErrorItem, UserModel>(expected);
        },
      );
      bloc = BlocSession.fromRepository(repository: repo);

      final Future<Either<ErrorItem, UserModel>> f1 = bloc.getCurrentUser();
      final Future<Either<ErrorItem, UserModel>> f2 = bloc.getCurrentUser();

      final List<Either<ErrorItem, UserModel>> results =
          await Future.wait(<Future<Either<ErrorItem, UserModel>>>[f1, f2]);

      expect(repo.getCurrentUserCalls, 1);
      expect(results[0].isRight && results[1].isRight, isTrue);
    });
  });
}
