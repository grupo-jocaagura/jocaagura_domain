import 'package:jocaagura_domain/jocaagura_domain.dart';

final List<Map<String, dynamic>> _entities = <Map<String, dynamic>>[];

class MockEntityService extends EntityService {
  const MockEntityService();

  void createEntity(Map<String, dynamic> entity) {
    final String id = entity['id']?.toString() ?? '';

    if (id.isNotEmpty) {
      _entities.add(entity);
    } else {
      throw ArgumentError('Entity must have a valid "id" field.');
    }
  }

  Map<String, dynamic>? readEntity(String id) {
    return _entities.firstWhere(
      (Map<String, dynamic> entity) => entity['id'] == id,
      orElse: () => <String, dynamic>{},
    );
  }

  bool updateEntity(String id, Map<String, dynamic> updatedFields) {
    final int entityIndex = _entities
        .indexWhere((Map<String, dynamic> entity) => entity['id'] == id);
    if (entityIndex != -1) {
      _entities[entityIndex] = <String, dynamic>{
        ..._entities[entityIndex],
        ...updatedFields,
      };
      return true;
    }
    return false;
  }

  bool deleteEntity(String id) {
    final Map<String, dynamic>? entity = readEntity(id);
    if (entity?.isNotEmpty ?? false) {
      _entities.remove(entity);
      return true;
    }
    return false;
  }

  List<Map<String, dynamic>> get entities =>
      List<Map<String, dynamic>>.unmodifiable(_entities);
}
