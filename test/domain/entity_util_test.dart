import 'package:flutter_test/flutter_test.dart';

import 'mock_entity_util.dart';

void main() {
  group('MockEntityUtil Tests', () {
    late MockEntityUtil util;

    setUp(() {
      util = const MockEntityUtil();
    });

    test('generateUniqueId generates a unique ID', () {
      final String id1 = util.generateUniqueId();
      final String id2 = util.generateUniqueId();

      expect(id1, isNotNull);
      expect(id2, isNotNull);
      expect(id1, isNotEmpty); // Ensure IDs are unique
    });

    test('isValidEntity returns true for valid entities', () {
      final Map<String, String> validEntity = <String, String>{
        'id': '123',
        'name': 'Entity',
      };
      final bool result = util.isValidEntity(validEntity);

      expect(result, isTrue);
    });

    test('isValidEntity returns false for entities without an ID', () {
      final Map<String, String> invalidEntity = <String, String>{
        'name': 'Entity',
      };
      final bool result = util.isValidEntity(invalidEntity);

      expect(result, isFalse);
    });

    test('isValidEntity returns false for entities with an empty ID', () {
      final Map<String, String> invalidEntity = <String, String>{
        'id': '',
        'name': 'Entity',
      };
      final bool result = util.isValidEntity(invalidEntity);

      expect(result, isFalse);
    });

    test('isValidEntity returns false for entities with a non-string ID', () {
      final Map<String, Object> invalidEntity = <String, Object>{
        'name': 'Entity',
      };
      final bool result = util.isValidEntity(invalidEntity);

      expect(result, isFalse);
    });
  });
}
