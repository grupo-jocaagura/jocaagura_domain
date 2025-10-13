part of 'jocaagura_domain.dart';

/// A utility class providing helper methods for common data operations.
///
/// This class includes methods for validating, parsing, and converting data
/// such as emails, URLs, phone numbers, JSON, and dynamic types. It also includes
/// formatters and validators to ensure proper data handling.
class Utils extends EntityUtil {
  /// Formats a 10-digit phone number as `(XX) X XXX XXXX`.
  ///
  /// This is an alias that keeps the original behavior while fixing the method
  /// name spelling and parameter naming. It delegates to
  /// [getFormatedPhoneNumber] without altering logic.
  ///
  /// **Contract**
  /// - Pads the number to 10 digits on the left with `0` when needed.
  /// - Does not validate country codes or international formats.
  /// - Negative numbers will keep their minus sign in the input string before
  ///   padding, which may lead to unexpected results. Prefer passing non-negative
  ///   integers only.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final String s = Utils.getFormattedPhoneNumber(3001234567);
  ///   // "(30) 0 123 4567"
  ///   print(s);
  /// }
  /// ```
  static String getFormattedPhoneNumber(int phoneNumber) {
    return getFormatedPhoneNumber(phoneNumber);
  }

  /// Formats a 10-digit phone number as `XXX XXX XXXX`.
  ///
  /// This is an alias that keeps the original behavior while fixing the method
  /// name spelling and parameter naming. It delegates to
  /// [getFormatedPhoneNumberAlt] without altering logic.
  ///
  /// **Contract**
  /// - Pads the number to 10 digits on the left with `0` when needed.
  /// - Not intended for international formats or extensions.
  /// - Input should be a non-negative integer representing a national 10-digit
  ///   number; other inputs may yield unexpected formatting.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final String s = Utils.getFormattedPhoneNumberAlt(3001234567);
  ///   // "300 123 4567"
  ///   print(s);
  /// }
  /// ```
  static String getFormattedPhoneNumberAlt(int phoneNumber) {
    return getFormatedPhoneNumberAlt(phoneNumber);
  }

  /// Converts a [Map] into a JSON string.
  ///
  /// - [inputMap]: The map to convert.
  /// - Returns: A JSON string representation of the map.
  ///
  /// Example:
  /// ```dart
  /// final String jsonString = Utils.mapToString({'key': 'value'});
  /// print(jsonString); // Output: {"key":"value"}
  /// ```
  static String mapToString(Map<String, dynamic> inputMap) {
    return getJsonEncode(inputMap);
  }

