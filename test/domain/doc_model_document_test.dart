import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelDocDocument', () {
    const ModelDocDocument document = ModelDocDocument(
      id: 'doc_welcome',
      title: 'Bienvenido',
      blocksByIndex: <int, ModelDocBlock>{
        0: ModelDocBlock(
          kind: ModelDocBlockKindEnum.heading,
          content: 'Bienvenido',
          level: 1,
        ),
        1: ModelDocBlock(
          kind: ModelDocBlockKindEnum.paragraph,
          content: 'Este documento introduce la plataforma.',
        ),
        2: ModelDocBlock(
          kind: ModelDocBlockKindEnum.markdown,
          content: '- item 1\n- item 2',
        ),
      },
    );

    test(
      'Given a canonical document When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = document.toJson();
        final ModelDocDocument roundtrip = ModelDocDocument.fromJson(json);

        expect(roundtrip, document);
        expect(roundtrip.toJson(), document.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelDocDocumentEnum.id.name: 'doc_welcome',
          ModelDocDocumentEnum.title.name: 'Bienvenido',
          ModelDocDocumentEnum.blocksByIndex.name: <String, dynamic>{
            '0': <String, dynamic>{
              ModelDocBlockEnum.kind.name: 'heading',
              ModelDocBlockEnum.content.name: 'Bienvenido',
              ModelDocBlockEnum.level.name: 1,
            },
            '1': <String, dynamic>{
              ModelDocBlockEnum.kind.name: 'paragraph',
              ModelDocBlockEnum.content.name:
                  'Este documento introduce la plataforma.',
            },
            '2': <String, dynamic>{
              ModelDocBlockEnum.kind.name: 'markdown',
              ModelDocBlockEnum.content.name: '- item 1\n- item 2',
            },
          },
        };

        final ModelDocDocument parsed = ModelDocDocument.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a document When copyWith overrides fields Then returns updated copy',
      () {
        final ModelDocDocument copy = document.copyWith(
          title: 'Bienvenida',
          blocksByIndex: <int, ModelDocBlock>{
            0: const ModelDocBlock(
              kind: ModelDocBlockKindEnum.heading,
              content: 'Bienvenida',
              level: 1,
            ),
          },
        );

        expect(copy.title, 'Bienvenida');
        expect(copy.blocksByIndex.length, 1);
        expect(copy.blocksByIndex[0]?.content, 'Bienvenida');
        expect(copy, isNot(document));
      },
    );
  });
}
