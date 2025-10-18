part of '../jocaagura_domain.dart';

/// Alias for backwards compatibility.
typedef ModelAttribute<T> = AttributeModel<T>;

enum AttributeEnum {
  name,
  value,
}

/// Represents a generic attribute with a name and a value, where the value is of a generic type [T].
///
/// The type [T] must maintain compatibility with Firestore data types:
/// - **Compatible Firestore Data Types**: Ensure that all values are types Firestore can handle,
/// including `String`, `Number` (integers and floats), `Boolean`, `Map`, `Array`, `Null`,
/// `Timestamp`, `GeoPoint`, and binary blobs.
/// Using unsupported types may cause errors or unexpected behavior.
///
/// Example of using [AttributeModel] in a practical application:
///
/// ```dart
/// void main() {
///   var attribute = AttributeModel<String>(
///     name: 'Color',
///     value: 'Blue',
///   );
///
///   print('Attribute Name: ${attribute.name}');
///   print('Attribute Value: ${attribute.value}');
///
///   var numberAttribute = AttributeModel<int>(
///     name: 'Age',
///     value: 30,
///   );
///
///   print('Attribute Name: ${numberAttribute.name}');
///   print('Attribute Value: ${numberAttribute.value}');
/// }
/// ```
///
/// This class is essential for managing flexible attribute data in systems where the type of value varies.
class AttributeModel<T> extends Model {
  /// Constructs a new [AttributeModel] with the given [name] and [value].
  const AttributeModel({
    required this.value,
    required this.name,
  });

  /// The value of the attribute, with type [T].
  final T value;

  /// The name of the attribute.
  final String name;

  /// Creates a copy of this [AttributeModel] with optional new values.
  @override
  AttributeModel<T> copyWith({
    String? name,
    T? value,
  }) =>
      AttributeModel<T>(
        value: value ?? this.value,
        name: name ?? this.name,
      );

  /// Serializes this [AttributeModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      AttributeEnum.value.name: value,
      AttributeEnum.name.name: name,
    };
  }

  /// Determines if two [AttributeModel] instances are equal.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeModel &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          name == other.name &&
          hashCode == other.hashCode;

  /// Returns the hash code for this [AttributeModel].
  @override
  int get hashCode => '$value$name'.hashCode;

  /// Returns a string representation of this [AttributeModel].
  ///
  /// This method serializes the object to a JSON string.
  @override
  String toString() {
    return jsonEncode(toJson());
  }

  /// Factory helper for safely creating typed attributes.
  ///
  /// Ensures value is valid and compatible with Firestore.
  /// Returns null if type is not supported.
  static AttributeModel<T>? from<T>(String name, T value) {
    if (isDomanCompatible(value)) {
      return AttributeModel<T>(name: name, value: value);
    }
    return null;
  }

  /// Internal check for Firestore-compatible types.
  /// Supports: String, num, bool, DateTime, Map, List, Null, etc.
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

/// Deserializes a JSON map into an [AttributeModel] of type [T].
///
/// The [fromJsonT] parameter is a function that converts the raw JSON value
/// into the desired type [T].
///
/// Example of deserializing an [AttributeModel]:
///
/// ```dart
/// var json = {
///   'name': 'Weight',
///   'value': 70,
/// };
///
/// var attribute = attributeModelfromJson<int>(json, (value) => value as int);
/// print('Attribute Name: ${attribute.name}');
/// print('Attribute Value: ${attribute.value}');
/// ```
AttributeModel<T> attributeModelfromJson<T>(
  Map<String, dynamic> json,
  T Function(dynamic) fromJsonT,
) {
  dynamic value = json['value'];
  value = fromJsonT(value);
  return AttributeModel<T>(
    name: json[AttributeEnum.name.name]?.toString() ?? '',
    value: value as T,
  );
}
