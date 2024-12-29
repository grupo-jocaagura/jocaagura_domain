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

  /// Converts a dynamic value to an integer.
  ///
  /// - [value]: The dynamic value to convert.
  /// - Returns: An integer value, or `0` if the conversion fails.
  static int getIntegerFromDynamic(dynamic value) {
    return int.tryParse(value.toString()) ?? 0;
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

  /// Converts a dynamic value to a double.
  ///
  /// - [json]: The dynamic value to convert.
  /// - [defaultValue]: The default value if conversion fails.
  /// - Returns: A double value, or `defaultValue` if the conversion fails.
  static double getDouble(dynamic json, [double defaultValue = double.nan]) {
    return double.tryParse(json.toString()) ?? defaultValue;
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
}
