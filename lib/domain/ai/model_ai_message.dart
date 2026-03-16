part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelAiMessage].
enum ModelAiMessageEnum {
  role,
  content,
}

/// Canonical conversational roles supported in the agnostic AI contract.
enum ModelAiMessageRoleEnum {
  user,
  assistant,
}

/// Minimal conversational message for AI interactions.
class ModelAiMessage extends Model {
  const ModelAiMessage({
    required this.role,
    required this.content,
  });

  factory ModelAiMessage.fromJson(Map<String, dynamic> json) {
    return ModelAiMessage(
      role: Utils.enumFromJson<ModelAiMessageRoleEnum>(
        ModelAiMessageRoleEnum.values,
        Utils.getStringFromDynamic(json[ModelAiMessageEnum.role.name]),
        ModelAiMessageRoleEnum.user,
      ),
      content:
          Utils.getStringFromDynamic(json[ModelAiMessageEnum.content.name]),
    );
  }

  final ModelAiMessageRoleEnum role;
  final String content;

  @override
  ModelAiMessage copyWith({
    ModelAiMessageRoleEnum? role,
    String? content,
  }) {
    return ModelAiMessage(
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelAiMessageEnum.role.name: role.name,
        ModelAiMessageEnum.content.name: content,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelAiMessage &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'ModelAiMessage(${toJson()})';
}
