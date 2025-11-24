part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP SYNC CONFIG
/// ===========================================================================
/// JSON keys for [ModelGroupSyncConfig].
///
/// This enum centralizes the string keys used for serialization and parsing,
/// avoiding magic strings across the codebase.
///
/// Example:
/// ```dart
/// void main() {
///   print(ModelGroupSyncConfigEnum.sourceSheetId.name); // "sourceSheetId"
/// }
/// ```
enum ModelGroupSyncConfigEnum {
  id,
  groupId,
  mode,
  courseId,
  sourceSheetId,
  sourceRange,
  schedule,
  strategy,
  lastResult,
  lastRunAt,
  lastJobId,
  lastErrorItemId,
  crud,
}

/// Sync configuration for a group.
///
/// This model defines how a [ModelGroup] is synchronized from an external
/// source (course, sheet, manual, etc.) and how the last sync execution
/// behaved.
///
/// JSON contract:
/// - Required fields:
///   - `id` (string)
///   - `groupId` (string)
///   - `mode` (string; [ModelGroupSyncMode.name])
///   - `schedule` (string; [ModelGroupSyncSchedule.name])
///   - `strategy` (string; [ModelGroupSyncStrategy.name])
///   - `lastResult` (string; [ModelGroupSyncLastResult.name])
///   - `crud` (object; [ModelCrudMetadata.toJson])
/// - Optional fields (serialized as empty string when logically empty):
///   - `courseId` (string)
///   - `sourceSheetId` (string)
///   - `sourceRange` (string)
///   - `lastJobId` (string)
///   - `lastErrorItemId` (string)
/// - Optional field with nullability:
///   - `lastRunAt` (string; ISO 8601) – omitted when `null`.
///
/// Parsing rules:
/// - String fields use [Utils.getStringFromDynamic], ensuring non-null
///   values (default `''` when missing).
/// - Enum fields are resolved via [Utils.enumFromJson] with the following
///   fallbacks when the value is missing or unknown:
///   - [ModelGroupSyncMode.manual]
///   - [ModelGroupSyncSchedule.onDemand]
///   - [ModelGroupSyncStrategy.fullReplace]
///   - [ModelGroupSyncLastResult.never]
/// - [lastRunAt] is parsed with [DateUtils.dateTimeFromDynamic] when present,
///   otherwise it is `null`.
/// - [crud] must contain a valid [ModelCrudMetadata] payload.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final DateTime now = DateTime.utc(2025, 1, 1, 10, 0, 0);
///
///   final ModelCrudMetadata crud = ModelCrudMetadata(
///     recordId: 'sync-1',
///     createdBy: 'system@domain.com',
///     createdAt: now,
///     updatedBy: 'system@domain.com',
///     updatedAt: now,
///     version: 1,
///   );
///
///   final ModelGroupSyncConfig config = ModelGroupSyncConfig(
///     id: 'sync-1',
///     groupId: 'group-001',
///     mode: ModelGroupSyncMode.fromSheet,
///     courseId: '',
///     sourceSheetId: 'sheet-123',
///     sourceRange: 'A2:D999',
///     schedule: ModelGroupSyncSchedule.daily,
///     strategy: ModelGroupSyncStrategy.fullReplace,
///     lastResult: ModelGroupSyncLastResult.ok,
///     lastRunAt: now,
///     lastJobId: 'job-987',
///     lastErrorItemId: '',
///     crud: crud,
///   );
///
///   final Map<String, dynamic> json = config.toJson();
///   final ModelGroupSyncConfig roundtrip = ModelGroupSyncConfig.fromJson(json);
///
///   print(roundtrip.mode);       // ModelGroupSyncMode.fromSheet
///   print(roundtrip.lastResult); // ModelGroupSyncLastResult.ok
/// }
/// ```
class ModelGroupSyncConfig extends Model {
  const ModelGroupSyncConfig({
    required this.id,
    required this.groupId,
    required this.mode,
    required this.schedule,
    required this.strategy,
    required this.lastResult,
    required this.crud,
    this.courseId = '',
    this.sourceSheetId = '',
    this.sourceRange = '',
    this.lastRunAt,
    this.lastJobId = '',
    this.lastErrorItemId = '',
  });

