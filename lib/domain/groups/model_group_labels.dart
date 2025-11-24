part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP LABELS
/// ===========================================================================

enum ModelGroupLabelsEnum {
  pillar,
  kind,
  tags,
  attributes,
}

/// High-level classification labels for a group.
///
/// Example:
/// ```dart
/// final ModelGroupLabels labels = ModelGroupLabels(
///   pillar: ModelGroupPillar.education,
///   kind: ModelGroupKind.course,
///   tags: <String>['primary', 'virtual'],
/// );
/// ```
class ModelGroupLabels extends Model {
  const ModelGroupLabels({
    required this.pillar,
    required this.kind,
    this.tags,
    this.attributes = const <String, dynamic>{},
  });

  factory ModelGroupLabels.fromJson(Map<String, dynamic> json) {
    return ModelGroupLabels(
      pillar: Utils.enumFromJson<ModelGroupPillar>(
        ModelGroupPillar.values,
        json[ModelGroupLabelsEnum.pillar.name]?.toString(),
        ModelGroupPillar.education,
      ),
      kind: Utils.enumFromJson<ModelGroupKind>(
        ModelGroupKind.values,
        json[ModelGroupLabelsEnum.kind.name]?.toString(),
        ModelGroupKind.other,
      ),
      tags: Utils.stringListFromDynamic(
        json[ModelGroupLabelsEnum.tags.name],
      ),
      attributes: Utils.mapFromDynamic(
        json[ModelGroupLabelsEnum.attributes.name],
      ),
    );
  }

  final ModelGroupPillar pillar;
  final ModelGroupKind kind;
  final List<String>? tags;
  final Map<String, dynamic>? attributes;

  @override
  ModelGroupLabels copyWith({
    ModelGroupPillar? pillar,
    ModelGroupKind? kind,
    List<String>? tags,
    bool? Function()? tagsOverrideNull,
    Map<String, String>? attributes,
    bool? Function()? attributesOverrideNull,
  }) {
    return ModelGroupLabels(
      pillar: pillar ?? this.pillar,
      kind: kind ?? this.kind,
      tags: tagsOverrideNull != null ? null : tags ?? this.tags,
      attributes:
          attributesOverrideNull != null ? null : attributes ?? this.attributes,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelGroupLabelsEnum.pillar.name: pillar.name,
      ModelGroupLabelsEnum.kind.name: kind.name,
    };
    if (tags != null) {
      json[ModelGroupLabelsEnum.tags.name] = tags;
    }
    if (attributes != null) {
      json[ModelGroupLabelsEnum.attributes.name] = attributes;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroupLabels &&
          runtimeType == other.runtimeType &&
          pillar == other.pillar &&
          kind == other.kind &&
          _listEquals(tags, other.tags) &&
          attributes == other.attributes;

  @override
  int get hashCode => Object.hash(
        pillar,
        kind,
        tags == null ? null : Object.hashAll(tags!),
        attributes,
      );

  @override
  String toString() => 'ModelGroupLabels(${toJson()})';
}
