part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP SYNC JOB
/// ===========================================================================
/// JSON keys for [ModelGroupSyncJob].
///
/// This enum centralizes the string keys used for serialization and parsing,
/// avoiding magic strings across the codebase.
///
/// Example:
/// ```dart
/// void main() {
///   print(ModelGroupSyncJobEnum.directoryApiCalls.name); // "directoryApiCalls"
/// }
/// ```
enum ModelGroupSyncJobEnum {
  id,
  groupId,
  source,
  type,
  status,
  startedAt,
  finishedAt,
  addedCount,
  removedCount,
  updatedCount,
  directoryApiCalls,
  groupSettingsApiCalls,
  errorItemId,
  createdBy,
}

/// Represents a single execution of a sync job.
///
/// Each instance tracks one concrete run of a group-membership sync process,
/// including:
/// - Input origin ([source])
/// - Sync [type] and current [status]
/// - Timestamps ([startedAt], optional [finishedAt])
/// - Counters for membership changes ([addedCount], [removedCount],
///   [updatedCount])
/// - API usage metrics ([directoryApiCalls], [groupSettingsApiCalls])
/// - Optional linkage to an error catalog ([errorItemId])
/// - Optional actor that triggered the job ([createdBy])
///
/// JSON contract:
/// - Required fields:
///   - `id` (string)
///   - `groupId` (string)
///   - `source` (string; [ModelGroupSyncJobSource.name])
///   - `type` (string; [ModelGroupSyncJobType.name])
///   - `status` (string; [ModelGroupSyncJobStatus.name])
///   - `startedAt` (string; ISO 8601, parsed via
///     [DateUtils.dateTimeFromDynamic])
///   - `addedCount` (int)
///   - `removedCount` (int)
///   - `updatedCount` (int)
///   - `directoryApiCalls` (int)
///   - `groupSettingsApiCalls` (int)
/// - Optional fields:
///   - `finishedAt` (string; ISO 8601) – omitted when `null`.
///   - `errorItemId` (string) – always serialized (may be empty).
///   - `createdBy` (string) – always serialized (may be empty).
///
/// Parsing rules:
/// - Enums are resolved via [Utils.enumFromJson] with these fallbacks on
///   missing/unknown values:
///   - [ModelGroupSyncJobSource.manual]
///   - [ModelGroupSyncJobType.full]
///   - [ModelGroupSyncJobStatus.running]
/// - Counts and API metrics use [Utils.getIntegerFromDynamic] and default to
///   `0` on invalid/null input.
/// - [errorItemId] and [createdBy] are obtained via
///   [Utils.getStringFromDynamic], so they never become `null`.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final DateTime started = DateTime.utc(2025, 1, 1, 10, 0, 0);
///   final DateTime finished = DateTime.utc(2025, 1, 1, 10, 5, 0);
///
///   final ModelGroupSyncJob job = ModelGroupSyncJob(
///     id: 'job-1',
///     groupId: 'group-001',
///     source: ModelGroupSyncJobSource.sheet,
///     type: ModelGroupSyncJobType.full,
///     status: ModelGroupSyncJobStatus.ok,
///     startedAt: started,
///     finishedAt: finished,
///     addedCount: 10,
///     removedCount: 2,
///     updatedCount: 3,
///     directoryApiCalls: 5,
///     groupSettingsApiCalls: 1,
///     errorItemId: '',
///     createdBy: 'system@domain.com',
///   );
///
///   final Map<String, dynamic> json = job.toJson();
///   final ModelGroupSyncJob roundtrip = ModelGroupSyncJob.fromJson(json);
///
///   print(roundtrip.status);      // ModelGroupSyncJobStatus.ok
///   print(roundtrip.addedCount);  // 10
/// }
/// ```
class ModelGroupSyncJob extends Model {
  const ModelGroupSyncJob({
    required this.id,
    required this.groupId,
    required this.source,
    required this.type,
    required this.status,
    required this.startedAt,
    required this.addedCount,
    required this.removedCount,
    required this.updatedCount,
    required this.directoryApiCalls,
    required this.groupSettingsApiCalls,
    this.finishedAt,
    this.errorItemId = '',
    this.createdBy = '',
  });

