part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUPS – ENUMS
/// ===========================================================================

/// Lifecycle state for a [ModelGroup].
///
/// JSON contract:
/// - Stored as a lowercase string using [name], e.g. `"active"`, `"archived"`,
///   `"deleted"`.
/// - Parsed via [Utils.enumFromJson], falling back to [ModelGroupState.active]
///   when the value is missing or unknown.
enum ModelGroupState {
  active,
  archived,
  deleted,
}

enum ModelGroupPillar {
  education,
  logistics,
  commerce,
  shared,
}

enum ModelGroupKind {
  course,
  family,
  cohort,
  project,
  team,
  warehouse,
  deliveryRoute,
  store,
  service,
  other,
}

enum ModelGroupAliasStatus {
  active,
  pending,
  error,
}

enum ModelGroupConfigApiSource {
  directory,
  cloudIdentity,
  mixed,
}

enum ModelGroupConfigLastSyncStatus {
  never,
  ok,
  error,
}

enum ModelGroupDynamicMembershipRuleStatus {
  active,
  draft,
  disabled,
}

enum ModelGroupMemberRole {
  owner,
  moderator,
  member,
  readOnly,
}

enum ModelGroupMemberEntityType {
  user,
  group,
  serviceAccount,
}

enum ModelGroupMemberSource {
  manual,
  fromCourse,
  fromSheet,
  syncJob,
}

enum ModelGroupMemberSubscription {
  allMail,
  digest,
  abridged,
  noEmail,
}

enum ModelGroupSyncMode {
  manual,
  fromCourse,
  fromSheet,
  mixed,
}

enum ModelGroupSyncSchedule {
  onDemand,
  hourly,
  daily,
  weekly,
}

enum ModelGroupSyncStrategy {
  fullReplace,
  merge,
  onlyAdd,
  onlyRemove,
}

enum ModelGroupSyncLastResult {
  never,
  ok,
  partialError,
  error,
}

enum ModelGroupSyncJobSource {
  course,
  sheet,
  manual,
  bulkImport,
}

enum ModelGroupSyncJobType {
  full,
  incremental,
}

enum ModelGroupSyncJobStatus {
  running,
  ok,
  error,
}

/// ===========================================================================
/// GROUP
/// ===========================================================================
/// JSON keys for [ModelGroup].
///
/// This enum centralizes the string keys used on serialization and parsing,
/// avoiding magic strings spread across the codebase.
///
/// Example:
/// ```dart
/// void main() {
///   print(ModelGroupEnum.driveFolderId.name); // "driveFolderId"
/// }
/// ```
enum ModelGroupEnum {
  id,
  name,
  description,
  email,
  labels,
  state,
  courseId,
  projectId,
  driveFolderId,
  crud,
}

/// Logical group in the Bienvenido domain.
///
/// A group represents a logical container of people or resources such as:
/// classes, families, teams, cohorts, projects or stores. It is always
/// associated with audit metadata ([crud]) describing when and by whom it was
/// created/updated.
///
/// JSON contract:
/// - Required fields (always present in the JSON payload):
///   - `id` (string)
///   - `name` (string)
///   - `state` (string; [ModelGroupState.name])
///   - `crud` (object; [ModelCrudMetadata.toJson])
/// - String fields that are always serialized but may be the empty string (`''`)
///   when not set:
///   - `description` (string, defaults to `''`)
///   - `email` (string, defaults to `''`)
///   - `courseId` (string, defaults to `''`)
///   - `projectId` (string, defaults to `''`)
///   - `driveFolderId` (string, defaults to `''`)
/// - Optional object field:
///   - `labels` (object; [ModelGroupLabels.toJson]) – omitted when `null`.
///
/// Parsing rules:
/// - Missing or `null` values for the string fields above are normalized to
///   `''` via [Utils.getStringFromDynamic].
/// - `state` is parsed using [Utils.enumFromJson], defaulting to
///   [ModelGroupState.active] when the value is missing or unknown.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final DateTime now = DateTime.utc(2025, 1, 1, 10, 0, 0);
///
///   final ModelCrudMetadata crud = ModelCrudMetadata(
///     recordId: 'group-001',
///     createdBy: 'system@domain.com',
///     createdAt: now,
///     updatedBy: 'system@domain.com',
///     updatedAt: now,
///     version: 1,
///   );
///
///   final ModelGroup group = ModelGroup(
///     id: 'group-001',
///     name: '5A Matemáticas 2025',
///     state: ModelGroupState.active,
///     crud: crud,
///   );
///
///   final Map<String, dynamic> json = group.toJson();
///   final ModelGroup roundtrip = ModelGroup.fromJson(json);
///
///   print(roundtrip.id);          // group-001
///   print(roundtrip.description); // '' (empty string by default)
///   print(roundtrip.state);       // ModelGroupState.active
/// }
/// ```
class ModelGroup extends Model {
  const ModelGroup({
    required this.id,
    required this.name,
    required this.state,
    required this.crud,
    this.description = '',
    this.email = '',
    this.labels,
    this.courseId = '',
    this.projectId = '',
    this.driveFolderId = '',
  });

