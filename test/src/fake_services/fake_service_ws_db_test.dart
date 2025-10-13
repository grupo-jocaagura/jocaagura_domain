import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart'; // ajusta el path

void main() {
  group('FakeServiceWsDb', () {
    FakeServiceWsDb makeDb({WsDbConfig? cfg}) =>
        FakeServiceWsDb(config: cfg ?? const WsDbConfig());

    test('Given save Then read returns same (normalized) payload', () async {
      final FakeServiceWsDb db = makeDb();
      final Map<String, dynamic> saved = await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'name': 'Alice', 'age': 30},
      );
      final Map<String, dynamic> read =
          await db.readDocument(collection: 'users', docId: 'u1');

      expect(saved['name'], 'Alice');
      expect(read['age'], 30);
      db.dispose();
    });

    test('Given non-existing doc When read Then throws StateError', () async {
      final FakeServiceWsDb db = makeDb();
      expect(
        () => db.readDocument(collection: 'users', docId: 'missing'),
        throwsA(isA<StateError>()),
      );
      db.dispose();
    });

    test('Given invalid args When calling methods Then throws ArgumentError',
        () async {
      final FakeServiceWsDb db = makeDb();
      expect(
        () => db.readDocument(collection: '', docId: 'x'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => db.readDocument(collection: 'users', docId: ''),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => db.collectionStream(collection: ''),
        throwsA(isA<ArgumentError>()),
      );
      db.dispose();
    });

    test(
        'Given document stream + emitInitial When no doc Then first event is {}',
        () async {
      final FakeServiceWsDb db = makeDb(cfg: const WsDbConfig());
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub = db
          .documentStream(collection: 'users', docId: 'u1')
          .listen(events.add);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, isNotEmpty);
      expect(events.first, isEmpty);

      await sub.cancel();
      db.dispose();
    });

    test(
        'Given document stream When saving twice Then emits two non-duplicate events',
        () async {
      final FakeServiceWsDb db = makeDb();
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub = db
          .documentStream(collection: 'users', docId: 'u1')
          .listen(events.add);

      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'v': 1},
      );
      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'v': 2},
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(
        events.length,
        3,
        reason: 'seed {} + two writes',
      ); // seed {}, v1, v2
      expect(events[1]['v'], 1);
      expect(events[2]['v'], 2);

      await sub.cancel();
      db.dispose();
    });

    test(
        'Given dedupeByContent=true When writing equal content Then skip duplicate emission',
        () async {
      final FakeServiceWsDb db = makeDb(cfg: const WsDbConfig());
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub = db
          .documentStream(collection: 'users', docId: 'u1')
          .listen(events.add);

      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'v': 1},
      );
      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'v': 1},
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // seed {} + first write {v:1}; second write deduped
      expect(events.length, 2);
      await sub.cancel();
      db.dispose();
    });

    test(
        'Given deepCopies=true When reading/streaming Then mutations do not affect store',
        () async {
      final FakeServiceWsDb db = makeDb(cfg: const WsDbConfig());
      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'name': 'A'},
      );

      final Map<String, dynamic> read =
          await db.readDocument(collection: 'users', docId: 'u1');
      read['name'] = 'B'; // mutate snapshot

      final Map<String, dynamic> read2 =
          await db.readDocument(collection: 'users', docId: 'u1');
      expect(read2['name'], 'A'); // store intact

      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub = db
          .documentStream(collection: 'users', docId: 'u1')
          .listen(events.add);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      events.first['name'] = 'C'; // mutate emitted snapshot

      final Map<String, dynamic> read3 =
          await db.readDocument(collection: 'users', docId: 'u1');
      expect(read3['name'], 'A'); // store still intact

      await sub.cancel();
      db.dispose();
    });

    test(
        'Given collection stream with orderCollectionsByKey=true Then snapshots are sorted by docId',
        () async {
      final FakeServiceWsDb db = makeDb(cfg: const WsDbConfig());

      final List<List<Map<String, dynamic>>> snaps =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub =
          db.collectionStream(collection: 'users').listen(snaps.add);

      await db.saveDocument(
        collection: 'users',
        docId: 'b',
        document: <String, dynamic>{'i': 2},
      );
      await db.saveDocument(
        collection: 'users',
        docId: 'a',
        document: <String, dynamic>{'i': 1},
      );
      await db.saveDocument(
        collection: 'users',
        docId: 'c',
        document: <String, dynamic>{'i': 3},
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final List<Map<String, dynamic>> last = snaps.last;
      // Espera orden a, b, c
      expect(
        last.map((Map<String, dynamic> m) => m['i']).toList(),
        <int>[1, 2, 3],
      );

      await sub.cancel();
      db.dispose();
    });

    test('Given latency When saving Then awaited time is >= latency', () async {
      const Duration latency = Duration(milliseconds: 20);
      final FakeServiceWsDb db =
          makeDb(cfg: const WsDbConfig(latency: latency));
      final Stopwatch sw = Stopwatch()..start();
      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{},
      );
      sw.stop();
      expect(sw.elapsedMilliseconds >= latency.inMilliseconds, isTrue);
      db.dispose();
    });

    test('Given throwOnSave/delete When operations Then throws StateError',
        () async {
      final FakeServiceWsDb dbSave =
          makeDb(cfg: const WsDbConfig(throwOnSave: true));
      expect(
        () => dbSave.saveDocument(
          collection: 'users',
          docId: 'x',
          document: <String, dynamic>{},
        ),
        throwsA(isA<StateError>()),
      );
      dbSave.dispose();

      final FakeServiceWsDb dbDel = makeDb(cfg: const WsDbConfig());
      await dbDel.saveDocument(
        collection: 'users',
        docId: 'x',
        document: <String, dynamic>{},
      );
      final FakeServiceWsDb dbDelErr =
          makeDb(cfg: const WsDbConfig(throwOnDelete: true));
      // Para forzar delete en el que lanza:
      expect(
        () => dbDelErr.deleteDocument(collection: 'users', docId: 'x'),
        throwsA(isA<StateError>()),
      );
      dbDel.dispose();
      dbDelErr.dispose();
    });

    test('Given delete idempotent When deleting missing doc Then ack ok:true',
        () async {
      final FakeServiceWsDb db = makeDb();
      final Map<String, dynamic> ack =
          await db.deleteDocument(collection: 'users', docId: 'missing');
      expect(ack['ok'], true);
      db.dispose();
    });

    test(
        'Given disposed service When calling methods Then throws StateError and dispose is idempotent',
        () async {
      final FakeServiceWsDb db = makeDb();
      db.dispose();
      // Segunda llamada no debería fallar
      expect(() => db.dispose(), returnsNormally);
      // Cualquier operación posterior debe fallar
      expect(
        () => db.saveDocument(
          collection: 'c',
          docId: 'd',
          document: <String, dynamic>{},
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('WsDbErrorMiniMapper', () {
    test('Maps ArgumentError/StateError/others to codes', () {
      const WsDbErrorMiniMapper m = WsDbErrorMiniMapper();
      final Map<String, dynamic> a = m.toErrorItem(
        ArgumentError('bad'),
        StackTrace.current,
        operation: 'read',
        collection: 'users',
        docId: 'u1',
      );
      final Map<String, dynamic> s = m.toErrorItem(
        StateError('nf'),
        StackTrace.current,
        operation: 'read',
        collection: 'users',
      );
      final Map<String, dynamic> u = m.toErrorItem(
        Exception('x'),
        StackTrace.current,
        operation: 'save',
        collection: 'users',
      );
      expect(a['code'], 'wsdb.invalid-argument');
      expect(s['code'], 'wsdb.not-found');
      expect(u['code'], 'wsdb.unexpected');
    });
  });
  group('FakeServiceWsDb - hooks on _collections', () {
    FakeServiceWsDb makeDb() => FakeServiceWsDb();

    test(
        'Given executeNow=false When register Then not called until first mutation',
        () async {
      final FakeServiceWsDb db = makeDb();
      int calls = 0;

      db.addFunctionToProcessTValueOnStream(
        'h1',
        (Map<String, dynamic> _) {
          calls++;
        },
      );

      // No mutación aún → 0 llamadas
      expect(calls, 0);

      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'name': 'Alice'},
      );

      // Tras mutar, al menos 1 llamada
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(calls, greaterThanOrEqualTo(1));

      db.dispose();
    });

    test('Given executeNow=true When register Then called immediately',
        () async {
      final FakeServiceWsDb db = makeDb();
      int calls = 0;

      db.addFunctionToProcessTValueOnStream(
        'h2',
        (Map<String, dynamic> _) {
          calls++;
        },
        true,
      );

      // Llamada inmediata
      expect(calls, 1);

      db.dispose();
    });

    test(
        'Given registered hook When delete by key Then subsequent mutations do not call it',
        () async {
      final FakeServiceWsDb db = makeDb();
      int calls = 0;

      db.addFunctionToProcessTValueOnStream(
        'h3',
        (Map<String, dynamic> _) {
          calls++;
        },
        true,
      );

      // Ya fue llamado una vez por executeNow
      expect(calls, 1);

      // Eliminar hook
      db.deleteFunctionToProcessTValueOnStream('h3');

      // Mutar estado
      await db.saveDocument(
        collection: 'users',
        docId: 'u2',
        document: <String, dynamic>{'name': 'Bob'},
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Debe permanecer en 1
      expect(calls, 1);

      db.dispose();
    });

    test('containsFunctionToProcessValueOnStream reflects current registration',
        () {
      final FakeServiceWsDb db = makeDb();

      expect(db.containsFunctionToProcessValueOnStream('h4'), isFalse);
      db.addFunctionToProcessTValueOnStream('h4', (Map<String, dynamic> _) {});
      expect(db.containsFunctionToProcessValueOnStream('h4'), isTrue);
      db.deleteFunctionToProcessTValueOnStream('h4');
      expect(db.containsFunctionToProcessValueOnStream('h4'), isFalse);

      db.dispose();
    });

    test(
        'Re-registering same key replaces previous callback (implementation-dependent)',
        () async {
      final FakeServiceWsDb db = makeDb();

      int first = 0;
      int second = 0;

      db.addFunctionToProcessTValueOnStream(
        'h5',
        (Map<String, dynamic> _) {
          first++;
        },
        true,
      ); // first++

      // Reemplazar con misma clave
      db.addFunctionToProcessTValueOnStream(
        'h5',
        (Map<String, dynamic> _) {
          second++;
        },
        true,
      ); // second++

      // Mutar estado: solo el segundo debe recibir eventos
      await db.saveDocument(
        collection: 'users',
        docId: 'u3',
        document: <String, dynamic>{'ok': true},
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(
        first,
        1,
        reason: 'El primero no debe recibir eventos tras el replace',
      );
      expect(second, greaterThanOrEqualTo(2), reason: 'executeNow + mutación');

      db.dispose();
    });
  });
  group('FakeServiceWsDb - hooks on _collections', () {
    FakeServiceWsDb makeDb() => FakeServiceWsDb();

    test(
        'Given executeNow=false When register Then not called until first mutation',
        () async {
      final FakeServiceWsDb db = makeDb();
      int calls = 0;

      db.addFunctionToProcessTValueOnStream(
        'h1',
        (Map<String, dynamic> _) {
          calls++;
        },
      );

      // No mutación aún → 0 llamadas
      expect(calls, 0);

      await db.saveDocument(
        collection: 'users',
        docId: 'u1',
        document: <String, dynamic>{'name': 'Alice'},
      );

      // Tras mutar, al menos 1 llamada
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(calls, greaterThanOrEqualTo(1));

      db.dispose();
    });

    test('Given executeNow=true When register Then called immediately',
        () async {
      final FakeServiceWsDb db = makeDb();
      int calls = 0;

      db.addFunctionToProcessTValueOnStream(
        'h2',
        (Map<String, dynamic> _) {
          calls++;
        },
        true,
      );

      // Llamada inmediata
      expect(calls, 1);

      db.dispose();
    });

    test(
        'Given registered hook When delete by key Then subsequent mutations do not call it',
        () async {
      final FakeServiceWsDb db = makeDb();
      int calls = 0;

      db.addFunctionToProcessTValueOnStream(
        'h3',
        (Map<String, dynamic> _) {
          calls++;
        },
        true,
      );

      // Ya fue llamado una vez por executeNow
      expect(calls, 1);

      // Eliminar hook
      db.deleteFunctionToProcessTValueOnStream('h3');

      // Mutar estado
      await db.saveDocument(
        collection: 'users',
        docId: 'u2',
        document: <String, dynamic>{'name': 'Bob'},
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Debe permanecer en 1
      expect(calls, 1);

      db.dispose();
    });

    test('containsFunctionToProcessValueOnStream reflects current registration',
        () {
      final FakeServiceWsDb db = makeDb();

      expect(db.containsFunctionToProcessValueOnStream('h4'), isFalse);
      db.addFunctionToProcessTValueOnStream('h4', (Map<String, dynamic> _) {});
      expect(db.containsFunctionToProcessValueOnStream('h4'), isTrue);
      db.deleteFunctionToProcessTValueOnStream('h4');
      expect(db.containsFunctionToProcessValueOnStream('h4'), isFalse);

      db.dispose();
    });

    test(
        'Re-registering same key replaces previous callback (implementation-dependent)',
        () async {
      final FakeServiceWsDb db = makeDb();

      int first = 0;
      int second = 0;

      db.addFunctionToProcessTValueOnStream(
        'h5',
        (Map<String, dynamic> _) {
          first++;
        },
        true,
      ); // first++

      // Reemplazar con misma clave
      db.addFunctionToProcessTValueOnStream(
        'h5',
        (Map<String, dynamic> _) {
          second++;
        },
        true,
      ); // second++

      // Mutar estado: solo el segundo debe recibir eventos
      await db.saveDocument(
        collection: 'users',
        docId: 'u3',
        document: <String, dynamic>{'ok': true},
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(
        first,
        1,
        reason: 'El primero no debe recibir eventos tras el replace',
      );
      expect(second, greaterThanOrEqualTo(2), reason: 'executeNow + mutación');

      db.dispose();
    });
  });
}
