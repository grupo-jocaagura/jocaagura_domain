import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Fake de ServiceHttpRequest que registra la última invocación.
class _RecordingServiceHttpRequest implements ServiceHttpRequest {
  Uri? lastUri;
  Map<String, String>? lastHeadersGet;
  Map<String, String>? lastHeadersPost;
  Map<String, String>? lastHeadersPut;
  Map<String, String>? lastHeadersDelete;

  Duration? lastTimeoutGet;
  Duration? lastTimeoutPost;
  Duration? lastTimeoutPut;
  Duration? lastTimeoutDelete;

  dynamic lastMetadataGet;
  dynamic lastMetadataPost;
  dynamic lastMetadataPut;
  dynamic lastMetadataDelete;

  Map<String, dynamic>? lastBodyPost;
  Map<String, dynamic>? lastBodyPut;

  Map<String, dynamic> response = <String, dynamic>{'ok': true};

  bool throwOnGet = false;
  bool throwOnPost = false;
  bool throwOnPut = false;
  bool throwOnDelete = false;

  @override
  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic>? metadata,
  }) async {
    lastUri = uri;
    lastHeadersGet = headers;
    lastTimeoutGet = timeout;
    lastMetadataGet = metadata;
    if (throwOnGet) {
      throw StateError('GET transport error');
    }
    return response;
  }

  @override
  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    Map<String, dynamic>? metadata,
  }) async {
    lastUri = uri;
    lastHeadersPost = headers;
    lastTimeoutPost = timeout;
    lastMetadataPost = metadata;
    lastBodyPost = body;
    if (throwOnPost) {
      throw StateError('POST transport error');
    }
    return response;
  }

  @override
  Future<Map<String, dynamic>> put(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    Map<String, dynamic>? metadata,
  }) async {
    lastUri = uri;
    lastHeadersPut = headers;
    lastTimeoutPut = timeout;
    lastMetadataPut = metadata;
    lastBodyPut = body;
    if (throwOnPut) {
      throw StateError('PUT transport error');
    }
    return response;
  }

  @override
  Future<Map<String, dynamic>> delete(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic>? metadata,
  }) async {
    lastUri = uri;
    lastHeadersDelete = headers;
    lastTimeoutDelete = timeout;
    lastMetadataDelete = metadata;
    if (throwOnDelete) {
      throw StateError('DELETE transport error');
    }
    return response;
  }
}

/// Fake de ErrorMapper que permite simular errores de negocio y transporte.
class _FakeErrorMapper implements ErrorMapper {
  ErrorItem? lastFromException;
  ErrorItem? lastFromPayload;
  String? lastLocationFromException;
  String? lastLocationFromPayload;

  bool returnBusinessError = false;

  @override
  ErrorItem fromException(
    Object error,
    StackTrace stackTrace, {
    String location = 'unknown',
  }) {
    final ErrorItem item = ErrorItem(
      title: 'Mapped from exception',
      code: 'EXCEPTION_CODE',
      description: 'Error: $error',
      errorLevel: ErrorLevelEnum.severe,
      meta: <String, dynamic>{
        'location': location,
        'type': error.runtimeType.toString(),
      },
    );
    lastFromException = item;
    lastLocationFromException = location;
    return item;
  }

  @override
  ErrorItem? fromPayload(
    Map<String, dynamic> payload, {
    String location = 'unknown',
  }) {
    lastLocationFromPayload = location;

    if (returnBusinessError && payload['businessError'] == true) {
      final ErrorItem item = ErrorItem(
        title: 'Business error',
        code: 'BUSINESS_ERROR',
        description: 'Detected by payload',
        errorLevel: ErrorLevelEnum.warning,
        meta: <String, dynamic>{
          'location': location,
        },
      );
      lastFromPayload = item;
      return item;
    }

    lastFromPayload = null;
    return null;
  }
}

