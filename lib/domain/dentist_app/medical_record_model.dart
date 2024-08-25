part of '../../jocaagura_domain.dart';

enum MedicalRecordEnum {
  id,
  patient,
  diagnoses,
  dentalConditions,
  treatmentPlan,
  acceptanceClause,
  address,
  legalId,
  user,
  appointments,
  medications,
  contacts,
}

final MedicalRecordModel defaultMedicalRecordModel = MedicalRecordModel(
  id: 'default',
  patient: defaultPersonModel,
  diagnoses: const <DiagnosisModel>[defaultDiagnosisModel],
  dentalConditions: <DentalConditionModel>[dentalConditionModelDefault],
  treatmentPlan: defaultTreatmentPlanModel,
  acceptanceClause: defaultAcceptanceClauseModel,
  address: defaultAddressModel,
  legalId: defaultLegalIdModel,
  user: defaultUserModel,
  appointments: <AppointmentModel>[defaultAppointmentModel],
  medications: <MedicationModel>[defaultMedicationModel],
  contacts: const <ContactModel>[defaultContactModel],
);

/// Represents a comprehensive medical record for a patient in a healthcare management system.
///
/// The [MedicalRecordModel] class is used to store and manage a patient's medical data,
/// including diagnoses, dental conditions, treatment plans, acceptance clauses, and other relevant information.
///
/// This model is crucial for maintaining a complete and organized record of a patient's medical history,
/// which can be accessed and updated by healthcare providers.
///
/// Example of using [MedicalRecordModel] in a practical application:
///
/// ```dart
/// void main() {
///   var medicalRecord = MedicalRecordModel(
///     id: 'record001',
///     patient: defaultPersonModel,
///     diagnoses: [defaultDiagnosisModel],
///     dentalConditions: [dentalConditionModelDefault],
///     treatmentPlan: defaultTreatmentPlanModel,
///     acceptanceClause: defaultAcceptanceClauseModel,
///     address: defaultAddressModel,
///     legalId: defaultLegalIdModel,
///     user: defaultUserModel,
///     appointments: [defaultAppointmentModel],
///     medications: [defaultMedicationModel],
///     contacts: [defaultContactModel],
///   );
///
///   print('Medical Record ID: ${medicalRecord.id}');
///   print('Patient: ${medicalRecord.patient}');
///   print('Diagnoses: ${medicalRecord.diagnoses}');
///   print('Medications: ${medicalRecord.medications}');
/// }
/// ```
///
/// This class is used to create a unified record that contains all pertinent information about a patient,
/// ensuring that their medical history is accurately tracked and easily accessible across different healthcare contexts.

class MedicalRecordModel extends Model {
  /// Constructs a new [MedicalRecordModel] with the given details.
  const MedicalRecordModel({
    required this.id,
    required this.patient,
    required this.diagnoses,
    required this.dentalConditions,
    required this.treatmentPlan,
    required this.acceptanceClause,
    required this.address,
    required this.legalId,
    required this.user,
    required this.appointments,
    required this.medications,
    required this.contacts,
  });

