import 'package:jocaagura_domain/jocaagura_domain.dart';

final List<Map<String, dynamic>> _entities = <Map<String, dynamic>>[];

class MockEntityProvider extends EntityProvider {
  const MockEntityProvider();
  void addEntity(Map<String, dynamic> entity) {
    _entities.add(entity);
  }

  List<Map<String, dynamic>> get entities => _entities;

  Map<String, dynamic>? getEntityById(String id) {
    return _entities.firstWhere(
      (Map<String, dynamic> entity) => entity['id'] == id,
      orElse: () => <String, dynamic>{},
    );
  }

  bool deleteEntityById(String id) {
    final Map<String, dynamic>? entity = getEntityById(id);
    if (entity != null) {
      _entities.remove(entity);
      return true;
    }
    return false;
  }
}
