import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FakeServiceGyroscope', () {
    late FakeServiceGyroscope gyro;

    setUp(() {
      gyro = FakeServiceGyroscope();
    });
    tearDown(() {
      gyro.dispose();
    });

    test('getCurrentRotation returns initialValue', () async {
      final Map<String, double> pos = await gyro.getCurrentRotation();
      expect(pos, FakeServiceGyroscope.initialValue);
    });

    test('rotationStream emits initialValue', () async {
      final List<Map<String, double>> events = <Map<String, double>>[];
      final StreamSubscription<Map<String, double>> sub =
          gyro.rotationStream().listen(events.add);
      await Future<void>.delayed(Duration.zero);
      expect(events.first, FakeServiceGyroscope.initialValue);
      await sub.cancel();
    });

    test('simulateRotation pushes new values', () async {
      final List<Map<String, double>> events = <Map<String, double>>[];
      final StreamSubscription<Map<String, double>> sub =
          gyro.rotationStream().listen(events.add);
      gyro.simulateRotation(x: 1.1, y: -2.2, z: 3.3);
      await Future<void>.delayed(Duration.zero);
      expect(
        events.last,
        <String, double>{'x': 1.1, 'y': -2.2, 'z': 3.3},
      );
      await sub.cancel();
    });

    test('getCurrentRotation latency simulation', () async {
      final FakeServiceGyroscope geo2 =
          FakeServiceGyroscope(latency: const Duration(milliseconds: 50));
      final Stopwatch sw = Stopwatch()..start();
      await geo2.getCurrentRotation();
      sw.stop();
      expect(sw.elapsedMilliseconds >= 50, isTrue);
      geo2.dispose();
    });

    test('getCurrentRotation throws when throwOnGet is true', () {
      final FakeServiceGyroscope g = FakeServiceGyroscope(throwOnGet: true);
      expect(
        () => g.getCurrentRotation(),
        throwsA(isA<StateError>()),
      );
      g.dispose();
    });

    test('multiple listeners receive same events', () async {
      final List<Map<String, double>> events1 = <Map<String, double>>[];
      final List<Map<String, double>> events2 = <Map<String, double>>[];
      final StreamSubscription<Map<String, double>> sub1 =
          gyro.rotationStream().listen(events1.add);
      final StreamSubscription<Map<String, double>> sub2 =
          gyro.rotationStream().listen(events2.add);
      gyro.simulateRotation(x: 7.7, y: 8.8, z: 9.9);
      await Future<void>.delayed(Duration.zero);
      expect(events1, equals(events2));
      await sub1.cancel();
      await sub2.cancel();
    });

    test('methods throw after dispose', () {
      gyro.dispose();
      expect(() => gyro.getCurrentRotation(), throwsA(isA<StateError>()));
      expect(() => gyro.rotationStream(), throwsA(isA<StateError>()));
      expect(
        () => gyro.simulateRotation(x: 0, y: 0, z: 0),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Continuous simulateRotation emissions', () {
    test('Multiple simulateRotation calls emit in correct order', () async {
      final FakeServiceGyroscope gyro = FakeServiceGyroscope();
      final List<Map<String, double>> events = <Map<String, double>>[];
      final StreamSubscription<Map<String, double>> sub =
          gyro.rotationStream().listen(events.add);

      final List<Map<String, double>> rotations = <Map<String, double>>[
        <String, double>{'x': 1.0, 'y': 2.0, 'z': 3.0},
        <String, double>{'x': -1.0, 'y': -2.0, 'z': -3.0},
        <String, double>{'x': 0.5, 'y': 0.6, 'z': 0.7},
      ];

      for (final Map<String, double> rot in rotations) {
        gyro.simulateRotation(
          x: rot['x']!,
          y: rot['y']!,
          z: rot['z']!,
        );
        await Future<void>.delayed(Duration.zero);
      }

      expect(events.first, FakeServiceGyroscope.initialValue);
      expect(events.sublist(1), equals(rotations));

      await sub.cancel();
    });
  });
  group('reset()', () {
    late FakeServiceGyroscope gyro;

    setUp(() {
      gyro = FakeServiceGyroscope();
    });

    tearDown(() {
      gyro.dispose();
    });

    test('resets to initial value after simulateRotation', () async {
      final List<Map<String, double>> events = <Map<String, double>>[];
      final StreamSubscription<Map<String, double>> sub =
          gyro.rotationStream().listen(events.add);

      gyro.simulateRotation(x: 4.2, y: -3.3, z: 2.1);
      await Future<void>.delayed(Duration.zero);

      gyro.reset();
      await Future<void>.delayed(Duration.zero);

      expect(
        events.last,
        FakeServiceGyroscope.initialValue,
      );

      await sub.cancel();
    });

    test('reset works multiple times', () async {
      final List<Map<String, double>> events = <Map<String, double>>[];
      final StreamSubscription<Map<String, double>> sub =
          gyro.rotationStream().listen(events.add);

      gyro.simulateRotation(x: 1.0, y: 2.0, z: 3.0);
      await Future<void>.delayed(Duration.zero);

      gyro.reset();
      await Future<void>.delayed(Duration.zero);

      gyro.simulateRotation(x: -1.0, y: -2.0, z: -3.0);
      await Future<void>.delayed(Duration.zero);

      gyro.reset();
      await Future<void>.delayed(Duration.zero);

      expect(
        events
            .where(
              (Map<String, double> e) => e == FakeServiceGyroscope.initialValue,
            )
            .length,
        3,
      );

      await sub.cancel();
    });

    test('reset throws after dispose', () {
      gyro.dispose();
      expect(() => gyro.reset(), throwsStateError);
    });
  });
}
