part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP DYNAMIC MEMBERSHIP RULE
/// ===========================================================================

enum ModelGroupDynamicMembershipRuleEnum {
  id,
  groupId,
  expression,
  status,
  lastEvaluatedAt,
  estimatedMembers,
}

/// Dynamic membership rule for a group.
class ModelGroupDynamicMembershipRule extends Model {
  const ModelGroupDynamicMembershipRule({
    required this.id,
    required this.groupId,
    required this.expression,
    required this.status,
    this.lastEvaluatedAt,
    this.estimatedMembers,
  });

  factory ModelGroupDynamicMembershipRule.fromJson(Map<String, dynamic> json) {
    return ModelGroupDynamicMembershipRule(
      id: json[ModelGroupDynamicMembershipRuleEnum.id.name]?.toString() ?? '',
      groupId:
          json[ModelGroupDynamicMembershipRuleEnum.groupId.name]?.toString() ??
              '',
      expression: json[ModelGroupDynamicMembershipRuleEnum.expression.name]
              ?.toString() ??
          '',
      status: Utils.enumFromJson<ModelGroupDynamicMembershipRuleStatus>(
        ModelGroupDynamicMembershipRuleStatus.values,
        json[ModelGroupDynamicMembershipRuleEnum.status.name]?.toString(),
        ModelGroupDynamicMembershipRuleStatus.draft,
      ),
      lastEvaluatedAt:
          json[ModelGroupDynamicMembershipRuleEnum.lastEvaluatedAt.name] == null
              ? null
              : DateUtils.dateTimeFromDynamic(
                  json[
                      ModelGroupDynamicMembershipRuleEnum.lastEvaluatedAt.name],
                ),
      estimatedMembers: json[
                  ModelGroupDynamicMembershipRuleEnum.estimatedMembers.name] ==
              null
          ? null
          : Utils.getIntegerFromDynamic(
              json[ModelGroupDynamicMembershipRuleEnum.estimatedMembers.name],
            ),
    );
  }

  final String id;
  final String groupId;
  final String expression;
  final ModelGroupDynamicMembershipRuleStatus status;
  final DateTime? lastEvaluatedAt;
  final int? estimatedMembers;

  @override
  ModelGroupDynamicMembershipRule copyWith({
    String? id,
    String? groupId,
    String? expression,
    ModelGroupDynamicMembershipRuleStatus? status,
    DateTime? lastEvaluatedAt,
    bool? Function()? lastEvaluatedAtOverrideNull,
    int? estimatedMembers,
    bool? Function()? estimatedMembersOverrideNull,
  }) {
    return ModelGroupDynamicMembershipRule(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      expression: expression ?? this.expression,
      status: status ?? this.status,
      lastEvaluatedAt: lastEvaluatedAtOverrideNull != null
          ? null
          : lastEvaluatedAt ?? this.lastEvaluatedAt,
      estimatedMembers: estimatedMembersOverrideNull != null
          ? null
          : estimatedMembers ?? this.estimatedMembers,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelGroupDynamicMembershipRuleEnum.id.name: id,
      ModelGroupDynamicMembershipRuleEnum.groupId.name: groupId,
      ModelGroupDynamicMembershipRuleEnum.expression.name: expression,
      ModelGroupDynamicMembershipRuleEnum.status.name: status.name,
    };
    if (lastEvaluatedAt != null) {
      json[ModelGroupDynamicMembershipRuleEnum.lastEvaluatedAt.name] =
          DateUtils.dateTimeToString(lastEvaluatedAt!);
    }
    if (estimatedMembers != null) {
      json[ModelGroupDynamicMembershipRuleEnum.estimatedMembers.name] =
          estimatedMembers;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroupDynamicMembershipRule &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          expression == other.expression &&
          status == other.status &&
          lastEvaluatedAt == other.lastEvaluatedAt &&
          estimatedMembers == other.estimatedMembers;

  @override
  int get hashCode => Object.hash(
        id,
        groupId,
        expression,
        status,
        lastEvaluatedAt,
        estimatedMembers,
      );

  @override
  String toString() => 'ModelGroupDynamicMembershipRule(${toJson()})';
}
