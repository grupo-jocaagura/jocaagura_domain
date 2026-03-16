part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelFlowCertificate].
enum ModelFlowCertificateEnum {
  id,
  certificateKey,
  flow,
  candidate,
  candidateDisplayName,
  createdAt,
  stepCompletionsByIndex,
  state,
  certifiedAt,
  certifiedBy,
  certifierNotes,
}

/// Lifecycle states of a linear flow certificate.
enum ModelFlowCertificateStateEnum {
  draft,
  inProgress,
  readyForCertification,
  certified,
}

/// Auditable wrapper that binds a complete linear flow to certification evidence.
class ModelFlowCertificate extends Model {
  const ModelFlowCertificate({
    required this.id,
    required this.certificateKey,
    required this.flow,
    required this.candidate,
    required this.createdAt,
    required this.stepCompletionsByIndex,
    required this.state,
    this.candidateDisplayName,
    this.certifiedAt,
    this.certifiedBy,
    this.certifierNotes,
  });

  factory ModelFlowCertificate.fromJson(Map<String, dynamic> json) {
    final Map<int, ModelFlowStepCompletion> tmp =
        <int, ModelFlowStepCompletion>{};
    final dynamic rawSteps =
        json[ModelFlowCertificateEnum.stepCompletionsByIndex.name];

    if (rawSteps is Map) {
      for (final MapEntry<dynamic, dynamic> entry in rawSteps.entries) {
        final int indexKey = Utils.getIntegerFromDynamic(entry.key);
        if (indexKey < 0) {
          continue;
        }
        final Map<String, dynamic> completionJson =
            Utils.mapFromDynamic(entry.value);
        tmp[indexKey] = ModelFlowStepCompletion.fromJson(completionJson);
      }
    }

    return ModelFlowCertificate(
      id: Utils.getStringFromDynamic(json[ModelFlowCertificateEnum.id.name]),
      certificateKey: Utils.getStringFromDynamic(
        json[ModelFlowCertificateEnum.certificateKey.name],
      ),
      flow: ModelCompleteFlow.fromJson(
        Utils.mapFromDynamic(json[ModelFlowCertificateEnum.flow.name]),
      ),
      candidate: UserModel.fromJson(
        Utils.mapFromDynamic(json[ModelFlowCertificateEnum.candidate.name]),
      ),
      candidateDisplayName: json.containsKey(
        ModelFlowCertificateEnum.candidateDisplayName.name,
      )
          ? _flowCertificateNullableStringFromDynamic(
              json[ModelFlowCertificateEnum.candidateDisplayName.name],
            )
          : null,
      createdAt: DateUtils.dateTimeFromDynamic(
        json[ModelFlowCertificateEnum.createdAt.name],
      ),
      stepCompletionsByIndex:
          Map<int, ModelFlowStepCompletion>.unmodifiable(tmp),
      state: Utils.enumFromJson<ModelFlowCertificateStateEnum>(
        ModelFlowCertificateStateEnum.values,
        Utils.getStringFromDynamic(json[ModelFlowCertificateEnum.state.name]),
        ModelFlowCertificateStateEnum.draft,
      ),
      certifiedAt: json.containsKey(ModelFlowCertificateEnum.certifiedAt.name)
          ? DateUtils.dateTimeFromDynamic(
              json[ModelFlowCertificateEnum.certifiedAt.name],
            )
          : null,
      certifiedBy: json.containsKey(ModelFlowCertificateEnum.certifiedBy.name)
          ? UserModel.fromJson(
              Utils.mapFromDynamic(
                json[ModelFlowCertificateEnum.certifiedBy.name],
              ),
            )
          : null,
      certifierNotes: json.containsKey(
        ModelFlowCertificateEnum.certifierNotes.name,
      )
          ? _flowCertificateNullableStringFromDynamic(
              json[ModelFlowCertificateEnum.certifierNotes.name],
            )
          : null,
    );
  }

  final String id;
  final String certificateKey;
  final ModelCompleteFlow flow;
  final UserModel candidate;
  final String? candidateDisplayName;
  final DateTime createdAt;
  final Map<int, ModelFlowStepCompletion> stepCompletionsByIndex;
  final ModelFlowCertificateStateEnum state;
  final DateTime? certifiedAt;
  final UserModel? certifiedBy;
  final String? certifierNotes;

  bool get isCertified =>
      state == ModelFlowCertificateStateEnum.certified && certifiedAt != null;

