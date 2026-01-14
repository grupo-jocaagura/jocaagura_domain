import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('JocaaguraFakeHttpRequest', () {
    test('Given disposed instance When calling get Then throws StateError',
        () async {
      final JocaaguraFakeHttpRequest http = JocaaguraFakeHttpRequest(
        services: <VirtualCrudService>[],
      );

      http.dispose();

      expect(
        () => http.get(url: 'https://example.com/ping'),
        throwsA(isA<StateError>()),
      );
    });

    test('Given config.throwOnGet When calling get Then throws StateError',
        () async {
      final JocaaguraFakeHttpRequest http = JocaaguraFakeHttpRequest(
        services: <VirtualCrudService>[],
        config: const FakeHttpRequestConfig(throwOnGet: true),
      );

      expect(
        () => http.get(url: 'https://example.com/ping'),
        throwsA(isA<StateError>()),
      );
    });

    test(
        'Given per-route error When calling matching route Then throws StateError with message',
        () async {
      const String key = 'GET https://example.com/ping';
      final JocaaguraFakeHttpRequest http = JocaaguraFakeHttpRequest(
        services: <VirtualCrudService>[],
        config: const FakeHttpRequestConfig(
          errorRoutes: <String, String>{key: 'Boom route'},
        ),
      );

      expect(
        () => http.get(url: 'https://example.com/ping'),
        throwsA(
          predicate((Object e) => e is StateError && e.message == 'Boom route'),
        ),
      );
    });

    test('Given cannedResponses When calling route Then returns canned payload',
        () async {
      const String key = 'GET https://example.com/ping';
      final JocaaguraFakeHttpRequest http = JocaaguraFakeHttpRequest(
        services: <VirtualCrudService>[],
        config: const FakeHttpRequestConfig(
          cannedResponses: <String, Map<String, dynamic>>{
            key: <String, dynamic>{'ok': true, 'source': 'canned'},
          },
        ),
      );

      final Map<String, dynamic> res =
          await http.get(url: 'https://example.com/ping');

      expect(res['ok'], isTrue);
      expect(res['source'], 'canned');
    });

    test('Given services in order When both canHandle Then first one wins',
        () async {
      final _SpyService first = _SpyService(
        canHandleFn: (RequestContext ctx) => true,
        handleFn: (RequestContext ctx) async =>
            <String, dynamic>{'from': 'first'},
      );
      final _SpyService second = _SpyService(
        canHandleFn: (RequestContext ctx) => true,
        handleFn: (RequestContext ctx) async =>
            <String, dynamic>{'from': 'second'},
      );

      final JocaaguraFakeHttpRequest http = JocaaguraFakeHttpRequest(
        services: <VirtualCrudService>[first, second],
      );

      final Map<String, dynamic> res =
          await http.get(url: 'https://example.com/any');

      expect(res['from'], 'first');
      expect(first.handleCalls, 1);
      expect(second.handleCalls, 0);
    });

    test(
        'Given no canned and no service match When calling Then throws StateError',
        () async {
      final _SpyService s = _SpyService(
        canHandleFn: (RequestContext ctx) => false,
        handleFn: (RequestContext ctx) async => <String, dynamic>{'x': 1},
      );

      final JocaaguraFakeHttpRequest http = JocaaguraFakeHttpRequest(
        services: <VirtualCrudService>[s],
      );

      expect(
        () => http.get(url: 'https://example.com/miss'),
        throwsA(isA<StateError>()),
      );
    });

    test('Given resetAll When called Then reset invoked on every service', () {
      final _SpyService a = _SpyService(
        canHandleFn: (RequestContext ctx) => false,
        handleFn: (RequestContext ctx) async => <String, dynamic>{},
      );
      final _SpyService b = _SpyService(
        canHandleFn: (RequestContext ctx) => false,
        handleFn: (RequestContext ctx) async => <String, dynamic>{},
      );

      final JocaaguraFakeHttpRequest http = JocaaguraFakeHttpRequest(
        services: <VirtualCrudService>[a, b],
      );

      http.resetAll();

      expect(a.resetCalls, 1);
      expect(b.resetCalls, 1);
    });

    test(
        'Given queryParameters When calling get Then uri includes query string',
        () async {
      final _SpyService s = _SpyService(
        canHandleFn: (RequestContext ctx) =>
            ctx.uri.queryParameters['q'] == '1',
        handleFn: (RequestContext ctx) async => <String, dynamic>{
          'q': ctx.uri.queryParameters['q'],
        },
      );

      final JocaaguraFakeHttpRequest http = JocaaguraFakeHttpRequest(
        services: <VirtualCrudService>[s],
      );

      final Map<String, dynamic> res = await http.get(
        url: 'https://example.com/search',
        queryParameters: <String, dynamic>{'q': 1},
      );

      expect(res['q'], '1');
    });
  });
}

/// -------------------
/// Minimal fakes used by tests.
/// -------------------

class _SpyService implements VirtualCrudService {
  _SpyService({
    required bool Function(RequestContext) canHandleFn,
    required Future<Map<String, dynamic>> Function(RequestContext) handleFn,
  })  : _canHandleFn = canHandleFn,
        _handleFn = handleFn;

  final bool Function(RequestContext) _canHandleFn;
  final Future<Map<String, dynamic>> Function(RequestContext) _handleFn;

  int handleCalls = 0;
  int resetCalls = 0;

  @override
  bool canHandle(RequestContext ctx) => _canHandleFn(ctx);

  @override
  Future<Map<String, dynamic>> handle(RequestContext ctx) async {
    handleCalls += 1;
    return _handleFn(ctx);
  }

  @override
  void reset() {
    resetCalls += 1;
  }
}
