import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ErrorItem Tests', () {
    test('Constructor sets values correctly', () {
      const ErrorItem error = ErrorItem(
        title: 'Network Failure',
        code: 'ERR_NETWORK',
        description: 'Failed to connect to server',
        meta: <String, dynamic>{'retryAfter': 5},
      );

      expect(error.title, 'Network Failure');
      expect(error.code, 'ERR_NETWORK');
      expect(error.description, 'Failed to connect to server');
      expect(error.meta, containsPair('retryAfter', 5));
    });

    test('toJson returns correct map', () {
      const ErrorItem error = ErrorItem(
        title: 'Timeout',
        code: 'ERR_TIMEOUT',
        description: 'Request timed out',
        meta: <String, dynamic>{'duration': 3000},
      );

      final Map<String, dynamic> json = error.toJson();

      expect(json['title'], 'Timeout');
      expect(json['code'], 'ERR_TIMEOUT');
      expect(json['description'], 'Request timed out');
      expect(json['meta'], containsPair('duration', 3000));
    });

    test('fromJson creates correct object', () {
      final Map<String, Object> json = <String, Object>{
        'title': 'API Error',
        'code': 'ERR_API',
        'description': 'Invalid response',
        'meta': <String, int>{'status': 500},
      };

      final ErrorItem error = ErrorItem.fromJson(json);

      expect(error.title, 'API Error');
      expect(error.code, 'ERR_API');
      expect(error.description, 'Invalid response');
      expect(error.meta, containsPair('status', 500));
    });

    test('fromJson handles missing meta field gracefully', () {
      final Map<String, String> json = <String, String>{
        'title': 'Simple Error',
        'code': 'ERR_SIMPLE',
        'description': 'Missing meta field',
      };

      final ErrorItem error = ErrorItem.fromJson(json);

      expect(error.title, 'Simple Error');
      expect(error.code, 'ERR_SIMPLE');
      expect(error.description, 'Missing meta field');
      expect(error.meta, isEmpty);
    });

    test('copyWith updates selected fields', () {
      const ErrorItem original = ErrorItem(
        title: 'Server Error',
        code: 'ERR_SERVER',
        description: 'Internal error',
        meta: <String, dynamic>{'attempts': 1},
      );

      final ErrorItem copy = original.copyWith(description: 'Updated error');

      expect(copy.title, 'Server Error');
      expect(copy.code, 'ERR_SERVER');
      expect(copy.description, 'Updated error');
      expect(copy.meta, containsPair('attempts', 1));
    });

    test('Equality operator works correctly', () {
      const ErrorItem error1 = ErrorItem(
        title: 'Error',
        code: 'ERR_CODE',
        description: 'Something went wrong',
        meta: <String, dynamic>{'info': 'none'},
      );

      const ErrorItem error2 = ErrorItem(
        title: 'Error',
        code: 'ERR_CODE',
        description: 'Something went wrong',
        meta: <String, dynamic>{'info': 'none'},
      );

      expect(error1, equals(error2));
    });

    test('defaultErrorItem has expected values', () {
      expect(defaultErrorItem.title, 'Unknown Error');
      expect(defaultErrorItem.code, 'ERR_UNKNOWN');
      expect(
        defaultErrorItem.description,
        'An unspecified error has occurred.',
      );
      expect(defaultErrorItem.meta, containsPair('severity', 'low'));
    });
  });
  group('ErrorItem Extended Tests', () {
    test('getErrorLevelFromString returns correct enum for valid input', () {
      expect(
        ErrorItem.getErrorLevelFromString('warning'),
        ErrorLevelEnum.warning,
      );
      expect(
        ErrorItem.getErrorLevelFromString('severe'),
        ErrorLevelEnum.severe,
      );
      expect(
        ErrorItem.getErrorLevelFromString('danger'),
        ErrorLevelEnum.danger,
      );
      expect(
        ErrorItem.getErrorLevelFromString('systemInfo'),
        ErrorLevelEnum.systemInfo,
      );
    });

    test('getErrorLevelFromString returns systemInfo for invalid or null input',
        () {
      expect(
        ErrorItem.getErrorLevelFromString('unknown'),
        ErrorLevelEnum.systemInfo,
      );
      expect(
        ErrorItem.getErrorLevelFromString(null),
        ErrorLevelEnum.systemInfo,
      );
    });

    test('fromJson includes errorLevel parsing', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'title': 'Conflict',
        'code': 'ERR_409',
        'description': 'There is a conflict',
        'meta': <String, dynamic>{'conflictType': 'id'},
        'errorLevel': 'severe',
      };

      final ErrorItem error = ErrorItem.fromJson(json);

      expect(error.title, 'Conflict');
      expect(error.code, 'ERR_409');
      expect(error.description, 'There is a conflict');
      expect(error.meta, containsPair('conflictType', 'id'));
      expect(error.errorLevel, ErrorLevelEnum.severe);
    });

    test('toString returns formatted output with errorLevel and meta', () {
      const ErrorItem error = ErrorItem(
        title: 'Unauthorized',
        code: 'ERR_401',
        description: 'Authentication failed',
        meta: <String, dynamic>{'reason': 'token expired'},
        errorLevel: ErrorLevelEnum.warning,
      );

      final String result = error.toString();

      expect(result, contains('Unauthorized (ERR_401): Authentication failed'));
      expect(result, contains('Meta: {reason: token expired}'));
      expect(result, contains('Level: warning'));
    });

    test('copyWith preserves or updates errorLevel correctly', () {
      const ErrorItem original = ErrorItem(
        title: 'Error',
        code: 'GENERIC',
        description: 'An error occurred',
        errorLevel: ErrorLevelEnum.severe,
      );

      final ErrorItem updated =
          original.copyWith(errorLevel: ErrorLevelEnum.danger);

      expect(updated.errorLevel, ErrorLevelEnum.danger);
      expect(original.errorLevel, ErrorLevelEnum.severe);
      expect(updated == original, false);
      expect(updated.hashCode != original.hashCode, true);
    });
  });
}
