import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelVector Tests', () {
    test('Constructor assigns properties correctly', () {
      const ModelVector vector = ModelVector(1.0, 2.0);
      expect(vector.dx, 1.0);
      expect(vector.dy, 2.0);
    });

    test('fromOffset creates a ModelVector from an Offset', () {
      const Offset offset = Offset(1.0, 2.0);
      final ModelVector vector = ModelVector.fromOffset(offset);
      expect(vector.dx, offset.dx);
      expect(vector.dy, offset.dy);
    });

    test('toJson returns a correct Map representation', () {
      const ModelVector vector = ModelVector(1.0, 2.0);
      expect(vector.toJson(), <String, double>{'dx': 1.0, 'dy': 2.0});
    });

    test('copyWith creates a modified copy of the object', () {
      const ModelVector vector = ModelVector(1.0, 2.0);
      final ModelVector modifiedVector = vector.copyWith(dy: 3.0);
      expect(modifiedVector.dx, 1.0);
      expect(modifiedVector.dy, 3.0);
    });

    test('ModelVector equality and hashCode test', () {
      const ModelVector vector1 = ModelVector(1.0, 2.0);
      const ModelVector vector2 = ModelVector(1.0, 2.0);
      const ModelVector vector3 = ModelVector(2.0, 1.0);

      expect(vector1, equals(vector2));
      expect(vector1.hashCode, equals(vector2.hashCode));
      expect(vector1, isNot(equals(vector3)));
    });
  });
  group('ModelVector.fromJson', () {
    test('should create a ModelVector from valid JSON', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'dx': 5.0,
        'dy': 10.0,
      };
      final ModelVector vector = ModelVector.fromJson(json);

      expect(vector.dx, 5.0);
      expect(vector.dy, 10.0);
    });

    test('should handle integer values in JSON', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'dx': 3,
        'dy': 4,
      };
      final ModelVector vector = ModelVector.fromJson(json);

      expect(vector.dx, 3.0);
      expect(vector.dy, 4.0);
    });

    test('should handle string values in JSON', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'dx': '7',
        'dy': '8',
      };
      final ModelVector vector = ModelVector.fromJson(json);

      expect(vector.dx, 7.0);
      expect(vector.dy, 8.0);
    });

    test('should treat null values as zero', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'dx': null,
        'dy': null,
      };
      final ModelVector vector = ModelVector.fromJson(json);

      expect(
        vector.dx.isNaN,
        true,
      );
      expect(
        vector.dy.isNaN,
        true,
      );
    });
  });
  group('ModelVector', () {
    // Crear una instancia de prueba de ModelVector
    const double dx = 3.0;
    const double dy = 4.0;
    const ModelVector vector = ModelVector(dx, dy);

    test('offset getter should return correct Offset object', () {
      // Comprobar que el Offset retornado tenga los valores correctos
      expect(vector.offset, equals(const Offset(dx, dy)));
    });

    test('toString should return the correct string representation', () {
      // Comprobar que toString retorne la representación en cadena correcta
      expect(vector.toString(), equals('($dx, $dy)'));
    });
  });

  group('ModelVector Equality', () {
    test('should return true for the same instance', () {
      const ModelVector vector = ModelVector(1.0, 2.0);

      expect(vector == vector, isTrue);
    });

    test('should return true for identical values but different instances', () {
      const ModelVector vector1 = ModelVector(1.0, 2.0);
      const ModelVector vector2 = ModelVector(1.0, 2.0);

      expect(vector1 == vector2, isTrue);
    });

    test('should return false for different values', () {
      const ModelVector vector1 = ModelVector(1.0, 2.0);
      const ModelVector vector2 = ModelVector(3.0, 4.0);

      expect(vector1 == vector2, isFalse);
    });

    test('should return false when compared with non-ModelVector object', () {
      const ModelVector vector = ModelVector(1.0, 2.0);
      const Object other = Object();

      expect(vector == other, isFalse);
    });

    test('hashCode comparison for equality', () {
      const ModelVector vector1 = ModelVector(1.0, 2.0);
      const ModelVector vector2 = ModelVector(1.0, 2.0);
      expect(vector1 == vector2, true);
      expect(vector1.hashCode, equals(vector2.hashCode));
    });

    test('hashCode comparison for non-equality', () {
      const ModelVector vector1 = ModelVector(1.0, 2.0);
      const ModelVector vector2 = ModelVector(1.0, 4.0);
      expect(vector1 == vector2, false);

      expect(vector1.hashCode, isNot(equals(vector2.hashCode)));
    });
  });
  group('ModelVector isCorrectVector', () {
    test('should return true for valid vectors', () {
      const ModelVector vector = ModelVector(1.0, 2.0);
      expect(vector.isCorrectVector, isTrue);
    });

    test('should return false if dx is NaN', () {
      const ModelVector vector = ModelVector(double.nan, 2.0);
      expect(vector.isCorrectVector, isFalse);
    });

    test('should return false if dy is NaN', () {
      const ModelVector vector = ModelVector(1.0, double.nan);
      expect(vector.isCorrectVector, isFalse);
    });

    test('should return false if both dx and dy are NaN', () {
      const ModelVector vector = ModelVector(double.nan, double.nan);
      expect(vector.isCorrectVector, isFalse);
    });
  });

  group('ModelVector integer-oriented view', () {
    test('round policy for positive decimals', () {
      const ModelVector v = ModelVector(1.4, 2.5);
      expect(v.x, 1);
      expect(v.y, 3); // .5 away from zero
    });

    test('round policy for negative decimals', () {
      const ModelVector v = ModelVector(-1.4, -2.5);
      expect(v.x, -1);
      expect(v.y, -3); // .5 away from zero
    });

    test('key stability', () {
      const ModelVector v = ModelVector(10.49, -3.51);
      expect(v.key, '10,-4');
    });

    test('copyWithInts overrides only provided axes', () {
      const ModelVector v = ModelVector(7.2, 8.8);

      final ModelVector c1 = v.copyWithInts(x: -1);
      expect(c1.dx, -1.0);
      expect(c1.dy, v.y.toDouble());

      final ModelVector c2 = v.copyWithInts(y: 5);
      expect(c2.dx, v.x.toDouble());
      expect(c2.dy, 5.0);
    });

    test('fromXY builds from integers', () {
      final ModelVector v = ModelVector.fromXY(3, -2);
      expect(v.dx, 3.0);
      expect(v.dy, -2.0);
    });
  });
}
