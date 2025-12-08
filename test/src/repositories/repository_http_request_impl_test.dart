import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Fake GatewayHttpRequest que permite controlar la respuesta y
/// registrar los parámetros de la última llamada.
class _FakeGatewayHttpRequest implements GatewayHttpRequest {
  Either<ErrorItem, Map<String, dynamic>>? forcedGetResult;
  Either<ErrorItem, Map<String, dynamic>>? forcedPostResult;
  Either<ErrorItem, Map<String, dynamic>>? forcedPutResult;
  Either<ErrorItem, Map<String, dynamic>>? forcedDeleteResult;

  // Parámetros registrados
  Uri? lastUri;
  Map<String, String>? lastHeadersGet;
  Map<String, String>? lastHeadersPost;
  Map<String, String>? lastHeadersPut;
  Map<String, String>? lastHeadersDelete;

  Duration? lastTimeoutGet;
  Duration? lastTimeoutPost;
  Duration? lastTimeoutPut;
  Duration? lastTimeoutDelete;

  Map<String, dynamic>? lastMetadataGet;
  Map<String, dynamic>? lastMetadataPost;
  Map<String, dynamic>? lastMetadataPut;
  Map<String, dynamic>? lastMetadataDelete;

  Map<String, dynamic>? lastBodyPost;
  Map<String, dynamic>? lastBodyPut;

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> get(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    lastUri = uri;
    lastHeadersGet = headers;
    lastTimeoutGet = timeout;
    lastMetadataGet = metadata;
    return forcedGetResult ??
        Right<ErrorItem, Map<String, dynamic>>(
          _buildConfigJson(
            method: HttpMethodEnum.get,
            uri: uri,
            headers: headers,
            timeout: timeout,
            metadata: metadata,
          ),
        );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    lastUri = uri;
    lastHeadersPost = headers;
    lastTimeoutPost = timeout;
    lastMetadataPost = metadata;
    lastBodyPost = body;
    return forcedPostResult ??
        Right<ErrorItem, Map<String, dynamic>>(
          _buildConfigJson(
            method: HttpMethodEnum.post,
            uri: uri,
            headers: headers ?? const <String, String>{},
            body: body,
            timeout: timeout,
            metadata: metadata,
          ),
        );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> put(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    lastUri = uri;
    lastHeadersPut = headers;
    lastTimeoutPut = timeout;
    lastMetadataPut = metadata;
    lastBodyPut = body;
    return forcedPutResult ??
        Right<ErrorItem, Map<String, dynamic>>(
          _buildConfigJson(
            method: HttpMethodEnum.put,
            uri: uri,
            headers: headers ?? const <String, String>{},
            body: body,
            timeout: timeout,
            metadata: metadata,
          ),
        );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> delete(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    lastUri = uri;
    lastHeadersDelete = headers;
    lastTimeoutDelete = timeout;
    lastMetadataDelete = metadata;
    return forcedDeleteResult ??
        Right<ErrorItem, Map<String, dynamic>>(
          _buildConfigJson(
            method: HttpMethodEnum.delete,
            uri: uri,
            headers: headers ?? const <String, String>{},
            timeout: timeout,
            metadata: metadata,
          ),
        );
  }

  Map<String, dynamic> _buildConfigJson({
    required HttpMethodEnum method,
    required Uri uri,
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return <String, dynamic>{
      'method': method.name,
      'uri': uri.toString(),
      'headers': headers,
      'body': body,
      'timeout': timeout?.inMilliseconds,
      'metadata': metadata,
    };
  }
}

void main() {
  group('RepositoryHttpRequestImpl - GET', () {
    test(
      'Given gateway devuelve Right '
      'When get es invocado '
      'Then devuelve Right con ModelConfigHttpRequest con method GET y parámetros correctos',
      () async {
        // Arrange
        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest();
        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Uri uri = Uri.parse('https://api.example.com/users');
        final Map<String, String> headers = <String, String>{
          'Authorization': 'Bearer token',
        };
        const Duration timeout = Duration(seconds: 5);
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'listUsers',
          'attempt': 1,
        };

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await repository.get(
          uri,
          headers: headers,
          timeout: timeout,
          metadata: metadata,
        );

        // Assert: delegación al gateway
        expect(fakeGateway.lastUri, equals(uri));
        expect(fakeGateway.lastHeadersGet, equals(headers));
        expect(fakeGateway.lastTimeoutGet, equals(timeout));
        expect(fakeGateway.lastMetadataGet, equals(metadata));

        // Assert: resultado Right con config correcta
        expect(result, isA<Right<ErrorItem, ModelConfigHttpRequest>>());
        final Right<ErrorItem, ModelConfigHttpRequest> right =
            result as Right<ErrorItem, ModelConfigHttpRequest>;
        final ModelConfigHttpRequest config = right.value;

        expect(config.method, equals(HttpMethodEnum.get));
        expect(config.uri, equals(uri));
        expect(config.headers, equals(headers));
        expect(config.timeout, equals(timeout));
        expect(config.metadata, equals(metadata));
        expect(config.body, isEmpty); // GET no usa body
      },
    );

    test(
      'Given gateway devuelve Left '
      'When get es invocado '
      'Then repo devuelve Left propagando el ErrorItem',
      () async {
        // Arrange
        const ErrorItem gatewayError = ErrorItem(
          title: 'Network error',
          code: 'NET_FAIL',
          description: 'No connection',
          errorLevel: ErrorLevelEnum.severe,
        );

        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest()
          ..forcedGetResult =
              Left<ErrorItem, Map<String, dynamic>>(gatewayError);

        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Uri uri = Uri.parse('https://api.example.com/users');

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await repository.get(uri);

        // Assert
        expect(result, isA<Left<ErrorItem, ModelConfigHttpRequest>>());
        final Left<ErrorItem, ModelConfigHttpRequest> left =
            result as Left<ErrorItem, ModelConfigHttpRequest>;
        expect(left.value, same(gatewayError));
      },
    );
  });

  group('RepositoryHttpRequestImpl - POST', () {
    test(
      'Given gateway devuelve Right '
      'When post es invocado '
      'Then devuelve Right con ModelConfigHttpRequest con method POST y body normalizado',
      () async {
        // Arrange
        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest();
        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Uri uri = Uri.parse('https://api.example.com/users');
        final Map<String, String> headers = <String, String>{
          'Content-Type': 'application/json',
        };
        final Map<String, dynamic> body = <String, dynamic>{
          'name': 'Alice',
          'age': 30,
          'active': true,
        };
        const Duration timeout = Duration(seconds: 2);
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'createUser',
        };

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await repository.post(
          uri,
          headers: headers,
          body: body,
          timeout: timeout,
          metadata: metadata,
        );

        // Assert: delegación al gateway
        expect(fakeGateway.lastUri, equals(uri));
        expect(fakeGateway.lastHeadersPost, equals(headers));
        expect(fakeGateway.lastBodyPost, equals(body));
        expect(fakeGateway.lastTimeoutPost, equals(timeout));
        expect(fakeGateway.lastMetadataPost, equals(metadata));

        // Assert: resultado Right con config correcta
        expect(result, isA<Right<ErrorItem, ModelConfigHttpRequest>>());
        final Right<ErrorItem, ModelConfigHttpRequest> right =
            result as Right<ErrorItem, ModelConfigHttpRequest>;
        final ModelConfigHttpRequest config = right.value;

        expect(config.method, equals(HttpMethodEnum.post));
        expect(config.uri, equals(uri));
        expect(config.headers, equals(headers));
        expect(config.timeout, equals(timeout));
        expect(config.metadata, equals(metadata));

        // Body normalizado (en este caso Map → se mantiene equivalente)
        expect(config.body['name'], equals('Alice'));
        expect(config.body['age'], equals(30));
        expect(config.body['active'], equals(true));
      },
    );

    test(
      'Given gateway devuelve Left '
      'When post es invocado '
      'Then repo devuelve Left con el mismo ErrorItem',
      () async {
        // Arrange
        const ErrorItem gatewayError = ErrorItem(
          title: 'Payload error',
          code: 'INVALID_BODY',
          description: 'Missing required fields',
          errorLevel: ErrorLevelEnum.warning,
        );

        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest()
          ..forcedPostResult =
              Left<ErrorItem, Map<String, dynamic>>(gatewayError);

        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Uri uri = Uri.parse('https://api.example.com/users');

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await repository.post(uri);

        // Assert
        expect(result, isA<Left<ErrorItem, ModelConfigHttpRequest>>());
        final Left<ErrorItem, ModelConfigHttpRequest> left =
            result as Left<ErrorItem, ModelConfigHttpRequest>;
        expect(left.value, same(gatewayError));
      },
    );

    test(
      'Given body vacío '
      'When post es invocado '
      'Then config.body es un Map vacío',
      () async {
        // Arrange
        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest();
        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Uri uri = Uri.parse('https://api.example.com/empty-body');

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await repository.post(
          uri,
        );

        // Assert
        expect(result, isA<Right<ErrorItem, ModelConfigHttpRequest>>());
        final ModelConfigHttpRequest config =
            (result as Right<ErrorItem, ModelConfigHttpRequest>).value;
        expect(config.body, isEmpty);
      },
    );
  });

  group('RepositoryHttpRequestImpl - PUT', () {
    test(
      'Given gateway devuelve Right '
      'When put es invocado '
      'Then devuelve Right con ModelConfigHttpRequest con method PUT y body normalizado',
      () async {
        // Arrange
        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest();
        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Uri uri = Uri.parse('https://api.example.com/users/1');
        final Map<String, String> headers = <String, String>{
          'Content-Type': 'application/json',
        };
        final Map<String, dynamic> body = <String, dynamic>{
          'name': 'Bob',
          'age': 40,
        };
        const Duration timeout = Duration(seconds: 4);
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'updateUser',
        };

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await repository.put(
          uri,
          headers: headers,
          body: body,
          timeout: timeout,
          metadata: metadata,
        );

        // Assert delegación
        expect(fakeGateway.lastUri, equals(uri));
        expect(fakeGateway.lastHeadersPut, equals(headers));
        expect(fakeGateway.lastBodyPut, equals(body));
        expect(fakeGateway.lastTimeoutPut, equals(timeout));
        expect(fakeGateway.lastMetadataPut, equals(metadata));

        // Assert config
        expect(result, isA<Right<ErrorItem, ModelConfigHttpRequest>>());
        final ModelConfigHttpRequest config =
            (result as Right<ErrorItem, ModelConfigHttpRequest>).value;

        expect(config.method, equals(HttpMethodEnum.put));
        expect(config.uri, equals(uri));
        expect(config.headers, equals(headers));
        expect(config.timeout, equals(timeout));
        expect(config.metadata, equals(metadata));
        expect(config.body['name'], equals('Bob'));
        expect(config.body['age'], equals(40));
      },
    );

    test(
      'Given gateway devuelve Left '
      'When put es invocado '
      'Then repo devuelve Left propagando el ErrorItem',
      () async {
        // Arrange
        const ErrorItem gatewayError = ErrorItem(
          title: 'PUT error',
          code: 'PUT_FAIL',
          description: 'Something went wrong',
          errorLevel: ErrorLevelEnum.severe,
        );

        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest()
          ..forcedPutResult =
              Left<ErrorItem, Map<String, dynamic>>(gatewayError);

        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Uri uri = Uri.parse('https://api.example.com/users/1');

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await repository.put(uri);

        // Assert
        expect(result, isA<Left<ErrorItem, ModelConfigHttpRequest>>());
        final Left<ErrorItem, ModelConfigHttpRequest> left =
            result as Left<ErrorItem, ModelConfigHttpRequest>;
        expect(left.value, same(gatewayError));
      },
    );
  });