  /// Converts a dynamic JSON-like value into a `Map<String, dynamic>`.
  ///
  /// Accepts:
  /// - `Map<String, dynamic>` → returned as-is.
  /// - raw `Map` with dynamic keys → keys are coerced to `String`.
  /// - JSON `String` → decoded into a map with `String` keys.
  ///
  /// Returns `{}` when decoding fails or when the value is not a map (never throws).
  ///
  /// Contract:
  /// - Keys are stringified (`'$k'`), which may collapse different non-string keys
  ///   into the same string representation.
  /// - Unknown/invalid inputs are safely mapped to `{}`.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   print(Utils.mapFromDynamic('{"a":1}'));            // {a: 1}
  ///   print(Utils.mapFromDynamic({1: true, 'b': 2}));    // {1: true, b: 2}
  ///   print(Utils.mapFromDynamic(42));                   // {}
  /// }
  /// ```
  static Map<String, dynamic> mapFromDynamic(dynamic jsonLike) {
    if (jsonLike is Map<String, dynamic>) {
      return jsonLike;
    }

    if (jsonLike is Map) {
      final Map<String, dynamic> m = <String, dynamic>{};
      jsonLike.forEach((dynamic k, dynamic v) {
        m['$k'] = v;
      });
      return m;
    }

    try {
      final dynamic decoded = jsonDecode(jsonLike.toString());
      if (decoded is Map) {
        final Map<String, dynamic> result = <String, dynamic>{};
        decoded.forEach((dynamic k, dynamic v) {
          result['$k'] = v;
        });
        return result;
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  /// Validates and extracts a valid email from a dynamic value.
  ///
  /// - [value]: The dynamic value containing the email.
  /// - Returns: A valid email string, or an empty string if invalid.
  static String getEmailFromDynamic(dynamic value) {
    final String email = value.toString();
    if (isEmail(email)) {
      return email;
    }
    return '';
  }

  /// Validates and extracts a valid URL from a dynamic value.
  ///
  /// - [value]: The dynamic value containing the URL.
  /// - Returns: A valid URL string, or an empty string if invalid.
  static String getUrlFromDynamic(dynamic value) {
    final String url = value.toString();
    if (isValidUrl(url)) {
      return url;
    }
    return '';
  }

  /// Validates if a string is a valid email format.
  ///
  /// - [email]: The string to validate.
  /// - Returns: `true` if the string is a valid email, `false` otherwise.
  static bool isEmail(String email) {
    final RegExp re =
        RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,24}$');
    return re.hasMatch(email);
  }

  /// Validates if a string is a valid URL format.
  ///
  /// - [url]: The string to validate.
  /// - Returns: `true` if the string is a valid URL, `false` otherwise.
  static bool isValidUrl(String s) {
    final Uri? u = Uri.tryParse(s.trim());
    if (u == null) {
      return false;
    }
    final bool okScheme =
        u.scheme == 'http' || u.scheme == 'https' || u.scheme == 'ftp';
    return okScheme && u.hasAuthority;
  }

  /// Converts a JSON string to a `List<String>`.
  ///
  /// Behavior:
  /// - If the decoded value is a `List`, each item is stringified.
  /// - If it's any other JSON value (e.g., number, object), returns a single-item
  ///   list containing its string representation.
  /// - If parsing fails or the input is `null`, returns `[]`.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   print(Utils.convertJsonToList('["a", 1, true]')); // [a, 1, true]
  ///   print(Utils.convertJsonToList('42'));             // [42]
  ///   print(Utils.convertJsonToList('oops'));           // []
  /// }
  /// ```
  static List<String> convertJsonToList(String? json) {
    json = json.toString();
    try {
      final dynamic decodedJson = jsonDecode(json);
      if (decodedJson == null) {
        return <String>[];
      }
      if (decodedJson is List) {
        return decodedJson.map((dynamic item) => item.toString()).toList();
      }
      return <String>[decodedJson.toString()];
    } catch (e) {
      return <String>[];
    }
  }

  /// Safely converts a dynamic value to a string.
  ///
  /// - [value]: The dynamic value to convert.
  /// - Returns: A string representation of the value, or an empty string if `null`.
  static String getStringFromDynamic(dynamic value) {
    return value?.toString() ?? '';
  }

  /// Serializes a `Map<String, dynamic>` into a JSON string.
  ///
  /// Returns a JSON string when serialization succeeds. On failure, returns a
  /// human-readable **non-JSON** string describing the error (does not throw).
  ///
  /// Contract:
  /// - Consumers that require valid JSON must verify the output or wrap the call
  ///   to ensure only encodable values are provided.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   print(Utils.getJsonEncode({'k': 'v'})); // {"k":"v"}
  ///   print(Utils.getJsonEncode({'bad': Object()})); // "{error: ...}" (not JSON)
  /// }
  /// ```
  static String getJsonEncode(Map<String, dynamic> map) {
    try {
      return jsonEncode(map);
    } catch (e) {
      return <String, String>{'error': e.toString()}.toString();
    }
  }

  /// Formats a phone number in a specific format: `(XX) X XXX XXXX`.
  ///
  /// - [numeroTelefono]: The phone number as an integer.
  /// - Returns: A formatted phone number string.
  static String getFormatedPhoneNumber(int numeroTelefono) {
    final String numeroString = numeroTelefono.toString().padLeft(10, '0');
    final String prefijo = numeroString.substring(0, 2);
    final String resto = numeroString.substring(2);

    String resultado = '($prefijo)';
    resultado += ' ${resto.substring(0, 1)} '
        '${resto.substring(1, 4)} '
        '${resto.substring(4)}';

    return resultado;
  }

  /// Formats a phone number in an alternate format: `XXX XXX XXXX`.
  ///
  /// - [numeroTelefono]: The phone number as an integer.
  /// - Returns: A formatted phone number string.
  static String getFormatedPhoneNumberAlt(int numeroTelefono) {
    final String numeroString = numeroTelefono.toString().padLeft(10, '0');
    return '${numeroString.substring(0, 3)} ${numeroString.substring(3, 6)} ${numeroString.substring(6)}';
  }

  /// Converts a dynamic value to a boolean.
  ///
  /// - [json]: The dynamic value to convert.
  /// - Returns: `true` if the value is `true`, otherwise `false`.
  static bool getBoolFromDynamic(dynamic json) {
    return json == true;
  }

  /// Converts a dynamic value into `List<Map<String, dynamic>>`.
  ///
  /// Accepts a `List` whose items can be either:
  /// - `Map<String, dynamic>` → kept as-is
  /// - raw `Map` with dynamic keys → keys are coerced to `String`
  ///
  /// Non-map elements are ignored. Returns an empty list for non-list inputs.
  /// Never throws.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final List<dynamic> raw = [ {'a': 1}, {2: 'x'}, 'noise', null ];
  ///   final List<Map<String, dynamic>> out = Utils.listFromDynamic(raw);
  ///   print(out); // [{a: 1}, {2: x}]
  /// }
  /// ```
  static List<Map<String, dynamic>> listFromDynamic(dynamic json) {
    if (json is! List) {
      return <Map<String, dynamic>>[];
    }

    final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
    for (final dynamic e in json) {
      if (e is Map<String, dynamic>) {
        out.add(e);
      } else if (e is Map) {
        final Map<String, dynamic> m = <String, dynamic>{};
        e.forEach((dynamic k, dynamic v) {
          m['$k'] = v;
        });
        out.add(m);
      }
    }
    return out;
  }

  /// Converts a dynamic value to an integer.
  ///
  /// Behavior:
  /// - `null` → `0`
  /// - `int`  → value as-is
  /// - `double` → truncated toward zero (e.g. `3.9` → `3`, `-3.9` → `-3`)
  /// - `String` → robust cleaning for currency symbols, thousand separators,
  ///   non-breaking spaces, and locale decimal (`,` vs `.`). Also supports
  ///   scientific notation like `"3e2"`.
  /// - Non-parsable / NaN / Infinity → `0`
  ///
  /// Examples:
  /// ```dart
  /// Utils.getIntegerFromDynamic('  1.234,56 COP '); // 1234
  /// Utils.getIntegerFromDynamic('3e2');             // 300
  /// Utils.getIntegerFromDynamic(42.9);              // 42
  /// Utils.getIntegerFromDynamic(null);              // 0
  /// ```
  static int getIntegerFromDynamic(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      if (value.isNaN || value.isInfinite) {
        return 0;
      }
      return value.truncate();
    }

    final String? cleaned = _normalizeNumberString(value);
    if (cleaned == null || cleaned.isEmpty) {
      return 0;
    }

    final int? i = int.tryParse(cleaned);
    if (i != null) {
      return i;
    }

    final double? d = double.tryParse(cleaned);
    if (d == null || d.isNaN || d.isInfinite) {
      return 0;
    }
    return d.truncate();
  }

  /// Converts a dynamic value to a double.
  ///
  /// Keep the same signature. If parsing fails, returns [defaultValue].
  ///
  /// Behavior:
  /// - `null` → [defaultValue]
  /// - `num`  → `toDouble()` (unless NaN/Infinity → [defaultValue])
  /// - `String` → robust cleaning for currency symbols, thousand separators,
  ///   non-breaking spaces, and locale decimal (`,` vs `.`). Also supports
  ///   scientific notation like `"3e-2"`.
  /// - Non-parsable / NaN / Infinity → [defaultValue]
  ///
  /// Examples:
  /// ```dart
  /// Utils.getDouble('  $1,234.56  ');        // 1234.56
  /// Utils.getDouble('1.234,56');             // 1234.56
  /// Utils.getDouble('3e-2');                 // 0.03
  /// Utils.getDouble('invalid', 0.0);         // 0.0
  /// Utils.getDouble(double.nan, 0.0);        // 0.0
  /// ```
  static double getDouble(dynamic json, [double defaultValue = double.nan]) {
    if (json == null) {
      return defaultValue;
    }

    if (json is num) {
      final double v = json.toDouble();
      if (v.isNaN || v.isInfinite) {
        return defaultValue;
      }
      return v;
    }

    final String? cleaned = _normalizeNumberString(json);
    if (cleaned == null || cleaned.isEmpty) {
      return defaultValue;
    }

    final double? parsed = double.tryParse(cleaned);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return defaultValue;
    }
    return parsed;
  }

