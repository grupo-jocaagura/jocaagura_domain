part of 'jocaagura_domain.dart';

class Utils {
  static String mapToString(Map<String, dynamic> inputMap) {
    return jsonEncode(inputMap);
  }

  /// Converts a string to a [Map].
  ///
  /// [source] is the string to be converted to a [Map].
  ///
  /// Returns an empty [Map] by default. Override this method to customize
  /// the conversion of your entity model.
  static Map<String, dynamic> mapFromString(
    dynamic jsonString,
  ) {
    if (jsonString is Map<String, dynamic>) {
      return jsonString;
    }

    try {
      final dynamic json = jsonDecode(jsonString.toString());
      if (json is Map) {
        final Map<String, dynamic> result = <String, dynamic>{};
        json.forEach((dynamic key, dynamic value) {
          result['$key'] = value;
        });
        return result;
      }
    } catch (e) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{};
  }

  static String getEmailFromMap(dynamic value) {
    final String email = value.toString();
    if (isEmail(email)) {
      return email;
    }
    return '';
  }

  static String getUrlFromMap(dynamic value) {
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
}
