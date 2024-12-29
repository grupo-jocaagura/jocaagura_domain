import 'package:flutter_test/flutter_test.dart';

import 'mock_entity_service.dart';

void main() {
  group('MockEntityService Tests', () {
    late MockEntityService service;

    setUp(() {
      service = const MockEntityService();
    });

    test('createEntity adds a valid entity', () {
      final Map<String, String> entity = <String, String>{
        'id': '1',
        'name': 'Entity 1',
      };
      service.createEntity(entity);

      expect(service.entities, contains(entity));
    });

    test('createEntity throws ArgumentError for invalid entity', () {
      final Map<String, String> invalidEntity = <String, String>{
        'name': 'Entity without ID',
      };

      expect(() => service.createEntity(invalidEntity), throwsArgumentError);
    });

    test('readEntity returns the correct entity', () {
      final Map<String, String> entity = <String, String>{
        'id': '1',
        'name': 'Entity 1',
      };
      service.createEntity(entity);

      final Map<String, dynamic>? result = service.readEntity('1');
      expect(result, equals(entity));
    });

    test('readEntity returns null for non-existent entity', () {
      final Map<String, dynamic>? result = service.readEntity('nonexistent');
      expect(result, isEmpty);
    });

    test('updateEntity updates the entity and returns true', () {
      final Map<String, String> entity = <String, String>{
        'id': '1',
        'name': 'Entity 1',
      };
      service.createEntity(entity);

      final Map<String, String> updatedFields = <String, String>{
        'name': 'Updated Entity 1',
      };
      final bool result = service.updateEntity('1', updatedFields);

      expect(result, isTrue);
      expect(service.readEntity('1')?['name'], equals('Updated Entity 1'));
    });

    test('updateEntity returns false for non-existent entity', () {
      final Map<String, String> updatedFields = <String, String>{
        'name': 'Updated Entity',
      };
      final bool result = service.updateEntity('nonexistent', updatedFields);

      expect(result, isFalse);
    });

    test('deleteEntity removes the entity and returns true', () {
      final Map<String, String> entity = <String, String>{
        'id': '3',
        'name': 'Entity 3',
      };
      service.createEntity(entity);

      final bool result = service.deleteEntity('3');
      expect(result, isTrue);
      expect(service.entities, isNot(contains(entity)));
    });

    test('deleteEntity returns false for non-existent entity', () {
      final bool result = service.deleteEntity('nonexistent');
      expect(result, isFalse);
    });

    test('entities returns an unmodifiable list', () {
      final Map<String, String> entity = <String, String>{
        'id': '1',
        'name': 'Entity 1',
      };
      service.createEntity(entity);

      expect(
        () => service.entities
            .add(<String, dynamic>{'id': '2', 'name': 'Entity 2'}),
        throwsUnsupportedError,
      );
    });
  });
}
