part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelAclPlan].
enum ModelAclPlanEnum {
  id,
  name,
  description,
  appName,
  acls,
}

/// Reusable bundle of concrete ACL grants for a specific app.
class ModelAclPlan extends Model {
  const ModelAclPlan({
    required this.id,
    required this.name,
    required this.appName,
    required this.acls,
    this.description,
  });

  factory ModelAclPlan.fromJson(Map<String, dynamic> json) {
    return ModelAclPlan(
      id: Utils.getStringFromDynamic(json[ModelAclPlanEnum.id.name]),
      name: Utils.getStringFromDynamic(json[ModelAclPlanEnum.name.name]),
      description: json.containsKey(ModelAclPlanEnum.description.name)
          ? _aclNullableStringFromDynamic(
              json[ModelAclPlanEnum.description.name],
            )
          : null,
      appName: Utils.getStringFromDynamic(json[ModelAclPlanEnum.appName.name]),
      acls: Utils.listFromDynamic(json[ModelAclPlanEnum.acls.name])
          .map((Map<String, dynamic> e) => ModelAcl.fromJson(e))
          .toList(growable: false),
    );
  }

  final String id;
  final String name;
  final String? description;
  final String appName;
  final List<ModelAcl> acls;

  @override
  ModelAclPlan copyWith({
    String? id,
    String? name,
    Object? description = _aclPlanUnset,
    String? appName,
    List<ModelAcl>? acls,
  }) {
    return ModelAclPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: identical(description, _aclPlanUnset)
          ? this.description
          : description as String?,
      appName: appName ?? this.appName,
      acls: acls ?? this.acls,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelAclPlanEnum.id.name: id,
      ModelAclPlanEnum.name.name: name,
      ModelAclPlanEnum.appName.name: appName,
      ModelAclPlanEnum.acls.name:
          acls.map((ModelAcl acl) => acl.toJson()).toList(growable: false),
    };

    if (description != null) {
      json[ModelAclPlanEnum.description.name] = description;
    }

    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelAclPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          appName == other.appName &&
          Utils.listEquals(acls, other.acls);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        appName,
        Utils.listHash(acls),
      );

  @override
  String toString() => 'ModelAclPlan(${toJson()})';
}

const Object _aclPlanUnset = Object();
