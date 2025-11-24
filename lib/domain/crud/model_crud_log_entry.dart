part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// CRUD LOG ENTRY
/// ===========================================================================

/// Operation kind for a CRUD log entry.
///
/// Represents the type of change that was performed on a domain entity.
/// Values are serialized using the enum [name] into JSON.
///
/// JSON contract:
/// - Stored as a lowercase string (e.g. `"create"`, `"update"`, `"delete"`).
/// - Parsed back using [Utils.enumFromJson], defaulting to [ModelCrudOperationKind.create]
///   when the value is missing or unknown.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final ModelCrudOperationKind op = ModelCrudOperationKind.update;
///   print(op.name); // "update"
/// }
/// ```
enum ModelCrudOperationKind {
  create,
  update,
  delete,
}

/// JSON keys for [ModelCrudLogEntry].
///
/// This enum centralizes the field names used when serializing and parsing
/// `ModelCrudLogEntry` instances to/from JSON-like maps. Using [name] avoids
/// hard-coded strings spread across the codebase.
///
/// Example:
/// ```dart
/// void main() {
///   print(ModelCrudLogEntryEnum.performedAt.name); // "performedAt"
/// }
/// ```
enum ModelCrudLogEntryEnum {
  id,
  entityType,
  entityId,
  operation,
  performedBy,
  performedAt,
  diff,
  env,
  errorItemId,
}

/// Immutable log entry representing a CRUD operation on any entity.
///
/// Each instance models a single audited change in the system, including:
/// - which entity was affected,
/// - which operation was performed,
/// - who performed it,
/// - when it happened,
/// - and an optional `diff` payload with additional metadata.
///
/// JSON contract:
/// - Required fields:
///   - `id` (string)
///   - `entityType` (string)
///   - `entityId` (string)
///   - `operation` (string; matches [ModelCrudOperationKind.name])
///   - `performedBy` (string)
///   - `performedAt` (string; parsed by [DateUtils.dateTimeFromDynamic])
/// - Optional fields:
///   - `diff` (object; stored as `Map<String, dynamic>`)
///   - `env` (string)
///   - `errorItemId` (string)
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final ModelCrudLogEntry original = ModelCrudLogEntry(
///     id: 'log-1',
///     entityType: 'Group',
///     entityId: 'group-001',
///     operation: ModelCrudOperationKind.create,
///     performedBy: 'admin@domain.com',
///     performedAt: DateTime.utc(2025, 1, 1, 10, 0, 0),
///     diff: <String, dynamic>{'field': 'value'},
///     env: 'dev',
///     errorItemId: 'ERR-123',
///   );
///
///   final Map<String, dynamic> json = original.toJson();
///   final ModelCrudLogEntry roundtrip = ModelCrudLogEntry.fromJson(json);
///
///   print(roundtrip == original); // true (roundtrip-safe)
/// }
/// ```
class ModelCrudLogEntry extends Model {
  const ModelCrudLogEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.performedBy,
    required this.performedAt,
    this.diff,
    this.env,
    this.errorItemId,
  });

  /// Creates a [ModelCrudLogEntry] from a JSON-like map.
  ///
  /// Parsing rules:
  /// - Scalar fields are read using [toString] and default to `''` when missing.
  /// - [operation] is resolved using [Utils.enumFromJson] with
  ///   [ModelCrudOperationKind.create] as fallback.
  /// - [performedAt] is parsed using [DateUtils.dateTimeFromDynamic].
  /// - [diff] is normalized with [Utils.mapFromDynamic] when present.
  ///
  /// Unknown or extra keys in [json] are safely ignored.
  factory ModelCrudLogEntry.fromJson(Map<String, dynamic> json) {
    return ModelCrudLogEntry(
      id: json[ModelCrudLogEntryEnum.id.name]?.toString() ?? '',
      entityType: json[ModelCrudLogEntryEnum.entityType.name]?.toString() ?? '',
      entityId: json[ModelCrudLogEntryEnum.entityId.name]?.toString() ?? '',
      operation: Utils.enumFromJson<ModelCrudOperationKind>(
        ModelCrudOperationKind.values,
        json[ModelCrudLogEntryEnum.operation.name]?.toString(),
        ModelCrudOperationKind.create,
      ),
      performedBy:
          json[ModelCrudLogEntryEnum.performedBy.name]?.toString() ?? '',
      performedAt: DateUtils.dateTimeFromDynamic(
        json[ModelCrudLogEntryEnum.performedAt.name],
      ),
      diff: json[ModelCrudLogEntryEnum.diff.name] == null
          ? null
          : Utils.mapFromDynamic(
              json[ModelCrudLogEntryEnum.diff.name],
            ).cast<String, dynamic>(),
      env: json[ModelCrudLogEntryEnum.env.name]?.toString(),
      errorItemId: json[ModelCrudLogEntryEnum.errorItemId.name]?.toString(),
    );
  }

  final String id;
  final String entityType;
  final String entityId;
  final ModelCrudOperationKind operation;
  final String performedBy;
  final DateTime performedAt;
  final Map<String, dynamic>? diff;
  final String? env;
  final String? errorItemId;

  @override
  ModelCrudLogEntry copyWith({
    String? id,
    String? entityType,
    String? entityId,
    ModelCrudOperationKind? operation,
    String? performedBy,
    DateTime? performedAt,
    Map<String, dynamic>? diff,
    bool? Function()? diffOverrideNull,
    String? env,
    String? errorItemId,
  }) {
    return ModelCrudLogEntry(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      performedBy: performedBy ?? this.performedBy,
      performedAt: performedAt ?? this.performedAt,
      diff: diffOverrideNull != null ? null : diff ?? this.diff,
      env: env ?? this.env,
      errorItemId: errorItemId ?? this.errorItemId,
    );
  }

  /// Serializes this entry into a JSON-like map.
  ///
  /// Only non-null optional fields are included (`diff`, `env`, `errorItemId`),
  /// keeping the payload compact and friendly for storage in logs.
  ///
  /// [performedAt] is converted to string using [DateUtils.dateTimeToString].
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelCrudLogEntryEnum.id.name: id,
      ModelCrudLogEntryEnum.entityType.name: entityType,
      ModelCrudLogEntryEnum.entityId.name: entityId,
      ModelCrudLogEntryEnum.operation.name: operation.name,
      ModelCrudLogEntryEnum.performedBy.name: performedBy,
      ModelCrudLogEntryEnum.performedAt.name:
          DateUtils.dateTimeToString(performedAt),
    };
    if (diff != null) {
      json[ModelCrudLogEntryEnum.diff.name] = diff;
    }
    if (env != null) {
      json[ModelCrudLogEntryEnum.env.name] = env;
    }
    if (errorItemId != null) {
      json[ModelCrudLogEntryEnum.errorItemId.name] = errorItemId;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelCrudLogEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          entityType == other.entityType &&
          entityId == other.entityId &&
          operation == other.operation &&
          performedBy == other.performedBy &&
          performedAt == other.performedAt &&
          diff == other.diff &&
          env == other.env &&
          errorItemId == other.errorItemId;

  @override
  int get hashCode => Object.hash(
        id,
        entityType,
        entityId,
        operation,
        performedBy,
        performedAt,
        diff,
        env,
        errorItemId,
      );

  @override
  String toString() => 'ModelCrudLogEntry(${toJson()})';
}
