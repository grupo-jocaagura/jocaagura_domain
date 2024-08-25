import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('MedicalRecordModel Tests', () {
    // Define test data
    const String id = 'default';
    const PersonModel patient = defaultPersonModel;
    final List<DiagnosisModel> diagnoses = <DiagnosisModel>[
      defaultDiagnosisModel,
    ];
    final List<DentalConditionModel> dentalConditions = <DentalConditionModel>[
      dentalConditionModelDefault,
    ];
    final TreatmentPlanModel treatmentPlan = defaultTreatmentPlanModel;
    final AcceptanceClauseModel acceptanceClause = defaultAcceptanceClauseModel;
    const AddressModel address = defaultAddressModel;
    const LegalIdModel legalId = defaultLegalIdModel;
    const UserModel user = defaultUserModel;
    final List<AppointmentModel> appointments = <AppointmentModel>[
      defaultAppointmentModel,
    ];
    final List<MedicationModel> medications = <MedicationModel>[
      defaultMedicationModel,
    ];
    final List<ContactModel> contacts = <ContactModel>[defaultContactModel];

    // Test the default model
    test('default model is correct', () {
      expect(defaultMedicalRecordModel, isA<MedicalRecordModel>());
      expect(defaultMedicalRecordModel.id, id);
      expect(defaultMedicalRecordModel.patient, patient);
      expect(defaultMedicalRecordModel.diagnoses, diagnoses);
      expect(defaultMedicalRecordModel.dentalConditions, dentalConditions);
      expect(defaultMedicalRecordModel.treatmentPlan, treatmentPlan);
      expect(defaultMedicalRecordModel.acceptanceClause, acceptanceClause);
      expect(defaultMedicalRecordModel.address, address);
      expect(defaultMedicalRecordModel.legalId, legalId);
      expect(defaultMedicalRecordModel.user, user);
      expect(defaultMedicalRecordModel.appointments, appointments);
      expect(defaultMedicalRecordModel.medications, medications);
      expect(defaultMedicalRecordModel.contacts, contacts);
    });

    // Test the constructor
    test('constructor sets values properly', () {
      final MedicalRecordModel medicalRecord = MedicalRecordModel(
        id: id,
        patient: patient,
        diagnoses: diagnoses,
        dentalConditions: dentalConditions,
        treatmentPlan: treatmentPlan,
        acceptanceClause: acceptanceClause,
        address: address,
        legalId: legalId,
        user: user,
        appointments: appointments,
        medications: medications,
        contacts: contacts,
      );

      expect(medicalRecord.id, id);
      expect(medicalRecord.patient, patient);
      expect(medicalRecord.diagnoses, diagnoses);
      expect(medicalRecord.dentalConditions, dentalConditions);
      expect(medicalRecord.treatmentPlan, treatmentPlan);
      expect(medicalRecord.acceptanceClause, acceptanceClause);
      expect(medicalRecord.address, address);
      expect(medicalRecord.legalId, legalId);
      expect(medicalRecord.user, user);
      expect(medicalRecord.appointments, appointments);
      expect(medicalRecord.medications, medications);
      expect(medicalRecord.contacts, contacts);
    });

    // Test copyWith
    test('copyWith updates values', () {
      final MedicalRecordModel updatedMedicalRecord =
          defaultMedicalRecordModel.copyWith(
        id: 'new_id',
        patient: patient.copyWith(id: 'new_patient'),
        diagnoses: <DiagnosisModel>[
          defaultDiagnosisModel.copyWith(id: 'new_diagnosis'),
        ],
        dentalConditions: <DentalConditionModel>[
          dentalConditionModelDefault.copyWith(id: 'new_dental_condition'),
        ],
        treatmentPlan: treatmentPlan.copyWith(id: 'new_treatment_plan'),
        acceptanceClause:
            acceptanceClause.copyWith(id: 'new_acceptance_clause'),
        address: address.copyWith(id: 'new_address'),
        legalId: legalId.copyWith(id: 'new_legal_id'),
        user: user.copyWith(id: 'new_user'),
        appointments: <AppointmentModel>[
          defaultAppointmentModel.copyWith(id: 'new_appointment'),
        ],
        medications: <MedicationModel>[
          defaultMedicationModel.copyWith(id: 'new_medication'),
        ],
        contacts: <ContactModel>[
          defaultContactModel.copyWith(id: 'new_contact'),
        ],
      );

      expect(updatedMedicalRecord.id, 'new_id');
      expect(updatedMedicalRecord.patient.id, 'new_patient');
      expect(updatedMedicalRecord.diagnoses.first.id, 'new_diagnosis');
      expect(
        updatedMedicalRecord.dentalConditions.first.id,
        'new_dental_condition',
      );
      expect(updatedMedicalRecord.treatmentPlan.id, 'new_treatment_plan');
      expect(updatedMedicalRecord.acceptanceClause.id, 'new_acceptance_clause');
      expect(updatedMedicalRecord.address.id, 'new_address');
      expect(updatedMedicalRecord.legalId.id, 'new_legal_id');
      expect(updatedMedicalRecord.user.id, 'new_user');
      expect(updatedMedicalRecord.appointments.first.id, 'new_appointment');
      expect(updatedMedicalRecord.medications.first.id, 'new_medication');
      expect(updatedMedicalRecord.contacts.first.id, 'new_contact');
    });

    test('copyWith without arguments returns the same object', () {
      final MedicalRecordModel copiedMedicalRecord =
          defaultMedicalRecordModel.copyWith();
      expect(copiedMedicalRecord, equals(defaultMedicalRecordModel));
      expect(
        copiedMedicalRecord.hashCode,
        equals(defaultMedicalRecordModel.hashCode),
      );
    });

    // Test toJson
    test('toJson returns correct map', () {
      final MedicalRecordModel medicalRecord = defaultMedicalRecordModel;
      final Map<String, dynamic> json = medicalRecord.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json[MedicalRecordEnum.id.name], id);
      expect(json[MedicalRecordEnum.patient.name], patient.toJson());
      expect(
        json[MedicalRecordEnum.treatmentPlan.name],
        treatmentPlan.toJson(),
      );
      expect(
        json[MedicalRecordEnum.acceptanceClause.name],
        acceptanceClause.toJson(),
      );
      expect(json[MedicalRecordEnum.address.name], address.toJson());
      expect(json[MedicalRecordEnum.legalId.name], legalId.toJson());
      expect(json[MedicalRecordEnum.user.name], user.toJson());
      expect(
        json[MedicalRecordEnum.diagnoses.name],
        diagnoses.map((DiagnosisModel e) => e.toJson()).toList(),
      );
      expect(
        json[MedicalRecordEnum.dentalConditions.name],
        dentalConditions.map((DentalConditionModel e) => e.toJson()).toList(),
      );
      expect(
        json[MedicalRecordEnum.appointments.name],
        appointments.map((AppointmentModel e) => e.toJson()).toList(),
      );
      expect(
        json[MedicalRecordEnum.medications.name],
        medications.map((MedicationModel e) => e.toJson()).toList(),
      );
      expect(
        json[MedicalRecordEnum.contacts.name],
        contacts.map((ContactModel e) => e.toJson()).toList(),
      );
    });

    // Test fromJson
    test('fromJson creates a new instance from json', () {
      final Map<String, Object> json = <String, Object>{
        MedicalRecordEnum.id.name: 'new_id',
        MedicalRecordEnum.patient.name: patient.toJson(),
        MedicalRecordEnum.diagnoses.name: <Map<String, dynamic>>[
          defaultDiagnosisModel.toJson(),
        ],
        MedicalRecordEnum.dentalConditions.name: <Map<String, dynamic>>[
          dentalConditionModelDefault.toJson(),
        ],
        MedicalRecordEnum.treatmentPlan.name: treatmentPlan.toJson(),
        MedicalRecordEnum.acceptanceClause.name: acceptanceClause.toJson(),
        MedicalRecordEnum.address.name: address.toJson(),
        MedicalRecordEnum.legalId.name: legalId.toJson(),
        MedicalRecordEnum.user.name: user.toJson(),
        MedicalRecordEnum.appointments.name: <Map<String, dynamic>>[
          defaultAppointmentModel.toJson(),
        ],
        MedicalRecordEnum.medications.name: <Map<String, dynamic>>[
          defaultMedicationModel.toJson(),
        ],
        MedicalRecordEnum.contacts.name: <Map<String, dynamic>>[
          defaultContactModel.toJson(),
        ],
      };

      final MedicalRecordModel fromJsonMedicalRecord =
          MedicalRecordModel.fromJson(json);
      expect(fromJsonMedicalRecord, isA<MedicalRecordModel>());
      expect(fromJsonMedicalRecord.id, 'new_id');
      expect(fromJsonMedicalRecord.patient, patient);
      expect(
        fromJsonMedicalRecord.diagnoses.first.id,
        defaultDiagnosisModel.id,
      );
      expect(
        fromJsonMedicalRecord.dentalConditions.first.id,
        dentalConditionModelDefault.id,
      );
      expect(fromJsonMedicalRecord.treatmentPlan.id, treatmentPlan.id);
      expect(fromJsonMedicalRecord.acceptanceClause.id, acceptanceClause.id);
      expect(fromJsonMedicalRecord.address.id, address.id);
      expect(fromJsonMedicalRecord.legalId.id, legalId.id);
      expect(fromJsonMedicalRecord.user.id, user.id);
      expect(
        fromJsonMedicalRecord.appointments.first.id,
        defaultAppointmentModel.id,
      );
      expect(
        fromJsonMedicalRecord.medications.first.id,
        defaultMedicationModel.id,
      );
      expect(fromJsonMedicalRecord.contacts.first.id, defaultContactModel.id);
    });

    // Test hashCode
    test('hashCode is consistent for the same values', () {
      final MedicalRecordModel record1 = defaultMedicalRecordModel;
      final MedicalRecordModel record2 = defaultMedicalRecordModel.copyWith();

      expect(record1.hashCode, record2.hashCode);
    });

    // Test equality operator
    test('equality operator works correctly', () {
      final MedicalRecordModel record1 = defaultMedicalRecordModel;
      final MedicalRecordModel record2 = defaultMedicalRecordModel.copyWith();

      expect(record1, equals(record2));
    });

    // Additional test: inequality operator
    test('inequality operator works correctly', () {
      final MedicalRecordModel record1 = defaultMedicalRecordModel;
      final MedicalRecordModel record2 =
          defaultMedicalRecordModel.copyWith(id: 'new_id');

      expect(record1, isNot(equals(record2)));
    });
  });
}
