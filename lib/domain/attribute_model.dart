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

  /// Parses a dynamic input into a *shallow* list of `AttributeModel<dynamic>`.
  ///
  /// - **Accepted inputs:**
  ///   - `String` holding JSON for a `List` of objects with `"name"` and `"value"` keys.
  ///   - Any non-string input that `Utils.listFromDynamic` can convert into
  ///     `List<Map<String, dynamic>>`.
  ///
  /// - **Shallow validation:** Each item's `value` is included **only if**
  ///   [AttributeModel.isDomanCompatible] returns `true` (supports `String`, `num`,
  ///   `bool`, `DateTime`, `Map`, `List`, and `null`). Nested elements are **not**
  ///   validated.
  /// - **Missing keys:** If `"name"` is absent, an empty string `''` is used.
  /// - **Error handling:** Invalid JSON or unsupported shapes are ignored silently,
  ///   yielding an empty list.
  /// - **Return mutability:** The returned list is **mutable**. If you need an
  ///   immutable result, wrap it with `List.unmodifiable(...)`.
  ///
  /// ### Minimal runnable example
  /// ```dart
  /// void main() {
  ///   const String json = '''
  ///   [
  ///     {"name":"color","value":"blue"},
  ///     {"name":"qty","value":3},
  ///     {"name":"active","value":true},
  ///     {"name":"tags","value":["a","b"]},
  ///     {"name":"meta","value":{"k":"v"}},
  ///     {"name":"nil","value":null}
  ///   ]
  ///   ''';
  ///
  ///   final List<ModelAttribute<dynamic>> attrs =
  ///       AttributeModel.listFromDynamicShallow(json);
  ///
  ///   print(attrs.length);        // 6
  ///   print(attrs.first.name);    // color
  ///   print(attrs.first.value);   // blue
  /// }
  /// ```
  ///
  /// ### Notes & limitations
  /// - JSON strings that decode to a single `Map` (not a `List`) produce an empty result.
  /// - Items with non-domain-compatible `value` are dropped silently.
  /// - This method does **not** convert ISO8601 strings to `DateTime`.
  static List<ModelAttribute<dynamic>> listFromDynamicShallow(dynamic input) {
    List<Map<String, dynamic>> asList = <Map<String, dynamic>>[];

    if (input is String) {
      try {
        final dynamic decoded = jsonDecode(input);
        if (decoded is List) {
          for (final dynamic e in decoded) {
            if (e is Map<String, dynamic>) {
              asList.add(e);
            }
          }
        }
      } catch (_) {
        debugPrint('Tipo no compatible');
      }
    } else {
      asList = Utils.listFromDynamic(input);
    }

    final List<ModelAttribute<dynamic>> out = <ModelAttribute<dynamic>>[];
    for (final Map<String, dynamic> m in asList) {
      final String name = m[AttributeEnum.name.name]?.toString() ?? '';
      final dynamic value = m[AttributeEnum.value.name];

      if (AttributeModel.isDomanCompatible(value)) {
        out.add(AttributeModel<dynamic>(name: name, value: value));
      }
    }
    return List<ModelAttribute<dynamic>>.unmodifiable(out);
  }

  /// Builds a typed list of `AttributeModel<T>` from a dynamic input.
  ///
  /// - **Accepted inputs**
  ///   - `String` holding JSON for an **array** of objects; only elements that
  ///     decode to `Map<String, dynamic>` are considered. Non-object elements are
  ///     ignored silently.
  ///   - Non-string inputs are delegated to `Utils.listFromDynamic` which must
  ///     return a `List<Map<String, dynamic>>`.
  ///
  /// - **Value conversion**
  ///   Each item's `"value"` is transformed to `T` using `fromJsonT`. If the
  ///   converter throws for an element, that element is skipped (the method does
  ///   **not** rethrow).
  ///
  /// - **Shallow domain check**
  ///   Only attributes whose converted `value` passes
  ///   [AttributeModel.isDomanCompatible] (`String`, `num`, `bool`, `DateTime`,
  ///   `Map`, `List`, or `null`) are included. **Nested elements are not validated.**
  ///
  /// - **Missing keys**
  ///   If `"name"` is absent, an empty string `''` is used.
  ///
  /// - **Error handling**
  ///   Invalid JSON, non-iterable JSON roots, or non-object elements are ignored
  ///   gracefully, yielding an empty result or skipping the offending items.
  ///
  /// - **Ordering**
  ///   The result preserves the order of the input sequence.
  ///
  /// ### Contracts
  /// - **Preconditions:**
  ///   - If `input` is `String`, it should contain a JSON array for elements to be parsed.
  ///   - `fromJsonT` must accept the raw `"value"` type and return a `T`.
  /// - **Postconditions:**
  ///   - Returned list contains only attributes with domain-compatible values.
  ///   - No exceptions are thrown by this method due to bad items; such items are skipped.
  ///
  /// ### Minimal runnable example
  /// ```dart
  /// void main() {
  ///   const String json = '''
  ///   [
  ///     {"name":"qty","value":"3"},
  ///     {"name":"createdAt","value":"2024-01-02T03:04:05.000Z"},
  ///     123,                    // ignored (not an object)
  ///     {"name":"bad","value":{}} // will be skipped if converter throws
  ///   ]
  ///   ''';
  ///
  ///   final List<ModelAttribute<int>> ints = AttributeModel.listFromDynamicTyped<int>(
  ///     json,
  ///     (dynamic v) => int.parse(v as String), // converter to T
  ///   );
  ///
  ///   print(ints.length); // 1
  ///   print(ints.first.name);  // qty
  ///   print(ints.first.value); // 3
  ///
  ///   final List<ModelAttribute<DateTime>> dates = AttributeModel.listFromDynamicTyped<DateTime>(
  ///     json,
  ///     (dynamic v) => DateTime.parse(v as String),
  ///   );
  ///
  ///   print(dates.first.name);  // createdAt
  ///   print(dates.first.value); // 2024-01-02 03:04:05.000Z
  /// }
  /// ```
  ///
  /// ### Notes & limitations
  /// - This method performs **shallow** checks only; it does not validate nested
  ///   contents of `Map` or `List`.
  /// - Avoid side effects inside `fromJsonT`; failures are swallowed to keep the
  ///   pipeline robust.
  /// - Non-object JSON array elements are ignored by design.
  ///
  /// Returns a (by default) **mutable** `List<ModelAttribute<T>>`. If you need an
  /// immutable result, wrap it with `List.unmodifiable(...)` at the call site or
  /// adjust the implementation accordingly
  static List<ModelAttribute<T>> listFromDynamicTyped<T>(
    dynamic input,
    T Function(dynamic) fromJsonT,
  ) {
    final List<Map<String, dynamic>> raw = (() {
      if (input is String) {
        try {
          final dynamic decoded = jsonDecode(input);
          if (decoded is Iterable) {
            final List<Map<String, dynamic>> tmp = <Map<String, dynamic>>[];
            for (final dynamic e in decoded) {
              if (e is Map<String, dynamic>) {
                tmp.add(e);
              }
            }
            return tmp;
          }
        } catch (_) {}
        return <Map<String, dynamic>>[];
      }
      return Utils.listFromDynamic(input);
    })();

    final List<ModelAttribute<T>> out = <ModelAttribute<T>>[];
    for (final Map<String, dynamic> m in raw) {
      try {
        final AttributeModel<T> attr = attributeModelFromJson<T>(m, fromJsonT);

        if (AttributeModel.isDomanCompatible(attr.value)) {
          out.add(attr);
        }
      } catch (_) {
        debugPrint('Falla silenciosamente');
      }
    }
    return List<ModelAttribute<T>>.unmodifiable(out);
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
