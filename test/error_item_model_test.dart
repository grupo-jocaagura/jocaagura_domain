import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  group('ErrorItem Model', () {
    test(
        'Given valid fields When toJson->fromJson Then round-trip yields equal instance',
        () {
      // Arrange
      final Map<String, Object?> meta = <String, Object?>{'a': 1, 'b': true};
      final ErrorItem original = ErrorItem(
        title: 'Network timeout',
        code: 'NET_TIMEOUT',
        description: 'Request took too long.',
        meta: meta,
        errorLevel: ErrorLevelEnum.severe,
      );

      // Act
      final String encoded = jsonEncode(original.toJson());
      final ErrorItem decoded =
          ErrorItem.fromJson(jsonDecode(encoded) as Map<String, dynamic>);

      // Assert
      expect(decoded, original);
      expect(decoded.hashCode, original.hashCode);
      expect(decoded.errorLevel, ErrorLevelEnum.severe);
      expect(mapEquals(decoded.meta, meta), isTrue);
    });

    test(
        'Given unknown errorLevel string When fromJson Then defaults to systemInfo',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ErrorItemEnum.title.name: 'Strange',
        ErrorItemEnum.code.name: 'X',
        ErrorItemEnum.description.name: 'Unknown level',
        ErrorItemEnum.meta.name: <String, Object?>{},
        ErrorItemEnum.errorLevel.name: 'notARealLevel',
      };

      // Act
      final ErrorItem item = ErrorItem.fromJson(json);

      // Assert
      expect(item.errorLevel, ErrorLevelEnum.systemInfo);
    });

    test(
        'Given copyWith overrides When applied Then only provided fields change',
        () {
      // Arrange
      const ErrorItem base = ErrorItem(
        title: 'A',
        code: 'C',
        description: 'D',
        meta: <String, Object?>{'k': 1},
        errorLevel: ErrorLevelEnum.warning,
      );

      // Act
      final ErrorItem modified = base.copyWith(
        title: 'A2',
        meta: <String, Object?>{'k': 1, 'x': 'y'},
      );

      // Assert
      expect(modified.title, 'A2');
      expect(modified.code, 'C');
      expect(modified.description, 'D');
      expect(modified.errorLevel, ErrorLevelEnum.warning);
      expect(
        mapEquals(modified.meta, <String, Object?>{'k': 1, 'x': 'y'}),
        isTrue,
      );
    });

    test(
        'Given two meta maps with different insertion orders Then equality and hashCode match',
        () {
      // Arrange
      const ErrorItem i1 = ErrorItem(
        title: 'Order',
        code: 'EQ',
        description: 'Order-insensitive meta',
        meta: <String, Object?>{'a': 1, 'b': 2},
      );
      const ErrorItem i2 = ErrorItem(
        title: 'Order',
        code: 'EQ',
        description: 'Order-insensitive meta',
        meta: <String, Object?>{'b': 2, 'a': 1},
      );

      // Assert
      expect(i1, i2);
      expect(i1.hashCode, i2.hashCode);
    });

    test(
        'Given toString When called Then includes title, code, description, level and meta if present',
        () {
      // Arrange
      const ErrorItem item = ErrorItem(
        title: 'Oops',
        code: 'X1',
        description: 'Something happened',
        meta: <String, Object?>{'ctx': 'flowA'},
        errorLevel: ErrorLevelEnum.warning,
      );

      // Act
      final String s = item.toString();

      // Assert
      expect(s, contains('Oops (X1): Something happened'));
      expect(s, contains('Meta: {ctx: flowA}'));
      expect(s, contains('Level: warning'));
    });

    test(
        'Given mutated meta map After constructing ErrorItem Then equality/hash may change (documenting risk)',
        () {
      // ⚠️ Este test documenta el riesgo actual (pre-refactor).
      // No falla el pipeline; sólo evidencia el comportamiento.
      // Arrange
      final Map<String, Object?> meta = <String, Object?>{'x': 1};
      final ErrorItem a = ErrorItem(
        title: 'Mut',
        code: 'M',
        description: 'test',
        meta: meta,
      );
      final ErrorItem b = a.copyWith();

      expect(a, b); // aún iguales

      // Act: mutamos el mapa original (compartido por referencia)
      meta['x'] = 2;

      // Assert: pueden dejar de ser iguales por efecto lateral
      expect(
        a == b,
        isFalse,
        reason:
            'Meta is mutable and shared by reference; prefer Map.unmodifiable in ctor/fromJson/copyWith.',
      );
    });

    test(
        'Given defaultErrorItem When inspected Then fields match expected defaults',
        () {
      // Assert
      expect(defaultErrorItem.title, 'Unknown Error');
      expect(defaultErrorItem.code, 'ERR_UNKNOWN');
      expect(
        defaultErrorItem.description,
        'An unspecified error has occurred.',
      );
      expect(defaultErrorItem.errorLevel, ErrorLevelEnum.systemInfo);
      expect(defaultErrorItem.meta['severity'], 'low');
    });
  });

  group('ErrorLevelEnum parsing', () {
    test('Given valid names When parsed Then matches enum values', () {
      for (final ErrorLevelEnum level in ErrorLevelEnum.values) {
        expect(ErrorItem.getErrorLevelFromString(level.name), level);
      }
    });

    test('Given null/empty When parsed Then defaults to systemInfo', () {
      expect(
        ErrorItem.getErrorLevelFromString(null),
        ErrorLevelEnum.systemInfo,
      );
      expect(ErrorItem.getErrorLevelFromString(''), ErrorLevelEnum.systemInfo);
    });
  });
}
