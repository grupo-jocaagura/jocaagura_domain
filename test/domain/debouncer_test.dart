import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('Debouncer Tests', () {
    late Debouncer debouncer;
    setUp(() {
      debouncer = Debouncer(
        milliseconds: 200,
      ); // Usamos un tiempo más corto para pruebas rápidas
    });

    test('debouncer should delay execution', () async {
      int counter = 0;
      debouncer.call(() {
        counter += 1;
      });

      // Inmediatamente después de llamar al debouncer, el contador debería seguir siendo 0
      expect(counter, 0);
      // Esperar para que se ejecute la acción
      await Future<void>.delayed(const Duration(milliseconds: 210));
      expect(counter, 1);
    });

    test(
        'debouncer should cancel previous calls if called again within the timeout',
        () async {
      int counter = 0;
      debouncer.call(() {
        counter += 1;
      });

      // Llamar al debouncer de nuevo para resetear el timer
      await Future<void>.delayed(const Duration(milliseconds: 10));
      debouncer.call(() {
        counter += 10;
      });
      expect(counter, 0);
      // Esperar más de 200 ms desde la última llamada
      await Future<void>.delayed(const Duration(milliseconds: 210));

      expect(counter, 10);
    });
  });

  group('Debouncer', () {
    test(
        'Given multiple calls within the window When time elapses Then only the last callback is executed',
        () async {
      // Arrange
      final Debouncer debouncer = Debouncer(milliseconds: 30);
      final List<String> executed = <String>[];

      // Act
      debouncer(() => executed.add('first'));
      await Future<void>.delayed(const Duration(milliseconds: 5));

      debouncer(() => executed.add('second'));
      await Future<void>.delayed(const Duration(milliseconds: 5));

      debouncer(() => executed.add('third'));

      // Wait enough time for the last callback to fire.
      await Future<void>.delayed(const Duration(milliseconds: 60));

      // Assert
      expect(executed, equals(<String>['third']));
      debouncer.dispose();
    });

    test(
        'Given a pending callback When dispose is called before timeout Then the callback must not execute',
        () async {
      // Arrange
      final Debouncer debouncer = Debouncer(milliseconds: 40);
      bool executed = false;

      // Act
      debouncer(() => executed = true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      debouncer.dispose();

      // Wait longer than debounce duration to ensure it would have fired.
      await Future<void>.delayed(const Duration(milliseconds: 80));

      // Assert
      expect(executed, isFalse);
      expect(debouncer.isDisposed, isTrue);
    });

    test(
        'Given a disposed instance When call() is invoked after dispose Then it must not execute actions',
        () async {
      // Arrange
      final Debouncer debouncer = Debouncer(milliseconds: 30);
      bool executed = false;

      // Act
      debouncer.dispose();
      debouncer(() => executed = true);

      await Future<void>.delayed(const Duration(milliseconds: 60));

      // Assert
      expect(executed, isFalse);
      expect(debouncer.isDisposed, isTrue);
    });
    test(
        'Given dispose called twice When dispose is called again Then it does not throw',
        () {
      final Debouncer debouncer = Debouncer(milliseconds: 10);

      debouncer.dispose();

      expect(() => debouncer.dispose(), returnsNormally);
    });
    test(
        'Given negative milliseconds When creating Debouncer Then it asserts in debug',
        () {
      expect(() => Debouncer(milliseconds: -1), throwsA(isA<AssertionError>()));
    });
  });
}
