part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// CRUD LOG ENTRY
/// ===========================================================================

/// Operation kind for a CRUD log entry.
enum ModelCrudOperationKind {
  create,
  update,
  delete,
}

/// JSON keys for [ModelCrudLogEntry].
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
/// Example:
/// ```dart
/// final ModelCrudLogEntry entry = ModelCrudLogEntry.fromJson({
///   'id': 'log-1',
///   'entityType': 'Group',
///   'entityId': 'group-001',
///   'operation': 'create',
///   'performedBy': 'admin@domain.com',
///   'performedAt': '2025-01-01T10:00:00Z',
/// });
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
