import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('MedicalTreatmentModel Tests', () {
    const String id = 'default_id';
    const String concept = 'Tratamiento de ejemplo';
    final DateTime dateTimeOfRecord = DateTime(2024, 7, 28);
    const int quantity = 1;

    test('default model is correct', () {
      expect(defaultMedicalTreatmentModel, isA<MedicalTreatmentModel>());
      expect(defaultMedicalTreatmentModel.id, id);
      expect(defaultMedicalTreatmentModel.concept, concept);
      expect(defaultMedicalTreatmentModel.dateTimeOfRecord, dateTimeOfRecord);
      expect(defaultMedicalTreatmentModel.quantity, quantity);
    });

    test('constructor sets values properly', () {
      final MedicalTreatmentModel treatment = MedicalTreatmentModel(
        id: id,
        concept: concept,
        dateTimeOfRecord: dateTimeOfRecord,
        quantity: quantity,
      );

      expect(treatment.id, id);
      expect(treatment.concept, concept);
      expect(treatment.dateTimeOfRecord, dateTimeOfRecord);
      expect(treatment.quantity, quantity);
    });

    test('copyWith updates values', () {
      final MedicalTreatmentModel updatedTreatment =
          defaultMedicalTreatmentModel.copyWith(
        id: 'new_id',
        concept: 'Nuevo Tratamiento',
        dateTimeOfRecord: DateTime(2025, 7, 28),
        quantity: 2,
      );

      expect(updatedTreatment.id, 'new_id');
      expect(updatedTreatment.concept, 'Nuevo Tratamiento');
      expect(updatedTreatment.dateTimeOfRecord, DateTime(2025, 7, 28));
      expect(updatedTreatment.quantity, 2);
    });

    test('copyWith without arguments returns the same object', () {
      final MedicalTreatmentModel copiedTreatment =
          defaultMedicalTreatmentModel.copyWith();
      expect(copiedTreatment, equals(defaultMedicalTreatmentModel));
      expect(
        copiedTreatment.hashCode,
        equals(defaultMedicalTreatmentModel.hashCode),
      );
    });

    test('toJson returns correct map', () {
      final MedicalTreatmentModel treatment = defaultMedicalTreatmentModel;
      final Map<String, dynamic> json = treatment.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json[MedicalTreatmentEnum.id.name], id);
      expect(json[MedicalTreatmentEnum.concept.name], concept);
      expect(
        json[MedicalTreatmentEnum.dateTimeOfRecord.name],
        DateUtils.dateTimeToString(dateTimeOfRecord),
      );
      expect(json[MedicalTreatmentEnum.quantity.name], quantity);
    });

    test('fromJson creates a new instance from json', () {
      final Map<String, Object> json = <String, Object>{
        MedicalTreatmentEnum.id.name: 'new_id',
        MedicalTreatmentEnum.concept.name: 'Nuevo Tratamiento',
        MedicalTreatmentEnum.dateTimeOfRecord.name:
            DateUtils.dateTimeToString(DateTime(2025, 7, 28)),
        MedicalTreatmentEnum.quantity.name: 2,
      };

      final MedicalTreatmentModel fromJsonTreatment =
          MedicalTreatmentModel.fromJson(json);
      expect(fromJsonTreatment, isA<MedicalTreatmentModel>());
      expect(fromJsonTreatment.id, 'new_id');
      expect(fromJsonTreatment.concept, 'Nuevo Tratamiento');
      expect(fromJsonTreatment.dateTimeOfRecord, DateTime(2025, 7, 28));
      expect(fromJsonTreatment.quantity, 2);
    });

    test('hashCode is consistent for the same values', () {
      final MedicalTreatmentModel treatment1 = defaultMedicalTreatmentModel;
      final MedicalTreatmentModel treatment2 = defaultMedicalTreatmentModel;

      expect(treatment1.hashCode, treatment2.hashCode);
    });

    test('equality operator works correctly', () {
      final MedicalTreatmentModel treatment1 = defaultMedicalTreatmentModel;
      final MedicalTreatmentModel treatment2 = defaultMedicalTreatmentModel;

      expect(treatment1, equals(treatment2));
    });
  });
}
