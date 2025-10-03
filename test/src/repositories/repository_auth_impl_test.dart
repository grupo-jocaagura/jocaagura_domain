import 'dart:async';
import 'dart:collection'; // para MapBase

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class _ThrowingIsSignedInMap extends MapBase<String, dynamic> {
  @override
  dynamic operator [](Object? key) {
    if (key == 'isSignedIn') {
      throw StateError('boom on isSignedIn');
    }
    if (key == 'ok') {
      return true; // evita que el mapper marque error
    }
    return null; // resto de claves no relevantes
  }

  @override
  void operator []=(String key, dynamic value) {}

  @override
  void clear() {}

  @override
  Iterable<String> get keys => const <String>[];

  @override
  dynamic remove(Object? key) => null;
}

/// Mapa que lanza al leer 'id' o 'email' (usadas por UserModel.fromJson),
/// pero no molesta al mapper (ok:true).
class _ThrowingUserFieldsMap extends MapBase<String, dynamic> {
  @override
  dynamic operator [](Object? key) {
    if (key == 'id' || key == 'email') {
      throw StateError('boom on user field');
    }
    if (key == 'ok') {
      return true; // evita Left por mapper
    }
    return null;
  }

  @override
  void operator []=(String key, dynamic value) {}

  @override
  void clear() {}

  @override
  Iterable<String> get keys => const <String>[];

  @override
  dynamic remove(Object? key) => null;
}

class _FakeErrorMapper implements ErrorMapper {
  const _FakeErrorMapper();

  @override
  ErrorItem fromException(
    Object error,
    StackTrace stackTrace, {
    String location = 'unknown',
  }) {
    return SessionErrorItems.unknown.copyWith(
      description: error.toString(),
      meta: <String, dynamic>{
        ...SessionErrorItems.unknown.meta,
        'location': location,
      },
    );
  }

  @override
  ErrorItem? fromPayload(
    Map<String, dynamic> payload, {
    String location = 'unknown',
  }) {
    final Object? ok = payload['ok'];
    if (ok is bool && ok == false) {
      return SessionErrorItems.unknown.copyWith(
        meta: <String, dynamic>{
          ...SessionErrorItems.unknown.meta,
          'location': location,
        },
      );
    }
    if (payload.containsKey('error')) {
      return SessionErrorItems.unknown.copyWith(
        meta: <String, dynamic>{
          ...SessionErrorItems.unknown.meta,
          'location': location,
        },
      );
    }
    if (payload.containsKey('code') && payload.containsKey('message')) {
      return SessionErrorItems.unknown.copyWith(
        meta: <String, dynamic>{
          ...SessionErrorItems.unknown.meta,
          'location': location,
        },
      );
    }
    return null;
  }
}

class _StubGateway implements GatewayAuth {
  _StubGateway({
    this.signIn,
    this.login,
    this.google,
    this.silent,
    this.refresh,
    this.recover,
    this.logout,
    this.current,
    this.signedIn,
    Stream<Either<ErrorItem, Map<String, dynamic>?>>? authStream,
  }) : _stream = authStream ??
            const Stream<Either<ErrorItem, Map<String, dynamic>?>>.empty();

  final Either<ErrorItem, Map<String, dynamic>>? signIn;
  final Either<ErrorItem, Map<String, dynamic>>? login;
  final Either<ErrorItem, Map<String, dynamic>>? google;
  final Either<ErrorItem, Map<String, dynamic>>? silent;
  final Either<ErrorItem, Map<String, dynamic>>? refresh;
  final Either<ErrorItem, Map<String, dynamic>>? recover;
  final Either<ErrorItem, Map<String, dynamic>>? logout;
  final Either<ErrorItem, Map<String, dynamic>>? current;
  final Either<ErrorItem, Map<String, dynamic>>? signedIn;

