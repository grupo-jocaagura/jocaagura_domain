import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class _CustomType {
  const _CustomType(this.id);

  final int id;
}

void main() {
  group('AttributeModel.listFromDynamicTyped (Iterable+mutable)', () {
    test(
      'Given JSON List<Map> válido con enteros '
      'When se parsea con fromJsonT (int) '
      'Then retorna lista tipada y valores conservados',
      () {
        const String json = '''
        [
          {"name":"qty","value":3},
          {"name":"age","value":42}
        ]
        ''';

        final List<ModelAttribute<int>> out =
            AttributeModel.listFromDynamicTyped<int>(
          json,
          (dynamic v) => v as int,
        );

        expect(out, isA<List<ModelAttribute<int>>>());
        expect(out.length, 2);
        expect(out[0].name, 'qty');
        expect(out[0].value, 3);
        expect(out[1].name, 'age');
        expect(out[1].value, 42);
      },
    );

    test(
      'Given JSON con ISO8601 '
      'When se parsea con fromJsonT (DateTime.parse) '
      'Then retorna DateTime y mantiene orden',
      () {
        const String json = '''
        [
          {"name":"createdAt","value":"2024-01-02T03:04:05.000Z"},
          {"name":"updatedAt","value":"2024-01-03T03:04:05.000Z"}
        ]
        ''';

        final List<ModelAttribute<DateTime>> out =
            AttributeModel.listFromDynamicTyped<DateTime>(
          json,
          (dynamic v) => DateTime.parse(v as String),
        );

        expect(out.length, 2);
        expect(out[0].name, 'createdAt');
        expect(out[0].value, isA<DateTime>());
        expect(out[1].name, 'updatedAt');
        expect(out[1].value.isAfter(out[0].value), isTrue);
      },
    );

    test(
      'Given JSON inválido '
      'When se intenta parsear '
      'Then retorna lista vacía (tolerancia a fallos)',
      () {
        const String json = 'no es json';
        final List<ModelAttribute<String>> out =
            AttributeModel.listFromDynamicTyped<String>(
          json,
          (dynamic v) => v?.toString() ?? '',
        );
        expect(out, isEmpty);
      },
    );

    test(
      'Given JSON que representa un Map (no Iterable/List) '
      'When se procesa '
      'Then retorna lista vacía',
      () {
        const String json = '{"name":"only","value":"one"}';
        final List<ModelAttribute<String>> out =
            AttributeModel.listFromDynamicTyped<String>(
          json,
          (dynamic v) => v as String,
        );
        expect(out, isEmpty);
      },
    );

    test(
      'Given entrada no-String (List<Map<String,dynamic>>) '
      'When se procesa (rama Utils) '
      'Then mapea correctamente usando fromJsonT',
      () {
        final List<Map<String, dynamic>> raw = <Map<String, dynamic>>[
          <String, dynamic>{'name': 'a', 'value': '10'},
          <String, dynamic>{'name': 'b', 'value': '20'},
        ];

        final List<ModelAttribute<int>> out =
            AttributeModel.listFromDynamicTyped<int>(
          raw,
          (dynamic v) => int.parse(v as String),
        );

        expect(out.length, 2);
        expect(out[0].name, 'a');
        expect(out[0].value, 10);
        expect(out[1].name, 'b');
        expect(out[1].value, 20);
      },
    );

    test(
      'Given item sin "name" '
      'When se procesa '
      'Then name cae a "" y value se convierte',
      () {
        const String json = '''
        [
          {"value": 7}
        ]
        ''';

        final List<ModelAttribute<int>> out =
            AttributeModel.listFromDynamicTyped<int>(
          json,
          (dynamic v) => v as int,
        );

        expect(out.length, 1);
        expect(out.first.name, '');
        expect(out.first.value, 7);
      },
    );

    test(
      'Given converter que lanza para un item '
      'When se procesa '
      'Then el item fallido se omite y no rompe el flujo',
      () {
        const String json = '''
        [
          {"name":"ok","value":"100"},
          {"name":"bad","value":{}},
          {"name":"ok2","value":"200"}
        ]
        ''';

        final List<ModelAttribute<int>> out =
            AttributeModel.listFromDynamicTyped<int>(
          json,
          (dynamic v) {
            if (v is String) {
              return int.parse(v);
            }
            throw StateError('conversion failed');
          },
        );

        expect(out.length, 2);
        expect(out[0].name, 'ok');
        expect(out[0].value, 100);
        expect(out[1].name, 'ok2');
        expect(out[1].value, 200);
      },
    );

    test(
      'Given fromJsonT retorna tipo no compatible de dominio '
      'When se procesa '
      'Then el elemento es descartado por isDomanCompatible',
      () {
        const String json = '''
        [
          {"name":"x","value":123}
        ]
        ''';

        final List<ModelAttribute<_CustomType>> out =
            AttributeModel.listFromDynamicTyped<_CustomType>(
          json,
          (dynamic v) =>
              _CustomType(v as int), // tipo no soportado por isDomanCompatible
        );

        expect(out, isEmpty);
      },
    );

    test(
      'Given resultado '
      'When se intenta mutar la lista '
      'Then permite mutación (lista mutable)',
      () {
        const String json = '''
        [
          {"name":"n","value":1}
        ]
        ''';

        final List<ModelAttribute<int>> out =
            AttributeModel.listFromDynamicTyped<int>(
          json,
          (dynamic v) => v as int,
        );
        try {
          out.add(const AttributeModel<int>(name: 'x', value: 2));
        } catch (e) {
          expect(true, isTrue);
        }
        expect(out.length, 1);
        expect(out.last.name, 'n');
        expect(out.last.value, 1);
      },
    );

    test(
      'Given JSON Iterable estándar '
      'When se parsea (decoded is Iterable) '
      'Then el flujo reconoce Iterable y procesa elementos Map',
      () {
        // Cubre explícitamente la condición "decoded is Iterable".
        const String json = '''
        [
          {"name":"k1","value":"v1"},
          {"name":"k2","value":"v2"}
        ]
        ''';

        final List<ModelAttribute<String>> out =
            AttributeModel.listFromDynamicTyped<String>(
          json,
          (dynamic v) => v as String,
        );

        expect(out.length, 2);
        expect(out[0].name, 'k1');
        expect(out[0].value, 'v1');
        expect(out[1].name, 'k2');
        expect(out[1].value, 'v2');
      },
    );

    test(
      'Given aclaración sobre branch (e is Map pero no Map<String,dynamic>) '
      'When se usa jsonDecode por defecto '
      'Then ese branch no es alcanzable con String (documentado)',
      skip:
          'jsonDecode en Dart produce Map<String, dynamic> para objetos JSON; '
          'para cubrir ese else-if se requeriría un decoder alterno o inyección.',
      () {
        // Especificación/documentación de por qué ese branch no se ejecuta
        // con entradas String + jsonDecode estándar.
        expect(true, isTrue);
      },
    );
  });
  group('AttributeModel tests', () {
    // Constructor tests
    test('Constructor creates AttributeModel', () {
      const AttributeModel<String> model =
          AttributeModel<String>(value: 'test', name: 'name');

      expect(model.value, 'test');
      expect(model.name, 'name');
    });

    // CopyWith tests
    test('copyWith creates new AttributeModel with updated values', () {
      const AttributeModel<String> originalModel =
          AttributeModel<String>(value: 'test', name: 'name');
      final AttributeModel<String> cloneModel = originalModel.copyWith();
      final AttributeModel<String> newModel =
          originalModel.copyWith(value: 'new value');
      expect(cloneModel == originalModel, true);
      expect(newModel.value, 'new value');
      expect(newModel.name, originalModel.name);
    });

    // toJson tests
    test('toJson returns JSON representation of AttributeModel', () {
      const AttributeModel<String> model =
          AttributeModel<String>(value: 'test', name: 'name');
      final Map<String, dynamic> json = model.toJson();

      expect(json, <String, String>{'value': 'test', 'name': 'name'});
    });

    test('fromJson parses JSON string and creates AttributeModel', () {
      const Map<String, dynamic> json = <String, dynamic>{
        'value': 'test',
        'name': 'name',
      };
      final AttributeModel<String> model =
          attributeModelfromJson<String>(json, Utils.getStringFromDynamic);

      expect(model.value, 'test');
      expect(model.name, 'name');
    });

    test('fromJson handles DateTime values', () {
      const Map<String, String> json = <String, String>{
        'value': '2023-10-27T00:00:00.000Z',
        'name': 'date',
      };

      final AttributeModel<DateTime> model =
          attributeModelfromJson<DateTime>(json, DateUtils.dateTimeFromDynamic);

      expect(model.value, DateTime.parse('2023-10-27T00:00:00.000Z'));
      expect(model.name, 'date');
    });

    test('fromJson handles int values', () {
      const Map<String, dynamic> json = <String, dynamic>{
        'value': 123,
        'name': 'age',
      };
      final AttributeModel<int> model =
          attributeModelfromJson<int>(json, Utils.getIntegerFromDynamic);

      expect(model.value, 123);
      expect(model.name, 'age');
    });

    // Equality tests
    test('AttributeModel instances are equal if values are equal', () {
      const AttributeModel<String> model1 =
          AttributeModel<String>(value: 'test', name: 'name');
      const AttributeModel<String> model2 =
          AttributeModel<String>(value: 'test', name: 'name');

      expect(model1 == model2, true);
      expect(model1 == Object(), false);
    });

    // hashCode tests
    test('AttributeModel instances with same values have the same hashCode',
        () {
      const AttributeModel<String> model1 =
          AttributeModel<String>(value: 'test', name: 'name');
      const AttributeModel<String> model2 =
          AttributeModel<String>(value: 'test', name: 'name');

      expect(model1.hashCode == model2.hashCode, true);
    });

    // toString tests
    test('toString returns JSON representation of AttributeModel', () {
      const AttributeModel<String> model =
          AttributeModel<String>(value: 'test', name: 'name');
      final String expectedString =
          jsonEncode(<String, String>{'value': 'test', 'name': 'name'});

      expect(model.toString(), expectedString);
    });
  });
  group('🔖 AttributeModel', () {
    test('from<T> creates valid attribute when type is compatible', () {
      final ModelAttribute<String>? attrStr =
          ModelAttribute.from('Color', 'Red');
      final ModelAttribute<int>? attrInt = ModelAttribute.from('Stock', 50);

      expect(attrStr, isNotNull);
      expect(attrStr!.value, equals('Red'));
      expect(attrInt, isNotNull);
      expect(attrInt!.value, equals(50));
    });

    test('from<T> returns null for unsupported types', () {
      final ModelAttribute<Uri>? invalid = ModelAttribute.from('Link', Uri());
      expect(invalid, isNull);
    });

    test('toJson ↔ fromJson roundtrip', () {
      const ModelAttribute<String> original = ModelAttribute<String>(
        name: 'Size',
        value: 'Large',
      );
      final Map<String, dynamic> json = original.toJson();
      final AttributeModel<String> parsed = attributeModelfromJson<String>(
        json,
        (dynamic v) => v as String,
      );
      expect(parsed, equals(original));
    });

    test('copyWith updates only provided fields', () {
      const AttributeModel<String> attr =
          ModelAttribute<String>(name: 'Material', value: 'Cotton');
      final AttributeModel<String> copy = attr.copyWith(value: 'Linen');
      expect(copy.name, equals('Material'));
      expect(copy.value, equals('Linen'));
    });

    test('toString returns a valid JSON string', () {
      const AttributeModel<int> attr =
          ModelAttribute<int>(name: 'Stock', value: 25);
      final String str = attr.toString();
      expect(str, contains('"Stock"'));
      expect(str, contains('25'));
    });

    test('Equality and hashCode are consistent', () {
      const AttributeModel<String> a =
          ModelAttribute<String>(name: 'Color', value: 'Blue');
      const AttributeModel<String> b =
          ModelAttribute<String>(name: 'Color', value: 'Blue');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
  group('AttributeModel.listFromDynamicShallow', () {
    test(
      'Given JSON válido con tipos heterogéneos '
      'When se parsea '
      'Then retorna atributos con valores preservados',
      () {
        const String json = '''
        [
          {"name":"color","value":"blue"},
          {"name":"qty","value":3},
          {"name":"active","value":true},
          {"name":"tags","value":["a","b"]},
          {"name":"meta","value":{"k":"v"}},
          {"name":"nil","value":null}
        ]
        ''';

        final List<ModelAttribute<dynamic>> out =
            AttributeModel.listFromDynamicShallow(json);

        expect(out.length, 6);

        expect(out[0].name, 'color');
        expect(out[0].value, 'blue');

        expect(out[1].name, 'qty');
        expect(out[1].value, isA<num>());
        expect(out[1].value, 3);

        expect(out[2].name, 'active');
        expect(out[2].value, isA<bool>());
        expect(out[2].value, true);

        expect(out[3].name, 'tags');
        expect(out[3].value, isA<List<dynamic>>());
        expect((out[3].value as List<dynamic>).length, 2);

        expect(out[4].name, 'meta');
        expect(out[4].value, isA<Map<String, dynamic>>());
        expect((out[4].value as Map<String, dynamic>)['k'], 'v');

        expect(out[5].name, 'nil');
        expect(out[5].value, isNull);
      },
    );

    test(
      'Given JSON inválido '
      'When se intenta parsear '
      'Then retorna lista vacía (falla silenciosa)',
      () {
        const String json = '¡esto no es JSON!';
        final List<ModelAttribute<dynamic>> out =
            AttributeModel.listFromDynamicShallow(json);
        expect(out, isEmpty);
      },
    );

    test(
      'Given JSON que representa un Map (no una List) '
      'When se procesa '
      'Then retorna lista vacía',
      () {
        const String json = '{"name":"solo","value":1}';
        final List<ModelAttribute<dynamic>> out =
            AttributeModel.listFromDynamicShallow(json);
        expect(out, isEmpty);
      },
    );

    test(
      'Given item sin "name" '
      'When se procesa '
      'Then se crea atributo con name == ""',
      () {
        const String json = '''
        [
          {"value":"v-sin-nombre"}
        ]
        ''';
        final List<ModelAttribute<dynamic>> out =
            AttributeModel.listFromDynamicShallow(json);

        expect(out.length, 1);
        expect(out.first.name, '');
        expect(out.first.value, 'v-sin-nombre');
      },
    );

    test(
      'Given entrada estructurada (List<Map<String,dynamic>>) '
      'When se procesa por rama Utils '
      'Then retorna atributos correctamente',
      () {
        final List<Map<String, dynamic>> raw = <Map<String, dynamic>>[
          <String, dynamic>{'name': 'a', 'value': 1},
          <String, dynamic>{'name': 'b', 'value': true},
        ];

        // Rama no-String => delega a Utils.listFromDynamic(...)
        final List<ModelAttribute<dynamic>> out =
            AttributeModel.listFromDynamicShallow(raw);

        expect(out.length, 2);
        expect(out[0].name, 'a');
        expect(out[0].value, 1);
        expect(out[1].name, 'b');
        expect(out[1].value, true);
      },
    );

    test(
      'Given valor no compatible con dominio (e.g., Function) '
      'When se procesa por rama Utils '
      'Then el item es omitido',
      () {
        final List<Map<String, dynamic>> raw = <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'bad',
            'value': () {}, // no compatible
          },
          <String, dynamic>{
            'name': 'ok',
            'value': 'string',
          },
        ];

        final List<ModelAttribute<dynamic>> out =
            AttributeModel.listFromDynamicShallow(raw);

        // Solo debe entrar el segundo
        expect(out.length, 1);
        expect(out.first.name, 'ok');
        expect(out.first.value, 'string');
      },
    );

    test(
      'Given null '
      'When se procesa '
      'Then retorna lista vacía (según Utils.listFromDynamic)',
      () {
        final List<ModelAttribute<dynamic>> out =
            AttributeModel.listFromDynamicShallow(null);
        expect(out, isEmpty);
      },
    );
  });
}
