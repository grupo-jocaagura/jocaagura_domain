import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FakeServicePreferences', () {
    late FakeServicePreferences prefs;

    setUp(() {
      prefs = FakeServicePreferences();
    });
    tearDown(() {
      prefs.dispose();
    });

    test('initial getAll retorna vacío', () async {
      expect(await prefs.getAll(), isEmpty);
    });

    test('allStream emite estado inicial', () async {
      final List<Map<String, dynamic>> events =
          <Map<String, dynamic>>[]; // antes era List<List<Map<...>>>
      final StreamSubscription<Map<String, dynamic>> sub =
          prefs.allStream().listen(events.add);
      await Future<void>.delayed(Duration.zero);
      expect(events.first, isEmpty);
      await sub.cancel();
    });

    test('setValue y getValue funcionan correctamente', () async {
      await prefs.setValue(key: 'a', value: 123);
      final int val =
          Utils.getIntegerFromDynamic(await prefs.getValue(key: 'a'));
      expect(val, equals(123));
    });
    test('getValue lanza StateError si la clave no existe', () async {
      final FakeServicePreferences p = FakeServicePreferences();
      expect(() => p.getValue(key: 'no_existe'), throwsA(isA<StateError>()));
      p.dispose();
    });

    test('remove elimina solo la clave especificada', () async {
      await prefs.setValue(key: 'a', value: 1);
      await prefs.setValue(key: 'b', value: 2);
      await prefs.remove(key: 'a');
      expect(await prefs.getAll(), equals(<String, int>{'b': 2}));
    });

    test('clear elimina todas las entradas', () async {
      await prefs.setValue(key: 'x', value: true);
      await prefs.clear();
      expect(await prefs.getAll(), isEmpty);
    });

    test('allStream emite estado inicial', () async {
      final List<Map<String, dynamic>> events =
          <Map<String, dynamic>>[]; // antes era List<List<Map<...>>>
      final StreamSubscription<Map<String, dynamic>> sub =
          prefs.allStream().listen(events.add);
      await Future<void>.delayed(Duration.zero);
      expect(events.first, isEmpty);
      await sub.cancel();
    });

    test('latencia configurable en getValue', () async {
      final FakeServicePreferences p =
          FakeServicePreferences(latency: const Duration(milliseconds: 30));
      await p.setValue(key: 'a', value: 1);
      final Stopwatch sw = Stopwatch()..start();
      await p.getValue(key: 'a');
      sw.stop();
      expect(sw.elapsedMilliseconds >= 30, isTrue);
      p.dispose();
    });

    group('throwOnGet error cases', () {
      test('getValue lanza StateError si throwOnGet=true', () async {
        final FakeServicePreferences p =
            FakeServicePreferences(throwOnGet: true);
        expect(() => p.getValue(key: 'x'), throwsA(isA<StateError>()));
        p.dispose();
      });
      test('getAll lanza StateError si throwOnGet=true', () async {
        final FakeServicePreferences p =
            FakeServicePreferences(throwOnGet: true);
        expect(() => p.getAll(), throwsA(isA<StateError>()));
        p.dispose();
      });
    });

    group('throwOnSet error cases', () {
      test('setValue lanza StateError si throwOnSet=true', () async {
        final FakeServicePreferences p =
            FakeServicePreferences(throwOnSet: true);
        expect(
          () => p.setValue(key: 'a', value: 1),
          throwsA(isA<StateError>()),
        );
        p.dispose();
      });
      test('remove lanza StateError si throwOnSet=true', () async {
        final FakeServicePreferences p =
            FakeServicePreferences(throwOnSet: true);
        expect(
          () => p.remove(key: 'a'),
          throwsA(isA<StateError>()),
        );
        p.dispose();
      });
      test('clear lanza StateError si throwOnSet=true', () async {
        final FakeServicePreferences p =
            FakeServicePreferences(throwOnSet: true);
        expect(() => p.clear(), throwsA(isA<StateError>()));
        p.dispose();
      });
    });

    test('métodos throw tras dispose', () {
      prefs.dispose();
      expect(
        () => prefs.setValue(key: 'k', value: 1),
        throwsA(isA<StateError>()),
      );
      expect(() => prefs.getValue(key: 'k'), throwsA(isA<StateError>()));
      expect(() => prefs.remove(key: 'k'), throwsA(isA<StateError>()));
      expect(() => prefs.clear(), throwsA(isA<StateError>()));
      expect(() => prefs.getAll(), throwsA(isA<StateError>()));
      expect(() => prefs.allStream(), throwsA(isA<StateError>()));
    });
  });

  group('Continuous setValue/remove/clear emissions', () {
    test('secuencia set/remove/clear emiten en orden correcto', () async {
      final FakeServicePreferences prefs = FakeServicePreferences();
      final List<Map<String, dynamic>> events =
          <Map<String, dynamic>>[]; // ahora captura Maps, no List<Maps>
      final StreamSubscription<Map<String, dynamic>> sub =
          prefs.allStream().listen(events.add);

      await prefs.setValue(key: 'a', value: 1);
      await Future<void>.delayed(Duration.zero);
      await prefs.setValue(key: 'b', value: 2);
      await Future<void>.delayed(Duration.zero);
      await prefs.remove(key: 'a'); // comilla agregada
      await Future<void>.delayed(Duration.zero);
      await prefs.clear();
      await Future<void>.delayed(Duration.zero);

      // events[0] es el estado inicial {}
      expect(events[1], equals(<String, int>{'a': 1}));
      expect(events[2], equals(<String, int>{'a': 1, 'b': 2}));
      expect(events[3], equals(<String, int>{'b': 2}));
      expect(events[4], equals(<dynamic, dynamic>{}));
      await sub.cancel();
    });
  });

  group('reset()', () {
    late FakeServicePreferences prefs;

    setUp(() {
      prefs = FakeServicePreferences();
    });

    tearDown(() {
      prefs.dispose();
    });

    test('reset limpia todas las preferencias', () async {
      await prefs.setValue(key: 'theme', value: 'dark');
      await prefs.setValue(key: 'volume', value: 80);
      prefs.reset();
      final Map<String, dynamic> all = await prefs.getAll();
      expect(all, isEmpty);
    });

    test('reset emite estado vacío en allStream', () async {
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          prefs.allStream().listen(events.add);
      await prefs.setValue(key: 'a', value: 1);
      await Future<void>.delayed(Duration.zero);
      prefs.reset();
      await Future<void>.delayed(Duration.zero);
      expect(events.last, isEmpty);
      await sub.cancel();
    });

    test('reset lanza error si ya fue dispose', () {
      prefs.dispose();
      expect(() => prefs.reset(), throwsStateError);
    });
  });
}
