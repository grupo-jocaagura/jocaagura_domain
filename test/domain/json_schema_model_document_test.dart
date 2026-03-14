import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelJsonSchemaDocument', () {
    final DateTime createdAt = DateTime.utc(2026, 3, 14, 12);
    final DateTime updatedAt = DateTime.utc(2026, 3, 14, 13);

    final Map<String, dynamic> canonicalSchema = <String, dynamic>{
      r'$schema': 'https://json-schema.org/draft/2020-12/schema',
      r'$id':
          'https://jocaagura.dev/schemas/jocaagura_domain/v1/address_model.schema.json',
      'title': 'AddressModel',
      'description': 'Canonical JSON contract for AddressModel.',
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, dynamic>{
        'id': <String, dynamic>{'type': 'string'},
      },
      'required': <String>['id'],
      'examples': <Map<String, dynamic>>[
        <String, dynamic>{'id': 'addr_001'},
      ],
    };

    final Map<String, dynamic> canonicalExample = <String, dynamic>{
      'id': 'addr_001',
    };

    final ModelJsonSchemaDocument document = ModelJsonSchemaDocument(
      id: 'schema-doc-001',
      schemaId:
          'https://jocaagura.dev/schemas/jocaagura_domain/v1/address_model.schema.json',
      schemaTitle: 'AddressModel',
      domainModel: 'AddressModel',
      version: 'v1',
      schemaDescription: 'Canonical schema document for AddressModel.',
      schema: canonicalSchema,
      example: canonicalExample,
      tags: const <String>['base', 'address'],
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: true,
    );

    test(
      'Given a canonical document When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = document.toJson();
        final ModelJsonSchemaDocument roundtrip =
            ModelJsonSchemaDocument.fromJson(json);

        expect(roundtrip, document);
        expect(roundtrip.toJson(), document.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelJsonSchemaDocumentEnum.id.name: 'schema-doc-001',
          ModelJsonSchemaDocumentEnum.schemaId.name:
              'https://jocaagura.dev/schemas/jocaagura_domain/v1/address_model.schema.json',
          ModelJsonSchemaDocumentEnum.schemaTitle.name: 'AddressModel',
          ModelJsonSchemaDocumentEnum.domainModel.name: 'AddressModel',
          ModelJsonSchemaDocumentEnum.version.name: 'v1',
          ModelJsonSchemaDocumentEnum.schemaDescription.name:
              'Canonical schema document for AddressModel.',
          ModelJsonSchemaDocumentEnum.schema.name: canonicalSchema,
          ModelJsonSchemaDocumentEnum.example.name: canonicalExample,
          ModelJsonSchemaDocumentEnum.tags.name: <String>['base', 'address'],
          ModelJsonSchemaDocumentEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          ModelJsonSchemaDocumentEnum.updatedAt.name:
              DateUtils.dateTimeToString(updatedAt),
          ModelJsonSchemaDocumentEnum.isActive.name: true,
        };

        final ModelJsonSchemaDocument parsed =
            ModelJsonSchemaDocument.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a document When copyWith overrides selected fields Then returns updated immutable copy',
      () {
        final ModelJsonSchemaDocument copy = document.copyWith(
          schemaTitle: 'Address Contract',
          isActive: false,
          tags: const <String>['base', 'contract'],
        );

        expect(copy.schemaTitle, 'Address Contract');
        expect(copy.isActive, isFalse);
        expect(copy.tags, const <String>['base', 'contract']);
        expect(copy.schemaId, document.schemaId);
        expect(copy.schema, document.schema);
        expect(copy, isNot(document));
      },
    );
  });
}
