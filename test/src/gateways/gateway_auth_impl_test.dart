import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Fake minimalista de ErrorItem (compatible con el modelo del dominio).
class _FakeErrorItem extends ErrorItem {
  const _FakeErrorItem({
    required super.code,
    required String message,
    String? location,
  }) : super(
          title: message,
          description: location ?? message,
          meta: const <String, dynamic>{},
        );
}

/// Fake ErrorMapper: mapea payloads con {ok:false} a ErrorItem y excepciones a ErrorItem.
/// Fake ErrorMapper: mapea payloads con {ok:false} a ErrorItem y excepciones a ErrorItem.
class _FakeErrorMapper implements ErrorMapper {
  const _FakeErrorMapper();

  @override
  ErrorItem fromException(Object e, StackTrace s, {String? location}) {
    return _FakeErrorItem(
      code: 'EX',
      message: e.toString(),
      location: location,
    );
  }

  @override
  ErrorItem? fromPayload(Map<String, dynamic> json, {String? location}) {
    final Object? ok = json['ok'];
    if (ok is bool && ok == false) {
      final String code = (json['code'] ?? 'PAYLOAD').toString();
      final String msg = (json['message'] ?? 'payload error').toString();
      return _FakeErrorItem(code: code, message: msg, location: location);
    }
    return null;
  }
}

/// Fake ServiceSession controlable por test.
class _StubServiceSession implements ServiceSession {
  _StubServiceSession({
    this.signInJson,
    this.loginJson,
    this.googleJson,
    this.silentJson,
    this.refreshJson,
    this.recoverJson,
    this.logoutJson,
    this.currentUserJson,
    this.isSignedInJson,
    Stream<Map<String, dynamic>?>? authStream,
    this.throwOnSignIn = false,
    this.throwOnLogin = false,
    this.throwOnGoogle = false,
    this.throwOnSilent = false,
    this.throwOnRefresh = false,
    this.throwOnRecover = false,
    this.throwOnLogout = false,
    this.throwOnCurrent = false,
    this.throwOnIsSignedIn = false,
  }) : _authStream = authStream;

  final Map<String, dynamic>? signInJson;
  final Map<String, dynamic>? loginJson;
  final Map<String, dynamic>? googleJson;
  final Map<String, dynamic>? silentJson;
  final Map<String, dynamic>? refreshJson;
  final Map<String, dynamic>? recoverJson;
  final Map<String, dynamic>? logoutJson;
  final Map<String, dynamic>? currentUserJson;
  final Map<String, dynamic>? isSignedInJson;

  final bool throwOnSignIn;
  final bool throwOnLogin;
  final bool throwOnGoogle;
  final bool throwOnSilent;
  final bool throwOnRefresh;
  final bool throwOnRecover;
  final bool throwOnLogout;
  final bool throwOnCurrent;
  final bool throwOnIsSignedIn;

  final Stream<Map<String, dynamic>?>? _authStream;

  @override
  Future<Map<String, dynamic>> signInUserAndPassword({
    required String email,
    required String password,
  }) async {
    if (throwOnSignIn) {
      throw StateError('signIn exception');
    }
    return signInJson ?? <String, dynamic>{'email': email, 'ok': true};
  }

  @override
  Future<Map<String, dynamic>> logInUserAndPassword({
    required String email,
    required String password,
  }) async {
    if (throwOnLogin) {
      throw StateError('login exception');
    }
    return loginJson ?? <String, dynamic>{'email': email, 'ok': true};
  }

  @override
  Future<Map<String, dynamic>> logInWithGoogle() async {
    if (throwOnGoogle) {
      throw StateError('google exception');
    }
    return googleJson ?? <String, dynamic>{'email': 'g@x.com', 'ok': true};
  }

  @override
  Future<Map<String, dynamic>> logInSilently(
    Map<String, dynamic> sessionJson,
  ) async {
    if (throwOnSilent) {
      throw StateError('silent exception');
    }
    return silentJson ?? <String, dynamic>{...sessionJson, 'ok': true};
  }

  @override
  Future<Map<String, dynamic>> refreshSession(
    Map<String, dynamic> sessionJson,
  ) async {
    if (throwOnRefresh) {
      throw StateError('refresh exception');
    }
    final Map<String, dynamic> base = <String, dynamic>{...sessionJson};
    base['jwt'] = <String, dynamic>{'accessToken': 'refreshed', 'ok': true};
    return refreshJson ?? base;
  }

  @override
  Future<Map<String, dynamic>> recoverPassword({required String email}) async {
    if (throwOnRecover) {
      throw StateError('recover exception');
    }
    return recoverJson ?? <String, dynamic>{'ok': true, 'email': email};
  }

  @override
  Future<Map<String, dynamic>> logOutUser(
    Map<String, dynamic> sessionJson,
  ) async {
    if (throwOnLogout) {
      throw StateError('logout exception');
    }
    return logoutJson ?? <String, dynamic>{'ok': true};
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    if (throwOnCurrent) {
      throw StateError('current exception');
    }
    final Map<String, dynamic>? v = currentUserJson;
    if (v == null) {
      throw StateError('no current');
    }
    return v;
  }

