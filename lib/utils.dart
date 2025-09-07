part of 'jocaagura_domain.dart';

/// A utility class providing helper methods for common data operations.
///
/// This class includes methods for validating, parsing, and converting data
/// such as emails, URLs, phone numbers, JSON, and dynamic types. It also includes
/// formatters and validators to ensure proper data handling.
class Utils extends EntityUtil {
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

  /// Converts a dynamic value to a [Map].
  ///
  /// - [jsonString]: The dynamic value, either a JSON string or a Map.
  /// - Returns: A [Map<String, dynamic>], or an empty map if the conversion fails.
  ///
  /// Example:
  /// ```dart
  /// final Map<String, dynamic> result = Utils.mapFromDynamic('{"key": "value"}');
  /// print(result); // Output: {key: value}
  /// ```
  static Map<String, dynamic> mapFromDynamic(dynamic jsonString) {
    if (jsonString is Map<String, dynamic>) {
      return jsonString;
    }

    final dynamic json = jsonDecode(jsonString.toString());
    if (json is Map) {
      final Map<String, dynamic> result = <String, dynamic>{};
      json.forEach((dynamic key, dynamic value) {
        result['$key'] = value;
      });
      return result;
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
    final RegExp regex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$',
    );
    return regex.hasMatch(email);
  }

  /// Validates if a string is a valid URL format.
  ///
  /// - [url]: The string to validate.
  /// - Returns: `true` if the string is a valid URL, `false` otherwise.
  static bool isValidUrl(String url) {
    final RegExp regex = RegExp(
      r'^(https?|ftp):\/\/[^\s\/$.?#].[^\s]*$',
    );
    return regex.hasMatch(url);
  }

  /// Converts a JSON string to a list of strings.
  ///
  /// - [json]: The JSON string to convert.
  /// - Returns: A list of strings, or an empty list if the conversion fails.
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

  /// Converts a map to a JSON string.
  ///
  /// - [map]: The map to convert.
  /// - Returns: A JSON string, or an error message if the conversion fails.
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

  /// Converts a dynamic value to a list of `Map<String, dynamic>`.
  ///
  /// - [json]: The dynamic value to convert.
  /// - Returns: A list of maps, or an empty list if the conversion fails.
  static List<Map<String, dynamic>> listFromDynamic(dynamic json) {
    if (json is List) {
      return json
          .whereType<Map<String, dynamic>>()
          .cast<Map<String, dynamic>>()
          .toList();
    }
    return <Map<String, dynamic>>[];
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

    // Try int directly first.
    final int? i = int.tryParse(cleaned);
    if (i != null) {
      return i;
    }

    // Fallback: parse as double, then truncate.
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

    // Replace non-breaking spaces and thin spaces commonly used as thousands separators.
    s = s
        .replaceAll('\u00A0', ' ')
        .replaceAll('\u202F', ' ')
        .replaceAll('\u2009', ' ')
        .trim();

    // Early parse for plain scientific notation or clean numbers.
    // If this succeeds, prefer the fast path.
    if (double.tryParse(s) != null || int.tryParse(s) != null) {
      return s;
    }

    // Remove currency/exotic symbols but keep digits, signs, separators, exponent chars, and spaces.
    // We'll decide later which separator is decimal.
    const String keptCharsPattern = r'[0-9eE\+\-\,\.\s]';
    final String stripped = s.split('').where((String ch) {
      return RegExp(keptCharsPattern).hasMatch(ch);
    }).join();

    String t = stripped.trim();
    if (t.isEmpty) {
      return null;
    }

    // Collapse multiple spaces.
    t = t.replaceAll(RegExp(r'\s+'), '');

    // If still trivially parseable, return.
    if (double.tryParse(t) != null || int.tryParse(t) != null) {
      return t;
    }

    // Decide decimal separator when both are present.
    final int lastDot = t.lastIndexOf('.');
    final int lastComma = t.lastIndexOf(',');

    if (lastDot >= 0 && lastComma >= 0) {
      // Use the last one as decimal; drop the other as thousands.
      final bool commaIsDecimal = lastComma > lastDot;
      if (commaIsDecimal) {
        // Remove all dots (thousands), then convert comma to dot.
        t = t.replaceAll('.', '');
        t = t.replaceAll(',', '.');
      } else {
        // Remove all commas (thousands), keep dots as decimal.
        t = t.replaceAll(',', '');
      }
    } else if (lastComma >= 0) {
      // Only comma present. If multiple commas → thousands; else decimal.
      final int count = RegExp(',').allMatches(t).length;
      if (count > 1) {
        t = t.replaceAll(',', ''); // likely thousands separators
      } else {
        t = t.replaceAll(',', '.'); // decimal comma → dot
      }
    } else if (lastDot >= 0) {
      // Only dot present. If multiple dots → thousands; else decimal.
      final int count = RegExp(r'\.').allMatches(t).length;
      if (count > 1) {
        t = t.replaceAll('.', ''); // likely thousands
      }
      // else: leave single dot as decimal
    }

    // Final safety pass: keep only one leading sign, digits, one dot for decimal,
    // and exponent part if any.
    // Split exponent if present to prevent multiple dots in mantissa+exponent.
    String mantissa = t;
    String exponent = '';
    final Match? expMatch =
        RegExp(r'([eE][\+\-]?\d+)$').firstMatch(t); // exponent at end
    if (expMatch != null) {
      exponent = expMatch.group(1)!; // like e-3
      mantissa = t.substring(0, expMatch.start);
    }

    // Remove all but digits, sign, and dot in mantissa.
    // Keep only the first sign (if at start) and the first dot.
    String sign = '';
    if (mantissa.startsWith('+') || mantissa.startsWith('-')) {
      sign = mantissa[0];
      mantissa = mantissa.substring(1);
    }
    // Remove everything not digit or dot
    mantissa = mantissa.replaceAll(RegExp(r'[^0-9\.]'), '');

    // Keep only first dot
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
}
