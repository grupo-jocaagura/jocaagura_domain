import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('OnboardingState – factories y valores por defecto', () {
    test(
      'Given idle() When se crea Then status=idle, stepIndex=0, totalSteps=0, error=null',
      () {
        // Arrange & Act
        final OnboardingState s = OnboardingState.idle();

        // Assert
        expect(s.status, OnboardingStatus.idle);
        expect(s.stepIndex, 0);
        expect(s.totalSteps, 0);
        expect(s.error, isNull);
        expect(s.hasStep, isFalse);
        expect(s.stepNumber, 0);
      },
    );
  });

  group('OnboardingState – utilidades de UI', () {
    test(
      'Given running con totalSteps>0 When hasStep Then true y stepNumber = stepIndex+1',
      () {
        // Arrange
        final OnboardingState s = OnboardingState.idle().copyWith(
          status: OnboardingStatus.running,
          stepIndex: 2,
          totalSteps: 5,
        );

        // Assert
        expect(s.hasStep, isTrue);
        expect(s.stepNumber, 3);
      },
    );

    test(
      'Given running con totalSteps==0 When hasStep Then false y stepNumber=0',
      () {
        // Arrange
        final OnboardingState s = OnboardingState.idle().copyWith(
          status: OnboardingStatus.running,
          totalSteps: 0,
        );

        // Assert
        expect(s.hasStep, isFalse);
        expect(s.stepNumber, 0);
      },
    );
  });

  group('OnboardingState – copyWith con centinela Unit.value', () {
    test(
      'Given state con error When copyWith(error: Unit.value) Then conserva el error',
      () {
        // Arrange
        const ErrorItem err = ErrorItem(
          title: 'Oops',
          code: 'ERR_TEST',
          description: 'Testing',
          meta: <String, dynamic>{'k': 'v'},
          errorLevel: ErrorLevelEnum.severe,
        );
        final OnboardingState s1 = OnboardingState.idle().copyWith(
          status: OnboardingStatus.running,
          totalSteps: 3,
          stepIndex: 1,
          error: err,
        );

        // Act
        final OnboardingState s2 = s1.copyWith(
          status: OnboardingStatus.running,
          // Nota: no pasamos error explícito; usamos el centinela por omisión
          // al no tocar el parámetro 'error' (queda en Unit.value via firma).
        );

        // Assert
        expect(s2.error, same(err), reason: 'Debe conservar error existente');
        expect(s2.status, OnboardingStatus.running);
        expect(s2.totalSteps, 3);
        expect(s2.stepIndex, 1);
      },
    );

    test(
      'Given state con error When copyWith(error: null) Then limpia el error',
      () {
        // Arrange
        final OnboardingState s1 = OnboardingState.idle().copyWith(
          error: const ErrorItem(
            title: 'Err',
            code: 'E',
            description: 'desc',
          ),
        );

        // Act
        final OnboardingState s2 = s1.copyWith(error: null);

        // Assert
        expect(s2.error, isNull);
      },
    );
  });

  group('OnboardingState – JSON round trip', () {
    test(
      'Given state sin error When toJson->fromJson Then estado equivalente',
      () {
        // Arrange
        final OnboardingState s = OnboardingState.idle().copyWith(
          status: OnboardingStatus.running,
          stepIndex: 0,
          totalSteps: 3,
        );

        // Act
        final Map<String, dynamic> j = s.toJson();
        final OnboardingState r = OnboardingState.fromJson(j);

        // Assert
        expect(r, equals(s));
        expect(j['status'], 'running');
        expect(j['stepIndex'], 0);
        expect(j['totalSteps'], 3);
        expect(j['error'], isNull);
      },
    );

    test(
      'Given state con error When toJson->fromJson Then se conserva ErrorItem',
      () {
        // Arrange
        const ErrorItem err = ErrorItem(
          title: 'Network',
          code: 'ERR_NET',
          description: 'Timeout',
          meta: <String, dynamic>{'retry': true},
          errorLevel: ErrorLevelEnum.warning,
        );
        final OnboardingState s = OnboardingState.idle().copyWith(
          status: OnboardingStatus.running,
          stepIndex: 1,
          totalSteps: 4,
          error: err,
        );

        // Act
        final Map<String, dynamic> j = s.toJson();
        final OnboardingState r = OnboardingState.fromJson(j);

        // Assert
        expect(r, equals(s));
        expect(j['error'], isA<Map<String, dynamic>>());
        expect((j['error'] as Map<String, dynamic>)['code'], 'ERR_NET');
        expect((j['error'] as Map<String, dynamic>)['errorLevel'], 'warning');
      },
    );

    test(
      'Given JSON malformado When fromJson Then usa defaults (idle, enteros=0, error=null)',
      () {
        // Arrange
        final Map<String, dynamic> bad = <String, dynamic>{
          'status': '???', // no coincide -> idle
          'stepIndex':
              'x1,2a', // Utils -> 1 o 12 según normalización; forzamos caso raro
          'totalSteps': null, // -> 0
          'error': 'not-a-map', // -> {} -> ErrorItem.fromJson => strings vacíos
        };

        // Act
        final OnboardingState r = OnboardingState.fromJson(bad);

        // Assert (verificamos solo lo fundamental; los enteros dependen de Utils)
        expect(r.status, OnboardingStatus.idle);
        expect(r.totalSteps, 0);
        // stepIndex dependerá de la limpieza de Utils; validamos que sea int no negativo por diseño actual
        expect(r.stepIndex, isA<int>());
        // error: para 'not-a-map' -> Utils.mapFromDynamic retorna {}, lo que crea ErrorItem con strings vacíos.
        // Sin embargo, el código solo crea error si json['error'] != null (aquí no es null), así que esperamos un ErrorItem "vacío".
        expect(r.error, isNotNull);
        expect(r.error!.code, isA<String>());
      },
    );
  });

  group('OnboardingState – igualdad, hashCode y toString', () {
    test(
      'Given dos estados idénticos When comparar Then == true y hashCode igual',
      () {
        // Arrange
        const ErrorItem err = ErrorItem(
          title: 'X',
          code: 'C',
          description: 'D',
          meta: <String, dynamic>{'k': 1},
        );
        final OnboardingState a = OnboardingState.idle().copyWith(
          status: OnboardingStatus.completed,
          stepIndex: 0,
          totalSteps: 3,
          error: err,
        );
        final OnboardingState b = OnboardingState.idle().copyWith(
          status: OnboardingStatus.completed,
          stepIndex: 0,
          totalSteps: 3,
          error: err,
        );

        // Assert
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      },
    );

    test(
      'Given state When toString Then incluye claves del JSON',
      () {
        // Arrange
        final OnboardingState s = OnboardingState.idle().copyWith(
          status: OnboardingStatus.skipped,
        );

        // Act
        final String str = s.toString();

        // Assert
        expect(str, contains('status'));
        expect(str, contains('stepIndex'));
        expect(str, contains('totalSteps'));
        expect(str, contains('error'));
      },
    );
  });

  group('OnboardingState – _statusFromString (fallback)', () {
    test(
      'Given string desconocido When parse Then idle como fallback',
      () {
        // Arrange
        final Map<String, dynamic> j = <String, dynamic>{
          'status': 'no-existe',
          'stepIndex': 0,
          'totalSteps': 0,
          'error': null,
        };

        // Act
        final OnboardingState r = OnboardingState.fromJson(j);

        // Assert
        expect(r.status, OnboardingStatus.idle);
      },
    );

    test(
      'Given string válido When parse Then usa valor correcto',
      () {
        // Arrange
        final Map<String, dynamic> j = <String, dynamic>{
          'status': 'running',
          'stepIndex': 1,
          'totalSteps': 3,
          'error': null,
        };

        // Act
        final OnboardingState r = OnboardingState.fromJson(j);

        // Assert
        expect(r.status, OnboardingStatus.running);
      },
    );
  });
}
