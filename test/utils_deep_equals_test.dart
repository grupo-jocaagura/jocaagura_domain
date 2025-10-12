import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('Utils.deepEqualsDynamic', () {
    test('Given identical reference When compared Then returns true', () {
      // Arrange
      final List<int> list = <int>[1, 2, 3];

      // Act
      final bool eq = Utils.deepEqualsDynamic(list, list);

      // Assert
      expect(eq, isTrue);
    });

    test('Given equal primitives When compared Then returns true', () {
      expect(Utils.deepEqualsDynamic(42, 42), isTrue);
      expect(Utils.deepEqualsDynamic('hi', 'hi'), isTrue);
      expect(Utils.deepEqualsDynamic(true, true), isTrue);
    });

    test('Given different primitives When compared Then returns false', () {
      expect(Utils.deepEqualsDynamic(1, 2), isFalse);
      expect(Utils.deepEqualsDynamic('a', 'b'), isFalse);
      expect(Utils.deepEqualsDynamic(true, false), isFalse);
    });

    test('Given lists with same order When compared Then returns true', () {
      final List<int> a = <int>[1, 2, 3];
      final List<int> b = <int>[1, 2, 3];

      expect(Utils.deepEqualsDynamic(a, b), isTrue);
    });

    test('Given lists with different order When compared Then returns false',
        () {
      final List<int> a = <int>[1, 2, 3];
      final List<int> b = <int>[3, 2, 1];

      expect(Utils.deepEqualsDynamic(a, b), isFalse);
    });

    test('Given lists with different length When compared Then returns false',
        () {
      final List<int> a = <int>[1, 2];
      final List<int> b = <int>[1, 2, 3];

      expect(Utils.deepEqualsDynamic(a, b), isFalse);
    });

    test('Given nested lists & maps equal When compared Then returns true', () {
      final dynamic a = <dynamic>[
        <String, dynamic>{
          'k': 'v',
          'n': <int>[1, 2],
        },
        <String, dynamic>{
          'x': <String, dynamic>{'y': 1},
        }
      ];
      final dynamic b = <dynamic>[
        <String, dynamic>{
          'k': 'v',
          'n': <int>[1, 2],
        },
        <String, dynamic>{
          'x': <String, dynamic>{'y': 1},
        }
      ];

      expect(Utils.deepEqualsDynamic(a, b), isTrue);
    });

    test('Given nested lists & maps different When compared Then returns false',
        () {
      final dynamic a = <dynamic>[
        <String, dynamic>{
          'k': 'v',
          'n': <int>[1, 2],
        },
      ];
      final dynamic b = <dynamic>[
        <String, dynamic>{
          'k': 'v',
          'n': <int>[1, 3],
        },
      ];

      expect(Utils.deepEqualsDynamic(a, b), isFalse);
    });

    test('Given two NaNs at same position When compared Then returns false',
        () {
      final List<double> a = <double>[double.nan];
      final List<double> b = <double>[double.nan];

      expect(Utils.deepEqualsDynamic(a, b), isFalse);
    });

    test('Given -0.0 and 0.0 When compared Then returns true (Dart semantics)',
        () {
      expect(Utils.deepEqualsDynamic(-0.0, 0.0), isTrue);
    });

    test(
        'Given raw Map with non-string keys When compared Then returns true after normalization',
        () {
      // Left is already string-keyed, right is raw/dynamic-keyed.
      final Map<String, dynamic> left = <String, dynamic>{'1': 'a'};
      final Map<dynamic, dynamic> right = <dynamic, dynamic>{1: 'a'};

      // deepEqualsDynamic normalizes both sides via mapFromDynamic for maps.
      expect(Utils.deepEqualsDynamic(left, right), isTrue);
    });

    test(
        'Given maps with key collision after stringification When compared Then reflects collision',
        () {
      // Both non-string keys stringify to the same '1'
      final Map<dynamic, dynamic> m1 = <dynamic, dynamic>{1: 'a'};
      final Map<dynamic, dynamic> m2 = <dynamic, dynamic>{'1': 'a'};

      // After normalization both become {'1': 'a'} → equal
      expect(Utils.deepEqualsDynamic(m1, m2), isTrue);
    });

    test('Given different types (map vs list) When compared Then returns false',
        () {
      expect(Utils.deepEqualsDynamic(<String, int>{'a': 1}, <int>[1]), isFalse);
    });
  });

  group('Utils.deepEqualsMap', () {
    test('Given identical map reference When compared Then returns true', () {
      final Map<String, dynamic> a = <String, dynamic>{'x': 1};
      expect(Utils.deepEqualsMap(a, a), isTrue);
    });

    test(
        'Given same key-value pairs different order When compared Then returns true',
        () {
      final Map<String, dynamic> a = <String, dynamic>{'a': 1, 'b': 2};
      final Map<String, dynamic> b = <String, dynamic>{'b': 2, 'a': 1};

      expect(Utils.deepEqualsMap(a, b), isTrue);
    });

    test('Given different key sets When compared Then returns false', () {
      final Map<String, dynamic> a = <String, dynamic>{'a': 1};
      final Map<String, dynamic> b = <String, dynamic>{'a': 1, 'b': 2};

      expect(Utils.deepEqualsMap(a, b), isFalse);
    });

    test(
        'Given same keys but different values When compared Then returns false',
        () {
      final Map<String, dynamic> a = <String, dynamic>{
        'k': <int>[1, 2, 3],
      };
      final Map<String, dynamic> b = <String, dynamic>{
        'k': <int>[1, 2, 4],
      };

      expect(Utils.deepEqualsMap(a, b), isFalse);
    });

    test('Given nested structures equal When compared Then returns true', () {
      final Map<String, dynamic> a = <String, dynamic>{
        'user': <String, dynamic>{'id': 1, 'name': 'Ana'},
        'tags': <String>['a', 'b'],
      };
      final Map<String, dynamic> b = <String, dynamic>{
        'tags': <String>['a', 'b'],
        'user': <String, dynamic>{'id': 1, 'name': 'Ana'},
      };

      expect(Utils.deepEqualsMap(a, b), isTrue);
    });

    test('Given value is NaN in both maps When compared Then returns false',
        () {
      final Map<String, dynamic> a = <String, dynamic>{'n': double.nan};
      final Map<String, dynamic> b = <String, dynamic>{'n': double.nan};

      // deepEqualsDynamic ultimately uses == for primitives → NaN != NaN
      expect(Utils.deepEqualsMap(a, b), isFalse);
    });

    test('Given normalized dynamic maps When compared Then returns expected',
        () {
      // Simulate callers that forgot to normalize before calling deepEqualsMap.
      // Enforce normalization and then compare.
      final Map<String, dynamic> a =
          Utils.mapFromDynamic(<dynamic, dynamic>{1: 'x', 'b': 2});
      final Map<String, dynamic> b =
          Utils.mapFromDynamic(<dynamic, dynamic>{'1': 'x', 'b': 2});

      expect(Utils.deepEqualsMap(a, b), isTrue);
    });
  });

  group('Utils.deepEqualsDynamic – números especiales', () {
    test('NaN en la misma posición en listas → false', () {
      final List<double> a = <double>[double.nan];
      final List<double> b = <double>[double.nan];
      expect(Utils.deepEqualsDynamic(a, b), isFalse);
    });

    test('NaN en el mismo key de mapas → false', () {
      final Map<String, dynamic> a = <String, dynamic>{'n': double.nan};
      final Map<String, dynamic> b = <String, dynamic>{'n': double.nan};
      expect(Utils.deepEqualsMap(a, b), isFalse);
    });

    test('Infinity (mismo signo) se considera igual', () {
      final List<double> a = <double>[double.infinity];
      final List<double> b = <double>[double.infinity];
      expect(Utils.deepEqualsDynamic(a, b), isTrue);
    });

    test('Infinity con signos opuestos → false', () {
      final List<double> a = <double>[double.infinity];
      final List<double> b = <double>[-double.infinity];
      expect(Utils.deepEqualsDynamic(a, b), isFalse);
    });

    test('-0.0 y 0.0 son iguales en Dart', () {
      final List<double> a = <double>[-0.0];
      final List<double> b = <double>[0.0];
      expect(Utils.deepEqualsDynamic(a, b), isTrue);
    });

    test('int 1 y double 1.0 son iguales', () {
      final List<dynamic> a = <dynamic>[1];
      final List<dynamic> b = <dynamic>[1.0];
      expect(Utils.deepEqualsDynamic(a, b), isTrue);
    });

    test('NaN anidado dentro de estructura compleja → false', () {
      final Map<String, dynamic> a = <String, dynamic>{
        'list': <dynamic>[
          1,
          <String, dynamic>{'x': double.nan},
        ],
      };
      final Map<String, dynamic> b = <String, dynamic>{
        'list': <dynamic>[
          1,
          <String, dynamic>{'x': double.nan},
        ],
      };
      expect(Utils.deepEqualsDynamic(a, b), isFalse);
    });
  });

  group('Utils.deepEqualsMap – orden de llaves irrelevante', () {
    test('Mismas llaves diferente orden → true si valores iguales', () {
      final Map<String, dynamic> a = <String, dynamic>{
        'x': <int>[1, 2],
        'y': 3.0,
      };
      final Map<String, dynamic> b = <String, dynamic>{
        'y': 3,
        'x': <int>[1, 2],
      };
      expect(Utils.deepEqualsMap(a, b), isTrue);
    });

    test('Lista con diferente orden → false', () {
      final Map<String, dynamic> a = <String, dynamic>{
        'x': <int>[1, 2],
      };
      final Map<String, dynamic> b = <String, dynamic>{
        'x': <int>[2, 1],
      };
      expect(Utils.deepEqualsMap(a, b), isFalse);
    });
  });
}
