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
  final String title;
  final String description;

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
