part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the property keys used in [ModelCategory].
///
/// These keys ensure consistency across serialization and deserialization.
enum ModelCategoryEnum {
  /// Unique logical identifier for the category.
  category,

  /// Description or explanation of the category's purpose.
  description,
}

/// Default instance of [ModelCategory] used for testing or fallback purposes.
///
/// Provides a simple placeholder category example.
const ModelCategory defaultModelCategory = ModelCategory(
  category: 'default-category',
  description: 'Default category for generic tagging or testing purposes.',
);

/// A minimal model representing a reusable category or tag.
///
/// This model is often used to classify items (e.g., products, services).
/// The [category] acts as a unique logical ID and is normalized to
/// `middle_snake_case` on `toJson`.
///
/// ### Example:
/// ```dart
/// final ModelCategory tag = ModelCategory(
///   category: 'Pet Store',
///   description: 'Items related to pets and animals',
/// );
///
/// print(tag.toJson());
/// // { category: pet_store, description: Items related to pets and animals }
/// ```
class ModelCategory extends Model {
  /// Creates a new immutable [ModelCategory] instance.
  const ModelCategory({
    required this.category,
    required this.description,
  });

  /// Creates a [ModelCategory] from a JSON [Map].
  factory ModelCategory.fromJson(Map<String, dynamic> json) {
    return ModelCategory(
      category:
          Utils.getStringFromDynamic(json[ModelCategoryEnum.category.name]),
      description:
          Utils.getStringFromDynamic(json[ModelCategoryEnum.description.name]),
    );
  }

  /// Unique logical identifier of the category.
  final String category;

  /// Description or tooltip for the category.
  final String description;

  /// Creates a copy of this [ModelCategory] with optional new values.
  @override
  ModelCategory copyWith({
    String? category,
    String? description,
  }) {
    return ModelCategory(
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  /// Converts this [ModelCategory] into a JSON [Map], normalizing the category key.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelCategoryEnum.category.name: normalizeCategory(category),
      ModelCategoryEnum.description.name: description.trim(),
    };
  }

  static String normalizeCategory(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9\- ]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .toLowerCase();
  }

  /// Overrides the hashCode using only the `category` field.
  @override
  int get hashCode => normalizeCategory(category).hashCode;

  /// Equality is based solely on the normalized category.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelCategory &&
          runtimeType == other.runtimeType &&
          normalizeCategory(category) == normalizeCategory(other.category);

  /// Pretty print for debugging.
  @override
  String toString() => '📦 Category($category): $description';
}
