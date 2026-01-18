part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the serialized fields of [ModelAclPolicy].
enum ModelAclPolicyEnum {
  id,
  minRoleType,
  appName,
  feature,
  isActive,
  note,
  upsertAtIsoDate,
  upsertBy,
}

/// Define the minimal, global access policy for an app feature.
///
/// A policy stores the **minimum role** required to enter a controlled flow/step.
/// It is intentionally deterministic and serializable (JSON roundtrip).
///
/// Important:
/// - "Deny-by-default" for missing/inactive policies is enforced by the ACL evaluator,
///   not by this model.
/// - Role hierarchy is assumed as: `admin > editor > viewer`.
///
/// Example:
/// ```dart
/// void main() {
///   final ModelAclPolicy policy = ModelAclPolicy(
///     id: ModelAclPolicy.buildId(appName: 'bienvenido', feature: 'user.creation'),
///     minRoleType: RoleType.editor,
///     appName: 'bienvenido',
///     feature: 'user.creation',
///     isActive: true,
///     note: 'Controls user creation flow',
///     upsertAtIsoDate: DateTime.utc(2026, 1, 18).toIso8601String(),
///     upsertBy: 'admin@corp.com',
///   );
///
///   final Map<String, dynamic> json = policy.toJson();
///   final ModelAclPolicy back = ModelAclPolicy.fromJson(json);
///
///   assert(policy == back);
/// }
/// ```
class ModelAclPolicy extends Model {
  /// Creates an immutable [ModelAclPolicy].
  const ModelAclPolicy({
    required this.id,
    required this.minRoleType,
    required this.appName,
    required this.feature,
    required this.isActive,
    required this.note,
    required this.upsertAtIsoDate,
    required this.upsertBy,
  });

  /// Robust JSON parsing with safe defaults.
  ///
  /// Behavior:
  /// - Uses `Utils.get*` helpers for robust scalar parsing.
  /// - `minRoleType` is decoded via `Utils.enumFromJson` using enum `name`.
  /// - `upsertAtIsoDate` accepts strings/DateTime/int; when parseable it is normalized to UTC.
  factory ModelAclPolicy.fromJson(Map<String, dynamic> json) {
    final String appName =
        Utils.getStringFromDynamic(json[ModelAclPolicyEnum.appName.name])
            .trim();
    final String feature =
        Utils.getStringFromDynamic(json[ModelAclPolicyEnum.feature.name])
            .trim();

    final String rawId =
        Utils.getStringFromDynamic(json[ModelAclPolicyEnum.id.name]).trim();
    final String computedId = buildId(appName: appName, feature: feature);
    final String id = rawId.isEmpty ? computedId : rawId;

    final String rawMinRole =
        Utils.getStringFromDynamic(json[ModelAclPolicyEnum.minRoleType.name]);

    return ModelAclPolicy(
      id: id,
      minRoleType: Utils.enumFromJson(
        RoleType.values,
        rawMinRole.isEmpty ? null : rawMinRole,
        RoleType.viewer,
      ),
      appName: appName,
      feature: feature,
      isActive: Utils.getBoolFromDynamic(
        json[ModelAclPolicyEnum.isActive.name],
        defaultValueIfNull: false,
      ),
      note: Utils.getStringFromDynamic(json[ModelAclPolicyEnum.note.name]),
      upsertAtIsoDate: DateUtils.normalizeIsoOrEmpty(
        json[ModelAclPolicyEnum.upsertAtIsoDate.name],
      ),
      upsertBy:
          Utils.getStringFromDynamic(json[ModelAclPolicyEnum.upsertBy.name]),
    );
  }

  const ModelAclPolicy._defaults()
      : id = '',
        minRoleType = RoleType.viewer,
        appName = '',
        feature = '',
        isActive = false,
        note = '',
        upsertAtIsoDate = '',
        upsertBy = '';

  /// Default instance for fallback/testing.
  static const ModelAclPolicy defaultModelAclPolicy =
      ModelAclPolicy._defaults();

  /// Canonical id: "<appName>.<feature>" (dot notation).
  ///
  /// Note: we **do not** enforce lowercase to keep implementers free to decide.
  static String buildId({
    required String appName,
    required String feature,
  }) {
    final String a = appName.trim();
    final String f = feature.trim();
    if (a.isEmpty || f.isEmpty) {
      return '';
    }
    return '$a.$f';
  }

  /// Pure role hierarchy check (admin > editor > viewer).
  static bool roleMeetsMin({
    required RoleType userRole,
    required RoleType minRole,
  }) {
    return _roleLevel(userRole) >= _roleLevel(minRole);
  }

  static int _roleLevel(RoleType role) {
    switch (role) {
      case RoleType.viewer:
        return 1;
      case RoleType.editor:
        return 2;
      case RoleType.admin:
        return 3;
    }
  }

  final String id;
  final RoleType minRoleType;
  final String appName;
  final String feature;
  final bool isActive;
  final String note;
  final String upsertAtIsoDate;
  final String upsertBy;

  @override
  ModelAclPolicy copyWith({
    String? id,
    RoleType? minRoleType,
    String? appName,
    String? feature,
    bool? isActive,
    String? note,
    String? upsertAtIsoDate,
    String? upsertBy,
  }) {
    final bool noChanges = id == null &&
        minRoleType == null &&
        appName == null &&
        feature == null &&
        isActive == null &&
        note == null &&
        upsertAtIsoDate == null &&
        upsertBy == null;

    if (noChanges) {
      return this;
    }

    return ModelAclPolicy(
      id: id ?? this.id,
      minRoleType: minRoleType ?? this.minRoleType,
      appName: appName ?? this.appName,
      feature: feature ?? this.feature,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
      upsertAtIsoDate: upsertAtIsoDate ?? this.upsertAtIsoDate,
      upsertBy: upsertBy ?? this.upsertBy,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelAclPolicyEnum.id.name: id,
        ModelAclPolicyEnum.minRoleType.name: minRoleType.name,
        ModelAclPolicyEnum.appName.name: appName,
        ModelAclPolicyEnum.feature.name: feature,
        ModelAclPolicyEnum.isActive.name: isActive,
        ModelAclPolicyEnum.note.name: note,
        ModelAclPolicyEnum.upsertAtIsoDate.name:
            DateUtils.normalizeIsoOrEmpty(upsertAtIsoDate),
        ModelAclPolicyEnum.upsertBy.name: upsertBy,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ModelAclPolicy &&
        other.id == id &&
        other.minRoleType == minRoleType &&
        other.appName == appName &&
        other.feature == feature &&
        other.isActive == isActive &&
        other.note == note &&
        other.upsertAtIsoDate == upsertAtIsoDate &&
        other.upsertBy == upsertBy;
  }

  @override
  int get hashCode => Object.hash(
        id,
        minRoleType,
        appName,
        feature,
        isActive,
        note,
        upsertAtIsoDate,
        upsertBy,
      );
}
