import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('BlocLoading group 1', () {
    late BlocLoading bloc;

    setUp(() {
      // Configuración inicial antes de cada prueba
      bloc = BlocLoading();
    });

    test('clearLoading should clear the loadingMsg', () {
      bloc.loadingMsg = 'Loading in progress...';
      bloc.clearLoading();
      expect(bloc.loadingMsg, '');
    });

    test(
        'loadingMsgWithFuture should set loadingMsg and clear it after completion',
        () async {
      const String msg = 'Loading in progress...';
      bool isFCompleted = false;

      await bloc.loadingMsgWithFuture(msg, () async {
        // Simulamos una tarea asíncrona
        await Future<void>.delayed(const Duration(seconds: 1));
        isFCompleted = true;
      });

      expect(bloc.loadingMsg, '');
      expect(bloc.isLoading, isFalse);
      expect(isFCompleted, true);
    });

    test('loadingMsgWithFuture should not set loadingMsg if it is not empty',
        () async {
      bloc.loadingMsg = 'Loading in progress...';
      bool isFCompleted = false;
      bloc.clearLoading();
      bloc.loadingMsgWithFuture('Another loading...', () async {
        await Future<void>.delayed(const Duration(seconds: 1));
        isFCompleted = true;
      });

      expect(bloc.loadingMsg, 'Another loading...');
      await Future<void>.delayed(
        const Duration(seconds: 1),
      );
      expect(bloc.loadingMsg, '');
      expect(isFCompleted, true);
    });
  });

  group('BlocLoading group 1', () {
    late BlocLoading blocLoading;

    setUp(() {
      blocLoading = BlocLoading();
    });

    tearDown(() {
      blocLoading.dispose();
    });

    test('Initial loading message is empty', () {
      expect(blocLoading.loadingMsg, '');
    });

    test('Setting loading message updates the value', () {
      blocLoading.loadingMsg = 'Loading...';
      expect(blocLoading.loadingMsg, 'Loading...');
    });

    testWidgets('Stream emits correct loading message',
        (WidgetTester tester) async {
      const String expectedMessage = 'Loading...';
      String emittedMessage = '';

      final StreamSubscription<String> subscription =
          blocLoading.loadingMsgStream.listen((String message) {
        emittedMessage = message;
      });

      blocLoading.loadingMsg = expectedMessage;
      await tester.pump();
      expect(emittedMessage, expectedMessage);

      subscription.cancel();
    });
  });
  group('BlocLoading group 1', () {
    test('initial state is empty and not loading', () {
      final BlocLoading bloc = BlocLoading();
      expect(bloc.loadingMsg, '');
      expect(bloc.isLoading, isFalse);
      bloc.dispose();
    });

    test('set and clear loading message updates stream', () async {
      final BlocLoading bloc = BlocLoading();
      final List<String> emissions = <String>[];

      final StreamSubscription<String> sub =
          bloc.loadingMsgStream.listen(emissions.add);

      bloc.loadingMsg = 'Working...';
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(bloc.loadingMsg, 'Working...');
      expect(bloc.isLoading, isTrue);

      bloc.clearLoading();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(bloc.loadingMsg, '');
      expect(bloc.isLoading, isFalse);

      await sub.cancel();
      bloc.dispose();

      // Debe haber al menos dos emisiones: 'Working...' y luego ''.
      expect(emissions, containsAllInOrder(<String>['Working...', '']));
    });

    test('loadingMsgWithFuture sets message and clears after success',
        () async {
      final BlocLoading bloc = BlocLoading();
      Future<void> job() async {
        expect(bloc.isLoading, isTrue); // Debe estar activo mientras corre
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      await bloc.loadingMsgWithFuture('Please wait', job);
      expect(bloc.isLoading, isFalse);
      expect(bloc.loadingMsg, '');
      bloc.dispose();
    });

    test('loadingMsgWithFuture clears after exception', () async {
      final BlocLoading bloc = BlocLoading();
      Future<void> failingJob() async {
        throw StateError('boom');
      }

      await expectLater(
        () => bloc.loadingMsgWithFuture('Failing...', failingJob),
        throwsA(isA<StateError>()),
      );

      // A pesar del error, debe limpiar el estado.
      expect(bloc.isLoading, isFalse);
      expect(bloc.loadingMsg, '');
      bloc.dispose();
    });

    test('overlapping calls are ignored (second action not executed)',
        () async {
      final BlocLoading bloc = BlocLoading();

      final Completer<void> firstStarted = Completer<void>();
      final Completer<void> firstDone = Completer<void>();

      bool secondExecuted = false;

      // Primera: larga
      unawaited(
        bloc.loadingMsgWithFuture('Long task', () async {
          firstStarted.complete();
          await Future<void>.delayed(const Duration(milliseconds: 20));
          firstDone.complete();
        }),
      );

      // Espera a que empiece
      await firstStarted.future;

      // Segunda: debería ser ignorada
      await bloc.loadingMsgWithFuture('Another task', () async {
        secondExecuted = true;
      });

      // Termina la primera
      await firstDone.future;

      // Estado limpio
      expect(bloc.isLoading, isFalse);
      expect(secondExecuted, isFalse);

      bloc.dispose();
    });
  });
  group('BlocLoading — extras (loadingWhile, isLoadingStream, queue)', () {
    test('loadingWhile returns value and honors minShow (anti-flicker)',
        () async {
      final BlocLoading bloc = BlocLoading();

      final DateTime t0 = DateTime.now();
      final int value = await bloc.loadingWhile<int>(
        'Quick task',
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return 7;
        },
        minShow: const Duration(milliseconds: 60),
      );
      final Duration elapsed = DateTime.now().difference(t0);

      expect(value, 7);
      expect(bloc.isLoading, isFalse);
      // Debe respetar al menos el minShow (~60ms).
      expect(
        elapsed.inMilliseconds >= 55,
        isTrue,
        reason: 'Elapsed ${elapsed.inMilliseconds}ms should be >= ~55ms',
      );

      bloc.dispose();
    });

    test('isLoadingStream emits true then false (distinct)', () async {
      final BlocLoading bloc = BlocLoading();
      final List<bool> emissions = <bool>[];

      final StreamSubscription<bool> sub =
          bloc.isLoadingStream.listen(emissions.add);

      // Dispara un ciclo de carga.
      await bloc.loadingMsgWithFuture('One', () async {
        expect(bloc.isLoading, isTrue);
        await Future<void>.delayed(const Duration(milliseconds: 5));
      });

      await sub.cancel();
      bloc.dispose();

      expect(emissions, <bool>[false, true]);
    });

    test('queueLoadingWhile runs tasks sequentially (FIFO) and returns results',
        () async {
      final BlocLoading bloc = BlocLoading();
      final List<int> order = <int>[];
      final List<DateTime> starts = <DateTime>[];
      final List<DateTime> ends = <DateTime>[];

      Future<int> task(int id, int ms) async {
        starts.add(DateTime.now());
        await Future<void>.delayed(Duration(milliseconds: ms));
        order.add(id);
        ends.add(DateTime.now());
        return id;
      }

      final Future<int> f1 = bloc.queueLoadingWhile<int>(
        'T1',
        () => task(1, 30),
      );
      final Future<int> f2 = bloc.queueLoadingWhile<int>(
        'T2',
        () => task(2, 20),
      );
      final Future<int> f3 = bloc.queueLoadingWhile<int>(
        'T3',
        () => task(3, 10),
      );

      final List<int> results = await Future.wait(<Future<int>>[f1, f2, f3]);

      expect(results, <int>[1, 2, 3]);
      expect(order, <int>[1, 2, 3]);

      // Asegura serialización (inicio de cada uno después de finalizar el previo).
      expect(starts.length, 3);
      expect(ends.length, 3);
      expect(
        starts[1].isAfter(ends[0]) || starts[1].isAtSameMomentAs(ends[0]),
        isTrue,
      );
      expect(
        starts[2].isAfter(ends[1]) || starts[2].isAtSameMomentAs(ends[1]),
        isTrue,
      );

      expect(bloc.isLoading, isFalse);
      bloc.dispose();
    });

    test('loadingWhile runs action even if already loading (no visual change)',
        () async {
      final BlocLoading bloc = BlocLoading();
      final Completer<void> started = Completer<void>();

      // Inicia una carga larga (mantiene el spinner activo).
      unawaited(
        bloc.loadingMsgWithFuture('Long…', () async {
          started.complete();
          await Future<void>.delayed(const Duration(milliseconds: 40));
        }),
      );

      await started.future;

      // Segunda acción: debe ejecutarse y retornar, sin tocar el visual actual.
      final int val = await bloc.loadingWhile<int>(
        'Should not override',
        () async {
          // Mientras corre, sigue habiendo loading activo por la primera.
          expect(bloc.isLoading, isTrue);
          return 99;
        },
      );

      expect(val, 99);

      // Espera un poco a que termine la primera y limpie.
      await Future<void>.delayed(const Duration(milliseconds: 45));
      expect(bloc.isLoading, isFalse);
      bloc.dispose();
    });
  });
}
