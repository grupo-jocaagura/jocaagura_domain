import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaagura_domain_core/jocaagura_domain_models.dart' as core;

void main() {
  group('UtilsFlutter', () {
    test(
      'preserves fractional coordinates and returns the canonical core type',
      () {
        const Offset offset = Offset(-3.25, 7.125);
        final core.ModelVector vector = UtilsFlutter.fromOffset(offset);
        expect(vector.dx, offset.dx);
        expect(vector.dy, offset.dy);
        expect(UtilsFlutter.toOffset(vector), offset);
        expect(identical(ModelVector, core.ModelVector), isTrue);
      },
    );

    test('accepts core values directly and preserves vector roundtrips', () {
      const core.ModelVector vector = core.ModelVector(0.125, -200.75);
      expect(UtilsFlutter.fromOffset(UtilsFlutter.toOffset(vector)), vector);
    });

    test('preserves signed zero without normalization', () {
      final core.ModelVector vector = UtilsFlutter.fromOffset(
        const Offset(-0.0, 0.0),
      );
      expect(vector.dx.isNegative, isTrue);
      expect(vector.dy.isNegative, isFalse);
      final Offset offset = UtilsFlutter.toOffset(vector);
      expect(offset.dx.isNegative, isTrue);
      expect(offset.dy.isNegative, isFalse);
    });

    test('preserves infinity and NaN without validation', () {
      final core.ModelVector vector = UtilsFlutter.fromOffset(
        const Offset(double.infinity, double.nan),
      );
      expect(vector.dx, double.infinity);
      expect(vector.dy.isNaN, isTrue);
      final Offset offset = UtilsFlutter.toOffset(vector);
      expect(offset.dx, double.infinity);
      expect(offset.dy.isNaN, isTrue);
    });
  });
}
