part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// CRUD METADATA
/// ===========================================================================

/// Enumerates the JSON keys used by [ModelCrudMetadata].
enum ModelCrudMetadataEnum {
  recordId,
  createdBy,
  createdAt,
  updatedBy,
  updatedAt,
  deleted,
  deletedBy,
  deletedAt,
  version,
}

/// Immutable audit metadata associated with a single record.
///
/// Timestamps are represented as [DateTime] in UTC-safe format using
/// [DateUtils.dateTimeFromDynamic] and [DateUtils.dateTimeToString].
///
/// Example:
/// ```dart
/// final ModelCrudMetadata crud = ModelCrudMetadata.fromJson({
///   'recordId': 'group-001',
///   'createdBy': 'system@domain.com',
///   'createdAt': '2025-01-01T10:00:00Z',
///   'updatedBy': 'system@domain.com',
///   'updatedAt': '2025-01-01T10:00:00Z',
/// });
///
/// print(crud.recordId);   // group-001
/// print(crud.createdAt);  // DateTime instance
/// ```
class ModelCrudMetadata extends Model {
  const ModelCrudMetadata({
    required this.recordId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deleted,
    this.deletedBy,
    this.deletedAt,
    this.version,
  });

  factory ModelCrudMetadata.fromJson(Map<String, dynamic> json) {
    return ModelCrudMetadata(
      recordId: json[ModelCrudMetadataEnum.recordId.name]?.toString() ?? '',
      createdBy: json[ModelCrudMetadataEnum.createdBy.name]?.toString() ?? '',
      createdAt: DateUtils.dateTimeFromDynamic(
        json[ModelCrudMetadataEnum.createdAt.name],
      ),
      updatedBy: json[ModelCrudMetadataEnum.updatedBy.name]?.toString() ?? '',
      updatedAt: DateUtils.dateTimeFromDynamic(
        json[ModelCrudMetadataEnum.updatedAt.name],
      ),
      deleted: json[ModelCrudMetadataEnum.deleted.name] == null
          ? null
          : Utils.getBoolFromDynamic(
              json[ModelCrudMetadataEnum.deleted.name],
            ),
      deletedBy: json[ModelCrudMetadataEnum.deletedBy.name]?.toString(),
      deletedAt: json[ModelCrudMetadataEnum.deletedAt.name] == null
          ? null
          : DateUtils.dateTimeFromDynamic(
              json[ModelCrudMetadataEnum.deletedAt.name],
            ),
      version: json[ModelCrudMetadataEnum.version.name] == null
          ? null
          : Utils.getIntegerFromDynamic(
              json[ModelCrudMetadataEnum.version.name],
            ),
    );
  }

  /// Logical identifier of the record owning this metadata.
  final String recordId;

  /// Actor (user or system) that created the record.
  final String createdBy;

  /// Creation timestamp (ISO 8601 round-trip).
  final DateTime createdAt;

  /// Actor (user or system) that last updated the record.
  final String updatedBy;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Soft-delete flag.
  final bool? deleted;

  /// Actor that marked the record as deleted.
  final String? deletedBy;

  /// Timestamp when the record was marked as deleted.
  final DateTime? deletedAt;

  /// Logical version for optimistic locking / history.
  final int? version;

  @override
  ModelCrudMetadata copyWith({
    String? recordId,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    bool? deleted,
    bool? Function()? deletedOverrideNull,
    String? deletedBy,
    DateTime? deletedAt,
    int? version,
    bool? Function()? versionOverrideNull,
  }) {
    // For nullable fields we allow a small trick:
    // - pass `deletedOverrideNull: () => true` to force `deleted = null`.
    // - otherwise, use normal parameter if provided.
    return ModelCrudMetadata(
      recordId: recordId ?? this.recordId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deletedOverrideNull != null ? null : deleted ?? this.deleted,
      deletedBy: deletedBy ?? this.deletedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      version: versionOverrideNull != null ? null : version ?? this.version,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelCrudMetadataEnum.recordId.name: recordId,
      ModelCrudMetadataEnum.createdBy.name: createdBy,
      ModelCrudMetadataEnum.createdAt.name:
          DateUtils.dateTimeToString(createdAt),
      ModelCrudMetadataEnum.updatedBy.name: updatedBy,
      ModelCrudMetadataEnum.updatedAt.name:
          DateUtils.dateTimeToString(updatedAt),
    };
    if (deleted != null) {
      json[ModelCrudMetadataEnum.deleted.name] = deleted;
    }
    if (deletedBy != null) {
      json[ModelCrudMetadataEnum.deletedBy.name] = deletedBy;
    }
    if (deletedAt != null) {
      json[ModelCrudMetadataEnum.deletedAt.name] =
          DateUtils.dateTimeToString(deletedAt!);
    }
    if (version != null) {
      json[ModelCrudMetadataEnum.version.name] = version;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelCrudMetadata &&
          runtimeType == other.runtimeType &&
          recordId == other.recordId &&
          createdBy == other.createdBy &&
          createdAt == other.createdAt &&
          updatedBy == other.updatedBy &&
          updatedAt == other.updatedAt &&
          deleted == other.deleted &&
          deletedBy == other.deletedBy &&
          deletedAt == other.deletedAt &&
          version == other.version;

  @override
  int get hashCode => Object.hash(
        recordId,
        createdBy,
        createdAt,
        updatedBy,
        updatedAt,
        deleted,
        deletedBy,
        deletedAt,
        version,
      );

  @override
  String toString() => 'ModelCrudMetadata(${toJson()})';
}
