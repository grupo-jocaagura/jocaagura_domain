part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by the drive resource models.
enum ModelDriveItemEnum {
  id,
  name,
  kind,
  mimeType,
  parentId,
  path,
  webUrl,
  createdAt,
  updatedAt,
  trashed,
  meta,
}

/// Domain classification of a drive resource.
enum ModelDriveKindEnum {
  file,
  folder,
}

/// Base real payload for a document resource in the logical drive domain.
///
/// This model is intentionally concrete and consumable. It can represent a
/// generic resource in listings, indexes or exploration responses, while more
/// specific contracts such as [ModelDriveFile] and [ModelDriveFolder] add
/// stricter guarantees on top.
class ModelDriveItem extends Model {
  const ModelDriveItem({
    required this.id,
    required this.name,
    required this.kind,
    required this.mimeType,
    required this.parentId,
    required this.path,
    required this.createdAt,
    required this.updatedAt,
    required this.trashed,
    this.webUrl,
    this.meta,
  });

  /// Rebuilds a [ModelDriveItem] from JSON.
  factory ModelDriveItem.fromJson(Map<String, dynamic> json) {
    return ModelDriveItem(
      id: Utils.getStringFromDynamic(json[ModelDriveItemEnum.id.name]),
      name: Utils.getStringFromDynamic(json[ModelDriveItemEnum.name.name]),
      kind: Utils.enumFromJson<ModelDriveKindEnum>(
        ModelDriveKindEnum.values,
        Utils.getStringFromDynamic(json[ModelDriveItemEnum.kind.name]),
        ModelDriveKindEnum.file,
      ),
      mimeType: Utils.getStringFromDynamic(
        json[ModelDriveItemEnum.mimeType.name],
      ),
      parentId:
          _nullableStringFromDynamic(json[ModelDriveItemEnum.parentId.name]),
      path: Utils.getStringFromDynamic(json[ModelDriveItemEnum.path.name]),
      webUrl: _nullableUrlFromDynamic(json[ModelDriveItemEnum.webUrl.name]),
      createdAt: DateUtils.dateTimeFromDynamic(
        json[ModelDriveItemEnum.createdAt.name],
      ),
      updatedAt: DateUtils.dateTimeFromDynamic(
        json[ModelDriveItemEnum.updatedAt.name],
      ),
      trashed: Utils.getBoolFromDynamic(json[ModelDriveItemEnum.trashed.name]),
      meta: _nullableMapFromDynamic(json[ModelDriveItemEnum.meta.name]),
    );
  }

  final String id;
  final String name;
  final ModelDriveKindEnum kind;
  final String mimeType;
  final String? parentId;
  final String path;
  final String? webUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool trashed;
  final Map<String, dynamic>? meta;

  @override
  ModelDriveItem copyWith({
    String? id,
    String? name,
    ModelDriveKindEnum? kind,
    String? mimeType,
    Object? parentId = _driveUnset,
    String? path,
    Object? webUrl = _driveUnset,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? trashed,
    Object? meta = _driveUnset,
  }) {
    return ModelDriveItem(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      mimeType: mimeType ?? this.mimeType,
      parentId: identical(parentId, _driveUnset)
          ? this.parentId
          : parentId as String?,
      path: path ?? this.path,
      webUrl: identical(webUrl, _driveUnset) ? this.webUrl : webUrl as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trashed: trashed ?? this.trashed,
      meta: identical(meta, _driveUnset)
          ? this.meta
          : meta as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelDriveItemEnum.id.name: id,
      ModelDriveItemEnum.name.name: name,
      ModelDriveItemEnum.kind.name: kind.name,
      ModelDriveItemEnum.mimeType.name: mimeType,
      ModelDriveItemEnum.parentId.name: parentId,
      ModelDriveItemEnum.path.name: path,
      ModelDriveItemEnum.createdAt.name: DateUtils.dateTimeToString(createdAt),
      ModelDriveItemEnum.updatedAt.name: DateUtils.dateTimeToString(updatedAt),
      ModelDriveItemEnum.trashed.name: trashed,
    };

    if (webUrl != null) {
      json[ModelDriveItemEnum.webUrl.name] = webUrl;
    }
    if (meta != null) {
      json[ModelDriveItemEnum.meta.name] = meta;
    }

    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelDriveItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          kind == other.kind &&
          mimeType == other.mimeType &&
          parentId == other.parentId &&
          path == other.path &&
          webUrl == other.webUrl &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          trashed == other.trashed &&
          Utils.deepEqualsDynamic(meta, other.meta);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        kind,
        mimeType,
        parentId,
        path,
        webUrl,
        createdAt,
        updatedAt,
        trashed,
        Utils.deepHash(meta),
      );

  @override
  String toString() => 'ModelDriveItem(${toJson()})';
}

const Object _driveUnset = Object();

String? _nullableStringFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  final String parsed = Utils.getStringFromDynamic(value);
  return parsed.isEmpty ? null : parsed;
}

String? _nullableUrlFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  final String parsed = Utils.getUrlFromDynamic(value);
  return parsed.isEmpty ? null : parsed;
}

Map<String, dynamic>? _nullableMapFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  return Utils.mapFromDynamic(value);
}
