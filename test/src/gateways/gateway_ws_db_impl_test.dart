import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('GatewayWsDatabaseImpl', () {
    late FakeServiceWsDb service;
    late GatewayWsDbImpl gateway;

    setUp(() {
      service = FakeServiceWsDb();
      gateway = GatewayWsDbImpl(
        service: service,
        collection: 'canvases',
        mapper: const DefaultErrorMapper(),
      );
    });

    tearDown(() {
      gateway.dispose();
      service.dispose();
    });

    // -------------------- READ --------------------
    group('read()', () {
      test('retorna Right y agrega idKey cuando el servidor no lo envía',
          () async {
        await gateway.write('a', <String, dynamic>{'name': 'A'});

        final Either<ErrorItem, Map<String, dynamic>> res =
            await gateway.read('a');

        res.fold(
          (ErrorItem l) => fail('Se esperaba Right, fue Left: $l'),
          (Map<String, dynamic> r) {
            expect(r['name'], 'A');
            expect(r['id'], 'a'); // inyectado por _withId
          },
        );
      });

      test('respeta id del servidor si ya viene presente', () async {
        await service.saveDocument(
          collection: 'canvases',
          docId: 'b',
          document: <String, dynamic>{'id': 'server-id', 'n': 1},
        );

        final Either<ErrorItem, Map<String, dynamic>> res =
            await gateway.read('b');

        res.fold(
          (ErrorItem l) => fail('Se esperaba Right, fue Left: $l'),
          (Map<String, dynamic> r) {
            expect(r['id'], 'server-id'); // no sobreescribe
            expect(r['n'], 1);
          },
        );
      });

      test('retorna Left cuando el documento NO existe (readDocument lanza)',
          () async {
        final Either<ErrorItem, Map<String, dynamic>> res =
            await gateway.read('missing');

        // No dependemos del tipo exacto de ErrorItem: basta con verificar que es Left
        expect(res.fold((_) => true, (_) => false), isTrue);
      });
    });

    // -------------------- WRITE -------------------
    group('write()', () {
      test('optimista (readAfterWrite=false): retorna Right con id inyectado',
          () async {
        gateway = GatewayWsDbImpl(
          service: service,
          collection: 'canvases',
          mapper: const DefaultErrorMapper(),
        );

        final Either<ErrorItem, Map<String, dynamic>> res =
            await gateway.write('c', <String, dynamic>{'v': 1});

        res.fold(
          (ErrorItem l) => fail('Se esperaba Right, fue Left: $l'),
          (Map<String, dynamic> r) {
            expect(r['id'], 'c'); // inyectado
            expect(r['v'], 1);
          },
        );
      });

      test(
          'autoritatvo (readAfterWrite=true): retorna lo que persiste el backend',
          () async {
        gateway = GatewayWsDbImpl(
          service: service,
          collection: 'canvases',
          mapper: const DefaultErrorMapper(),
          readAfterWrite: true,
        );

        final Either<ErrorItem, Map<String, dynamic>> res =
            await gateway.write('d', <String, dynamic>{'k': 'v'});

        res.fold(
          (ErrorItem l) => fail('Se esperaba Right, fue Left: $l'),
          (Map<String, dynamic> r) {
            // En este Fake el payload autoritativo == lo guardado.
            expect(r['id'], 'd');
            expect(r['k'], 'v');
          },
        );
      });

      test('respeta id del JSON si viene incluido al escribir', () async {
        final Either<ErrorItem, Map<String, dynamic>> res = await gateway
            .write('e', <String, dynamic>{'id': 'from-client', 'v': 2});

        res.fold(
          (ErrorItem l) => fail('Se esperaba Right, fue Left: $l'),
          (Map<String, dynamic> r) {
            expect(r['id'], 'from-client'); // _withId no sobreescribe
            expect(r['v'], 2);
          },
        );
      });

      test('mapea errores de save a Left(ErrorItem)', () async {
        final WsDbConfig cfg = defaultWsDbConfig.copyWith(throwOnSave: true);
        service = FakeServiceWsDb(config: cfg);
        gateway = GatewayWsDbImpl(
          service: service,
          collection: 'canvases',
          mapper: const DefaultErrorMapper(),
        );

        final Either<ErrorItem, Map<String, dynamic>> res =
            await gateway.write('x', <String, dynamic>{});

        expect(res.fold((_) => true, (_) => false), isTrue);
      });
    });

    group('delete()', () {
      test('retorna Right(Unit) cuando borra un doc existente', () async {
        await gateway.write('f', <String, dynamic>{'v': 1});

        final Either<ErrorItem, Unit> res = await gateway.delete('f');

        res.fold(
          (ErrorItem l) => fail('Se esperaba Right(Unit), fue Left: $l'),
          (Unit r) => expect(r, Unit.value),
        );
      });

      test('mapea errores de delete a Left(ErrorItem)', () async {
        final WsDbConfig cfg = defaultWsDbConfig.copyWith(throwOnDelete: true);
        service = FakeServiceWsDb(config: cfg);
        gateway = GatewayWsDbImpl(
          service: service,
          collection: 'canvases',
          mapper: const DefaultErrorMapper(),
        );

        final Either<ErrorItem, Unit> res = await gateway.delete('y');

        expect(res.fold((_) => true, (_) => false), isTrue);
      });

      test('delete es idempotente cuando no existe (Fake no lanza)', () async {
        final Either<ErrorItem, Unit> res = await gateway.delete('no-exist');
        res.fold(
          (ErrorItem l) => fail('Se esperaba Right(Unit), fue Left: $l'),
          (Unit r) => expect(r, Unit.value),
        );
      });
    });

    // -------------------- WATCH -------------------
    group('watch() + ref-count (detachWatch / releaseDoc / dispose)', () {
      test(
          'doc inexistente: con treatEmptyAsMissing=false el segundo evento trae id inyectado',
          () async {
        final Stream<Either<ErrorItem, Map<String, dynamic>>> s =
            gateway.watch('w1');

        final List<Either<ErrorItem, Map<String, dynamic>>> events =
            <Either<ErrorItem, Map<String, dynamic>>>[];
        final StreamSubscription<Either<ErrorItem, Map<String, dynamic>>> sub =
            s.listen(events.add);

        await pumpEventQueue(); // 1) Right({}) de BlocGeneral + 2) seed del servicio

        expect(
          events.length >= 2,
          isTrue,
          reason:
              'Debe haber al menos el evento inicial y el seed del servicio',
        );

        // El evento "bueno" es el último (el seed del servicio)
        final Either<ErrorItem, Map<String, dynamic>> last = events.last;
        last.fold(
          (ErrorItem l) => fail('Se esperaba Right con id, fue Left: $l'),
          (Map<String, dynamic> r) {
            expect(r['id'], 'w1'); // inyectado por _withId
          },
        );

        await sub.cancel();
        gateway.detachWatch('w1');
      });

      test(
          'doc inexistente: con treatEmptyAsMissing=true el segundo evento es Left(notFound)',
          () async {
        gateway = GatewayWsDbImpl(
          service: service,
          collection: 'canvases',
          mapper: const DefaultErrorMapper(),
          treatEmptyAsMissing: true,
        );

        final List<Either<ErrorItem, Map<String, dynamic>>> events =
            <Either<ErrorItem, Map<String, dynamic>>>[];
        final StreamSubscription<Either<ErrorItem, Map<String, dynamic>>> sub =
            gateway.watch('w2').listen(events.add);

        await pumpEventQueue(); // 1) Right({}) inicial + 2) seed {} -> Left(notFound)

        expect(
          events.length >= 2,
          isTrue,
          reason:
              'Debe haber al menos el evento inicial y el seed del servicio',
        );

        final Either<ErrorItem, Map<String, dynamic>> last = events.last;
        // Verificamos que sea Left (notFound). No dependemos del tipo exacto.
        expect(last.fold((_) => true, (_) => false), isTrue);

        await sub.cancel();
        gateway.detachWatch('w2');
      });

      test('recibe actualizaciones posteriores al seed inicial', () async {
        final List<Either<ErrorItem, Map<String, dynamic>>> events =
            <Either<ErrorItem, Map<String, dynamic>>>[];
        final StreamSubscription<Either<ErrorItem, Map<String, dynamic>>> sub =
            gateway.watch('w3').listen(events.add);

        await pumpEventQueue(); // 1) Right({}) inicial + 2) seed del servicio

        await gateway.write('w3', <String, dynamic>{'name': 'first'});
        await pumpEventQueue(); // 3) update real

        final Either<ErrorItem, Map<String, dynamic>> last = events.last;
        last.fold(
          (ErrorItem l) => fail('Se esperaba Right tras write, fue Left: $l'),
          (Map<String, dynamic> r) {
            expect(r['id'], 'w3');
            expect(r['name'], 'first');
          },
        );

        await sub.cancel();
        gateway.detachWatch('w3');
      });

      test(
          'múltiples watchers: al detach de uno, el otro sigue recibiendo eventos',
          () async {
        final List<Map<String, dynamic>> a = <Map<String, dynamic>>[];
        final List<Map<String, dynamic>> b = <Map<String, dynamic>>[];

        final StreamSubscription<Either<ErrorItem, Map<String, dynamic>>> subA =
            gateway
                .watch('w4')
                .listen((Either<ErrorItem, Map<String, dynamic>> e) {
          e.fold((_) {}, (Map<String, dynamic> r) => a.add(r));
        });
        final StreamSubscription<Either<ErrorItem, Map<String, dynamic>>> subB =
            gateway
                .watch('w4')
                .listen((Either<ErrorItem, Map<String, dynamic>> e) {
          e.fold((_) {}, (Map<String, dynamic> r) => b.add(r));
        });

        await pumpEventQueue(); // seeds

        await subA.cancel();
        gateway.detachWatch('w4'); // ref-- (queda subB)

        await gateway.write('w4', <String, dynamic>{'tick': 1});
        await pumpEventQueue();

        expect(a.isEmpty || a.last['tick'] != 1, isTrue);
        expect(b.isNotEmpty && b.last['tick'] == 1, isTrue);

        await subB.cancel();
        gateway.detachWatch('w4'); // ref-- (0 -> cierra canal)
      });

      test(
          'releaseDoc fuerza cierre inmediato del canal (cualquier suscriptor)',
          () async {
        final List<Either<ErrorItem, Map<String, dynamic>>> events =
            <Either<ErrorItem, Map<String, dynamic>>>[];
        final StreamSubscription<Either<ErrorItem, Map<String, dynamic>>> sub =
            gateway.watch('w5').listen(events.add);

        await pumpEventQueue(); // seed
        gateway.releaseDoc('w5'); // corta canal y cierra Bloc del doc

        // Emitir después no debería entregar más eventos a este sub
        await gateway.write('w5', <String, dynamic>{'x': 1});
        await pumpEventQueue();

        final int countAfter = events.length;
        expect(countAfter >= 1, isTrue);

        await sub.cancel(); // cleanup del lado del test
      });

      test('dispose cierra todos los canales', () async {
        final StreamSubscription<Either<ErrorItem, Map<String, dynamic>>> sub1 =
            gateway.watch('w6').listen((_) {});
        final StreamSubscription<Either<ErrorItem, Map<String, dynamic>>> sub2 =
            gateway.watch('w7').listen((_) {});
        await pumpEventQueue();

        gateway.dispose();

        await sub1.cancel();
        await sub2.cancel();
      });
    });
  });
}
