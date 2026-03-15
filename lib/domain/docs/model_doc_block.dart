part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelDocBlock].
enum ModelDocBlockEnum {
  kind,
  content,
  level,
}

/// Canonical block kinds supported by the docs module.
enum ModelDocBlockKindEnum {
  heading,
  paragraph,
  markdown,
}

/// Minimal block-based content unit for portable docs.
class ModelDocBlock extends Model {
  const ModelDocBlock({
    required this.kind,
    required this.content,
    this.level,
  });

  factory ModelDocBlock.fromJson(Map<String, dynamic> json) {
    return ModelDocBlock(
      kind: Utils.enumFromJson<ModelDocBlockKindEnum>(
        ModelDocBlockKindEnum.values,
        Utils.getStringFromDynamic(json[ModelDocBlockEnum.kind.name]),
        ModelDocBlockKindEnum.paragraph,
      ),
      content: Utils.getStringFromDynamic(json[ModelDocBlockEnum.content.name]),
      level: json.containsKey(ModelDocBlockEnum.level.name)
          ? Utils.getIntegerFromDynamic(json[ModelDocBlockEnum.level.name])
          : null,
    );
  }

  final ModelDocBlockKindEnum kind;
  final String content;
  final int? level;

  @override
  ModelDocBlock copyWith({
    ModelDocBlockKindEnum? kind,
    String? content,
    Object? level = _docUnset,
  }) {
    return ModelDocBlock(
      kind: kind ?? this.kind,
      content: content ?? this.content,
      level: identical(level, _docUnset) ? this.level : level as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelDocBlockEnum.kind.name: kind.name,
      ModelDocBlockEnum.content.name: content,
    };
    if (level != null) {
      json[ModelDocBlockEnum.level.name] = level;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelDocBlock &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          content == other.content &&
          level == other.level;

  @override
  int get hashCode => Object.hash(kind, content, level);

  @override
  String toString() => 'ModelDocBlock(${toJson()})';
}

const Object _docUnset = Object();
