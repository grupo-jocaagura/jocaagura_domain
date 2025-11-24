part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP ALIAS
/// ===========================================================================

enum ModelGroupAliasEnum {
  id,
  groupId,
  aliasEmail,
  status,
  errorItemId,
  crud,
}

/// Represents an email alias bound to a group.
///
/// Example:
/// ```dart
/// final ModelGroupAlias alias = ModelGroupAlias.fromJson({
///   'id': 'alias-1',
///   'groupId': 'group-001',
///   'aliasEmail': 'soporte@domain.com',
///   'status': 'active',
///   'crud': {...},
/// });
/// ```
class ModelGroupAlias extends Model {
  const ModelGroupAlias({
    required this.id,
    required this.groupId,
    required this.aliasEmail,
    required this.status,
    required this.crud,
    this.errorItemId,
  });

  factory ModelGroupAlias.fromJson(Map<String, dynamic> json) {
    return ModelGroupAlias(
      id: json[ModelGroupAliasEnum.id.name]?.toString() ?? '',
      groupId: json[ModelGroupAliasEnum.groupId.name]?.toString() ?? '',
      aliasEmail: json[ModelGroupAliasEnum.aliasEmail.name]?.toString() ?? '',
      status: Utils.enumFromJson<ModelGroupAliasStatus>(
        ModelGroupAliasStatus.values,
        json[ModelGroupAliasEnum.status.name]?.toString(),
        ModelGroupAliasStatus.active,
      ),
      errorItemId: json[ModelGroupAliasEnum.errorItemId.name]?.toString(),
      crud: ModelCrudMetadata.fromJson(
        Utils.mapFromDynamic(json[ModelGroupAliasEnum.crud.name]),
      ),
    );
  }

  final String id;
  final String groupId;
  final String aliasEmail;
  final ModelGroupAliasStatus status;
  final String? errorItemId;
  final ModelCrudMetadata crud;

  @override
  ModelGroupAlias copyWith({
    String? id,
    String? groupId,
    String? aliasEmail,
    ModelGroupAliasStatus? status,
    String? errorItemId,
    bool? Function()? errorItemIdOverrideNull,
    ModelCrudMetadata? crud,
  }) {
    return ModelGroupAlias(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      aliasEmail: aliasEmail ?? this.aliasEmail,
      status: status ?? this.status,
      errorItemId: errorItemIdOverrideNull != null
          ? null
          : errorItemId ?? this.errorItemId,
      crud: crud ?? this.crud,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelGroupAliasEnum.id.name: id,
      ModelGroupAliasEnum.groupId.name: groupId,
      ModelGroupAliasEnum.aliasEmail.name: aliasEmail,
      ModelGroupAliasEnum.status.name: status.name,
      ModelGroupAliasEnum.crud.name: crud.toJson(),
    };
    if (errorItemId != null) {
      json[ModelGroupAliasEnum.errorItemId.name] = errorItemId;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroupAlias &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          aliasEmail == other.aliasEmail &&
          status == other.status &&
          errorItemId == other.errorItemId &&
          crud == other.crud;

  @override
  int get hashCode => Object.hash(
        id,
        groupId,
        aliasEmail,
        status,
        errorItemId,
        crud,
      );

  @override
  String toString() => 'ModelGroupAlias(${toJson()})';
}
