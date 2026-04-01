part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// JSON keys used by [ModelVehicle].
enum ModelVehicleEnum {
  id,
  displayName,
  plate,
  brand,
  model,
  year,
  description,
  isActive,
  vehicleCategory,
  tags,
  attributes,
}

/// Default instance of [ModelVehicle] for tests and fallback scenarios.
const ModelVehicle defaultModelVehicle = ModelVehicle(
  id: '',
  displayName: 'Default Vehicle',
  plate: '',
  brand: '',
  model: '',
  year: 0,
  description: '',
  isActive: true,
  vehicleCategory: defaultModelCategory,
);

/// Represent a canonical cross-cutting vehicle contract for the domain.
///
/// This model stores the structural identity of a vehicle and keeps
/// operational variability in [attributes].
///
/// Canonical JSON contract:
/// - `vehicleCategory` is serialized as a single [ModelCategory].
/// - `tags` is serialized as an ordered list of [ModelCategory].
/// - `attributes` is serialized as a named dictionary of [AttributeModel].
///
/// The [fromJson] factory is defensive and accepts some non-canonical shapes
/// to simplify interoperability. However, [toJson] always emits the canonical
/// portable representation.
///
/// Functional example:
/// ```dart
/// void main() {
///   final ModelVehicle vehicle = ModelVehicle(
///     id: 'vehicle-1',
///     displayName: 'Delivery Van',
///     plate: 'ABC123',
///     brand: 'Jocaagura Motors',
///     model: 'Cargo X',
///     year: 2024,
///     description: 'Main distribution vehicle',
///     isActive: true,
///     vehicleCategory: defaultModelCategory,
///     tags: <ModelCategory>[defaultModelCategory],
///     attributes: <String, AttributeModel<dynamic>>{
///       'fuelLevel': AttributeModel<double>(
///         name: 'fuelLevel',
///         value: 0.75,
///       ),
///     },
///   );
///
///   final Map<String, dynamic> json = vehicle.toJson();
///   final ModelVehicle parsed = ModelVehicle.fromJson(json);
///
///   print(parsed.displayName);
/// }
/// ```
///
/// Notes:
/// - [attributes] can represent operational values such as fuel level,
///   maintenance indicators, attached documents, or occupancy metadata.
/// - [fromJson] may ignore unsupported attribute values when normalizing
///   non-canonical input.
/// - [tags] preserve order during serialization.
/// - [attributes] are compared by deep JSON content for equality.
///
/// Contracts:
/// - [id], [displayName], [plate], [brand], [model], and [description]
///   are normalized as strings.
/// - [year] is normalized as an integer.
/// - [isActive] defaults to `true` when omitted or null during parsing.
/// - [vehicleCategory] is always expected as a single category object in the
///   canonical JSON representation.
class ModelVehicle extends Model {
  /// Create an immutable [ModelVehicle].
  ///
  /// Use this constructor to define the canonical structural data of a vehicle.
  ///
  /// Parameters:
  /// - [id]: Stable identifier of the vehicle.
  /// - [displayName]: Human-readable label.
  /// - [plate]: Registration or plate identifier.
  /// - [brand]: Manufacturer or brand.
  /// - [model]: Commercial or internal model name.
  /// - [year]: Model year.
  /// - [description]: Additional free-text description.
  /// - [isActive]: Whether the vehicle is active in the domain.
  /// - [vehicleCategory]: Primary reusable classification.
  /// - [tags]: Secondary reusable categories for grouping or filtering.
  /// - [attributes]: Extensible operational attributes keyed by name.
  const ModelVehicle({
    required this.id,
    required this.displayName,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.description,
    required this.isActive,
    required this.vehicleCategory,
    this.tags = const <ModelCategory>[],
    this.attributes = const <String, AttributeModel<dynamic>>{},
  });