  final Stream<Either<ErrorItem, Map<String, dynamic>?>> _stream;

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> signInUserAndPassword(
    String email,
    String password,
  ) async {
    return signIn ??
        Right<ErrorItem, Map<String, dynamic>>(
          <String, dynamic>{'id': email, 'email': email},
        );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logInUserAndPassword(
    String email,
    String password,
  ) async {
    return login ??
        Right<ErrorItem, Map<String, dynamic>>(
          <String, dynamic>{'id': email, 'email': email},
        );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logInWithGoogle() async {
    return google ??
        Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'id': 'g', 'email': 'g@x.com'},
        );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logInSilently(
    Map<String, dynamic> sessionJson,
  ) async {
    return silent ?? Right<ErrorItem, Map<String, dynamic>>(sessionJson);
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> refreshSession(
    Map<String, dynamic> sessionJson,
  ) async {
    final Map<String, dynamic> next = <String, dynamic>{
      ...sessionJson,
      'jwt': <String, dynamic>{'accessToken': 'r'},
    };
    return refresh ?? Right<ErrorItem, Map<String, dynamic>>(next);
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> recoverPassword(
    String email,
  ) async {
    return recover ??
        Right<ErrorItem, Map<String, dynamic>>(
          <String, dynamic>{'ok': true, 'email': email},
        );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logOutUser(
    Map<String, dynamic> sessionJson,
  ) async {
    return logout ??
        Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'ok': true},
        );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> getCurrentUser() async {
    return current ??
        Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'id': 'id', 'email': 'a@b.com'},
        );
    // Para simular "no session" como error, retorna Left
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> isSignedIn() async {
    return signedIn ??
        Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'isSignedIn': true},
        );
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>?>> authStateChanges() =>
      _stream;
}

// Helpers
Future<T> _expectRight<T>(
  Future<Either<ErrorItem, T>> fut, {
  void Function(T v)? verify,
}) async {
  final Either<ErrorItem, T> r = await fut;
  return r.fold(
    (ErrorItem l) => fail('Expected Right, got Left: $l'),
    (T v) {
      verify?.call(v);
      return v;
    },
  );
}

Future<void> _expectLeft<T>(Future<Either<ErrorItem, T>> fut) async {
  final Either<ErrorItem, T> r = await fut;
  r.fold(
    (_) {},
    (_) => fail('Expected Left, got Right'),
  );
}

void main() {
  group('RepositoryAuthImpl | happy paths', () {
    test('StubGateway acepta todos los parámetros opcionales (silencia lints)',
        () {
      final _StubGateway g = _StubGateway(
        signIn: Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'id': 's', 'email': 's@x.com'},
        ),
        login: Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'id': 'l', 'email': 'l@x.com'},
        ),
        google: Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'id': 'g', 'email': 'g@x.com'},
        ),
        silent: Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'id': 'z', 'email': 'z@x.com'},
        ),
        refresh: Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'id': 'r', 'email': 'r@x.com'},
        ),
        recover: Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'ok': true},
        ),
        logout: Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'ok': true},
        ),
        current: Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'id': 'c', 'email': 'c@x.com'},
        ),
        signedIn: Right<ErrorItem, Map<String, dynamic>>(
          const <String, dynamic>{'isSignedIn': true},
        ),
        authStream:
            const Stream<Either<ErrorItem, Map<String, dynamic>?>>.empty(),
      );
      expect(g, isA<_StubGateway>());
    });

    test('logInUserAndPassword → Right(UserModel)', () async {
      final GatewayAuth gw = _StubGateway(
        login: Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{
          'id': 'u1',
          'email': 'a@b.com',
          'jwt': <String, dynamic>{'accessToken': 't'},
        }),
      );
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: gw,
        errorMapper: const _FakeErrorMapper(),
      );

      final Either<ErrorItem, UserModel> r =
          await repo.logInUserAndPassword('a@b.com', 'x');
      r.fold(
        (ErrorItem l) => fail('should be Right'),
        (UserModel u) => expect(u.email, 'a@b.com'),
      );
    });

    test('logInWithGoogle → Right(UserModel)', () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(
          google: Right<ErrorItem, Map<String, dynamic>>(
            const <String, dynamic>{'id': 'g', 'email': 'g@x.com'},
          ),
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      final Either<ErrorItem, UserModel> r = await repo.logInWithGoogle();
      r.fold(
        (ErrorItem l) => fail('should be Right'),
        (UserModel u) => expect(u.email, 'g@x.com'),
      );
    });

    test('logInSilently/refreshSession → Right(UserModel)', () async {
      final UserModel current = UserModel.fromJson(
        const <String, dynamic>{'id': 'id', 'email': 'a@b.com'},
      );
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectRight<UserModel>(repo.logInSilently(current));
      await _expectRight<UserModel>(repo.refreshSession(current));
    });

    test('recoverPassword/logOutUser → Right(void)', () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectRight<void>(repo.recoverPassword('a@b.com'));
      final UserModel u = UserModel.fromJson(
        const <String, dynamic>{'id': 'id', 'email': 'a@b.com'},
      );
      await _expectRight<void>(repo.logOutUser(u));
    });

    test('getCurrentUser → Right(UserModel)', () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(
          current: Right<ErrorItem, Map<String, dynamic>>(
            const <String, dynamic>{'id': 'id', 'email': 'a@b.com'},
          ),
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      final Either<ErrorItem, UserModel> r = await repo.getCurrentUser();
      r.fold(
        (ErrorItem l) => fail('should be Right'),
        (UserModel u) => expect(u.email, 'a@b.com'),
      );
    });

    test('isSignedIn → Right(bool)', () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(
          signedIn: Right<ErrorItem, Map<String, dynamic>>(
            const <String, dynamic>{'isSignedIn': false},
          ),
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      final Either<ErrorItem, bool> r = await repo.isSignedIn();
      r.fold(
        (ErrorItem l) => fail('should be Right'),
        (bool b) => expect(b, isFalse),
      );
    });
  });

  group('RepositoryAuthImpl | payload errors & exceptions', () {
    test('payload error (ok:false) → Left en signIn', () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(
          signIn: Right<ErrorItem, Map<String, dynamic>>(
            const <String, dynamic>{'ok': false, 'message': 'nope'},
          ),
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectLeft<UserModel>(repo.signInUserAndPassword('a@b.com', 'x'));
    });

    test('payload inválido (ok:false) → Left', () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(
          login: Right<ErrorItem, Map<String, dynamic>>(
            const <String, dynamic>{'ok': false, 'message': 'invalid'},
          ),
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectLeft<UserModel>(repo.logInUserAndPassword('a@b.com', 'x'));
    });

    test('isSignedIn payload error → Left', () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(
          signedIn: Right<ErrorItem, Map<String, dynamic>>(
            const <String, dynamic>{'ok': false},
          ),
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectLeft<bool>(repo.isSignedIn());
    });

    test('malformed json (payload inválido) → Left vía mapper', () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(
          login: Right<ErrorItem, Map<String, dynamic>>(
            const <String, dynamic>{'ok': false, 'message': 'invalid'},
          ),
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectLeft<UserModel>(repo.logInUserAndPassword('a@b.com', 'x'));
    });
  });

  group('RepositoryAuthImpl | authStateChanges', () {
    test('secuencia Right(null) → Right(user)', () async {
      final StreamController<Either<ErrorItem, Map<String, dynamic>?>> ctrl =
          StreamController<Either<ErrorItem, Map<String, dynamic>?>>();
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(authStream: ctrl.stream),
        errorMapper: const _FakeErrorMapper(),
      );

      final List<Either<ErrorItem, UserModel?>> emissions =
          <Either<ErrorItem, UserModel?>>[];
      final StreamSubscription<Either<ErrorItem, UserModel?>> sub =
          repo.authStateChanges().listen(emissions.add);

      ctrl.add(Right<ErrorItem, Map<String, dynamic>?>(null));
      ctrl.add(
        Right<ErrorItem, Map<String, dynamic>?>(
          const <String, dynamic>{'id': 'id', 'email': 'a@b.com'},
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await ctrl.close();
      await sub.cancel();

      expect(emissions.length, 2);
      emissions[0].fold(
        (_) => fail('expected Right(null)'),
        (UserModel? u) => expect(u, isNull),
      );
      emissions[1].fold(
        (_) => fail('expected Right(user)'),
        (UserModel? u) => expect(u!.email, 'a@b.com'),
      );
    });

    test('payload error en stream → Left', () async {
      final StreamController<Either<ErrorItem, Map<String, dynamic>?>> ctrl =
          StreamController<Either<ErrorItem, Map<String, dynamic>?>>();
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(authStream: ctrl.stream),
        errorMapper: const _FakeErrorMapper(),
      );

      final Completer<void> seenLeft = Completer<void>();
      final StreamSubscription<Either<ErrorItem, UserModel?>> sub =
          repo.authStateChanges().listen((Either<ErrorItem, UserModel?> e) {
        e.fold((_) => seenLeft.complete(), (_) {});
      });

      ctrl.add(
        Right<ErrorItem, Map<String, dynamic>?>(
          const <String, dynamic>{'ok': false},
        ),
      );
      await seenLeft.future;
      await ctrl.close();
      await sub.cancel();
    });

    test('Left(ErrorItem) desde el Gateway → Left en repo', () async {
      final Stream<Either<ErrorItem, Map<String, dynamic>?>> s =
          Stream<Either<ErrorItem, Map<String, dynamic>?>>.fromIterable(
        <Either<ErrorItem, Map<String, dynamic>?>>[
          Left<ErrorItem, Map<String, dynamic>?>(
            SessionErrorItems.networkUnavailable,
          ),
        ],
      );
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(authStream: s),
        errorMapper: const _FakeErrorMapper(),
      );

      final Either<ErrorItem, UserModel?> first =
          await repo.authStateChanges().first;
      first.fold(
        (ErrorItem l) => expect(l.code, 'AUTH_NETWORK_UNAVAILABLE'),
        (_) => fail('expected Left'),
      );
    });
  });
  group('RepositoryAuthImpl | branch coverage', () {
    test(
        'onOk(identity) en signInUserAndPassword → Right con el UserModel mapeado',
        () async {
      // El gateway entrega JSON válido; onOk devuelve el mismo UserModel (identidad).
      final GatewayAuth gw = _StubGateway(
        signIn: Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{
          'id': 'u1',
          'email': 'onok@x.com',
          'jwt': <String, dynamic>{'accessToken': 't'},
        }),
      );
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: gw,
        errorMapper: const _FakeErrorMapper(),
      );

      final Either<ErrorItem, UserModel> r =
          await repo.signInUserAndPassword('onok@x.com', 'x');

      r.fold(
        (ErrorItem l) => fail('Esperado Right, got Left: $l'),
        (UserModel u) {
          expect(u.email, 'onok@x.com'); // se ejecutó onOk(u) => u
          expect(u.id, 'u1');
        },
      );
    });

    test('ackToVoid: ok:false en recoverPassword → Left (ramal pe!=null)',
        () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(
          recover: Right<ErrorItem, Map<String, dynamic>>(
            const <String, dynamic>{'ok': false, 'message': 'invalid'},
          ),
        ),
        errorMapper: const _FakeErrorMapper(), // detecta ok:false
      );

      final Either<ErrorItem, void> r = await repo.recoverPassword('a@b.com');
      r.fold(
        (ErrorItem _) {}, // Left esperado
        (_) => fail('Esperado Left, got Right'),
      );
    });

    test('isSignedIn: excepción en try interno → Left (ramal catch)', () async {
      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(
          signedIn:
              Right<ErrorItem, Map<String, dynamic>>(_ThrowingIsSignedInMap()),
        ),
        errorMapper: const _FakeErrorMapper(),
      );

      final Either<ErrorItem, bool> r = await repo.isSignedIn();
      r.fold(
        (ErrorItem _) {}, // Left esperado
        (bool _) => fail('Esperado Left por excepción, got Right'),
      );
    });
    test(
        'authStateChanges: excepción al parsear UserModel → Left (ramal catch)',
        () async {
      final Stream<Either<ErrorItem, Map<String, dynamic>?>> s =
          Stream<Either<ErrorItem, Map<String, dynamic>?>>.fromIterable(
        <Either<ErrorItem, Map<String, dynamic>?>>[
          Right<ErrorItem, Map<String, dynamic>?>(_ThrowingUserFieldsMap()),
        ],
      );

      final RepositoryAuth repo = RepositoryAuthImpl(
        gateway: _StubGateway(authStream: s),
        errorMapper: const _FakeErrorMapper(),
      );

      final Either<ErrorItem, UserModel?> first =
          await repo.authStateChanges().first;
      first.fold(
        (ErrorItem _) {}, // Left esperado por catch(ex, st)
        (_) => fail('Esperado Left por excepción de parsing'),
      );
    });
  });
}
