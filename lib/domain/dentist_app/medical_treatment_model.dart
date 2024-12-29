part of '../../jocaagura_domain.dart';

/// Enum representing the fields of the [MedicalTreatmentModel].
///
/// Each value corresponds to a specific property of the [MedicalTreatmentModel].
enum MedicalTreatmentEnum {
  /// Unique identifier for the treatment record.
  id,

  /// The concept or description of the treatment administered.
  concept,

  /// The date and time when the treatment was recorded.
  dateTimeOfRecord,

  /// The quantity of the treatment administered.
  quantity,
}

/// Default instance of [MedicalTreatmentModel] used as a placeholder or for testing.
///
/// Provides predefined values for all fields.
final MedicalTreatmentModel defaultMedicalTreatmentModel =
    MedicalTreatmentModel(
  id: 'default_id',
  concept: 'Tratamiento de ejemplo',
  dateTimeOfRecord: DateTime(2024, 7, 28),
  quantity: 1,
);

/// Represents a medical treatment record within an application that manages
/// healthcare data.
///
/// This model class encapsulates information about a specific treatment given to a patient,
/// including the treatment concept, the quantity administered, and the date and time of administration.
///
/// Example of using [MedicalTreatmentModel] in a practical application:
///
/// ```dart
/// void main() {
///   var treatment = MedicalTreatmentModel(
///     id: '001',
///     concept: 'Antibiotic Administration',
///     dateTimeOfRecord: DateTime.now(),
///     quantity: 2,
///   );
///
///   print('Treatment ID: ${treatment.id}');
///   print('Concept: ${treatment.concept}');
///   print('Administered on: ${treatment.dateTimeOfRecord}');
///   print('Quantity: ${treatment.quantity}');
/// }
/// ```
///
/// This class is essential for tracking the administration of various treatments within
/// healthcare settings, ensuring accurate record-keeping and easy retrieval of treatment details.
class MedicalTreatmentModel extends Model {
  /// Constructs a new instance with the provided [id], [concept], [dateTimeOfRecord],
  /// and [quantity].
  ///
  /// These parameters are essential for describing a medical treatment comprehensively.
  const MedicalTreatmentModel({
    required this.id,
    required this.concept,
    required this.dateTimeOfRecord,
    required this.quantity,
  });

  /// Deserializes a JSON map into an instance of [MedicalTreatmentModel].
  ///
  /// The JSON map must contain keys for 'id', 'concept', 'dateTimeOfRecord',
  /// and 'quantity' with appropriate values.
  factory MedicalTreatmentModel.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentModel(
      id: Utils.getStringFromDynamic(json[MedicalTreatmentEnum.id.name]),
      concept:
          Utils.getStringFromDynamic(json[MedicalTreatmentEnum.concept.name]),
      dateTimeOfRecord: DateUtils.dateTimeFromDynamic(
        json[MedicalTreatmentEnum.dateTimeOfRecord.name],
      ),
      quantity:
          Utils.getIntegerFromDynamic(json[MedicalTreatmentEnum.quantity.name]),
    );
  }

  /// The unique identifier for the treatment record.
  final String id;

  /// The concept or description of the treatment administered.
  final String concept;

  /// The date and time when the treatment was recorded.
  final DateTime dateTimeOfRecord;

  /// The quantity of the treatment administered.
  final int quantity;

  /// Creates a copy of this [MedicalTreatmentModel] with optional new values.
  ///
  /// This method allows for modifications of the treatment record while preserving immutability.
  @override
  MedicalTreatmentModel copyWith({
    String? id,
    String? concept,
    DateTime? dateTimeOfRecord,
    int? quantity,
  }) {
    return MedicalTreatmentModel(
      id: id ?? this.id,
      concept: concept ?? this.concept,
      dateTimeOfRecord: dateTimeOfRecord ?? this.dateTimeOfRecord,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Converts this [MedicalTreatmentModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      MedicalTreatmentEnum.id.name: id,
      MedicalTreatmentEnum.concept.name: concept,
      MedicalTreatmentEnum.dateTimeOfRecord.name:
          DateUtils.dateTimeToString(dateTimeOfRecord),
      MedicalTreatmentEnum.quantity.name: quantity,
    };
  }

  /// Determines if two [MedicalTreatmentModel] instances are equal.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MedicalTreatmentModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            concept == other.concept &&
            dateTimeOfRecord == other.dateTimeOfRecord &&
            quantity == other.quantity;
  }

  /// Returns the hash code for this [MedicalTreatmentModel].
  ///
  /// The hash code is based on all of the fields of the model.
  @override
  int get hashCode => Object.hash(
        id,
        concept,
        dateTimeOfRecord,
        quantity,
      );
}
