import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('GraphAxisSpec', () {
    test('Given valid json When fromJson Then builds spec with doubles', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        GraphAxisSpecEnum.title.name: 'Price',
        GraphAxisSpecEnum.min.name: 55000, // int → double 55000.0
        GraphAxisSpecEnum.max.name: 65000.0, // double
      };

      // Act
      final GraphAxisSpec spec = GraphAxisSpec.fromJson(json);

      // Assert
      expect(spec.title, 'Price');
      expect(spec.min, 55000.0);
      expect(spec.max, 65000.0);
    });

    test('Given noisy json When fromJson Then accepts and may yield NaN', () {
      // Arrange: valores no numéricos → Utils.getDouble → double.nan por contrato
      final Map<String, dynamic> json = <String, dynamic>{
        GraphAxisSpecEnum.title.name: null, // → ''
        GraphAxisSpecEnum.min.name: 'abc', // → NaN
        GraphAxisSpecEnum.max.name: '∞', // → NaN
      };

      // Act
      final GraphAxisSpec spec = GraphAxisSpec.fromJson(json);

      // Assert
      expect(spec.title, ''); // getStringFromDynamic(null) → ''
      expect(spec.min.isFinite, isFalse); // NaN/Infinity → no finito
      expect(spec.max.isFinite, isFalse);
    });

    test('Given spec When toJson Then shape and values are preserved', () {
      // Arrange
      const GraphAxisSpec spec = GraphAxisSpec(
        title: 'Units',
        min: 0.0,
        max: 100.0,
      );

      // Act
      final Map<String, dynamic> out = spec.toJson();

      // Assert
      expect(out[GraphAxisSpecEnum.title.name], 'Units');
      expect(out[GraphAxisSpecEnum.min.name], 0.0);
      expect(out[GraphAxisSpecEnum.max.name], 100.0);
    });

    test('Given copyWith When overriding Then returns new spec with overrides',
        () {
      // Arrange
      const GraphAxisSpec a = GraphAxisSpec(title: 'A', min: 1.0, max: 10.0);

      // Act
      final GraphAxisSpec b = a.copyWith(min: -5.0);
      final GraphAxisSpec c = a.copyWith(title: 'B', max: 20.0);

      // Assert
      expect(b.title, 'A');
      expect(b.min, -5.0);
      expect(b.max, 10.0);

      expect(c.title, 'B');
      expect(c.min, 1.0);
      expect(c.max, 20.0);
    });

    test('Given two equal specs When comparing Then == and hashCode match', () {
      // Arrange
      const GraphAxisSpec a = GraphAxisSpec(title: 'T', min: 0.0, max: 1.0);
      const GraphAxisSpec b = GraphAxisSpec(title: 'T', min: 0.0, max: 1.0);

      // Assert
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test(
        'Given inverted range When constructing Then model allows it (no validation)',
        () {
      // Arrange
      const GraphAxisSpec spec =
          GraphAxisSpec(title: 'NoCheck', min: 10.0, max: -10.0);

      // Assert (documented: no invariant enforced here)
      expect(spec.min > spec.max, isTrue);
    });
  });
}
