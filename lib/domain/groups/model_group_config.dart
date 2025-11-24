part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP CONFIG
/// ===========================================================================
/// JSON keys for [ModelGroupConfig].
///
/// This enum centralizes the string keys used on serialization and parsing,
/// avoiding magic strings across the codebase.
///
/// Example:
/// ```dart
/// void main() {
///   print(ModelGroupConfigEnum.googleGroupId.name); // "googleGroupId"
/// }
/// ```
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
/// This model holds the technical identifiers and synchronization state for a
/// group in the underlying provider (e.g. Google Directory / Cloud Identity),
/// as well as the audit metadata in [crud].
///
/// JSON contract:
/// - Required fields:
///   - `id` (string)
///   - `groupId` (string)
///   - `googleGroupId` (string)
///   - `email` (string)
///   - `apiSource` (string; [ModelGroupConfigApiSource.name])
///   - `lastSyncStatus` (string; [ModelGroupConfigLastSyncStatus.name])
///   - `crud` (object; [ModelCrudMetadata.toJson])
/// - Optional fields:
///   - `resourceName` (string, defaults to `''` when missing or `null`)
///   - `etagSettings` (string, defaults to `''` when missing or `null`)
///   - `lastSyncAt` (string, ISO 8601; omitted when `null`)
///
/// Parsing rules:
/// - Scalar required fields fall back to `''` when missing or `null`.
/// - [apiSource] is resolved via [Utils.enumFromJson], defaulting to
///   [ModelGroupConfigApiSource.directory] on unknown values.
/// - [lastSyncStatus] is resolved via [Utils.enumFromJson], defaulting to
///   [ModelGroupConfigLastSyncStatus.never] on unknown values.
/// - [resourceName] and [etagSettings] are normalized using
///   [Utils.getStringFromDynamic] (missing/null → `''`).
/// - [lastSyncAt] uses [DateUtils.dateTimeFromDynamic] when present.
/// - [crud] must contain a valid [ModelCrudMetadata] payload.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final DateTime now = DateTime.utc(2025, 1, 1, 10, 0, 0);
///
///   final ModelCrudMetadata crud = ModelCrudMetadata(
///     recordId: 'cfg-1',
///     createdBy: 'system@domain.com',
///     createdAt: now,
///     updatedBy: 'system@domain.com',
///     updatedAt: now,
///     version: 1,
///   );
///
///   final ModelGroupConfig config = ModelGroupConfig(
///     id: 'cfg-1',
///     groupId: 'group-001',
///     googleGroupId: 'AAA...',
///     email: 'soporte@domain.com',
///     apiSource: ModelGroupConfigApiSource.directory,
///     lastSyncStatus: ModelGroupConfigLastSyncStatus.never,
///     crud: crud,
///   );
///
///   final Map<String, dynamic> json = config.toJson();
///   final ModelGroupConfig roundtrip = ModelGroupConfig.fromJson(json);
///
///   print(roundtrip.email);          // soporte@domain.com
///   print(roundtrip.lastSyncStatus); // ModelGroupConfigLastSyncStatus.never
/// }
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
    this.resourceName = '',
    this.etagSettings = '',
    this.lastSyncAt,
  });

  /// Creates a [ModelGroupConfig] from a JSON-like map.
  ///
  /// Extra keys are ignored safely.
  factory ModelGroupConfig.fromJson(Map<String, dynamic> json) {
    return ModelGroupConfig(
      id: json[ModelGroupConfigEnum.id.name]?.toString() ?? '',
      groupId: json[ModelGroupConfigEnum.groupId.name]?.toString() ?? '',
      googleGroupId:
          json[ModelGroupConfigEnum.googleGroupId.name]?.toString() ?? '',
      email: json[ModelGroupConfigEnum.email.name]?.toString() ?? '',
      resourceName: Utils.getStringFromDynamic(
        json[ModelGroupConfigEnum.resourceName.name],
      ),
      apiSource: Utils.enumFromJson<ModelGroupConfigApiSource>(
        ModelGroupConfigApiSource.values,
        json[ModelGroupConfigEnum.apiSource.name]?.toString(),
        ModelGroupConfigApiSource.directory,
      ),
      etagSettings: Utils.getStringFromDynamic(
        json[ModelGroupConfigEnum.etagSettings.name],
      ),
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
  final String resourceName;
  final ModelGroupConfigApiSource apiSource;
  final String etagSettings;
  final ModelGroupConfigLastSyncStatus lastSyncStatus;
  final DateTime? lastSyncAt;
  final ModelCrudMetadata crud;

  /// Returns a new [ModelGroupConfig] with some fields updated.
  @override
  ModelGroupConfig copyWith({
    String? id,
    String? groupId,
    String? googleGroupId,
    String? email,
    String? resourceName,
    ModelGroupConfigApiSource? apiSource,
    String? etagSettings,
    ModelGroupConfigLastSyncStatus? lastSyncStatus,
    DateTime? lastSyncAt,
    ModelCrudMetadata? crud,
  }) {
    return ModelGroupConfig(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      googleGroupId: googleGroupId ?? this.googleGroupId,
      email: email ?? this.email,
      resourceName: resourceName ?? this.resourceName,
      apiSource: apiSource ?? this.apiSource,
      etagSettings: etagSettings ?? this.etagSettings,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
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
    json[ModelGroupConfigEnum.resourceName.name] = resourceName;
    json[ModelGroupConfigEnum.etagSettings.name] = etagSettings;
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
