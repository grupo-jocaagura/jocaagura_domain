part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelJsonSchemaDocument].
enum ModelJsonSchemaDocumentEnum {
  id,
  schemaId,
  schemaTitle,
  domainModel,
  version,
  schemaDescription,
  schema,
  example,
  tags,
  createdAt,
  updatedAt,
  isActive,
}

/// Immutable domain document that stores a complete JSON Schema contract as data.
///
/// This model is the core of the `json_schema` module. It lets the domain
/// transport, persist and version JSON Schema documents without coupling them to
/// a specific implementation language.
///
/// Contract notes:
/// - [schema] stores the full JSON Schema document as a JSON object.
/// - [example] stores one canonical example payload associated with the schema.
/// - [createdAt] and [updatedAt] are serialized as ISO-8601 strings.
/// - [tags] is always normalized to a list of strings.
class ModelJsonSchemaDocument extends Model {
  const ModelJsonSchemaDocument({
    required this.id,
    required this.schemaId,
    required this.schemaTitle,
    required this.domainModel,
    required this.version,
    required this.schemaDescription,
    required this.schema,
    required this.example,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  /// Rebuilds a [ModelJsonSchemaDocument] from JSON.
  factory ModelJsonSchemaDocument.fromJson(Map<String, dynamic> json) {
    return ModelJsonSchemaDocument(
      id: Utils.getStringFromDynamic(
        json[ModelJsonSchemaDocumentEnum.id.name],
      ),
      schemaId: Utils.getStringFromDynamic(
        json[ModelJsonSchemaDocumentEnum.schemaId.name],
      ),
      schemaTitle: Utils.getStringFromDynamic(
        json[ModelJsonSchemaDocumentEnum.schemaTitle.name],
      ),
      domainModel: Utils.getStringFromDynamic(
        json[ModelJsonSchemaDocumentEnum.domainModel.name],
      ),
      version: Utils.getStringFromDynamic(
        json[ModelJsonSchemaDocumentEnum.version.name],
      ),
      schemaDescription: Utils.getStringFromDynamic(
        json[ModelJsonSchemaDocumentEnum.schemaDescription.name],
      ),
      schema: Utils.mapFromDynamic(
        json[ModelJsonSchemaDocumentEnum.schema.name],
      ),
      example: Utils.mapFromDynamic(
        json[ModelJsonSchemaDocumentEnum.example.name],
      ),
      tags: Utils.stringListFromDynamic(
        json[ModelJsonSchemaDocumentEnum.tags.name],
      ),
      createdAt: DateUtils.dateTimeFromDynamic(
        json[ModelJsonSchemaDocumentEnum.createdAt.name],
      ),
      updatedAt: DateUtils.dateTimeFromDynamic(
        json[ModelJsonSchemaDocumentEnum.updatedAt.name],
      ),
      isActive: Utils.getBoolFromDynamic(
        json[ModelJsonSchemaDocumentEnum.isActive.name],
      ),
    );
  }

  /// Internal identifier of the schema document record.
  final String id;

  /// Canonical schema identifier, usually aligned with `$id`.
  final String schemaId;

  /// Human-readable title of the contract.
  final String schemaTitle;

  /// Domain model described by the schema.
  final String domainModel;

  /// Version label of the contract line, e.g. `v1`.
  final String version;

  /// Functional description of the contract.
  final String schemaDescription;

  /// Full JSON Schema document stored as JSON object.
  final Map<String, dynamic> schema;

  /// Canonical example payload for the contract.
  final Map<String, dynamic> example;

  /// Classification tags for search and grouping.
  final List<String> tags;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Indicates whether the document is currently active.
  final bool isActive;

  @override
  ModelJsonSchemaDocument copyWith({
    String? id,
    String? schemaId,
    String? schemaTitle,
    String? domainModel,
    String? version,
    String? schemaDescription,
    Map<String, dynamic>? schema,
    Map<String, dynamic>? example,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ModelJsonSchemaDocument(
      id: id ?? this.id,
      schemaId: schemaId ?? this.schemaId,
      schemaTitle: schemaTitle ?? this.schemaTitle,
      domainModel: domainModel ?? this.domainModel,
      version: version ?? this.version,
      schemaDescription: schemaDescription ?? this.schemaDescription,
      schema: schema ?? this.schema,
      example: example ?? this.example,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelJsonSchemaDocumentEnum.id.name: id,
      ModelJsonSchemaDocumentEnum.schemaId.name: schemaId,
      ModelJsonSchemaDocumentEnum.schemaTitle.name: schemaTitle,
      ModelJsonSchemaDocumentEnum.domainModel.name: domainModel,
      ModelJsonSchemaDocumentEnum.version.name: version,
      ModelJsonSchemaDocumentEnum.schemaDescription.name: schemaDescription,
      ModelJsonSchemaDocumentEnum.schema.name: schema,
      ModelJsonSchemaDocumentEnum.example.name: example,
      ModelJsonSchemaDocumentEnum.tags.name: tags,
      ModelJsonSchemaDocumentEnum.createdAt.name:
          DateUtils.dateTimeToString(createdAt),
      ModelJsonSchemaDocumentEnum.updatedAt.name:
          DateUtils.dateTimeToString(updatedAt),
      ModelJsonSchemaDocumentEnum.isActive.name: isActive,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelJsonSchemaDocument &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          schemaId == other.schemaId &&
          schemaTitle == other.schemaTitle &&
          domainModel == other.domainModel &&
          version == other.version &&
          schemaDescription == other.schemaDescription &&
          Utils.deepEqualsDynamic(schema, other.schema) &&
          Utils.deepEqualsDynamic(example, other.example) &&
          Utils.deepEqualsDynamic(tags, other.tags) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(
        id,
        schemaId,
        schemaTitle,
        domainModel,
        version,
        schemaDescription,
        Utils.deepHash(schema),
        Utils.deepHash(example),
        Utils.deepHash(tags),
        createdAt,
        updatedAt,
        isActive,
      );

  @override
  String toString() => 'ModelJsonSchemaDocument(${toJson()})';
}
