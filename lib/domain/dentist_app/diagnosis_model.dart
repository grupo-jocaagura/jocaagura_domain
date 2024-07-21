part of '../../jocaagura_domain.dart';

enum DiagnosisModelEnum {
  id,
  title,
  description,
}

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
/// ```.

class DiagnosisModel implements Model {
  const DiagnosisModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: Utils.getStringFromDynamic(json[DiagnosisModelEnum.id.name]),
      title: Utils.getStringFromDynamic(json[DiagnosisModelEnum.title.name]),
      description: Utils.getStringFromDynamic(
        json[DiagnosisModelEnum.description.name],
      ),
    );
  }

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
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      DiagnosisModelEnum.id.name: id,
      DiagnosisModelEnum.title.name: title,
      DiagnosisModelEnum.description.name: description,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DiagnosisModel &&
            other.hashCode == hashCode &&
            runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
      );
}