  /// Creates a [ModelGroupSyncConfig] from a JSON-like map.
  ///
  /// Extra keys are ignored safely.
  factory ModelGroupSyncConfig.fromJson(Map<String, dynamic> json) {
    return ModelGroupSyncConfig(
      id: json[ModelGroupSyncConfigEnum.id.name]?.toString() ?? '',
      groupId: json[ModelGroupSyncConfigEnum.groupId.name]?.toString() ?? '',
      mode: Utils.enumFromJson<ModelGroupSyncMode>(
        ModelGroupSyncMode.values,
        json[ModelGroupSyncConfigEnum.mode.name]?.toString(),
        ModelGroupSyncMode.manual,
      ),
      courseId: Utils.getStringFromDynamic(
        json[ModelGroupSyncConfigEnum.courseId.name],
      ),
      sourceSheetId: Utils.getStringFromDynamic(
        json[ModelGroupSyncConfigEnum.sourceSheetId.name],
      ),
      sourceRange: Utils.getStringFromDynamic(
        json[ModelGroupSyncConfigEnum.sourceRange.name],
      ),
      schedule: Utils.enumFromJson<ModelGroupSyncSchedule>(
        ModelGroupSyncSchedule.values,
        json[ModelGroupSyncConfigEnum.schedule.name]?.toString(),
        ModelGroupSyncSchedule.onDemand,
      ),
      strategy: Utils.enumFromJson<ModelGroupSyncStrategy>(
        ModelGroupSyncStrategy.values,
        json[ModelGroupSyncConfigEnum.strategy.name]?.toString(),
        ModelGroupSyncStrategy.fullReplace,
      ),
      lastResult: Utils.enumFromJson<ModelGroupSyncLastResult>(
        ModelGroupSyncLastResult.values,
        json[ModelGroupSyncConfigEnum.lastResult.name]?.toString(),
        ModelGroupSyncLastResult.never,
      ),
      lastRunAt: json[ModelGroupSyncConfigEnum.lastRunAt.name] == null
          ? null
          : DateUtils.dateTimeFromDynamic(
              json[ModelGroupSyncConfigEnum.lastRunAt.name],
            ),
      lastJobId: Utils.getStringFromDynamic(
        json[ModelGroupSyncConfigEnum.lastJobId.name],
      ),
      lastErrorItemId: Utils.getStringFromDynamic(
        json[ModelGroupSyncConfigEnum.lastErrorItemId.name],
      ),
      crud: ModelCrudMetadata.fromJson(
        Utils.mapFromDynamic(json[ModelGroupSyncConfigEnum.crud.name]),
      ),
    );
  }

  final String id;
  final String groupId;
  final ModelGroupSyncMode mode;
  final String courseId;
  final String sourceSheetId;
  final String sourceRange;
  final ModelGroupSyncSchedule schedule;
  final ModelGroupSyncStrategy strategy;
  final ModelGroupSyncLastResult lastResult;
  final DateTime? lastRunAt;
  final String lastJobId;
  final String lastErrorItemId;
  final ModelCrudMetadata crud;

  @override
  ModelGroupSyncConfig copyWith({
    String? id,
    String? groupId,
    ModelGroupSyncMode? mode,
    String? courseId,
    String? sourceSheetId,
    String? sourceRange,
    ModelGroupSyncSchedule? schedule,
    ModelGroupSyncStrategy? strategy,
    ModelGroupSyncLastResult? lastResult,
    DateTime? lastRunAt,
    String? lastJobId,
    String? lastErrorItemId,
    ModelCrudMetadata? crud,
  }) {
    return ModelGroupSyncConfig(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      mode: mode ?? this.mode,
      courseId: courseId ?? this.courseId,
      sourceSheetId: sourceSheetId ?? this.sourceSheetId,
      sourceRange: sourceRange ?? this.sourceRange,
      schedule: schedule ?? this.schedule,
      strategy: strategy ?? this.strategy,
      lastResult: lastResult ?? this.lastResult,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      lastJobId: lastJobId ?? this.lastJobId,
      lastErrorItemId: lastErrorItemId ?? this.lastErrorItemId,
      crud: crud ?? this.crud,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelGroupSyncConfigEnum.id.name: id,
      ModelGroupSyncConfigEnum.groupId.name: groupId,
      ModelGroupSyncConfigEnum.mode.name: mode.name,
      ModelGroupSyncConfigEnum.schedule.name: schedule.name,
      ModelGroupSyncConfigEnum.strategy.name: strategy.name,
      ModelGroupSyncConfigEnum.lastResult.name: lastResult.name,
      ModelGroupSyncConfigEnum.crud.name: crud.toJson(),
    };
    json[ModelGroupSyncConfigEnum.courseId.name] = courseId;
    json[ModelGroupSyncConfigEnum.sourceSheetId.name] = sourceSheetId;
    json[ModelGroupSyncConfigEnum.sourceRange.name] = sourceRange;
    if (lastRunAt != null) {
      json[ModelGroupSyncConfigEnum.lastRunAt.name] =
          DateUtils.dateTimeToString(lastRunAt!);
    }
    json[ModelGroupSyncConfigEnum.lastJobId.name] = lastJobId;
    json[ModelGroupSyncConfigEnum.lastErrorItemId.name] = lastErrorItemId;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroupSyncConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          mode == other.mode &&
          courseId == other.courseId &&
          sourceSheetId == other.sourceSheetId &&
          sourceRange == other.sourceRange &&
          schedule == other.schedule &&
          strategy == other.strategy &&
          lastResult == other.lastResult &&
          lastRunAt == other.lastRunAt &&
          lastJobId == other.lastJobId &&
          lastErrorItemId == other.lastErrorItemId &&
          crud == other.crud;

  @override
  int get hashCode => Object.hash(
        id,
        groupId,
        mode,
        courseId,
        sourceSheetId,
        sourceRange,
        schedule,
        strategy,
        lastResult,
        lastRunAt,
        lastJobId,
        lastErrorItemId,
        crud,
      );

  @override
  String toString() => 'ModelGroupSyncConfig(${toJson()})';
}
