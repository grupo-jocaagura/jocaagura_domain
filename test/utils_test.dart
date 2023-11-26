import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('Utils', () {
    test('mapToString should convert a map to a JSON string', () {
      final Map<String, String> inputMap = <String, String>{'key': 'value'};

      final String jsonString = Utils.mapToString(inputMap);

      expect(jsonString, '{"key":"value"}');
    });

    test('mapFromString should convert a JSON string to a map', () {
      const String jsonString = '{"key":"value"}';

      final Map<String, dynamic> resultMap = Utils.mapFromDynamic(jsonString);

      expect(resultMap, <String, String>{'key': 'value'});
    });

    test('trying to trigger an error should convert a JSON string to a map',
        () async {
      dynamic jsonString;
      final Map<String, dynamic> resultMap = Utils.mapFromDynamic(jsonString);
      expect(resultMap, <String, String>{});
    });

    test('getEmailFromMap should extract a valid email from a map', () {
      final Map<String, dynamic> validEmailMap = <String, dynamic>{
        'email': 'john@example.com',
      };

      final String email = Utils.getEmailFromDynamic(validEmailMap['email']);
      final String email2 = Utils.getEmailFromDynamic(validEmailMap['email2']);

      expect(email, 'john@example.com');
      expect(email2, '');
    });

    test('getEmailFromMap should return an empty string for an invalid email',
        () {
      final Map<String, String> invalidEmailMap = <String, String>{
        'email': 'invalid-email',
      };

      final String email = Utils.getEmailFromDynamic(invalidEmailMap);

      expect(email, '');
    });

    test('getUrlFromMap should extract a valid URL from a map', () {
      final Map<String, String> validUrlMap = <String, String>{
        'url': 'https://example.com',
      };

      final String url = Utils.getUrlFromDynamic(validUrlMap['url']);
      final String url2 = Utils.getUrlFromDynamic(validUrlMap['url2']);

      expect(url, 'https://example.com');
      expect(url2, '');
    });

    test('getUrlFromMap should return an empty string for an invalid URL', () {
      final Map<String, String> invalidUrlMap = <String, String>{
        'url': 'invalid-url',
      };

      final String url = Utils.getUrlFromDynamic(invalidUrlMap);

      expect(url, '');
    });

    test('isEmail should return true for a valid email', () {
      const String validEmail = 'john@example.com';

      final bool result = Utils.isEmail(validEmail);

      expect(result, true);
    });

    test('isEmail should return false for an invalid email', () {
      const String invalidEmail = 'invalid-email';

      final bool result = Utils.isEmail(invalidEmail);

      expect(result, false);
    });

    test('isValidUrl should return true for a valid URL', () {
      const String validUrl = 'https://example.com';

      final bool result = Utils.isValidUrl(validUrl);

      expect(result, true);
    });

    test('isValidUrl should return false for an invalid URL', () {
      const String invalidUrl = 'invalid-url';

      final bool result = Utils.isValidUrl(invalidUrl);

      expect(result, false);
    });
  });

  group('convertJsonToList', () {
    test('should return an empty list for null json', () {
      final List<String> result = Utils.convertJsonToList(null);
      expect(result, <String>[]);
    });

    test('should return an empty list for invalid json', () {
      const String invalidJson = 'invalid-json';
      final List<String> result = Utils.convertJsonToList(invalidJson);
      expect(result, <String>[]);
    });

    test('should return a list with one item for a single string json', () {
      const String singleStringJson = '"hello"';
      final List<String> result = Utils.convertJsonToList(singleStringJson);
      expect(result, <String>['hello']);
    });

    test('should return a list of strings for a valid list json', () {
      const String validListJson = '["item1", "item2", "item3"]';
      final List<String> result = Utils.convertJsonToList(validListJson);
      expect(result, <String>['item1', 'item2', 'item3']);
    });

    test('should return a list with one item for a valid non-list json', () {
      const String validNonListJson = '"hello"';
      final List<String> result = Utils.convertJsonToList(validNonListJson);
      expect(result, <String>['hello']);
    });
  });
}
