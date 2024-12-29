import 'package:jocaagura_domain/jocaagura_domain.dart';

class MockEntityUtil extends EntityUtil {
  const MockEntityUtil();

  String generateUniqueId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  bool isValidEntity(Map<String, dynamic> entity) {
    final String id = entity['id']?.toString() ?? '';
    return id.isNotEmpty;
  }
}
