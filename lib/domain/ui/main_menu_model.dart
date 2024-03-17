part of '../../jocaagura_domain.dart';

class ModelMainMenuModel extends Model {
  const ModelMainMenuModel({
    required this.iconData,
    required this.onPressed,
    required this.label,
    this.description = '',
  });

  final IconData iconData;
  final void Function() onPressed;
  final String label;
  final String description;

  @override
  ModelMainMenuModel copyWith({
    IconData? iconData,
    void Function()? onPressed,
    String? label,
    String? description,
  }) {
    return ModelMainMenuModel(
        iconData: iconData ?? this.iconData,
        onPressed: onPressed ?? this.onPressed,
        label: label ?? this.label,
        description: description ?? this.description);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelMainMenuModel &&
          runtimeType == other.runtimeType &&
          iconData == other.iconData &&
          label == other.label &&
          description == other.description &&
          hashCode == other.hashCode;

  @override
  int get hashCode => label.toLowerCase().hashCode;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }
}
