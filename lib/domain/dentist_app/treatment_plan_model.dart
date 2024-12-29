part of '../../jocaagura_domain.dart';

/// Enum representing the fields of the [TreatmentPlanModel].
///
/// Each value corresponds to a specific property of the [TreatmentPlanModel].
enum TreatmentPlanEnum {
  /// Unique identifier for the treatment plan.
  id,

  /// A map of medical treatments included in the treatment plan.
  medicalTreatments,
}

/// Default instance of [TreatmentPlanModel] used as a placeholder or for testing.
///
/// Provides predefined values for all fields.
TreatmentPlanModel defaultTreatmentPlanModel = TreatmentPlanModel(
  id: 'dtpm',
  medicalTreatments: <String, MedicalTreatmentModel>{
    'oxo': defaultMedicalTreatmentModel,
  },
);

/// Represents a comprehensive treatment plan within a healthcare management application.
///
/// This model class encapsulates a treatment plan which includes multiple medical treatments
/// each mapped by a unique key. It allows for detailed tracking and management of a patient's
/// treatment procedures over time.
///
/// Example of using [TreatmentPlanModel] in a practical application:
///
/// ```dart
/// void main() {
///   var treatment1 = MedicalTreatmentModel(
///     id: '001',
///     concept: 'Antibiotic',
///     dateTimeOfRecord: DateTime.now(),
///     quantity: 2,
///   );
///
///   var treatment2 = MedicalTreatmentModel(
///     id: '002',
///     concept: 'Painkiller',
///     dateTimeOfRecord: DateTime.now().add(Duration(days: 1)),
///     quantity: 1,
///   );
///
///   var treatmentPlan = TreatmentPlanModel(
///     id: 'TP1',
///     medicalTreatments: {
///       'treatment1': treatment1,
///       'treatment2': treatment2,
///     },
///   );
///
///   print('Treatment Plan ID: ${treatmentPlan.id}');
///   treatmentPlan.medicalTreatments.forEach((key, treatment) {
///     print('Treatment ID: ${treatment.id}, Concept: ${treatment.concept}');
///   });
/// }
/// ```
///
/// This class supports creating, managing, and serializing treatment plans, which can include
/// any number of individual treatments.
class TreatmentPlanModel extends Model {
  /// Constructs a new [TreatmentPlanModel] with the given [id] and a map of [medicalTreatments].
  ///
  /// Each treatment is identified by a unique key.
  const TreatmentPlanModel({
    required this.id,
    required this.medicalTreatments,
  });

  /// Deserializes a JSON map into an instance of [TreatmentPlanModel].
  ///
  /// The JSON map must contain keys for 'id' and 'medicalTreatments' with a nested map of treatments.
  factory TreatmentPlanModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> tmp =
        Utils.mapFromDynamic(json[TreatmentPlanEnum.medicalTreatments.name]);
    final Map<String, MedicalTreatmentModel> medicalTreatments =
        <String, MedicalTreatmentModel>{};
    tmp.forEach((String key, dynamic value) {
      medicalTreatments[key] = MedicalTreatmentModel.fromJson(
        Utils.mapFromDynamic(value),
      );
    });
    return TreatmentPlanModel(
      id: Utils.getStringFromDynamic(json[TreatmentPlanEnum.id.name]),
      medicalTreatments: medicalTreatments,
    );
  }

  /// A unique identifier for the treatment plan.
  final String id;

  /// A map of medical treatments included in the treatment plan, keyed by a unique identifier.
  final Map<String, MedicalTreatmentModel> medicalTreatments;

  /// Creates a copy of this [TreatmentPlanModel] with optional new values.
  @override
  TreatmentPlanModel copyWith({
    String? id,
    Map<String, MedicalTreatmentModel>? medicalTreatments,
  }) {
    return TreatmentPlanModel(
      id: id ?? this.id,
      medicalTreatments: medicalTreatments ?? this.medicalTreatments,
    );
  }

  /// Serializes this [TreatmentPlanModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> tmp = <String, dynamic>{};
    medicalTreatments.forEach((String key, MedicalTreatmentModel value) {
      tmp[key] = value.toJson();
    });

    return <String, dynamic>{
      TreatmentPlanEnum.id.name: id,
      TreatmentPlanEnum.medicalTreatments.name: tmp,
    };
  }

  /// Determines if two [TreatmentPlanModel] instances are equal.
  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
        other is TreatmentPlanModel &&
            other.runtimeType == runtimeType &&
            other.id == id &&
            other.medicalTreatments == medicalTreatments;
  }

  /// Returns the hash code for this [TreatmentPlanModel].
  @override
  int get hashCode => Object.hash(
        id,
        Object.hashAll(medicalTreatments.values),
      );
}