  /// Creates a [ModelGroupSyncJob] from a JSON-like map.
  ///
  /// Extra keys are ignored safely.
  factory ModelGroupSyncJob.fromJson(Map<String, dynamic> json) {
    return ModelGroupSyncJob(
      id: json[ModelGroupSyncJobEnum.id.name]?.toString() ?? '',
      groupId: json[ModelGroupSyncJobEnum.groupId.name]?.toString() ?? '',
      source: Utils.enumFromJson<ModelGroupSyncJobSource>(
        ModelGroupSyncJobSource.values,
        json[ModelGroupSyncJobEnum.source.name]?.toString(),
        ModelGroupSyncJobSource.manual,
      ),
      type: Utils.enumFromJson<ModelGroupSyncJobType>(
        ModelGroupSyncJobType.values,
        json[ModelGroupSyncJobEnum.type.name]?.toString(),
        ModelGroupSyncJobType.full,
      ),
      status: Utils.enumFromJson<ModelGroupSyncJobStatus>(
        ModelGroupSyncJobStatus.values,
        json[ModelGroupSyncJobEnum.status.name]?.toString(),
        ModelGroupSyncJobStatus.running,
      ),
      startedAt: DateUtils.dateTimeFromDynamic(
        json[ModelGroupSyncJobEnum.startedAt.name],
      ),
      finishedAt: json[ModelGroupSyncJobEnum.finishedAt.name] == null
          ? null
          : DateUtils.dateTimeFromDynamic(
              json[ModelGroupSyncJobEnum.finishedAt.name],
            ),
      addedCount: Utils.getIntegerFromDynamic(
        json[ModelGroupSyncJobEnum.addedCount.name],
      ),
      removedCount: Utils.getIntegerFromDynamic(
        json[ModelGroupSyncJobEnum.removedCount.name],
      ),
      updatedCount: Utils.getIntegerFromDynamic(
        json[ModelGroupSyncJobEnum.updatedCount.name],
      ),
      directoryApiCalls: Utils.getIntegerFromDynamic(
        json[ModelGroupSyncJobEnum.directoryApiCalls.name],
      ),
      groupSettingsApiCalls: Utils.getIntegerFromDynamic(
        json[ModelGroupSyncJobEnum.groupSettingsApiCalls.name],
      ),
      errorItemId: Utils.getStringFromDynamic(
        json[ModelGroupSyncJobEnum.errorItemId.name],
      ),
      createdBy: Utils.getStringFromDynamic(
        json[ModelGroupSyncJobEnum.createdBy.name],
      ),
    );
  }

  final String id;
  final String groupId;
  final ModelGroupSyncJobSource source;
  final ModelGroupSyncJobType type;
  final ModelGroupSyncJobStatus status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int addedCount;
  final int removedCount;
  final int updatedCount;
  final int directoryApiCalls;
  final int groupSettingsApiCalls;
  final String errorItemId;
  final String createdBy;

  @override
  ModelGroupSyncJob copyWith({
    String? id,
    String? groupId,
    ModelGroupSyncJobSource? source,
    ModelGroupSyncJobType? type,
    ModelGroupSyncJobStatus? status,
    DateTime? startedAt,
    DateTime? finishedAt,
    bool? Function()? finishedAtOverrideNull,
    int? addedCount,
    int? removedCount,
    int? updatedCount,
    int? directoryApiCalls,
    int? groupSettingsApiCalls,
    String? errorItemId,
    String? createdBy,
  }) {
    return ModelGroupSyncJob(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      source: source ?? this.source,
      type: type ?? this.type,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt:
          finishedAtOverrideNull != null ? null : finishedAt ?? this.finishedAt,
      addedCount: addedCount ?? this.addedCount,
      removedCount: removedCount ?? this.removedCount,
      updatedCount: updatedCount ?? this.updatedCount,
      directoryApiCalls: directoryApiCalls ?? this.directoryApiCalls,
      groupSettingsApiCalls:
          groupSettingsApiCalls ?? this.groupSettingsApiCalls,
      errorItemId: errorItemId ?? this.errorItemId,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelGroupSyncJobEnum.id.name: id,
      ModelGroupSyncJobEnum.groupId.name: groupId,
      ModelGroupSyncJobEnum.source.name: source.name,
      ModelGroupSyncJobEnum.type.name: type.name,
      ModelGroupSyncJobEnum.status.name: status.name,
      ModelGroupSyncJobEnum.startedAt.name:
          DateUtils.dateTimeToString(startedAt),
      ModelGroupSyncJobEnum.addedCount.name: addedCount,
      ModelGroupSyncJobEnum.removedCount.name: removedCount,
      ModelGroupSyncJobEnum.updatedCount.name: updatedCount,
      ModelGroupSyncJobEnum.directoryApiCalls.name: directoryApiCalls,
      ModelGroupSyncJobEnum.groupSettingsApiCalls.name: groupSettingsApiCalls,
    };
    if (finishedAt != null) {
      json[ModelGroupSyncJobEnum.finishedAt.name] =
          DateUtils.dateTimeToString(finishedAt!);
    }
    json[ModelGroupSyncJobEnum.errorItemId.name] = errorItemId;
    json[ModelGroupSyncJobEnum.createdBy.name] = createdBy;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroupSyncJob &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          source == other.source &&
          type == other.type &&
          status == other.status &&
          startedAt == other.startedAt &&
          finishedAt == other.finishedAt &&
          addedCount == other.addedCount &&
          removedCount == other.removedCount &&
          updatedCount == other.updatedCount &&
          directoryApiCalls == other.directoryApiCalls &&
          groupSettingsApiCalls == other.groupSettingsApiCalls &&
          errorItemId == other.errorItemId &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
        id,
        groupId,
        source,
        type,
        status,
        startedAt,
        finishedAt,
        addedCount,
        removedCount,
        updatedCount,
        directoryApiCalls,
        groupSettingsApiCalls,
        errorItemId,
        createdBy,
      );

  @override
  String toString() => 'ModelGroupSyncJob(${toJson()})';
}
