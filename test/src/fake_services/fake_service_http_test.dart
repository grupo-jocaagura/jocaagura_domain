import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FakeServiceHttp basic behaviors', () {
    late FakeServiceHttp http;

    setUp(() {
      http = FakeServiceHttp();
    });
    tearDown(() {
      http.dispose();
    });

    test('GET returns empty map por defecto', () async {
      final Map<String, dynamic> res = await http.get(url: '/test');
      expect(res, isEmpty);
    });

    test('POST devuelve body cuando no hay respuesta simulada', () async {
      final Map<String, int> body = <String, int>{'a': 1};
      final Map<String, dynamic> res =
          await http.post(url: '/post', body: body);
      expect(res, equals(body));
    });

    test('PUT devuelve body cuando no hay respuesta simulada', () async {
      final Map<String, int> body = <String, int>{'b': 2};
      final Map<String, dynamic> res = await http.put(url: '/put', body: body);
      expect(res, equals(body));
    });

    test('DELETE no devuelve nada y no falla', () async {
      await http.delete(url: '/del');
    });

    group('simulateResponse with method constants', () {
      late FakeServiceHttp http;

      setUp(() {
        http = FakeServiceHttp();
      });
      tearDown(() {
        http.dispose();
      });

      test('simulateResponse usando methodGet', () async {
        http.simulateResponse(
          FakeServiceHttp.methodGet,
          '/foo',
          <String, dynamic>{'foo': 'bar'},
        );
        final Map<String, dynamic> res = await http.get(url: '/foo');
        expect(res, equals(<String, dynamic>{'foo': 'bar'}));
      });

      test('simulateResponse usando methodPost', () async {
        http.simulateResponse(
          FakeServiceHttp.methodPost,
          '/foo',
          <String, dynamic>{'created': 1},
        );
        final Map<String, dynamic> res = await http.post(
          url: '/foo',
        );
        expect(res, equals(<String, dynamic>{'created': 1}));
      });

      test('simulateResponse usando methodPut', () async {
        http.simulateResponse(
          FakeServiceHttp.methodPut,
          '/foo',
          <String, dynamic>{'updated': true},
        );
        final Map<String, dynamic> res =
            await http.put(url: '/foo', body: <String, dynamic>{});
        expect(res, equals(<String, dynamic>{'updated': true}));
      });

      test('simulateResponse no afecta otros métodos', () async {
        http.simulateResponse(
          FakeServiceHttp.methodGet,
          '/onlyGet',
          <String, dynamic>{'a': 1},
        );
        expect(
          await http.get(url: '/onlyGet'),
          equals(<String, dynamic>{'a': 1}),
        );
        expect(
          await http.post(
            url: '/onlyGet',
          ),
          isEmpty,
        );
        expect(
          await http.put(
            url: '/onlyGet',
          ),
          isEmpty,
        );
        // DELETE sigue sin lanzar
        await http.delete(url: '/onlyGet');
      });
    });
  });

  group('Error simulation per method', () {
    test('GET lanza StateError cuando throwOnGet=true', () {
      final FakeServiceHttp h = FakeServiceHttp(throwOnGet: true);
      expect(() => h.get(url: '/'), throwsA(isA<StateError>()));
      h.dispose();
    });
    test('POST lanza StateError cuando throwOnPost=true', () {
      final FakeServiceHttp h = FakeServiceHttp(throwOnPost: true);
      expect(() => h.post(url: '/'), throwsA(isA<StateError>()));
      h.dispose();
    });
    test('PUT lanza StateError cuando throwOnPut=true', () {
      final FakeServiceHttp h = FakeServiceHttp(throwOnPut: true);
      expect(() => h.put(url: '/'), throwsA(isA<StateError>()));
      h.dispose();
    });
    test('DELETE lanza StateError cuando throwOnDelete=true', () {
      final FakeServiceHttp h = FakeServiceHttp(throwOnDelete: true);
      expect(() => h.delete(url: '/'), throwsA(isA<StateError>()));
      h.dispose();
    });
  });

  group('Validation and disposal', () {
    test('empty url lanza ArgumentError en todos los métodos', () {
      final FakeServiceHttp http = FakeServiceHttp();
      expect(() => http.get(url: ''), throwsA(isA<ArgumentError>()));
      expect(() => http.post(url: ''), throwsA(isA<ArgumentError>()));
      expect(() => http.put(url: ''), throwsA(isA<ArgumentError>()));
      expect(() => http.delete(url: ''), throwsA(isA<ArgumentError>()));
    });

    test('métodos throw tras dispose', () {
      final FakeServiceHttp h = FakeServiceHttp();
      h.dispose();
      expect(() => h.get(url: '/'), throwsA(isA<StateError>()));
      expect(() => h.post(url: '/'), throwsA(isA<StateError>()));
      expect(() => h.put(url: '/'), throwsA(isA<StateError>()));
      expect(() => h.delete(url: '/'), throwsA(isA<StateError>()));
    });
  });

  group('Latency simulation', () {
    test('GET respeta latencia', () async {
      final FakeServiceHttp h =
          FakeServiceHttp(latency: const Duration(milliseconds: 30));
      final Stopwatch sw = Stopwatch()..start();
      await h.get(url: '/');
      sw.stop();
      expect(sw.elapsedMilliseconds >= 30, isTrue);
      h.dispose();
    });
  });
  group('simulateResponse with method constants', () {
    late FakeServiceHttp http;

    setUp(() {
      http = FakeServiceHttp();
    });
    tearDown(() {
      http.dispose();
    });

    test('simulateResponse using methodGet constant', () async {
      http.simulateResponse(
        FakeServiceHttp.methodGet,
        '/foo',
        <String, dynamic>{'foo': 'bar'},
      );
      final Map<String, dynamic> res = await http.get(url: '/foo');
      expect(res, equals(<String, String>{'foo': 'bar'}));
    });

    test('simulateResponse using methodPost constant', () async {
      http.simulateResponse(
        FakeServiceHttp.methodPost,
        '/foo',
        <String, dynamic>{'created': 1},
      );
      final Map<String, dynamic> res = await http.post(url: '/foo');
      expect(res, equals(<String, int>{'created': 1}));
    });

    test('simulateResponse using methodPut constant', () async {
      http.simulateResponse(
        FakeServiceHttp.methodPut,
        '/foo',
        <String, dynamic>{'updated': true},
      );
      final Map<String, dynamic> res =
          await http.put(url: '/foo', body: <dynamic, dynamic>{});
      expect(res, equals(<String, bool>{'updated': true}));
    });

    test('simulateResponse does not affect other methods', () async {
      // Sólo definimos GET, así POST/PUT/DELETE siguen devolviendo por defecto
      http.simulateResponse(
        FakeServiceHttp.methodGet,
        '/onlyGet',
        <String, dynamic>{'a': 1},
      );
      expect(await http.get(url: '/onlyGet'), equals(<String, int>{'a': 1}));
      expect(await http.post(url: '/onlyGet'), isEmpty);
      expect(await http.put(url: '/onlyGet'), isEmpty);
      await http.delete(url: '/onlyGet');
    });
  });

  group('delete resets simulated responses', () {
    late FakeServiceHttp http;

    setUp(() {
      http = FakeServiceHttp();
      // Simulamos respuestas GET/POST/PUT para /resource
      http.simulateResponse(
        FakeServiceHttp.methodGet,
        '/resource',
        <String, dynamic>{'g': 1},
      );
      http.simulateResponse(
        FakeServiceHttp.methodPost,
        '/resource',
        <String, dynamic>{'p': 2},
      );
      http.simulateResponse(
        FakeServiceHttp.methodPut,
        '/resource',
        <String, dynamic>{'u': 3},
      );
    });

    tearDown(() {
      http.dispose();
    });

    test('antes de delete devuelve valores simulados', () async {
      expect(await http.get(url: '/resource'), equals(<String, int>{'g': 1}));
      expect(await http.post(url: '/resource'), equals(<String, int>{'p': 2}));
      expect(
        await http.put(url: '/resource', body: <dynamic, dynamic>{}),
        equals(<String, int>{'u': 3}),
      );
    });

    test('delete limpia todas las simulaciones para la URL', () async {
      await http.delete(url: '/resource');
      // Tras delete, ya no hay simulaciones, vuelve a valor por defecto
      expect(await http.get(url: '/resource'), isEmpty);
      expect(await http.post(url: '/resource'), isEmpty);
      expect(
        await http.put(url: '/resource', body: <dynamic, dynamic>{}),
        isEmpty,
      );
    });

    test('delete no falla si no hay simulaciones previas', () async {
      // URL distinta no tiene simulaciones
      await http.delete(url: '/other');
      expect(await http.get(url: '/other'), isEmpty);
    });
  });
}
