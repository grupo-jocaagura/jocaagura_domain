part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the field names used in [ModelPrice].
enum ModelPriceEnum {
  amount,
  mathPrecision,
  currency,
}

/// List of supported currencies for prices and transactions.
enum CurrencyEnum {
  COP,
  USD,
  MXN,
  PEN,
  CLP,
  ARS,
  BRL,
  EUR,
  BTC,
  USDT,
}

/// A minimal price model representing a monetary value with currency and precision.
///
/// Example:
/// ```dart
/// final price = ModelPrice(
///   amount: 1250,
///   mathPrecision: 2,
///   currency: CurrencyEnum.COP,
/// );
/// // amount → 1250
/// // decimalAmount → 12.50
/// ```
class ModelPrice extends Model {
  /// Creates a new immutable [ModelPrice].
  const ModelPrice({
    required this.amount,
    required this.mathPrecision,
    required this.currency,
  }) : assert(amount >= 0);

  /// Builds a [ModelPrice] from JSON.
  factory ModelPrice.fromJson(Map<String, dynamic> json) {
    return ModelPrice(
      amount:
          Utils.getIntegerFromDynamic(json[ModelPriceEnum.amount.name]).abs(),
      mathPrecision:
          Utils.getIntegerFromDynamic(json[ModelPriceEnum.mathPrecision.name]),
      currency: CurrencyEnum.values.firstWhere(
        (CurrencyEnum e) =>
            e.name ==
            Utils.getStringFromDynamic(json[ModelPriceEnum.currency.name]),
        orElse: () => CurrencyEnum.COP,
      ),
    );
  }

  /// Amount scaled by `mathPrecision`. Should be non-negative.
  final int amount;

  /// Precision used to scale `amount`. For example, `2` → 100 = 1.00.
  final int mathPrecision;

  /// Currency used to represent the value.
  final CurrencyEnum currency;

  /// Decimal representation derived from [amount] and [mathPrecision].
  double get decimalAmount => amount / pow(10, mathPrecision);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelPriceEnum.amount.name: amount,
        ModelPriceEnum.mathPrecision.name: mathPrecision,
        ModelPriceEnum.currency.name: currency.name,
      };

  @override
  ModelPrice copyWith({
    int? amount,
    int? mathPrecision,
    CurrencyEnum? currency,
  }) =>
      ModelPrice(
        amount: amount?.abs() ?? this.amount,
        mathPrecision: mathPrecision ?? this.mathPrecision,
        currency: currency ?? this.currency,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelPrice &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          mathPrecision == other.mathPrecision &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, mathPrecision, currency);

  @override
  String toString() =>
      '💰 ${decimalAmount.toStringAsFixed(mathPrecision)} $currency';
}

/// Default price model used for testing or fallbacks.
const ModelPrice defaultModelPrice = ModelPrice(
  amount: 0,
  mathPrecision: 2,
  currency: CurrencyEnum.COP,
);
