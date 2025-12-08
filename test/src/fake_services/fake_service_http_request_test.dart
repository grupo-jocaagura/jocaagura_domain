import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FakeHttpRequestConfig', () {
    test(
      'Given FakeHttpRequestConfig.none '
      'When se inspeccionan los campos '
      'Then no tiene latency ni rutas ni errores configurados',
      () {
        // Arrange & Act
        const FakeHttpRequestConfig config = FakeHttpRequestConfig.none;

        // Assert
        expect(config.latency, equals(Duration.zero));
        expect(config.throwOnGet, isFalse);
        expect(config.throwOnPost, isFalse);
        expect(config.throwOnPut, isFalse);
        expect(config.throwOnDelete, isFalse);
        expect(config.cannedResponses, isEmpty);
        expect(config.cannedConfigs, isEmpty);
        expect(config.errorRoutes, isEmpty);
      },
    );

    test(
      'Given un FakeHttpRequestConfig custom '
      'When se crea '
      'Then conserva los valores configurados',
      () {
        // Arrange
        const FakeHttpRequestConfig config = FakeHttpRequestConfig(
          latency: Duration(milliseconds: 5),
          throwOnGet: true,
          throwOnPost: true,
          throwOnDelete: true,
          cannedResponses: <String, Map<String, dynamic>>{
            'GET https://api.example.com/ping': <String, dynamic>{'ok': true},
          },
          errorRoutes: <String, String>{
            'GET https://api.example.com/error': 'route error',
          },
        );

        // Assert
        expect(config.latency, equals(const Duration(milliseconds: 5)));
        expect(config.throwOnGet, isTrue);
        expect(config.throwOnPost, isTrue);
        expect(config.throwOnPut, isFalse);
        expect(config.throwOnDelete, isTrue);
        expect(config.cannedResponses.length, equals(1));
        expect(config.errorRoutes.length, equals(1));
      },
    );
  });

  group('FakeHttpRequest - cannedResponses y cannedConfigs', () {
    test(
      'Given un cannedResponse registrado '
      'When se hace un GET a esa ruta '
      'Then devuelve una copia del JSON esperado',
      () async {
        // Arrange
        final Uri uri = Uri.parse('https://api.example.com/ping');
        const String routeKey = 'GET https://api.example.com/ping';
        const Map<String, dynamic> cannedBody = <String, dynamic>{
          'ok': true,
          'nested': <String, dynamic>{'value': 1},
        };

        final FakeHttpRequestConfig config = FakeHttpRequestConfig(
          cannedResponses: <String, Map<String, dynamic>>{
            routeKey: FakeHttpRequestConfig.cannedHttpResponse(
              method: HttpMethodEnum.get,
              uri: uri,
              body: cannedBody,
            ),
          },
        );

        final FakeHttpRequest service = FakeHttpRequest(config: config);

        // Act
        final Map<String, dynamic> result = await service.get(uri);

        // Assert
        expect(result['method'], equals('GET'));
        expect(result['uri'], equals(uri.toString()));
        expect(result['statusCode'], equals(200));
        expect(result['body'], equals(cannedBody));
        expect(result['fake'], isTrue);
        expect(result['source'], equals('FakeHttpRequest'));
      },
    );

    test(
      'Given un cannedConfig registrado '
      'When se hace GET a esa ruta '
      'Then la respuesta es el JSON de ModelConfigHttpRequest',
      () async {
        // Arrange
        const String routeKey = 'GET https://api.example.com/config';
        final ModelConfigHttpRequest configModel = ModelConfigHttpRequest(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://api.example.com/config'),
          headers: const <String, String>{'Authorization': 'Bearer token'},
          body: const <String, dynamic>{'filter': 'all'},
          timeout: const Duration(seconds: 3),
          metadata: const <String, dynamic>{'feature': 'configTest'},
        );

        final Map<String, ModelConfigHttpRequest> cannedConfigs =
            <String, ModelConfigHttpRequest>{
          routeKey: configModel,
        };

        final FakeHttpRequest service = FakeHttpRequest(
          config: FakeHttpRequestConfig(
            cannedConfigs: cannedConfigs,
          ),
        );

        final Uri uri = Uri.parse('https://api.example.com/config');

        // Act
        final Map<String, dynamic> result = await service.get(uri);

        // Assert
        expect(result['method'], equals('GET'));
        expect(result['uri'], equals(uri.toString()));
        expect(result['headers'], equals(configModel.headers));
        expect(result['body'], equals(configModel.body));
        expect(result['metadata'], equals(configModel.metadata));
        expect(result['timeout'], equals(configModel.timeout?.inMilliseconds));
      },
    );
  });

  group('FakeHttpRequest - echo responses', () {
    test(
      'Given una ruta sin canned ni error '
      'When se hace un GET '
      'Then devuelve un echo con method, uri, headers, timeoutMs y metadata',
      () async {
        // Arrange
        final FakeHttpRequest service = FakeHttpRequest();
        final Uri uri = Uri.parse('https://api.example.com/echo');
        final Map<String, String> headers = <String, String>{
          'X-Test': '1',
        };
        const Duration timeout = Duration(seconds: 5);
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'echoTest',
        };

        // Act
        final Map<String, dynamic> result = await service.get(
          uri,
          headers: headers,
          timeout: timeout,
          metadata: metadata,
        );

        // Assert
        expect(result['method'], equals('GET'));
        expect(result['uri'], equals('https://api.example.com/echo'));
        expect(result['headers'], equals(headers));
        expect(result['body'], isNull);
        expect(result['timeoutMs'], equals(timeout.inMilliseconds));
        expect(result['metadata'], equals(metadata));
        expect(result['fake'], isTrue);
        expect(result['source'], equals('FakeHttpRequest'));
      },
    );

    test(
      'Given una ruta sin canned ni error '
      'When se hace un POST con body '
      'Then el echo conserva el body y metadata',
      () async {
        // Arrange
        final FakeHttpRequest service = FakeHttpRequest();
        final Uri uri = Uri.parse('https://api.example.com/echo-post');
        final Map<String, dynamic> body = <String, dynamic>{
          'name': 'John',
          'age': 30,
        };
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'postEcho',
        };

        // Act
        final Map<String, dynamic> result = await service.post(
          uri,
          body: body,
          metadata: metadata,
        );

        // Assert
        expect(result['method'], equals('POST'));
        expect(result['uri'], equals('https://api.example.com/echo-post'));
        expect(result['headers'], equals(<String, String>{}));
        expect(result['body'], equals(body));
        expect(result['metadata'], equals(metadata));
        expect(result['fake'], isTrue);
        expect(result['source'], equals('FakeHttpRequest'));
      },
    );
  });

  group('FakeHttpRequest - errores por método y por ruta', () {
    test(
      'Given throwOnGet=true '
      'When se hace un GET '
      'Then lanza StateError con mensaje Simulated GET error',
      () async {
        // Arrange
        final FakeHttpRequest service = FakeHttpRequest(
          config: const FakeHttpRequestConfig(
            throwOnGet: true,
          ),
        );
        final Uri uri = Uri.parse('https://api.example.com/any');

        // Act & Assert
        expect(
          () => service.get(uri),
          throwsA(
            isA<StateError>().having(
              (StateError e) => e.message,
              'message',
              contains('Simulated GET error'),
            ),
          ),
        );
      },
    );

    test(
      'Given throwOnPost/Put/Delete=true '
      'When se llama post/put/delete '
      'Then cada uno lanza StateError con mensaje correspondiente',
      () async {
        // Arrange
        final FakeHttpRequest service = FakeHttpRequest(
          config: const FakeHttpRequestConfig(
            throwOnPost: true,
            throwOnPut: true,
            throwOnDelete: true,
          ),
        );
        final Uri uri = Uri.parse('https://api.example.com/any');

        // Act & Assert - POST
        expect(
          () => service.post(uri),
          throwsA(
            isA<StateError>().having(
              (StateError e) => e.message,
              'message',
              contains('POST'),
            ),
          ),
        );

        // PUT
        expect(
          () => service.put(uri),
          throwsA(
            isA<StateError>().having(
              (StateError e) => e.message,
              'message',
              contains('PUT'),
            ),
          ),
        );

        // DELETE
        expect(
          () => service.delete(uri),
          throwsA(
            isA<StateError>().having(
              (StateError e) => e.message,
              'message',
              contains('DELETE'),
            ),
          ),
        );
      },
    );

    test(
      'Given errorRoutes configurado para una ruta '
      'When se hace GET a esa ruta '
      'Then lanza StateError con el mensaje configurado',
      () async {
        // Arrange
        const String key = 'GET https://api.example.com/fail';
        final FakeHttpRequest service = FakeHttpRequest(
          config: const FakeHttpRequestConfig(
            errorRoutes: <String, String>{
              key: 'Ruta con error',
            },
          ),
        );
        final Uri uri = Uri.parse('https://api.example.com/fail');

        // Act & Assert
        expect(
          () => service.get(uri),
          throwsA(
            isA<StateError>().having(
              (StateError e) => e.message,
              'message',
              contains('Ruta con error'),
            ),
          ),
        );
      },
    );

    test(
      'Given throwOnGet=true y errorRoutes para la misma ruta '
      'When se hace GET '
      'Then tiene precedencia throwOnGet sobre errorRoutes',
      () async {
        // Arrange
        const String key = 'GET https://api.example.com/fail';
        final FakeHttpRequest service = FakeHttpRequest(
          config: const FakeHttpRequestConfig(
            throwOnGet: true,
            errorRoutes: <String, String>{
              key: 'Este mensaje no debe verse',
            },
          ),
        );
        final Uri uri = Uri.parse('https://api.example.com/fail');

        // Act & Assert
        expect(
          () => service.get(uri),
          throwsA(
            isA<StateError>().having(
              (StateError e) => e.message,
              'message',
              contains('Simulated GET error'),
            ),
          ),
        );
      },
    );
  });

  group('FakeHttpRequest - latency y dispose', () {
    test(
      'Given latency distinta de Duration.zero '
      'When se hace una petición '
      'Then la llamada sigue funcionando (se ejecuta _maybeDelay)',
      () async {
        // Arrange
        final FakeHttpRequest service = FakeHttpRequest(
          config: const FakeHttpRequestConfig(
            latency: Duration(milliseconds: 1),
          ),
        );
        final Uri uri = Uri.parse('https://api.example.com/latency');

        // Act
        final Map<String, dynamic> result = await service.get(uri);

        // Assert
        expect(result['method'], equals('GET'));
        expect(result['uri'], equals('https://api.example.com/latency'));
        expect(result['fake'], isTrue);
      },
    );

    test(
      'Given una instancia que ha sido dispose() '
      'When se intenta usar cualquier método '
      'Then lanza StateError indicando que fue disposed',
      () async {
        // Arrange
        final FakeHttpRequest service = FakeHttpRequest();
        final Uri uri = Uri.parse('https://api.example.com/disposed');

        // Act
        service.dispose();

        // Assert
        expect(
          () => service.get(uri),
          throwsA(
            isA<StateError>().having(
              (StateError e) => e.message,
              'message',
              contains('FakeHttpRequest has been disposed'),
            ),
          ),
        );
      },
    );
  });

  group('FakeHttpRequest - deep copy de respuestas', () {
    test(
      'Given una respuesta canned con estructuras anidadas '
      'When se modifica el resultado de la primera llamada '
      'Then una segunda llamada devuelve datos originales (deep copy)',
      () async {
        // Arrange
        final Uri uri = Uri.parse('https://api.example.com/deep');
        const String key = 'GET https://api.example.com/deep';
        final FakeHttpRequestConfig config = FakeHttpRequestConfig(
          cannedResponses: <String, Map<String, dynamic>>{
            key: FakeHttpRequestConfig.cannedHttpResponse(
              method: HttpMethodEnum.get,
              uri: uri,
              body: <String, dynamic>{
                'nested': <String, dynamic>{'value': 1},
                'list': <dynamic>[
                  <String, dynamic>{'value': 2},
                ],
              },
            ),
          },
        );
        final FakeHttpRequest service = FakeHttpRequest(config: config);

        // Act - primera llamada
        final Map<String, dynamic> first = await service.get(uri);
        final Map<String, dynamic> firstBody =
            first['body'] as Map<String, dynamic>;
        (firstBody['nested'] as Map<String, dynamic>)['value'] = 999;
        ((firstBody['list'] as List<dynamic>)[0]
            as Map<String, dynamic>)['value'] = 888;

        // Segunda llamada
        final Map<String, dynamic> second = await service.get(uri);
        final Map<String, dynamic> secondBody =
            second['body'] as Map<String, dynamic>;

        // Assert - el segundo resultado no fue afectado por las mutaciones
        expect(
          (secondBody['nested'] as Map<String, dynamic>)['value'],
          equals(1),
        );
        expect(
          ((secondBody['list'] as List<dynamic>)[0]
              as Map<String, dynamic>)['value'],
          equals(2),
        );
      },
    );
  });

  group('FakeHttpRequest - canned responses for POST/PUT/DELETE', () {
    test(
      'Given a cannedResponse for POST '
      'When post is called for that route '
      'Then it returns the canned JSON instead of echo',
      () async {
        // Arrange
        final Uri uri = Uri.parse('https://api.example.com/post-canned');
        const String routeKey = 'POST https://api.example.com/post-canned';
        final FakeHttpRequestConfig config = FakeHttpRequestConfig(
          cannedResponses: <String, Map<String, dynamic>>{
            routeKey: FakeHttpRequestConfig.cannedHttpResponse(
              method: HttpMethodEnum.post,
              uri: uri,
              statusCode: 201,
              body: const <String, dynamic>{
                'status': 'created',
                'id': 123,
              },
            ),
          },
        );

        final FakeHttpRequest service = FakeHttpRequest(config: config);

        // Act
        final Map<String, dynamic> result = await service.post(
          uri,
          body: const <String, dynamic>{'name': 'John'},
        );

        // Assert
        expect(result['method'], equals('POST'));
        expect(result['uri'], equals(uri.toString()));
        expect(result['statusCode'], equals(201));
        expect(
          result['body'],
          equals(const <String, dynamic>{'status': 'created', 'id': 123}),
        );
      },
    );

    test(
      'Given a cannedResponse for PUT and another route without canned '
      'When put is called for both routes '
      'Then the first returns the canned JSON and the second returns an echo',
      () async {
        // Arrange
        final Uri cannedUri = Uri.parse('https://api.example.com/put-canned');
        const String cannedKey = 'PUT https://api.example.com/put-canned';
        final FakeHttpRequestConfig config = FakeHttpRequestConfig(
          cannedResponses: <String, Map<String, dynamic>>{
            cannedKey: FakeHttpRequestConfig.cannedHttpResponse(
              method: HttpMethodEnum.put,
              uri: cannedUri,
              body: const <String, dynamic>{
                'updated': true,
                'version': 2,
              },
            ),
          },
        );

        final FakeHttpRequest service = FakeHttpRequest(config: config);
        final Uri echoUri = Uri.parse('https://api.example.com/put-echo');

        // Act - ruta con canned
        final Map<String, dynamic> cannedResult = await service.put(
          cannedUri,
          body: const <String, dynamic>{'field': 'value'},
        );

        // Act - ruta sin canned (echo)
        final Map<String, dynamic> echoResult = await service.put(
          echoUri,
          headers: const <String, String>{'X-Test': '1'},
        );

        // Assert - canned
        expect(cannedResult['method'], equals('PUT'));
        expect(cannedResult['uri'], equals(cannedUri.toString()));
        expect(
          cannedResult['body'],
          equals(const <String, dynamic>{'updated': true, 'version': 2}),
        );

        // Assert - echo
        expect(echoResult['method'], equals('PUT'));
        expect(echoResult['uri'], equals('https://api.example.com/put-echo'));
        expect(
          echoResult['headers'],
          equals(const <String, String>{'X-Test': '1'}),
        );
        expect(echoResult['fake'], isTrue);
        expect(echoResult['source'], equals('FakeHttpRequest'));
      },
    );

    test(
      'Given a cannedResponse for DELETE and another route without canned '
      'When delete is called for both routes '
      'Then the first returns the canned JSON and the second returns an echo',
      () async {
        // Arrange
        final Uri cannedUri =
            Uri.parse('https://api.example.com/delete-canned');
        const String cannedKey = 'DELETE https://api.example.com/delete-canned';
        final FakeHttpRequestConfig config = FakeHttpRequestConfig(
          cannedResponses: <String, Map<String, dynamic>>{
            cannedKey: FakeHttpRequestConfig.cannedHttpResponse(
              method: HttpMethodEnum.delete,
              uri: cannedUri,
              body: const <String, dynamic>{
                'deleted': true,
                'id': 99,
              },
            ),
          },
        );

        final FakeHttpRequest service = FakeHttpRequest(config: config);
        final Uri echoUri = Uri.parse('https://api.example.com/delete-echo');

        // Act - ruta con canned
        final Map<String, dynamic> cannedResult = await service.delete(
          cannedUri,
        );

        // Act - ruta sin canned (echo)
        final Map<String, dynamic> echoResult = await service.delete(
          echoUri,
          metadata: const <String, dynamic>{'feature': 'deleteEcho'},
        );

        // Assert - canned
        expect(cannedResult['method'], equals('DELETE'));
        expect(cannedResult['uri'], equals(cannedUri.toString()));
        expect(
          cannedResult['body'],
          equals(const <String, dynamic>{'deleted': true, 'id': 99}),
        );

        // Assert - echo
        expect(echoResult['method'], equals('DELETE'));
        expect(
          echoResult['uri'],
          equals('https://api.example.com/delete-echo'),
        );
        expect(echoResult['headers'], equals(<String, String>{}));
        expect(
          echoResult['metadata'],
          equals(const <String, dynamic>{'feature': 'deleteEcho'}),
        );
        expect(echoResult['fake'], isTrue);
        expect(echoResult['source'], equals('FakeHttpRequest'));
      },
    );
  });
}
