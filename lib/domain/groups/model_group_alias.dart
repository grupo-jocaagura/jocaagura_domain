part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP ALIAS
/// ===========================================================================

/// JSON keys for [ModelGroupAlias].
///
/// This enum centralizes the string keys used on serialization and parsing,
/// avoiding magic strings across the codebase.
///
/// Example:
/// ```dart
/// void main() {
///   print(ModelGroupAliasEnum.aliasEmail.name); // "aliasEmail"
/// }
/// ```
enum ModelGroupAliasEnum {
  id,
  groupId,
  aliasEmail,
  status,
  errorItemId,
  crud,
}

/// Represents an email alias bound to a group.
///
/// An alias is identified by [id] and tied to a group via [groupId]. The
/// current lifecycle is expressed in [status], and audit metadata is stored in
/// [crud]. Optionally, [errorItemId] can reference a domain ErrorItem used to
/// track provisioning or synchronization failures.
///
/// JSON contract:
/// - Required fields:
///   - `id` (string)
///   - `groupId` (string)
///   - `aliasEmail` (string)
///   - `status` (string; [ModelGroupAliasStatus.name])
///   - `crud` (object; [ModelCrudMetadata.toJson])
/// - Optional field:
///   - `errorItemId` (string) – omitted when `null`.
///
/// Parsing rules:
/// - `id`, `groupId`, `aliasEmail` fall back to `''` when missing or `null`.
/// - [status] is resolved with [Utils.enumFromJson], defaulting to
///   [ModelGroupAliasStatus.active] when the value is missing or unknown.
/// - [crud] must contain a valid [ModelCrudMetadata] payload.
/// - Extra keys are ignored safely.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final DateTime now = DateTime.utc(2025, 1, 1, 10, 0, 0);
///
///   final ModelCrudMetadata crud = ModelCrudMetadata(
///     recordId: 'alias-1',
///     createdBy: 'system@domain.com',
///     createdAt: now,
///     updatedBy: 'system@domain.com',
///     updatedAt: now,
///     version: 1,
///   );
///
///   final ModelGroupAlias alias = ModelGroupAlias(
///     id: 'alias-1',
///     groupId: 'group-001',
///     aliasEmail: 'soporte@domain.com',
///     status: ModelGroupAliasStatus.active,
///     crud: crud,
///   );
///
///   final Map<String, dynamic> json = alias.toJson();
///   final ModelGroupAlias roundtrip = ModelGroupAlias.fromJson(json);
///
///   print(roundtrip.aliasEmail); // soporte@domain.com
///   print(roundtrip.status);     // ModelGroupAliasStatus.active
/// }
/// ```
class ModelGroupAlias extends Model {
  const ModelGroupAlias({
    required this.id,
    required this.groupId,
    required this.aliasEmail,
    required this.status,
    required this.crud,
    this.errorItemId = '',
  });

  /// Creates a [ModelGroupAlias] from a JSON-like map.
  ///
  /// - Required scalar fields (`id`, `groupId`, `aliasEmail`) fall back to `''`
  ///   when missing or `null`.
  /// - [status] is resolved with [Utils.enumFromJson], defaulting to
  ///   [ModelGroupAliasStatus.active].
  /// - [errorItemId] is parsed as a nullable string.
  /// - [crud] is mandatory and must contain a valid [ModelCrudMetadata] payload.
  factory ModelGroupAlias.fromJson(Map<String, dynamic> json) {
    return ModelGroupAlias(
      id: json[ModelGroupAliasEnum.id.name]?.toString() ?? '',
      groupId: json[ModelGroupAliasEnum.groupId.name]?.toString() ?? '',
      aliasEmail: json[ModelGroupAliasEnum.aliasEmail.name]?.toString() ?? '',
      status: Utils.enumFromJson<ModelGroupAliasStatus>(
        ModelGroupAliasStatus.values,
        json[ModelGroupAliasEnum.status.name]?.toString(),
        ModelGroupAliasStatus.active,
      ),
      errorItemId: Utils.getStringFromDynamic(
        json[ModelGroupAliasEnum.errorItemId.name],
      ),
      crud: ModelCrudMetadata.fromJson(
        Utils.mapFromDynamic(json[ModelGroupAliasEnum.crud.name]),
      ),
    );
  }

  final String id;
  final String groupId;
  final String aliasEmail;
  final ModelGroupAliasStatus status;
  final String errorItemId;
  final ModelCrudMetadata crud;

  /// Returns a new [ModelGroupAlias] with some fields updated.
  ///
  /// - Passing a non-null [errorItemId] replaces the current value.
  ///   Since [errorItemId] is non-nullable, clearing it means setting it to `''`.
  @override
  ModelGroupAlias copyWith({
    String? id,
    String? groupId,
    String? aliasEmail,
    ModelGroupAliasStatus? status,
    String? errorItemId,
    ModelCrudMetadata? crud,
  }) {
    return ModelGroupAlias(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      aliasEmail: aliasEmail ?? this.aliasEmail,
      status: status ?? this.status,
      errorItemId: errorItemId ?? this.errorItemId,
      crud: crud ?? this.crud,
    );
  }

  /// Serializes this alias into a JSON-like map.
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelGroupAliasEnum.id.name: id,
      ModelGroupAliasEnum.groupId.name: groupId,
      ModelGroupAliasEnum.aliasEmail.name: aliasEmail,
      ModelGroupAliasEnum.status.name: status.name,
      ModelGroupAliasEnum.crud.name: crud.toJson(),
    };
    json[ModelGroupAliasEnum.errorItemId.name] = errorItemId;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroupAlias &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          aliasEmail == other.aliasEmail &&
          status == other.status &&
          errorItemId == other.errorItemId &&
          crud == other.crud;

  @override
  int get hashCode => Object.hash(
        id,
        groupId,
        aliasEmail,
        status,
        errorItemId,
        crud,
      );

  @override
  String toString() => 'ModelGroupAlias(${toJson()})';
}
