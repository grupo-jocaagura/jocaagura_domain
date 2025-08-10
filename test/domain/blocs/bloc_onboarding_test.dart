import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  late BlocOnboarding blocOnboarding;
  late StreamSubscription<String> subscription;

  setUp(() {
    blocOnboarding = BlocOnboarding(
      <FutureOr<void> Function()>[],
      delayInSeconds: 0,
      startingMsg: 'Empezando',
      workingMsg: 'pendientes',
      finishedMsg: 'Finalizado',
    );
    subscription = blocOnboarding.msgStream.listen((_) {});
  });

  tearDown(() async {
    await subscription.cancel();
    await blocOnboarding.dispose();
  });
  group('BlocOnboarding Constructor', () {
    test('Inicializa con mensajes y delay personalizados', () {
      final BlocOnboarding bloc = BlocOnboarding(
        <FutureOr<void> Function()>[() async {}],
        delayInSeconds: 3,
        startingMsg: 'Preparando',
        workingMsg: 'faltantes',
        finishedMsg: 'Listo',
      );
      expect(bloc.delayInSeconds, 3);
      expect(bloc.startingMsg, 'Preparando');
      expect(bloc.workingMsg, 'faltantes');
      expect(bloc.finishedMsg, 'Listo');
      expect(bloc.msg, '');
      expect(bloc.progress, 0.0);
    });

    test('Copia la lista inicial, permitiendo listas inmutables', () {
      final List<FutureOr<void> Function()> unmod =
          List<FutureOr<void> Function()>.unmodifiable(<dynamic>[() async {}]);
      final BlocOnboarding bloc = BlocOnboarding(unmod);
      expect(() => bloc.addFunction(() async {}), returnsNormally);
    });

    test('El assert de delay funciona', () {
      expect(
          () =>
              BlocOnboarding(<FutureOr<void> Function()>[], delayInSeconds: -1),
          throwsA(isA<AssertionError>()));
    });
  });
  group('msg y msgStream', () {
    late BlocOnboarding bloc;
    StreamSubscription<String>? sub;

    setUp(() {
      bloc = BlocOnboarding(
        <FutureOr<void> Function()>[],
        startingMsg: 'Inicializando',
      );
    });

    tearDown(() async {
      await sub?.cancel();
      await bloc.dispose();
    });

    test('msg retorna el valor inicial', () {
      expect(bloc.msg, '');
    });

    test('msgStream emite valores durante la ejecución', () async {
      final List<String> messages = <String>[];
      sub = bloc.msgStream.listen(messages.add);

      bloc.addFunction(() async {});
      bloc.addFunction(() async {});
      await bloc.execute(Duration.zero);

      expect(messages[1], 'Inicializando');
      expect(messages, contains('1 working'));
      expect(messages.last, 'Completed');
    });
  });
  group('progress y progressStream', () {
    late BlocOnboarding bloc;
    StreamSubscription<double>? sub;

    setUp(() {
      bloc = BlocOnboarding(<FutureOr<void> Function()>[]);
    });

    tearDown(() async {
      await sub?.cancel();
      await bloc.dispose();
    });

    test('progress es 0.0 al inicio', () {
      expect(bloc.progress, 0.0);
    });

    test('progressStream emite progreso durante la ejecución', () async {
      final List<double> progresses = <double>[];
      sub = bloc.progressStream.listen(progresses.add);

      bloc.addFunction(() async {});
      bloc.addFunction(() async {});
      await bloc.execute(Duration.zero);

      expect(progresses, contains(0.5));
      expect(progresses.last, 1.0);
    });
  });
  group('addFunction', () {
    late BlocOnboarding bloc;
    setUp(() {
      bloc = BlocOnboarding(<FutureOr<void> Function()>[]);
    });

    tearDown(() => bloc.dispose());

    test('Agrega tareas y retorna el tamaño actualizado', () {
      int size1 = bloc.addFunction(() async {});
      int size2 = bloc.addFunction(() async {});
      expect(size1, 1);
      expect(size2, 2);
    });

    test('Permite agregar tareas tras ejecutar o limpiar', () async {
      bloc.addFunction(() async {});
      await bloc.execute(Duration.zero);
      bloc.clearFunctions();
      expect(bloc.addFunction(() async {}), 1);
    });
  });
  group('clearFunctions', () {
    late BlocOnboarding bloc;
    setUp(() {
      bloc = BlocOnboarding(<FutureOr<void> Function()>[]);
    });

    tearDown(() => bloc.dispose());

    test('Limpia todas las funciones', () {
      bloc.addFunction(() async {});
      bloc.addFunction(() async {});
      bloc.clearFunctions();
      expect(() async => await bloc.execute(Duration.zero), returnsNormally);
    });

    test('No altera msg ni progress', () {
      bloc.addFunction(() async {});
      bloc.clearFunctions();
      expect(bloc.msg, '');
      expect(bloc.progress, 0.0);
    });
  });
  group('execute', () {
    late BlocOnboarding bloc;

    setUp(() {
      bloc = BlocOnboarding(<FutureOr<void> Function()>[]);
    });

    tearDown(() => bloc.dispose());

    test('Ejecuta tareas en orden', () async {
      final List<String> calls = <String>[];
      bloc.addFunction(() async => calls.add('a'));
      bloc.addFunction(() async => calls.add('b'));
      await bloc.execute(Duration.zero);
      expect(calls, <String>['a', 'b']);
    });

    test('Maneja errores con onError', () async {
      Object? caught;
      bloc = BlocOnboarding(
          <FutureOr<void> Function()>[() => throw Exception('fail')],
          onError: (Object e, StackTrace s) => caught = e);
      await bloc.execute(Duration.zero);
      expect(caught, isA<Exception>());
    });

    test('Emite el mensaje final solo si hay tareas', () async {
      final List<String> messages = <String>[];
      final StreamSubscription<String> sub =
          bloc.msgStream.listen(messages.add);
      await bloc.execute(Duration.zero);
      // Si no hay tareas, solo se emite el inicial
      expect(messages, <String>[
        '',
      ]);
      await sub.cancel();
    });

    test('Respeta el delay dado', () async {
      bloc.addFunction(() async {});
      final Stopwatch sw = Stopwatch()..start();
      await bloc.execute(const Duration(milliseconds: 200));
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(180)); // margen
    });

    test('Puede ejecutarse varias veces', () async {
      bloc.addFunction(() async {});
      await bloc.execute(Duration.zero);
      bloc.addFunction(() async {});
      await bloc.execute(Duration.zero);
      expect(bloc.progress, 1.0);
    });
  });
  group('dispose', () {
    late BlocOnboarding bloc;

    setUp(() {
      bloc = BlocOnboarding(<FutureOr<void> Function()>[]);
    });

    test('Libera recursos sin errores, incluso al llamar varias veces',
        () async {
      await bloc.dispose();
      await bloc.dispose();
    });
  });
}