void main() {
  group('GatewayHttpRequestImpl - GET mapping and success', () {
    test(
      'Given metadata de dominio y headers vacíos '
      'When get es invocado '
      'Then mapea metadata a Map<String, String> y headers se pasan como null',
      () async {
        // Arrange
        final _RecordingServiceHttpRequest service =
            _RecordingServiceHttpRequest();
        final _FakeErrorMapper mapper = _FakeErrorMapper();

        final GatewayHttpRequestImpl gateway = GatewayHttpRequestImpl(
          service: service,
          errorMapper: mapper,
          location: 'MyGateway',
        );

        final Uri uri = Uri.parse('https://api.example.com/users');
        const Duration timeout = Duration(seconds: 3);
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'listUsers',
          'attempt': 2,
          'flag': true,
        };

        // Act
        final Either<ErrorItem, Map<String, dynamic>> result =
            await gateway.get(
          uri,
          // headers por defecto => {}
          timeout: timeout,
          metadata: metadata,
        );

        // Assert gateway result
        expect(result, isA<Right<ErrorItem, Map<String, dynamic>>>());
        final Right<ErrorItem, Map<String, dynamic>> right =
            result as Right<ErrorItem, Map<String, dynamic>>;
        expect(right.value, equals(service.response));

        // Assert mapping hacia ServiceHttpRequest
        expect(service.lastUri, equals(uri));
        expect(service.lastHeadersGet, isNull); // headers vacíos → null
        expect(service.lastTimeoutGet, equals(timeout));

        final Map<String, dynamic>? svcMetadata =
            service.lastMetadataGet as Map<String, dynamic>?;
        expect(svcMetadata, isNotNull);
        expect(svcMetadata!['feature'], equals('listUsers'));
        expect(svcMetadata['attempt'], equals('2'));
        expect(svcMetadata['flag'], equals('true'));

        // No hay error de negocio
        expect(mapper.lastFromPayload, isNull);
      },
    );

    test(
      'Given headers no vacíos '
      'When get es invocado '
      'Then headers son propagados tal cual al servicio',
      () async {
        // Arrange
        final _RecordingServiceHttpRequest service =
            _RecordingServiceHttpRequest();
        final GatewayHttpRequestImpl gateway = GatewayHttpRequestImpl(
          service: service,
          errorMapper: _FakeErrorMapper(),
          location: 'MyGateway',
        );

        final Uri uri = Uri.parse('https://api.example.com/users');
        final Map<String, String> headers = <String, String>{
          'Authorization': 'Bearer token',
        };

        // Act
        final Either<ErrorItem, Map<String, dynamic>> result =
            await gateway.get(
          uri,
          headers: headers,
        );

        // Assert
        expect(result, isA<Right<ErrorItem, Map<String, dynamic>>>());
        expect(service.lastHeadersGet, equals(headers));
      },
    );
  });

  group('GatewayHttpRequestImpl - POST/PUT/DELETE body & metadata adapters',
      () {
    test(
      'Given body con valores dinámicos y metadata '
      'When post es invocado '
      'Then body se transforma a Map<String, String> y metadata a {tags: {...}}',
      () async {
        // Arrange
        final _RecordingServiceHttpRequest service =
            _RecordingServiceHttpRequest();
        final _FakeErrorMapper mapper = _FakeErrorMapper();

        final GatewayHttpRequestImpl gateway = GatewayHttpRequestImpl(
          service: service,
          errorMapper: mapper,
          location: 'Gw',
        );

        final Uri uri = Uri.parse('https://api.example.com/create');
        final Map<String, dynamic> body = <String, dynamic>{
          'amount': 10,
          'active': true,
        };
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'createUser',
          'attempt': 1,
        };

        // Act
        final Either<ErrorItem, Map<String, dynamic>> result =
            await gateway.post(
          uri,
          headers: <String, String>{'X-Test': 'yes'},
          body: body,
          metadata: metadata,
        );

        // Assert resultado
        expect(result, isA<Right<ErrorItem, Map<String, dynamic>>>());

        // Assert body transformado
        final Map<String, dynamic>? svcBody = service.lastBodyPost;
        expect(svcBody, isNotNull);
        expect(svcBody!['amount'], equals('10'));
        expect(svcBody['active'], equals('true'));

        // Assert metadata anidado
        final Map<String, dynamic>? svcMetadata =
            service.lastMetadataPost as Map<String, dynamic>?;
        expect(svcMetadata, isNotNull);
        expect(svcMetadata!.containsKey('tags'), isTrue);

        final Map<String, String>? tags =
            svcMetadata['tags'] as Map<String, String>?;
        expect(tags, isNotNull);
        expect(tags!['feature'], equals('createUser'));
        expect(tags['attempt'], equals('1'));
      },
    );

    test(
      'Given body vacío '
      'When post es invocado '
      'Then body se pasa como null al ServiceHttpRequest',
      () async {
        // Arrange
        final _RecordingServiceHttpRequest service =
            _RecordingServiceHttpRequest();
        final GatewayHttpRequestImpl gateway = GatewayHttpRequestImpl(
          service: service,
          errorMapper: _FakeErrorMapper(),
        );

        final Uri uri = Uri.parse('https://api.example.com/empty-body');

        // Act
        final Either<ErrorItem, Map<String, dynamic>> result =
            await gateway.post(
          uri,
        );

        // Assert
        expect(result, isA<Right<ErrorItem, Map<String, dynamic>>>());
        expect(service.lastBodyPost, isNull);
      },
    );

    test(
      'Given metadata de dominio '
      'When put es invocado '
      'Then metadata se transforma a {tags: flatMap} y body a Map<String, String> si no está vacío',
      () async {
        // Arrange
        final _RecordingServiceHttpRequest service =
            _RecordingServiceHttpRequest();
        final GatewayHttpRequestImpl gateway = GatewayHttpRequestImpl(
          service: service,
          errorMapper: _FakeErrorMapper(),
        );

        final Uri uri = Uri.parse('https://api.example.com/update');
        final Map<String, dynamic> body = <String, dynamic>{
          'name': 'Alice',
          'age': 25,
        };
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'updateUser',
          'attempt': 2,
        };

        // Act
        final Either<ErrorItem, Map<String, dynamic>> result =
            await gateway.put(
          uri,
          body: body,
          metadata: metadata,
        );

        // Assert
        expect(result, isA<Right<ErrorItem, Map<String, dynamic>>>());

        final Map<String, dynamic>? svcBody = service.lastBodyPut;
        expect(svcBody, isNotNull);
        expect(svcBody!['name'], equals('Alice'));
        expect(svcBody['age'], equals('25'));

        final Map<String, dynamic>? svcMetadata =
            service.lastMetadataPut as Map<String, dynamic>?;
        final Map<String, String>? tags =
            svcMetadata?['tags'] as Map<String, String>?;
        expect(tags, isNotNull);
        expect(tags!['feature'], equals('updateUser'));
        expect(tags['attempt'], equals('2'));
      },
    );

    test(
      'Given metadata de dominio '
      'When delete es invocado '
      'Then metadata se transforma a {tags: flatMap}',
      () async {
        // Arrange
        final _RecordingServiceHttpRequest service =
            _RecordingServiceHttpRequest();
        final GatewayHttpRequestImpl gateway = GatewayHttpRequestImpl(
          service: service,
          errorMapper: _FakeErrorMapper(),
        );

        final Uri uri = Uri.parse('https://api.example.com/delete/1');
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'deleteUser',
          'hardDelete': false,
        };

        // Act
        final Either<ErrorItem, Map<String, dynamic>> result =
            await gateway.delete(
          uri,
          metadata: metadata,
        );

        // Assert
        expect(result, isA<Right<ErrorItem, Map<String, dynamic>>>());

        final Map<String, dynamic>? svcMetadata =
            service.lastMetadataDelete as Map<String, dynamic>?;
        final Map<String, String>? tags =
            svcMetadata?['tags'] as Map<String, String>?;
        expect(tags, isNotNull);
        expect(tags!['feature'], equals('deleteUser'));
        expect(tags['hardDelete'], equals('false'));
      },
    );
  });

  group('GatewayHttpRequestImpl - business errors via fromPayload', () {
    test(
      'Given ErrorMapper devuelve ErrorItem en fromPayload '
      'When el payload contiene businessError=true '
      'Then el gateway devuelve Left con ese ErrorItem',
      () async {
        // Arrange
        final _RecordingServiceHttpRequest service =
            _RecordingServiceHttpRequest()
              ..response = <String, dynamic>{
                'businessError': true,
                'message': 'Invalid data',
              };

        final _FakeErrorMapper mapper = _FakeErrorMapper()
          ..returnBusinessError = true;

        final GatewayHttpRequestImpl gateway = GatewayHttpRequestImpl(
          service: service,
          errorMapper: mapper,
          location: 'BizGateway',
        );

        final Uri uri = Uri.parse('https://api.example.com/biz');

        // Act
        final Either<ErrorItem, Map<String, dynamic>> result =
            await gateway.post(uri);

        // Assert
        expect(result, isA<Left<ErrorItem, Map<String, dynamic>>>());
        final Left<ErrorItem, Map<String, dynamic>> left =
            result as Left<ErrorItem, Map<String, dynamic>>;

        final ErrorItem error = left.value;
        expect(error.code, equals('BUSINESS_ERROR'));
        expect(error.title, equals('Business error'));
        expect(
          error.meta['location'],
          equals('BizGateway.POST($uri)'),
        ); // usa _buildLocation

        // Confirmamos que fromException NO se llamó
        expect(mapper.lastFromException, isNull);
      },
    );
  });

  group('GatewayHttpRequestImpl - exception mapping via fromException', () {
    test(
      'Given el servicio lanza una excepción '
      'When el gateway invoca el método '
      'Then captura la excepción y devuelve Left mapeado por ErrorMapper',
      () async {
        // Arrange
        final _RecordingServiceHttpRequest service =
            _RecordingServiceHttpRequest()..throwOnPost = true;

        final _FakeErrorMapper mapper = _FakeErrorMapper();

        final GatewayHttpRequestImpl gateway = GatewayHttpRequestImpl(
          service: service,
          errorMapper: mapper,
          location: 'TransportGateway',
        );

        final Uri uri = Uri.parse('https://api.example.com/fail');

        // Act
        final Either<ErrorItem, Map<String, dynamic>> result =
            await gateway.post(uri);

        // Assert
        expect(result, isA<Left<ErrorItem, Map<String, dynamic>>>());
        final Left<ErrorItem, Map<String, dynamic>> left =
            result as Left<ErrorItem, Map<String, dynamic>>;

        final ErrorItem error = left.value;
        expect(error.code, equals('EXCEPTION_CODE'));
        expect(
          error.meta['location'],
          equals('TransportGateway.POST($uri)'),
        ); // _buildLocation
        expect(error.meta['type'], equals('StateError'));

        // Confirmamos que se llamó fromException con la misma location
        expect(
          mapper.lastLocationFromException,
          equals('TransportGateway.POST($uri)'),
        );
      },
    );
  });

  group('GatewayHttpRequestImpl - helpers internos', () {
    test(
      'Given metadata vacío '
      'When se usa en POST/PUT/DELETE '
      'Then se mapea a {tags: {}} y no es null',
      () async {
        // Arrange
        final _RecordingServiceHttpRequest service =
            _RecordingServiceHttpRequest();
        final GatewayHttpRequestImpl gateway = GatewayHttpRequestImpl(
          service: service,
          errorMapper: _FakeErrorMapper(),
        );

        final Uri uri = Uri.parse('https://api.example.com/empty-meta');

        // Act
        await gateway.post(uri);

        // Assert
        final Map<String, dynamic>? metaPost =
            service.lastMetadataPost as Map<String, dynamic>?;
        expect(metaPost, isNotNull);
        expect(metaPost!.containsKey('tags'), isTrue);
        expect(metaPost['tags'], equals(<String, String>{}));

        // PUT
        await gateway.put(uri);
        final Map<String, dynamic>? metaPut =
            service.lastMetadataPut as Map<String, dynamic>?;
        expect(metaPut, isNotNull);
        expect(metaPut!['tags'], equals(<String, String>{}));

        // DELETE
        await gateway.delete(uri);
        final Map<String, dynamic>? metaDelete =
            service.lastMetadataDelete as Map<String, dynamic>?;
        expect(metaDelete, isNotNull);
        expect(metaDelete!['tags'], equals(<String, String>{}));
      },
    );
  });
}
