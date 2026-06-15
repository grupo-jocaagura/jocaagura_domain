import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('Either', () {
    // Test for Left
    test('Left should return correct value and type', () {
      const Left<int, String> left = Left<int, String>(42);

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
      const Right<int, String> right = Right<int, String>('hello');
      const Right<int, String> right2 = Right<int, String>('hello');

      expect(right.isLeft, false);
      expect(right.isRight, true);
      expect(right == right2, true);
      expect(right.toString(), 'Right(hello)');

      final String result = right.fold(
        (int l) => 'Left: $l',
        (String r) => 'Right: $r',
      );

      expect(result, 'Right: hello');
    });

    // Test for when method
    test('Either.when should execute correct function', () {
      const Left<int, String> left = Left<int, String>(42);
      const Left<int, String> left2 = Left<int, String>(42);
      const Right<int, String> right = Right<int, String>('hello');
      expect(left2 == left, true);

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
  group('Either.match', () {
    test('Given Left When match is called Then executes left branch', () {
      const Either<String, int> either = Left<String, int>('failure');

      final String result = either.match<String>(
        left: (String left) => 'left: $left',
        right: (int right) => 'right: $right',
      );

      expect(result, 'left: failure');
    });

    test('Given Right When match is called Then executes right branch', () {
      const Either<String, int> either = Right<String, int>(10);

      final String result = either.match<String>(
        left: (String left) => 'left: $left',
        right: (int right) => 'right: $right',
      );

      expect(result, 'right: 10');
    });
  });

  group('Either.map', () {
    test('Given Left When map is called Then preserves left value', () {
      const Either<String, int> either = Left<String, int>('failure');
      bool transformCalled = false;

      final Either<String, String> result = either.map<String>((int right) {
        transformCalled = true;
        return right.toString();
      });

      expect(result, const Left<String, String>('failure'));
      expect(transformCalled, false);
    });

    test('Given Right When map is called Then transforms right value', () {
      const Either<String, int> either = Right<String, int>(21);

      final Either<String, String> result = either.map<String>(
        (int right) => 'value: ${right * 2}',
      );

      expect(result, const Right<String, String>('value: 42'));
    });
  });

  group('Either.mapLeft', () {
    test('Given Left When mapLeft is called Then transforms left value', () {
      const Either<String, int> either = Left<String, int>('failure');

      final Either<int, int> result = either.mapLeft<int>(
        (String left) => left.length,
      );

      expect(result, const Left<int, int>(7));
    });

    test('Given Right When mapLeft is called Then preserves right value', () {
      const Either<String, int> either = Right<String, int>(42);
      bool transformCalled = false;

      final Either<int, int> result = either.mapLeft<int>((String left) {
        transformCalled = true;
        return left.length;
      });

      expect(result, const Right<int, int>(42));
      expect(transformCalled, false);
    });
  });

  group('Either.flatMap', () {
    test('Given Left When flatMap is called Then preserves left value', () {
      const Either<String, int> either = Left<String, int>('failure');
      bool transformCalled = false;

      final Either<String, String> result = either.flatMap<String>((int right) {
        transformCalled = true;
        return Right<String, String>(right.toString());
      });

      expect(result, const Left<String, String>('failure'));
      expect(transformCalled, false);
    });

    test('Given Right When flatMap returns Right Then resolves next success',
        () {
      const Either<String, int> either = Right<String, int>(7);

      final Either<String, String> result = either.flatMap<String>(
        (int right) => Right<String, String>('value: ${right * 2}'),
      );

      expect(result, const Right<String, String>('value: 14'));
    });

    test('Given Right When flatMap returns Left Then resolves next failure',
        () {
      const Either<String, int> either = Right<String, int>(7);

      final Either<String, String> result = either.flatMap<String>(
        (int right) => const Left<String, String>('mapped failure'),
      );

      expect(result, const Left<String, String>('mapped failure'));
    });
  });

  group('Either.onLeft', () {
    test(
        'Given Left When onLeft is called Then executes action and returns same value',
        () {
      const Either<String, int> either = Left<String, int>('failure');
      String? captured;

      final Either<String, int> result = either.onLeft((String left) {
        captured = left;
      });

      expect(captured, 'failure');
      expect(result, same(either));
    });

    test('Given Right When onLeft is called Then does not execute action', () {
      const Either<String, int> either = Right<String, int>(42);
      bool actionCalled = false;

      final Either<String, int> result = either.onLeft((String left) {
        actionCalled = true;
      });

      expect(actionCalled, false);
      expect(result, same(either));
    });
  });

  group('Either.onRight', () {
    test(
        'Given Right When onRight is called Then executes action and returns same value',
        () {
      const Either<String, int> either = Right<String, int>(42);
      int? captured;

      final Either<String, int> result = either.onRight((int right) {
        captured = right;
      });

      expect(captured, 42);
      expect(result, same(either));
    });

    test('Given Left When onRight is called Then does not execute action', () {
      const Either<String, int> either = Left<String, int>('failure');
      bool actionCalled = false;

      final Either<String, int> result = either.onRight((int right) {
        actionCalled = true;
      });

      expect(actionCalled, false);
      expect(result, same(either));
    });
  });

  group('Either equality and hashCode', () {
    test(
        'Given two Left values with same content When compared Then they are equal',
        () {
      const Left<int, String> first = Left<int, String>(42);
      const Left<int, String> second = Left<int, String>(42);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test(
        'Given two Left values with different content When compared Then they are not equal',
        () {
      const Left<int, String> first = Left<int, String>(42);
      const Left<int, String> second = Left<int, String>(7);

      expect(first == second, false);
    });

    test(
        'Given two Right values with same content When compared Then they are equal',
        () {
      const Right<int, String> first = Right<int, String>('hello');
      const Right<int, String> second = Right<int, String>('hello');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test(
        'Given two Right values with different content When compared Then they are not equal',
        () {
      const Right<int, String> first = Right<int, String>('hello');
      const Right<int, String> second = Right<int, String>('world');

      expect(first == second, false);
    });

    test('Given Left and Right When compared Then they are not equal', () {
      const Either<int, int> left = Left<int, int>(1);
      const Either<int, int> right = Right<int, int>(1);

      expect(left == right, false);
    });
  });

  group('Either.fold', () {
    test('Given Left When fold is called Then executes left branch', () {
      const Either<int, String> either = Left<int, String>(42);

      final String result = either.fold<String>(
        (int left) => 'left: $left',
        (String right) => 'right: $right',
      );

      expect(result, 'left: 42');
    });

    test('Given Right When fold is called Then executes right branch', () {
      const Either<int, String> either = Right<int, String>('hello');

      final String result = either.fold<String>(
        (int left) => 'left: $left',
        (String right) => 'right: $right',
      );

      expect(result, 'right: hello');
    });
  });
}
