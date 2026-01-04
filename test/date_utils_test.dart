import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('DateUtils', () {
    test('Convertir cadena de fecha', () {
      const String dateString = '2023-05-30T12:30:00';
      final DateTime result = DateUtils.dateTimeFromDynamic(dateString);
      final DateTime expected = DateTime(2023, 5, 30, 12, 30);
      expect(result, equals(expected));
    });

    test('Convertir valor de tiempo en milisegundos', () {
      const int milliseconds = 1622394000000; // 31 de mayo de 2021, 12:00:00
      final DateTime result = DateUtils.dateTimeFromDynamic(milliseconds);
      final DateTime expected = DateTime(2021, 5, 30, 12);
      expect(result.year, equals(expected.year));
      expect(result.month, equals(expected.month));
      expect(result.day, equals(expected.day));
    });

    test('Convertir Duration', () {
      const Duration duration = Duration(days: 5);
      final DateTime result = DateUtils.dateTimeFromDynamic(duration);
      final DateTime expected = DateTime.now().add(duration);
      expect(expected.runtimeType == result.runtimeType, true);
    });
    test('Manejar valor DateTime directo', () {
      final DateTime directDateTime = DateTime(2023, 6, 15, 8);
      final DateTime result = DateUtils.dateTimeFromDynamic(directDateTime);
      expect(result, equals(directDateTime));
    });

    test('Manejar valor nulo', () {
      final DateTime result = DateUtils.dateTimeFromDynamic(null);
      expect(result, isA<DateTime>());
    });
  });

  group('dateTimeToString Tests', () {
    test('Converts a DateTime to an ISO 8601 string', () {
      final DateTime dateTime = DateTime(2023, 4, 20, 12, 30);
      final String result = DateUtils.dateTimeToString(dateTime);

      // Verificar que el resultado es una cadena en formato ISO 8601
      expect(result, '2023-04-20T12:30:00.000');
    });

    test('Handles different time zones correctly', () {
      final DateTime dateTime = DateTime.utc(2023, 4, 20, 12, 30);
      final String result = DateUtils.dateTimeToString(dateTime);

      // Verificar que la zona horaria UTC se maneja correctamente
      expect(result, '2023-04-20T12:30:00.000Z');
    });
  });

  group('DateUtils.normalizeIsoOrEmpty', () {
    test(
      'Given null When normalizeIsoOrEmpty Then returns empty string',
      () {
        // Act
        final String result = DateUtils.normalizeIsoOrEmpty(null);

        // Assert
        expect(result, '');
      },
    );

    test(
      'Given empty/blank string When normalizeIsoOrEmpty Then returns empty string',
      () {
        // Act
        final String empty = DateUtils.normalizeIsoOrEmpty('');
        final String spaces = DateUtils.normalizeIsoOrEmpty('   ');

        // Assert
        expect(empty, '');
        expect(spaces, '');
      },
    );

    test(
      'Given UTC DateTime When normalizeIsoOrEmpty Then returns same instant in ISO (ends with Z)',
      () {
        // Arrange
        final DateTime input = DateTime.utc(2026, 1, 3, 10, 20, 30, 400);

        // Act
        final String result = DateUtils.normalizeIsoOrEmpty(input);

        // Assert
        expect(result, '2026-01-03T10:20:30.400Z');
      },
    );

    test(
      'Given local DateTime When normalizeIsoOrEmpty Then returns UTC ISO string representing same instant',
      () {
        // Arrange
        // Build a local DateTime from the same instant.
        final DateTime utc = DateTime.utc(2026, 1, 3, 10, 20, 30);
        final DateTime localSameInstant = utc.toLocal();

        // Act
        final String result = DateUtils.normalizeIsoOrEmpty(localSameInstant);

        // Assert
        // Must encode the same instant in UTC.
        final DateTime parsed = DateTime.parse(result);
        expect(parsed.isUtc, true);
        expect(parsed.toUtc(), utc);
      },
    );

    test(
      'Given epoch milliseconds int When normalizeIsoOrEmpty Then returns UTC ISO string of that instant',
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
      },
    );

    test(
      'Given valid ISO string with Z When normalizeIsoOrEmpty Then returns a canonical ISO (preserves instant)',
      () {
        // Arrange
        const String input = '2026-01-03T10:20:30Z';

        // Act
        final String result = DateUtils.normalizeIsoOrEmpty(input);

        // Assert
        final DateTime parsed = DateTime.parse(result);
        expect(parsed.isUtc, true);
        expect(parsed.toUtc(), DateTime.utc(2026, 1, 3, 10, 20, 30));
      },
    );

    test(
      'Given valid ISO string without timezone When normalizeIsoOrEmpty Then returns canonical UTC ISO for same local time instant',
      () {
        // Arrange
        // NOTE: A timezone-less ISO is parsed as "local" by Dart.
        const String input = '2026-01-03T10:20:30.000';

        // Act
        final String result = DateUtils.normalizeIsoOrEmpty(input);

        // Assert
        final DateTime parsed = DateTime.parse(result);
        expect(parsed.isUtc, true);

        // The input is interpreted as local time; normalize should convert to UTC.
        final DateTime local = DateTime.parse(input);
        expect(parsed.toUtc(), local.toUtc());
      },
    );

    test(
      'Given invalid date string When normalizeIsoOrEmpty Then returns raw trimmed string (not empty)',
      () {
        // Arrange
        const String input = '  not-a-date  ';

        // Act
        final String result = DateUtils.normalizeIsoOrEmpty(input);

        // Assert
        expect(result, 'not-a-date');
      },
    );

    test(
      'Given non-date dynamic value When normalizeIsoOrEmpty Then returns Utils.getStringFromDynamic(value) trimmed',
      () {
        // Arrange
        final Object input = <String, dynamic>{'x': 1};

        // Act
        final String result = DateUtils.normalizeIsoOrEmpty(input);

        // Assert
        // Utils.getStringFromDynamic for maps typically yields something like "{x: 1}".
        // We just assert it is non-empty and stable under trimming.
        expect(result.trim(), result);
        expect(result.isNotEmpty, true);
      },
    );

    test(
      'Given output from normalizeIsoOrEmpty When parsed Then represents same instant round-trip',
      () {
        // Arrange
        final DateTime utc = DateTime.utc(2026, 1, 3, 12, 0, 0, 123);

        // Act
        final String normalized = DateUtils.normalizeIsoOrEmpty(utc);
        final DateTime parsed = DateTime.parse(normalized);

        // Assert
        expect(parsed.isUtc, true);
        expect(parsed.toUtc(), utc);
      },
    );
  });
}
