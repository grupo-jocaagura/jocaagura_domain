part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP CONFIG
/// ===========================================================================

enum ModelGroupConfigEnum {
  id,
  groupId,
  googleGroupId,
  email,
  resourceName,
  apiSource,
  etagSettings,
  lastSyncStatus,
  lastSyncAt,
  crud,
}

/// Technical configuration binding a [ModelGroup] to the provider.
///
/// Example:
/// ```dart
/// final ModelGroupConfig config = ModelGroupConfig.fromJson({
///   'id': 'cfg-1',
///   'groupId': 'group-001',
///   'googleGroupId': 'AAA...',
///   'email': 'soporte@domain.com',
///   'apiSource': 'directory',
///   'lastSyncStatus': 'ok',
///   'crud': {...},
/// });
/// ```
class ModelGroupConfig extends Model {
  const ModelGroupConfig({
    required this.id,
    required this.groupId,
    required this.googleGroupId,
    required this.email,
    required this.apiSource,
    required this.lastSyncStatus,
    required this.crud,
    this.resourceName,
    this.etagSettings,
    this.lastSyncAt,
  });

  factory ModelGroupConfig.fromJson(Map<String, dynamic> json) {
    return ModelGroupConfig(
      id: json[ModelGroupConfigEnum.id.name]?.toString() ?? '',
      groupId: json[ModelGroupConfigEnum.groupId.name]?.toString() ?? '',
      googleGroupId:
          json[ModelGroupConfigEnum.googleGroupId.name]?.toString() ?? '',
      email: json[ModelGroupConfigEnum.email.name]?.toString() ?? '',
      resourceName: json[ModelGroupConfigEnum.resourceName.name]?.toString(),
      apiSource: Utils.enumFromJson<ModelGroupConfigApiSource>(
        ModelGroupConfigApiSource.values,
        json[ModelGroupConfigEnum.apiSource.name]?.toString(),
        ModelGroupConfigApiSource.directory,
      ),
      etagSettings: json[ModelGroupConfigEnum.etagSettings.name]?.toString(),
      lastSyncStatus: Utils.enumFromJson<ModelGroupConfigLastSyncStatus>(
        ModelGroupConfigLastSyncStatus.values,
        json[ModelGroupConfigEnum.lastSyncStatus.name]?.toString(),
        ModelGroupConfigLastSyncStatus.never,
      ),
      lastSyncAt: json[ModelGroupConfigEnum.lastSyncAt.name] == null
          ? null
          : DateUtils.dateTimeFromDynamic(
              json[ModelGroupConfigEnum.lastSyncAt.name],
            ),
      crud: ModelCrudMetadata.fromJson(
        Utils.mapFromDynamic(json[ModelGroupConfigEnum.crud.name]),
      ),
    );
  }

  final String id;
  final String groupId;
  final String googleGroupId;
  final String email;
  final String? resourceName;
  final ModelGroupConfigApiSource apiSource;
  final String? etagSettings;
  final ModelGroupConfigLastSyncStatus lastSyncStatus;
  final DateTime? lastSyncAt;
  final ModelCrudMetadata crud;

  @override
  ModelGroupConfig copyWith({
    String? id,
    String? groupId,
    String? googleGroupId,
    String? email,
    String? resourceName,
    bool? Function()? resourceNameOverrideNull,
    ModelGroupConfigApiSource? apiSource,
    String? etagSettings,
    bool? Function()? etagSettingsOverrideNull,
    ModelGroupConfigLastSyncStatus? lastSyncStatus,
    DateTime? lastSyncAt,
    bool? Function()? lastSyncAtOverrideNull,
    ModelCrudMetadata? crud,
  }) {
    return ModelGroupConfig(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      googleGroupId: googleGroupId ?? this.googleGroupId,
      email: email ?? this.email,
      resourceName: resourceNameOverrideNull != null
          ? null
          : resourceName ?? this.resourceName,
      apiSource: apiSource ?? this.apiSource,
      etagSettings: etagSettingsOverrideNull != null
          ? null
          : etagSettings ?? this.etagSettings,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncAt:
          lastSyncAtOverrideNull != null ? null : lastSyncAt ?? this.lastSyncAt,
      crud: crud ?? this.crud,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelGroupConfigEnum.id.name: id,
      ModelGroupConfigEnum.groupId.name: groupId,
      ModelGroupConfigEnum.googleGroupId.name: googleGroupId,
      ModelGroupConfigEnum.email.name: email,
      ModelGroupConfigEnum.apiSource.name: apiSource.name,
      ModelGroupConfigEnum.lastSyncStatus.name: lastSyncStatus.name,
      ModelGroupConfigEnum.crud.name: crud.toJson(),
    };
    if (resourceName != null) {
      json[ModelGroupConfigEnum.resourceName.name] = resourceName;
    }
    if (etagSettings != null) {
      json[ModelGroupConfigEnum.etagSettings.name] = etagSettings;
    }
    if (lastSyncAt != null) {
      json[ModelGroupConfigEnum.lastSyncAt.name] =
          DateUtils.dateTimeToString(lastSyncAt!);
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroupConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          googleGroupId == other.googleGroupId &&
          email == other.email &&
          resourceName == other.resourceName &&
          apiSource == other.apiSource &&
          etagSettings == other.etagSettings &&
          lastSyncStatus == other.lastSyncStatus &&
          lastSyncAt == other.lastSyncAt &&
          crud == other.crud;

  @override
  int get hashCode => Object.hash(
        id,
        groupId,
        googleGroupId,
        email,
        resourceName,
        apiSource,
        etagSettings,
        lastSyncStatus,
        lastSyncAt,
        crud,
      );

  @override
  String toString() => 'ModelGroupConfig(${toJson()})';
}