  /// Normalizes a dynamic numeric-ish input into a canonical parseable string.
  ///
  /// Rules:
  /// - Trims and removes non-breaking spaces.
  /// - If `String` has both `,` and `.`, the **last** separator is treated as
  ///   the decimal separator; the other char is removed as thousand separator.
  /// - If only one of `,` or `.` is present:
  ///   - If it appears multiple times → treat as thousands separator (remove all).
  ///   - Otherwise → treat as decimal separator.
  /// - Removes currency and non-numeric symbols (keeps digits, sign, decimal dot,
  ///   exponent `e/E`, and a single decimal point).
  /// - Converts the decimal separator to dot `.`.
  ///
  /// Returns a string suitable for `double.tryParse` / `int.tryParse`, or `null`
  /// if nothing meaningful remains.
  static String? _normalizeNumberString(dynamic input) {
    String s = input.toString().trim();
    if (s.isEmpty) {
      return null;
    }

    s = s
        .replaceAll('\u00A0', ' ')
        .replaceAll('\u202F', ' ')
        .replaceAll('\u2009', ' ')
        .trim();

    if (double.tryParse(s) != null || int.tryParse(s) != null) {
      return s;
    }

    const String keptCharsPattern = r'[0-9eE+\-.,\s]';
    final String stripped = s.split('').where((String ch) {
      return RegExp(keptCharsPattern).hasMatch(ch);
    }).join();

    String t = stripped.trim();
    if (t.isEmpty) {
      return null;
    }

    t = t.replaceAll(RegExp(r'\s+'), '');

    if (double.tryParse(t) != null || int.tryParse(t) != null) {
      return t;
    }

    final int lastDot = t.lastIndexOf('.');
    final int lastComma = t.lastIndexOf(',');

    if (lastDot >= 0 && lastComma >= 0) {
      final bool commaIsDecimal = lastComma > lastDot;
      if (commaIsDecimal) {
        t = t.replaceAll('.', '');
        t = t.replaceAll(',', '.');
      } else {
        t = t.replaceAll(',', '');
      }
    } else if (lastComma >= 0) {
      final int count = RegExp(',').allMatches(t).length;
      if (count > 1) {
        t = t.replaceAll(',', '');
      } else {
        t = t.replaceAll(',', '.');
      }
    } else if (lastDot >= 0) {
      final int count = RegExp(r'\.').allMatches(t).length;
      if (count > 1) {
        t = t.replaceAll('.', '');
      }
    }

    String mantissa = t;
    String exponent = '';
    final Match? expMatch = RegExp(r'([eE][+-]?\d+)$').firstMatch(t);
    if (expMatch != null) {
      exponent = expMatch.group(1)!;
      mantissa = t.substring(0, expMatch.start);
    }

    String sign = '';
    if (mantissa.startsWith('+') || mantissa.startsWith('-')) {
      sign = mantissa[0];
      mantissa = mantissa.substring(1);
    }
    mantissa = mantissa.replaceAll(RegExp(r'[^0-9.]'), '');

    final int firstDotIdx = mantissa.indexOf('.');
    if (firstDotIdx >= 0) {
      final String before = mantissa.substring(0, firstDotIdx + 1);
      final String after =
          mantissa.substring(firstDotIdx + 1).replaceAll('.', '');
      mantissa = before + after;
    }

    final String candidate = '$sign$mantissa$exponent'.trim();

    // Edge: "." or "-" or empty → invalid
    if (candidate.isEmpty ||
        candidate == '-' ||
        candidate == '+' ||
        candidate == '.' ||
        candidate == '-.' ||
        candidate == '+.') {
      return null;
    }

    return candidate;
  }

