import 'package:flutter_test/flutter_test.dart';

import '../mock_entity_provider.dart';

void main() {
  group('MockEntityProvider Tests', () {
    late MockEntityProvider provider;

    setUp(() {
      provider = const MockEntityProvider();
    });

    test('addEntity adds an entity to the provider', () {
      final Map<String, String> entity = <String, String>{
        'id': '1',
        'name': 'Entity 1',
      };
      provider.addEntity(entity);

      expect(provider.entities, contains(entity));
      expect(provider.entities.length, 1);
    });

    test('getEntityById returns the correct entity when it exists', () {
      final Map<String, String> entity1 = <String, String>{
        'id': '1',
        'name': 'Entity 1',
      };
      final Map<String, String> entity2 = <String, String>{
        'id': '2',
        'name': 'Entity 2',
      };
      provider.addEntity(entity1);
      provider.addEntity(entity2);

      final Map<String, dynamic>? result = provider.getEntityById('1');
      expect(result, equals(entity1));
    });

    test('getEntityById returns null when the entity does not exist', () {
      final Map<String, dynamic>? result =
          provider.getEntityById('nonexistent');
      expect(result, isEmpty);
    });

    test('deleteEntityById removes the correct entity and returns true', () {
      final Map<String, String> entity = <String, String>{
        'id': '3',
        'name': 'Entity 1',
      };
      provider.addEntity(entity);

      final bool deleteResult = provider.deleteEntityById('3');
      expect(deleteResult, isTrue);
      expect(provider.entities, isNot(contains(entity)));
    });

    test('deleteEntityById returns false when the entity does not exist', () {
      final bool deleteResult = provider.deleteEntityById('nonexistent');
      expect(deleteResult, isA<bool>());
    });

    test(
        'deleteEntityById does not affect the list when the entity does not exist',
        () {
      final Map<String, String> entity = <String, String>{
        'id': '3',
        'name': 'Entity 3',
      };
      provider.addEntity(entity);

      provider.deleteEntityById('nonexistent');
      expect(provider.entities, contains(entity));
      expect(provider.entities.length, greaterThanOrEqualTo(1));
    });
  });
}
