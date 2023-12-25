import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('LegalIdModel Tests', () {
    const LegalIdTypeEnum idType = LegalIdTypeEnum.cedula;
    const String names = 'John';
    const String lastNames = 'Doe';
    const String legalIdNumber = '987654321';
    const String id = 'a1b2c3d4';
    final Map<String, AttributeModel<dynamic>> attributes =
        <String, AttributeModel<dynamic>>{};

    test('default model is correct', () {
      expect(defaultLegalIdModel, isA<LegalIdModel>());
    });

    // Test the constructor
    test('constructor sets values properly', () {
      final LegalIdModel legalId = LegalIdModel(
        idType: idType,
        names: names,
        lastNames: lastNames,
        legalIdNumber: legalIdNumber,
        id: id,
        attributes: attributes,
      );

      expect(legalId.idType, idType);
      expect(legalId.names, names);
      expect(legalId.lastNames, lastNames);
      expect(legalId.legalIdNumber, legalIdNumber);
      expect(legalId.id, id);
      expect(legalId.attributes, attributes);
    });

    // Test copyWith
    test('copyWith updates values', () {
      final LegalIdModel legalId = defaultLegalIdModel.copyWith(id: 'newId');
      expect(legalId.id, 'newId');
      expect(
        defaultLegalIdModel.toString() ==
            defaultLegalIdModel.copyWith().toString(),
        isTrue,
      );
      expect(
        defaultLegalIdModel == defaultLegalIdModel.copyWith(),
        isTrue,
      );
      // Add more assertions for each property as needed
    });

    // Test from method
    test('from creates a new instance from json', () {
      final Map<String, String> json = <String, String>{
        'id': 'newId',
        'idType': 'Cédula de Ciudadanía',
        'names': 'Jane',
        'lastNames': 'Doe',
        'legalIdNumber': '123456789',
      };

      final LegalIdModel fromJsonLegalId = LegalIdModel.fromJson(json);
      expect(fromJsonLegalId, isA<LegalIdModel>());
      // Add more assertions for each property as needed
    });

    // Test toJson
    test('toJson returns correct map', () {
      const LegalIdModel legalId = defaultLegalIdModel;
      final Map<String, dynamic> json = legalId.toJson();
      expect(json, isA<Map<String, dynamic>>());
      // Add more specific expectations based on your implementation
    });

    // Test hashCode
    test('hashCode is consistent for the same values', () {
      const LegalIdModel legalId1 = defaultLegalIdModel;
      const LegalIdModel legalId2 = defaultLegalIdModel;

      expect(legalId1.hashCode, legalId2.hashCode);
    });

    // Test equality operator
    test('equality operator works correctly', () {
      const LegalIdModel legalId1 = defaultLegalIdModel;
      const LegalIdModel legalId2 = defaultLegalIdModel;

      expect(legalId1, equals(legalId2));
    });

    test('LegalIdTypeEnum extension returns correct description', () {
      expect(LegalIdTypeEnum.cedula.description, 'Cédula de Ciudadanía');
    });

    // Test getEnumValueFromString
    test('getEnumValueFromString returns correct enum value', () {
      expect(
        getEnumValueFromString('Cédula de Ciudadanía'),
        LegalIdTypeEnum.cedula,
      );
      expect(
        getEnumValueFromString(LegalIdTypeEnum.cedula.description),
        LegalIdTypeEnum.cedula,
      );
      expect(
        getEnumValueFromString(LegalIdTypeEnum.cedulaExtranjeria.description),
        LegalIdTypeEnum.cedulaExtranjeria,
      );
      expect(
        getEnumValueFromString(LegalIdTypeEnum.pasaporte.description),
        LegalIdTypeEnum.pasaporte,
      );
      expect(
        getEnumValueFromString(LegalIdTypeEnum.licenciaConduccion.description),
        LegalIdTypeEnum.licenciaConduccion,
      );
      expect(
        getEnumValueFromString(
          LegalIdTypeEnum.certificadoNacidoVivo.description,
        ),
        LegalIdTypeEnum.certificadoNacidoVivo,
      );
      expect(
        getEnumValueFromString('registro civil'),
        LegalIdTypeEnum.registroCivil,
      );
      expect(
        getEnumValueFromString('Cédula de Extranjería'),
        LegalIdTypeEnum.cedulaExtranjeria,
      );
      expect(
        getEnumValueFromString('Cédula de Extranjería'),
        LegalIdTypeEnum.cedulaExtranjeria,
      );
      expect(
        getEnumValueFromString('PASAPORTE'),
        LegalIdTypeEnum.pasaporte,
      );
      expect(
        getEnumValueFromString('LicencIa de Conducción'),
        LegalIdTypeEnum.licenciaConduccion,
      );
      expect(
        getEnumValueFromString('Certificado de Nacido Vivo'),
        LegalIdTypeEnum.certificadoNacidoVivo,
      );
      expect(
        getEnumValueFromString('K3'),
        LegalIdTypeEnum.cedula,
      );
    });
  });
}
