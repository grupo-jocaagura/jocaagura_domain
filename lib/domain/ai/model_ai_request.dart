part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelAiRequest].
enum ModelAiRequestEnum {
  id,
  provider,
  modelId,
  taskType,
  systemInstruction,
  messages,
  references,
  executionConfig,
  expectedResponseSchema,
}

/// Canonical agnostic AI task kinds.
enum ModelAiTaskTypeEnum {
  textGeneration,
  groundedTextGeneration,
  imageGeneration,
}

/// Canonical AI request portable across providers.
class ModelAiRequest extends Model {
  const ModelAiRequest({
    required this.id,
    required this.provider,
    required this.modelId,
    required this.taskType,
    required this.messages,
    this.systemInstruction,
    this.references,
    this.executionConfig,
    this.expectedResponseSchema,
  });

  factory ModelAiRequest.fromJson(Map<String, dynamic> json) {
    return ModelAiRequest(
      id: Utils.getStringFromDynamic(json[ModelAiRequestEnum.id.name]),
      provider:
          Utils.getStringFromDynamic(json[ModelAiRequestEnum.provider.name]),
      modelId:
          Utils.getStringFromDynamic(json[ModelAiRequestEnum.modelId.name]),
      taskType: Utils.enumFromJson<ModelAiTaskTypeEnum>(
        ModelAiTaskTypeEnum.values,
        Utils.getStringFromDynamic(json[ModelAiRequestEnum.taskType.name]),
        ModelAiTaskTypeEnum.textGeneration,
      ),
      systemInstruction: json.containsKey(
        ModelAiRequestEnum.systemInstruction.name,
      )
          ? _aiNullableStringFromDynamic(
              json[ModelAiRequestEnum.systemInstruction.name],
            )
          : null,
      messages: Utils.listFromDynamic(json[ModelAiRequestEnum.messages.name])
          .map((Map<String, dynamic> e) => ModelAiMessage.fromJson(e))
          .toList(),
      references: json.containsKey(ModelAiRequestEnum.references.name)
          ? Utils.stringListFromDynamic(
              json[ModelAiRequestEnum.references.name],
            )
          : null,
      executionConfig: json.containsKey(ModelAiRequestEnum.executionConfig.name)
          ? ModelAiExecutionConfig.fromJson(
              Utils.mapFromDynamic(
                json[ModelAiRequestEnum.executionConfig.name],
              ),
            )
          : null,
      expectedResponseSchema: json.containsKey(
        ModelAiRequestEnum.expectedResponseSchema.name,
      )
          ? ModelJsonSchemaDocument.fromJson(
              Utils.mapFromDynamic(
                json[ModelAiRequestEnum.expectedResponseSchema.name],
              ),
            )
          : null,
    );
  }

  final String id;
  final String provider;
  final String modelId;
  final ModelAiTaskTypeEnum taskType;
  final String? systemInstruction;
  final List<ModelAiMessage> messages;
  final List<String>? references;
  final ModelAiExecutionConfig? executionConfig;
  final ModelJsonSchemaDocument? expectedResponseSchema;

  @override
  ModelAiRequest copyWith({
    String? id,
    String? provider,
    String? modelId,
    ModelAiTaskTypeEnum? taskType,
    Object? systemInstruction = _aiUnset,
    List<ModelAiMessage>? messages,
    Object? references = _aiUnset,
    Object? executionConfig = _aiUnset,
    Object? expectedResponseSchema = _aiUnset,
  }) {
    return ModelAiRequest(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      modelId: modelId ?? this.modelId,
      taskType: taskType ?? this.taskType,
      systemInstruction: identical(systemInstruction, _aiUnset)
          ? this.systemInstruction
          : systemInstruction as String?,
      messages: messages ?? this.messages,
      references: identical(references, _aiUnset)
          ? this.references
          : references as List<String>?,
      executionConfig: identical(executionConfig, _aiUnset)
          ? this.executionConfig
          : executionConfig as ModelAiExecutionConfig?,
      expectedResponseSchema: identical(expectedResponseSchema, _aiUnset)
          ? this.expectedResponseSchema
          : expectedResponseSchema as ModelJsonSchemaDocument?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelAiRequestEnum.id.name: id,
      ModelAiRequestEnum.provider.name: provider,
      ModelAiRequestEnum.modelId.name: modelId,
      ModelAiRequestEnum.taskType.name: taskType.name,
      ModelAiRequestEnum.messages.name:
          messages.map((ModelAiMessage e) => e.toJson()).toList(),
    };

    if (systemInstruction != null) {
      json[ModelAiRequestEnum.systemInstruction.name] = systemInstruction;
    }
    if (references != null) {
      json[ModelAiRequestEnum.references.name] = references;
    }
    if (executionConfig != null) {
      json[ModelAiRequestEnum.executionConfig.name] = executionConfig!.toJson();
    }
    if (expectedResponseSchema != null) {
      json[ModelAiRequestEnum.expectedResponseSchema.name] =
          expectedResponseSchema!.toJson();
    }

    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelAiRequest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          provider == other.provider &&
          modelId == other.modelId &&
          taskType == other.taskType &&
          systemInstruction == other.systemInstruction &&
          Utils.listEquals(messages, other.messages) &&
          Utils.deepEqualsDynamic(references, other.references) &&
          executionConfig == other.executionConfig &&
          expectedResponseSchema == other.expectedResponseSchema;

  @override
  int get hashCode => Object.hash(
        id,
        provider,
        modelId,
        taskType,
        systemInstruction,
        Utils.listHash(messages),
        Utils.deepHash(references),
        executionConfig,
        expectedResponseSchema,
      );

  @override
  String toString() => 'ModelAiRequest(${toJson()})';
}
