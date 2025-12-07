import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('Utils.duration (json/parse)', () {
    test('durationToJson returns milliseconds', () {
      const Duration d =
          Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 4);
      final int ms = Utils.durationToJson(d);
      expect(ms, 3723004);
    });

    test('fromMap: int/double/String (ms)', () {
      expect(Utils.durationFromJson(1500), const Duration(milliseconds: 1500));
      expect(
        Utils.durationFromJson(1500.9),
        const Duration(milliseconds: 1500),
      );
      expect(
        Utils.durationFromJson('2000'),
        const Duration(milliseconds: 2000),
      );
      expect(
        Utils.durationFromJson('2000.7'),
        const Duration(milliseconds: 2000),
      );
    });

    test('fromMap: HH:MM:SS[.fff] and MM:SS[.fff]', () {
      expect(
        Utils.durationFromJson('01:02:03'),
        const Duration(hours: 1, minutes: 2, seconds: 3),
      );
      expect(
        Utils.durationFromJson('00:01:30.250'),
        const Duration(minutes: 1, seconds: 30, milliseconds: 250),
      );
      // MM:SS
      expect(
        Utils.durationFromJson('12:05'),
        const Duration(minutes: 12, seconds: 5),
      );
      // Pad fractional digits to milliseconds
      expect(
        Utils.durationFromJson('00:00:00.5'),
        const Duration(milliseconds: 500),
      );
      expect(
        Utils.durationFromJson('00:00:00.12'),
        const Duration(milliseconds: 120),
      );
    });

    test('fromMap: ISO8601 subset P[nD]T[nH][nM][nS]', () {
      expect(
        Utils.durationFromJson('PT1H30M5S'),
        const Duration(hours: 1, minutes: 30, seconds: 5),
      );
      expect(
        Utils.durationFromJson('PT2H'),
        const Duration(hours: 2),
      );
      expect(
        Utils.durationFromJson('P1DT2H'), // 1 day + 2 hours = 26h
        const Duration(hours: 26),
      );
      expect(
        Utils.durationFromJson('PT0.25S'),
        const Duration(milliseconds: 250),
      );
    });

    test(
        'fromMap: shorthand "2h45m", "90m", "30s", "1h2m3.5s" (case-insensitive)',
        () {
      expect(
        Utils.durationFromJson('2h45m'),
        const Duration(hours: 2, minutes: 45),
      );
      expect(
        Utils.durationFromJson('90m'),
        const Duration(minutes: 90),
      );
      expect(
        Utils.durationFromJson('30s'),
        const Duration(seconds: 30),
      );
      expect(
        Utils.durationFromJson('1h2m3.5s'),
        const Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 500),
      );
      expect(
        Utils.durationFromJson('PT1H2M3S'.toLowerCase()),
        const Duration(hours: 1, minutes: 2, seconds: 3),
      );
    });

    test('fromMap: Duration input returned as-is', () {
      const Duration d = Duration(minutes: 5);
      expect(Utils.durationFromJson(d), same(d));
    });

    test('fromMap: invalid or null returns default', () {
      expect(Utils.durationFromJson(null), Duration.zero);
      expect(
        Utils.durationFromJson(
          'not a duration',
          defaultDuration: const Duration(seconds: 7),
        ),
        const Duration(seconds: 7),
      );
      expect(
        Utils.durationFromJson(
          double.nan,
          defaultDuration: const Duration(milliseconds: 123),
        ),
        const Duration(milliseconds: 123),
      );
    });
  });
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
        Utils.getFormatedPhoneNumberAlt(5555555555),
        equals('555 555 5555'),
      );
    });

    test('Formato correcto para número de teléfono con menos de 10 dígitos',
        () {
      expect(Utils.getFormatedPhoneNumberAlt(8923465), equals('000 892 3465'));
    });

    test('Formato correcto para número de teléfono con 10 dígitos', () {
      expect(
        Utils.getFormatedPhoneNumberAlt(3000000000),
        equals('300 000 0000'),
      );
    });

    test(
        'Formato correcto para número de teléfono con todos los dígitos como ceros',
        () {
      expect(Utils.getFormatedPhoneNumberAlt(0), equals('000 000 0000'));
    });
  });
  group('getDouble Tests', () {
    test('Correctly parses valid double string', () {
      expect(Utils.getDouble('123.45'), 123.45);
    });

    test('Returns NaN for invalid double string', () {
      expect(Utils.getDouble('not_a_double'), isNaN);
    });

    test('Handles null input', () {
      expect(Utils.getDouble(null), isNaN);
    });
  });

  group('getBoolFromDynamic Tests', () {
    test('Returns true for true boolean', () {
      expect(Utils.getBoolFromDynamic(true), isTrue);
    });

    test('Returns false for false boolean', () {
      expect(Utils.getBoolFromDynamic(false), isFalse);
    });

    test('Returns false for non-boolean values', () {
      expect(Utils.getBoolFromDynamic('true'), isFalse);
      expect(Utils.getBoolFromDynamic(1), isFalse);
      expect(Utils.getBoolFromDynamic(null), isFalse);
    });
  });

  group('Utils.listFromDynamic', () {
    test('returns a list of maps when input is a list of Map<String, dynamic>',
        () {
      final List<Map<String, String>> input = <Map<String, String>>[
        <String, String>{'key1': 'value1'},
        <String, String>{'key2': 'value2'},
      ];

      final List<Map<String, dynamic>> result = Utils.listFromDynamic(input);

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result, equals(input));
    });

    test('returns an empty list when input is a list of non-map elements', () {
      final List<Object> input = <Object>[1, 2, 3, 'string'];

      final List<Map<String, dynamic>> result = Utils.listFromDynamic(input);

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.isEmpty, isTrue);
    });

    test('returns an empty list when input is not a list', () {
      const String input = 'this is a string';

      final List<Map<String, dynamic>> result = Utils.listFromDynamic(input);

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.isEmpty, isTrue);
    });

    test('returns an empty list when input is null', () {
      final List<Map<String, dynamic>> result = Utils.listFromDynamic(null);

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.isEmpty, isTrue);
    });

    test('returns only maps from a mixed list', () {
      final List<Object> input = <Object>[
        <String, String>{'key1': 'value1'},
        2,
        <String, String>{'key2': 'value2'},
        'string',
      ];

      final List<Map<String, dynamic>> result = Utils.listFromDynamic(input);

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(
        result,
        equals(<Map<String, String>>[
          <String, String>{'key1': 'value1'},
          <String, String>{'key2': 'value2'},
        ]),
      );
    });
  });

  group('Utils - robust numeric parsing (no regressions)', () {
    group('getIntegerFromDynamic', () {
      test('null, NaN e infinitos degradan a 0', () {
        expect(Utils.getIntegerFromDynamic(null), 0);
        expect(Utils.getIntegerFromDynamic(double.nan), 0);
        expect(Utils.getIntegerFromDynamic(double.infinity), 0);
        expect(Utils.getIntegerFromDynamic(double.negativeInfinity), 0);
      });

      test('int y double (truncate toward zero) se manejan correctamente', () {
        expect(Utils.getIntegerFromDynamic(42), 42);
        expect(Utils.getIntegerFromDynamic(42.9), 42);
        expect(Utils.getIntegerFromDynamic(-42.9), -42);
      });

      test('strings limpias y notación científica', () {
        expect(Utils.getIntegerFromDynamic('300'), 300);
        expect(Utils.getIntegerFromDynamic('3e2'), 300);
        expect(Utils.getIntegerFromDynamic('+3e2'), 300);
        expect(Utils.getIntegerFromDynamic('-3e2'), -300);
        expect(Utils.getIntegerFromDynamic('12.5'), 12); // trunca
        expect(Utils.getIntegerFromDynamic('12,5'), 12); // trunca
      });

      test('moneda, miles y locales mezclados', () {
        expect(Utils.getIntegerFromDynamic(r'  $1,234.56  '), 1234);
        expect(Utils.getIntegerFromDynamic('1.234,56'), 1234);
        expect(Utils.getIntegerFromDynamic('1,234,567'), 1234567);
        expect(Utils.getIntegerFromDynamic('1.234.567'), 1234567);
        expect(
          Utils.getIntegerFromDynamic('1,234.5'),
          1234,
        ); // último sep. como decimal
        expect(
          Utils.getIntegerFromDynamic('1.234,5'),
          1234,
        ); // último sep. como decimal
        expect(Utils.getIntegerFromDynamic('1\u00A0234,5'), 1234); // NBSP
        expect(Utils.getIntegerFromDynamic('-1,234.5'), -1234);
      });

      test('no numéricos degradan a 0', () {
        expect(Utils.getIntegerFromDynamic('—'), 0);
        expect(Utils.getIntegerFromDynamic('abc'), 0);
        expect(Utils.getIntegerFromDynamic('.'), 0);
        expect(Utils.getIntegerFromDynamic('-'), 0);
      });
    });

    group('getDouble', () {
      test(
          'null y valores no parseables respetan defaultValue (NaN por defecto)',
          () {
        expect(Utils.getDouble(null).isNaN, isTrue);
        expect(Utils.getDouble('not_a_double').isNaN, isTrue);
        expect(Utils.getDouble('.', 0.0), 0.0);
        expect(Utils.getDouble('-', 0.0), 0.0);
      });

      test('NaN e infinitos se degradan al defaultValue', () {
        expect(Utils.getDouble(double.nan, 0.0), 0.0);
        expect(Utils.getDouble(double.infinity, 0.0), 0.0);
        expect(Utils.getDouble(double.negativeInfinity, 0.0), 0.0);
      });

      test('num y strings numéricos se parsean correctamente', () {
        expect(Utils.getDouble(10), 10.0);
        expect(Utils.getDouble(10.5), 10.5);
        expect(Utils.getDouble('123.45'), 123.45);
        expect(Utils.getDouble('12,5'), 12.5); // coma decimal
        expect(Utils.getDouble('3e-2'), closeTo(0.03, 1e-12));
        expect(Utils.getDouble('+3e2'), 300.0);
        expect(Utils.getDouble('-3e2'), -300.0);
      });

      test('moneda, miles y espacios no convencionales', () {
        expect(Utils.getDouble(r'  $1,234.56  '), 1234.56);
        expect(Utils.getDouble('1.234,56'), 1234.56);
        expect(Utils.getDouble('1,234.56'), 1234.56);
        expect(Utils.getDouble('1\u00A0234,56'), 1234.56); // NBSP
        expect(Utils.getDouble('-1,234.5'), -1234.5);
      });

      test('cuando hay coma y punto, el último actúa como decimal', () {
        expect(Utils.getDouble('1,234.5'), 1234.5); // último: punto
        expect(Utils.getDouble('1.234,5'), 1234.5); // último: coma
      });
    });
  });

  group('listFromDynamic (branch else-if: Map<dynamic,dynamic>)', () {
    test(
        'Given list with Map<dynamic,dynamic> When parse Then normalizes keys to String',
        () {
      // Arrange
      final List<dynamic> input = <dynamic>[
        <dynamic, dynamic>{1: 'a', true: 2}, // claves no String
        <dynamic, dynamic>{'x': 10, 99: 'y'},
      ];

      // Act
      final List<Map<String, dynamic>> out = Utils.listFromDynamic(input);

      // Assert
      expect(
        out,
        equals(<Map<String, dynamic>>[
          <String, dynamic>{'1': 'a', 'true': 2},
          <String, dynamic>{'x': 10, '99': 'y'},
        ]),
      );
    });

    test(
        'Given mixed list with non-Map items When parse Then ignores non-Map items',
        () {
      final List<dynamic> input = <dynamic>[
        <dynamic, dynamic>{0: 'zero'},
        'not a map',
        null,
        123,
        <dynamic, dynamic>{'ok': true},
      ];

      final List<Map<String, dynamic>> out = Utils.listFromDynamic(input);

      expect(
        out,
        equals(<Map<String, dynamic>>[
          <String, dynamic>{'0': 'zero'},
          <String, dynamic>{'ok': true},
        ]),
      );
    });

    test(
        'Given Map<dynamic,dynamic> with nested structures When parse Then keeps values as-is',
        () {
      final List<dynamic> input = <dynamic>[
        <dynamic, dynamic>{
          'nested': <String, dynamic>{'a': 1},
          'list': <dynamic>[
            1,
            2,
            <String, dynamic>{'k': 'v'},
          ],
        },
      ];

      final List<Map<String, dynamic>> out = Utils.listFromDynamic(input);

      expect(out.length, 1);
      expect(out.first.keys, containsAll(<String>['nested', 'list']));
      expect(out.first['nested'], isA<Map<String, dynamic>>());
      expect(out.first['list'], isA<List<dynamic>>());
    });

    test(
        'Given empty Map<dynamic,dynamic> When parse Then returns empty normalized map entry',
        () {
      final List<dynamic> input = <dynamic>[<dynamic, dynamic>{}];

      final List<Map<String, dynamic>> out = Utils.listFromDynamic(input);

      expect(out, equals(<Map<String, dynamic>>[<String, dynamic>{}]));
    });
  });

  group('mapFromDynamic (all branches & edge cases)', () {
    test(
        'Given Map<String,dynamic> When passed Then returns same instance (no copy)',
        () {
      // Arrange
      final Map<String, dynamic> m = <String, dynamic>{'a': 1, 'b': true};

      // Act
      final Map<String, dynamic> out = Utils.mapFromDynamic(m);

      // Assert
      expect(identical(out, m), isTrue, reason: 'Debe retornar el mismo mapa');
      expect(out, equals(m));
    });

    test(
        'Given Map<dynamic,dynamic> When passed Then normalizes keys to String',
        () {
      final Map<dynamic, dynamic> raw = <dynamic, dynamic>{
        1: 'x',
        true: 7,
        'k': <String, dynamic>{'nested': 1},
      };

      final Map<String, dynamic> out = Utils.mapFromDynamic(raw);

      expect(
        out,
        equals(<String, dynamic>{
          '1': 'x',
          'true': 7,
          'k': <String, dynamic>{'nested': 1},
        }),
      );
    });

    test('Given JSON string (object) When decodes Then returns normalized map',
        () {
      const String json = '{"a":1,"b":false,"c":{"d":2},"e":[1,2,3]}';

      final Map<String, dynamic> out = Utils.mapFromDynamic(json);

      expect(out['a'], 1);
      expect(out['b'], false);
      expect(out['c'], isA<Map<String, dynamic>>());
      expect(out['e'], isA<List<dynamic>>());
    });

    test(
        'Given JSON string with whitespace/unicode When decodes Then returns map',
        () {
      const String json = '  {  " título ": "Ok",  "π": 3.14 }  ';

      final Map<String, dynamic> out = Utils.mapFromDynamic(json);

      expect(out, equals(<String, dynamic>{' título ': 'Ok', 'π': 3.14}));
    });

    test('Given non-JSON string When decode fails Then returns empty map', () {
      final Map<String, dynamic> out = Utils.mapFromDynamic('not-json');
      expect(out, isEmpty);
    });

    test('Given JSON that is not a Map (number) Then returns empty map', () {
      // jsonDecode('123') -> 123 (num), no es Map => {}
      final Map<String, dynamic> out = Utils.mapFromDynamic('123');
      expect(out, isEmpty);
    });

    test('Given JSON that is not a Map (list) Then returns empty map', () {
      // jsonDecode('[1,2]') -> List, no es Map => {}
      final Map<String, dynamic> out = Utils.mapFromDynamic('[1,2]');
      expect(out, isEmpty);
    });

    test(
        'Given non-string non-map whose toString() is valid JSON map Then decodes it',
        () {
      final Map<String, dynamic> out =
          Utils.mapFromDynamic(_JsonLikeToString());
      expect(out, equals(<String, dynamic>{'fromToString': 42}));
    });

    test(
        'Given null When toString -> "null" Then jsonDecode returns null => not a Map => {}',
        () {
      final Map<String, dynamic> out = Utils.mapFromDynamic(null);
      expect(out, isEmpty);
    });

    test(
        'Given empty map literal {} When passed Then returns same (identity true)',
        () {
      final Map<String, dynamic> empty = <String, dynamic>{};
      final Map<String, dynamic> out = Utils.mapFromDynamic(empty);
      expect(identical(out, empty), isTrue);
      expect(out, isEmpty);
    });

    test(
        'Given Map<dynamic,dynamic> with complex nested values Then only keys are normalized',
        () {
      final Map<dynamic, dynamic> raw = <dynamic, dynamic>{
        9: <dynamic, dynamic>{
          'inner': <String, dynamic>{'x': 1},
          'list': <dynamic>[
            1,
            <String, dynamic>{'k': 'v'},
          ],
        },
      };

      final Map<String, dynamic> out = Utils.mapFromDynamic(raw);

      expect(out.keys, equals(<String>['9']));
      expect(out['9'], isA<Map<dynamic, dynamic>>());
      final Map<dynamic, dynamic> nested = out['9'] as Map<dynamic, dynamic>;
      expect(nested['inner'], isA<Map<String, dynamic>>());
      expect(nested['list'], isA<List<dynamic>>());
    });

    test(
        'Given String that is JSON object with non-ASCII keys Then keys remain as decoded strings',
        () {
      final String json = jsonEncode(<String, dynamic>{'á': 1, '世': 2});
      final Map<String, dynamic> out = Utils.mapFromDynamic(json);
      expect(out, equals(<String, dynamic>{'á': 1, '世': 2}));
    });
  });
  group('Utils.listEquals', () {
    test(
      'Given same instance When compared Then returns true (fast-path)',
      () {
        final List<int> a = <int>[1, 2, 3];
        expect(Utils.listEquals<int>(a, a), isTrue);
      },
    );

    test(
      'Given equal content and order When compared Then returns true',
      () {
        final List<String> a = <String>['x', 'y'];
        final List<String> b = <String>['x', 'y'];
        expect(Utils.listEquals<String>(a, b), isTrue);
      },
    );

    test(
      'Given equal content but different order When compared Then returns false',
      () {
        final List<int> a = <int>[1, 2, 3];
        final List<int> b = <int>[3, 2, 1];
        expect(Utils.listEquals<int>(a, b), isFalse);
      },
    );

    test(
      'Given different lengths When compared Then returns false',
      () {
        final List<int> a = <int>[1, 2, 3];
        final List<int> b = <int>[1, 2, 3, 4];
        expect(Utils.listEquals<int>(a, b), isFalse);
      },
    );

    test(
      'Given null elements When same pattern Then returns true',
      () {
        final List<String?> a = <String?>['a', null, 'c'];
        final List<String?> b = <String?>['a', null, 'c'];
        expect(Utils.listEquals<String?>(a, b), isTrue);
      },
    );

    test(
      'Given custom equality type When same values Then returns true',
      () {
        final List<Box> a = <Box>[const Box(1), const Box(2)];
        final List<Box> b = <Box>[const Box(1), const Box(2)];
        expect(Utils.listEquals<Box>(a, b), isTrue);
      },
    );

    test(
      'Given NaN at same index When compared Then returns false (IEEE754)',
      () {
        final List<double> a = <double>[double.nan];
        final List<double> b = <double>[double.nan];
        expect(Utils.listEquals<double>(a, b), isFalse);
      },
    );
  });

  group('Utils.listHash', () {
    test(
      'Given equal lists per listEquals When hashed Then hashes are equal',
      () {
        final List<int> a = <int>[1, 2, 3];
        final List<int> b = <int>[1, 2, 3];
        expect(Utils.listEquals<int>(a, b), isTrue);
        expect(Utils.listHash<int>(a), equals(Utils.listHash<int>(b)));
      },
    );

    test(
      'Given different order When hashed Then hashes typically differ',
      () {
        final List<String> a = <String>['a', 'b', 'c'];
        final List<String> b = <String>['c', 'b', 'a'];
        expect(Utils.listEquals<String>(a, b), isFalse);
        expect(Utils.listHash<String>(a) == Utils.listHash<String>(b), isFalse);
      },
    );

    test(
      'Given null elements When hashed Then does not throw and is deterministic',
      () {
        final List<String?> a = <String?>['a', null, 'c'];
        final int h1 = Utils.listHash<String?>(a);
        final int h2 = Utils.listHash<String?>(a);
        expect(h1, equals(h2));
      },
    );

    test(
      'Given custom equality/HashCode When equal Then hashes match',
      () {
        final List<Box> a = <Box>[const Box(7), const Box(9)];
        final List<Box> b = <Box>[const Box(7), const Box(9)];
        expect(Utils.listEquals<Box>(a, b), isTrue);
        expect(Utils.listHash<Box>(a), equals(Utils.listHash<Box>(b)));
      },
    );

    test(
      'Given shallow structure When elements are lists Then uses element hashCode (no deep hash)',
      () {
        final List<List<int>> a = <List<int>>[
          <int>[1, 2],
          <int>[3],
        ];
        final List<List<int>> b = <List<int>>[
          <int>[1, 2],
          <int>[3],
        ];

        // By default List== is identity; these are different instances.
        expect(Utils.listEquals<List<int>>(a, b), isFalse);

        // Hash will also differ in general (because element hashCodes differ).
        expect(
          Utils.listHash<List<int>>(a) == Utils.listHash<List<int>>(b),
          isFalse,
        );
      },
    );
  });

  group('Utils.enumFromJson', () {
    test(
      'Given valid enum name When enumFromJson is called Then returns matching value',
      () {
        // Arrange
        const _TestStatus fallback = _TestStatus.disabled;

        // Act
        final _TestStatus result = Utils.enumFromJson<_TestStatus>(
          _TestStatus.values,
          'active',
          fallback,
        );

        // Assert
        expect(result, _TestStatus.active);
      },
    );

    test(
      'Given null raw value When enumFromJson is called Then returns fallback',
      () {
        // Arrange
        const _TestStatus fallback = _TestStatus.disabled;

        // Act
        final _TestStatus result = Utils.enumFromJson<_TestStatus>(
          _TestStatus.values,
          null,
          fallback,
        );

        // Assert
        expect(result, fallback);
      },
    );

    test(
      'Given unknown enum name When enumFromJson is called Then returns fallback',
      () {
        // Arrange
        const _TestStatus fallback = _TestStatus.pending;

        // Act
        final _TestStatus result = Utils.enumFromJson<_TestStatus>(
          _TestStatus.values,
          'unknown_status',
          fallback,
        );

        // Assert
        expect(result, fallback);
      },
    );

    test(
      'Given same name with different case When enumFromJson is called Then returns fallback (case-sensitive)',
      () {
        // Arrange
        const _TestStatus fallback = _TestStatus.pending;

        // Act
        final _TestStatus result = Utils.enumFromJson<_TestStatus>(
          _TestStatus.values,
          'ACTIVE', // different case
          fallback,
        );

        // Assert
        expect(result, fallback);
      },
    );
  });

  group('Utils.stringListFromDynamic', () {
    test(
      'Given null value When stringListFromDynamic is called Then returns empty list',
      () {
        // Act
        final List<String> result = Utils.stringListFromDynamic(null);

        // Assert
        expect(result, isEmpty);
      },
    );

    test(
      'Given List<String> value When stringListFromDynamic is called Then returns same string contents',
      () {
        // Arrange
        final List<String> source = <String>['a', 'b', 'c'];

        // Act
        final List<String> result = Utils.stringListFromDynamic(source);

        // Assert
        expect(result, <String>['a', 'b', 'c']);
      },
    );

    test(
      'Given List<dynamic> value When stringListFromDynamic is called Then converts all elements with toString',
      () {
        // Arrange
        final List<dynamic> source = <dynamic>['x', 1, true, null];

        // Act
        final List<String> result = Utils.stringListFromDynamic(source);

        // Assert
        expect(result, <String>['x', '1', 'true', 'null']);
      },
    );

    test(
      'Given JSON array string When stringListFromDynamic is called Then parses and stringifies elements',
      () {
        // Arrange
        const String jsonArray = '["foo", 2, false]';

        // Act
        final List<String> result = Utils.stringListFromDynamic(jsonArray);

        // Assert
        expect(result, <String>['foo', '2', 'false']);
      },
    );

    test(
      'Given scalar number When stringListFromDynamic is called Then wraps it into single-element list',
      () {
        // Arrange
        const int scalar = 42;

        // Act
        final List<String> result = Utils.stringListFromDynamic(scalar);

        // Assert
        expect(result, <String>['42']);
      },
    );

    test(
      'Given non-JSON string When stringListFromDynamic is called Then returns empty list',
      () {
        // Arrange
        const String invalidJson = 'not a json';

        // Act
        final List<String> result = Utils.stringListFromDynamic(invalidJson);

        // Assert
        expect(result, isEmpty);
      },
    );
  });
}

class _JsonLikeToString {
  @override
  String toString() => '{"fromToString":42}';
}

@immutable
class Box {
  const Box(this.v);

  final int v;

  @override
  bool operator ==(Object other) => other is Box && other.v == v;

  @override
  int get hashCode => v.hashCode ^ 0x9e3779b1;
}

/// Local enum used only for testing [Utils.enumFromJson].
enum _TestStatus { pending, active, disabled }