  /// Deserializes a JSON map into an instance of [MedicalRecordModel].
  ///
  /// The JSON map must contain all the keys corresponding to the fields in this class.
  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: Utils.getStringFromDynamic(json[MedicalRecordEnum.id.name]),
      patient: PersonModel.fromJson(
        Utils.mapFromDynamic(json[MedicalRecordEnum.patient.name]),
      ),
      diagnoses: Utils.listFromDynamic(json[MedicalRecordEnum.diagnoses.name])
          .map((Map<String, dynamic> e) => DiagnosisModel.fromJson(e))
          .toList(),
      dentalConditions: Utils.listFromDynamic(
        json[MedicalRecordEnum.dentalConditions.name],
      )
          .map((Map<String, dynamic> e) => DentalConditionModel.fromJson(e))
          .toList(),
      treatmentPlan: TreatmentPlanModel.fromJson(
        Utils.mapFromDynamic(json[MedicalRecordEnum.treatmentPlan.name]),
      ),
      acceptanceClause: AcceptanceClauseModel.fromJson(
        Utils.mapFromDynamic(json[MedicalRecordEnum.acceptanceClause.name]),
      ),
      address: AddressModel.fromJson(
        Utils.mapFromDynamic(json[MedicalRecordEnum.address.name]),
      ),
      legalId: LegalIdModel.fromJson(
        Utils.mapFromDynamic(json[MedicalRecordEnum.legalId.name]),
      ),
      user: UserModel.fromJson(
        Utils.mapFromDynamic(json[MedicalRecordEnum.user.name]),
      ),
      appointments:
          Utils.listFromDynamic(json[MedicalRecordEnum.appointments.name])
              .map((Map<String, dynamic> e) => AppointmentModel.fromJson(e))
              .toList(),
      medications:
          Utils.listFromDynamic(json[MedicalRecordEnum.medications.name])
              .map((Map<String, dynamic> e) => MedicationModel.fromJson(e))
              .toList(),
      contacts: Utils.listFromDynamic(json[MedicalRecordEnum.contacts.name])
          .map((Map<String, dynamic> e) => ContactModel.fromJson(e))
          .toList(),
    );
  }

  /// A unique identifier for the medical record.
  final String id;

  /// The patient's personal details.
  final PersonModel patient;

  /// The treatment plan prescribed for the patient.
  final TreatmentPlanModel treatmentPlan;

  /// The acceptance clause, including signatures and other consent information.
  final AcceptanceClauseModel acceptanceClause;

  /// The patient's address.
  final AddressModel address;

  /// The patient's legal identification.
  final LegalIdModel legalId;

  /// The user associated with this medical record.
  final UserModel user;

  /// A list of medical diagnoses for the patient.
  final List<DiagnosisModel> diagnoses;

  /// A list of dental conditions for the patient.
  final List<DentalConditionModel> dentalConditions;

  /// A list of appointments scheduled for the patient.
  final List<AppointmentModel> appointments;

  /// A list of medications prescribed to the patient.
  final List<MedicationModel> medications;

  /// A list of emergency contacts for the patient.
  final List<ContactModel> contacts;

  /// Creates a copy of this [MedicalRecordModel] with optional new values.
  @override
  MedicalRecordModel copyWith({
    String? id,
    PersonModel? patient,
    List<DiagnosisModel>? diagnoses,
    List<DentalConditionModel>? dentalConditions,
    TreatmentPlanModel? treatmentPlan,
    AcceptanceClauseModel? acceptanceClause,
    AddressModel? address,
    LegalIdModel? legalId,
    UserModel? user,
    List<AppointmentModel>? appointments,
    List<MedicationModel>? medications,
    List<ContactModel>? contacts,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      diagnoses: diagnoses ?? this.diagnoses,
      dentalConditions: dentalConditions ?? this.dentalConditions,
      treatmentPlan: treatmentPlan ?? this.treatmentPlan,
      acceptanceClause: acceptanceClause ?? this.acceptanceClause,
      address: address ?? this.address,
      legalId: legalId ?? this.legalId,
      user: user ?? this.user,
      appointments: appointments ?? this.appointments,
      medications: medications ?? this.medications,
      contacts: contacts ?? this.contacts,
    );
  }

  /// Serializes this [MedicalRecordModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      MedicalRecordEnum.id.name: id,
      MedicalRecordEnum.patient.name: patient.toJson(),
      MedicalRecordEnum.treatmentPlan.name: treatmentPlan.toJson(),
      MedicalRecordEnum.acceptanceClause.name: acceptanceClause.toJson(),
      MedicalRecordEnum.address.name: address.toJson(),
      MedicalRecordEnum.legalId.name: legalId.toJson(),
      MedicalRecordEnum.user.name: user.toJson(),
      MedicalRecordEnum.diagnoses.name:
          diagnoses.map((DiagnosisModel e) => e.toJson()).toList(),
      MedicalRecordEnum.dentalConditions.name:
          dentalConditions.map((DentalConditionModel e) => e.toJson()).toList(),
      MedicalRecordEnum.appointments.name:
          appointments.map((AppointmentModel e) => e.toJson()).toList(),
      MedicalRecordEnum.medications.name:
          medications.map((MedicationModel e) => e.toJson()).toList(),
      MedicalRecordEnum.contacts.name:
          contacts.map((ContactModel e) => e.toJson()).toList(),
    };
  }

  /// Compares this [MedicalRecordModel] to another object.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MedicalRecordModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            patient == other.patient &&
            diagnoses == other.diagnoses &&
            dentalConditions == other.dentalConditions &&
            treatmentPlan == other.treatmentPlan &&
            acceptanceClause == other.acceptanceClause &&
            address == other.address &&
            legalId == other.legalId &&
            user == other.user &&
            appointments == other.appointments &&
            medications == other.medications &&
            contacts == other.contacts;
  }

  /// Returns the hash code for this [MedicalRecordModel].
  @override
  int get hashCode => Object.hash(
        id,
        patient,
        Object.hashAll(diagnoses),
        Object.hashAll(dentalConditions),
        treatmentPlan,
        acceptanceClause,
        address,
        legalId,
        user,
        Object.hashAll(appointments),
        Object.hashAll(medications),
        Object.hashAll(contacts),
      );
}
