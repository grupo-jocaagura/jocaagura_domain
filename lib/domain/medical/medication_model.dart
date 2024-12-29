part of '../../jocaagura_domain.dart';

/// Enum representing the fields of the [MedicationModel].
///
/// Each value corresponds to a specific property of the [MedicationModel].
enum MedicationEnum {
  /// Unique identifier for the medication.
  id,

  /// Name of the medication.
  name,

  /// Dosage of the medication.
  dosage,

  /// Frequency of administration.
  frequency,

  /// Start date of the medication prescription.
  startDate,

  /// End date of the medication prescription.
  endDate,
}

/// Default instance of [MedicationModel] used for testing or as a placeholder.
///
/// Provides predefined values for all fields.
final MedicationModel defaultMedicationModel = MedicationModel(
  id: 'med001',
  name: 'Ibuprofeno',
  dosage: '200mg',
  frequency: 'Cada 8 horas',
  startDate: DateTime(2024, 07, 20),
  endDate: DateTime(2024, 07, 25),
);

/// Represents a medication prescribed to a patient within a healthcare management application.
///
/// This model class encapsulates the details of a medication, including:
/// - [id]: A unique identifier for the medication.
/// - [name]: The name of the medication.
/// - [dosage]: The dosage of the medication (e.g., "200mg").
/// - [frequency]: The frequency of administration (e.g., "Every 8 hours").
/// - [startDate]: The start date of the medication prescription.
/// - [endDate]: The end date of the medication prescription.
///
/// Example of using [MedicationModel] in a practical application:
///
/// ```dart
/// void main() {
///   var medication = MedicationModel(
///     id: 'med001',
///     name: 'Ibuprofen',
///     dosage: '200mg',
///     frequency: 'Every 8 hours',
///     startDate: DateTime(2024, 08, 01),
///     endDate: DateTime(2024, 08, 10),
///   );
///
///   print('Medication ID: ${medication.id}');
///   print('Name: ${medication.name}');
///   print('Dosage: ${medication.dosage}');
///   print('Frequency: ${medication.frequency}');
///   print('Start Date: ${medication.startDate}');
///   print('End Date: ${medication.endDate}');
/// }
/// ```
class MedicationModel extends Model {
  /// Constructs a new [MedicationModel] with the given details.
  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    required this.endDate,
  });

  /// Deserializes a JSON map into an instance of [MedicationModel].
  ///
  /// The JSON map must contain keys for 'id', 'name', 'dosage', 'frequency',
  /// 'startDate', and 'endDate' with appropriate values.
  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: Utils.getStringFromDynamic(json[MedicationEnum.id.name]),
      name: Utils.getStringFromDynamic(json[MedicationEnum.name.name]),
      dosage: Utils.getStringFromDynamic(json[MedicationEnum.dosage.name]),
      frequency:
          Utils.getStringFromDynamic(json[MedicationEnum.frequency.name]),
      startDate:
          DateUtils.dateTimeFromDynamic(json[MedicationEnum.startDate.name]),
      endDate: DateUtils.dateTimeFromDynamic(json[MedicationEnum.endDate.name]),
    );
  }

  /// A unique identifier for the medication.
  final String id;

  /// The name of the medication.
  final String name;

  /// The dosage of the medication (e.g., "200mg").
  final String dosage;

  /// The frequency of administration (e.g., "Every 8 hours").
  final String frequency;

  /// The start date of the medication prescription.
  final DateTime startDate;

  /// The end date of the medication prescription.
  final DateTime endDate;

  /// Creates a copy of this [MedicationModel] with optional new values.
  ///
  /// This method supports immutability while allowing modifications to the model.
  @override
  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Serializes this [MedicationModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      MedicationEnum.id.name: id,
      MedicationEnum.name.name: name,
      MedicationEnum.dosage.name: dosage,
      MedicationEnum.frequency.name: frequency,
      MedicationEnum.startDate.name: DateUtils.dateTimeToString(startDate),
      MedicationEnum.endDate.name: DateUtils.dateTimeToString(endDate),
    };
  }

  /// Determines if two [MedicationModel] instances are equal.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MedicationModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            name == other.name &&
            dosage == other.dosage &&
            frequency == other.frequency &&
            startDate == other.startDate &&
            endDate == other.endDate;
  }

  /// Returns the hash code for this [MedicationModel].
  @override
  int get hashCode =>
      Object.hash(id, name, dosage, frequency, startDate, endDate);
}
