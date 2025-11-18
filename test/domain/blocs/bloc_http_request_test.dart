import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class _DummyRepositoryHttpRequest implements RepositoryHttpRequest {
  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> get(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> post(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> put(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> delete(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    throw UnimplementedError();
  }
}

// GET
class _FakeUsecaseHttpRequestGet extends UsecaseHttpRequestGet {
  _FakeUsecaseHttpRequestGet() : super(_DummyRepositoryHttpRequest());

  Either<ErrorItem, ModelConfigHttpRequest> result =
      Right<ErrorItem, ModelConfigHttpRequest>(
    ModelConfigHttpRequest(
      method: HttpMethodEnum.get,
      uri: Uri.parse('https://example.com/get'),
    ),
  );

  bool delay = false;

  Uri? lastUri;
  Map<String, String>? lastHeaders;
  Duration? lastTimeout;
  Map<String, dynamic>? lastMetadata;

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    lastUri = uri;
    lastHeaders = headers;
    lastTimeout = timeout;
    lastMetadata = metadata;
    if (delay) {
      await Future<void>.delayed(Duration.zero);
    }
    return result;
  }
}

// POST
class _FakeUsecaseHttpRequestPost extends UsecaseHttpRequestPost {
  _FakeUsecaseHttpRequestPost() : super(_DummyRepositoryHttpRequest());

  Either<ErrorItem, ModelConfigHttpRequest> result =
      Right<ErrorItem, ModelConfigHttpRequest>(
    ModelConfigHttpRequest(
      method: HttpMethodEnum.post,
      uri: Uri.parse('https://example.com/post'),
    ),
  );

  bool delay = false;

  Uri? lastUri;
  Map<String, String>? lastHeaders;
  Map<String, dynamic>? lastBody;
  Duration? lastTimeout;
  Map<String, dynamic>? lastMetadata;

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    lastUri = uri;
    lastHeaders = headers;
    lastBody = body;
    lastTimeout = timeout;
    lastMetadata = metadata;
    if (delay) {
      await Future<void>.delayed(Duration.zero);
    }
    return result;
  }
}

// PUT
class _FakeUsecaseHttpRequestPut extends UsecaseHttpRequestPut {
  _FakeUsecaseHttpRequestPut() : super(_DummyRepositoryHttpRequest());

  Either<ErrorItem, ModelConfigHttpRequest> result =
      Right<ErrorItem, ModelConfigHttpRequest>(
    ModelConfigHttpRequest(
      method: HttpMethodEnum.put,
      uri: Uri.parse('https://example.com/put'),
    ),
  );

  bool delay = false;

  Uri? lastUri;
  Map<String, String>? lastHeaders;
  Map<String, dynamic>? lastBody;
  Duration? lastTimeout;
  Map<String, dynamic>? lastMetadata;

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    lastUri = uri;
    lastHeaders = headers;
    lastBody = body;
    lastTimeout = timeout;
    lastMetadata = metadata;
    if (delay) {
      await Future<void>.delayed(Duration.zero);
    }
    return result;
  }
}

// DELETE
class _FakeUsecaseHttpRequestDelete extends UsecaseHttpRequestDelete {
  _FakeUsecaseHttpRequestDelete() : super(_DummyRepositoryHttpRequest());

  Either<ErrorItem, ModelConfigHttpRequest> result =
      Right<ErrorItem, ModelConfigHttpRequest>(
    ModelConfigHttpRequest(
      method: HttpMethodEnum.delete,
      uri: Uri.parse('https://example.com/delete'),
    ),
  );

  bool delay = false;

  Uri? lastUri;
  Map<String, String>? lastHeaders;
  Duration? lastTimeout;
  Map<String, dynamic>? lastMetadata;

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    lastUri = uri;
    lastHeaders = headers;
    lastTimeout = timeout;
    lastMetadata = metadata;
    if (delay) {
      await Future<void>.delayed(Duration.zero);
    }
    return result;
  }
}

// RETRY
class _FakeUsecaseHttpRequestRetry extends UsecaseHttpRequestRetry {
  _FakeUsecaseHttpRequestRetry() : super(_DummyRepositoryHttpRequest());

  Either<ErrorItem, ModelConfigHttpRequest> result =
      Right<ErrorItem, ModelConfigHttpRequest>(
    ModelConfigHttpRequest(
      method: HttpMethodEnum.get,
      uri: Uri.parse('https://example.com/retry'),
    ),
  );

  bool delay = false;

