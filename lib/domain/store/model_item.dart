part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the field names used in [ModelItem].
enum ModelItemEnum {
  id,
  name,
  description,
  type,
  price,
  attributes,
}

/// Represents a minimal and extensible item (product, service, etc).
///
/// The [id] may be empty if coming from a new instance and should be
/// assigned via repository or backend. If empty, the [type.category]
/// will be used as a fallback logical identifier in certain contexts.
///
/// ### Example
/// ```dart
/// final item = ModelItem(
///   id: '',
///   name: 'Surgical Mask',
///   description: 'Disposable protective face mask',
///   type: ModelCategory(category: 'health-supplies', description: 'Health-related items'),
///   price: ModelPrice(amount: 2500, mathPrecision: 2, currency: CurrencyEnum.COP),
///   attributes: [
///     ModelAttribute.from<String>('Color', 'Blue')!,
///     ModelAttribute.from<int>('Stock', 50)!,
///   ],
/// );
///
/// print(item.toJson());
/// ```
class ModelItem extends Model {
  /// Creates a new immutable [ModelItem].
  const ModelItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    this.attributes = const <ModelAttribute<dynamic>>[],
  });

  /// Builds a [ModelItem] from JSON.
  factory ModelItem.fromJson(Map<String, dynamic> json) {
    return ModelItem(
      id: Utils.getStringFromDynamic(json[ModelItemEnum.id.name]),
      name: Utils.getStringFromDynamic(json[ModelItemEnum.name.name]),
      description:
          Utils.getStringFromDynamic(json[ModelItemEnum.description.name]),
      type: ModelCategory.fromJson(
        Utils.mapFromDynamic(json[ModelItemEnum.type.name]),
      ),
      price: ModelPrice.fromJson(
        Utils.mapFromDynamic(json[ModelItemEnum.price.name]),
      ),
      attributes: Utils.listFromDynamic(json[ModelItemEnum.attributes.name])
          .map(
            (Map<String, dynamic> e) =>
                attributeModelfromJson<dynamic>(e, (dynamic v) => v),
          )
          .toList(),
    );
  }

  /// Unique identifier for the item.
  final String id;

  /// Name of the item.
  final String name;

  /// Description or details of the item.
  final String description;

  /// Logical type or tag associated to the item.
  final ModelCategory type;

  /// Price configuration of the item.
  final ModelPrice price;

  /// Optional extensible list of attributes (e.g., size, color, stock).
  final List<ModelAttribute<dynamic>> attributes;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelItemEnum.id.name:
          id.isEmpty ? ModelCategory.normalizeCategory(type.category) : id,
      ModelItemEnum.name.name: name.trim(),
      ModelItemEnum.description.name: description.trim(),
      ModelItemEnum.type.name: type.toJson(),
      ModelItemEnum.price.name: price.toJson(),
      ModelItemEnum.attributes.name:
          attributes.map((ModelAttribute<dynamic> e) => e.toJson()).toList(),
    };
  }

  @override
  ModelItem copyWith({
    String? id,
    String? name,
    String? description,
    ModelCategory? type,
    ModelPrice? price,
    List<ModelAttribute<dynamic>>? attributes,
  }) {
    return ModelItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          type == other.type &&
          price == other.price &&
          Utils.listEquals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        type,
        price,
        Utils.listHash(attributes),
      );

  @override
  String toString() =>
      '📦 Item($id): $name — ${type.category}, ${price.amount} @ ${price.currency}';
}

/// Default instance of [ModelItem] useful for test/fallback.
const ModelItem defaultModelItem = ModelItem(
  id: '',
  name: 'Default Item',
  description: 'This is a placeholder item',
  type: defaultModelCategory,
  price: defaultModelPrice,
);
