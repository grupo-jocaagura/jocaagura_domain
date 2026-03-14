import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelJsonSchemaReference', () {
    final ModelJsonSchemaReference reference = ModelJsonSchemaReference(
      id: 'schema-ref-001',
      sourceSchemaId:
          'https://jocaagura.dev/schemas/jocaagura_domain/v1/medical_record_model.schema.json',
      targetSchemaId:
          'https://jocaagura.dev/schemas/jocaagura_domain/v1/person_model.schema.json',
      referenceType: JsonSchemaReferenceTypeEnum.ref,
      path: '/properties/patient',
      referenceDescription:
          'Medical record references the person contract for patient.',
    );

    test(
      'Given a reference When toJson and fromJson Then preserves the dependency contract',
      () {
        final Map<String, dynamic> json = reference.toJson();
        final ModelJsonSchemaReference roundtrip =
            ModelJsonSchemaReference.fromJson(json);

        expect(roundtrip, reference);
        expect(roundtrip.toJson(), reference.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelJsonSchemaReferenceEnum.id.name: 'schema-ref-001',
          ModelJsonSchemaReferenceEnum.sourceSchemaId.name:
              'https://jocaagura.dev/schemas/jocaagura_domain/v1/medical_record_model.schema.json',
          ModelJsonSchemaReferenceEnum.targetSchemaId.name:
              'https://jocaagura.dev/schemas/jocaagura_domain/v1/person_model.schema.json',
          ModelJsonSchemaReferenceEnum.referenceType.name: 'ref',
          ModelJsonSchemaReferenceEnum.path.name: '/properties/patient',
          ModelJsonSchemaReferenceEnum.referenceDescription.name:
              'Medical record references the person contract for patient.',
        };

        final ModelJsonSchemaReference parsed =
            ModelJsonSchemaReference.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a reference When copyWith overrides fields Then returns updated copy',
      () {
        final ModelJsonSchemaReference copy = reference.copyWith(
          referenceType: JsonSchemaReferenceTypeEnum.property,
          path: '/properties/patient/properties/id',
        );

        expect(copy.referenceType, JsonSchemaReferenceTypeEnum.property);
        expect(copy.path, '/properties/patient/properties/id');
        expect(copy.sourceSchemaId, reference.sourceSchemaId);
        expect(copy.targetSchemaId, reference.targetSchemaId);
        expect(copy, isNot(reference));
      },
    );
  });
}
