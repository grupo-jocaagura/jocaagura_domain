part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelAiExecutionConfig].
enum ModelAiExecutionConfigEnum {
  temperature,
  topP,
  topK,
  maxOutputTokens,
  seed,
  stopSequences,
  deterministicPreferred,
}

/// Agnostic execution intent for an AI inference request.
class ModelAiExecutionConfig extends Model {
  const ModelAiExecutionConfig({
    this.temperature,
    this.topP,
    this.topK,
    this.maxOutputTokens,
    this.seed,
    this.stopSequences,
    this.deterministicPreferred,
  });

  factory ModelAiExecutionConfig.fromJson(Map<String, dynamic> json) {
    return ModelAiExecutionConfig(
      temperature: json.containsKey(ModelAiExecutionConfigEnum.temperature.name)
          ? _aiNullableDoubleFromDynamic(
              json[ModelAiExecutionConfigEnum.temperature.name],
            )
          : null,
      topP: json.containsKey(ModelAiExecutionConfigEnum.topP.name)
          ? _aiNullableDoubleFromDynamic(
              json[ModelAiExecutionConfigEnum.topP.name],
            )
          : null,
      topK: json.containsKey(ModelAiExecutionConfigEnum.topK.name)
          ? Utils.getIntegerFromDynamic(
              json[ModelAiExecutionConfigEnum.topK.name],
            )
          : null,
      maxOutputTokens:
          json.containsKey(ModelAiExecutionConfigEnum.maxOutputTokens.name)
              ? Utils.getIntegerFromDynamic(
                  json[ModelAiExecutionConfigEnum.maxOutputTokens.name],
                )
              : null,
      seed: json.containsKey(ModelAiExecutionConfigEnum.seed.name)
          ? Utils.getIntegerFromDynamic(
              json[ModelAiExecutionConfigEnum.seed.name],
            )
          : null,
      stopSequences:
          json.containsKey(ModelAiExecutionConfigEnum.stopSequences.name)
              ? Utils.stringListFromDynamic(
                  json[ModelAiExecutionConfigEnum.stopSequences.name],
                )
              : null,
      deterministicPreferred: json.containsKey(
        ModelAiExecutionConfigEnum.deterministicPreferred.name,
      )
          ? Utils.getBoolFromDynamic(
              json[ModelAiExecutionConfigEnum.deterministicPreferred.name],
            )
          : null,
    );
  }

  final double? temperature;
  final double? topP;
  final int? topK;
  final int? maxOutputTokens;
  final int? seed;
  final List<String>? stopSequences;
  final bool? deterministicPreferred;

  @override
  ModelAiExecutionConfig copyWith({
    Object? temperature = _aiUnset,
    Object? topP = _aiUnset,
    Object? topK = _aiUnset,
    Object? maxOutputTokens = _aiUnset,
    Object? seed = _aiUnset,
    Object? stopSequences = _aiUnset,
    Object? deterministicPreferred = _aiUnset,
  }) {
    return ModelAiExecutionConfig(
      temperature: identical(temperature, _aiUnset)
          ? this.temperature
          : temperature as double?,
      topP: identical(topP, _aiUnset) ? this.topP : topP as double?,
      topK: identical(topK, _aiUnset) ? this.topK : topK as int?,
      maxOutputTokens: identical(maxOutputTokens, _aiUnset)
          ? this.maxOutputTokens
          : maxOutputTokens as int?,
      seed: identical(seed, _aiUnset) ? this.seed : seed as int?,
      stopSequences: identical(stopSequences, _aiUnset)
          ? this.stopSequences
          : stopSequences as List<String>?,
      deterministicPreferred: identical(deterministicPreferred, _aiUnset)
          ? this.deterministicPreferred
          : deterministicPreferred as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    if (temperature != null) {
      json[ModelAiExecutionConfigEnum.temperature.name] = temperature;
    }
    if (topP != null) {
      json[ModelAiExecutionConfigEnum.topP.name] = topP;
    }
    if (topK != null) {
      json[ModelAiExecutionConfigEnum.topK.name] = topK;
    }
    if (maxOutputTokens != null) {
      json[ModelAiExecutionConfigEnum.maxOutputTokens.name] = maxOutputTokens;
    }
    if (seed != null) {
      json[ModelAiExecutionConfigEnum.seed.name] = seed;
    }
    if (stopSequences != null) {
      json[ModelAiExecutionConfigEnum.stopSequences.name] = stopSequences;
    }
    if (deterministicPreferred != null) {
      json[ModelAiExecutionConfigEnum.deterministicPreferred.name] =
          deterministicPreferred;
    }

    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelAiExecutionConfig &&
          runtimeType == other.runtimeType &&
          temperature == other.temperature &&
          topP == other.topP &&
          topK == other.topK &&
          maxOutputTokens == other.maxOutputTokens &&
          seed == other.seed &&
          Utils.deepEqualsDynamic(stopSequences, other.stopSequences) &&
          deterministicPreferred == other.deterministicPreferred;

  @override
  int get hashCode => Object.hash(
        temperature,
        topP,
        topK,
        maxOutputTokens,
        seed,
        Utils.deepHash(stopSequences),
        deterministicPreferred,
      );

  @override
  String toString() => 'ModelAiExecutionConfig(${toJson()})';
}
