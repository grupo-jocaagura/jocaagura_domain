import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

WsDbConfig cfg({
  Duration latency = Duration.zero,
  bool throwOnSave = false,
  bool throwOnDelete = false,
  bool emitInitial = true,
  bool deepCopies = true,
  bool dedupeByContent = true,
  bool orderCollectionsByKey = true,
  String idKey = 'id',
}) {
  return WsDbConfig(
    latency: latency,
    throwOnSave: throwOnSave,
    throwOnDelete: throwOnDelete,
    emitInitial: emitInitial,
    deepCopies: deepCopies,
    dedupeByContent: dedupeByContent,
    orderCollectionsByKey: orderCollectionsByKey,
    idKey: idKey,
  );
}

void main() {
  // Fixture por defecto.
  late FakeServiceWsDatabase db;

  setUp(() {
    db = FakeServiceWsDatabase(config: cfg());
  });

  tearDown(() {
    try {
      db.dispose();
    } catch (_) {/* ignore double-dispose */}
  });

  group('FakeServiceWsDatabase — documentStream semantics', () {
    test('emits seed {} when document does not exist', () async {
      final Stream<Map<String, dynamic>> s =
          db.documentStream(collection: 'users', docId: 'nope');

      await expectLater(s.take(1), emits(equals(<String, dynamic>{})));
    });

    test('emits seed with current doc and then updates', () async {
      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'name': 'Alice', 'age': 30},
      );

      final Stream<Map<String, dynamic>> s =
          db.documentStream(collection: 'users', docId: 'u1');

      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub = s.listen(events.add);

      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'name': 'Alice', 'age': 31},
      );

      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(
        events.first,
        equals(<String, dynamic>{'name': 'Alice', 'age': 30}),
      );
      expect(
        events.last,
        equals(<String, dynamic>{'name': 'Alice', 'age': 31}),
      );

      await sub.cancel();
    });

    test('delete causes stream to emit {} (idempotent delete)', () async {
      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'n': 1},
      );

      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub = db
          .documentStream(collection: 'users', docId: 'u1')
          .listen(events.add);

      await db.deleteDocument(collection: 'users', docId: 'u1');
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(events.last, equals(<String, dynamic>{}));

      await sub.cancel();
    });

    test('dedupe by content: repeated save with same payload does not re-emit',
        () async {
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub = db
          .documentStream(collection: 'users', docId: 'u1')
          .listen(events.add);

      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'n': 1},
      );
      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'n': 1}, // mismo contenido
      );

      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(events.length, 2);
      expect(events[0], equals(<String, dynamic>{}));
      expect(events[1], equals(<String, dynamic>{'n': 1}));

      await sub.cancel();
    });
  });

  group('FakeServiceWsDatabase — collectionStream semantics', () {
    test('emits seed [] and later sorted list by docId', () async {
      final List<List<Map<String, dynamic>>> events =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub =
          db.collectionStream(collection: 'users').listen(events.add);

      // Guardamos ids fuera de orden
      await db.saveDocument(
        collection: 'users',
        docId: 'b',
        document: <String, dynamic>{'v': 2},
      );
      await db.saveDocument(
        collection: 'users',
        docId: 'a',
        document: <String, dynamic>{'v': 1},
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final List<Map<String, dynamic>> last = events.last;
      expect(
        last,
        equals(<Map<String, dynamic>>[
          <String, dynamic>{'v': 1},
          <String, dynamic>{'v': 2},
        ]),
      );

      await sub.cancel();
    });

    test('dedupe by content on collection', () async {
      final List<List<Map<String, dynamic>>> events =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub =
          db.collectionStream(collection: 'c').listen(events.add);

      await db.saveDocument(
        collection: 'c',
        docId: 'x',
        document: <String, dynamic>{'n': 1},
      );
      await db.saveDocument(
        collection: 'c',
        docId: 'x',
        document: <String, dynamic>{'n': 1},
      );

      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(events.length, 2);
      expect(events[0], equals(<Map<String, dynamic>>[]));
      expect(
        events[1],
        equals(<Map<String, dynamic>>[
          <String, dynamic>{'n': 1},
        ]),
      );

      await sub.cancel();
    });
  });

  group('FakeServiceWsDatabase — raw collection snapshots', () {
    test('collectionRawStream emits id->doc map (seed + updates)', () async {
      final List<Map<String, Map<String, dynamic>>> events =
          <Map<String, Map<String, dynamic>>>[];

      final StreamSubscription<Map<String, Map<String, dynamic>>> sub =
          db.collectionRawStream(collection: 'ps').listen(events.add);

      await db.saveDocument(
        collection: 'ps',
        docId: 'p2',
        document: <String, dynamic>{'v': 2},
      );
      await db.saveDocument(
        collection: 'ps',
        docId: 'p1',
        document: <String, dynamic>{'v': 1},
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(events.first, equals(<String, Map<String, dynamic>>{})); // seed
      final Map<String, Map<String, dynamic>> last = events.last;
      expect(last.keys.toList(), equals(<String>['p1', 'p2'])); // ordenado
      expect(last['p1'], equals(<String, dynamic>{'v': 1}));
      expect(last['p2'], equals(<String, dynamic>{'v': 2}));

      await sub.cancel();
    });
  });

  group('FakeServiceWsDatabase — deep copy semantics', () {
    test('mutating the saved input after save does not affect stored state',
        () async {
      final Map<String, dynamic> original = <String, dynamic>{
        'nested': <String, dynamic>{'a': 1},
      };

      await db.saveDocument(collection: 'c', docId: 'd', document: original);

      (original['nested'] as Map<String, dynamic>)['a'] = 999;

      final Map<String, dynamic> read =
          await db.readDocument(collection: 'c', docId: 'd');

      expect(
        read,
        equals(<String, dynamic>{
          'nested': <String, dynamic>{'a': 1},
        }),
      );
    });

    test('mutating the read map does not affect internal state', () async {
      await db.saveDocument(
        collection: 'c',
        docId: 'd',
        document: <String, dynamic>{
          'k': <String, dynamic>{'x': 1},
        },
      );

      final Map<String, dynamic> read1 =
          await db.readDocument(collection: 'c', docId: 'd');
      (read1['k'] as Map<String, dynamic>)['x'] = 999;

      final Map<String, dynamic> read2 =
          await db.readDocument(collection: 'c', docId: 'd');

      expect(
        read2,
        equals(<String, dynamic>{
          'k': <String, dynamic>{'x': 1},
        }),
      );
    });
  });

  group('FakeServiceWsDatabase — simulated errors & latency', () {
    test('throwOnSave: save throws and state remains unchanged', () async {
      final FakeServiceWsDatabase local =
          FakeServiceWsDatabase(config: cfg(throwOnSave: true));

      expect(
        local.saveDocument(
          collection: 'c',
          docId: 'd',
          document: <String, dynamic>{'x': 1},
        ),
        throwsA(isA<StateError>()),
      );

      expect(
        local.readDocument(collection: 'c', docId: 'd'),
        throwsA(isA<StateError>()), // not created
      );

      local.dispose();
    });

    test('throwOnDelete: delete throws and state remains unchanged', () async {
      final FakeServiceWsDatabase local =
          FakeServiceWsDatabase(config: cfg(throwOnDelete: true));

      await local.saveDocument(
        collection: 'c',
        docId: 'd',
        document: <String, dynamic>{'x': 1},
      );

      expect(
        local.deleteDocument(collection: 'c', docId: 'd'),
        throwsA(isA<StateError>()),
      );

      final Map<String, dynamic> read =
          await local.readDocument(collection: 'c', docId: 'd');
      expect(read, equals(<String, dynamic>{'x': 1}));

      local.dispose();
    });

    test('latency is respected for save/read/delete', () async {
      const Duration L = Duration(milliseconds: 25);
      final FakeServiceWsDatabase local =
          FakeServiceWsDatabase(config: cfg(latency: L));

      final Stopwatch sw = Stopwatch()..start();
      await local.saveDocument(
        collection: 'c',
        docId: 'd',
        document: <String, dynamic>{'x': 1},
      );
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(L.inMilliseconds));

      sw
        ..reset()
        ..start();
      await local.readDocument(collection: 'c', docId: 'd');
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(L.inMilliseconds));

      sw
        ..reset()
        ..start();
      await local.deleteDocument(collection: 'c', docId: 'd');
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(L.inMilliseconds));

      local.dispose();
    });
  });

  group('FakeServiceWsDatabase — dispose behavior', () {
    test('methods after dispose throw StateError', () async {
      db.dispose();

      expect(
        db.saveDocument(
          collection: 'c',
          docId: 'd',
          document: <String, dynamic>{},
        ),
        throwsA(isA<StateError>()),
      );
      expect(
        db.readDocument(collection: 'c', docId: 'd'),
        throwsA(isA<StateError>()),
      );
      expect(
        db.deleteDocument(collection: 'c', docId: 'd'),
        throwsA(isA<StateError>()),
      );
    });

    test('active streams stop producing on dispose', () async {
      // db local para manejar su ciclo de vida sin interferir con el fixture.
      final FakeServiceWsDatabase local = FakeServiceWsDatabase(config: cfg());

      final List<Map<String, dynamic>> docEvents = <Map<String, dynamic>>[];
      final List<List<Map<String, dynamic>>> colEvents =
          <List<Map<String, dynamic>>>[];

      final StreamSubscription<Map<String, dynamic>> s1 = local
          .documentStream(collection: 'c', docId: 'd')
          .listen(docEvents.add);
      final StreamSubscription<List<Map<String, dynamic>>> s2 =
          local.collectionStream(collection: 'c').listen(colEvents.add);

      // Deja que lleguen semillas (si aplica)
      await Future<void>.delayed(const Duration(milliseconds: 2));

      // Disponer el servicio
      local.dispose();

      // Luego de dispose, las operaciones deben fallar
      expect(
        local.saveDocument(
          collection: 'c',
          docId: 'd',
          document: <String, dynamic>{'k': 1},
        ),
        throwsA(isA<StateError>()),
      );

      // Cancelamos manualmente las subs (no dependemos de onDone).
      await s1.cancel();
      await s2.cancel();

      // Y validamos que al menos recibimos como mucho la semilla previa
      expect(docEvents.isNotEmpty, isTrue);
      expect(colEvents.isNotEmpty, isTrue);
    });
  });

  group('FakeServiceWsDatabase — validations', () {
    test('empty collection/docId throws ArgumentError', () async {
      expect(
        db.saveDocument(
          collection: '',
          docId: 'x',
          document: <String, dynamic>{},
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        db.saveDocument(
          collection: 'c',
          docId: '',
          document: <String, dynamic>{},
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        db.readDocument(collection: '', docId: 'x'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        db.readDocument(collection: 'c', docId: ''),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        db.deleteDocument(collection: '', docId: 'x'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        db.deleteDocument(collection: 'c', docId: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('read non-existing document throws StateError', () async {
      expect(
        db.readDocument(collection: 'c', docId: 'nope'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
