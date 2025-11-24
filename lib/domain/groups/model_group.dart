part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUPS – ENUMS
/// ===========================================================================

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

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null || a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// ===========================================================================
/// GROUP
/// ===========================================================================

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
/// Example:
/// ```dart
/// final ModelGroup group = ModelGroup.fromJson({
///   'id': 'group-001',
///   'name': '5A Matemáticas 2025',
///   'state': 'active',
///   'crud': {
///     'recordId': 'group-001',
///     'createdBy': 'system',
///     'createdAt': '2025-01-01T10:00:00Z',
///     'updatedBy': 'system',
///     'updatedAt': '2025-01-01T10:00:00Z',
///   },
/// });
/// ```
class ModelGroup extends Model {
  const ModelGroup({
    required this.id,
    required this.name,
    required this.state,
    required this.crud,
    this.description,
    this.email,
    this.labels,
    this.courseId,
    this.projectId,
    this.driveFolderId,
  });

  factory ModelGroup.fromJson(Map<String, dynamic> json) {
    return ModelGroup(
      id: json[ModelGroupEnum.id.name]?.toString() ?? '',
      name: json[ModelGroupEnum.name.name]?.toString() ?? '',
      description: json[ModelGroupEnum.description.name]?.toString(),
      email: json[ModelGroupEnum.email.name]?.toString(),
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
      courseId: json[ModelGroupEnum.courseId.name]?.toString(),
      projectId: json[ModelGroupEnum.projectId.name]?.toString(),
      driveFolderId: json[ModelGroupEnum.driveFolderId.name]?.toString(),
      crud: ModelCrudMetadata.fromJson(
        Utils.mapFromDynamic(json[ModelGroupEnum.crud.name]),
      ),
    );
  }

  final String id;
  final String name;
  final String? description;
  final String? email;
  final ModelGroupLabels? labels;
  final ModelGroupState state;
  final String? courseId;
  final String? projectId;
  final String? driveFolderId;
  final ModelCrudMetadata crud;

  @override
  ModelGroup copyWith({
    String? id,
    String? name,
    String? description,
    bool? Function()? descriptionOverrideNull,
    String? email,
    bool? Function()? emailOverrideNull,
    ModelGroupLabels? labels,
    bool? Function()? labelsOverrideNull,
    ModelGroupState? state,
    String? courseId,
    bool? Function()? courseIdOverrideNull,
    String? projectId,
    bool? Function()? projectIdOverrideNull,
    String? driveFolderId,
    bool? Function()? driveFolderIdOverrideNull,
    ModelCrudMetadata? crud,
  }) {
    return ModelGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: descriptionOverrideNull != null
          ? null
          : description ?? this.description,
      email: emailOverrideNull != null ? null : email ?? this.email,
      labels: labelsOverrideNull != null ? null : labels ?? this.labels,
      state: state ?? this.state,
      courseId: courseIdOverrideNull != null ? null : courseId ?? this.courseId,
      projectId:
          projectIdOverrideNull != null ? null : projectId ?? this.projectId,
      driveFolderId: driveFolderIdOverrideNull != null
          ? null
          : driveFolderId ?? this.driveFolderId,
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
    if (description != null) {
      json[ModelGroupEnum.description.name] = description;
    }
    if (email != null) {
      json[ModelGroupEnum.email.name] = email;
    }
    if (labels != null) {
      json[ModelGroupEnum.labels.name] = labels!.toJson();
    }
    if (courseId != null) {
      json[ModelGroupEnum.courseId.name] = courseId;
    }
    if (projectId != null) {
      json[ModelGroupEnum.projectId.name] = projectId;
    }
    if (driveFolderId != null) {
      json[ModelGroupEnum.driveFolderId.name] = driveFolderId;
    }
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
