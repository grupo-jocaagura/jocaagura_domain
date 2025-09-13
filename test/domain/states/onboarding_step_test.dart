import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Simula la activación de un paso:
/// - Si `onEnter` es `null`, retorna `Right(unit)`.
/// - Si `onEnter` lanza, **esto viola el contrato**; la función propaga la excepción.
/// - Si retorna `Left`, no avanza.
/// - Si retorna `Right` y hay `autoAdvanceAfter`, espera dicho tiempo y reporta éxito.
Future<Either<ErrorItem, Unit>> activateStep(OnboardingStep step) async {
  if (step.onEnter == null) {
    // Éxito inmediato (no-op).
    if (step.autoAdvanceAfter != null) {
      await Future<void>.delayed(step.autoAdvanceAfter!);
    }
    return Right<ErrorItem, Unit>(unit);
  }

  final Either<ErrorItem, Unit> result = await step.onEnter!();

  // En éxito, respeta auto-advance (si definido).
  if (result.isRight && step.autoAdvanceAfter != null) {
    await Future<void>.delayed(step.autoAdvanceAfter!);
  }
  return result;
}

void main() {
  group('OnboardingStep – contratos de onEnter', () {
    test('Given onEnter null When activateStep Then éxito inmediato (Right)',
        () async {
      // Arrange
      const OnboardingStep step = OnboardingStep(title: 'Bienvenida');

      // Act
      final Either<ErrorItem, Unit> r = await activateStep(step);

      // Assert
      expect(
        r.isRight,
        isTrue,
        reason: 'onEnter == null debe asumirse como éxito',
      );
    });

    test(
        'Given onEnter éxito When activateStep Then retorna Right y respeta autoAdvance',
        () async {
      // Arrange
      const Duration delay = Duration(milliseconds: 50);
      final OnboardingStep step = OnboardingStep(
        title: 'Permisos',
        autoAdvanceAfter: delay,
        onEnter: () async => Right<ErrorItem, Unit>(unit),
      );

      // Act + Assert (no medimos el tiempo exacto, solo que no falla y es Right)
      final Either<ErrorItem, Unit> r = await activateStep(step);
      expect(r.isRight, isTrue);
    });

    test(
        'Given onEnter error (Left) When activateStep Then no autoAdvance y permanece (Left)',
        () async {
      // Arrange
      int tick = 0;
      final OnboardingStep step = OnboardingStep(
        title: 'Validación',
        autoAdvanceAfter: const Duration(milliseconds: 20),
        onEnter: () {
          tick++; // Se ejecuta una vez
          return Left<ErrorItem, Unit>(
            const ErrorItem(
              code: 'VALIDATION_FAIL',
              title: 'Datos inválidos',
              description: 'Datos inválidos',
            ),
          );
        },
      );

      // Act
      final DateTime start = DateTime.now();
      final Either<ErrorItem, Unit> r = await activateStep(step);
      final Duration elapsed = DateTime.now().difference(start);

      // Assert
      expect(r.isLeft, isTrue, reason: 'Debe propagar el error (Left)');
      expect(
        tick,
        equals(1),
        reason: 'onEnter debe ejecutarse exactamente una vez',
      );
      expect(
        elapsed.inMilliseconds,
        lessThan(20),
        reason: 'En Left NO debe esperar autoAdvanceAfter',
      );
    });

    test(
        'Given onEnter lanza excepción When activateStep Then viola contrato y propaga',
        () async {
      // Arrange
      final OnboardingStep step = OnboardingStep(
        title: 'Configuración',
        onEnter: () {
          throw StateError('No debería lanzarse (contrato violado)');
        },
      );

      // Act + Assert
      await expectLater(
        () => activateStep(step),
        throwsA(isA<StateError>()),
        reason:
            'Si lanza, se considera violación de contrato (test lo evidencia)',
      );
    });
  });

  group('OnboardingStep – semántica de autoAdvanceAfter', () {
    test(
        'Given éxito y autoAdvanceAfter When activateStep Then espera el delay',
        () async {
      // Arrange
      const Duration delay = Duration(milliseconds: 60);
      final OnboardingStep step = OnboardingStep(
        title: 'Sincronización',
        autoAdvanceAfter: delay,
        onEnter: () async => Right<ErrorItem, Unit>(unit),
      );

      // Act
      final DateTime start = DateTime.now();
      final Either<ErrorItem, Unit> r = await activateStep(step);
      final Duration elapsed = DateTime.now().difference(start);

      // Assert
      expect(r.isRight, isTrue);
      expect(
        elapsed.inMilliseconds,
        greaterThanOrEqualTo(delay.inMilliseconds),
        reason: 'Debe respetar el tiempo de auto-advance sólo en éxito',
      );
    });

    test(
        'Given onEnter null y autoAdvanceAfter When activateStep Then éxito y espera delay',
        () async {
      // Arrange
      const Duration delay = Duration(milliseconds: 40);
      const OnboardingStep step = OnboardingStep(
        title: 'No-Op',
        autoAdvanceAfter: delay,
        // onEnter: null => éxito inmediato + espera delay
      );

      // Act
      final DateTime start = DateTime.now();
      final Either<ErrorItem, Unit> r = await activateStep(step);
      final Duration elapsed = DateTime.now().difference(start);

      // Assert
      expect(r.isRight, isTrue);
      expect(
        elapsed.inMilliseconds,
        greaterThanOrEqualTo(delay.inMilliseconds),
      );
    });
  });
}
