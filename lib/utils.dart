part of 'jocaagura_domain.dart';

class Utils extends EntityUtil {
  static String mapToString(Map<String, dynamic> inputMap) {
    return getJsonEncode(inputMap);
  }

  /// Converts a string to a [Map].
  ///
  /// [source] is the string to be converted to a [Map].
  ///
  /// Returns an empty [Map] by default. Override this method to customize
  /// the conversion of your entity model.
  static Map<String, dynamic> mapFromDynamic(
    dynamic jsonString,
  ) {
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

  static String getEmailFromDynamic(dynamic value) {
    final String email = value.toString();
    if (isEmail(email)) {
      return email;
    }
    return '';
  }

  static String getUrlFromDynamic(dynamic value) {
    final String url = value.toString();
    if (isValidUrl(url)) {
      return url;
    }
    return '';
  }

  static bool isEmail(String email) {
    final RegExp regex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$',
    );

    return regex.hasMatch(email);
  }

  static bool isValidUrl(String url) {
    final RegExp regex = RegExp(
      r'^(https?|ftp):\/\/[^\s\/$.?#].[^\s]*$',
    );
    return regex.hasMatch(url);
  }

  /// Converts a JSON string to a list of strings.
  ///
  /// [json] is the JSON string to be converted.
  ///
  /// Returns an empty list if the conversion fails.
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

  static String getStringFromDynamic(dynamic value) {
    return value?.toString() ?? '';
  }

  static int getIntegerFromDynamic(dynamic value) {
    return int.tryParse(value.toString()) ?? 0;
  }

  static String getJsonEncode(Map<String, dynamic> map) {
    try {
      return jsonEncode(map);
    } catch (e) {
      return <String, String>{'error': e.toString()}.toString();
    }
  }

  /// phoneNumbers formaters
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

  static String getFormatedPhoneNumberAlt(int numeroTelefono) {
    final String numeroString = numeroTelefono.toString().padLeft(10, '0');
    return '${numeroString.substring(0, 3)} ${numeroString.substring(3, 6)} ${numeroString.substring(6)}';
  }

  static double getDouble(
    dynamic json, [
    double defaultValue = double.nan,
  ]) {
    return double.tryParse(json.toString()) ?? defaultValue;
  }

  static bool getBoolFromDynamic(dynamic json) {
    return json == true;
  }

  /// Converts a dynamic value to a List of Map<String, dynamic>.
  ///
  /// [json] is the dynamic value to be converted.
  ///
  /// Returns an empty list if the conversion fails or if the value is not a list of maps.
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
