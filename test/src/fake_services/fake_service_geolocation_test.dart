import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FakeServiceGeolocation', () {
    late FakeServiceGeolocation geo;

    setUp(() {
      geo = FakeServiceGeolocation();
    });
    tearDown(() {
      geo.dispose();
    });

    test('getCurrentLocation returns initial coords', () async {
      final Map<String, double> pos = await geo.getCurrentLocation();
      expect(pos, <String, double>{'latitude': 0.0, 'longitude': 0.0});
    });

    test('locationStream emits initial coords', () async {
      final List<Map<String, double>> events = <Map<String, double>>[];
      final StreamSubscription<Map<String, double>> sub =
          geo.locationStream().listen(events.add);
      await Future<void>.delayed(Duration.zero);
      expect(events.first, <String, double>{'latitude': 0.0, 'longitude': 0.0});
      await sub.cancel();
    });

    test('simulateLocation pushes new coords', () async {
      final List<Map<String, double>> events = <Map<String, double>>[];
      final StreamSubscription<Map<String, double>> sub =
          geo.locationStream().listen(events.add);
      geo.simulateLocation(latitude: 10.5, longitude: -20.5);
      await Future<void>.delayed(Duration.zero);
      expect(
        events.last,
        <String, double>{'latitude': 10.5, 'longitude': -20.5},
      );
      await sub.cancel();
    });

    test('getCurrentLocation latency simulation', () async {
      final FakeServiceGeolocation geo2 =
          FakeServiceGeolocation(latency: const Duration(milliseconds: 50));
      final Stopwatch sw = Stopwatch()..start();
      await geo2.getCurrentLocation();
      sw.stop();
      expect(sw.elapsedMilliseconds >= 50, isTrue);
      geo2.dispose();
    });

    test('getCurrentLocation throws when throwOnGet is true', () {
      final FakeServiceGeolocation geo2 =
          FakeServiceGeolocation(throwOnGet: true);
      expect(
        () => geo2.getCurrentLocation(),
        throwsA(isA<StateError>()),
      );
      geo2.dispose();
    });

    test('multiple listeners receive same events', () async {
      final List<Map<String, double>> events1 = <Map<String, double>>[];
      final List<Map<String, double>> events2 = <Map<String, double>>[];
      final StreamSubscription<Map<String, double>> sub1 =
          geo.locationStream().listen(events1.add);
      final StreamSubscription<Map<String, double>> sub2 =
          geo.locationStream().listen(events2.add);
      geo.simulateLocation(latitude: 1.1, longitude: 2.2);
      await Future<void>.delayed(Duration.zero);
      expect(events1, equals(events2));
      await sub1.cancel();
      await sub2.cancel();
    });

    test('methods throw after dispose', () {
      geo.dispose();
      expect(() => geo.getCurrentLocation(), throwsA(isA<StateError>()));
      expect(() => geo.locationStream(), throwsA(isA<StateError>()));
      expect(
        () => geo.simulateLocation(latitude: 0, longitude: 0),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Recommended test group', () {
    test('Retorna ubicación inicial por defecto', () async {
      final FakeServiceGeolocation geo = FakeServiceGeolocation();
      final Map<String, double> result = await geo.getCurrentLocation();
      expect(result, FakeServiceGeolocation.initialValue);
    });
  });
  test('Emite nueva ubicación al simular', () async {
    final FakeServiceGeolocation geo = FakeServiceGeolocation();
    final Map<String, double> expected = <String, double>{
      'latitude': 1.23,
      'longitude': 4.56,
    };

    final List<Map<String, double>> events = <Map<String, double>>[];
    final StreamSubscription<Map<String, double>> sub =
        geo.locationStream().listen(events.add);

    geo.simulateLocation(latitude: 1.23, longitude: 4.56);
    await Future<void>.delayed(Duration.zero);

    expect(events.last, expected);
    await sub.cancel();
  });
  test('Lanza error si throwOnGet es true', () async {
    final FakeServiceGeolocation geo = FakeServiceGeolocation(throwOnGet: true);
    expect(() => geo.getCurrentLocation(), throwsStateError);
  });
}
