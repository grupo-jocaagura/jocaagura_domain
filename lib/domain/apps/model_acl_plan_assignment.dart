part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelAclPlanAssignment].
enum ModelAclPlanAssignmentEnum {
  id,
  plan,
  targetUser,
  assignedAt,
  assignedBy,
  notes,
}

/// Snapshot assignment of an ACL plan to a target user.
class ModelAclPlanAssignment extends Model {
  const ModelAclPlanAssignment({
    required this.id,
    required this.plan,
    required this.targetUser,
    required this.assignedAt,
    this.assignedBy,
    this.notes,
  });

  factory ModelAclPlanAssignment.fromJson(Map<String, dynamic> json) {
    return ModelAclPlanAssignment(
      id: Utils.getStringFromDynamic(json[ModelAclPlanAssignmentEnum.id.name]),
      plan: ModelAclPlan.fromJson(
        Utils.mapFromDynamic(json[ModelAclPlanAssignmentEnum.plan.name]),
      ),
      targetUser: UserModel.fromJson(
        Utils.mapFromDynamic(json[ModelAclPlanAssignmentEnum.targetUser.name]),
      ),
      assignedAt: DateUtils.dateTimeFromDynamic(
        json[ModelAclPlanAssignmentEnum.assignedAt.name],
      ),
      assignedBy: json.containsKey(ModelAclPlanAssignmentEnum.assignedBy.name)
          ? UserModel.fromJson(
              Utils.mapFromDynamic(
                json[ModelAclPlanAssignmentEnum.assignedBy.name],
              ),
            )
          : null,
      notes: json.containsKey(ModelAclPlanAssignmentEnum.notes.name)
          ? _aclNullableStringFromDynamic(
              json[ModelAclPlanAssignmentEnum.notes.name],
            )
          : null,
    );
  }

  final String id;
  final ModelAclPlan plan;
  final UserModel targetUser;
  final DateTime assignedAt;
  final UserModel? assignedBy;
  final String? notes;

  @override
  ModelAclPlanAssignment copyWith({
    String? id,
    ModelAclPlan? plan,
    UserModel? targetUser,
    DateTime? assignedAt,
    Object? assignedBy = _aclPlanAssignmentUnset,
    Object? notes = _aclPlanAssignmentUnset,
  }) {
    return ModelAclPlanAssignment(
      id: id ?? this.id,
      plan: plan ?? this.plan,
      targetUser: targetUser ?? this.targetUser,
      assignedAt: assignedAt ?? this.assignedAt,
      assignedBy: identical(assignedBy, _aclPlanAssignmentUnset)
          ? this.assignedBy
          : assignedBy as UserModel?,
      notes: identical(notes, _aclPlanAssignmentUnset)
          ? this.notes
          : notes as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelAclPlanAssignmentEnum.id.name: id,
      ModelAclPlanAssignmentEnum.plan.name: plan.toJson(),
      ModelAclPlanAssignmentEnum.targetUser.name: targetUser.toJson(),
      ModelAclPlanAssignmentEnum.assignedAt.name:
          DateUtils.dateTimeToString(assignedAt),
    };

    if (assignedBy != null) {
      json[ModelAclPlanAssignmentEnum.assignedBy.name] = assignedBy!.toJson();
    }
    if (notes != null) {
      json[ModelAclPlanAssignmentEnum.notes.name] = notes;
    }

    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelAclPlanAssignment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          plan == other.plan &&
          Utils.deepEqualsDynamic(
            targetUser.toJson(),
            other.targetUser.toJson(),
          ) &&
          assignedAt == other.assignedAt &&
          Utils.deepEqualsDynamic(
            assignedBy?.toJson(),
            other.assignedBy?.toJson(),
          ) &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        id,
        plan,
        Utils.deepHash(targetUser.toJson()),
        assignedAt,
        Utils.deepHash(assignedBy?.toJson()),
        notes,
      );

  @override
  String toString() => 'ModelAclPlanAssignment(${toJson()})';
}

const Object _aclPlanAssignmentUnset = Object();

String? _aclNullableStringFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  final String parsed = Utils.getStringFromDynamic(value);
  return parsed.isEmpty ? null : parsed;
}
