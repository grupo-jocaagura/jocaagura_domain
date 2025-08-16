part of '../../jocaagura_domain.dart';

/// Enum representing the fields of the [DiagnosisModel].
///
/// Each value corresponds to a specific property of the [DiagnosisModel].
enum DiagnosisModelEnum {
  /// Unique identifier for the diagnosis.
  id,

  /// Title or name of the diagnosis.
  title,

  /// Detailed description of the diagnosis.
  description,
}

/// Default instance of [DiagnosisModel] used as a placeholder or for testing.
///
/// Provides predefined values for all fields.
const DiagnosisModel defaultDiagnosisModel = DiagnosisModel(
  id: 'xox',
  title: 'diagnostico',
  description: 'Descripcion del diagnostico',
);

/// Represents a medical diagnosis within an application that manages
/// healthcare records.
///
/// This model class encapsulates a diagnosis, storing the unique identifier,
/// the [title] of the diagnosis, and a more detailed [description]. It is suitable
/// for use in healthcare applications where detailed records of diagnoses are necessary.
///
/// Example of using [DiagnosisModel] in a practical application:
///
/// ```dart
/// void main() {
///   var diagnosis = DiagnosisModel(
///     id: '001',
///     title: 'Type 2 Diabetes',
///     description: 'A chronic condition that affects the way the body processes blood sugar (glucose).',
///   );
///
///   print('Diagnosis ID: ${diagnosis.id}');
///   print('Title: ${diagnosis.title}');
///   print('Description: ${diagnosis.description}');
/// }
/// ```
class DiagnosisModel extends Model {
  /// Constructs a new [DiagnosisModel] with the given [id], [title], and [description].
  const DiagnosisModel({
    required this.id,
    required this.title,
    required this.description,
  });

  /// Deserializes a JSON map into an instance of [DiagnosisModel].
  ///
  /// The JSON map must contain keys for 'id', 'title', and 'description' with appropriate values.
  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: Utils.getStringFromDynamic(json[DiagnosisModelEnum.id.name]),
      title: Utils.getStringFromDynamic(json[DiagnosisModelEnum.title.name]),
      description: Utils.getStringFromDynamic(
        json[DiagnosisModelEnum.description.name],
      ),
    );
  }

  /// A unique identifier for the diagnosis.
  final String id;

  /// The title or name of the medical condition diagnosed.
  final String title;

  /// A detailed description of the diagnosis.
  final String description;

  /// Creates a copy of this [DiagnosisModel] with optional modifications.
  ///
  /// Useful for creating a modified diagnosis while preserving immutability.
  @override
  DiagnosisModel copyWith({
    String? id,
    String? title,
    String? description,
  }) {
    return DiagnosisModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  /// Converts this [DiagnosisModel] into a JSON map.
  ///
  /// Useful for serializing the [DiagnosisModel] to JSON, for example when storing
  /// the model in a database or sending it over a network.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      DiagnosisModelEnum.id.name: id,
      DiagnosisModelEnum.title.name: title,
      DiagnosisModelEnum.description.name: description,
    };
  }

  /// Determines if two [DiagnosisModel] instances are equal.
  ///
  /// Returns true if the [other] object is an instance of [DiagnosisModel]
  /// and all fields are equal.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DiagnosisModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            description == other.description;
  }

  /// Returns the hash code for this [DiagnosisModel].
  ///
  /// The hash code is based on all of the fields of the model.
  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
      );
}
