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
}
