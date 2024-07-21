import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('MedicalDiagnosisTabModel Tests', () {
    // Define test data
    const String id = 'oxo';
    const String condition = 'sane';
    const String observation = 'No observation';
    const double quantity = 0.0;
    final DateTime dateTimeOfRecord = DateTime(2024, 07, 21);

    // Test the default model
    test('default model is correct', () {
      expect(defaultMMedicalDiagnosisModel, isA<MedicalDiagnosisTabModel>());
    });

    // Test the constructor
    test('constructor sets values properly', () {
      final MedicalDiagnosisTabModel diagnosis = MedicalDiagnosisTabModel(
        id: id,
        condition: condition,
        observation: observation,
        quantity: quantity,
        dateTimeOfRecord: dateTimeOfRecord,
      );

      expect(diagnosis.id, id);
      expect(diagnosis.condition, condition);
      expect(diagnosis.observation, observation);
      expect(diagnosis.quantity, quantity);
      expect(diagnosis.dateTimeOfRecord, dateTimeOfRecord);
    });

    // Test copyWith
    test('copyWith updates values', () {
      final MedicalDiagnosisTabModel updatedDiagnosis =
          defaultMMedicalDiagnosisModel.copyWith(
        id: 'newId2',
        condition: 'newCondition2',
        observation: 'newObservation2',
        quantity: 2.0,
        dateTimeOfRecord: DateTime(2025, 07, 22),
      );
      final MedicalDiagnosisTabModel sameUpdatedDiagnosis =
          defaultMMedicalDiagnosisModel.copyWith();

      expect(updatedDiagnosis.id, 'newId2');
      expect(updatedDiagnosis.condition, 'newCondition2');
      expect(updatedDiagnosis.observation, 'newObservation2');
      expect(updatedDiagnosis.quantity, 2.0);
      expect(updatedDiagnosis.dateTimeOfRecord, DateTime(2025, 07, 22));
      expect(updatedDiagnosis == defaultMMedicalDiagnosisModel, false);
      expect(
        sameUpdatedDiagnosis.hashCode == defaultMMedicalDiagnosisModel.hashCode,
        true,
      );
    });

    // Test toJson
    test('toJson returns correct map', () {
      final MedicalDiagnosisTabModel diagnosis = defaultMMedicalDiagnosisModel;
      final Map<String, dynamic> json = diagnosis.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json[MedicalDiagnosisTabModelEnum.id.name], id);
      expect(json[MedicalDiagnosisTabModelEnum.condition.name], condition);
      expect(json[MedicalDiagnosisTabModelEnum.observation.name], observation);
      expect(json[MedicalDiagnosisTabModelEnum.quantity.name], quantity);
      expect(json[MedicalDiagnosisTabModelEnum.dateTimeOfRecord.name],
          DateUtils.dateTimeToString(dateTimeOfRecord));
    });

    // Test fromJson
    test('fromJson creates a new instance from json', () {
      final Map<String, Object> json = <String, Object>{
        MedicalDiagnosisTabModelEnum.id.name: 'newId',
        MedicalDiagnosisTabModelEnum.condition.name: 'newCondition',
        MedicalDiagnosisTabModelEnum.observation.name: 'newObservation',
        MedicalDiagnosisTabModelEnum.quantity.name: 1.0,
        MedicalDiagnosisTabModelEnum.dateTimeOfRecord.name:
            DateUtils.dateTimeToString(DateTime(2025, 07, 21)),
      };

      final MedicalDiagnosisTabModel fromJsonDiagnosis =
          MedicalDiagnosisTabModel.fromJson(json);
      expect(fromJsonDiagnosis, isA<MedicalDiagnosisTabModel>());
      expect(fromJsonDiagnosis.id, 'newId');
      expect(fromJsonDiagnosis.condition, 'newCondition');
      expect(fromJsonDiagnosis.observation, 'newObservation');
      expect(fromJsonDiagnosis.quantity, 1.0);
      expect(fromJsonDiagnosis.dateTimeOfRecord, DateTime(2025, 07, 21));
    });

    // Test hashCode
    test('hashCode is consistent for the same values', () {
      final MedicalDiagnosisTabModel diagnosis1 = defaultMMedicalDiagnosisModel;
      final MedicalDiagnosisTabModel diagnosis2 = defaultMMedicalDiagnosisModel;

      expect(diagnosis1.hashCode, diagnosis2.hashCode);
    });

    // Test equality operator
    test('equality operator works correctly', () {
      final MedicalDiagnosisTabModel diagnosis1 = defaultMMedicalDiagnosisModel;
      final MedicalDiagnosisTabModel diagnosis2 = defaultMMedicalDiagnosisModel;

      expect(diagnosis1, equals(diagnosis2));
    });

    // Add any additional tests here to cover edge cases or other methods
  });
}
