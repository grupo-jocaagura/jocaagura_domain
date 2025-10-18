import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('📦 ModelItem', () {
    const ModelItem original = ModelItem(
      id: '',
      name: 'Ice Cream',
      description: 'Delicious vanilla ice cream',
      type:
          ModelCategory(category: 'Food Products', description: 'Consumables'),
      price: ModelPrice(
        amount: 1899,
        mathPrecision: 2,
        currency: CurrencyEnum.COP,
      ),
      attributes: <AttributeModel<dynamic>>[
        AttributeModel<String>(name: 'Size', value: 'Small'),
        AttributeModel<int>(name: 'Stock', value: 20),
      ],
    );

    test('Roundtrip toJson ↔ fromJson preserves data', () {
      final Map<String, dynamic> json = original.toJson();
      final ModelItem parsed = ModelItem.fromJson(json);

      expect(parsed, equals(original));
      expect(parsed.toJson(), equals(json));
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
      expect(output.contains('food-products'), isTrue);
    });
  });

  group('💰 ModelPrice', () {
    const ModelPrice price = ModelPrice(
      amount: 1050,
      mathPrecision: 2,
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
}
