part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP MEMBER
/// ===========================================================================

enum ModelGroupMemberEnum {
  id,
  groupId,
  email,
  userId,
  role,
  entityType,
  membershipId,
  source,
  subscription,
  includeDerived,
  active,
  crud,
}

/// Represents a member bound to a group.
class ModelGroupMember extends Model {
  const ModelGroupMember({
    required this.id,
    required this.groupId,
    required this.email,
    required this.userId,
    required this.role,
    required this.entityType,
    required this.membershipId,
    required this.source,
    required this.subscription,
    required this.includeDerived,
    required this.active,
    required this.crud,
  });

  factory ModelGroupMember.fromJson(Map<String, dynamic> json) {
    return ModelGroupMember(
      id: json[ModelGroupMemberEnum.id.name]?.toString() ?? '',
      groupId: json[ModelGroupMemberEnum.groupId.name]?.toString() ?? '',
      email: Utils.getEmailFromDynamic(
        json[ModelGroupMemberEnum.email.name],
      ),
      userId: json[ModelGroupMemberEnum.userId.name]?.toString() ?? '',
      role: Utils.enumFromJson<ModelGroupMemberRole>(
        ModelGroupMemberRole.values,
        json[ModelGroupMemberEnum.role.name]?.toString(),
        ModelGroupMemberRole.member,
      ),
      entityType: Utils.enumFromJson<ModelGroupMemberEntityType>(
        ModelGroupMemberEntityType.values,
        json[ModelGroupMemberEnum.entityType.name]?.toString(),
        ModelGroupMemberEntityType.user,
      ),
      membershipId:
          json[ModelGroupMemberEnum.membershipId.name]?.toString() ?? '',
      source: Utils.enumFromJson<ModelGroupMemberSource>(
        ModelGroupMemberSource.values,
        json[ModelGroupMemberEnum.source.name]?.toString(),
        ModelGroupMemberSource.manual,
      ),
      subscription: Utils.enumFromJson<ModelGroupMemberSubscription>(
        ModelGroupMemberSubscription.values,
        json[ModelGroupMemberEnum.subscription.name]?.toString(),
        ModelGroupMemberSubscription.allMail,
      ),
      includeDerived: Utils.getBoolFromDynamic(
        json[ModelGroupMemberEnum.includeDerived.name],
        defaultValueIfNull: false,
      ),
      active: Utils.getBoolFromDynamic(
        json[ModelGroupMemberEnum.active.name],
        defaultValueIfNull: true,
      ),
      crud: ModelCrudMetadata.fromJson(
        Utils.mapFromDynamic(json[ModelGroupMemberEnum.crud.name]),
      ),
    );
  }

  final String id;
  final String groupId;
  final String email;
  final String userId;
  final ModelGroupMemberRole role;
  final ModelGroupMemberEntityType entityType;
  final String membershipId;
  final ModelGroupMemberSource source;
  final ModelGroupMemberSubscription subscription;
  final bool includeDerived;
  final bool active;
  final ModelCrudMetadata crud;

  @override
  ModelGroupMember copyWith({
    String? id,
    String? groupId,
    String? email,
    String? userId,
    ModelGroupMemberRole? role,
    ModelGroupMemberEntityType? entityType,
    String? membershipId,
    ModelGroupMemberSource? source,
    ModelGroupMemberSubscription? subscription,
    bool? includeDerived,
    bool? active,
    ModelCrudMetadata? crud,
  }) {
    return ModelGroupMember(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      entityType: entityType ?? this.entityType,
      membershipId: membershipId ?? this.membershipId,
      source: source ?? this.source,
      subscription: subscription ?? this.subscription,
      includeDerived: includeDerived ?? this.includeDerived,
      active: active ?? this.active,
      crud: crud ?? this.crud,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelGroupMemberEnum.id.name: id,
      ModelGroupMemberEnum.groupId.name: groupId,
      ModelGroupMemberEnum.email.name: email,
      ModelGroupMemberEnum.userId.name: userId,
      ModelGroupMemberEnum.role.name: role.name,
      ModelGroupMemberEnum.entityType.name: entityType.name,
      ModelGroupMemberEnum.membershipId.name: membershipId,
      ModelGroupMemberEnum.source.name: source.name,
      ModelGroupMemberEnum.subscription.name: subscription.name,
      ModelGroupMemberEnum.includeDerived.name: includeDerived,
      ModelGroupMemberEnum.active.name: active,
      ModelGroupMemberEnum.crud.name: crud.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroupMember &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          email == other.email &&
          userId == other.userId &&
          role == other.role &&
          entityType == other.entityType &&
          membershipId == other.membershipId &&
          source == other.source &&
          subscription == other.subscription &&
          includeDerived == other.includeDerived &&
          active == other.active &&
          crud == other.crud;

  @override
  int get hashCode => Object.hash(
        id,
        groupId,
        email,
        userId,
        role,
        entityType,
        membershipId,
        source,
        subscription,
        includeDerived,
        active,
        crud,
      );

  @override
  String toString() => 'ModelGroupMember(${toJson()})';
}
