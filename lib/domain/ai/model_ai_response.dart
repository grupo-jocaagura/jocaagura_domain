part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelAiResponse].
enum ModelAiResponseEnum {
  requestId,
  provider,
  modelId,
  content,
  parsedJson,
  finishReason,
  usage,
}

/// Canonical final AI response for a request.
class ModelAiResponse extends Model {
  const ModelAiResponse({
    required this.requestId,
    required this.provider,
    required this.modelId,
    required this.content,
    this.parsedJson,
    this.finishReason,
    this.usage,
  });

  factory ModelAiResponse.fromJson(Map<String, dynamic> json) {
    return ModelAiResponse(
      requestId:
          Utils.getStringFromDynamic(json[ModelAiResponseEnum.requestId.name]),
      provider:
          Utils.getStringFromDynamic(json[ModelAiResponseEnum.provider.name]),
      modelId:
          Utils.getStringFromDynamic(json[ModelAiResponseEnum.modelId.name]),
      content:
          Utils.getStringFromDynamic(json[ModelAiResponseEnum.content.name]),
      parsedJson: json.containsKey(ModelAiResponseEnum.parsedJson.name)
          ? Utils.mapFromDynamic(json[ModelAiResponseEnum.parsedJson.name])
          : null,
      finishReason: json.containsKey(ModelAiResponseEnum.finishReason.name)
          ? _aiNullableStringFromDynamic(
              json[ModelAiResponseEnum.finishReason.name],
            )
          : null,
      usage: json.containsKey(ModelAiResponseEnum.usage.name)
          ? Utils.mapFromDynamic(json[ModelAiResponseEnum.usage.name])
          : null,
    );
  }

  final String requestId;
  final String provider;
  final String modelId;
  final String content;
  final Map<String, dynamic>? parsedJson;
  final String? finishReason;
  final Map<String, dynamic>? usage;

  @override
  ModelAiResponse copyWith({
    String? requestId,
    String? provider,
    String? modelId,
    String? content,
    Object? parsedJson = _aiUnset,
    Object? finishReason = _aiUnset,
    Object? usage = _aiUnset,
  }) {
    return ModelAiResponse(
      requestId: requestId ?? this.requestId,
      provider: provider ?? this.provider,
      modelId: modelId ?? this.modelId,
      content: content ?? this.content,
      parsedJson: identical(parsedJson, _aiUnset)
          ? this.parsedJson
          : parsedJson as Map<String, dynamic>?,
      finishReason: identical(finishReason, _aiUnset)
          ? this.finishReason
          : finishReason as String?,
      usage: identical(usage, _aiUnset)
          ? this.usage
          : usage as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelAiResponseEnum.requestId.name: requestId,
      ModelAiResponseEnum.provider.name: provider,
      ModelAiResponseEnum.modelId.name: modelId,
      ModelAiResponseEnum.content.name: content,
    };

    if (parsedJson != null) {
      json[ModelAiResponseEnum.parsedJson.name] = parsedJson;
    }
    if (finishReason != null) {
      json[ModelAiResponseEnum.finishReason.name] = finishReason;
    }
    if (usage != null) {
      json[ModelAiResponseEnum.usage.name] = usage;
    }

    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelAiResponse &&
          runtimeType == other.runtimeType &&
          requestId == other.requestId &&
          provider == other.provider &&
          modelId == other.modelId &&
          content == other.content &&
          Utils.deepEqualsDynamic(parsedJson, other.parsedJson) &&
          finishReason == other.finishReason &&
          Utils.deepEqualsDynamic(usage, other.usage);

  @override
  int get hashCode => Object.hash(
        requestId,
        provider,
        modelId,
        content,
        Utils.deepHash(parsedJson),
        finishReason,
        Utils.deepHash(usage),
      );

  @override
  String toString() => 'ModelAiResponse(${toJson()})';
}

const Object _aiUnset = Object();

String? _aiNullableStringFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  final String parsed = Utils.getStringFromDynamic(value);
  return parsed.isEmpty ? null : parsed;
}

double? _aiNullableDoubleFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  final String normalized = value.toString().trim();
  if (normalized.isEmpty) {
    return null;
  }
  return double.tryParse(normalized);
}
