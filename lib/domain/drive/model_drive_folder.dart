part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelDriveFolder].
enum ModelDriveFolderEnum {
  childrenCount,
}

/// Concrete folder payload for the logical drive domain.
class ModelDriveFolder extends ModelDriveItem {
  const ModelDriveFolder({
    required super.id,
    required super.name,
    required super.parentId,
    required super.path,
    required super.createdAt,
    required super.updatedAt,
    required super.trashed,
    super.webUrl,
    super.meta,
    this.childrenCount,
  }) : super(
          kind: ModelDriveKindEnum.folder,
          mimeType: 'application/vnd.jocaagura.folder',
        );

  /// Rebuilds a [ModelDriveFolder] from JSON.
  factory ModelDriveFolder.fromJson(Map<String, dynamic> json) {
    return ModelDriveFolder(
      id: Utils.getStringFromDynamic(json[ModelDriveItemEnum.id.name]),
      name: Utils.getStringFromDynamic(json[ModelDriveItemEnum.name.name]),
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
      childrenCount: json.containsKey(ModelDriveFolderEnum.childrenCount.name)
          ? Utils.getIntegerFromDynamic(
              json[ModelDriveFolderEnum.childrenCount.name],
            )
          : null,
    );
  }

  final int? childrenCount;

  @override
  ModelDriveFolder copyWith({
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
    Object? childrenCount = _driveUnset,
  }) {
    return ModelDriveFolder(
      id: id ?? this.id,
      name: name ?? this.name,
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
      childrenCount: identical(childrenCount, _driveUnset)
          ? this.childrenCount
          : childrenCount as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    if (childrenCount != null) {
      json[ModelDriveFolderEnum.childrenCount.name] = childrenCount;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelDriveFolder &&
          super == other &&
          childrenCount == other.childrenCount;

  @override
  int get hashCode => Object.hash(super.hashCode, childrenCount);

  @override
  String toString() => 'ModelDriveFolder(${toJson()})';
}
