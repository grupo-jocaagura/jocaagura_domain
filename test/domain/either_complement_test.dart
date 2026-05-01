import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('Either const constructor', () {
    test('Given const Left values When compared Then they are equal', () {
      const Left<String, int> first = Left<String, int>('error');
      const Left<String, int> second = Left<String, int>('error');

      expect(first, second);
      expect(identical(first, second), isTrue);
    });

    test('Given const Right values When compared Then they are equal', () {
      const Right<String, int> first = Right<String, int>(1);
      const Right<String, int> second = Right<String, int>(1);

      expect(first, second);
      expect(identical(first, second), isTrue);
    });
  });

  group('Either when', () {
    test('Given Left When when is called Then executes left callback', () {
      const Either<String, int> result = Left<String, int>('error');

      final String message = result.when<String>(
        (String error) => 'left: $error',
        (int value) => 'right: $value',
      );

      expect(message, 'left: error');
    });

    test('Given Right When when is called Then executes right callback', () {
      const Either<String, int> result = Right<String, int>(1);

      final String message = result.when<String>(
        (String error) => 'left: $error',
        (int value) => 'right: $value',
      );

      expect(message, 'right: 1');
    });
  });

  group('Either fold', () {
    test('Given Left When fold is called Then executes onLeft callback', () {
      const Either<String, int> result = Left<String, int>('error');

      final String message = result.fold<String>(
        (String error) => 'left: $error',
        (int value) => 'right: $value',
      );

      expect(message, 'left: error');
    });

    test('Given Right When fold is called Then executes onRight callback', () {
      const Either<String, int> result = Right<String, int>(1);

      final String message = result.fold<String>(
        (String error) => 'left: $error',
        (int value) => 'right: $value',
      );

      expect(message, 'right: 1');
    });
  });

  group('Either type flags', () {
    test(
        'Given Left When flags are read Then isLeft is true and isRight is false',
        () {
      const Either<String, int> result = Left<String, int>('error');

      expect(result.isLeft, isTrue);
      expect(result.isRight, isFalse);
    });

    test(
        'Given Right When flags are read Then isRight is true and isLeft is false',
        () {
      const Either<String, int> result = Right<String, int>(1);

      expect(result.isRight, isTrue);
      expect(result.isLeft, isFalse);
    });
  });
}
