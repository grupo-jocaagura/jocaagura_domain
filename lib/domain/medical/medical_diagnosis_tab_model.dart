part of '../../jocaagura_domain.dart';

enum MedicalDiagnosisTabModelEnum {
  id,
  condition,
  quantity,
  observation,
  dateTimeOfRecord,
}

MedicalDiagnosisTabModel defaultMMedicalDiagnosisModel =
    MedicalDiagnosisTabModel(
  id: 'oxo',
  condition: 'sane',
  observation: 'No observation',
  quantity: 0.0,
  dateTimeOfRecord: DateTime(2024, 07, 21),
);

/// Represents a medical diagnosis record in an application that manages
/// patient health data.
///
///
/// Requires an [id] that uniquely identifies the diagnosis record.
/// a [condition] describing the medical condition diagnosed,
/// an [observation] providing additional details about the diagnosis,
/// a [quantity] that could represent severity or any numerical data related
/// to the condition, and the [dateTimeOfRecord] which logs when the diagnosis
/// was made.
///
/// Example of using [MedicalDiagnosisTabModel] in a practical application:
///
/// ```dart
/// void main() {
///   var diagnosis = MedicalDiagnosisTabModel(
///     id: '001',
///     condition: 'Hypertension',
///     observation: 'Patient shows elevated blood pressure.',
///     quantity: 3, // indicating high severity
///     dateTimeOfRecord: DateTime.now(),
///   );
///
///   print(diagnosis);
/// }
/// ```
/// Each instance of this class encapsulates information about a specific
/// diagnosis made by healthcare providers, including details about the
/// condition, any observations made, the quantity (e.g., severity or count),
/// and the date and time the diagnosis was recorded.
/// Constructs a [MedicalDiagnosisTabModel].

class MedicalDiagnosisTabModel extends Model {
  const MedicalDiagnosisTabModel({
    required this.id,
    required this.condition,
    required this.observation,
    required this.quantity,
    required this.dateTimeOfRecord,
  });

  /// Creates a new [MedicalDiagnosisTabModel] from a JSON map.
  ///
  /// This factory constructor is used for deserializing a JSON structure
  /// into an instance of [MedicalDiagnosisTabModel].
  factory MedicalDiagnosisTabModel.fromJson(Map<String, dynamic> json) {
    return MedicalDiagnosisTabModel(
      id: Utils.getStringFromDynamic(json['id']),
      condition: Utils.getStringFromDynamic(json['condition']),
      observation: Utils.getStringFromDynamic(json['observation']),
      quantity: Utils.getDouble(json['quantity']),
      dateTimeOfRecord: DateUtils.dateTimeFromDynamic(json['dateTimeOfRecord']),
    );
  }

  /// A unique identifier for the diagnosis record.
  final String id;

  /// A description of the medical condition diagnosed.
  final String condition;

  /// Additional observations about the diagnosis.
  final String observation;

  /// A quantitative measure of the diagnosis, such as severity or count.
  final double quantity;

  final DateTime dateTimeOfRecord;

  @override
  MedicalDiagnosisTabModel copyWith({
    String? id,
    String? condition,
    String? observation,
    double? quantity,
    DateTime? dateTimeOfRecord,
  }) {
    return MedicalDiagnosisTabModel(
      id: id ?? this.id,
      condition: condition ?? this.condition,
      observation: observation ?? this.observation,
      quantity: quantity ?? this.quantity,
      dateTimeOfRecord: dateTimeOfRecord ?? this.dateTimeOfRecord,
    );
  }

  /// Converts the [MedicalDiagnosisTabModel] to a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'condition': condition,
      'observation': observation,
      'quantity': quantity,
      'dateTimeOfRecord': DateUtils.dateTimeToString(dateTimeOfRecord),
    };
  }

  /// Compares this [MedicalDiagnosisTabModel] to another object.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalDiagnosisTabModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          condition == other.condition &&
          observation == other.observation &&
          quantity == other.quantity &&
          dateTimeOfRecord == other.dateTimeOfRecord;

  /// Returns the hash code for this [MedicalDiagnosisTabModel].
  @override
  int get hashCode => Object.hash(
        id,
        condition,
        observation,
        quantity,
        dateTimeOfRecord,
      );
}
