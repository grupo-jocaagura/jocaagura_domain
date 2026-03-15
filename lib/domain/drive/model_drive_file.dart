part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelDriveFile].
enum ModelDriveFileEnum {
  sizeBytes,
  extension,
}

/// Concrete file payload for the logical drive domain.
class ModelDriveFile extends ModelDriveItem {
  const ModelDriveFile({
    required super.id,
    required super.name,
    required super.mimeType,
    required super.parentId,
    required super.path,
    required super.createdAt,
    required super.updatedAt,
    required super.trashed,
    required this.sizeBytes,
    super.webUrl,
    super.meta,
    this.extension,
  }) : super(kind: ModelDriveKindEnum.file);

  /// Rebuilds a [ModelDriveFile] from JSON.
  factory ModelDriveFile.fromJson(Map<String, dynamic> json) {
    return ModelDriveFile(
      id: Utils.getStringFromDynamic(json[ModelDriveItemEnum.id.name]),
      name: Utils.getStringFromDynamic(json[ModelDriveItemEnum.name.name]),
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
      sizeBytes:
          Utils.getIntegerFromDynamic(json[ModelDriveFileEnum.sizeBytes.name]),
      extension:
          _nullableStringFromDynamic(json[ModelDriveFileEnum.extension.name]),
    );
  }

  final int sizeBytes;
  final String? extension;

  @override
  ModelDriveFile copyWith({
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
    int? sizeBytes,
    Object? extension = _driveUnset,
  }) {
    return ModelDriveFile(
      id: id ?? this.id,
      name: name ?? this.name,
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
      sizeBytes: sizeBytes ?? this.sizeBytes,
      extension: identical(extension, _driveUnset)
          ? this.extension
          : extension as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json[ModelDriveFileEnum.sizeBytes.name] = sizeBytes;
    if (extension != null) {
      json[ModelDriveFileEnum.extension.name] = extension;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelDriveFile &&
          super == other &&
          sizeBytes == other.sizeBytes &&
          extension == other.extension;

  @override
  int get hashCode => Object.hash(super.hashCode, sizeBytes, extension);

  @override
  String toString() => 'ModelDriveFile(${toJson()})';
}
