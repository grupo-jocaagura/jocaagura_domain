import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Repo fake para impulsar cambios de sesión
/// -------------------------
class _RepoFake implements RepositoryAuth {
  _RepoFake()
      : _ctrl = StreamController<Either<ErrorItem, UserModel?>>.broadcast();

  final StreamController<Either<ErrorItem, UserModel?>> _ctrl;

  // Helpers para inyectar eventos al stream de auth:
  void addAuth(Either<ErrorItem, UserModel?> e) => _ctrl.add(e);

  Future<void> close() => _ctrl.close();

  // Implementaciones mínimas para satisfacer la interfaz (no usadas aquí):
  @override
  Stream<Either<ErrorItem, UserModel?>> authStateChanges() => _ctrl.stream;

  @override
  Future<Either<ErrorItem, UserModel>> getCurrentUser() async =>
      Left<ErrorItem, UserModel>(SessionErrorItems.notSignedIn);

  @override
  Future<Either<ErrorItem, bool>> isSignedIn() async =>
      Right<ErrorItem, bool>(false);

  @override
  Future<Either<ErrorItem, UserModel>> logInSilently(
    UserModel currentUser,
  ) async =>
      Right<ErrorItem, UserModel>(currentUser);

  @override
  Future<Either<ErrorItem, UserModel>> logInUserAndPassword(
    String email,
    String password,
  ) async =>
      Right<ErrorItem, UserModel>(
        UserModel.fromJson(<String, dynamic>{'id': email, 'email': email}),
      );

  @override
  Future<Either<ErrorItem, UserModel>> logInWithGoogle() async =>
      Right<ErrorItem, UserModel>(
        UserModel.fromJson(
          const <String, dynamic>{'id': 'g', 'email': 'g@x.com'},
        ),
      );

  @override
  Future<Either<ErrorItem, void>> logOutUser(UserModel user) async =>
      Right<ErrorItem, UserModel>(defaultUserModel);

  @override
  Future<Either<ErrorItem, void>> recoverPassword(String email) async =>
      Right<ErrorItem, UserModel>(defaultUserModel);

  @override
  Future<Either<ErrorItem, UserModel>> refreshSession(
    UserModel currentUser,
  ) async =>
      Right<ErrorItem, UserModel>(currentUser);

  @override
  Future<Either<ErrorItem, UserModel>> signInUserAndPassword(
    String email,
    String password,
  ) async =>
      Right<ErrorItem, UserModel>(
        UserModel.fromJson(<String, dynamic>{'id': email, 'email': email}),
      );
}

/// Usuario de prueba
UserModel _u(String email) =>
    UserModel.fromJson(<String, dynamic>{'id': email, 'email': email});

void main() {
  group('BlocSession hooks', () {
    test(
        'addFunctionToProcessTValueOnStream with executeNow=true is called immediately with current snapshot',
        () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(repository: repo);

      // Estado inicial del bloc es Unauthenticated (antes de boot)
      SessionState? lastSeen;
      session.addFunctionToProcessTValueOnStream(
        'immediate',
        (SessionState s) {
          lastSeen = s;
        },
        true,
      );

      expect(lastSeen, isA<Unauthenticated>());

      // Limpieza
      session.deleteFunctionToProcessTValueOnStream('immediate');
      session.dispose();
      await repo.close();
    });

    test(
        'hook receives subsequent emissions (Unauthenticated -> Authenticated -> SessionError)',
        () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(repository: repo);

      final List<Type> seenTypes = <Type>[];
      session.addFunctionToProcessTValueOnStream('observer', (SessionState s) {
        seenTypes.add(s.runtimeType);
      });

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

      // Assert: las tres clases de estado fueron observadas
      expect(seenTypes.any((Type t) => t == Unauthenticated), isTrue);
      expect(seenTypes.any((Type t) => t == Authenticated), isTrue);
      expect(seenTypes.any((Type t) => t == SessionError), isTrue);

      // Limpieza
      session.deleteFunctionToProcessTValueOnStream('observer');
      session.dispose();
      await repo.close();
    });

    test(
        'deleteFunctionToProcessTValueOnStream detiene invocaciones posteriores',
        () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(repository: repo);

      int calls = 0;
      session.addFunctionToProcessTValueOnStream('counter', (_) {
        calls++;
      });

      await session.boot();

      // Primera emisión: debería incrementar
      repo.addAuth(Right<ErrorItem, UserModel?>(null));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(calls, greaterThanOrEqualTo(1));

      // Elimina el hook y emite de nuevo
      session.deleteFunctionToProcessTValueOnStream('counter');
      final int before = calls;

      repo.addAuth(Right<ErrorItem, UserModel?>(_u('b@x.com')));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      // No debe incrementarse después de borrar
      expect(calls, before);

      session.dispose();
      await repo.close();
    });

    test(
        'containsFunctionToProcessValueOnStream reflects registration lifecycle',
        () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(repository: repo);

      expect(session.containsFunctionToProcessValueOnStream('k'), isFalse);

      session.addFunctionToProcessTValueOnStream('k', (_) {});
      expect(session.containsFunctionToProcessValueOnStream('k'), isTrue);

      session.deleteFunctionToProcessTValueOnStream('k');
      expect(session.containsFunctionToProcessValueOnStream('k'), isFalse);

      session.dispose();
      await repo.close();
    });

    test('replacing a hook with the same key swaps the function', () async {
      final _RepoFake repo = _RepoFake();
      final BlocSession session = BlocSession.fromRepository(repository: repo);

      int a = 0;
      int b = 0;

      session.addFunctionToProcessTValueOnStream('dup', (_) => a++);
      await session.boot();

      repo.addAuth(Right<ErrorItem, UserModel?>(null));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(a, greaterThanOrEqualTo(1));
      expect(b, 0);

      // Reemplaza el hook bajo la misma llave
      session.addFunctionToProcessTValueOnStream('dup', (_) => b++);

      repo.addAuth(Right<ErrorItem, UserModel?>(_u('c@x.com')));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      // Ya no debería incrementarse `a`; ahora incrementa `b`
      final int aAfter = a;
      expect(b, greaterThanOrEqualTo(1));

      repo.addAuth(Left<ErrorItem, UserModel?>(SessionErrorItems.timeout));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(a, aAfter); // a no cambió

      session.dispose();
      await repo.close();
    });
  });
}
