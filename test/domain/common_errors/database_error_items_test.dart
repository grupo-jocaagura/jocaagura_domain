import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('DatabaseErrorItems catalog', () {
    test(
        'Given predefined database errors When inspected Then all use DB code prefix and database source meta',
        () {
      final List<ErrorItem> errors = <ErrorItem>[
        DatabaseErrorItems.connectionFailed,
        DatabaseErrorItems.unavailable,
        DatabaseErrorItems.unauthorized,
        DatabaseErrorItems.forbidden,
        DatabaseErrorItems.notFound,
        DatabaseErrorItems.alreadyExists,
        DatabaseErrorItems.conflict,
        DatabaseErrorItems.constraintViolation,
        DatabaseErrorItems.validationFailed,
        DatabaseErrorItems.serializationError,
        DatabaseErrorItems.timeout,
        DatabaseErrorItems.quotaExceeded,
        DatabaseErrorItems.transactionFailed,
        DatabaseErrorItems.deadlock,
        DatabaseErrorItems.streamClosed,
      ];

      for (final ErrorItem error in errors) {
        expect(error.code.startsWith('DB_'), true);
        expect(
          error.meta[DatabaseErrorItems.sourceKey],
          DatabaseErrorItems.sourceValue,
        );
      }
    });

    test(
        'Given predefined database errors When inspected Then each error exposes expected severity',
        () {
      final Map<ErrorItem, ErrorLevelEnum> expectedLevels =
          <ErrorItem, ErrorLevelEnum>{
        DatabaseErrorItems.connectionFailed: ErrorLevelEnum.danger,
        DatabaseErrorItems.unavailable: ErrorLevelEnum.severe,
        DatabaseErrorItems.unauthorized: ErrorLevelEnum.severe,
        DatabaseErrorItems.forbidden: ErrorLevelEnum.severe,
        DatabaseErrorItems.notFound: ErrorLevelEnum.warning,
        DatabaseErrorItems.alreadyExists: ErrorLevelEnum.warning,
        DatabaseErrorItems.conflict: ErrorLevelEnum.warning,
        DatabaseErrorItems.constraintViolation: ErrorLevelEnum.warning,
        DatabaseErrorItems.validationFailed: ErrorLevelEnum.warning,
        DatabaseErrorItems.serializationError: ErrorLevelEnum.severe,
        DatabaseErrorItems.timeout: ErrorLevelEnum.warning,
        DatabaseErrorItems.quotaExceeded: ErrorLevelEnum.severe,
        DatabaseErrorItems.transactionFailed: ErrorLevelEnum.severe,
        DatabaseErrorItems.deadlock: ErrorLevelEnum.severe,
        DatabaseErrorItems.streamClosed: ErrorLevelEnum.warning,
      };

      for (final MapEntry<ErrorItem, ErrorLevelEnum> entry
          in expectedLevels.entries) {
        expect(entry.key.errorLevel, entry.value);
      }
    });
  });

  group('DatabaseErrorItems.unknown', () {
    test(
        'Given no reason When unknown is called Then returns default unknown database error',
        () {
      final ErrorItem result = DatabaseErrorItems.unknown();

      expect(result.title, 'Unknown Database Error');
      expect(result.code, 'DB_UNKNOWN');
      expect(result.description, 'An unknown database error has occurred.');
      expect(
        result.meta[DatabaseErrorItems.sourceKey],
        DatabaseErrorItems.sourceValue,
      );
    });

    test(
        'Given custom reason When unknown is called Then uses reason as description',
        () {
      final ErrorItem result = DatabaseErrorItems.unknown(
        reason: 'Provider returned an unexpected status.',
      );

      expect(result.title, 'Unknown Database Error');
      expect(result.code, 'DB_UNKNOWN');
      expect(result.description, 'Provider returned an unexpected status.');
      expect(
        result.meta[DatabaseErrorItems.sourceKey],
        DatabaseErrorItems.sourceValue,
      );
    });
  });

  group('DatabaseErrorItems.fromCode', () {
    test(
        'Given known database code When fromCode is called Then returns matching predefined error',
        () {
      final Map<String, ErrorItem> expectedItems = <String, ErrorItem>{
        'DB_CONN_FAILED': DatabaseErrorItems.connectionFailed,
        'DB_UNAVAILABLE': DatabaseErrorItems.unavailable,
        'DB_UNAUTHORIZED': DatabaseErrorItems.unauthorized,
        'DB_FORBIDDEN': DatabaseErrorItems.forbidden,
        'DB_NOT_FOUND': DatabaseErrorItems.notFound,
        'DB_ALREADY_EXISTS': DatabaseErrorItems.alreadyExists,
        'DB_CONFLICT': DatabaseErrorItems.conflict,
        'DB_CONSTRAINT_VIOLATION': DatabaseErrorItems.constraintViolation,
        'DB_VALIDATION_FAILED': DatabaseErrorItems.validationFailed,
        'DB_SERIALIZATION_ERROR': DatabaseErrorItems.serializationError,
        'DB_TIMEOUT': DatabaseErrorItems.timeout,
        'DB_QUOTA_EXCEEDED': DatabaseErrorItems.quotaExceeded,
        'DB_TRANSACTION_FAILED': DatabaseErrorItems.transactionFailed,
        'DB_DEADLOCK': DatabaseErrorItems.deadlock,
        'DB_STREAM_CLOSED': DatabaseErrorItems.streamClosed,
      };

      for (final MapEntry<String, ErrorItem> entry in expectedItems.entries) {
        final ErrorItem result = DatabaseErrorItems.fromCode(entry.key);

        expect(result.code, entry.value.code);
        expect(result.title, entry.value.title);
        expect(result.description, entry.value.description);
        expect(result.errorLevel, entry.value.errorLevel);
        expect(
          result.meta[DatabaseErrorItems.sourceKey],
          DatabaseErrorItems.sourceValue,
        );
      }
    });

    test(
        'Given unknown database code When fromCode is called Then returns unknown error with unrecognized code description',
        () {
      final ErrorItem result = DatabaseErrorItems.fromCode('DB_CUSTOM_FAILURE');

      expect(result.title, 'Unknown Database Error');
      expect(result.code, 'DB_UNKNOWN');
      expect(
        result.description,
        'Unrecognized Database code: DB_CUSTOM_FAILURE',
      );
      expect(
        result.meta[DatabaseErrorItems.sourceKey],
        DatabaseErrorItems.sourceValue,
      );
    });

    test(
        'Given empty database code When fromCode is called Then returns unknown error preserving empty code context',
        () {
      final ErrorItem result = DatabaseErrorItems.fromCode('');

      expect(result.code, 'DB_UNKNOWN');
      expect(result.description, 'Unrecognized Database code: ');
      expect(
        result.meta[DatabaseErrorItems.sourceKey],
        DatabaseErrorItems.sourceValue,
      );
    });
  });
}
