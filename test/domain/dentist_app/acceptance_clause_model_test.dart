import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('AcceptanceClauseModel Tests', () {
    const String id = 'acm789';
    final SignatureModel odontologistSignature = defaultOdontologistSignature;
    const String patientPrint = 'patientPrintData';
    final SignatureModel patientSignature = defaultPatientSignature;
    const String stringAcceptanceLeyend = '''
# Términos de Aceptación
Por la presente, yo, el paciente, acepto los términos y condiciones del tratamiento odontológico proporcionado por [Nombre del odontólogo] y confirmo que he sido informado adecuadamente sobre los procedimientos y riesgos involucrados.

Firma del Odontólogo: ![Firma del Odontólogo](data:image/png;base64,base64EncodedImageStringForOdontologistSignature)
Firma del Paciente: ![Firma del Paciente](data:image/png;base64,base64EncodedImageStringForPatientSignature)

ID: xmio
    ''';

    test('default model is correct', () {
      expect(defaultAcceptanceClauseModel, isA<AcceptanceClauseModel>());
      expect(defaultAcceptanceClauseModel.id, id);
      expect(
        defaultAcceptanceClauseModel.odontologistSignature,
        odontologistSignature,
      );
      expect(defaultAcceptanceClauseModel.patientPrint, patientPrint);
      expect(defaultAcceptanceClauseModel.patientSignature, patientSignature);
      expect(
        defaultAcceptanceClauseModel.stringAcceptanceLeyend,
        stringAcceptanceLeyend,
      );
    });

    test('constructor sets values properly', () {
      final AcceptanceClauseModel clause = AcceptanceClauseModel(
        id: id,
        odontologistSignature: odontologistSignature,
        patientPrint: patientPrint,
        patientSignature: patientSignature,
        stringAcceptanceLeyend: stringAcceptanceLeyend,
      );

      expect(clause.id, id);
      expect(clause.odontologistSignature, odontologistSignature);
      expect(clause.patientPrint, patientPrint);
      expect(clause.patientSignature, patientSignature);
      expect(clause.stringAcceptanceLeyend, stringAcceptanceLeyend);
    });

    test('copyWith updates values', () {
      final AcceptanceClauseModel updatedClause =
          defaultAcceptanceClauseModel.copyWith(
        id: 'new_id',
        odontologistSignature:
            defaultOdontologistSignature.copyWith(id: 'new_sig'),
        patientPrint: 'new_patientPrint',
        patientSignature: defaultPatientSignature.copyWith(id: 'new_sig'),
        stringAcceptanceLeyend: 'new_leyend',
      );

      expect(updatedClause.id, 'new_id');
      expect(updatedClause.odontologistSignature.id, 'new_sig');
      expect(updatedClause.patientPrint, 'new_patientPrint');
      expect(updatedClause.patientSignature.id, 'new_sig');
      expect(updatedClause.stringAcceptanceLeyend, 'new_leyend');
    });

    test('copyWith without arguments returns the same object', () {
      final AcceptanceClauseModel copiedClause =
          defaultAcceptanceClauseModel.copyWith();
      expect(copiedClause, equals(defaultAcceptanceClauseModel));
      expect(
        copiedClause.hashCode,
        equals(defaultAcceptanceClauseModel.hashCode),
      );
    });

    test('toJson returns correct map', () {
      final AcceptanceClauseModel clause = defaultAcceptanceClauseModel;
      final Map<String, dynamic> json = clause.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json[AcceptanceClauseEnum.id.name], id);
      expect(
        json[AcceptanceClauseEnum.odontologistSignature.name],
        odontologistSignature.toJson(),
      );
      expect(json[AcceptanceClauseEnum.patientPrint.name], patientPrint);
      expect(
        json[AcceptanceClauseEnum.patientSignature.name],
        patientSignature.toJson(),
      );
      expect(
        json[AcceptanceClauseEnum.stringAcceptanceLeyend.name],
        stringAcceptanceLeyend,
      );
    });

    test('fromJson creates a new instance from json', () {
      final Map<String, Object> json = <String, Object>{
        AcceptanceClauseEnum.id.name: 'new_id',
        AcceptanceClauseEnum.odontologistSignature.name:
            defaultOdontologistSignature.toJson(),
        AcceptanceClauseEnum.patientPrint.name: 'new_patientPrint',
        AcceptanceClauseEnum.patientSignature.name:
            defaultPatientSignature.toJson(),
        AcceptanceClauseEnum.stringAcceptanceLeyend.name: 'new_leyend',
      };

      print(json);

      final AcceptanceClauseModel fromJsonClause =
          AcceptanceClauseModel.fromJson(json);
      expect(fromJsonClause, isA<AcceptanceClauseModel>());
      expect(fromJsonClause.id, 'new_id');
      expect(fromJsonClause.odontologistSignature.id, 'sig123');
      expect(fromJsonClause.patientPrint, 'new_patientPrint');
      expect(fromJsonClause.patientSignature.id, 'sig456');
      expect(fromJsonClause.stringAcceptanceLeyend, 'new_leyend');
    });

    test('hashCode is consistent for the same values', () {
      final AcceptanceClauseModel clause1 = defaultAcceptanceClauseModel;
      final AcceptanceClauseModel clause2 = defaultAcceptanceClauseModel;

      expect(clause1.hashCode, clause2.hashCode);
    });

    test('equality operator works correctly', () {
      final AcceptanceClauseModel clause1 = defaultAcceptanceClauseModel;
      final AcceptanceClauseModel clause2 = defaultAcceptanceClauseModel;

      expect(clause1, equals(clause2));
    });
  });
}
