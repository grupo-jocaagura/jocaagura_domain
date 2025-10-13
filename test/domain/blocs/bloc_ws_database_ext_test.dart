import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

// --------- FakeRepository in-memory ---------
class RepoFake implements RepositoryWsDatabase<UserModel> {
  final Map<String, UserModel> _store = <String, UserModel>{};
  final Map<String, StreamController<Either<ErrorItem, UserModel>>> _streams =
      <String, StreamController<Either<ErrorItem, UserModel>>>{};

  int detachCalls = 0;
  int releaseCalls = 0;
  int disposeCalls = 0;

  @override
  Future<Either<ErrorItem, UserModel>> read(String docId) async {
    final UserModel? u = _store[docId];
    if (u == null) {
      return Left<ErrorItem, UserModel>(DatabaseErrorItems.notFound);
    }
    return Right<ErrorItem, UserModel>(u);
  }

  @override
  Future<Either<ErrorItem, UserModel>> write(
    String docId,
    UserModel entity,
  ) async {
    _store[docId] = entity;
    _streams[docId]?.add(Right<ErrorItem, UserModel>(entity));
    return Right<ErrorItem, UserModel>(entity);
  }

  @override
  Future<Either<ErrorItem, Unit>> delete(String docId) async {
    _store.remove(docId);
    _streams[docId]
        ?.add(Left<ErrorItem, UserModel>(DatabaseErrorItems.notFound));
    return Right<ErrorItem, Unit>(Unit.value);
  }

  @override
  Stream<Either<ErrorItem, UserModel>> watch(String docId) {
    final StreamController<Either<ErrorItem, UserModel>> ctrl =
        _streams.putIfAbsent(
      docId,
      () => StreamController<Either<ErrorItem, UserModel>>.broadcast(),
    );
    // seed (puede ser {} mapeado arriba, aquí usamos estado actual si existe)
    scheduleMicrotask(() {
      final UserModel? u = _store[docId];
      ctrl.add(
        u == null
            ? Left<ErrorItem, UserModel>(DatabaseErrorItems.notFound)
            : Right<ErrorItem, UserModel>(u),
      );
    });
    return ctrl.stream;
  }

  @override
  void detachWatch(String docId) {
    detachCalls++;
  }

  @override
  void releaseDoc(String docId) {
    releaseCalls++;
  }

  @override
  void dispose() {
    disposeCalls++;
    for (final StreamController<Either<ErrorItem, UserModel>> c
        in _streams.values) {
      c.close();
    }
    _streams.clear();
  }
}

