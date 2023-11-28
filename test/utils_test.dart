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

    test('getUrlFromMap with segments is valid', () {
      final Map<String, String> validUrlMap = <String, String>{
        'url': 'https://example.com/photo.jpg',
        'urly': 'https://www.youtube.com/watch?v=x3G_-Jbb4Sw',
      };

      final String url = Utils.getUrlFromDynamic(validUrlMap['url']);
      final String url2 = Utils.getUrlFromDynamic(validUrlMap['url2']);
      final String url3 = Utils.getUrlFromDynamic(validUrlMap['urly']);

      expect(url, 'https://example.com/photo.jpg');
      expect(url3, 'https://www.youtube.com/watch?v=x3G_-Jbb4Sw');
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

    test('isValidUrl should return true for valid URLs', () {
      const String validUrl = 'https://example.com';
      const String validUrl2 = 'https://example.com/photo.jpg';
      const String validUrl3 = 'https://www.youtube.com/watch?v=x3G_-Jbb4Sw';

      expect(Utils.isValidUrl(validUrl), true);
      expect(Utils.isValidUrl(validUrl2), true);
      expect(Utils.isValidUrl(validUrl3), true);
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

  group('Testing String from dynamic', () {
    const String name = 'joao';
    const int number = 123;
    final Map<String, dynamic> valueMap = <String, dynamic>{
      'name': name,
      'number': number,
    };
    test('return empty from null', () {
      final String testString =
          Utils.getStringFromDynamic(valueMap['Non existing']);
      expect(testString, '');
    });
    test('return number to String', () {
      final String testString = Utils.getStringFromDynamic(valueMap['number']);
      expect(testString, number.toString());
    });
    test('return String from string', () {
      final String testString = Utils.getStringFromDynamic(valueMap['name']);
      expect(testString, name);
    });
  });

  group('Testing integer numbers from dynamic', () {
    const String name = 'joao';
    const int number = 123;
    final Map<String, dynamic> valueMap = <String, dynamic>{
      'name': name,
      'number': number,
    };
    test('return 0 from null', () {
      final int testNumber =
          Utils.getIntegerFromDynamic(valueMap['Non existing']);
      expect(testNumber, 0);
    });
    test('return number from number', () {
      final int testNumber = Utils.getIntegerFromDynamic(valueMap['number']);
      expect(testNumber, number);
    });
    test('return 0 from string', () {
      final int testNumber = Utils.getIntegerFromDynamic(valueMap['name']);
      expect(testNumber, 0);
    });
  });

  group('Json encode and decode', () {
    test('jsonEncode should encode a map correctly', () {
      final Map<String, dynamic> inputMap = <String, dynamic>{'key': 'value'};
      final String encodedJson = Utils.getJsonEncode(inputMap);

      expect(encodedJson, '{"key":"value"}');
    });
  });

  group('Utils', () {
    test('jsonEncode should throw an exception with invalid input', () {
      final Map<String, dynamic> invalidInput = <String, dynamic>{
        'name': <dynamic, DateTime>{null: DateTime.now()},
      };

      final String result = Utils.getJsonEncode(invalidInput);

      expect(
        result.contains('error'),
        isTrue,
      );
    });
  });

  group('Formatted numbers', () {
    test('Formato correcto para número de teléfono válido', () {
      expect(
        Utils.getFormatedPhoneNumber(6018923465),
        equals('(60) 1 892 3465'),
      );
    });

    test(
        'Formato correcto para número de teléfono válido con menos de 10 dígitos',
        () {
      expect(Utils.getFormatedPhoneNumber(8923465), equals('(00) 0 892 3465'));
    });

    test(
        'Formato correcto para número de teléfono válido con 10 dígitos pero prefijo inválido',
        () {
      expect(
        Utils.getFormatedPhoneNumber(1234567890),
        equals('(12) 3 456 7890'),
      );
    });

    test(
        'Formato correcto para número de teléfono con todos los dígitos iguales',
        () {
      expect(
        Utils.getFormatedPhoneNumber(5555555555),
        equals('(55) 5 555 5555'),
      );
    });

    test(
        'Formato correcto para número de teléfono con todos los dígitos iguales',
        () {
      expect(
          Utils.getFormatedPhoneNumberAlt(5555555555), equals('555 555 5555'));
    });

    test('Formato correcto para número de teléfono con menos de 10 dígitos',
        () {
      expect(Utils.getFormatedPhoneNumberAlt(8923465), equals('000 892 3465'));
    });

    test('Formato correcto para número de teléfono con 10 dígitos', () {
      expect(
          Utils.getFormatedPhoneNumberAlt(3000000000), equals('300 000 0000'));
    });

    test(
        'Formato correcto para número de teléfono con todos los dígitos como ceros',
        () {
      expect(Utils.getFormatedPhoneNumberAlt(0), equals('000 000 0000'));
    });
  });
}
