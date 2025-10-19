part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the JSON field names used by [ModelPrice].
///
/// Contracts:
/// - These keys are **stable** and serialized by `name`.
/// - Reordering the enum does not affect JSON when using `name`-based encoding.
///
/// Example:
/// ```dart
/// void main() {
///   final Map<String, dynamic> json = <String, dynamic>{
///     ModelPriceEnum.amount.name: 1250,
///     ModelPriceEnum.mathPrecision.name: 2,
///     ModelPriceEnum.currency.name: CurrencyEnum.COP.name,
///   };
///   // { "amount": 1250, "mathPrecision": 2, "currency": "COP" }
/// }
/// ```
enum ModelPriceEnum {
  amount,
  mathPrecision,
  currency,
}

/// Supported currency codes for prices and transactions.
///
/// Codes are serialized/deserialized by **enum name** (e.g., `"COP"`, `"USD"`).
/// This list focuses on Hispanoamérica and includes a few common globals/crypto
/// codes used in apps.
///
/// ### Notes
/// - Adding new codes is **non-breaking** as long as JSON uses `currency.name`.
/// - Avoid relying on `CurrencyEnum.values[index]` in persistence; prefer names.
/// - Venezuela uses `VES` (replaces older `VEF`).
/// - Panamá usa `PAB` y también `USD`.
/// - El Salvador opera en `USD` (el código `SVC` existe pero está en desuso).
///
/// ### Example
/// ```dart
/// void main() {
///   final CurrencyEnum c = CurrencyEnum.MXN;
///   print(c.name); // "MXN"
/// }
/// ```
enum CurrencyEnum {
  COP, // Colombia
  USD, // United States dollar (también de curso en SV y PA)
  MXN, // México
  PEN, // Perú (Sol)
  CLP, // Chile (Peso)
  ARS, // Argentina (Peso)
  BRL, // Brasil (Real)
  EUR, // Euro
  BTC, // Bitcoin (crypto)
  USDT, // Tether (stablecoin)
  BOB, // Bolivia (Boliviano)
  CRC, // Costa Rica (Colón)
  DOP, // República Dominicana (Peso)
  GTQ, // Guatemala (Quetzal)
  HNL, // Honduras (Lempira)
  NIO, // Nicaragua (Córdoba)
  PAB, // Panamá (Balboa; convive con USD)
  PYG, // Paraguay (Guaraní)
  UYU, // Uruguay (Peso Uruguayo)
  VES, // Venezuela (Bolívar Soberano)
}

/// Represents an immutable monetary amount stored in minor units, with its
/// decimal precision and currency.
///
/// Values are stored in `amount` (minor units). The decimal value is derived as:
/// `decimalAmount = amount / pow(10, mathPrecision)`.
///
/// ### Contracts
/// - `amount` **must be non-negative**.
/// - `mathPrecision` **must be non-negative** (defaults to [defaultMathprecision]).
/// - `currency` is required and encoded/decoded by its enum name (e.g. `"COP"`).
/// - JSON shape: `{ "amount": int, "mathPrecision": int, "currency": String }`.
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   // 12.50 COP represented as 1250 minor units with precision 2
///   final ModelPrice price = ModelPrice(
///     amount: 1250,
///     currency: CurrencyEnum.COP,
///     mathPrecision: ModelPrice.defaultMathprecision, // 2
///   );
///
///   print(price.decimalAmount); // 12.5
///   print(price.toJson());      // {amount: 1250, mathPrecision: 2, currency: COP}
///   print(price);               // 💰 12.50 COP
///
///   // copyWith normalizes negatives: amount -> abs, precision -> non-negative
///   final ModelPrice updated = price.copyWith(amount: -1999, mathPrecision: -1);
///   print(updated.amount);        // 1999
///   print(updated.mathPrecision); // 2 (fallback to default)
/// }
/// ```
///
/// ### Notes
/// - `decimalAmount` uses floating-point division; for display, prefer
///   `toString()` or `toStringAsFixed(mathPrecision)` to avoid rounding artifacts.
class ModelPrice extends Model {
  /// Creates a new immutable [ModelPrice].
  ///
  /// Throws (debug mode):
  /// - [AssertionError] if `amount < 0` or `mathPrecision < 0`.
  const ModelPrice({
    required this.amount,
    required this.currency,
    this.mathPrecision = defaultMathprecision,
  })  : assert(amount >= 0),
        assert(mathPrecision >= 0);

  /// Builds a [ModelPrice] from a JSON map.
  ///
  /// Behavior:
  /// - `amount` is parsed and coerced to absolute value.
  /// - `mathPrecision` is parsed as integer (no clamping here; constructor asserts non-negative).
  /// - Unknown `currency` names default to [CurrencyEnum.COP].
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final ModelPrice p = ModelPrice.fromJson({
  ///     'amount': -999, // abs() => 999
  ///     'mathPrecision': 2,
  ///     'currency': 'USD',
  ///   });
  ///   print(p); // 💰 9.99 USD
  /// }
  /// ```
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

  /// Default decimal precision used when not provided.
  static const int defaultMathprecision = 2;

  /// Amount in minor units (scaled by [mathPrecision]); must be non-negative.
  final int amount;

  /// Number of decimal places used to scale [amount].
  ///
  /// Example: `2` ⇒ 100 minor units = 1.00.
  final int mathPrecision;

  /// ISO-like currency code from [CurrencyEnum] (e.g., `COP`, `USD`, `EUR`).
  final CurrencyEnum currency;

  /// Decimal representation computed as `amount / pow(10, mathPrecision)`.
  double get decimalAmount => amount / pow(10, mathPrecision);

  /// Serializes this price to JSON:
  /// `{ "amount": int, "mathPrecision": int, "currency": String }`.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelPriceEnum.amount.name: amount,
        ModelPriceEnum.mathPrecision.name: mathPrecision,
        ModelPriceEnum.currency.name: currency.name,
      };

  /// Returns a new [ModelPrice] overriding the provided fields.
  ///
  /// Normalization rules:
  /// - Negative `amount` is coerced to `abs(amount)`.
  /// - Negative `mathPrecision` falls back to [defaultMathprecision].
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   const ModelPrice p = ModelPrice(amount: 100, currency: CurrencyEnum.EUR);
  ///   final ModelPrice q = p.copyWith(amount: -250, mathPrecision: -3);
  ///   print(q.amount);        // 250
  ///   print(q.mathPrecision); // 2 (default)
  /// }
  /// ```
  @override
  ModelPrice copyWith({
    int? amount,
    int? mathPrecision,
    CurrencyEnum? currency,
  }) =>
      ModelPrice(
        amount: (amount ?? this.amount).abs(),
        mathPrecision: (mathPrecision ?? this.mathPrecision) < 0
            ? defaultMathprecision
            : (mathPrecision ?? this.mathPrecision),
        currency: currency ?? this.currency,
      );

  /// Structural equality on `amount`, `mathPrecision`, and `currency`.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelPrice &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          mathPrecision == other.mathPrecision &&
          currency == other.currency;

  /// Hash code consistent with equality.
  @override
  int get hashCode => Object.hash(amount, mathPrecision, currency);

  /// Human-readable representation (e.g., `💰 12.50 COP`).
  @override
  String toString() =>
      '💰 ${decimalAmount.toStringAsFixed(mathPrecision)} ${currency.name}';
}

/// Default price model used for testing or fallbacks.
///
/// Example:
/// ```dart
/// void main() {
///   print(defaultModelPrice); // 💰 0.00 COP
/// }
/// ```
const ModelPrice defaultModelPrice = ModelPrice(
  amount: 0,
  currency: CurrencyEnum.COP,
);