// --------- Tests ---------
void main() {
  group('BlocWsDatabase', () {
    late RepoFake repo;
    late FacadeWsDatabaseUsecases<UserModel> facade;
    late BlocWsDatabase<UserModel> bloc;

    setUp(() {
      repo = RepoFake();
      facade = FacadeWsDatabaseUsecases<UserModel>.fromRepository(
        repository: repo,
        fromJson: UserModel.fromJson,
      );
      bloc = BlocWsDatabase<UserModel>(facade: facade);
    });

    tearDown(() {
      // Best-effort; el propio bloc hará cleanup en dispose
      bloc.dispose();
    });

    test('Given readDoc success Then state has docId/doc and loading toggles',
        () async {
      await repo.write(
        'u1',
        const UserModel(
          id: 'u1',
          displayName: 'Alice',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );

      final List<WsDbState<UserModel>> states = <WsDbState<UserModel>>[];
      final StreamSubscription<WsDbState<UserModel>> sub =
          bloc.stream.listen(states.add);

      final Either<ErrorItem, UserModel> res = await bloc.readDoc('u1');
      expect(res.fold((_) => false, (_) => true), isTrue);

      await pumpEventQueue(); // o: await Future<void>.delayed(Duration.zero);

      expect(states.any((WsDbState<UserModel> s) => s.loading == true), isTrue);
      expect(states.last.docId, 'u1');
      expect(states.last.doc?.displayName, 'Alice');
      expect(states.last.loading, isFalse);

      await sub.cancel();
    });

    test('Given readDoc not found Then error populated and doc unchanged',
        () async {
      final WsDbState<UserModel> first = bloc.value;
      final Either<ErrorItem, UserModel> res = await bloc.readDoc('missing');
      expect(res.fold((_) => true, (_) => false), isTrue);
      expect(bloc.value.error, isNotNull);
      expect(
        bloc.value.doc,
        first.doc,
        reason: 'doc remains unchanged on error',
      );
    });

    test('Given writeDoc Then state updates with authoritative result',
        () async {
      final Either<ErrorItem, UserModel> res = await bloc.writeDoc(
        'u2',
        const UserModel(
          id: 'u2',
          displayName: 'Bob',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );
      expect(
        res.fold((_) => false, (UserModel u) => u.displayName == 'Bob'),
        isTrue,
      );
      expect(bloc.value.docId, 'u2');
      expect(bloc.value.doc?.displayName, 'Bob');
    });

    test('Given deleteDoc current Then clears doc for that docId', () async {
      await bloc.writeDoc(
        'u3',
        const UserModel(
          id: 'u3',
          displayName: 'Caro',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );
      final Either<ErrorItem, Unit> r = await bloc.deleteDoc('u3');
      expect(r.fold((_) => false, (_) => true), isTrue);
      expect(bloc.value.docId, 'u3');
      expect(bloc.value.doc, isNull);
    });

    test('startWatch/stopWatch: updates state and detaches via facade',
        () async {
      // prepara dato
      await repo.write(
        'u4',
        const UserModel(
          id: 'u4',
          displayName: 'Dani',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );

      final List<WsDbState<UserModel>> states = <WsDbState<UserModel>>[];
      final StreamSubscription<WsDbState<UserModel>> sub =
          bloc.stream.listen(states.add);

      await bloc.startWatch('u4');
      // Emisión inicial del repo fake
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.value.isWatching, isTrue);
      expect(bloc.value.docId, 'u4');
      expect(bloc.value.doc?.displayName, 'Dani', reason: 'seed propagated');

      // Ahora cambia el dato y verifica actualización
      await repo.write(
        'u4',
        const UserModel(
          id: 'u4',
          displayName: 'Dani*',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.value.doc?.displayName, 'Dani*');

      await bloc.stopWatch('u4');
      expect(bloc.value.isWatching, isFalse);
      expect(repo.detachCalls, 1);

      await sub.cancel();
    });

    test('stopAllWatches detaches all and sets isWatching=false', () async {
      await repo.write(
        'a',
        const UserModel(
          id: 'a',
          displayName: 'A',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );
      await repo.write(
        'b',
        const UserModel(
          id: 'b',
          displayName: 'B',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );

      await bloc.startWatch('a');
      await bloc.startWatch('b');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await bloc.stopAllWatches();
      expect(repo.detachCalls, 2);
      expect(bloc.value.isWatching, isFalse);
    });

    test('dispose cancels/ detaches remaining watches (best-effort)', () async {
      await repo.write(
        'x',
        const UserModel(
          id: 'x',
          displayName: 'X',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );
      await bloc.startWatch('x');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // dispose sin await en detach
      bloc.dispose();
      expect(repo.detachCalls >= 1, isTrue);
      expect(
        repo.disposeCalls,
        0,
        reason: 'Bloc.dispose must not dispose repository',
      );
    });

    test(
        'existsDoc/ensureDoc/mutateDoc/patchDoc happy paths update or return as expected',
        () async {
      // exists -> false
      final Either<ErrorItem, bool> ex0 = await bloc.existsDoc('m1');
      expect(ex0.fold((_) => false, (bool b) => b == false), isTrue);

      // ensure create
      final Either<ErrorItem, UserModel> en = await bloc.ensureDoc(
        docId: 'm1',
        create: () => const UserModel(
          id: 'm1',
          displayName: 'Z',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );
      expect(
        en.fold((_) => false, (UserModel u) => u.displayName == 'Z'),
        isTrue,
      );

      // exists -> true
      final Either<ErrorItem, bool> ex1 = await bloc.existsDoc('m1');
      expect(ex1.fold((_) => false, (bool b) => b == true), isTrue);

      // mutate
      final Either<ErrorItem, UserModel> mu = await bloc.mutateDoc(
        'm1',
        (UserModel u) => UserModel(
          id: u.id,
          displayName: '${u.displayName}!',
          photoUrl: '',
          email: '',
          jwt: const <String, dynamic>{},
        ),
      );
      expect(
        mu.fold((_) => false, (UserModel u) => u.displayName.endsWith('!')),
        isTrue,
      );

      // patch
      final Either<ErrorItem, UserModel> pa = await bloc
          .patchDoc('m1', <String, dynamic>{'displayName': 'Patched'});
      expect(
        pa.fold((_) => false, (UserModel u) => u.displayName == 'Patched'),
        isTrue,
      );
    });

    test(
        'watchUntil use case fulfills on predicate and does not detach automatically',
        () async {
      // Construye facade con el repo fake
      final WatchDocUntilUseCase<UserModel> until =
          facade.watchUntil((UserModel u) => u.displayName == 'Ready');
      // Semilla vacía → probablemente notFound; luego escribe y debe cumplir
      final Future<Either<ErrorItem, UserModel>> future =
          until.call(const WatchParams('w1'));
      await repo.write(
        'w1',
        const UserModel(
          id: 'w1',
          displayName: 'Ready',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
      );
      final Either<ErrorItem, UserModel> res = await future;
      expect(
        res.fold((_) => false, (UserModel u) => u.displayName == 'Ready'),
        isTrue,
      );

      // Debe requerir detach explícito (el BLoC/facade no lo hace aquí)
      expect(repo.detachCalls, 0);
      await facade.detach('w1');
      expect(repo.detachCalls, 1);
    });
  });
}
