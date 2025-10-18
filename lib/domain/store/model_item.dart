part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the JSON field names used by [ModelItem].
///
/// Contracts:
/// - Keys are serialized by `name`, making the enum order irrelevant.
/// - Keep names stable to avoid breaking persisted data.
///
/// Example:
/// ```dart
/// void main() {
///   final Map<String, dynamic> json = <String, dynamic>{
///     ModelItemEnum.id.name: 'SKU-123',
///     ModelItemEnum.name.name: 'Surgical Mask',
///   };
///   print(json.keys); // (id, name)
/// }
/// ```
enum ModelItemEnum {
  id,
  name,
  description,
  type,
  price,
  attributes,
}

/// Represents an immutable item (product/service) with metadata, price and attributes.
///
/// The `attributes` list is exposed as **read-only**; attempting to mutate it
/// at runtime will throw. Use [copyWith] to derive new instances.
///
/// ### Contracts
/// - **Immutability:** lists are wrapped with `List.unmodifiable`.
/// - **Identifier fallback:** when `id` is empty, `toJson()` uses
///   `ModelCategory.normalizeCategory(type.category)` as a logical identifier.
/// - **Serialization:** `{ id, name, description, type, price, attributes }`.
///   `name` and `description` are serialized **trimmed**.
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   final ModelItem item = ModelItem(
///     id: '',
///     name: '  Surgical Mask  ',
///     description: '  Disposable protective face mask  ',
///     type: ModelCategory(category: 'health-supplies', description: 'Health-related items'),
///     price: ModelPrice(amount: 2500, currency: CurrencyEnum.COP),
///     attributes: <ModelAttribute<dynamic>>[
///       AttributeModel.from<String>('Color', 'Blue')!,
///       AttributeModel.from<int>('Stock', 50)!,
///     ],
///   );
///
///   print(item.attributes.length); // 2
///   print(item.toJson()['id']);    // normalized category when original id is empty
///   // item.attributes.add(...);   // will throw (unmodifiable)
/// }
/// ```
///
/// ### Notes
/// - `toString()` displays minor units and currency code from [ModelPrice]; for a
///   human-friendly decimal string consider using a currency helper/formatter.
class ModelItem extends Model {
  ModelItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    List<ModelAttribute<dynamic>> attributes =
        const <ModelAttribute<dynamic>>[],
  }) : attributes = List<ModelAttribute<dynamic>>.unmodifiable(attributes);

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

  /// Unique identifier for the item. May be empty on new instances.
  final String id;

  /// Human-readable name.
  final String name;

  /// Long description or details.
  final String description;

  /// Logical classification/category.
  final ModelCategory type;

  /// Price configuration.
  final ModelPrice price;

  /// Read-only attribute list (e.g., size, color, stock).
  final List<ModelAttribute<dynamic>> attributes;

  /// Serializes this item to JSON using trimmed `name`/`description`.
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

  /// Derives a new [ModelItem] overriding selected fields.
  ///
  /// The resulting instance preserves the read-only `attributes` contract.
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

  /// Structural equality including attributes (order-sensitive).
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

  /// Hash code consistent with equality.
  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        type,
        price,
        Utils.listHash(attributes),
      );

  /// Human-readable summary.
  @override
  String toString() =>
      '📦 Item($id): $name — ${type.category}, ${price.amount} @ ${price.currency}';
}

/// Default instance of [ModelItem] useful for test/fallback.
final ModelItem defaultModelItem = ModelItem(
  id: '',
  name: 'Default Item',
  description: 'This is a placeholder item',
  type: defaultModelCategory,
  price: defaultModelPrice,
);
