import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('BlocOnboarding – configuración y arranque', () {
    late BlocOnboarding bloc;
    setUp(() {
      bloc = BlocOnboarding();
    });

    tearDown(() {
      bloc.dispose();
    });

    test('Given configure([]) When start() Then completed inmediatamente',
        () async {
      // Arrange
      bloc.configure(<OnboardingStep>[]);

      // Act
      bloc.start();

      // Assert
      expect(bloc.state.status, OnboardingStatus.completed);
      expect(bloc.state.totalSteps, 0);
      expect(bloc.state.error, isNull);
    });

    test('Given configure(steps) When start() Then running en step 0',
        () async {
      // Arrange
      final List<OnboardingStep> steps = <OnboardingStep>[
        const OnboardingStep(title: 'A'),
        const OnboardingStep(title: 'B'),
      ];
      bloc.configure(steps);

      // Act
      bloc.start();

      // Assert
      expect(bloc.state.status, OnboardingStatus.running);
      expect(bloc.state.stepIndex, 0);
      expect(bloc.state.totalSteps, 2);
      expect(bloc.currentStep?.title, 'A');
    });
  });

  group('BlocOnboarding – onEnter éxito y error', () {
    late BlocOnboarding bloc;
    setUp(() {
      bloc = BlocOnboarding();
    });

    tearDown(() {
      bloc.dispose();
    });

    test(
        'Given onEnter Right When start Then no error y puede auto-advance si aplica',
        () async {
      // Arrange
      final OnboardingStep step = OnboardingStep(
        title: 'ok',
        autoAdvanceAfter: const Duration(milliseconds: 40),
        onEnter: () async {
          // Simular trabajo asíncrono rápido
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return Right<ErrorItem, Unit>(Unit.value);
        },
      );
      const OnboardingStep step2 = OnboardingStep(title: 'next');
      bloc.configure(<OnboardingStep>[step, step2]);

      // Act
      bloc.start();
      // Esperar más que el autoAdvanceAfter
      await Future<void>.delayed(const Duration(milliseconds: 70));

      // Assert: avanzó al siguiente paso (index 1), sin error
      expect(bloc.state.status, OnboardingStatus.running);
      expect(bloc.state.stepIndex, 1);
      expect(bloc.state.error, isNull);
      expect(bloc.currentStep?.title, 'next');
    });

    test('Given onEnter Left When start Then coloca error y no auto-advance',
        () async {
      // Arrange
      final OnboardingStep step = OnboardingStep(
        title: 'fail',
        autoAdvanceAfter: const Duration(milliseconds: 20),
        onEnter: () async {
          return Left<ErrorItem, Unit>(
            const ErrorItem(
              title: 'X',
              code: 'ERR',
              description: 'boom',
            ),
          );
        },
      );
      const OnboardingStep step2 = OnboardingStep(title: 'next');
      bloc.configure(<OnboardingStep>[step, step2]);

      // Act
      bloc.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Assert: sigue en el mismo paso, con error
      expect(bloc.state.stepIndex, 0);
      expect(bloc.state.error, isNotNull);
      expect(bloc.currentStep?.title, 'fail');
    });

    test(
        'Given onEnter lanza excepción When start Then mapea a ErrorItem y no auto-advance',
        () async {
      // Arrange
      final OnboardingStep step = OnboardingStep(
        title: 'throw',
        autoAdvanceAfter: const Duration(milliseconds: 20),
        onEnter: () {
          throw StateError('should not throw per contract');
        },
      );
      const OnboardingStep step2 = OnboardingStep(title: 'next');
      bloc.configure(<OnboardingStep>[step, step2]);

      // Act
      bloc.start();
      // Dar tiempo para captura y mapeo de excepción
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Assert: error mapeado y sin avance automático
      expect(bloc.state.stepIndex, 0);
      expect(bloc.state.error, isNotNull);
    });
  });

  group('BlocOnboarding – retryOnEnter y clearError', () {
    late BlocOnboarding bloc;
    setUp(() {
      bloc = BlocOnboarding();
    });

    tearDown(() {
      bloc.dispose();
    });

    test(
        'Given error en onEnter When retryOnEnter Then limpia error y reintenta',
        () async {
      // Arrange: primer intento falla, segundo intento pasa
      int attempts = 0;
      final OnboardingStep step = OnboardingStep(
        title: 'retry',
        onEnter: () async {
          attempts++;
          if (attempts == 1) {
            return Left<ErrorItem, Unit>(
              const ErrorItem(
                title: 'F',
                code: 'E1',
                description: 'first',
              ),
            );
          }
          return Right<ErrorItem, Unit>(Unit.value);
        },
        autoAdvanceAfter: const Duration(milliseconds: 20),
      );
      // autoAdvance para confirmar ejecución tras el retry
      const OnboardingStep step2 = OnboardingStep(
        title: 'next',
        autoAdvanceAfter: Duration(milliseconds: 30),
      );
      bloc.configure(<OnboardingStep>[step, step2]);

      // Act: start -> primer onEnter falla
      bloc.start();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.error, isNotNull);

      // retry: limpia error y reintenta
      bloc.retryOnEnter();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Assert: ya no hay error y avanzó por auto-advance
      expect(bloc.state.error, isNull);
      expect(bloc.state.stepIndex, 1);
      expect(attempts, equals(2));
    });

    test('clearError limpia el error manteniendo step/status', () async {
      // Arrange
      final OnboardingStep step = OnboardingStep(
        title: 'fail',
        onEnter: () async => Left<ErrorItem, Unit>(
          const ErrorItem(
            title: 'X',
            code: 'ERR',
            description: 'boom',
          ),
        ),
      );
      bloc.configure(<OnboardingStep>[step]);
      bloc.start();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.error, isNotNull);

      // Act
      bloc.clearError();

      // Assert
      expect(bloc.state.error, isNull);
      expect(bloc.state.stepIndex, 0);
      expect(bloc.state.status, OnboardingStatus.running);
    });
  });

  group('BlocOnboarding – navegación next/back y currentStep', () {
    late BlocOnboarding bloc;
    setUp(() {
      bloc = BlocOnboarding();
    });

    tearDown(() {
      bloc.dispose();
    });

    test('next avanza y back retrocede, limpiando timers y error', () async {
      // Arrange: pasos sin onEnter con pequeños autoAdvance para evidenciar cancelación
      const OnboardingStep s0 = OnboardingStep(
        title: '0',
        autoAdvanceAfter: Duration(milliseconds: 50),
      );
      const OnboardingStep s1 = OnboardingStep(
        title: '1',
        autoAdvanceAfter: Duration(milliseconds: 50),
      );
      const OnboardingStep s2 = OnboardingStep(title: '2');
      bloc.configure(<OnboardingStep>[s0, s1, s2]);

      // Act
      bloc.start(); // step 0
      expect(bloc.currentStep?.title, '0');

      bloc.next(); // step 1
      expect(bloc.currentStep?.title, '1');

      bloc.back(); // step 0
      expect(bloc.currentStep?.title, '0');

      // Esperar suficiente para que cualquier timer viejo dispare si no se canceló
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert: sigue en 0 (el timer de step 1 debió ser cancelado)
      expect(bloc.currentStep?.title, '0');
      expect(bloc.state.error, isNull);
    });

    test('currentStep es null cuando no está running o índice fuera de rango',
        () async {
      // Arrange
      bloc.configure(<OnboardingStep>[]);
      expect(bloc.currentStep, isNull);

      bloc.configure(<OnboardingStep>[const OnboardingStep(title: 'only')]);
      expect(bloc.currentStep, isNull); // aún idle
      bloc.start();
      expect(bloc.currentStep, isNotNull);
      // Forzar estado inconsistente para probar null
      bloc.complete();
      expect(bloc.currentStep, isNull);
    });
  });

  group('BlocOnboarding – guards de carrera con epoch', () {
    late BlocOnboarding bloc;
    setUp(() {
      bloc = BlocOnboarding();
    });

    tearDown(() {
      bloc.dispose();
    });

    test('onEnter lento de step 0 no debe afectar cuando ya estamos en step 1',
        () async {
      // Arrange
      final OnboardingStep slowFail = OnboardingStep(
        title: 'slow-fail',
        onEnter: () async {
          await Future<void>.delayed(const Duration(milliseconds: 60));
          return Left<ErrorItem, Unit>(
            const ErrorItem(
              title: 'late',
              code: 'LATE',
              description: 'arrived too late',
            ),
          );
        },
      );
      final OnboardingStep ok = OnboardingStep(
        title: 'ok',
        onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
      );
      bloc.configure(<OnboardingStep>[slowFail, ok]);

      // Act: iniciar y saltar al siguiente antes de que termine onEnter del 1er paso
      bloc.start(); // step 0
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.next(); // step 1
      await Future<void>.delayed(const Duration(milliseconds: 80));

      // Assert: debe mantenerse en step 1, con error == null (resultado tardío ignorado)
      expect(bloc.state.stepIndex, 1);
      expect(bloc.currentStep?.title, 'ok');
      expect(bloc.state.error, isNull);
    });
  });

  group('BlocOnboarding – terminal states y limpieza de error', () {
    late BlocOnboarding bloc;
    setUp(() {
      bloc = BlocOnboarding();
    });

    tearDown(() {
      bloc.dispose();
    });

    test('skip preserva error existente', () async {
      // Arrange
      final OnboardingStep fail = OnboardingStep(
        title: 'fail',
        onEnter: () async => Left<ErrorItem, Unit>(
          const ErrorItem(
            title: 'boom',
            code: 'ERR',
            description: 'x',
          ),
        ),
      );
      bloc.configure(<OnboardingStep>[fail]);
      bloc.start();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.error, isNotNull);

      // Act
      bloc.skip();

      // Assert
      expect(bloc.state.status, OnboardingStatus.skipped);
      expect(
        bloc.state.error,
        isNotNull,
        reason: 'política documentada: no se limpia automáticamente',
      );
    });

    test('complete preserva error existente', () async {
      // Arrange
      final OnboardingStep fail = OnboardingStep(
        title: 'fail',
        onEnter: () async => Left<ErrorItem, Unit>(
          const ErrorItem(
            title: 'boom',
            code: 'ERR',
            description: 'x',
          ),
        ),
      );
      bloc.configure(<OnboardingStep>[fail]);
      bloc.start();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.error, isNotNull);

      // Act
      bloc.complete();

      // Assert
      expect(bloc.state.status, OnboardingStatus.completed);
      expect(bloc.state.error, isNotNull);
    });
  });

  group('BlocOnboarding – dispose y timers', () {
    late BlocOnboarding bloc;
    setUp(() {
      bloc = BlocOnboarding();
    });

    test('dispose cancela timer y marca isDisposed', () async {
      // Arrange
      final OnboardingStep s0 = OnboardingStep(
        title: 'auto',
        autoAdvanceAfter: const Duration(milliseconds: 60),
        onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
      );
      const OnboardingStep s1 = OnboardingStep(title: 'next');
      bloc.configure(<OnboardingStep>[s0, s1]);
      bloc.start();

      // Debe haber programado un timer
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(bloc.timer, isNotNull);

      // Act
      bloc.dispose();

      // Assert inmediato
      expect(bloc.isDisposed, isTrue);
      expect(bloc.timer, isNull, reason: 'timer cancelado en dispose');

      // Esperar más que el delay para confirmar que no avanza
      final int prevIndex =
          bloc.state.stepIndex; // snapshot (aunque ya disposed)
      await Future<void>.delayed(const Duration(milliseconds: 80));
      // No debería haber cambiado nada tras dispose (no hay guarantees de emisión, pero el timer no debe disparar next()).
      expect(bloc.state.stepIndex, prevIndex);
    });
  });

  group('BlocOnboarding – back() NO auto-advance', () {
    late BlocOnboarding bloc;

    setUp(() {
      bloc = BlocOnboarding();
    });

    tearDown(() {
      bloc.dispose();
    });

    test(
      'Given step con autoAdvance (sin onEnter) '
      'When start -> avanza; back() '
      'Then NO auto-advance tras volver y esperar > delay',
      () async {
        // Arrange
        const OnboardingStep a = OnboardingStep(
          title: 'A',
          // Este delay auto-avanzaría normalmente, pero tras back() NO debe ocurrir.
          autoAdvanceAfter: Duration(milliseconds: 40),
        );
        const OnboardingStep b = OnboardingStep(title: 'B');

        bloc.configure(<OnboardingStep>[a, b]);

        // Act: start -> A, esperar auto-advance a B
        bloc.start();
        await Future<void>.delayed(const Duration(milliseconds: 70));
        expect(bloc.state.stepIndex, 1, reason: 'Debe haber avanzado a B');

        // back() -> vuelve a A
        bloc.back();
        expect(bloc.state.stepIndex, 0, reason: 'Volvió a A');

        // Esperar más que el delay de A; NO debe auto-avanzar
        await Future<void>.delayed(const Duration(milliseconds: 80));

        // Assert
        expect(
          bloc.state.stepIndex,
          0,
          reason:
              'Tras back() no debe auto-avanzar aunque A tenga autoAdvanceAfter',
        );
        expect(bloc.state.error, isNull);
      },
    );

    test(
      'Given step con onEnter Right + autoAdvance '
      'When start -> avanza; back() '
      'Then NO auto-advance tras volver aunque onEnter sea exitoso',
      () async {
        // Arrange
        final OnboardingStep a = OnboardingStep(
          title: 'A',
          onEnter: () async {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            return Right<ErrorItem, Unit>(Unit.value);
          },
          autoAdvanceAfter: const Duration(milliseconds: 40),
        );
        const OnboardingStep b = OnboardingStep(title: 'B');

        bloc.configure(<OnboardingStep>[a, b]);

        // Act: start -> A, esperar auto-advance a B
        bloc.start();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(bloc.state.stepIndex, 1);

        // back() -> A
        bloc.back();
        expect(bloc.state.stepIndex, 0);

        // Esperamos > autoAdvanceAfter; NO debe avanzar
        await Future<void>.delayed(const Duration(milliseconds: 80));

        // Assert
        expect(
          bloc.state.stepIndex,
          0,
          reason:
              'Tras back(), el auto-advance está deshabilitado por política del BLoC',
        );
        expect(bloc.state.error, isNull);
      },
    );

    test(
      'Given back() deshabilita auto-advance '
      'When retryOnEnter() explícito '
      'Then vuelve a habilitarse el auto-advance y avanza',
      () async {
        // Arrange
        final OnboardingStep a = OnboardingStep(
          title: 'A',
          onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
          autoAdvanceAfter: const Duration(milliseconds: 40),
        );
        const OnboardingStep b = OnboardingStep(title: 'B');

        bloc.configure(<OnboardingStep>[a, b]);

        // start -> auto-advance a B
        bloc.start();
        await Future<void>.delayed(const Duration(milliseconds: 70));
        expect(bloc.state.stepIndex, 1);

        // back() -> A, NO auto-advance
        bloc.back();
        expect(bloc.state.stepIndex, 0);
        await Future<void>.delayed(const Duration(milliseconds: 70));
        expect(
          bloc.state.stepIndex,
          0,
          reason: 'Sigue en A: back() deshabilitó el auto-advance',
        );

        // Act: retryOnEnter() (habilita de nuevo auto-advance si hay éxito)
        bloc.retryOnEnter();
        await Future<void>.delayed(const Duration(milliseconds: 70));

        // Assert: avanzó a B gracias al retry explícito
        expect(
          bloc.state.stepIndex,
          1,
          reason:
              'retryOnEnter() corre onEnter y vuelve a permitir auto-advance',
        );
      },
    );
  });
}
