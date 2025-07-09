import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FakeServiceConnectivity', () {
    late FakeServiceConnectivity conn;

    setUp(() {
      conn = FakeServiceConnectivity();
    });
    tearDown(() {
      conn.dispose();
    });

    test('isConnected retorna valor inicial true', () async {
      expect(await conn.isConnected(), isTrue);
    });

    test('connectivityStream emite valor inicial', () async {
      final List<bool> events = <bool>[];
      final StreamSubscription<bool> sub =
          conn.connectivityStream().listen(events.add);
      await Future<void>.delayed(Duration.zero);
      expect(events.first, FakeServiceConnectivity.initialValue);
      await sub.cancel();
    });

    test('simulateConnectivity cambia estado y emite', () async {
      final List<bool> events = <bool>[];
      final StreamSubscription<bool> sub =
          conn.connectivityStream().listen(events.add);
      conn.simulateConnectivity(false);
      await Future<void>.delayed(Duration.zero);
      expect(events.last, isFalse);
      conn.simulateConnectivity(true);
      await Future<void>.delayed(Duration.zero);
      expect(events.last, isTrue);
      await sub.cancel();
    });

    test('isConnected respeta latencia', () async {
      final FakeServiceConnectivity fake =
          FakeServiceConnectivity(latency: const Duration(milliseconds: 50));
      final Stopwatch sw = Stopwatch()..start();
      await fake.isConnected();
      sw.stop();
      expect(sw.elapsedMilliseconds >= 50, isTrue);
      fake.dispose();
    });

    test('isConnected lanza StateError en throwOnGet=true', () async {
      final FakeServiceConnectivity fake =
          FakeServiceConnectivity(throwOnGet: true);
      expect(() => fake.isConnected(), throwsA(isA<StateError>()));
      fake.dispose();
    });

    test('métodos throw tras dispose', () {
      conn.dispose();
      expect(() => conn.isConnected(), throwsA(isA<StateError>()));
      expect(() => conn.connectivityStream(), throwsA(isA<StateError>()));
      expect(() => conn.simulateConnectivity(true), throwsA(isA<StateError>()));
    });
  });

  group('Continuous simulateConnectivity emissions', () {
    test('Múltiples simulateConnectivity emiten en orden correcto', () async {
      final FakeServiceConnectivity conn = FakeServiceConnectivity();
      final List<bool> events = <bool>[];
      final StreamSubscription<bool> sub =
          conn.connectivityStream().listen(events.add);
      final List<bool> seq = <bool>[false, true, false];
      for (final bool s in seq) {
        conn.simulateConnectivity(s);
        await Future<void>.delayed(Duration.zero);
      }
      // El primer valor es el inicial: true
      expect(events.first, FakeServiceConnectivity.initialValue);
      expect(events.sublist(1), equals(seq));
      await sub.cancel();
    });
    test('reset vuelve a estado inicial', () async {
      final FakeServiceConnectivity svc = FakeServiceConnectivity();
      svc.simulateConnectivity(false);
      await Future<void>.delayed(Duration.zero);
      svc.reset();
      expect(await svc.isConnected(), isTrue);
      svc.dispose();
    });
  });
}