  /// Creates a [ModelGroup] from a JSON-like map.
  ///
  /// Parsing rules:
  /// - Required scalar fields (`id`, `name`) fall back to `''` when missing.
  /// - [state] is resolved with [Utils.enumFromJson] and defaults to
  ///   [ModelGroupState.active].
  /// - [labels], when present, is normalized with [Utils.mapFromDynamic] and
  ///   passed to [ModelGroupLabels.fromJson].
  /// - [crud] is mandatory and must contain a valid [ModelCrudMetadata] payload.
  ///
  /// Extra keys are ignored safely.
  factory ModelGroup.fromJson(Map<String, dynamic> json) {
    return ModelGroup(
      id: json[ModelGroupEnum.id.name]?.toString() ?? '',
      name: json[ModelGroupEnum.name.name]?.toString() ?? '',
      description:
          Utils.getStringFromDynamic(json[ModelGroupEnum.description.name]),
      email: Utils.getStringFromDynamic(json[ModelGroupEnum.email.name]),
      labels: json[ModelGroupEnum.labels.name] == null
          ? null
          : ModelGroupLabels.fromJson(
              Utils.mapFromDynamic(
                json[ModelGroupEnum.labels.name],
              ),
            ),
      state: Utils.enumFromJson<ModelGroupState>(
        ModelGroupState.values,
        json[ModelGroupEnum.state.name]?.toString(),
        ModelGroupState.active,
      ),
      courseId: Utils.getStringFromDynamic(json[ModelGroupEnum.courseId.name]),
      projectId:
          Utils.getStringFromDynamic(json[ModelGroupEnum.projectId.name]),
      driveFolderId:
          Utils.getStringFromDynamic(json[ModelGroupEnum.driveFolderId.name]),
      crud: ModelCrudMetadata.fromJson(
        Utils.mapFromDynamic(json[ModelGroupEnum.crud.name]),
      ),
    );
  }

  final String id;
  final String name;
  final String description;
  final String email;
  final ModelGroupLabels? labels;
  final ModelGroupState state;
  final String courseId;
  final String projectId;
  final String driveFolderId;
  final ModelCrudMetadata crud;

  @override
  ModelGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? email,
    ModelGroupLabels? labels,
    ModelGroupState? state,
    String? courseId,
    String? projectId,
    String? driveFolderId,
    ModelCrudMetadata? crud,
  }) {
    return ModelGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      email: email ?? this.email,
      labels: labels ?? this.labels,
      state: state ?? this.state,
      courseId: courseId ?? this.courseId,
      projectId: projectId ?? this.projectId,
      driveFolderId: driveFolderId ?? this.driveFolderId,
      crud: crud ?? this.crud,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelGroupEnum.id.name: id,
      ModelGroupEnum.name.name: name,
      ModelGroupEnum.state.name: state.name,
      ModelGroupEnum.crud.name: crud.toJson(),
    };
    json[ModelGroupEnum.description.name] = description;
    json[ModelGroupEnum.email.name] = email;
    if (labels != null) {
      json[ModelGroupEnum.labels.name] = labels!.toJson();
    }
    json[ModelGroupEnum.courseId.name] = courseId;
    json[ModelGroupEnum.projectId.name] = projectId;
    json[ModelGroupEnum.driveFolderId.name] = driveFolderId;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroup &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          email == other.email &&
          labels == other.labels &&
          state == other.state &&
          courseId == other.courseId &&
          projectId == other.projectId &&
          driveFolderId == other.driveFolderId &&
          crud == other.crud;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        email,
        labels,
        state,
        courseId,
        projectId,
        driveFolderId,
        crud,
      );

  @override
  String toString() => 'ModelGroup(${toJson()})';
}
