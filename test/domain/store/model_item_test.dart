import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('📦 ModelItem', () {
    final ModelItem original = ModelItem(
      id: '',
      name: 'Ice Cream',
      description: 'Delicious vanilla ice cream',
      type: const ModelCategory(
        category: 'Food Products',
        description: 'Consumables',
      ),
      price: const ModelPrice(
        amount: 1899,
        currency: CurrencyEnum.COP,
      ),
      attributes: const <AttributeModel<dynamic>>[
        AttributeModel<String>(name: 'Size', value: 'Small'),
        AttributeModel<int>(name: 'Stock', value: 20),
      ],
    );

    test('Roundtrip toJson ↔ fromJson preserves data', () {
      final Map<String, dynamic> json = original.toJson();
      final ModelItem parsed = ModelItem.fromJson(json);

      expect(parsed.toJson(), equals(json));
      expect(parsed, isNot(same(defaultModelItem)));
    });

    test('Fallback ID from type.category normalization', () {
      final String fallbackId = original.toJson()['id'].toString();
      expect(fallbackId, equals('food-products'));
    });

    test('copyWith updates selected fields', () {
      final ModelItem copy = original.copyWith(name: 'Updated');
      expect(copy.name, equals('Updated'));
      expect(copy.id, equals(original.id));
    });

    test('Equality and hashCode are consistent', () {
      final ModelItem other = original.copyWith();
      expect(other, equals(original));
      expect(other.hashCode, equals(original.hashCode));
    });

    test('toString contains relevant info', () {
      final String output = original.toString();
      expect(output.contains('Ice Cream'), isTrue);
      expect(output.contains('Food'), isTrue);
      expect(output.contains('Products'), isTrue);
    });
  });

  group('💰 ModelPrice', () {
    const ModelPrice price = ModelPrice(
      amount: 1050,
      currency: CurrencyEnum.USD,
    );

    test('decimalAmount is computed correctly', () {
      expect(price.decimalAmount, equals(10.5));
    });

    test('CurrencyEnum roundtrip works', () {
      final Map<String, dynamic> json = price.toJson();
      final ModelPrice parsed = ModelPrice.fromJson(json);
      expect(parsed.currency, equals(CurrencyEnum.USD));
      expect(parsed, equals(price));
    });

    test('copyWith retains and replaces values correctly', () {
      final ModelPrice updated = price.copyWith(amount: 2000);
      expect(updated.amount, equals(2000));
      expect(updated.currency, equals(CurrencyEnum.USD));
    });
  });

  group('ModelItem', () {
    test('Given attributes list When constructed Then becomes unmodifiable',
        () {
      final List<ModelAttribute<dynamic>> attrs = <ModelAttribute<dynamic>>[
        const AttributeModel<String>(name: 'Color', value: 'Blue'),
      ];
      final ModelItem item = ModelItem(
        id: '',
        name: 'Mask',
        description: 'Medical mask',
        type: const ModelCategory(category: 'health', description: 'x'),
        price: const ModelPrice(amount: 2500, currency: CurrencyEnum.COP),
        attributes: attrs,
      );

      // mutate original list -> item.attributes must not change
      attrs.add(const AttributeModel<int>(name: 'Stock', value: 10));
      expect(item.attributes.length, 1);

      // list must be truly unmodifiable
      expect(
        () => item.attributes
            .add(const AttributeModel<String>(name: 'S', value: 'x')),
        throwsUnsupportedError,
      );
    });

    test('Given empty id When toJson Then id falls back to normalized category',
        () {
      final ModelItem item = ModelItem(
        id: '',
        name: '  Mask  ',
        description: '  Medical  ',
        type:
            const ModelCategory(category: 'health-supplies', description: 'x'),
        price: const ModelPrice(amount: 1000, currency: CurrencyEnum.COP),
      );
      final Map<String, dynamic> json = item.toJson();
      expect(json['id'], ModelCategory.normalizeCategory('health-supplies'));
      expect(json['name'], 'Mask');
      expect(json['description'], 'Medical');
    });

    test('Given json When fromJson Then roundtrip preserves fields', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'SKU1',
        'name': 'Gloves',
        'description': 'Latex',
        'type':
            const ModelCategory(category: 'health', description: 'x').toJson(),
        'price':
            const ModelPrice(amount: 1999, currency: CurrencyEnum.USD).toJson(),
        'attributes': <Map<String, dynamic>>[
          const AttributeModel<String>(name: 'Size', value: 'M').toJson(),
          const AttributeModel<int>(name: 'Stock', value: 50).toJson(),
        ],
      };
      final ModelItem item = ModelItem.fromJson(json);
      expect(item.id, 'SKU1');
      expect(item.name, 'Gloves');
      expect(item.price.currency, CurrencyEnum.USD);
      expect(item.attributes.length, 2);
    });

    test(
        'Given copyWith When change fields Then new instance with same immutability',
        () {
      final ModelItem base = ModelItem(
        id: 'A',
        name: 'Item',
        description: 'Desc',
        type: const ModelCategory(category: 'cat', description: 'x'),
        price: const ModelPrice(amount: 100, currency: CurrencyEnum.EUR),
      );

      final ModelItem changed = base.copyWith(
        id: 'B',
        attributes: <ModelAttribute<dynamic>>[
          const AttributeModel<bool>(name: 'Fragile', value: true),
        ],
      );

      expect(changed.id, 'B');
      expect(
        () => changed.attributes
            .add(const AttributeModel<int>(name: 'X', value: 1)),
        throwsUnsupportedError,
      );
    });

    test('Given equals/hash When same fields Then equality true and hash equal',
        () {
      final ModelItem a = ModelItem(
        id: 'A',
        name: 'N',
        description: 'D',
        type: const ModelCategory(category: 'cat', description: 'x'),
        price: const ModelPrice(amount: 1, currency: CurrencyEnum.CLP),
        attributes: const <ModelAttribute<dynamic>>[
          AttributeModel<int>(name: 'Stock', value: 1),
        ],
      );
      final ModelItem b = ModelItem(
        id: 'A',
        name: 'N',
        description: 'D',
        type: const ModelCategory(category: 'cat', description: 'x'),
        price: const ModelPrice(amount: 1, currency: CurrencyEnum.CLP),
        attributes: const <ModelAttribute<dynamic>>[
          AttributeModel<int>(name: 'Stock', value: 1),
        ],
      );
      expect(a == b, isTrue);
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