  /// Returns `true` if both lists have the same length and each pair of elements
  /// at the same index are equal according to `==`.
  ///
  /// Characteristics:
  /// - Order-sensitive (i.e., `[1,2]` ≠ `[2,1]`).
  /// - Uses element-wise `==`, so custom equality on `T` is honored.
  /// - `identical(a, b)` is a fast-path for `true`.
  /// - This is a shallow comparison (nested lists are compared by their own `==`,
  ///   not by deep traversal).
  /// - `double.nan` compares unequal to itself, so lists containing `NaN` at the
  ///   same index will not be considered equal.
  ///
  /// Complexity: O(n).
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final List<int> x = <int>[1, 2, 3];
  ///   final List<int> y = <int>[1, 2, 3];
  ///   final List<int> z = <int>[3, 2, 1];
  ///
  ///   print(Utils.listEquals(x, y)); // true
  ///   print(Utils.listEquals(x, z)); // false (order matters)
  /// }
  /// ```
  static bool listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  /// Computes an order-sensitive hash for a list by mixing the `hashCode` of each
  /// element into an accumulator.
  ///
  /// Guarantees:
  /// - If `listEquals(a, b)` is `true`, then `listHash(a) == listHash(b)`.
  /// - Order-sensitive: changing the order changes the hash in general.
  /// - Shallow: relies on each element's `hashCode`; nested lists use their own
  ///   `hashCode` (no deep hashing).
  ///
  /// Notes:
  /// - Not cryptographic; collisions are possible.
  /// - `null` elements are supported (their `hashCode` participates).
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final List<String?> a = <String?>['a', null, 'c'];
  ///   final List<String?> b = <String?>['a', null, 'c'];
  ///   final List<String?> c = <String?>['c', null, 'a'];
  ///
  ///   print(Utils.listHash(a) == Utils.listHash(b)); // true
  ///   print(Utils.listHash(a) == Utils.listHash(c)); // typically false
  /// }
  /// ```
  static int listHash<T>(List<T> a) {
    int h = 0;
    for (final T e in a) {
      h = 0x1fffffff & (h + e.hashCode);
      h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
      h ^= h >> 6;
    }
    return h;
  }

