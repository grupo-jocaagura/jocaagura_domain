import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FakeServiceSession (Map-based ServiceSession)', () {
    late FakeServiceSession session;

    setUp(() {
      session = FakeServiceSession();
    });

    tearDown(() {
      session.dispose();
    });

    test('logInUserAndPassword coloca estado en signed in y emite payload',
        () async {
      final List<Map<String, dynamic>?> events = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          session.authStateChanges().listen(events.add);

      await session.logInUserAndPassword(
        email: 'user@fake.com',
        password: 'pass',
      );

      final Map<String, dynamic> signedMap = await session.isSignedIn();
      expect(signedMap['isSignedIn'], isTrue);
      expect(events.isNotEmpty, isTrue);
      expect(events.last, isA<Map<String, dynamic>>());
      expect(events.last?['email'] ?? '', 'user@fake.com');

      await sub.cancel();
    });

    test('logOutUser coloca estado en signed out y emite null', () async {
      await session.logInUserAndPassword(
        email: 'user@fake.com',
        password: 'pass',
      );

      final List<Map<String, dynamic>?> events = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          session.authStateChanges().listen(events.add);

      final Map<String, dynamic> current = await session.getCurrentUser();
      await session.logOutUser(current);

      final Map<String, dynamic> signedMap = await session.isSignedIn();
      expect(signedMap['isSignedIn'], isFalse);
      expect(events.isNotEmpty, isTrue);
      expect(events.last, isNull);

      await sub.cancel();
    });

    test('logInUserAndPassword lanza si email vacío', () {
      expect(
        () => session.logInUserAndPassword(email: '', password: 'pass'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('logInUserAndPassword lanza si password vacío', () {
      expect(
        () =>
            session.logInUserAndPassword(email: 'user@fake.com', password: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('lanza error simulado cuando throwOnSignIn = true', () {
      session.dispose();
      session = FakeServiceSession(throwOnSignIn: true);
      expect(
        () => session.logInUserAndPassword(
          email: 'user@fake.com',
          password: 'pass',
        ),
        throwsA(isA<StateError>()),
      );
      session.dispose();
    });

    test('métodos lanzan después de dispose', () async {
      session.dispose();
      expect(
        () => session.logInUserAndPassword(email: 'u@f.com', password: 'p'),
        throwsA(isA<StateError>()),
      );
      expect(
        () => session.logOutUser(<String, dynamic>{'id': 'x'}),
        throwsA(isA<StateError>()),
      );
      expect(
        () => session.isSignedIn(),
        throwsA(isA<StateError>()),
      );
      expect(
        () => session.authStateChanges(),
        throwsA(isA<StateError>()),
      );
      expect(
        () => session.getCurrentUser(),
        throwsA(isA<StateError>()),
      );
    });

    group('getCurrentUser y authStateChanges', () {
      test(
          'getCurrentUser refleja el usuario tras login y lanza si no hay sesión',
          () async {
        await session.logInUserAndPassword(email: 'a@f.com', password: 'b');
        final Map<String, dynamic> u1 = await session.getCurrentUser();
        expect(u1['email'], 'a@f.com');

        final Map<String, dynamic> current = await session.getCurrentUser();
        await session.logOutUser(current);

        expect(() => session.getCurrentUser(), throwsA(isA<StateError>()));
      });

      test('authStateChanges emite payload tras login y null tras logout',
          () async {
        final List<Map<String, dynamic>?> payloads = <Map<String, dynamic>?>[];
        final StreamSubscription<Map<String, dynamic>?> sub =
            session.authStateChanges().listen(payloads.add);

        await session.logInUserAndPassword(email: 'a@f.com', password: 'b');
        final Map<String, dynamic> cur = await session.getCurrentUser();
        await session.logOutUser(cur);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Debe existir al menos un valor no nulo y terminar en null
        expect(payloads.any((Map<String, dynamic>? e) => e != null), isTrue);
        expect(payloads.last, isNull);

        await sub.cancel();
      });
    });

    group('logInWithGoogle', () {
      test('logInWithGoogle funciona y actualiza la sesión', () async {
        final Map<String, dynamic> payload = await session.logInWithGoogle();
        expect(payload['email'], isNotNull);

        final Map<String, dynamic> signedMap = await session.isSignedIn();
        expect(signedMap['isSignedIn'], isTrue);
      });

      test('logInWithGoogle lanza error si throwOnSignIn', () async {
        session.dispose();
        session = FakeServiceSession(throwOnSignIn: true);
        expect(() => session.logInWithGoogle(), throwsA(isA<StateError>()));
        session.dispose();
      });
    });

    test('nuevo login sobrescribe la sesión anterior', () async {
      await session.logInUserAndPassword(email: 'a@f.com', password: 'b');
      final Map<String, dynamic> u1 = await session.getCurrentUser();

      await session.logInUserAndPassword(email: 'b@f.com', password: 'c');
      final Map<String, dynamic> u2 = await session.getCurrentUser();

      expect(u1['id'], isNot(equals(u2['id'])));
      expect(u2['id'], 'b@f.com');
    });

    test('isSignedIn refleja el estado correctamente', () async {
      expect((await session.isSignedIn())['isSignedIn'], isFalse);
      await session.logInUserAndPassword(email: 'a@f.com', password: 'b');
      expect((await session.isSignedIn())['isSignedIn'], isTrue);

      final Map<String, dynamic> cur = await session.getCurrentUser();
      await session.logOutUser(cur);
      expect((await session.isSignedIn())['isSignedIn'], isFalse);
    });

    test('authStateChanges: secuencia coherente de null/non-null', () async {
      final List<Map<String, dynamic>?> values = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          session.authStateChanges().listen(values.add);

      await session.logInUserAndPassword(email: 'a@f.com', password: 'b');
      await session.logInUserAndPassword(
        email: 'a@f.com',
        password: 'b',
      ); // nuevo payload
      final Map<String, dynamic> cur = await session.getCurrentUser();
      await session.logOutUser(cur);
      // segundo logout sobre estado ya vacío provocará otro null en este fake? No, porque lanza tras dispose.
      // Aquí solo forzamos un wait para drenar eventos.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Debe haber al menos dos no-null por los dos logins y terminar en null
      expect(
        values.where((Map<String, dynamic>? e) => e != null).length >= 2,
        isTrue,
      );
      expect(values.last, isNull);

      await sub.cancel();
    });

    test('dispose cierra el stream; no se reciben más eventos luego', () async {
      final List<Map<String, dynamic>?> values = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          session.authStateChanges().listen(values.add);

      await session.logInUserAndPassword(email: 'a@f.com', password: 'b');
      session.dispose();

      // Intentar emitir tras dispose debe lanzar y no alterar la lista
      try {
        final Map<String, dynamic> cur = <String, dynamic>{
          'id': 'a@f.com',
          'email': 'a@f.com',
        };
        await session.logOutUser(cur);
      } catch (_) {}

      final int before = values.length;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(values.length, before); // sin nuevos eventos

      await sub.cancel();
    });
  });

  group('Additional FakeServiceSession behaviors (Map-based)', () {
    late FakeServiceSession session;

    setUp(() {
      session = FakeServiceSession();
    });

    tearDown(() {
      session.dispose();
    });

    test('authStateChanges emite null inicialmente', () async {
      final List<Map<String, dynamic>?> events = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          session.authStateChanges().listen(events.add);
      await Future<void>.delayed(Duration.zero);
      expect(events.first, isNull);
      await sub.cancel();
    });

    test('isSignedIn() indica false inicialmente', () async {
      final Map<String, dynamic> signed = await session.isSignedIn();
      expect(signed['isSignedIn'], isFalse);
    });

    test('authStateChanges emite payload tras logInWithGoogle()', () async {
      final List<Map<String, dynamic>?> events = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          session.authStateChanges().listen(events.add);
      await session.logInWithGoogle();
      await Future<void>.delayed(Duration.zero);
      expect(events.last, isA<Map<String, dynamic>>());
      await sub.cancel();
    });

    test('latencia configurable en logInUserAndPassword()', () async {
      final FakeServiceSession fake =
          FakeServiceSession(latency: const Duration(milliseconds: 50));
      final Stopwatch sw = Stopwatch()..start();
      await fake.logInUserAndPassword(email: 'u@f.com', password: 'p');
      sw.stop();
      expect(sw.elapsedMilliseconds >= 50, isTrue);
      fake.dispose();
    });

    test('latencia configurable en logInWithGoogle()', () async {
      final FakeServiceSession fake =
          FakeServiceSession(latency: const Duration(milliseconds: 50));
      final Stopwatch sw = Stopwatch()..start();
      await fake.logInWithGoogle();
      sw.stop();
      expect(sw.elapsedMilliseconds >= 50, isTrue);
      fake.dispose();
    });

    test('logOutUser tras logInWithGoogle resetea estado y emite null',
        () async {
      final List<Map<String, dynamic>?> events = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          session.authStateChanges().listen(events.add);

      final Map<String, dynamic> payload = await session.logInWithGoogle();
      expect((await session.isSignedIn())['isSignedIn'], isTrue);

      await session.logOutUser(payload);
      expect((await session.isSignedIn())['isSignedIn'], isFalse);
      expect(events.last, isNull);

      await sub.cancel();
    });

    test('múltiples listeners reciben los mismos eventos', () async {
      final List<Map<String, dynamic>?> events1 = <Map<String, dynamic>?>[];
      final List<Map<String, dynamic>?> events2 = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub1 =
          session.authStateChanges().listen(events1.add);
      final StreamSubscription<Map<String, dynamic>?> sub2 =
          session.authStateChanges().listen(events2.add);

      await session.logInUserAndPassword(email: 'a@f.com', password: 'b');
      final Map<String, dynamic> cur = await session.getCurrentUser();
      await session.logOutUser(cur);
      await Future<void>.delayed(Duration.zero);

      expect(events1.length, equals(events2.length));
      for (int i = 0; i < events1.length; i++) {
        final Map<String, dynamic>? a = events1[i];
        final Map<String, dynamic>? b = events2[i];
        if (a == null || b == null) {
          expect(a, equals(b));
        } else {
          // Comparación superficial clave principal: 'email'
          expect(a['email'], equals(b['email']));
        }
      }

      await sub1.cancel();
      await sub2.cancel();
    });
  });

  group('FakeServiceSession', () {
    late FakeServiceSession svc;

    setUp(() {
      svc = FakeServiceSession(latency: const Duration(milliseconds: 2));
    });

    tearDown(() {
      svc.dispose();
    });

    test('authStateChanges emite null inicialmente', () async {
      final List<Map<String, dynamic>?> events = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          svc.authStateChanges().listen(events.add);
      // da un tick
      await Future<void>.delayed(Duration.zero);
      expect(events.first, isNull);
      await sub.cancel();
    });

    test('signInUserAndPassword → sesión activa y evento en stream', () async {
      final List<Map<String, dynamic>?> subValues = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          svc.authStateChanges().listen(subValues.add);

      final Map<String, dynamic> user = await svc.signInUserAndPassword(
        email: 'a@x.com',
        password: '123',
      );

      expect(user['email'], 'a@x.com');
      final Map<String, dynamic> isSigned = await svc.isSignedIn();
      expect(isSigned['isSignedIn'], isTrue);

      // último evento no nulo
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(subValues.last, isNotNull);

      final Map<String, dynamic> current = await svc.getCurrentUser();
      expect(current['id'], 'a@x.com');

      await sub.cancel();
    });

    test('logInUserAndPassword con campos vacíos lanza ArgumentError',
        () async {
      expectLater(
        svc.logInUserAndPassword(email: '', password: 'x'),
        throwsA(isA<ArgumentError>()),
      );
      expectLater(
        svc.logInUserAndPassword(email: 'a@x.com', password: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throwOnSignIn=true hace fallar login/signin/google con StateError',
        () async {
      svc.dispose();
      svc = FakeServiceSession(
        latency: const Duration(milliseconds: 1),
        throwOnSignIn: true,
      );

      expectLater(
        svc.signInUserAndPassword(email: 'a@x.com', password: '1'),
        throwsA(isA<StateError>()),
      );
      expectLater(
        svc.logInUserAndPassword(email: 'a@x.com', password: '1'),
        throwsA(isA<StateError>()),
      );
      expectLater(
        svc.logInWithGoogle(),
        throwsA(isA<StateError>()),
      );
    });

    test('logInWithGoogle → usuario fake@fake.com y stream actualizado',
        () async {
      final List<Map<String, dynamic>?> subVals = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          svc.authStateChanges().listen(subVals.add);

      final Map<String, dynamic> user = await svc.logInWithGoogle();
      expect(user['email'], 'fake@fake.com');

      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(subVals.last?['email'], 'fake@fake.com');
      await sub.cancel();
    });

    test('logInSilently lanza si sessionJson vacío; funciona si no', () async {
      expectLater(
        svc.logInSilently(<String, dynamic>{}),
        throwsA(isA<StateError>()),
      );

      final Map<String, dynamic> payload = <String, dynamic>{
        'id': 'seed',
        'email': 'seed@x.com',
        'jwt': <String, dynamic>{'accessToken': 't'},
      };
      final Map<String, dynamic> user = await svc.logInSilently(payload);
      expect(user['email'], 'seed@x.com');
    });

    test('refreshSession renueva token/fechas y mantiene id/email', () async {
      // Prepara una sesión
      final Map<String, dynamic> base = await svc.signInUserAndPassword(
        email: 'b@x.com',
        password: 'p',
      );
      final Map<String, dynamic> beforeJwt =
          Map<String, dynamic>.from(Utils.mapFromDynamic(base['jwt']));
      final DateTime beforeExpires =
          DateTime.parse(beforeJwt['expiresAt'] as String);

      // Refresca
      final Map<String, dynamic> refreshed = await svc.refreshSession(base);
      final Map<String, dynamic> afterJwt =
          Map<String, dynamic>.from(Utils.mapFromDynamic(refreshed['jwt']));

      expect(afterJwt['accessToken'], startsWith('refreshed-token-'));
      expect(afterJwt['refreshedAt'], isA<String>());
      expect(
        DateTime.parse(afterJwt['expiresAt'] as String).isAfter(beforeExpires),
        isTrue,
      );
      expect(refreshed['email'], base['email']);
      expect(refreshed['id'], base['id']);
    });

    test('recoverPassword devuelve ack con ok=true y el email', () async {
      final Map<String, dynamic> ack =
          await svc.recoverPassword(email: 'z@x.com');
      expect(ack['ok'], isTrue);
      expect(ack['email'], 'z@x.com');
      expect(ack['message'], contains('Recovery'));
    });

    test(
        'logOutUser limpia sesión, emite null y getCurrentUser vuelve a fallar',
        () async {
      final List<Map<String, dynamic>?> subVals = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          svc.authStateChanges().listen(subVals.add);

      final Map<String, dynamic> u =
          await svc.signInUserAndPassword(email: 'out@x.com', password: 'p');
      expect((await svc.isSignedIn())['isSignedIn'], isTrue);

      final Map<String, dynamic> resp = await svc.logOutUser(u);
      expect(resp['ok'], isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(subVals.last, isNull);
      expect((await svc.isSignedIn())['isSignedIn'], isFalse);

      expectLater(svc.getCurrentUser(), throwsA(isA<StateError>()));

      await sub.cancel();
    });

    test('múltiples listeners reciben los mismos eventos', () async {
      final List<Map<String, dynamic>?> a = <Map<String, dynamic>?>[];
      final List<Map<String, dynamic>?> b = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sa =
          svc.authStateChanges().listen(a.add);
      final StreamSubscription<Map<String, dynamic>?> sb =
          svc.authStateChanges().listen(b.add);

      await svc.signInUserAndPassword(email: 'm@x.com', password: 'p');
      await svc.logOutUser(<String, dynamic>{});

      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(
        a.map((Map<String, dynamic>? e) => e?['email']).toList(),
        b.map((Map<String, dynamic>? e) => e?['email']).toList(),
      );

      await sa.cancel();
      await sb.cancel();
    });

    test('métodos lanzan tras dispose()', () async {
      svc.dispose();
      expect(() => svc.authStateChanges(), throwsA(isA<StateError>()));
      expectLater(svc.isSignedIn(), throwsA(isA<StateError>()));
      expectLater(
        svc.signInUserAndPassword(email: 'a@x.com', password: '1'),
        throwsA(isA<StateError>()),
      );
    });
  });
  group('FakeServiceSession with initial session', () {
    test('arranca logueado cuando se pasa initialUserJson', () async {
      final Map<String, dynamic> initial = <String, dynamic>{
        'id': 'seed',
        'displayName': 'Seed',
        'photoUrl': 'https://fake.com/photo.png',
        'email': 'seed@x.com',
        'jwt': <String, dynamic>{
          'accessToken': 'seed-token',
          'issuedAt': DateTime.now().toIso8601String(),
          'expiresAt':
              DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        },
      };

      final FakeServiceSession svc = FakeServiceSession(
        latency: const Duration(milliseconds: 1),
        initialUserJson: initial,
      );

      // El stream debe emitir initialUserJson de entrada
      final Map<String, dynamic>? first = await svc.authStateChanges().first;
      expect(first, isNotNull);
      expect(first?['email'], 'seed@x.com');

      // isSignedIn() debe ser true
      final Map<String, dynamic> signed = await svc.isSignedIn();
      expect(signed['isSignedIn'], isTrue);

      // getCurrentUser() debe devolver el mismo usuario
      final Map<String, dynamic> current = await svc.getCurrentUser();
      final Map<String, dynamic> currentJwt =
          Utils.mapFromDynamic(current['jwt']);
      expect(current['id'], 'seed');
      expect(
        Utils.getStringFromDynamic(currentJwt['accessToken']),
        'seed-token',
      );

      svc.dispose();
    });

    test(
        'arranca logueado → refreshSession actualiza token y mantiene identidad',
        () async {
      final Map<String, dynamic> initial = <String, dynamic>{
        'id': 'b@x.com',
        'displayName': 'b',
        'photoUrl': 'https://fake.com/photo.png',
        'email': 'b@x.com',
        'jwt': <String, dynamic>{
          'accessToken': 'seed-token',
          'issuedAt': DateTime.now().toIso8601String(),
          'expiresAt':
              DateTime.now().add(const Duration(minutes: 1)).toIso8601String(),
        },
      };

      final FakeServiceSession svc = FakeServiceSession(
        latency: const Duration(milliseconds: 1),
        initialUserJson: initial,
      );

      final Map<String, dynamic> before = await svc.getCurrentUser();
      final Map<String, dynamic> beforeJwt =
          Utils.mapFromDynamic(before['jwt']);
      final Map<String, dynamic> refreshed = await svc.refreshSession(before);
      final Map<String, dynamic> refreshedJwt =
          Utils.mapFromDynamic(refreshed['jwt']);
      expect(refreshed['email'], 'b@x.com');
      expect(refreshed['id'], 'b@x.com');
      expect(refreshedJwt['accessToken'], startsWith('refreshed-token-'));
      expect(
        DateUtils.dateTimeFromDynamic(refreshedJwt['expiresAt'])
            .isAfter(DateUtils.dateTimeFromDynamic(beforeJwt['expiresAt'])),
        isTrue,
      );

      svc.dispose();
    });

    test('arranca logueado → logOutUser emite null y deja sin sesión',
        () async {
      final Map<String, dynamic> initial = <String, dynamic>{
        'id': 'out@x.com',
        'displayName': 'out',
        'photoUrl': 'https://fake.com/photo.png',
        'email': 'out@x.com',
        'jwt': <String, dynamic>{
          'accessToken': 'seed-token',
          'issuedAt': DateTime.now().toIso8601String(),
          'expiresAt':
              DateTime.now().add(const Duration(minutes: 1)).toIso8601String(),
        },
      };

      final FakeServiceSession svc = FakeServiceSession(
        latency: const Duration(milliseconds: 1),
        initialUserJson: initial,
      );

      final List<Map<String, dynamic>?> events = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          svc.authStateChanges().listen(events.add);

      final Map<String, dynamic> ack = await svc.logOutUser(initial);
      expect(ack['ok'], isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(events.last, isNull);
      expect((await svc.isSignedIn())['isSignedIn'], isFalse);

      svc.dispose();
      await sub.cancel();
    });
  });

  group('FakeServiceSession | password flows', () {
    test(
        'Given valid email/password When signInUserAndPassword Then emits user & returns payload',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      final Completer<Map<String, dynamic>?> emission =
          Completer<Map<String, dynamic>?>();
      final StreamSubscription<Map<String, dynamic>?> sub =
          svc.authStateChanges().listen((Map<String, dynamic>? e) {
        if (!emission.isCompleted) {
          emission.complete(e);
        }
      });

      await svc.signInUserAndPassword(email: 'a@b.com', password: 'x');

      final Map<String, dynamic>? firstNonNull = await svc
          .authStateChanges()
          .firstWhere((Map<String, dynamic>? e) => e != null);

      expect(firstNonNull, isNotNull);
      expect(firstNonNull!['email'], 'a@b.com');

      await sub.cancel();
      svc.dispose();
    });

    test('Given empty email When signIn Then throws ArgumentError', () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));

      expect(
        () => svc.signInUserAndPassword(email: '', password: 'x'),
        throwsA(isA<ArgumentError>()),
      );

      svc.dispose();
    });

    test(
        'Given throwOnSignIn true When logInUserAndPassword Then throws StateError',
        () async {
      final FakeServiceSession svc = FakeServiceSession(
        latency: const Duration(milliseconds: 1),
        throwOnSignIn: true,
      );

      expect(
        () => svc.logInUserAndPassword(email: 'a@b.com', password: 'x'),
        throwsA(isA<StateError>()),
      );

      svc.dispose();
    });
  });

  group('FakeServiceSession | google & silent', () {
    test('Given normal flow When logInWithGoogle Then returns and emits user',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      final List<Map<String, dynamic>?> emissions = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub =
          svc.authStateChanges().listen(emissions.add);

      final Map<String, dynamic> user = await svc.logInWithGoogle();
      expect(user['email'], 'fake@fake.com');

      // Espera a que el stream procese el payload (salta el null inicial).
      final Map<String, dynamic>? firstNonNull = await svc
          .authStateChanges()
          .firstWhere((Map<String, dynamic>? e) => e != null);

      expect(firstNonNull, isNotNull);
      expect(firstNonNull!['email'], 'fake@fake.com');

      await sub.cancel();
      svc.dispose();
    });

    test('Given non-empty session When logInSilently Then emits session',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      final Map<String, dynamic> session = <String, dynamic>{
        'id': 'id-1',
        'email': 'a@b.com',
        'jwt': <String, dynamic>{'accessToken': 'old', 'expiresAt': 'tbd'},
      };

      final Map<String, dynamic> result = await svc.logInSilently(session);
      expect(result['id'], 'id-1');

      svc.dispose();
    });

    test('Given empty session When logInSilently Then throws StateError',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      expect(
        () => svc.logInSilently(<String, dynamic>{}),
        throwsA(isA<StateError>()),
      );
      svc.dispose();
    });
  });

  group('FakeServiceSession | refresh & recovery', () {
    test('Given valid jwt When refreshSession Then rewrites jwt fields',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      final Map<String, dynamic> session = <String, dynamic>{
        'id': 'abc',
        'email': 'a@b.com',
        'jwt': <String, dynamic>{'accessToken': 'old', 'expiresAt': 'tbd'},
      };

      final Map<String, dynamic> refreshed = await svc.refreshSession(session);
      final Map<String, dynamic> jwt = refreshed['jwt'] as Map<String, dynamic>;
      expect(jwt['accessToken'], startsWith('refreshed-token-'));
      expect(jwt.containsKey('expiresAt'), isTrue);
      expect(jwt.containsKey('refreshedAt'), isTrue);

      svc.dispose();
    });

    test('Given empty session When refreshSession Then throws StateError',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      expect(
        () => svc.refreshSession(<String, dynamic>{}),
        throwsA(isA<StateError>()),
      );
      svc.dispose();
    });

    test('Given email When recoverPassword Then returns ack with email',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      final Map<String, dynamic> r =
          await svc.recoverPassword(email: 'a@b.com');
      expect(r['ok'], isTrue);
      expect(r['email'], 'a@b.com');
      svc.dispose();
    });

    test('Given empty email When recoverPassword Then throws ArgumentError',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      expect(
        () => svc.recoverPassword(email: ''),
        throwsA(isA<ArgumentError>()),
      );
      svc.dispose();
    });
  });

  group('FakeServiceSession | current, signedIn, logout', () {
    test('Given signed in When getCurrentUser Then returns user', () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      await svc.logInUserAndPassword(email: 'a@b.com', password: 'x');
      final Map<String, dynamic> u = await svc.getCurrentUser();
      expect(u['email'], 'a@b.com');
      svc.dispose();
    });

    test('Given no session When getCurrentUser Then throws StateError',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      expect(() => svc.getCurrentUser(), throwsA(isA<StateError>()));
      svc.dispose();
    });

    test('Given session When logOutUser Then emits null and returns ack',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      await svc.logInWithGoogle();

      final Completer<Map<String, dynamic>?> emission =
          Completer<Map<String, dynamic>?>();
      final StreamSubscription<Map<String, dynamic>?> sub =
          svc.authStateChanges().listen((Map<String, dynamic>? e) {
        if (!emission.isCompleted && e == null) {
          emission.complete(e);
        }
      });

      final Map<String, dynamic> r = await svc.logOutUser(<String, dynamic>{});
      expect(r['ok'], isTrue);

      await emission.future; // Wait for null emission
      await sub.cancel();
      svc.dispose();
    });

    test('Given states When isSignedIn Then reflects boolean correctly',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      expect((await svc.isSignedIn())['isSignedIn'], isFalse);

      await svc.logInWithGoogle();
      expect((await svc.isSignedIn())['isSignedIn'], isTrue);
      svc.dispose();
    });
  });

  group('FakeServiceSession | lifecycle & initial state', () {
    test('Given initialUserJson When created Then first emission is that user',
        () async {
      final Map<String, dynamic> initial = <String, dynamic>{
        'id': 'init',
        'email': 'init@x.com',
        'jwt': <String, dynamic>{'accessToken': 'init'},
      };
      final FakeServiceSession svc = FakeServiceSession(
        latency: const Duration(milliseconds: 1),
        initialUserJson: initial,
      );

      final Map<String, dynamic>? first = await svc.authStateChanges().first;
      expect(first, isNotNull);
      expect(first!['email'], 'init@x.com');

      svc.dispose();
    });

    test(
        'Given disposed service When calling any method Then throws StateError',
        () async {
      final FakeServiceSession svc =
          FakeServiceSession(latency: const Duration(milliseconds: 1));
      svc.dispose();

      expect(() => svc.authStateChanges(), throwsA(isA<StateError>()));
      expect(() => svc.isSignedIn(), throwsA(isA<StateError>()));
      expect(() => svc.logInWithGoogle(), throwsA(isA<StateError>()));
    });
  });
}