  @override
  Future<Map<String, dynamic>> isSignedIn() async {
    if (throwOnIsSignedIn) {
      throw StateError('isSignedIn exception');
    }
    return isSignedInJson ??
        <String, dynamic>{'isSignedIn': currentUserJson != null};
  }

  @override
  Stream<Map<String, dynamic>?> authStateChanges() {
    return _authStream ?? const Stream<Map<String, dynamic>?>.empty();
  }

  @override
  void dispose() {}
}

// ======= Helpers Either =======

Future<T> _expectRight<T>(
  Future<Either<ErrorItem, T>> fut, {
  void Function(T value)? verify,
}) async {
  final Either<ErrorItem, T> r = await fut;
  return r.fold(
    (ErrorItem l) {
      fail('Expected Right but got Left: $l');
    },
    (T val) {
      verify?.call(val);
      return val;
    },
  );
}

Future<ErrorItem> _expectLeft<T>(Future<Either<ErrorItem, T>> fut) async {
  final Either<ErrorItem, T> r = await fut;
  return r.fold(
    (ErrorItem l) => l,
    (T val) {
      fail('Expected Left but got Right: $val');
    },
  );
}

// ======= TESTS =======

void main() {
  group('GatewayAuthImpl | _guardJson paths', () {
    test(
        'Given success payload When logInUserAndPassword Then returns Right(user)',
        () async {
      final _StubServiceSession svc = _StubServiceSession(
        loginJson: <String, dynamic>{'email': 'a@b.com', 'ok': true},
      );
      final GatewayAuthImpl gw =
          GatewayAuthImpl(svc, errorMapper: const _FakeErrorMapper());

      await _expectRight<Map<String, dynamic>>(
        gw.logInUserAndPassword('a@b.com', 'x'),
        verify: (Map<String, dynamic> json) => expect(json['email'], 'a@b.com'),
      );
    });

    test(
        'Given payload error (ok:false) When signIn Then returns Left(ErrorItem)',
        () async {
      final _StubServiceSession svc = _StubServiceSession(
        signInJson: <String, dynamic>{
          'ok': false,
          'code': 'E100',
          'message': 'invalid',
        },
      );
      final GatewayAuthImpl gw =
          GatewayAuthImpl(svc, errorMapper: const _FakeErrorMapper());

      final ErrorItem err = await _expectLeft<Map<String, dynamic>>(
        gw.signInUserAndPassword('x@y.com', 'x'),
      );
      expect(err, isA<ErrorItem>());
    });

    test(
        'Given service throws exception When getCurrentUser Then returns Left(ErrorItem)',
        () async {
      final _StubServiceSession svc = _StubServiceSession(throwOnCurrent: true);
      final GatewayAuthImpl gw =
          GatewayAuthImpl(svc, errorMapper: const _FakeErrorMapper());

      final ErrorItem err =
          await _expectLeft<Map<String, dynamic>>(gw.getCurrentUser());
      expect(err, isA<ErrorItem>());
    });
  });

  group('GatewayAuthImpl | other methods happy path', () {
    test('logInWithGoogle Right', () async {
      final GatewayAuthImpl gw = GatewayAuthImpl(
        _StubServiceSession(
          googleJson: <String, dynamic>{'email': 'g@x.com', 'ok': true},
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectRight<Map<String, dynamic>>(gw.logInWithGoogle());
    });

    test('logInSilently Right', () async {
      final Map<String, dynamic> session = <String, dynamic>{
        'id': '1',
        'jwt': <String, dynamic>{},
      };
      final GatewayAuthImpl gw = GatewayAuthImpl(
        _StubServiceSession(
          silentJson: <String, dynamic>{...session, 'ok': true},
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectRight<Map<String, dynamic>>(gw.logInSilently(session));
    });

    test('refreshSession Right', () async {
      final Map<String, dynamic> session = <String, dynamic>{
        'id': '1',
        'jwt': <String, dynamic>{},
      };
      final GatewayAuthImpl gw = GatewayAuthImpl(
        _StubServiceSession(
          refreshJson: <String, dynamic>{
            ...session,
            'jwt': <String, dynamic>{'accessToken': 'refreshed'},
            'ok': true,
          },
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectRight<Map<String, dynamic>>(gw.refreshSession(session));
    });

    test('recoverPassword Right', () async {
      final GatewayAuthImpl gw = GatewayAuthImpl(
        _StubServiceSession(
          recoverJson: <String, dynamic>{'ok': true, 'email': 'a@b.com'},
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectRight<Map<String, dynamic>>(gw.recoverPassword('a@b.com'));
    });

    test('logOutUser Right', () async {
      final GatewayAuthImpl gw = GatewayAuthImpl(
        _StubServiceSession(logoutJson: <String, dynamic>{'ok': true}),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectRight<Map<String, dynamic>>(
        gw.logOutUser(<String, dynamic>{}),
      );
    });

    test('isSignedIn Right', () async {
      final GatewayAuthImpl gw = GatewayAuthImpl(
        _StubServiceSession(
          isSignedInJson: <String, dynamic>{
            'isSignedIn': true,
          },
        ),
        errorMapper: const _FakeErrorMapper(),
      );
      await _expectRight<Map<String, dynamic>>(
        gw.isSignedIn(),
        verify: (Map<String, dynamic> json) {
          expect(json['isSignedIn'], isTrue);
        },
      );
    });
  });

  group('GatewayAuthImpl | authStateChanges stream', () {
    test(
        'Given sequence [null, user] When listen Then emits Right(null) then Right(user)',
        () async {
      final StreamController<Map<String, dynamic>?> ctrl =
          StreamController<Map<String, dynamic>?>();
      final _StubServiceSession svc =
          _StubServiceSession(authStream: ctrl.stream);
      final GatewayAuthImpl gw =
          GatewayAuthImpl(svc, errorMapper: const _FakeErrorMapper());

      final List<Either<ErrorItem, Map<String, dynamic>?>> emissions =
          <Either<ErrorItem, Map<String, dynamic>?>>[];
      final StreamSubscription<Either<ErrorItem, Map<String, dynamic>?>> sub =
          gw.authStateChanges().listen(emissions.add);

      ctrl.add(null); // signed out
      ctrl.add(<String, dynamic>{'email': 'a@b.com'}); // signed in
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await ctrl.close();
      await sub.cancel();

      expect(emissions.length, 2);

      // 1st → Right(null)
      emissions[0].fold(
        (ErrorItem l) => fail('Expected Right(null) as first emission'),
        (Map<String, dynamic>? r) => expect(r, isNull),
      );

      // 2nd → Right(user)
      emissions[1].fold(
        (ErrorItem l) => fail('Expected Right(user) as second emission'),
        (Map<String, dynamic>? r) => expect(r, isA<Map<String, dynamic>>()),
      );
    });

    test('Given payload error ok:false When listen Then emits Left(ErrorItem)',
        () async {
      final StreamController<Map<String, dynamic>?> ctrl =
          StreamController<Map<String, dynamic>?>();
      final _StubServiceSession svc =
          _StubServiceSession(authStream: ctrl.stream);
      final GatewayAuthImpl gw =
          GatewayAuthImpl(svc, errorMapper: const _FakeErrorMapper());

      final Completer<void> seenLeft = Completer<void>();
      final StreamSubscription<Either<ErrorItem, Map<String, dynamic>?>> sub =
          gw
              .authStateChanges()
              .listen((Either<ErrorItem, Map<String, dynamic>?> e) {
        e.fold((ErrorItem l) => seenLeft.complete(), (_) {});
      });

      ctrl.add(
        <String, dynamic>{'ok': false, 'code': 'E200', 'message': 'nope'},
      );
      await seenLeft.future;
      await ctrl.close();
      await sub.cancel();
    });

    test('Given service stream addError When listen Then emits Left(ErrorItem)',
        () async {
      final StreamController<Map<String, dynamic>?> ctrl =
          StreamController<Map<String, dynamic>?>();
      final _StubServiceSession svc =
          _StubServiceSession(authStream: ctrl.stream);
      final GatewayAuthImpl gw =
          GatewayAuthImpl(svc, errorMapper: const _FakeErrorMapper());

      final Completer<void> seenLeft = Completer<void>();
      final StreamSubscription<Either<ErrorItem, Map<String, dynamic>?>> sub =
          gw
              .authStateChanges()
              .listen((Either<ErrorItem, Map<String, dynamic>?> e) {
        e.fold((_) => seenLeft.complete(), (_) {});
      });

      ctrl.addError(StateError('boom')); // debe mapear a Left(ErrorItem)
      await seenLeft.future;
      await ctrl.close();
      await sub.cancel();
    });
    test('Stub accepts all optional constructor params (silences lints)', () {
      final _StubServiceSession stub = _StubServiceSession(
        signInJson: <String, dynamic>{'ok': true},
        loginJson: <String, dynamic>{'ok': true},
        googleJson: <String, dynamic>{'ok': true},
        silentJson: <String, dynamic>{'ok': true},
        refreshJson: <String, dynamic>{'ok': true, 'jwt': <String, dynamic>{}},
        recoverJson: <String, dynamic>{'ok': true},
        logoutJson: <String, dynamic>{'ok': true},
        currentUserJson: <String, dynamic>{'email': 'x@y.com'},
        isSignedInJson: <String, dynamic>{'isSignedIn': true},
        authStream: const Stream<Map<String, dynamic>?>.empty(),
        throwOnSignIn: true,
        throwOnLogin: true,
        throwOnGoogle: true,
        throwOnSilent: true,
        throwOnRefresh: true,
        throwOnRecover: true,
        throwOnLogout: true,
        throwOnCurrent: true,
        throwOnIsSignedIn: true,
      );
      expect(stub, isA<_StubServiceSession>());
    });
  });
}
