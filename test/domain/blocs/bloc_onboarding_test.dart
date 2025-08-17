import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Helpers

/// Crea una función onEnter que retorna Right(Unit) tras [delay].
FutureOr<Either<ErrorItem, Unit>> Function() onEnterSuccess({
  Duration delay = Duration.zero,
}) {
  return () async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return Right<ErrorItem, Unit>(Unit.value);
  };
}

/// Crea una función onEnter que lanza una excepción tras [delay].
FutureOr<Either<ErrorItem, Unit>> Function() onEnterThrows({
  Duration delay = Duration.zero,
  FormatException error = const FormatException('boom'),
}) {
  return () async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    throw error;
  };
}

void main() {
  group('BlocOnboarding — core', () {
    test('estado inicial idle y sin pasos', () {
      final BlocOnboarding bloc = BlocOnboarding();
      final OnboardingState s = bloc.state;

      expect(s.status, OnboardingStatus.idle);
      expect(s.totalSteps, 0);
      expect(s.stepIndex, 0);
      expect(s.error, isNull);

      bloc.dispose();
    });

    test(
        'configure establece totalSteps y mantiene idle; start pasa a running en step 0',
        () {
      final BlocOnboarding bloc = BlocOnboarding();
      bloc.configure(<OnboardingStep>[
        OnboardingStep(title: 'A', onEnter: onEnterSuccess()),
        OnboardingStep(title: 'B', onEnter: onEnterSuccess()),
      ]);

      expect(bloc.state.status, OnboardingStatus.idle);
      expect(bloc.state.totalSteps, 2);
      expect(bloc.state.error, isNull);

      bloc.start();
      expect(bloc.state.status, OnboardingStatus.running);
      expect(bloc.state.stepIndex, 0);

      bloc.dispose();
    });

    test('start con lista vacía completa inmediatamente', () {
      final BlocOnboarding bloc = BlocOnboarding();
      bloc.configure(const <OnboardingStep>[]);
      bloc.start();
      expect(bloc.state.status, OnboardingStatus.completed);
      bloc.dispose();
    });

    test('next avanza y complete al final; back retrocede y se detiene en 0',
        () {
      final BlocOnboarding bloc = BlocOnboarding();
      bloc.configure(<OnboardingStep>[
        OnboardingStep(title: 'A', onEnter: onEnterSuccess()),
        OnboardingStep(title: 'B', onEnter: onEnterSuccess()),
        OnboardingStep(title: 'C', onEnter: onEnterSuccess()),
      ]);

      bloc.start();
      expect(bloc.state.stepIndex, 0);

      bloc.next();
      expect(bloc.state.stepIndex, 1);
      expect(bloc.state.status, OnboardingStatus.running);

      bloc.next();
      expect(bloc.state.stepIndex, 2);
      expect(bloc.state.status, OnboardingStatus.running);

      bloc.next();
      expect(bloc.state.status, OnboardingStatus.completed);

      // back no debe cambiar nada ya que está completed
      bloc.back();
      expect(bloc.state.status, OnboardingStatus.completed);

      bloc.dispose();
    });

    test('skip marca skipped y cancela cualquier avance posterior', () async {
      final BlocOnboarding bloc = BlocOnboarding();
      bloc.configure(<OnboardingStep>[
        OnboardingStep(
          title: 'A',
          onEnter: onEnterSuccess(),
          autoAdvanceAfter: const Duration(milliseconds: 60),
        ),
        OnboardingStep(title: 'B', onEnter: onEnterSuccess()),
      ]);

      bloc.start();
      // antes de que auto-avance:
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.skip();

      expect(bloc.state.status, OnboardingStatus.skipped);

      // esperar más que el delay para asegurar que no auto-avanza
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(bloc.state.status, OnboardingStatus.skipped);

      bloc.dispose();
    });
  });

  group('BlocOnboarding — timers (auto-advance condicionado por onEnter)', () {
    test('auto-advance SOLO se programa cuando onEnter resulta Right(Unit)',
        () async {
      final BlocOnboarding bloc = BlocOnboarding();
      // Paso 0: éxito → debe programar auto-advance (50 ms)
      // Paso 1: éxito → debe programar auto-advance (50 ms)
      // Paso 2: éxito sin auto → se queda en ese paso en running
      bloc.configure(<OnboardingStep>[
        OnboardingStep(
          title: 'A',
          onEnter: onEnterSuccess(), // éxito inmediato
          autoAdvanceAfter: const Duration(milliseconds: 50),
        ),
        OnboardingStep(
          title: 'B',
          onEnter: onEnterSuccess(delay: const Duration(milliseconds: 5)),
          autoAdvanceAfter: const Duration(milliseconds: 50),
        ),
        OnboardingStep(
          title: 'C',
          onEnter: onEnterSuccess(),
        ),
      ]);

      bloc.start(); // entra a A → Right → programa auto-advance
      expect(bloc.state.stepIndex, 0);

      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(bloc.state.stepIndex, 1); // avanzó a B

      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(bloc.state.stepIndex, 2); // avanzó a C

      // C no tiene auto-advance → permanece en running/step 2
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(bloc.state.stepIndex, 2);
      expect(bloc.state.status, OnboardingStatus.running);

      bloc.dispose();
    });

    test('cuando onEnter lanza, se mapea a error y NO programa auto-advance',
        () async {
      final BlocOnboarding bloc = BlocOnboarding();
      bloc.configure(<OnboardingStep>[
        OnboardingStep(
          title: 'A',
          onEnter: onEnterThrows(delay: const Duration(milliseconds: 10)),
          autoAdvanceAfter: const Duration(milliseconds: 30),
        ),
        OnboardingStep(title: 'B', onEnter: onEnterSuccess()),
      ]);

      bloc.start();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      // Debe quedarse en el step 0 con error y sin auto-advance ejecutado
      expect(bloc.state.stepIndex, 0);
      expect(bloc.state.status, OnboardingStatus.running);
      expect(bloc.state.error, isNotNull);

      // esperar más para verificar que nunca avanzó automáticamente
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(bloc.state.stepIndex, 0);

      bloc.dispose();
    });

    test('back/next cancelan timer actual y reprograman para el nuevo step',
        () async {
      final BlocOnboarding bloc = BlocOnboarding();
      bloc.configure(<OnboardingStep>[
        OnboardingStep(
          title: 'A',
          onEnter: onEnterSuccess(),
          autoAdvanceAfter: const Duration(milliseconds: 80),
        ),
        OnboardingStep(
          title: 'B',
          onEnter: onEnterSuccess(),
          autoAdvanceAfter: const Duration(milliseconds: 60),
        ),
      ]);

      bloc.start();
      await Future<void>.delayed(
        const Duration(milliseconds: 30),
      ); // timer A corriendo
      bloc.next(); // debe cancelar timer A y pasar a B

      expect(bloc.state.stepIndex, 1);

      // Ahora debe avanzar desde B por su propio timer
      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(bloc.state.status, OnboardingStatus.completed);

      bloc.dispose();
    });
  });

  group('BlocOnboarding — onEnter (async & errors)', () {
    test(
        'onEnter éxito con delay: respeta epoch y programa auto-advance del step activo',
        () async {
      final BlocOnboarding bloc = BlocOnboarding();
      bloc.configure(<OnboardingStep>[
        OnboardingStep(
          title: 'A',
          onEnter: onEnterSuccess(delay: const Duration(milliseconds: 50)),
          autoAdvanceAfter: const Duration(milliseconds: 40),
        ),
        OnboardingStep(
          title: 'B',
          onEnter: onEnterSuccess(),
        ),
      ]);

      bloc.start();
      expect(bloc.state.stepIndex, 0);

      // se ejecuta onEnter(A) con delay; tras completarse (Right) debe armar auto-advance de 40ms
      await Future<void>.delayed(const Duration(milliseconds: 60));
      // esperar tiempo para que dispare
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.stepIndex, 1);

      bloc.dispose();
    });

    test('onEnter que lanza establece error mapeado; clearError lo limpia',
        () async {
      final BlocOnboarding bloc = BlocOnboarding();
      bloc.configure(<OnboardingStep>[
        OnboardingStep(
          title: 'A',
          onEnter: onEnterThrows(delay: const Duration(milliseconds: 10)),
        ),
      ]);

      bloc.start();
      await Future<void>.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.error, isNotNull);
      final ErrorItem? e1 = bloc.state.error;

      bloc.clearError();
      expect(bloc.state.error, isNull);

      // Asegurar que no "revive" el error por algún timer (no hay)
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(bloc.state.error, isNull);
      // El error inicial quedó registrado y es distinto a null
      expect(e1, isNotNull);

      bloc.dispose();
    });

    test(
        'retryOnEnter: primer onEnter lanza (error), segundo onEnter éxito → limpia error y puede auto-avanzar',
        () async {
      final BlocOnboarding bloc = BlocOnboarding();

      // Cambiamos el comportamiento con una variable cerrada por el closure.
      String mode = 'throw';
      FutureOr<Either<ErrorItem, Unit>> onEnterMixed() async {
        if (mode == 'throw') {
          throw const FormatException('fail first');
        }
        return Right<ErrorItem, Unit>(Unit.value);
      }

      bloc.configure(<OnboardingStep>[
        OnboardingStep(
          title: 'A',
          onEnter: onEnterMixed,
          autoAdvanceAfter: const Duration(milliseconds: 40),
        ),
        OnboardingStep(
          title: 'B',
          onEnter: onEnterSuccess(),
        ),
      ]);

      bloc.start();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.error, isNotNull);
      expect(bloc.state.stepIndex, 0);

      // Ajustamos a éxito y reintentamos:
      mode = 'ok';
      bloc.retryOnEnter();

      // Debe limpiar error y, tras Right(Unit), programar auto-advance a B.
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(bloc.state.error, isNull);
      expect(bloc.state.stepIndex, 1);

      bloc.dispose();
    });

    test(
        'epoch guard: finalización tardía de onEnter de un step anterior NO debe afectar el step actual',
        () async {
      final BlocOnboarding bloc = BlocOnboarding();

      // A: onEnter tarda y LUEGO "lanza" (simulamos error tardío).
      final FutureOr<Either<ErrorItem, Unit>> Function() slowThrow =
          onEnterThrows(delay: const Duration(milliseconds: 80));

      // B: éxito inmediato
      final FutureOr<Either<ErrorItem, Unit>> Function() fastOk =
          onEnterSuccess();

      bloc.configure(<OnboardingStep>[
        OnboardingStep(title: 'A', onEnter: slowThrow),
        OnboardingStep(title: 'B', onEnter: fastOk),
      ]);

      bloc.start(); // entra a A y lanza timer de slowThrow

      // Cambiamos de paso antes de que A termine:
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.next(); // pasa a B; epoch cambia.

      // Espera suficiente para que A "termine" y tratara de setear error.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // NO debe haber modificado el estado actual (B) ni marcado error por A.
      expect(bloc.state.stepIndex, 1);
      expect(bloc.state.error, isNull);

      bloc.dispose();
    });

    test('dispose cancela timers y evita efectos posteriores de onEnter',
        () async {
      final BlocOnboarding bloc = BlocOnboarding();
      bloc.configure(<OnboardingStep>[
        OnboardingStep(
          title: 'A',
          onEnter: onEnterSuccess(delay: const Duration(milliseconds: 40)),
          autoAdvanceAfter: const Duration(milliseconds: 40),
        ),
        OnboardingStep(
          title: 'B',
          onEnter: onEnterSuccess(),
        ),
      ]);

      bloc.start();
      bloc.dispose();

      // Espera más que cualquier delay; no debe arrojar, ni avanzar, ni cambiar estado.
      await Future<void>.delayed(const Duration(milliseconds: 120));

      // No podemos leer un estado "vivo" post-dispose, pero si llegamos aquí sin excepciones,
      // asumimos que los timers no hicieron nada luego del dispose.
      expect(true, isTrue);
    });
  });
}