  /// Create a [ModelVehicle] from a JSON-like map.
  ///
  /// This factory accepts the canonical JSON representation and also supports
  /// some defensive normalization for `attributes`.
  ///
  /// Supported `attributes` input shapes:
  /// - a canonical named map of attribute objects
  /// - a map of primitive compatible values
  /// - a list of shallow attribute objects
  ///
  /// Returns a normalized immutable [ModelVehicle].
  ///
  /// Notes:
  /// - Missing or null `isActive` values default to `true`.
  /// - Unsupported attribute values may be ignored during normalization.
  factory ModelVehicle.fromJson(Map<String, dynamic> json) {
    return ModelVehicle(
      id: Utils.getStringFromDynamic(json[ModelVehicleEnum.id.name]),
      displayName:
          Utils.getStringFromDynamic(json[ModelVehicleEnum.displayName.name]),
      plate: Utils.getStringFromDynamic(json[ModelVehicleEnum.plate.name]),
      brand: Utils.getStringFromDynamic(json[ModelVehicleEnum.brand.name]),
      model: Utils.getStringFromDynamic(json[ModelVehicleEnum.model.name]),
      year: Utils.getIntegerFromDynamic(json[ModelVehicleEnum.year.name]),
      description:
          Utils.getStringFromDynamic(json[ModelVehicleEnum.description.name]),
      isActive: Utils.getBoolFromDynamic(
        json[ModelVehicleEnum.isActive.name],
        defaultValueIfNull: true,
      ),
      vehicleCategory: ModelCategory.fromJson(
        Utils.mapFromDynamic(json[ModelVehicleEnum.vehicleCategory.name]),
      ),
      tags: _tagsFromDynamic(json[ModelVehicleEnum.tags.name]),
      attributes:
          _attributesFromDynamic(json[ModelVehicleEnum.attributes.name]),
    );
  }

  /// Stable identifier of the vehicle.
  final String id;

  /// Human-readable display label.
  final String displayName;

  /// Vehicle plate or registration identifier.
  final String plate;

  /// Manufacturer or brand.
  final String brand;

  /// Commercial or internal model name.
  final String model;

  /// Model year.
  final int year;

  /// Additional free-text description.
  final String description;

  /// Whether the vehicle is active in the domain.
  final bool isActive;

  /// Primary reusable classification of the vehicle.
  final ModelCategory vehicleCategory;

  /// Secondary reusable tags for grouping or filtering.
  final List<ModelCategory> tags;

  /// Named extensible attributes for operational context.
  final Map<String, AttributeModel<dynamic>> attributes;

  /// Create a copy of this vehicle with the provided overrides.
  ///
  /// Any parameter left as `null` preserves the current value.
  ///
  /// Returns a new [ModelVehicle] instance.
  @override
  ModelVehicle copyWith({
    String? id,
    String? displayName,
    String? plate,
    String? brand,
    String? model,
    int? year,
    String? description,
    bool? isActive,
    ModelCategory? vehicleCategory,
    List<ModelCategory>? tags,
    Map<String, AttributeModel<dynamic>>? attributes,
  }) {
    return ModelVehicle(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      plate: plate ?? this.plate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      tags: tags ?? this.tags,
      attributes: attributes ?? this.attributes,
    );
  }

  /// Serialize this vehicle into its canonical JSON representation.
  ///
  /// Returns a portable map where:
  /// - `vehicleCategory` is a single serialized [ModelCategory]
  /// - `tags` is an ordered list of serialized [ModelCategory]
  /// - `attributes` is a named map of serialized [AttributeModel]
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> serializedAttributes = <String, dynamic>{};
    for (final MapEntry<String, AttributeModel<dynamic>> entry
        in attributes.entries) {
      serializedAttributes[entry.key] = entry.value.toJson();
    }

