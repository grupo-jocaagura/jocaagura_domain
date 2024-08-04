import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('TreatmentPlanModel Tests', () {
    // Define test data
    const String id = 'dtpm';
    final Map<String, MedicalTreatmentModel> medicalTreatments =
        <String, MedicalTreatmentModel>{
      'oxo': defaultMedicalTreatmentModel,
    };

    // Test the default model
    test('default model is correct', () {
      expect(defaultTreatmentPlanModel, isA<TreatmentPlanModel>());
      expect(defaultTreatmentPlanModel.id, id);
      expect(defaultTreatmentPlanModel.medicalTreatments, medicalTreatments);
    });

    // Test the constructor
    test('constructor sets values properly', () {
      final TreatmentPlanModel treatmentPlan = TreatmentPlanModel(
        id: id,
        medicalTreatments: medicalTreatments,
      );

      expect(treatmentPlan.id, id);
      expect(treatmentPlan.medicalTreatments, medicalTreatments);
    });

    // Test copyWith
    test('copyWith updates values', () {
      final TreatmentPlanModel updatedPlan = defaultTreatmentPlanModel.copyWith(
        id: 'new_id',
        medicalTreatments: <String, MedicalTreatmentModel>{
          'new_oxo': defaultMedicalTreatmentModel.copyWith(id: 'new_oxo'),
        },
      );

      expect(updatedPlan.id, 'new_id');
      expect(updatedPlan.medicalTreatments, <String, MedicalTreatmentModel>{
        'new_oxo': defaultMedicalTreatmentModel.copyWith(id: 'new_oxo'),
      });
    });

    test('copyWith without arguments returns the same object', () {
      final TreatmentPlanModel copiedPlan =
          defaultTreatmentPlanModel.copyWith();
      expect(copiedPlan, equals(defaultTreatmentPlanModel));
      expect(copiedPlan.hashCode, equals(defaultTreatmentPlanModel.hashCode));
    });

    // Test toJson
    test('toJson returns correct map', () {
      final TreatmentPlanModel treatmentPlan = defaultTreatmentPlanModel;
      final Map<String, dynamic> json = treatmentPlan.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json[TreatmentPlanEnum.id.name], id);
      expect(
        json[TreatmentPlanEnum.medicalTreatments.name],
        isA<Map<String, dynamic>>(),
      );
    });

    // Test fromJson
    test('fromJson creates a new instance from json', () {
      final Map<String, Object> json = <String, Object>{
        TreatmentPlanEnum.id.name: 'new_id',
        TreatmentPlanEnum.medicalTreatments.name:
            <String, Map<String, dynamic>>{
          'new_oxo': defaultMedicalTreatmentModel.toJson(),
        },
      };

      final TreatmentPlanModel fromJsonPlan = TreatmentPlanModel.fromJson(json);
      expect(fromJsonPlan, isA<TreatmentPlanModel>());
      expect(fromJsonPlan.id, 'new_id');
    });

    // Test hashCode
    test('hashCode is consistent for the same values', () {
      final TreatmentPlanModel plan1 = defaultTreatmentPlanModel;
      final TreatmentPlanModel plan2 = defaultTreatmentPlanModel;

      expect(plan1.hashCode, plan2.hashCode);
    });

    test('equality operator works correctly', () {
      final TreatmentPlanModel plan1 = defaultTreatmentPlanModel;
      final TreatmentPlanModel plan2 = defaultTreatmentPlanModel;

      expect(plan1, equals(plan2));
    });
  });
}