  @override
  ModelFlowCertificate copyWith({
    String? id,
    String? certificateKey,
    ModelCompleteFlow? flow,
    UserModel? candidate,
    Object? candidateDisplayName = _flowCertificateUnset,
    DateTime? createdAt,
    Map<int, ModelFlowStepCompletion>? stepCompletionsByIndex,
    ModelFlowCertificateStateEnum? state,
    Object? certifiedAt = _flowCertificateUnset,
    Object? certifiedBy = _flowCertificateUnset,
    Object? certifierNotes = _flowCertificateUnset,
  }) {
    return ModelFlowCertificate(
      id: id ?? this.id,
      certificateKey: certificateKey ?? this.certificateKey,
      flow: flow ?? this.flow,
      candidate: candidate ?? this.candidate,
      candidateDisplayName: identical(
        candidateDisplayName,
        _flowCertificateUnset,
      )
          ? this.candidateDisplayName
          : candidateDisplayName as String?,
      createdAt: createdAt ?? this.createdAt,
      stepCompletionsByIndex:
          stepCompletionsByIndex ?? this.stepCompletionsByIndex,
      state: state ?? this.state,
      certifiedAt: identical(certifiedAt, _flowCertificateUnset)
          ? this.certifiedAt
          : certifiedAt as DateTime?,
      certifiedBy: identical(certifiedBy, _flowCertificateUnset)
          ? this.certifiedBy
          : certifiedBy as UserModel?,
      certifierNotes: identical(certifierNotes, _flowCertificateUnset)
          ? this.certifierNotes
          : certifierNotes as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final List<int> keys = stepCompletionsByIndex.keys.toList(growable: false)
      ..sort();
    final Map<String, dynamic> byIndex = <String, dynamic>{};

    for (final int key in keys) {
      final ModelFlowStepCompletion? completion = stepCompletionsByIndex[key];
      if (completion != null) {
        byIndex[key.toString()] = completion.toJson();
      }
    }

    final Map<String, dynamic> json = <String, dynamic>{
      ModelFlowCertificateEnum.id.name: id,
      ModelFlowCertificateEnum.certificateKey.name: certificateKey,
      ModelFlowCertificateEnum.flow.name: flow.toJson(),
      ModelFlowCertificateEnum.candidate.name: candidate.toJson(),
      ModelFlowCertificateEnum.createdAt.name:
          DateUtils.dateTimeToString(createdAt),
      ModelFlowCertificateEnum.stepCompletionsByIndex.name: byIndex,
      ModelFlowCertificateEnum.state.name: state.name,
    };

    if (candidateDisplayName != null) {
      json[ModelFlowCertificateEnum.candidateDisplayName.name] =
          candidateDisplayName;
    }
    if (certifiedAt != null) {
      json[ModelFlowCertificateEnum.certifiedAt.name] =
          DateUtils.dateTimeToString(certifiedAt!);
    }
    if (certifiedBy != null) {
      json[ModelFlowCertificateEnum.certifiedBy.name] = certifiedBy!.toJson();
    }
    if (certifierNotes != null) {
      json[ModelFlowCertificateEnum.certifierNotes.name] = certifierNotes;
    }

    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelFlowCertificate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          certificateKey == other.certificateKey &&
          flow == other.flow &&
          Utils.deepEqualsDynamic(
            candidate.toJson(),
            other.candidate.toJson(),
          ) &&
          candidateDisplayName == other.candidateDisplayName &&
          createdAt == other.createdAt &&
          Utils.deepEqualsDynamic(
            stepCompletionsByIndex,
            other.stepCompletionsByIndex,
          ) &&
          state == other.state &&
          certifiedAt == other.certifiedAt &&
          Utils.deepEqualsDynamic(
            certifiedBy?.toJson(),
            other.certifiedBy?.toJson(),
          ) &&
          certifierNotes == other.certifierNotes;

  @override
  int get hashCode => Object.hash(
        id,
        certificateKey,
        flow,
        Utils.deepHash(candidate.toJson()),
        candidateDisplayName,
        createdAt,
        Utils.deepHash(stepCompletionsByIndex),
        state,
        certifiedAt,
        Utils.deepHash(certifiedBy?.toJson()),
        certifierNotes,
      );

  @override
  String toString() => 'ModelFlowCertificate(${toJson()})';
}

const Object _flowCertificateUnset = Object();

String? _flowCertificateNullableStringFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  final String parsed = Utils.getStringFromDynamic(value);
  return parsed.isEmpty ? null : parsed;
}

String? _flowCertificateNullableUrlFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  final String parsed = Utils.getUrlFromDynamic(value);
  return parsed.isEmpty ? null : parsed;
}