  /// Performs a deep equality comparison between two dynamic values.
  ///
  /// Rules:
  /// - Maps: compared by keys and values using [deepEqualsMap] (keys are coerced
  ///   to `String` through [Utils.mapFromDynamic] when needed).
  /// - Lists: order-sensitive, length must match, elements compared recursively.
  /// - Primitives/other: compared with `==`.
  /// - Fast path: `identical(a, b)` returns `true`.
  ///
  /// Notes:
  /// - `double.nan` is **not** equal to itself in Dart (`NaN != NaN`), therefore
  ///   nested structures containing `NaN` at the same position will be considered
  ///   **not equal**.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final Map<String, dynamic> a = <String, dynamic>{
  ///     'x': <int>[1, 2, 3],
  ///     'y': <String, dynamic>{'k': 'v'}
  ///   };
  ///   final Map<String, dynamic> b = <String, dynamic>{
  ///     'y': <String, dynamic>{'k': 'v'},
  ///     'x': <int>[1, 2, 3],
  ///   };
  ///
  ///   // Deep equal (order-independent for maps, order-sensitive for lists).
  ///   final bool eq = Utils.deepEqualsDynamic(a, b); // true
  ///   print(eq);
  /// }
  /// ```
  static bool deepEqualsDynamic(dynamic a, dynamic b) {
    // 1) Caso especial para double: NaN ≠ NaN según el contrato de estos tests.
    if (a is double && b is double) {
      if (a.isNaN && b.isNaN) {
        return false; // <- clave para que el test pase
      }
      // otros doubles siguen evaluándose normalmente (== maneja 0.0/-0.0 e infinitos)
    }

    // 2) Fast-path habitual
    if (identical(a, b)) {
      return true;
    }

    // 3) Map
    if (a is Map && b is Map) {
      return deepEqualsMap(Utils.mapFromDynamic(a), Utils.mapFromDynamic(b));
    }

    // 4) List
    if (a is List && b is List) {
      if (a.length != b.length) {
        return false;
      }
      for (int i = 0; i < a.length; i++) {
        if (!deepEqualsDynamic(a[i], b[i])) {
          return false;
        }
      }
      return true;
    }

    // 5) Primitivos/otros
    return a == b;
  }