    return <String, dynamic>{
      ModelVehicleEnum.id.name: id,
      ModelVehicleEnum.displayName.name: displayName,
      ModelVehicleEnum.plate.name: plate,
      ModelVehicleEnum.brand.name: brand,
      ModelVehicleEnum.model.name: model,
      ModelVehicleEnum.year.name: year,
      ModelVehicleEnum.description.name: description,
      ModelVehicleEnum.isActive.name: isActive,
      ModelVehicleEnum.vehicleCategory.name: vehicleCategory.toJson(),
      ModelVehicleEnum.tags.name:
          tags.map((ModelCategory tag) => tag.toJson()).toList(),
      ModelVehicleEnum.attributes.name: serializedAttributes,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ModelVehicle &&
            runtimeType == other.runtimeType &&
            other.id == id &&
            other.displayName == displayName &&
            other.plate == plate &&
            other.brand == brand &&
            other.model == model &&
            other.year == year &&
            other.description == description &&
            other.isActive == isActive &&
            other.vehicleCategory == vehicleCategory &&
            Utils.listEquals(other.tags, tags) &&
            _attributeMapEquals(other.attributes, attributes);
  }

  @override
  int get hashCode => Object.hash(
        id,
        displayName,
        plate,
        brand,
        model,
        year,
        description,
        isActive,
        vehicleCategory,
        Utils.listHash(tags),
        _attributeMapHash(attributes),
      );

  @override
  String toString() => 'ModelVehicle(${toJson()})';

  static List<ModelCategory> _tagsFromDynamic(dynamic rawTags) {
    return Utils.listFromDynamic(rawTags)
        .map(ModelCategory.fromJson)
        .toList(growable: false);
  }

  static Map<String, AttributeModel<dynamic>> _attributesFromDynamic(
    dynamic rawAttributes,
  ) {
    if (rawAttributes is List) {
      final List<ModelAttribute<dynamic>> list =
          AttributeModel.listFromDynamicShallow(rawAttributes);
      final Map<String, AttributeModel<dynamic>> fromList =
          <String, AttributeModel<dynamic>>{};
      for (final AttributeModel<dynamic> attribute in list) {
        if (attribute.name.isNotEmpty) {
          fromList[attribute.name] = attribute;
        }
      }
      return Map<String, AttributeModel<dynamic>>.unmodifiable(fromList);
    }

    final Map<String, dynamic> rawMap = Utils.mapFromDynamic(rawAttributes);
    final Map<String, AttributeModel<dynamic>> parsed =
        <String, AttributeModel<dynamic>>{};

    for (final MapEntry<String, dynamic> entry in rawMap.entries) {
      final String key = entry.key;
      final dynamic value = entry.value;

      if (value is Map) {
        final Map<String, dynamic> mapValue = Utils.mapFromDynamic(value);
        final String attributeName =
            Utils.getStringFromDynamic(mapValue[AttributeEnum.name.name])
                    .isEmpty
                ? key
                : Utils.getStringFromDynamic(mapValue[AttributeEnum.name.name]);
        final dynamic attributeValue = mapValue[AttributeEnum.value.name];
        if (AttributeModel.isDomainCompatible(attributeValue)) {
          parsed[key] = AttributeModel<dynamic>(
            name: attributeName,
            value: attributeValue,
          );
        }
        continue;
      }

      if (AttributeModel.isDomainCompatible(value)) {
        parsed[key] = AttributeModel<dynamic>(name: key, value: value);
      }
    }

    return Map<String, AttributeModel<dynamic>>.unmodifiable(parsed);
  }

  static bool _attributeMapEquals(
    Map<String, AttributeModel<dynamic>> a,
    Map<String, AttributeModel<dynamic>> b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (final MapEntry<String, AttributeModel<dynamic>> entry in a.entries) {
      final AttributeModel<dynamic>? otherValue = b[entry.key];
      if (otherValue == null) {
        return false;
      }
      if (!Utils.deepEqualsMap(entry.value.toJson(), otherValue.toJson())) {
        return false;
      }
    }
    return true;
  }

  static int _attributeMapHash(Map<String, AttributeModel<dynamic>> map) {
    return Object.hashAllUnordered(
      map.entries.map(
        (MapEntry<String, AttributeModel<dynamic>> entry) =>
            Object.hash(entry.key, Utils.deepHash(entry.value.toJson())),
      ),
    );
  }
}
