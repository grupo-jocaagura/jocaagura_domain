import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaagura_domain/src/fake_services/fake_service_session.dart';

void main() {
  group('FakeServiceSession', () {
    late FakeServiceSession session;

    setUp(() {
      session = FakeServiceSession();
    });

    tearDown(() {
      session.dispose();
    });

    test('signIn sets state to signed in', () async {
      final List<bool> events = <bool>[];
      final StreamSubscription<bool> sub =
          session.authStateStream().listen(events.add);
      await session.signIn(username: 'user', password: 'pass');
      expect(await session.isSignedIn(), isTrue);
      expect(events.last, isTrue);
      await sub.cancel();
    });

    test('signOut sets state to signed out', () async {
      await session.signIn(username: 'user', password: 'pass');
      final List<bool> events = <bool>[];
      final StreamSubscription<bool> sub =
          session.authStateStream().listen(events.add);
      await session.signOut();
      expect(await session.isSignedIn(), isFalse);
      expect(events.last, isFalse);
      await sub.cancel();
    });

    test('signIn throws on empty username', () {
      expect(
        () => session.signIn(username: '', password: 'pass'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('signIn throws on empty password', () {
      expect(
        () => session.signIn(username: 'user', password: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws simulated error when throwOnSignIn is true', () {
      session.dispose();
      session = FakeServiceSession(throwOnSignIn: true);
      expect(
        () => session.signIn(username: 'user', password: 'pass'),
        throwsA(isA<StateError>()),
      );
      session.dispose();
    });

    test('methods throw after dispose', () async {
      session.dispose();
      expect(
        () => session.signIn(username: 'u', password: 'p'),
        throwsA(isA<StateError>()),
      );
      expect(
        () => session.signOut(),
        throwsA(isA<StateError>()),
      );
      expect(
        () => session.isSignedIn(),
        throwsA(isA<StateError>()),
      );
      expect(
        () => session.authStateStream(),
        throwsA(isA<StateError>()),
      );
    });

    group('currentUser y userStream', () {
      test('currentUser refleja el usuario tras signIn y null tras signOut',
          () async {
        expect(session.currentUser, isNull);
        await session.signIn(username: 'a', password: 'b');
        expect(session.currentUser, isNotNull);
        await session.signOut();
        expect(session.currentUser, isNull);
      });

      test(
          'userStream emite el usuario correcto tras signIn y null tras signOut',
          () async {
        final List<UserModel?> users = <UserModel?>[];
        final StreamSubscription<UserModel?> sub =
            session.userStream.listen(users.add);
        await session.signIn(username: 'a', password: 'b');
        await session.signOut();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        // Debe haber exactamente un valor no nulo (el usuario) y el último debe ser null
        expect(users.where((UserModel? u) => u != null).length, 1);
        expect(users.last, isNull);
        expect(users.first, isNull); // El primer valor debe ser null (inicial)
        await sub.cancel();
      });
    });

    group('signInWithGoogle', () {
      test('signInWithGoogle funciona y actualiza el usuario', () async {
        final UserModel? user = await session.signInWithGoogle();
        expect(user, isNotNull);
        expect(session.currentUser, isNotNull);
        expect(await session.isSignedIn(), isTrue);
      });
      test('signInWithGoogle lanza error si throwOnSignIn', () async {
        session.dispose();
        session = FakeServiceSession(throwOnSignIn: true);
        expect(() => session.signInWithGoogle(), throwsA(isA<StateError>()));
        session.dispose();
      });
    });

    test('signIn sobrescribe el usuario anterior', () async {
      await session.signIn(username: 'a', password: 'b');
      final UserModel? user1 = session.currentUser;
      await session.signIn(username: 'b', password: 'c');
      final UserModel? user2 = session.currentUser;
      expect(user1, isNot(equals(user2)));
      expect(user2?.id, 'b');
    });

    test('isSignedIn refleja el estado correctamente', () async {
      expect(await session.isSignedIn(), isFalse);
      await session.signIn(username: 'a', password: 'b');
      expect(await session.isSignedIn(), isTrue);
      await session.signOut();
      expect(await session.isSignedIn(), isFalse);
    });

    test('authStateStream solo emite valores distintos', () async {
      final List<bool> values = <bool>[];
      final StreamSubscription<bool> sub =
          session.authStateStream().listen(values.add);
      await session.signIn(username: 'a', password: 'b');
      await session.signIn(username: 'a', password: 'b');
      await session.signOut();
      await session.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      // Solo debe emitir: true (al firmar), false (al salir)
      expect(values.where((bool e) => e == true).length, 1);
      expect(values.where((bool e) => e == false).length, 2);
      await sub.cancel();
    });

    test('dispose cierra el stream y no emite más valores', () async {
      final List<bool> values = <bool>[];
      final StreamSubscription<bool> sub =
          session.authStateStream().listen(values.add);
      await session.signIn(username: 'a', password: 'b');
      session.dispose();
      // Intentar emitir tras dispose no debe cambiar el stream
      try {
        await session.signOut();
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(values, contains(true));
      await sub.cancel();
    });
  });
  // Añade este grupo al final de fake_service_session_test.dart

  group('Additional FakeServiceSession behaviors', () {
    late FakeServiceSession session;

    setUp(() {
      session = FakeServiceSession();
    });

    tearDown(() {
      session.dispose();
    });
    test('authStateStream emite false inicialmente', () async {
      final List<bool> events = <bool>[];
      final StreamSubscription<bool> sub =
          session.authStateStream().listen(events.add);
      // Esperamos al menos un tick para la emisión inicial
      await Future<void>.delayed(Duration.zero);
      expect(events.first, isFalse);
      await sub.cancel();
    });

    test('userStream emite null inicialmente', () async {
      final List<UserModel?> users = <UserModel?>[];
      final StreamSubscription<UserModel?> sub =
          session.userStream.listen(users.add);
      await Future<void>.delayed(Duration.zero);
      expect(users.first, isNull);
      await sub.cancel();
    });

    test('authStateStream emite true tras signInWithGoogle()', () async {
      final List<bool> events = <bool>[];
      final StreamSubscription<bool> sub =
          session.authStateStream().listen(events.add);
      await session.signInWithGoogle();
      // Espera un tick para que el stream emita el nuevo valor
      await Future<void>.delayed(Duration.zero);
      expect(events.last, isTrue);
      await sub.cancel();
    });

    test('latencia configurable en signIn()', () async {
      final FakeServiceSession fake =
          FakeServiceSession(latency: const Duration(milliseconds: 50));
      final Stopwatch sw = Stopwatch()..start();
      await fake.signIn(username: 'u', password: 'p');
      sw.stop();
      expect(sw.elapsedMilliseconds >= 50, isTrue);
      fake.dispose();
    });

    test('latencia configurable en signInWithGoogle()', () async {
      final FakeServiceSession fake =
          FakeServiceSession(latency: const Duration(milliseconds: 50));
      final Stopwatch sw = Stopwatch()..start();
      await fake.signInWithGoogle();
      sw.stop();
      expect(sw.elapsedMilliseconds >= 50, isTrue);
      fake.dispose();
    });

    test('signOut tras signInWithGoogle resetea estado y emite false',
        () async {
      final List<bool> events = <bool>[];
      final StreamSubscription<bool> sub =
          session.authStateStream().listen(events.add);
      await session.signInWithGoogle();
      expect(await session.isSignedIn(), isTrue);
      await session.signOut();
      expect(await session.isSignedIn(), isFalse);
      expect(events.last, isFalse);
      await sub.cancel();
    });

    test('múltiples listeners reciben los mismos eventos', () async {
      final List<bool> events1 = <bool>[], events2 = <bool>[];
      final StreamSubscription<bool> sub1 =
          session.authStateStream().listen(events1.add);
      final StreamSubscription<bool> sub2 =
          session.authStateStream().listen(events2.add);
      await session.signIn(username: 'a', password: 'b');
      await session.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(events1, equals(events2));
      await sub1.cancel();
      await sub2.cancel();
    });
  });
}