  /// Performs a deep equality comparison between two string-keyed maps.
  ///
  /// Conditions for equality:
  /// - Both maps must have the same set of keys (order does not matter).
  /// - Each value pair is compared recursively via [deepEqualsDynamic].
  /// - Fast path: `identical(a, b)` returns `true`.
  ///
  /// Limitations:
  /// - Keys must be of type `String`. If your inputs come from dynamic/raw maps,
  ///   first normalize them with [Utils.mapFromDynamic] to ensure string keys and
  ///   consistent comparison semantics.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final Map<String, dynamic> a = <String, dynamic>{
  ///     'user': <String, dynamic>{'id': 1, 'name': 'Ana'},
  ///     'tags': <String>['a', 'b']
  ///   };
  ///   final Map<String, dynamic> b = <String, dynamic>{
  ///     'tags': <String>['a', 'b'],
  ///     'user': <String, dynamic>{'id': 1, 'name': 'Ana'},
  ///   };
  ///
  ///   print(Utils.deepEqualsMap(a, b)); // true
  /// }
  /// ```
  static bool deepEqualsMap(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (final String k in a.keys) {
      if (!b.containsKey(k)) {
        return false;
      }
      if (!deepEqualsDynamic(a[k], b[k])) {
        return false;
      }
    }
    return true;
  }

  /// Computes a deep hash for dynamic, JSON-like structures.
  ///
  /// Behavior:
  /// - **Map**: keys are coerced to `String` via [Utils.mapFromDynamic]; each
  ///   entry contributes `Object.hash(key, deepHash(value))`, then all entry
  ///   hashes are combined with `Object.hashAllUnordered` (order-independent).
  /// - **List**: elements are hashed recursively with [deepHash] and combined
  ///   using `Object.hashAll` (order-sensitive).
  /// - **Other values (including `null`)**: returns `value.hashCode`.
  ///
  /// Guarantees:
  /// - If `Utils.deepEqualsDynamic(a, b)` is `true`, then `deepHash(a) == deepHash(b)`.
  /// - Different list orders generally produce different hashes; different map
  ///   key orders produce the **same** hash.
  ///
  /// Notes & limitations:
  /// - **Not cryptographic**; collisions are possible.
  /// - Map key coercion uses stringification (`'$k'`), which may collapse
  ///   distinct non-string keys to the same `String`.
  /// - Input must be **acyclic**; cyclic structures will cause unbounded recursion.
  /// - Values like `double.nan` have a stable `hashCode`, but keep in mind that
  ///   `NaN != NaN`; unequal values may still collide by hash.
  ///
  /// Complexity: O(n) over the number of elements traversed.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final Map<String, dynamic> a = <String, dynamic>{
  ///     'user': <String, dynamic>{'id': 1, 'tags': <String>['a', 'b']},
  ///     'ok': true,
  ///   };
  ///   final Map<String, dynamic> b = <String, dynamic>{
  ///     'ok': true,
  ///     'user': <String, dynamic>{'tags': <String>['a', 'b'], 'id': 1},
  ///   };
  ///
  ///   // Same deep content (map order differs) → same hash
  ///   final int ha = deepHash(a);
  ///   final int hb = deepHash(b);
  ///   print(ha == hb); // true
  ///
  ///   // List order matters
  ///   final List<int> x = <int>[1, 2, 3];
  ///   final List<int> y = <int>[3, 2, 1];
  ///   print(deepHash(x) == deepHash(y)); // typically false
  /// }
  /// ```
  static int deepHash(dynamic value) {
    if (value is Map) {
      final Map<String, dynamic> m = Utils.mapFromDynamic(value);
      final Iterable<int> perEntry = m.entries.map(
        (MapEntry<String, dynamic> e) => Object.hash(e.key, deepHash(e.value)),
      );
      return Object.hashAllUnordered(perEntry);
    }
    if (value is List) {
      return Object.hashAll(value.map(deepHash));
    }
    return value.hashCode;
  }
}
