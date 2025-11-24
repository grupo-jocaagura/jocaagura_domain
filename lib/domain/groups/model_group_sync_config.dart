part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP SYNC CONFIG
/// ===========================================================================

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
class ModelGroupSyncConfig extends Model {
  const ModelGroupSyncConfig({
    required this.id,
    required this.groupId,
    required this.mode,
    required this.schedule,
    required this.strategy,
    required this.lastResult,
    required this.crud,
    this.courseId,
    this.sourceSheetId,
    this.sourceRange,
    this.lastRunAt,
    this.lastJobId,
    this.lastErrorItemId,
  });

  factory ModelGroupSyncConfig.fromJson(Map<String, dynamic> json) {
    return ModelGroupSyncConfig(
      id: json[ModelGroupSyncConfigEnum.id.name]?.toString() ?? '',
      groupId: json[ModelGroupSyncConfigEnum.groupId.name]?.toString() ?? '',
      mode: Utils.enumFromJson<ModelGroupSyncMode>(
        ModelGroupSyncMode.values,
        json[ModelGroupSyncConfigEnum.mode.name]?.toString(),
        ModelGroupSyncMode.manual,
      ),
      courseId: json[ModelGroupSyncConfigEnum.courseId.name]?.toString(),
      sourceSheetId:
          json[ModelGroupSyncConfigEnum.sourceSheetId.name]?.toString(),
      sourceRange: json[ModelGroupSyncConfigEnum.sourceRange.name]?.toString(),
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
      lastJobId: json[ModelGroupSyncConfigEnum.lastJobId.name]?.toString(),
      lastErrorItemId:
          json[ModelGroupSyncConfigEnum.lastErrorItemId.name]?.toString(),
      crud: ModelCrudMetadata.fromJson(
        Utils.mapFromDynamic(json[ModelGroupSyncConfigEnum.crud.name]),
      ),
    );
  }

  final String id;
  final String groupId;
  final ModelGroupSyncMode mode;
  final String? courseId;
  final String? sourceSheetId;
  final String? sourceRange;
  final ModelGroupSyncSchedule schedule;
  final ModelGroupSyncStrategy strategy;
  final ModelGroupSyncLastResult lastResult;
  final DateTime? lastRunAt;
  final String? lastJobId;
  final String? lastErrorItemId;
  final ModelCrudMetadata crud;

  @override
  ModelGroupSyncConfig copyWith({
    String? id,
    String? groupId,
    ModelGroupSyncMode? mode,
    String? courseId,
    bool? Function()? courseIdOverrideNull,
    String? sourceSheetId,
    bool? Function()? sourceSheetIdOverrideNull,
    String? sourceRange,
    bool? Function()? sourceRangeOverrideNull,
    ModelGroupSyncSchedule? schedule,
    ModelGroupSyncStrategy? strategy,
    ModelGroupSyncLastResult? lastResult,
    DateTime? lastRunAt,
    bool? Function()? lastRunAtOverrideNull,
    String? lastJobId,
    bool? Function()? lastJobIdOverrideNull,
    String? lastErrorItemId,
    bool? Function()? lastErrorItemIdOverrideNull,
    ModelCrudMetadata? crud,
  }) {
    return ModelGroupSyncConfig(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      mode: mode ?? this.mode,
      courseId: courseIdOverrideNull != null ? null : courseId ?? this.courseId,
      sourceSheetId: sourceSheetIdOverrideNull != null
          ? null
          : sourceSheetId ?? this.sourceSheetId,
      sourceRange: sourceRangeOverrideNull != null
          ? null
          : sourceRange ?? this.sourceRange,
      schedule: schedule ?? this.schedule,
      strategy: strategy ?? this.strategy,
      lastResult: lastResult ?? this.lastResult,
      lastRunAt:
          lastRunAtOverrideNull != null ? null : lastRunAt ?? this.lastRunAt,
      lastJobId:
          lastJobIdOverrideNull != null ? null : lastJobId ?? this.lastJobId,
      lastErrorItemId: lastErrorItemIdOverrideNull != null
          ? null
          : lastErrorItemId ?? this.lastErrorItemId,
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
    if (courseId != null) {
      json[ModelGroupSyncConfigEnum.courseId.name] = courseId;
    }
    if (sourceSheetId != null) {
      json[ModelGroupSyncConfigEnum.sourceSheetId.name] = sourceSheetId;
    }
    if (sourceRange != null) {
      json[ModelGroupSyncConfigEnum.sourceRange.name] = sourceRange;
    }
    if (lastRunAt != null) {
      json[ModelGroupSyncConfigEnum.lastRunAt.name] =
          DateUtils.dateTimeToString(lastRunAt!);
    }
    if (lastJobId != null) {
      json[ModelGroupSyncConfigEnum.lastJobId.name] = lastJobId;
    }
    if (lastErrorItemId != null) {
      json[ModelGroupSyncConfigEnum.lastErrorItemId.name] = lastErrorItemId;
    }
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