  ModelConfigHttpRequest? lastPreviousConfig;
  Map<String, dynamic>? lastExtraMetadata;

  @override
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    ModelConfigHttpRequest previousConfig, {
    Map<String, dynamic> extraMetadata = const <String, dynamic>{},
  }) async {
    lastPreviousConfig = previousConfig;
    lastExtraMetadata = extraMetadata;
    if (delay) {
      await Future<void>.delayed(Duration.zero);
    }
    return result;
  }
}

void main() {
  group('BlocHttpRequest - estado inicial y helpers básicos', () {
    test(
      'Given un BlocHttpRequest recién creado '
      'When se inspecciona el estado '
      'Then no tiene requests activos y hasActiveRequests es false',
      () {
        // Arrange
        final _FakeUsecaseHttpRequestGet fakeGet = _FakeUsecaseHttpRequestGet();
        final _FakeUsecaseHttpRequestPost fakePost =
            _FakeUsecaseHttpRequestPost();
        final _FakeUsecaseHttpRequestPut fakePut = _FakeUsecaseHttpRequestPut();
        final _FakeUsecaseHttpRequestDelete fakeDelete =
            _FakeUsecaseHttpRequestDelete();
        final _FakeUsecaseHttpRequestRetry fakeRetry =
            _FakeUsecaseHttpRequestRetry();

        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: fakeGet,
          post: fakePost,
          put: fakePut,
          delete: fakeDelete,
          retry: fakeRetry,
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        // Assert
        expect(bloc.activeRequests, isEmpty);
        expect(bloc.hasActiveRequests, isFalse);
      },
    );
  });

  group('BlocHttpRequest - tracking de GET', () {
    test(
      'Given un GET con delay '
      'When se invoca get '
      'Then requestKey se marca activo mientras está en vuelo y se limpia al terminar',
      () async {
        // Arrange
        final _FakeUsecaseHttpRequestGet fakeGet = _FakeUsecaseHttpRequestGet()
          ..delay = true;
        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: fakeGet,
          post: _FakeUsecaseHttpRequestPost(),
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        const String requestKey = 'userProfile.fetchMe';
        final Uri uri = Uri.parse('https://api.example.com/v1/users/me');
        final Map<String, dynamic> metadata = <String, dynamic>{
          'feature': 'userProfile',
        };

        // Act
        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future =
            bloc.get(
          requestKey: requestKey,
          uri: uri,
          metadata: metadata,
        );

        // Mientras está corriendo
        expect(bloc.hasActiveRequests, isTrue);
        expect(bloc.isActive(requestKey), isTrue);

        final Either<ErrorItem, ModelConfigHttpRequest> result = await future;

        // Assert final
        expect(result, isA<Right<ErrorItem, ModelConfigHttpRequest>>());
        expect(bloc.hasActiveRequests, isFalse);
        expect(bloc.isActive(requestKey), isFalse);

        // Delegación a fakeGet
        expect(fakeGet.lastUri, equals(uri));
        expect(fakeGet.lastMetadata, equals(metadata));
      },
    );
  });

  group('BlocHttpRequest - POST/PUT/DELETE tracking y errores', () {
    test(
      'Given un POST exitoso '
      'When post es invocado '
      'Then requestKey se marca activo y luego inactivo, y el Right se propaga',
      () async {
        // Arrange
        final _FakeUsecaseHttpRequestPost fakePost =
            _FakeUsecaseHttpRequestPost()..delay = true;
        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: _FakeUsecaseHttpRequestGet(),
          post: fakePost,
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        const String requestKey = 'users.create';
        final Uri uri = Uri.parse('https://api.example.com/users');
        final Map<String, String> headers = <String, String>{
          'Content-Type': 'application/json',
        };
        final Map<String, dynamic> body = <String, dynamic>{'name': 'Alice'};

        // Act
        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future =
            bloc.post(
          requestKey: requestKey,
          uri: uri,
          headers: headers,
          body: body,
        );

        expect(bloc.hasActiveRequests, isTrue);
        expect(bloc.isActive(requestKey), isTrue);

        final Either<ErrorItem, ModelConfigHttpRequest> result = await future;

        // Assert
        expect(result, isA<Right<ErrorItem, ModelConfigHttpRequest>>());
        expect(bloc.hasActiveRequests, isFalse);
        expect(bloc.isActive(requestKey), isFalse);

        expect(fakePost.lastUri, equals(uri));
        expect(fakePost.lastHeaders, equals(headers));
        expect(fakePost.lastBody, equals(body));
      },
    );

    test(
      'Given fakePost.result = Left '
      'When post es invocado '
      'Then BlocHttpRequest devuelve Left con el mismo ErrorItem',
      () async {
        // Arrange
        const ErrorItem error = ErrorItem(
          title: 'Validation error',
          code: 'INVALID_DATA',
          description: 'Missing fields',
          errorLevel: ErrorLevelEnum.warning,
        );

        final _FakeUsecaseHttpRequestPost fakePost =
            _FakeUsecaseHttpRequestPost()
              ..result = Left<ErrorItem, ModelConfigHttpRequest>(error);

        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: _FakeUsecaseHttpRequestGet(),
          post: fakePost,
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        // Act
        final Either<ErrorItem, ModelConfigHttpRequest> result =
            await bloc.post(
          requestKey: 'users.create',
          uri: Uri.parse('https://api.example.com/users'),
        );

        // Assert
        expect(result, isA<Left<ErrorItem, ModelConfigHttpRequest>>());
        final Left<ErrorItem, ModelConfigHttpRequest> left =
            result as Left<ErrorItem, ModelConfigHttpRequest>;
        expect(left.value, same(error));
      },
    );

    test(
      'Given un PUT exitoso '
      'When put es invocado '
      'Then se trackea el requestKey y se propaga el Right',
      () async {
        // Arrange
        final _FakeUsecaseHttpRequestPut fakePut = _FakeUsecaseHttpRequestPut()
          ..delay = true;

        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: _FakeUsecaseHttpRequestGet(),
          post: _FakeUsecaseHttpRequestPost(),
          put: fakePut,
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        const String requestKey = 'users.update';
        final Uri uri = Uri.parse('https://api.example.com/users/1');

        // Act
        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future =
            bloc.put(
          requestKey: requestKey,
          uri: uri,
          body: const <String, dynamic>{'name': 'Bob'},
        );

        expect(bloc.hasActiveRequests, isTrue);
        expect(bloc.isActive(requestKey), isTrue);

        final Either<ErrorItem, ModelConfigHttpRequest> result = await future;

        // Assert
        expect(result, isA<Right<ErrorItem, ModelConfigHttpRequest>>());
        expect(bloc.hasActiveRequests, isFalse);
        expect(bloc.isActive(requestKey), isFalse);
        expect(fakePut.lastUri, equals(uri));
      },
    );

    test(
      'Given fakeDelete.result = Left '
      'When delete es invocado '
      'Then devuelve Left y el requestKey termina inactivo',
      () async {
        // Arrange
        const ErrorItem error = ErrorItem(
          title: 'Delete error',
          code: 'DELETE_FAIL',
          description: 'Cannot delete',
          errorLevel: ErrorLevelEnum.severe,
        );

        final _FakeUsecaseHttpRequestDelete fakeDelete =
            _FakeUsecaseHttpRequestDelete()
              ..delay = true
              ..result = Left<ErrorItem, ModelConfigHttpRequest>(error);

        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: _FakeUsecaseHttpRequestGet(),
          post: _FakeUsecaseHttpRequestPost(),
          put: _FakeUsecaseHttpRequestPut(),
          delete: fakeDelete,
          retry: _FakeUsecaseHttpRequestRetry(),
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        const String requestKey = 'users.delete';
        final Uri uri = Uri.parse('https://api.example.com/users/1');

        // Act
        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future =
            bloc.delete(
          requestKey: requestKey,
          uri: uri,
        );

        expect(bloc.hasActiveRequests, isTrue);
        expect(bloc.isActive(requestKey), isTrue);

        final Either<ErrorItem, ModelConfigHttpRequest> result = await future;

        // Assert
        expect(result, isA<Left<ErrorItem, ModelConfigHttpRequest>>());
        expect(bloc.hasActiveRequests, isFalse);
        expect(bloc.isActive(requestKey), isFalse);
      },
    );
  });

  group('BlocHttpRequest - retry', () {
    test(
      'Given un retry exitoso '
      'When retry es invocado '
      'Then se trackea el requestKey y se propaga el resultado',
      () async {
        // Arrange
        final _FakeUsecaseHttpRequestRetry fakeRetry =
            _FakeUsecaseHttpRequestRetry()..delay = true;

        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: _FakeUsecaseHttpRequestGet(),
          post: _FakeUsecaseHttpRequestPost(),
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: fakeRetry,
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        const String requestKey = 'users.retryFetch';
        final ModelConfigHttpRequest previousConfig = ModelConfigHttpRequest(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://api.example.com/users/1'),
          metadata: const <String, dynamic>{'feature': 'userProfile'},
        );

        final Map<String, dynamic> extraMetadata = <String, dynamic>{
          'retryReason': 'timeout',
        };

        // Act
        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future =
            bloc.retry(
          requestKey: requestKey,
          previousConfig: previousConfig,
          extraMetadata: extraMetadata,
        );

        expect(bloc.hasActiveRequests, isTrue);
        expect(bloc.isActive(requestKey), isTrue);

        final Either<ErrorItem, ModelConfigHttpRequest> result = await future;

        // Assert
        expect(result, isA<Right<ErrorItem, ModelConfigHttpRequest>>());
        expect(bloc.hasActiveRequests, isFalse);
        expect(bloc.isActive(requestKey), isFalse);

        expect(fakeRetry.lastPreviousConfig, same(previousConfig));
        expect(fakeRetry.lastExtraMetadata, equals(extraMetadata));
      },
    );
  });

  group('BlocHttpRequest - clear / clearAll', () {
    test(
      'Given un request en vuelo '
      'When clear se llama con su requestKey '
      'Then se remueve del set y _markInactive no lo vuelve a agregar',
      () async {
        // Arrange
        final _FakeUsecaseHttpRequestGet fakeGet = _FakeUsecaseHttpRequestGet()
          ..delay = true;
        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: fakeGet,
          post: _FakeUsecaseHttpRequestPost(),
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        const String requestKey = 'users.list';
        final Uri uri = Uri.parse('https://api.example.com/users');

        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future =
            bloc.get(
          requestKey: requestKey,
          uri: uri,
        );

        expect(bloc.isActive(requestKey), isTrue);

        // Act
        bloc.clear(requestKey);

        // Assert
        expect(bloc.isActive(requestKey), isFalse);
        expect(bloc.hasActiveRequests, isFalse);

        await future;
        expect(bloc.isActive(requestKey), isFalse);
        expect(bloc.hasActiveRequests, isFalse);
      },
    );

    test(
      'Given dos requests en vuelo '
      'When clearAll es llamado '
      'Then el set queda vacío y las terminaciones posteriores no los activan',
      () async {
        // Arrange
        final _FakeUsecaseHttpRequestGet fakeGet = _FakeUsecaseHttpRequestGet()
          ..delay = true;
        final _FakeUsecaseHttpRequestPost fakePost =
            _FakeUsecaseHttpRequestPost()..delay = true;

        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: fakeGet,
          post: fakePost,
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future1 =
            bloc.get(
          requestKey: 'users.list',
          uri: Uri.parse('https://api.example.com/users'),
        );

        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future2 =
            bloc.post(
          requestKey: 'orders.create',
          uri: Uri.parse('https://api.example.com/orders'),
          body: const <String, dynamic>{'amount': 10},
        );

        expect(bloc.hasActiveRequests, isTrue);
        expect(bloc.activeRequests.length, equals(2));

        // Act
        bloc.clearAll();

        // Assert
        expect(bloc.activeRequests, isEmpty);
        expect(bloc.hasActiveRequests, isFalse);

        await Future.wait(<Future<dynamic>>[future1, future2]);
        expect(bloc.activeRequests, isEmpty);
        expect(bloc.hasActiveRequests, isFalse);
      },
    );
  });

  group('BlocHttpRequest - wiring con BlocGeneral', () {
    test(
      'Given se registra una función en el stream '
      'When executeNow=true '
      'Then la función se ejecuta al menos una vez y queda registrada',
      () async {
        // Arrange
        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: _FakeUsecaseHttpRequestGet(),
          post: _FakeUsecaseHttpRequestPost(),
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );
        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        final List<Set<String>> notifications = <Set<String>>[];

        // Act
        bloc.addFunctionToProcessActiveRequestsOnStream(
          'logger',
          (Set<String> active) {
            notifications.add(active);
          },
          true,
        );

        // Assert básico
        expect(bloc.containsKeyFunction('logger'), isTrue);
        expect(notifications, isNotEmpty);
        expect(notifications.first, equals(<String>{}));

        // Disparamos un cambio
        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future =
            bloc.get(
          requestKey: 'test.request',
          uri: Uri.parse('https://api.example.com/test'),
        );
        await future;

        expect(
          notifications.any(
            (Set<String> s) => s.contains('test.request'),
          ),
          isTrue,
        );
      },
    );

    test(
      'Given una función registrada '
      'When deleteFunctionToProcessActiveRequestsOnStream es llamada '
      'Then la función deja de estar registrada',
      () {
        // Arrange
        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: _FakeUsecaseHttpRequestGet(),
          post: _FakeUsecaseHttpRequestPost(),
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );
        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        bloc.addFunctionToProcessActiveRequestsOnStream(
          'logger',
          (_) {},
        );
        expect(bloc.containsKeyFunction('logger'), isTrue);

        // Act
        bloc.deleteFunctionToProcessActiveRequestsOnStream('logger');

        // Assert
        expect(bloc.containsKeyFunction('logger'), isFalse);
      },
    );

    test(
      'Given un BlocHttpRequest '
      'When dispose es invocado '
      'Then no lanza',
      () {
        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: _FakeUsecaseHttpRequestGet(),
          post: _FakeUsecaseHttpRequestPost(),
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );
        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        expect(() => bloc.dispose(), returnsNormally);
      },
    );
  });
  group('BlocHttpRequest - stream de Set<String>', () {
    test(
      'Given un listener suscrito al stream '
      'When se ejecuta un GET con delay '
      'Then el stream emite un set con el requestKey activo y luego un set sin él',
      () async {
        // Arrange
        final _FakeUsecaseHttpRequestGet fakeGet = _FakeUsecaseHttpRequestGet()
          ..delay = true;

        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: fakeGet,
          post: _FakeUsecaseHttpRequestPost(),
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        const String requestKey = 'userProfile.fetchMe';
        final Uri uri = Uri.parse('https://api.example.com/v1/users/me');

        final List<Set<String>> emissions = <Set<String>>[];

        // Nos suscribimos al stream
        final StreamSubscription<Set<String>> sub =
            bloc.stream.listen(emissions.add);

        // Act: lanzamos la petición
        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future =
            bloc.get(
          requestKey: requestKey,
          uri: uri,
        );

        // Esperamos a que termine
        await future;
        await Future<void>.delayed(
          Duration.zero,
        ); // aseguramos flush del stream

        await sub.cancel();

        // Assert: debe haber al menos un estado con la key activa
        expect(
          emissions.any((Set<String> s) => s.contains(requestKey)),
          isTrue,
          reason: 'El stream nunca emitió el requestKey activo',
        );

        // Y al menos un estado final sin la key
        expect(
          emissions.any((Set<String> s) => !s.contains(requestKey)),
          isTrue,
          reason: 'El stream nunca emitió un estado sin el requestKey',
        );
      },
    );

    test(
      'Given dos requests en paralelo '
      'When se observan las emisiones del stream '
      'Then en algún punto contiene ambos keys y termina vacío',
      () async {
        // Arrange
        final _FakeUsecaseHttpRequestGet fakeGet = _FakeUsecaseHttpRequestGet()
          ..delay = true;
        final _FakeUsecaseHttpRequestPost fakePost =
            _FakeUsecaseHttpRequestPost()..delay = true;

        final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
          get: fakeGet,
          post: fakePost,
          put: _FakeUsecaseHttpRequestPut(),
          delete: _FakeUsecaseHttpRequestDelete(),
          retry: _FakeUsecaseHttpRequestRetry(),
        );

        final BlocHttpRequest bloc = BlocHttpRequest(facade);

        const String key1 = 'users.list';
        const String key2 = 'orders.create';

        final Uri uri1 = Uri.parse('https://api.example.com/users');
        final Uri uri2 = Uri.parse('https://api.example.com/orders');

        final List<Set<String>> emissions = <Set<String>>[];
        final StreamSubscription<Set<String>> sub =
            bloc.stream.listen(emissions.add);

        // Act: lanzamos dos requests en paralelo
        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future1 =
            bloc.get(
          requestKey: key1,
          uri: uri1,
        );

        final Future<Either<ErrorItem, ModelConfigHttpRequest>> future2 =
            bloc.post(
          requestKey: key2,
          uri: uri2,
          body: const <String, dynamic>{'amount': 10},
        );

        await Future.wait(<Future<dynamic>>[future1, future2]);
        await Future<void>.delayed(Duration.zero); // flush de emisiones
        await sub.cancel();

        // Assert: al menos una emisión con ambos keys activos
        expect(
          emissions.any(
            (Set<String> s) => s.contains(key1) && s.contains(key2),
          ),
          isTrue,
          reason:
              'El stream nunca emitió un estado donde ambos requestKeys estuvieran activos',
        );

        // Y debe terminar vacío (última emisión sin keys)
        expect(emissions, isNotEmpty);
        expect(emissions.last, equals(<String>{}));
      },
    );
  });
}
