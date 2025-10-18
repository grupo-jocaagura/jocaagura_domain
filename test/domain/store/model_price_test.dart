import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('💰 ModelPrice', () {
    const ModelPrice original = ModelPrice(
      amount: 12345,
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

  group('ModelPrice', () {
    test('Given valid inputs When construct Then decimalAmount correct', () {
      const ModelPrice p = ModelPrice(
        amount: 1250,
        currency: CurrencyEnum.COP,
      );
      expect(p.decimalAmount, closeTo(12.5, 0.0000001));
      expect(p.toString(), '💰 12.50 COP');
    });

    test('Given negative amount When construct Then assert (debug mode)', () {
      expect(
        () => ModelPrice(
          amount: -1,
          currency: CurrencyEnum.USD,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Given negative precision When construct Then assert (debug mode)',
        () {
      expect(
        () => ModelPrice(
          amount: 1,
          mathPrecision: -1,
          currency: CurrencyEnum.USD,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Given fromJson with unknown currency When parse Then defaults to COP',
        () {
      final ModelPrice p = ModelPrice.fromJson(const <String, Object?>{
        'amount': -999, // will be abs() => 999
        'mathPrecision': 2,
        'currency': '???',
      });
      expect(p.amount, 999);
      expect(p.currency, CurrencyEnum.COP);
      expect(p.decimalAmount, closeTo(9.99, 0.0000001));
    });

    test('Given copyWith When amount negative Then coerced to abs', () {
      const ModelPrice base = ModelPrice(
        amount: 100,
        currency: CurrencyEnum.EUR,
      );
      final ModelPrice changed = base.copyWith(amount: -250);
      expect(changed.amount, 250);
      expect(changed.mathPrecision, 2);
      expect(changed.currency, CurrencyEnum.EUR);
    });

    test(
        'Given copyWith When precision negative Then normalized to non-negative',
        () {
      const ModelPrice base = ModelPrice(
        amount: 100,
        currency: CurrencyEnum.USD,
      );
      final ModelPrice changed = base.copyWith(mathPrecision: -3);
      expect(changed.mathPrecision, ModelPrice.defaultMathprecision);
      expect(changed.decimalAmount, 1.00);
    });

    test('Given two equal instances When compare Then == true and hash equal',
        () {
      const ModelPrice a = ModelPrice(amount: 1, currency: CurrencyEnum.CLP);
      const ModelPrice b = ModelPrice(amount: 1, currency: CurrencyEnum.CLP);
      expect(a == b, isTrue);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('Given toJson When serialize Then matches expected keys', () {
      const ModelPrice p = ModelPrice(amount: 123, currency: CurrencyEnum.MXN);
      final Map<String, dynamic> json = p.toJson();
      expect(json['amount'], 123);
      expect(json['mathPrecision'], 2);
      expect(json['currency'], 'MXN');
    });
  });
}
