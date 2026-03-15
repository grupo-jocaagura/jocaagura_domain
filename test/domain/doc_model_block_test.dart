import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelDocBlock', () {
    const ModelDocBlock block = ModelDocBlock(
      kind: ModelDocBlockKindEnum.heading,
      content: 'Bienvenido',
      level: 1,
    );

    test(
      'Given a canonical block When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = block.toJson();
        final ModelDocBlock roundtrip = ModelDocBlock.fromJson(json);

        expect(roundtrip, block);
        expect(roundtrip.toJson(), block.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelDocBlockEnum.kind.name: 'heading',
          ModelDocBlockEnum.content.name: 'Bienvenido',
          ModelDocBlockEnum.level.name: 1,
        };

        final ModelDocBlock parsed = ModelDocBlock.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a block When copyWith overrides fields Then returns updated copy',
      () {
        final ModelDocBlock copy = block.copyWith(
          kind: ModelDocBlockKindEnum.markdown,
          content: '- item 1\n- item 2',
          level: null,
        );

        expect(copy.kind, ModelDocBlockKindEnum.markdown);
        expect(copy.content, '- item 1\n- item 2');
        expect(copy.level, isNull);
        expect(copy, isNot(block));
      },
    );
  });
}