  group('RepositoryHttpRequestImpl - DELETE', () {
    test(
      'Given gateway devuelve Right '
      'When delete es invocado '
      'Then devuelve Right con ModelConfigHttpRequest con method DELETE',
      () async {
        // Arrange
        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest();
        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Uri uri = Uri.parse('https://api.example.com/users/1');
        final Map<String, String> headers = <String, String>{
          'Authorization': 'Bearer token',
        };
        const Duration timeout = Duration(seconds: 1);
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'deleteUser',
        };

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await repository.delete(
          uri,
          headers: headers,
          timeout: timeout,
          metadata: metadata,
        );

        // Assert delegación
        expect(fakeGateway.lastUri, equals(uri));
        expect(fakeGateway.lastHeadersDelete, equals(headers));
        expect(fakeGateway.lastTimeoutDelete, equals(timeout));
        expect(fakeGateway.lastMetadataDelete, equals(metadata));

        // Assert config
        expect(result, isA<Right<ErrorItem, ModelConfigHttpRequest>>());
        final ModelConfigHttpRequest config =
            (result as Right<ErrorItem, ModelConfigHttpRequest>).value;

        expect(config.method, equals(HttpMethodEnum.delete));
        expect(config.uri, equals(uri));
        expect(config.headers, equals(headers));
        expect(config.timeout, equals(timeout));
        expect(config.metadata, equals(metadata));
        expect(config.body, isEmpty); // DELETE no usa body
      },
    );

    test(
      'Given gateway devuelve Left '
      'When delete es invocado '
      'Then repo devuelve Left con el mismo ErrorItem',
      () async {
        // Arrange
        const ErrorItem gatewayError = ErrorItem(
          title: 'DELETE error',
          code: 'DELETE_FAIL',
          description: 'Cannot delete',
          errorLevel: ErrorLevelEnum.warning,
        );

        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest()
          ..forcedDeleteResult =
              Left<ErrorItem, Map<String, dynamic>>(gatewayError);

        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Uri uri = Uri.parse('https://api.example.com/users/1');

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await repository.delete(uri);

        // Assert
        expect(result, isA<Left<ErrorItem, ModelConfigHttpRequest>>());
        final Left<ErrorItem, ModelConfigHttpRequest> left =
            result as Left<ErrorItem, ModelConfigHttpRequest>;
        expect(left.value, same(gatewayError));
      },
    );
  });
  group('RepositoryHttpRequestImpl.normalizeBody', () {
    test(
      'Given body == null '
      'When normalizeBody is called '
      'Then returns an empty Map<String, dynamic>',
      () {
        // Arrange
        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest();
        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        // Act
        final Map<String, dynamic> result = repository.normalizeBody(null);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result, isEmpty);
      },
    );

    test(
      'Given body is a Map '
      'When normalizeBody is called '
      'Then returns a Map<String, dynamic> normalized via Utils.mapFromDynamic',
      () {
        // Arrange
        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest();
        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        final Map<String, dynamic> body = <String, dynamic>{
          'name': 'Alice',
          'age': 30,
          'nested': <String, dynamic>{'active': true},
        };

        // Act
        final Map<String, dynamic> result = repository.normalizeBody(body);

        // Assert básico (estructura equivalente)
        expect(result['name'], equals('Alice'));
        expect(result['age'], equals(30));
        expect(result['nested'], isA<Map<String, dynamic>>());
        expect(
          (result['nested'] as Map<String, dynamic>)['active'],
          equals(true),
        );
      },
    );

    test(
      'Given body is not a Map (e.g. String/int/etc.) '
      'When normalizeBody is called '
      'Then wraps the value into {"value": body}',
      () {
        // Arrange
        final _FakeGatewayHttpRequest fakeGateway = _FakeGatewayHttpRequest();
        final RepositoryHttpRequestImpl repository =
            RepositoryHttpRequestImpl(fakeGateway);

        const String body = 'raw-payload';

        // Act
        final Map<String, dynamic> result = repository.normalizeBody(body);

        // Assert
        expect(result.length, equals(1));
        expect(result['value'], equals(body));
      },
    );
  });
}
