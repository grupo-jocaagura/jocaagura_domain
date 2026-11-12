import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaagura_domain_core/jocaagura_domain_core.dart' as core;

void main() {
  test('local models and core vectors share the canonical Model contract', () {
    expect(identical(Model, core.Model), isTrue);
    final List<core.Model> models = <Model>[
      defaultErrorItem,
      defaultModelVector,
      UserModel.fromJson(const <String, dynamic>{}),
    ];
    for (final core.Model model in models) {
      final Model copy = model.copyWith();
      expect(copy, isA<core.Model>());
      expect(copy.toJson(), model.toJson());
    }
  });
}
