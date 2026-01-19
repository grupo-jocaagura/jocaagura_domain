import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('DateUtils.dateTimeFromDynamic', () {
    test('Given ISO string When dateTimeFromDynamic Then parses to DateTime',
        () {
      // Arrange
      const String dateString = '2023-05-30T12:30:00';

      // Act
      final DateTime result = DateUtils.dateTimeFromDynamic(dateString);

      // Assert
      final DateTime expected = DateTime(2023, 5, 30, 12, 30);
      expect(result, equals(expected));
    });

    test(
        'Given epoch milliseconds When dateTimeFromDynamic Then returns same instant',
        () {
      // Arrange
      const int milliseconds = 1622394000000;

      // Act
      final DateTime result = DateUtils.dateTimeFromDynamic(milliseconds);

      // Assert
      final DateTime expected =
          DateTime.fromMillisecondsSinceEpoch(milliseconds);
      expect(result, equals(expected));
    });

    test(
        'Given Duration When dateTimeFromDynamic Then returns now + duration (bounded)',
        () {
      // Arrange
      const Duration duration = Duration(days: 5);
      final DateTime before = DateTime.now();

      // Act
      final DateTime result = DateUtils.dateTimeFromDynamic(duration);

      // Assert
      final DateTime after = DateTime.now();
      final DateTime minExpected = before.add(duration);
      final DateTime maxExpected = after.add(duration);

      expect(
        result.isAfter(minExpected) || result.isAtSameMomentAs(minExpected),
        true,
      );
      expect(
        result.isBefore(maxExpected) || result.isAtSameMomentAs(maxExpected),
        true,
      );
    });

    test('Given DateTime When dateTimeFromDynamic Then returns same instance',
        () {
      // Arrange
      final DateTime directDateTime = DateTime(2023, 6, 15, 8);

      // Act
      final DateTime result = DateUtils.dateTimeFromDynamic(directDateTime);

      // Assert
      expect(result, equals(directDateTime));
    });

    test(
        'Given null When dateTimeFromDynamic Then returns a DateTime (now fallback)',
        () {
      // Arrange
      final DateTime before = DateTime.now();

      // Act
      final DateTime result = DateUtils.dateTimeFromDynamic(null);

      // Assert
      final DateTime after = DateTime.now();
      expect(result.isAfter(before) || result.isAtSameMomentAs(before), true);
      expect(result.isBefore(after) || result.isAtSameMomentAs(after), true);
    });
  });

  group('DateUtils.dateTimeToString', () {
    test(
        'Given local DateTime When dateTimeToString Then returns ISO string (no Z)',
        () {
      // Arrange
      final DateTime dateTime = DateTime(2023, 4, 20, 12, 30);

      // Act
      final String result = DateUtils.dateTimeToString(dateTime);

      // Assert
      expect(result, '2023-04-20T12:30:00.000');
    });

    test(
        'Given UTC DateTime When dateTimeToString Then returns ISO string ending with Z',
        () {
      // Arrange
      final DateTime dateTime = DateTime.utc(2023, 4, 20, 12, 30);

      // Act
      final String result = DateUtils.dateTimeToString(dateTime);

      // Assert
      expect(result, '2023-04-20T12:30:00.000Z');
    });
  });

  group('DateUtils.normalizeIsoOrEmpty', () {
    test('Given null When normalizeIsoOrEmpty Then returns empty string', () {
      // Act
      final String result = DateUtils.normalizeIsoOrEmpty(null);

      // Assert
      expect(result, '');
    });

    test(
        'Given empty/blank string When normalizeIsoOrEmpty Then returns empty string',
        () {
      // Act
      final String empty = DateUtils.normalizeIsoOrEmpty('');
      final String spaces = DateUtils.normalizeIsoOrEmpty('   ');

      // Assert
      expect(empty, '');
      expect(spaces, '');
    });

    test(
        'Given UTC DateTime When normalizeIsoOrEmpty Then returns ISO ending with Z',
        () {
      // Arrange
      final DateTime input = DateTime.utc(2026, 1, 3, 10, 20, 30, 400);

      // Act
      final String result = DateUtils.normalizeIsoOrEmpty(input);

      // Assert
      expect(result, '2026-01-03T10:20:30.400Z');
    });

    test(
        'Given local DateTime When normalizeIsoOrEmpty Then returns same instant in UTC',
        () {
      // Arrange
      final DateTime utc = DateTime.utc(2026, 1, 3, 10, 20, 30);
      final DateTime localSameInstant = utc.toLocal();

      // Act
      final String result = DateUtils.normalizeIsoOrEmpty(localSameInstant);

      // Assert
      final DateTime parsed = DateTime.parse(result);
      expect(parsed.isUtc, true);
      expect(parsed.toUtc(), utc);
    });

    test(
        'Given epoch milliseconds int When normalizeIsoOrEmpty Then returns that instant in UTC',
        () {
      // Arrange
      final DateTime utc = DateTime.utc(2026, 1, 3);
      final int ms = utc.millisecondsSinceEpoch;

      // Act
      final String result = DateUtils.normalizeIsoOrEmpty(ms);

      // Assert
      final DateTime parsed = DateTime.parse(result);
      expect(parsed.isUtc, true);
      expect(parsed.toUtc(), utc);
    });

    test(
        'Given valid ISO string with Z When normalizeIsoOrEmpty Then preserves instant',
        () {
      // Arrange
      const String input = '2026-01-03T10:20:30Z';

      // Act
      final String result = DateUtils.normalizeIsoOrEmpty(input);

      // Assert
      final DateTime parsed = DateTime.parse(result);
      expect(parsed.isUtc, true);
      expect(parsed.toUtc(), DateTime.utc(2026, 1, 3, 10, 20, 30));
    });

    test(
        'Given valid ISO string without timezone When normalizeIsoOrEmpty Then converts local to UTC',
        () {
      // Arrange
      const String input = '2026-01-03T10:20:30.000';

      // Act
      final String result = DateUtils.normalizeIsoOrEmpty(input);

      // Assert
      final DateTime parsed = DateTime.parse(result);
      expect(parsed.isUtc, true);

      final DateTime local = DateTime.parse(input); // parsed as local
      expect(parsed.toUtc(), local.toUtc());
    });

    test(
        'Given invalid date string When normalizeIsoOrEmpty Then returns empty string',
        () {
      // Arrange
      const String input = '  not-a-date  ';

      // Act
      final String result = DateUtils.normalizeIsoOrEmpty(input);

      // Assert
      expect(result, '');
    });

    test(
        'Given non-date dynamic value When normalizeIsoOrEmpty Then returns empty string',
        () {
      // Arrange
      final Object input = <String, dynamic>{'x': 1};

      // Act
      final String result = DateUtils.normalizeIsoOrEmpty(input);

      // Assert
      expect(result, '');
    });

    test(
        'Given output from normalizeIsoOrEmpty When parsed Then round-trips the same instant',
        () {
      // Arrange
      final DateTime utc = DateTime.utc(2026, 1, 3, 12, 0, 0, 123);

      // Act
      final String normalized = DateUtils.normalizeIsoOrEmpty(utc);
      final DateTime parsed = DateTime.parse(normalized);

      // Assert
      expect(parsed.isUtc, true);
      expect(parsed.toUtc(), utc);
    });
  });
}
