import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('💰 ModelPrice', () {
    const ModelPrice original = ModelPrice(
      amount: 12345,
      mathPrecision: 2,
      currency: CurrencyEnum.USD,
    );

    test('toJson ↔ fromJson roundtrip', () {
      final Map<String, dynamic> json = original.toJson();
      final ModelPrice parsed = ModelPrice.fromJson(json);

      expect(parsed, equals(original));
      expect(parsed.toJson(), equals(json));
    });

    test('decimalAmount reflects scaled amount', () {
      expect(original.decimalAmount, equals(123.45));
    });

    test('copyWith overrides only specified fields', () {
      final ModelPrice updated = original.copyWith(amount: 999);

      expect(updated.amount, equals(999));
      expect(updated.mathPrecision, equals(original.mathPrecision));
      expect(updated.currency, equals(original.currency));
    });

    test('CurrencyEnum defaults to COP if not found', () {
      final ModelPrice fallback = ModelPrice.fromJson(const <String, dynamic>{
        'amount': 2000,
        'mathPrecision': 2,
        'currency': 'NON_EXISTENT',
      });

      expect(fallback.currency, equals(CurrencyEnum.COP));
    });

    test('toString includes decimal and currency', () {
      expect(original.toString(), contains('USD'));
      expect(original.toString(), contains('123.45'));
    });
  });
}
