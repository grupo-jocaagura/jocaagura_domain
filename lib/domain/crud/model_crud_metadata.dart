part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the JSON keys used by [ModelCrudMetadata].
///
/// Using this enum avoids scattering raw string keys across the codebase.
/// Each key is serialized/deserialized via its [name] property.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   // Prints "createdAt"
///   print(ModelCrudMetadataEnum.createdAt.name);
/// }
/// ```
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
/// This model centralizes who created/updated/deleted a record and when,
/// plus an optional logical [version] used for optimistic locking or history.
///
/// JSON contract:
/// - Required fields:
///   - `recordId` (string)
///   - `createdBy` (string)
///   - `createdAt` (string; parsed by [DateUtils.dateTimeFromDynamic])
///   - `updatedBy` (string)
///   - `updatedAt` (string; parsed by [DateUtils.dateTimeFromDynamic])
/// - Optional fields (only included when non-null):
///   - `deleted` (bool)
///   - `deletedBy` (string)
///   - `deletedAt` (string; parsed by [DateUtils.dateTimeFromDynamic])
///   - `version` (int)
///
/// Timestamps are represented as [DateTime] and converted using
/// [DateUtils.dateTimeFromDynamic] and [DateUtils.dateTimeToString].
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final ModelCrudMetadata created = ModelCrudMetadata(
///     recordId: 'group-001',
///     createdBy: 'system@domain.com',
///     createdAt: DateTime.utc(2025, 1, 1, 10, 0, 0),
///     updatedBy: 'system@domain.com',
///     updatedAt: DateTime.utc(2025, 1, 1, 10, 0, 0),
///     version: 1,
///   );
///
///   final Map<String, dynamic> json = created.toJson();
///   final ModelCrudMetadata roundtrip = ModelCrudMetadata.fromJson(json);
///
///   print(roundtrip.recordId); // group-001
///   print(roundtrip.createdAt); // DateTime instance
/// }
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

  /// Creates a [ModelCrudMetadata] from a JSON-like map.
  ///
  /// Parsing rules:
  /// - String fields are read with `toString()` and default to `''` when null.
  /// - Timestamps are parsed through [DateUtils.dateTimeFromDynamic].
  /// - [deleted] is parsed via [Utils.getBoolFromDynamic] when non-null.
  /// - [version] is parsed via [Utils.getIntegerFromDynamic] when non-null.
  ///
  /// Extra keys are safely ignored.
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

  /// Serializes this metadata into a JSON-like map.
  ///
  /// Required timestamps are converted with [DateUtils.dateTimeToString].
  /// Optional fields (`deleted`, `deletedBy`, `deletedAt`, `version`) are only
  /// included when non-null to keep the JSON payload compact.
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

  /// Initializes CRUD metadata for a newly created record.
  ///
  /// Behavior:
  /// - Sets [recordId] and [createdBy] / [updatedBy] to [actor].
  /// - Uses [timestamp] (converted to UTC) when provided; otherwise
  ///   `DateTime.now().toUtc()`.
  /// - Sets [createdAt] and [updatedAt] to the same timestamp.
  /// - Sets [deleted], [deletedBy], [deletedAt] to `null`.
  /// - Sets [version] to [initialVersion] (defaults to `1`).
  ///
  /// This is typically used at the moment a new record is inserted.
  ///
  /// Minimal runnable example:
  /// ```dart
  /// void main() {
  ///   final ModelCrudMetadata crud = ModelCrudMetadata.initialize(
  ///     recordId: 'group-001',
  ///     actor: 'system@domain.com',
  ///   );
  ///   print(crud.version);   // 1
  ///   print(crud.deleted);   // null
  /// }
  /// ```
  static ModelCrudMetadata initialize({
    required String recordId,
    required String actor,
    DateTime? timestamp,
    int initialVersion = 1,
  }) {
    final DateTime t = (timestamp ?? DateTime.now()).toUtc();
    return ModelCrudMetadata(
      recordId: recordId,
      createdBy: actor,
      createdAt: t,
      updatedBy: actor,
      updatedAt: t,
      version: initialVersion,
    );
  }

  /// Updates audit metadata for an existing record on modification.
  ///
  /// Behavior:
  /// - Keeps [recordId], [createdBy] and [createdAt] unchanged.
  /// - Sets [updatedBy] to [actor].
  /// - Sets [updatedAt] to [timestamp] (UTC) or `DateTime.now().toUtc()`.
  /// - When [bumpVersion] is `true` (default), increments [version] as:
  ///   `(current.version ?? 0) + 1`.
  /// - When [bumpVersion] is `false`, preserves [current.version].
  ///
  /// This is typically used whenever the main record is updated.
  ///
  /// Minimal runnable example:
  /// ```dart
  /// void main() {
  ///   final DateTime createdAt = DateTime.utc(2025, 1, 1, 10);
  ///   final ModelCrudMetadata base = ModelCrudMetadata(
  ///     recordId: 'group-001',
  ///     createdBy: 'system@domain.com',
  ///     createdAt: createdAt,
  ///     updatedBy: 'system@domain.com',
  ///     updatedAt: createdAt,
  ///     version: 1,
  ///   );
  ///
  ///   final ModelCrudMetadata updated = ModelCrudMetadata.touchOnUpdate(
  ///     current: base,
  ///     actor: 'admin@domain.com',
  ///   );
  ///
  ///   print(updated.version);    // 2
  ///   print(updated.updatedBy);  // admin@domain.com
  /// }
  /// ```
  static ModelCrudMetadata touchOnUpdate({
    required ModelCrudMetadata current,
    required String actor,
    DateTime? timestamp,
    bool bumpVersion = true,
  }) {
    final DateTime t = (timestamp ?? DateTime.now()).toUtc();
    final int? newVersion =
        bumpVersion ? ((current.version ?? 0) + 1) : current.version;

    return current.copyWith(
      updatedBy: actor,
      updatedAt: t,
      version: newVersion,
    );
  }

  /// Marks the record as soft-deleted, updating audit metadata.
  ///
  /// Behavior:
  /// - Sets [deleted] to `true`.
  /// - Sets [deletedBy] to [actor].
  /// - Sets [deletedAt] to [timestamp] (UTC) or `DateTime.now().toUtc()`.
  /// - When [bumpVersion] is `true` (default), increments [version] as:
  ///   `(current.version ?? 0) + 1`.
  /// - When [bumpVersion] is `false`, preserves [current.version].
  ///
  /// This helper does not perform a hard delete; it only updates the metadata
  /// so that higher layers can decide how to handle soft-deleted records.
  ///
  /// Minimal runnable example:
  /// ```dart
  /// void main() {
  ///   final ModelCrudMetadata base = ModelCrudMetadata.initialize(
  ///     recordId: 'group-001',
  ///     actor: 'system@domain.com',
  ///   );
  ///
  ///   final ModelCrudMetadata deleted = ModelCrudMetadata.markDeleted(
  ///     current: base,
  ///     actor: 'admin@domain.com',
  ///   );
  ///
  ///   print(deleted.deleted);   // true
  ///   print(deleted.deletedBy); // admin@domain.com
  /// }
  /// ```
  static ModelCrudMetadata markDeleted({
    required ModelCrudMetadata current,
    required String actor,
    DateTime? timestamp,
    bool bumpVersion = true,
  }) {
    final DateTime t = (timestamp ?? DateTime.now()).toUtc();
    final int? newVersion =
        bumpVersion ? ((current.version ?? 0) + 1) : current.version;

    return current.copyWith(
      deleted: true,
      deletedBy: actor,
      deletedAt: t,
      version: newVersion,
    );
  }
}
