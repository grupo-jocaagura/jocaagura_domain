import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('Either', () {
    // Test for Left
    test('Left should return correct value and type', () {
      final Left<int, String> left = Left<int, String>(42);

      expect(left.isLeft, true);
      expect(left.isRight, false);
      expect(left.toString(), 'Left(42)');

      final String result = left.fold(
        (int l) => 'Left: $l',
        (String r) => 'Right: $r',
      );

      expect(result, 'Left: 42');
    });

    // Test for Right
    test('Right should return correct value and type', () {
      final Right<int, String> right = Right<int, String>('hello');

      expect(right.isLeft, false);
      expect(right.isRight, true);
      expect(right.toString(), 'Right(hello)');

      final String result = right.fold(
        (int l) => 'Left: $l',
        (String r) => 'Right: $r',
      );

      expect(result, 'Right: hello');
    });

    // Test for when method
    test('Either.when should execute correct function', () {
      final Left<int, String> left = Left<int, String>(42);
      final Right<int, String> right = Right<int, String>('hello');

      expect(
        left.when(
          (int l) => 'Left: $l',
          (String r) => 'Right: $r',
        ),
        'Left: 42',
      );

      expect(
        right.when(
          (int l) => 'Left: $l',
          (String r) => 'Right: $r',
        ),
        'Right: hello',
      );
    });
  });
}
