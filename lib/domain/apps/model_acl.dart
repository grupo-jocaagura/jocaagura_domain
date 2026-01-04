part of 'package:jocaagura_domain/jocaagura_domain.dart';

enum RoleType {
  admin,
  editor,
  viewer,
}

enum ModelAclEnum {
  id,
  roleType,
  appName,
  feature,
  email,
  isActive,
  emailAutorizedBy,
  autorizedAtIsoDate,
  revokedAtIsoDate,
  note,
}

/// Describe an access control (ACL) grant for a user over an app feature.
///
/// Guarantees:
/// - Instances are **immutable** (all fields are `final`).
/// - JSON round-trip safety: `toJson()` and `fromJson(...)` preserve values,
///   normalizing date inputs when possible (UTC ISO-8601).
///
/// Trust contract:
/// - [isValidAcl] is `true` only when [autorizedAtIsoDate] is a **valid ISO-8601**
///   date string (non-empty + parseable via `DateTime.tryParse`).
/// - If [autorizedAtIsoDate] is invalid, the app should not trust this ACL grant.
///
/// Minimal example:
/// ```dart
/// void main() {
///   final ModelAcl acl = ModelAcl(
///     id: 'acl-1',
///     roleType: RoleType.admin,
///     appName: 'sat-p',
///     feature: 'router',
///     email: 'user@pragma.com.co',
///     isActive: true,
///     emailAutorizedBy: 'admin@pragma.com.co',
///     autorizedAt: DateTime.utc(2026, 1, 3),
///     revokedAt: '',
///     note: 'Seed permission',
///   );
///
///   final Map<String, dynamic> json = acl.toJson();
///   final ModelAcl back = ModelAcl.fromJson(json);
///
///   assert(acl == back);
///   assert(back.isValidAcl == true);
///   assert(back.autorizedAtDateTime != null);
/// }
/// ```
class ModelAcl extends Model {
  const ModelAcl({
    required this.id,
    required this.roleType,
    required this.appName,
    required this.feature,
    required this.email,
    required this.isActive,
    required this.emailAutorizedBy,
    this.autorizedAtIsoDate = '',
    this.revokedAtIsoDate = '',
    this.note = '',
  });

  /// Creates an instance from a JSON-like map.
  ///
  /// Behavior:
  /// - Uses `Utils.get*` helpers for robust parsing of scalars.
  /// - `roleType` is decoded via `Utils.enumFromJson` using enum `name`.
  /// - Dates accept strings/DateTime/int; when parseable they are normalized to UTC.
  /// - Unknown keys are ignored; missing values fall back to constructor defaults.
  factory ModelAcl.fromJson(Map<String, dynamic> json) {
    final String rawRole = Utils.getStringFromDynamic(
      json[ModelAclEnum.roleType.name],
    );

    return ModelAcl(
      id: Utils.getStringFromDynamic(json[ModelAclEnum.id.name]),
      roleType: Utils.enumFromJson<RoleType>(
        RoleType.values,
        rawRole.isEmpty ? null : rawRole,
        RoleType.viewer,
      ),
      appName: Utils.getStringFromDynamic(json[ModelAclEnum.appName.name]),
      feature: Utils.getStringFromDynamic(json[ModelAclEnum.feature.name]),
      email: Utils.getEmailFromDynamic(json[ModelAclEnum.email.name]),
      isActive: Utils.getBoolFromDynamic(
        json[ModelAclEnum.isActive.name],
        defaultValueIfNull: false,
      ),
      emailAutorizedBy: Utils.getEmailFromDynamic(
        json[ModelAclEnum.emailAutorizedBy.name],
      ),
      autorizedAtIsoDate: DateUtils.normalizeIsoOrEmpty(
        json[ModelAclEnum.autorizedAtIsoDate.name],
      ),
      revokedAtIsoDate: DateUtils.normalizeIsoOrEmpty(
        json[ModelAclEnum.revokedAtIsoDate.name],
      ),
      note: Utils.getStringFromDynamic(json[ModelAclEnum.note.name]),
    );
  }

