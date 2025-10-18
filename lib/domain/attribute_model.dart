part of '../jocaagura_domain.dart';

/// Alias for backwards compatibility.
typedef ModelAttribute<T> = AttributeModel<T>;

enum AttributeEnum {
  name,
  value,
}

/// Represents an immutable name–value attribute where [value] is of type [T].
///
/// This model is storage-agnostic; values should be *serializable* in your
/// chosen persistence layer. Collections are allowed but their elements are
/// not recursively validated by this class.
///
/// ### Contracts
/// - **Equality:** Two attributes are equal iff both `name` and `value` are equal.
///   Equality does **not** depend on `hashCode`.
/// - **Immutability:** Fields are `final`. Use [copyWith] to derive a new instance.
/// - **Serialization:** [toJson] returns `{ "value": <T>, "name": <String> }`.
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   final AttributeModel<String> color = AttributeModel<String>(
///     name: 'color',
///     value: 'blue',
///   );
///
///   final AttributeModel<String> copy = color.copyWith(value: 'red');
///   print(color.toJson()); // {value: blue, name: color}
///   print(copy);           // prints JSON string
///
///   // Equality contract
///   assert(color != copy);
/// }
/// ```
///
/// ### Usage notes
/// - If you need strict compatibility with a backend (e.g., Firestore), validate
///   types at your mapper/boundary layer. This class only does a shallow check
///   via [AttributeModel.isDomainCompatible].
class AttributeModel<T> extends Model {
  /// Creates an [AttributeModel] with a [name] and a [value] of type [T].
  const AttributeModel({
    required this.value,
    required this.name,
  });

  /// The attribute value.
  final T value;

  /// The attribute name.
  final String name;

  /// Returns a new [AttributeModel] replacing the provided fields.
  @override
  AttributeModel<T> copyWith({
    String? name,
    T? value,
  }) =>
      AttributeModel<T>(
        value: value ?? this.value,
        name: name ?? this.name,
      );

  /// Serializes this attribute to a JSON map:
  /// `{ "value": <T>, "name": <String> }`.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      AttributeEnum.value.name: value,
      AttributeEnum.name.name: name,
    };
  }

  /// Equality is based on `name` and `value` only.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeModel<T> &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          name == other.name;

  /// Hash code consistent with equality.
  @override
  int get hashCode => Object.hash(name, value);

  /// JSON string representation.
  @override
  String toString() {
    return jsonEncode(toJson());
  }

  /// Factory helper that returns a typed [AttributeModel] if [value] is
  /// considered serializable for the domain; otherwise returns `null`.
  static AttributeModel<T>? from<T>(String name, T value) {
    if (isDomanCompatible(value)) {
      return AttributeModel<T>(name: name, value: value);
    }
    return null;
  }

  /// Shallow check for domain-serializable types.
  ///
  /// Supports: `String`, `num`, `bool`, `DateTime`, `Map`, `List`, and `null`.
  /// Does **not** validate nested elements.
  static bool isDomanCompatible(dynamic value) {
    return value == null ||
        value is String ||
        value is num ||
        value is bool ||
        value is DateTime ||
        value is Map ||
        value is List;
  }
}

/// Deserializes an [AttributeModel] of type [T] using a converter for the value.
///
/// The converter [fromJsonT] transforms the raw JSON field into [T].
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   final Map<String, dynamic> json = <String, dynamic>{
///     'name': 'weight',
///     'value': 70,
///   };
///
///   final AttributeModel<int> attr = attributeModelFromJson<int>(
///     json,
///     (dynamic v) => v as int,
///   );
///
///   print(attr.name);  // weight
///   print(attr.value); // 70
/// }
/// ```
@Deprecated('Use static from<T> instead.')
AttributeModel<T> attributeModelfromJson<T>(
  Map<String, dynamic> json,
  T Function(dynamic) fromJsonT,
) =>
    attributeModelFromJson<T>(json, fromJsonT);

// New idiomatic name
AttributeModel<T> attributeModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(dynamic) fromJsonT,
) {
  final dynamic raw = json[AttributeEnum.value.name];
  final T value = fromJsonT(raw);
  return AttributeModel<T>(
    name: json[AttributeEnum.name.name]?.toString() ?? '',
    value: value,
  );
}
