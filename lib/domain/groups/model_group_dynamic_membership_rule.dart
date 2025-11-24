part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP DYNAMIC MEMBERSHIP RULE
/// ===========================================================================
/// JSON keys for [ModelGroupDynamicMembershipRule].
///
/// This enum centralizes the string keys used on serialization and parsing,
/// avoiding magic strings across the codebase.
///
/// Example:
/// ```dart
/// void main() {
///   print(ModelGroupDynamicMembershipRuleEnum.estimatedMembers.name); // "estimatedMembers"
/// }
/// ```
enum ModelGroupDynamicMembershipRuleEnum {
  id,
  groupId,
  expression,
  status,
  lastEvaluatedAt,
  estimatedMembers,
}

/// Dynamic membership rule for a group.
///
/// This model represents a dynamic rule expression (e.g. Google Workspace
/// style predicates) used to determine the members of a group without
/// manually managing memberships.
///
/// JSON contract:
/// - Required fields:
///   - `id` (string)
///   - `groupId` (string)
///   - `expression` (string)
///   - `status` (string; [ModelGroupDynamicMembershipRuleStatus.name])
/// - Optional fields:
///   - `lastEvaluatedAt` (string; ISO 8601, parsed by [DateUtils.dateTimeFromDynamic])
///   - `estimatedMembers` (int; total members estimated by the provider)
///
/// Parsing rules:
/// - Scalar strings (`id`, `groupId`, `expression`) fall back to `''`
///   when missing or `null`.
/// - [status] is resolved with [Utils.enumFromJson], defaulting to
///   [ModelGroupDynamicMembershipRuleStatus.draft] for missing/unknown values.
/// - [lastEvaluatedAt] is `null` when missing or `null`.
/// - [estimatedMembers] is normalized with [Utils.getIntegerFromDynamic].
///   When missing or `null`, it effectively defaults to `0`.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final ModelGroupDynamicMembershipRule rule = ModelGroupDynamicMembershipRule(
///     id: 'rule-1',
///     groupId: 'group-001',
///     expression: 'user.department == "Engineering"',
///     status: ModelGroupDynamicMembershipRuleStatus.active,
///     estimatedMembers: 42,
///   );
///
///   final Map<String, dynamic> json = rule.toJson();
///   final ModelGroupDynamicMembershipRule roundtrip =
///       ModelGroupDynamicMembershipRule.fromJson(json);
///
///   print(roundtrip.expression);       // user.department == "Engineering"
///   print(roundtrip.status);           // ModelGroupDynamicMembershipRuleStatus.active
///   print(roundtrip.estimatedMembers); // 42
/// }
/// ```
class ModelGroupDynamicMembershipRule extends Model {
  const ModelGroupDynamicMembershipRule({
    required this.id,
    required this.groupId,
    required this.expression,
    required this.status,
    this.lastEvaluatedAt,
    this.estimatedMembers = 1,
  });

  /// Creates a [ModelGroupDynamicMembershipRule] from a JSON-like map.
  ///
  /// Extra keys are ignored safely.
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
      estimatedMembers: Utils.getIntegerFromDynamic(
        json[ModelGroupDynamicMembershipRuleEnum.estimatedMembers.name],
      ),
    );
  }

  final String id;
  final String groupId;
  final String expression;
  final ModelGroupDynamicMembershipRuleStatus status;
  final DateTime? lastEvaluatedAt;
  final int estimatedMembers;

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
      estimatedMembers: estimatedMembers ?? this.estimatedMembers,
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
    json[ModelGroupDynamicMembershipRuleEnum.estimatedMembers.name] =
        estimatedMembers;
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