  const ModelAcl._defaults()
      : id = 'default',
        roleType = RoleType.viewer,
        appName = '',
        feature = '',
        email = '',
        isActive = false,
        emailAutorizedBy = '',
        autorizedAtIsoDate = '',
        revokedAtIsoDate = '',
        note = '';

  static const ModelAcl defaultModelAcl = ModelAcl._defaults();

  final String id;
  final RoleType roleType;
  final String appName;
  final String feature;
  final String email;
  final bool isActive;
  final String emailAutorizedBy;
  final String autorizedAtIsoDate;
  final String revokedAtIsoDate;
  final String note;

  /// Returns a copy with selected fields replaced.
  ///
  /// Optimization:
  /// - If every argument is `null`, returns `this` (no new allocation).
  @override
  ModelAcl copyWith({
    String? id,
    RoleType? roleType,
    String? appName,
    String? feature,
    String? email,
    bool? isActive,
    String? emailAutorizedBy,
    String? autorizedAt,
    String? revokedAt,
    String? note,
  }) {
    final bool noChanges = id == null &&
        roleType == null &&
        appName == null &&
        feature == null &&
        email == null &&
        isActive == null &&
        emailAutorizedBy == null &&
        autorizedAt == null &&
        revokedAt == null &&
        note == null;

    if (noChanges) {
      return this;
    }

    return ModelAcl(
      id: id ?? this.id,
      roleType: roleType ?? this.roleType,
      appName: appName ?? this.appName,
      feature: feature ?? this.feature,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      emailAutorizedBy: emailAutorizedBy ?? this.emailAutorizedBy,
      autorizedAtIsoDate: autorizedAt ?? autorizedAtIsoDate,
      revokedAtIsoDate: revokedAt ?? revokedAtIsoDate,
      note: note ?? this.note,
    );
  }

  /// Serializes the model into a JSON map.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelAclEnum.id.name: id,
        ModelAclEnum.roleType.name: roleType.name,
        ModelAclEnum.appName.name: appName,
        ModelAclEnum.feature.name: feature,
        ModelAclEnum.email.name: email,
        ModelAclEnum.isActive.name: isActive,
        ModelAclEnum.emailAutorizedBy.name: emailAutorizedBy,
        ModelAclEnum.autorizedAtIsoDate.name:
            DateUtils.normalizeIsoOrEmpty(autorizedAtIsoDate),
        ModelAclEnum.revokedAtIsoDate.name:
            DateUtils.normalizeIsoOrEmpty(revokedAtIsoDate),
        ModelAclEnum.note.name: note,
      };

  /// `true` only when [autorizedAtIsoDate] is a valid non-empty ISO-8601 date.
  ///
  /// If this is `false`, consumers should treat this ACL as untrusted.
  bool get isValidAcl => _tryParseIso(autorizedAtIsoDate) != null;

  /// Parsed [autorizedAtIsoDate] as a `DateTime` in UTC, or `null` if empty/invalid.
  DateTime? get autorizedAtDateTime {
    final DateTime? dt = _tryParseIso(autorizedAtIsoDate);
    return dt == null ? null : (dt.isUtc ? dt : dt.toUtc());
  }

  /// Parsed [revokedAtIsoDate] as a `DateTime` in UTC, or `null` if empty/invalid.
  DateTime? get revokedAtDateTime {
    final DateTime? dt = _tryParseIso(revokedAtIsoDate);
    return dt == null ? null : (dt.isUtc ? dt : dt.toUtc());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ModelAcl &&
        other.id == id &&
        other.roleType == roleType &&
        other.appName == appName &&
        other.feature == feature &&
        other.email == email &&
        other.isActive == isActive &&
        other.emailAutorizedBy == emailAutorizedBy &&
        other.autorizedAtIsoDate == autorizedAtIsoDate &&
        other.revokedAtIsoDate == revokedAtIsoDate &&
        other.note == note;
  }

  @override
  int get hashCode => Object.hash(
        id,
        roleType,
        appName,
        feature,
        email,
        isActive,
        emailAutorizedBy,
        autorizedAtIsoDate,
        revokedAtIsoDate,
        note,
      );

  static DateTime? _tryParseIso(String value) {
    final String s = value.trim();
    if (s.isEmpty) {
      return null;
    }
    return DateTime.tryParse(s);
  }
}
