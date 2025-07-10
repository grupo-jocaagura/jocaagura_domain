import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/src/fake_services/fake_service_ws_database.dart';

void main() {
  group('FakeServiceWsDatabase', () {
    late FakeServiceWsDatabase db;

    setUp(() {
      db = FakeServiceWsDatabase();
    });

    group('parameter validation', () {
      test('saveDocument throws on empty collection', () {
        expect(
          () => db.saveDocument(
            collection: '',
            docId: 'id',
            document: <String, dynamic>{'a': 1},
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('saveDocument throws on empty docId', () {
        expect(
          () => db.saveDocument(
            collection: 'col',
            docId: '',
            document: <String, dynamic>{'a': 1},
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('readDocument throws on empty collection', () {
        expect(
          () => db.readDocument(collection: '', docId: 'id'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('readDocument throws on empty docId', () {
        expect(
          () => db.readDocument(collection: 'col', docId: ''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('deleteDocument throws on empty collection', () {
        expect(
          () => db.deleteDocument(collection: '', docId: 'id'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('deleteDocument throws on empty docId', () {
        expect(
          () => db.deleteDocument(collection: 'col', docId: ''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('collectionStream throws on empty collection', () {
        expect(
          () => db.collectionStream(collection: ''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('documentStream throws on empty collection', () {
        expect(
          () => db.documentStream(collection: '', docId: 'id'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('documentStream throws on empty docId', () {
        expect(
          () => db.documentStream(collection: 'col', docId: ''),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('basic operations', () {
      test('save and read document', () async {
        const Map<String, String> data = <String, String>{'key': 'value'};
        await db.saveDocument(collection: 'col', docId: 'id', document: data);
        final Map<String, dynamic> result =
            await db.readDocument(collection: 'col', docId: 'id');
        expect(result, equals(data));
      });

      test('collectionStream updates on saveDocument', () async {
        final List<List<Map<String, dynamic>>> events =
            <List<Map<String, dynamic>>>[];
        final StreamSubscription<List<Map<String, dynamic>>> sub =
            db.collectionStream(collection: 'col').listen(events.add);
        await db.saveDocument(
          collection: 'col',
          docId: 'id',
          document: <String, dynamic>{'a': 1},
        );
        await Future<void>.delayed(Duration.zero);
        expect(events, isNotEmpty);
        // La colección debe contener un documento con 'a': 1
        // Comprobación manual de que la lista contiene un mapa con 'a': 1
        bool contiene = false;
        for (final Map<String, dynamic> doc in events.last) {
          if (doc['a'] == 1 && doc.length == 1) {
            contiene = true;
            break;
          }
        }
        expect(contiene, isTrue);
        await sub.cancel();
      });

      test('documentStream updates on saveDocument', () async {
        final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
        final StreamSubscription<Map<String, dynamic>> sub = db
            .documentStream(collection: 'col', docId: 'id')
            .listen(events.add);
        await db.saveDocument(
          collection: 'col',
          docId: 'id',
          document: <String, dynamic>{'a': 1},
        );
        await Future<void>.delayed(Duration.zero);
        // Comprobación manual sin paquetes externos
        bool contiene = false;
        for (final Map<String, dynamic> e in events) {
          if (e.length == 1 && e['a'] == 1) {
            contiene = true;
            break;
          }
        }
        expect(contiene, isTrue);
        await sub.cancel();
      });

      test('readDocument throws when document does not exist', () async {
        expect(
          () => db.readDocument(collection: 'col', docId: 'unknown'),
          throwsA(isA<StateError>()),
        );
      });

      test('deleteDocument removes document and updates streams', () async {
        await db.saveDocument(
          collection: 'col',
          docId: 'id',
          document: <String, dynamic>{'k': 'v'},
        );
        final List<Map<String, dynamic>> docEvents = <Map<String, dynamic>>[];
        final StreamSubscription<Map<String, dynamic>> subDoc = db
            .documentStream(collection: 'col', docId: 'id')
            .listen(docEvents.add);
        final List<List<Map<String, dynamic>>> colEvents =
            <List<Map<String, dynamic>>>[];
        final StreamSubscription<List<Map<String, dynamic>>> subCol =
            db.collectionStream(collection: 'col').listen(colEvents.add);
        await db.deleteDocument(collection: 'col', docId: 'id');
        await Future<void>.delayed(Duration.zero);
        // El documento eliminado debe ser un mapa vacío
        expect(docEvents.last, equals(<String, dynamic>{}));
        // La colección debe estar vacía
        expect(colEvents.last, equals(<Map<String, dynamic>>[]));
        await subDoc.cancel();
        await subCol.cancel();
      });
    });

    group('throwOnSave coverage', () {
      test('saveDocument lanza StateError si throwOnSave es true', () async {
        final FakeServiceWsDatabase db =
            FakeServiceWsDatabase(throwOnSave: true);
        expect(
          () => db.saveDocument(
            collection: 'col',
            docId: 'id',
            document: <String, dynamic>{'a': 1},
          ),
          throwsA(isA<StateError>()),
        );
      });
      test('deleteDocument lanza StateError si throwOnSave es true', () async {
        final FakeServiceWsDatabase db =
            FakeServiceWsDatabase(throwOnSave: true);
        expect(
          () => db.deleteDocument(collection: 'col', docId: 'id'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('dispose seguro', () {
      test('dispose no lanza excepción', () {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        expect(() => db.dispose(), returnsNormally);
      });
      test('guardar tras dispose lanza excepción', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        await db.saveDocument(
          collection: 'col',
          docId: 'id',
          document: <String, dynamic>{'a': 1},
        );
        db.dispose();
        try {
          await db.saveDocument(
            collection: 'col',
            docId: 'id2',
            document: <String, dynamic>{'a': 2},
          );
          fail('No se lanzó StateError');
        } catch (e) {
          expect(e, isA<StateError>());
        }
      });
      test('eliminar tras dispose lanza excepción', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        await db.saveDocument(
          collection: 'col',
          docId: 'id',
          document: <String, dynamic>{'a': 1},
        );
        db.dispose();
        expect(
          () => db.deleteDocument(collection: 'col', docId: 'id'),
          throwsA(
            predicate(
              (Object? e) =>
                  e is StateError ||
                  e.toString().contains('Bad state') ||
                  e.toString().contains('disposed'),
            ),
          ),
        );
      });
    });

    group('funcionalidad avanzada y robustez', () {
      test('leer documento en colección inexistente', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        expect(
          () => db.readDocument(collection: 'noexiste', docId: 'id'),
          throwsA(isA<StateError>()),
        );
      });
      test('stream de colección en colección inexistente', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        final List<List<Map<String, dynamic>>> events =
            <List<Map<String, dynamic>>>[];
        final StreamSubscription<List<Map<String, dynamic>>> sub =
            db.collectionStream(collection: 'noexiste').listen(events.add);
        await Future<void>.delayed(Duration.zero);
        expect(events.isNotEmpty, isTrue);
        expect(events.first, isEmpty);
        await sub.cancel();
      });
      test('stream de documento en colección inexistente', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
        final StreamSubscription<Map<String, dynamic>> sub = db
            .documentStream(collection: 'noexiste', docId: 'id')
            .listen(events.add);
        await Future<void>.delayed(Duration.zero);
        expect(events.isNotEmpty, isTrue);
        expect(events.first, isEmpty);
        await sub.cancel();
      });
      test('sobrescribir documento con el mismo docId', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        await db.saveDocument(
          collection: 'col',
          docId: 'id',
          document: <String, dynamic>{'a': 1},
        );
        await db.saveDocument(
          collection: 'col',
          docId: 'id',
          document: <String, dynamic>{'a': 2},
        );
        final Map<String, dynamic> doc =
            await db.readDocument(collection: 'col', docId: 'id');
        expect(doc['a'], 2);
      });
      test('guardar documento con datos anidados', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        final Map<String, Object> nested = <String, Object>{
          'a': 1,
          'b': <String, Object>{
            'c': 2,
            'd': <int>[3, 4],
          },
        };
        await db.saveDocument(collection: 'col', docId: 'id', document: nested);
        final Map<String, dynamic> doc =
            await db.readDocument(collection: 'col', docId: 'id');
        expect(doc['b'], isA<Map<String, dynamic>>());
        final Map<String, dynamic>? b = doc['b'] as Map<String, dynamic>?;
        expect(b?['d'], isA<List<dynamic>>());
      });
      test('latencia artificial en saveDocument', () async {
        final FakeServiceWsDatabase db =
            FakeServiceWsDatabase(latency: const Duration(milliseconds: 100));
        final Stopwatch sw = Stopwatch()..start();
        await db.saveDocument(
          collection: 'col',
          docId: 'id',
          document: <String, dynamic>{'a': 1},
        );
        sw.stop();
        expect(sw.elapsedMilliseconds >= 100, isTrue);
      });
      test('latencia artificial en readDocument', () async {
        final FakeServiceWsDatabase db =
            FakeServiceWsDatabase(latency: const Duration(milliseconds: 100));
        await db.saveDocument(
          collection: 'col',
          docId: 'id',
          document: <String, dynamic>{'a': 1},
        );
        final Stopwatch sw = Stopwatch()..start();
        await db.readDocument(collection: 'col', docId: 'id');
        sw.stop();
        expect(sw.elapsedMilliseconds >= 100, isTrue);
      });
      test('eliminar todos los documentos y verificar stream vacío', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        await db.saveDocument(
          collection: 'col',
          docId: 'id1',
          document: <String, dynamic>{'a': 1},
        );
        await db.saveDocument(
          collection: 'col',
          docId: 'id2',
          document: <String, dynamic>{'a': 2},
        );
        final List<List<Map<String, dynamic>>> events =
            <List<Map<String, dynamic>>>[];
        final StreamSubscription<List<Map<String, dynamic>>> sub =
            db.collectionStream(collection: 'col').listen(events.add);
        await db.deleteDocument(collection: 'col', docId: 'id1');
        await db.deleteDocument(collection: 'col', docId: 'id2');
        await Future<void>.delayed(Duration.zero);
        expect(events.last, isEmpty);
        await sub.cancel();
      });
      test('usar métodos tras dispose es seguro', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        db.dispose();
        await Future<void>.delayed(Duration.zero);
        await expectLater(
          () async => db.saveDocument(
            collection: 'col',
            docId: 'id',
            document: <String, dynamic>{'a': 1},
          ),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('cobertura de errores y dispose internos', () {
      test('throwOnSave en _ensureCollection (línea 46)', () {
        final FakeServiceWsDatabase db =
            FakeServiceWsDatabase(throwOnSave: true);
        expect(
          () => db.saveDocument(
            collection: 'noexiste',
            docId: 'id',
            document: <String, dynamic>{'a': 1},
          ),
          throwsA(isA<StateError>()),
        );
      });
      test('throwOnSave en deleteDocument (línea 111)', () async {
        final FakeServiceWsDatabase db =
            FakeServiceWsDatabase(throwOnSave: true);
        expect(
          () => db.deleteDocument(collection: 'col', docId: 'id'),
          throwsA(isA<StateError>()),
        );
      });
      test('dispose llama a controller.dispose linea 126', () async {
        final FakeServiceWsDatabase db = FakeServiceWsDatabase();
        expect(() => db.dispose(), returnsNormally);
        await expectLater(
          () async => db.saveDocument(
            collection: 'col',
            docId: 'id',
            document: <String, dynamic>{'a': 1},
          ),
          throwsA(isA<StateError>()),
        );
        // No se debe intentar guardar/eliminar después de dispose aquí
      });
    });

    group('throwOnSave true cobertura de errores', () {
      test('saveDocument lanza StateError (línea 55)', () async {
        final FakeServiceWsDatabase db =
            FakeServiceWsDatabase(throwOnSave: true);
        expect(
          () => db.saveDocument(
            collection: 'col',
            docId: 'id',
            document: <String, dynamic>{'a': 1},
          ),
          throwsA(
            predicate(
              (Object? e) =>
                  e is StateError &&
                  (e.toString().contains('Simulated save error') ||
                      e.toString().contains('Collection not found')),
            ),
          ),
        );
      });
      test('deleteDocument lanza StateError (línea 124)', () async {
        final FakeServiceWsDatabase db =
            FakeServiceWsDatabase(throwOnSave: true);
        expect(
          () => db.deleteDocument(collection: 'col', docId: 'id'),
          throwsA(
            predicate(
              (Object? e) =>
                  e is StateError &&
                  (e.toString().contains('Simulated delete error') ||
                      e.toString().contains('Collection not found')),
            ),
          ),
        );
      });
    });
  });
}
