import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelPoint', () {
    test(
        'Given valid json When fromJson Then builds point and preserves values',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ModelPointEnum.label.name: 'Enero',
        ModelPointEnum.vector.name: <String, dynamic>{
          ModelVectorEnum.dx.name: 1.0,
          ModelVectorEnum.dy.name: 60000.0,
        },
      };

      // Act
      final ModelPoint p = ModelPoint.fromJson(json);

      // Assert
      expect(p.label, 'Enero');
      expect(p.vector.dx, 1.0);
      expect(p.vector.dy, 60000.0);
      expect(p.vector.isValidVector, isTrue);
    });

    test(
        'Given noisy json When fromJson Then label may be empty and vector may be invalid',
        () {
      // Arrange: vector ausente/ruidoso → mapFromDynamic devuelve {}
      final Map<String, dynamic> json = <String, dynamic>{
        ModelPointEnum.label.name: null,
        ModelPointEnum.vector.name: 12345, // no es mapa → {}
      };

      // Act
      final ModelPoint p = ModelPoint.fromJson(json);

      // Assert
      expect(p.label, ''); // getStringFromDynamic(null) → ''
      // Dependiendo de Utils.getDouble por defecto (double.nan),
      // el vector resultante no será válido:
      expect(p.vector.isValidVector, isFalse);
    });

    test('Given point When toJson Then emits expected shape', () {
      // Arrange
      const ModelPoint p = ModelPoint(
        label: 'Feb',
        vector: ModelVector(2.0, 45000.0),
      );

      // Act
      final Map<String, dynamic> out = p.toJson();

      // Assert
      expect(out[ModelPointEnum.label.name], 'Feb');
      final Map<String, dynamic> v =
          out[ModelPointEnum.vector.name] as Map<String, dynamic>;
      expect(v[ModelVectorEnum.dx.name], 2.0);
      expect(v[ModelVectorEnum.dy.name], 45000.0);
    });

    test('Given two equal points When comparing Then == and hashCode match',
        () {
      // Arrange
      const ModelPoint a =
          ModelPoint(label: 'M', vector: ModelVector(1.0, 1.0));
      const ModelPoint b =
          ModelPoint(label: 'M', vector: ModelVector(1.0, 1.0));

      // Assert
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test(
        'Given copyWith When overriding fields Then returns new instance with overrides',
        () {
      // Arrange
      const ModelPoint p = ModelPoint(label: 'L', vector: ModelVector.zero);

      // Act
      final ModelPoint p1 = p.copyWith(label: 'N');
      final ModelPoint p2 = p.copyWith(vector: const ModelVector(3.0, -7.0));

      // Assert
      expect(p1.label, 'N');
      expect(p1.vector, p.vector); // solo cambió label
      expect(p2.label, 'L');
      expect(p2.vector.dx, 3.0);
      expect(p2.vector.dy, -7.0);
    });

    test(
        'Given round-trip When fromJson(toJson()) Then preserves semantic equality',
        () {
      // Arrange
      const ModelPoint original =
          ModelPoint(label: 'R', vector: ModelVector(3.0, 4.0));

      // Act
      final ModelPoint round = ModelPoint.fromJson(original.toJson());

      // Assert
      expect(round, original);
    });
  });

  group('ModelVector (integration checks used by ModelPoint)', () {
    test('Given approximate vectors When equalsApprox Then true within eps',
        () {
      // Arrange
      const ModelVector a = ModelVector(1.000000001, 2.0);
      const ModelVector b = ModelVector(1.0, 2.0);

      // Assert
      expect(a.equalsApprox(b), isTrue);
    });

    test('Given invalid numbers When isValidVector Then false', () {
      // Arrange
      const ModelVector v = ModelVector(double.nan, double.infinity);

      // Assert
      expect(v.isValidVector, isFalse);
    });
  });
}
