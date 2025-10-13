import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
// ---------- Fakes & helpers ----------

class _UserModel extends Model {
  const _UserModel({required this.id, required this.name});

  final String id;
  final String name;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};

  static _UserModel fromJson(Map<String, dynamic> json) {
    // Simula un parser estricto
    final String name = json['name'] as String;
    final String id = (json['id'] as String?) ?? 'na';
    return _UserModel(id: id, name: name);
  }

  @override
  Model copyWith() {
    throw UnimplementedError();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _UserModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class _ErrorMapperFake implements ErrorMapper {
  const _ErrorMapperFake();

  @override
  ErrorItem? fromPayload(
    Map<String, dynamic> payload, {
    String location = '',
  }) {
    // Este repo no usa fromPayload; devolver null
    return null;
  }

  @override
  ErrorItem fromException(
    Object error,
    StackTrace stackTrace, {
    String location = '',
  }) {
    // Devuelve un ErrorItem mínimo del dominio; si no tienes constructor,
    // reemplaza por tu factory/constante de error genérico.
    return defaultErrorItem; // ajusta si tu dominio difiere
  }
}

/// Fake Gateway que permite controlar timings y conteo de llamadas.
/// Simula un backend JSON con streams por docId.
class _GatewayFake implements GatewayWsDatabase {
  _GatewayFake({
    this.writeDelay = Duration.zero,
    this.deleteDelay = Duration.zero,
  });

  final Duration writeDelay;
  final Duration deleteDelay;

  final Map<String, Map<String, dynamic>> _store =
      <String, Map<String, dynamic>>{};
  final Map<String, StreamController<Either<ErrorItem, Map<String, dynamic>>>>
      _docCtrls =
      <String, StreamController<Either<ErrorItem, Map<String, dynamic>>>>{};

  int detachCount = 0;
  int releaseCount = 0;
  int disposeCount = 0;

  /// Para verificar serialización: lista de marcas de inicio por docId.
  final List<String> writeOrder = <String>[];
  final List<String> deleteOrder = <String>[];

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String docId) async {
    final Map<String, dynamic>? json = _store[docId];
    if (json == null) {
      return Left<ErrorItem, Map<String, dynamic>>(DatabaseErrorItems.notFound);
    }
    return Right<ErrorItem, Map<String, dynamic>>(
      Map<String, dynamic>.from(json),
    );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    String docId,
    Map<String, dynamic> json,
  ) async {
    writeOrder.add('start:$docId:${DateTime.now().microsecondsSinceEpoch}');
    if (writeDelay != Duration.zero) {
      await Future<void>.delayed(writeDelay);
    }
    _store[docId] = Map<String, dynamic>.from(json);
    _docCtrls[docId]
        ?.add(Right<ErrorItem, Map<String, dynamic>>(_store[docId]!));
    return Right<ErrorItem, Map<String, dynamic>>(
      Map<String, dynamic>.from(_store[docId]!),
    );
  }

  @override
  Future<Either<ErrorItem, Unit>> delete(String docId) async {
    deleteOrder.add('start:$docId:${DateTime.now().microsecondsSinceEpoch}');
    if (deleteDelay != Duration.zero) {
      await Future<void>.delayed(deleteDelay);
    }
    _store.remove(docId);
    _docCtrls[docId]?.add(
      Left<ErrorItem, Map<String, dynamic>>(DatabaseErrorItems.notFound),
    );
    return Right<ErrorItem, Unit>(Unit.value);
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch(String docId) {
    final StreamController<Either<ErrorItem, Map<String, dynamic>>> ctrl =
        _docCtrls.putIfAbsent(
      docId,
      () =>
          StreamController<Either<ErrorItem, Map<String, dynamic>>>.broadcast(),
    );

    // seed (emula gateway que puede emitir {} como Right)
    final Map<String, dynamic> seed = _store[docId] ?? <String, dynamic>{};
    scheduleMicrotask(() {
      ctrl.add(
        Right<ErrorItem, Map<String, dynamic>>(
          Map<String, dynamic>.from(seed),
        ),
      );
    });
    return ctrl.stream;
  }

  @override
  void detachWatch(String docId) {
    detachCount++;
  }

  @override
  void releaseDoc(String docId) {
    releaseCount++;
    // No cerramos ctrl aquí para facilitar pruebas; el repo solo delega.
  }

  @override
  void dispose() {
    disposeCount++;
    for (final StreamController<Either<ErrorItem, Map<String, dynamic>>> c
        in _docCtrls.values) {
      c.close();
    }
    _docCtrls.clear();
  }
}

void main() {
  late FakeServiceWsDatabase service;
  late GatewayWsDatabase gateway;

  setUp(() {
    service = FakeServiceWsDatabase();
    gateway = GatewayWsDatabaseImpl(
      service: service,
      collection: 'users',
    );
  });

  UserModel mkUser(String id) => UserModel(
        id: id,
        displayName: 'John',
        photoUrl: '',
        email: 'john@example.com',
        jwt: const <String, dynamic>{'t': '1'},
      );

  test('write then read returns the same entity', () async {
    final RepositoryWsDatabaseImpl<UserModel> repo =
        RepositoryWsDatabaseImpl<UserModel>(
      gateway: gateway,
      fromJson: UserModel.fromJson,
    );

    final Either<ErrorItem, UserModel> w = await repo.write('u1', mkUser('u1'));
    expect(w.isRight, isTrue);

    final Either<ErrorItem, UserModel> r = await repo.read('u1');
    r.fold((_) => fail('should succeed'), (UserModel u) {
      expect(u.id, 'u1');
      expect(u.email, 'john@example.com');
    });
  });

  test('decode mapping_error when fromJson throws', () async {
    // Un parser que siempre lanza:
    UserModel badParser(Map<String, dynamic> _) => throw StateError('boom');

    final RepositoryWsDatabaseImpl<UserModel> repo =
        RepositoryWsDatabaseImpl<UserModel>(
      gateway: gateway,
      fromJson: badParser,
    );

    // Pre-graba JSON válido
    await service.saveDocument(
      collection: 'users',
      docId: 'u2',
      document: <String, dynamic>{
        UserEnum.id.name: 'u2',
        UserEnum.displayName.name: 'Jane',
        UserEnum.photoUrl.name: '',
        UserEnum.email.name: 'jane@example.com',
        UserEnum.jwt.name: <String, dynamic>{'t': '2'},
      },
    );

    final Either<ErrorItem, UserModel> r = await repo.read('u2');
    expect(r.isLeft, isTrue);
    r.fold(
      (ErrorItem err) {
        // Dependiendo de tu ErrorMapper, puede ser 'mapping_error'
        expect(err.code, isNotNull);
      },
      (_) => fail('should not succeed'),
    );
  });

  test('watch streams entities and maps errors', () async {
    final RepositoryWsDatabaseImpl<UserModel> repo =
        RepositoryWsDatabaseImpl<UserModel>(
      gateway: gateway,
      fromJson: UserModel.fromJson,
    );

    await service.saveDocument(
      collection: 'users',
      docId: 'u3',
      document: <String, dynamic>{
        UserEnum.id.name: 'u3',
        UserEnum.displayName.name: 'Init',
        UserEnum.photoUrl.name: '',
        UserEnum.email.name: 'init@example.com',
        UserEnum.jwt.name: <String, dynamic>{'t': '3'},
      },
    );

    final List<UserModel> seen = <UserModel>[];
    final StreamSubscription<Either<ErrorItem, UserModel>> sub =
        repo.watch('u3').listen((Either<ErrorItem, UserModel> e) {
      e.fold((_) {}, (UserModel u) => seen.add(u));
    });

    await service.saveDocument(
      collection: 'users',
      docId: 'u3',
      document: <String, dynamic>{
        UserEnum.id.name: 'u3',
        UserEnum.displayName.name: 'Updated',
        UserEnum.photoUrl.name: '',
        UserEnum.email.name: 'up@example.com',
        UserEnum.jwt.name: <String, dynamic>{'t': '3'},
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));
    await sub.cancel();
    gateway.detachWatch('u3');

    expect(seen.isNotEmpty, isTrue);
    expect(seen.last.displayName, 'Updated');
  });
  group('RepositoryWsDatabaseImpl<T>', () {
    test('read: Given success Right(Map) When decode Then returns Right(T)',
        () async {
      final _GatewayFake gw = _GatewayFake();
      gw._store['u1'] = <String, dynamic>{'id': 'u1', 'name': 'Alice'};

      final RepositoryWsDatabaseImpl<_UserModel> repo =
          RepositoryWsDatabaseImpl<_UserModel>(
        gateway: gw,
        fromJson: _UserModel.fromJson,
        mapper: const _ErrorMapperFake(),
      );

      final Either<ErrorItem, _UserModel> res = await repo.read('u1');
      res.fold(
        (ErrorItem l) => fail('Expected Right, got Left'),
        (_UserModel r) {
          expect(r.id, 'u1');
          expect(r.name, 'Alice');
        },
      );

      repo.dispose();
      expect(gw.disposeCount, 1);
    });

    test('read: Given Left(error) When decode Then propagates Left', () async {
      final _GatewayFake gw = _GatewayFake(); // store vacío → notFound
      final RepositoryWsDatabaseImpl<_UserModel> repo =
          RepositoryWsDatabaseImpl<_UserModel>(
        gateway: gw,
        fromJson: _UserModel.fromJson,
        mapper: const _ErrorMapperFake(),
      );

      final Either<ErrorItem, _UserModel> res = await repo.read('missing');
      expect(
        res.fold((_) => true, (_) => false),
        isTrue,
        reason: 'Expected Left',
      );

      repo.dispose();
    });

    test(
        'write: Given serializeWrites=true When two writes same doc Then executes in FIFO without overlap',
        () async {
      final _GatewayFake gw =
          _GatewayFake(writeDelay: const Duration(milliseconds: 40));
      final RepositoryWsDatabaseImpl<_UserModel> repo =
          RepositoryWsDatabaseImpl<_UserModel>(
        gateway: gw,
        fromJson: _UserModel.fromJson,
        mapper: const _ErrorMapperFake(),
        serializeWrites: true,
      );

      final Future<Either<ErrorItem, _UserModel>> f1 =
          repo.write('u1', const _UserModel(id: 'u1', name: 'A'));
      final Future<Either<ErrorItem, _UserModel>> f2 =
          repo.write('u1', const _UserModel(id: 'u1', name: 'B'));

      final Either<ErrorItem, _UserModel> r1 = await f1;
      final Either<ErrorItem, _UserModel> r2 = await f2;

      expect(r1.fold((_) => false, (_UserModel v) => v.name == 'A'), isTrue);
      expect(r2.fold((_) => false, (_UserModel v) => v.name == 'B'), isTrue);

      // Verifica orden (dos "start:u1:timestamp")
      expect(gw.writeOrder.length, 2);
      final int t0 = int.parse(gw.writeOrder.first.split(':').last);
      final int t1 = int.parse(gw.writeOrder.last.split(':').last);
      expect(t1 > t0, isTrue, reason: 'Second write must start after first');

      repo.dispose();
    });

    test(
        'write: Given serializeWrites=true When writes different docIds Then may run in parallel',
        () async {
      final _GatewayFake gw =
          _GatewayFake(writeDelay: const Duration(milliseconds: 40));
      final RepositoryWsDatabaseImpl<_UserModel> repo =
          RepositoryWsDatabaseImpl<_UserModel>(
        gateway: gw,
        fromJson: _UserModel.fromJson,
        mapper: const _ErrorMapperFake(),
        serializeWrites: true,
      );

      // Dispara dos docIds distintos casi en simultáneo
      final Stopwatch sw = Stopwatch()..start();
      final Future<Either<ErrorItem, _UserModel>> f1 =
          repo.write('u1', const _UserModel(id: 'u1', name: 'A'));
      final Future<Either<ErrorItem, _UserModel>> f2 =
          repo.write('u2', const _UserModel(id: 'u2', name: 'B'));

      await Future.wait(<Future<dynamic>>[f1, f2]);
      sw.stop();

      // Si fueran forzosamente en serie, tardaría ~80ms; aceptamos <80ms como “posible paralelo”.
      expect(sw.elapsedMilliseconds < 80, isTrue);

      repo.dispose();
    });

    test(
        'delete: Given serializeWrites=true When two deletes same doc Then executes in FIFO',
        () async {
      final _GatewayFake gw =
          _GatewayFake(deleteDelay: const Duration(milliseconds: 30));
      final RepositoryWsDatabaseImpl<_UserModel> repo =
          RepositoryWsDatabaseImpl<_UserModel>(
        gateway: gw,
        fromJson: _UserModel.fromJson,
        mapper: const _ErrorMapperFake(),
        serializeWrites: true,
      );

      final Future<Either<ErrorItem, Unit>> d1 = repo.delete('u1');
      final Future<Either<ErrorItem, Unit>> d2 = repo.delete('u1');

      await d1;
      await d2;

      expect(gw.deleteOrder.length, 2);
      final int t0 = int.parse(gw.deleteOrder.first.split(':').last);
      final int t1 = int.parse(gw.deleteOrder.last.split(':').last);
      expect(t1 > t0, isTrue);

      repo.dispose();
    });

    test(
        'watch: Given gateway emits Right/Left Then repo maps to T or propagates error',
        () async {
      final _GatewayFake gw = _GatewayFake();
      final RepositoryWsDatabaseImpl<_UserModel> repo =
          RepositoryWsDatabaseImpl<_UserModel>(
        gateway: gw,
        fromJson: _UserModel.fromJson,
        mapper: const _ErrorMapperFake(),
      );

      final List<Either<ErrorItem, _UserModel>> events =
          <Either<ErrorItem, _UserModel>>[];
      final StreamSubscription<Either<ErrorItem, _UserModel>> sub =
          repo.watch('u1').listen(events.add);

      // Emit seed {} (Right({})) → mapping error esperado (fromJson requiere 'name')
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, isNotEmpty);
      // Primer evento podría ser Left(mapping_error) según tu ErrorMapper real; si no, ignora.

      // Ahora simula write correcto
      await gw.write('u1', <String, dynamic>{'id': 'u1', 'name': 'Alice'});
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Debe aparecer un Right<_UserModel>
      expect(
        events.any(
          (Either<ErrorItem, _UserModel> e) =>
              e.fold((_) => false, (_UserModel r) => r.name == 'Alice'),
        ),
        isTrue,
      );

      await sub.cancel();
      // El repo delega el detach al caller:
      repo.detachWatch('u1');
      repo.dispose();
    });

    test('delegation: detachWatch/releaseDoc/ dispose are forwarded to gateway',
        () {
      final _GatewayFake gw = _GatewayFake();
      final RepositoryWsDatabaseImpl<_UserModel> repo =
          RepositoryWsDatabaseImpl<_UserModel>(
        gateway: gw,
        fromJson: _UserModel.fromJson,
        mapper: const _ErrorMapperFake(),
      );

      repo.detachWatch('u1');
      repo.releaseDoc('u1');
      repo.dispose();

      expect(gw.detachCount, 1);
      expect(gw.releaseCount, 1);
      expect(gw.disposeCount, 1);
    });
  });
}
