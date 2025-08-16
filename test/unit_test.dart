import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('Unit', () {
    test('singleton identity (const canonicalization)', () {
      expect(identical(unit, Unit.value), isTrue);
    });

    test('equality: any Unit equals any other Unit', () {
      expect(unit == Unit.value, isTrue);
      expect(unit, equals(Unit.value));
    });

    test('hashCode is stable and consistent with equality', () {
      expect(unit.hashCode, 0);
      expect(Unit.value.hashCode, 0);
    });

    test('toString returns "unit"', () {
      expect(unit.toString(), 'unit');
      expect(Unit.value.toString(), 'unit');
    });

    test('works as key/value in collections without duplicates', () {
      final Set<Unit> s = <Unit>{};
      s.add(unit);
      s.add(Unit.value); // no debería duplicar
      expect(s.length, 1);

      final Map<Unit, String> m = <Unit, String>{};
      m[unit] = 'a';
      m[Unit.value] = 'b'; // debe sobrescribir la misma clave
      expect(m.length, 1);
      expect(m[unit], 'b');
    });

    test('usable in generics (e.g., List<Unit>)', () {
      final List<Unit> list = <Unit>[unit, Unit.value];
      // Dos entradas pero semánticamente el mismo valor; la lista mantiene 2 items
      // (este test valida que el tipo es usable en genéricos, no deduplicación)
      expect(list.length, 2);
      expect(list.every((Unit u) => u == unit), isTrue);
    });
  });
}
