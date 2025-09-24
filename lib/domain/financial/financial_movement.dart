part of '../../jocaagura_domain.dart';

/// Enumerates the JSON field names for [FinancialMovementModel].
enum FinancialMovementEnum {
  /// Unique identifier of the financial transaction.
  id,

  /// Transaction amount in scaled integer using mathPrecision fractional digits
  /// to avoid precision issues.
  amount,

  /// Date when the transaction was made.
  date,

  /// General concept of the financial transaction.
  concept,

  /// Detailed description of the financial transaction.
  detailedDescription,

  /// Category of the financial transaction (e.g., "Income", "Expense").
  category,

  /// Date when the transaction was recorded.
  createdAt,
}

/// Default sample instance for initialization or tests.
final FinancialMovementModel defaultMovement = FinancialMovementModel(
  id: 'fm001',
  amount: 1000,
  date: DateTime(2024, 07, 20),
  concept: 'Salary',
  detailedDescription: 'Monthly salary deposit',
  category: 'Income',
  createdAt: DateTime(2024, 07, 25),
);

/// Represents an immutable financial movement stored as a scaled integer.
///
/// Amount is stored as an **integer** using `mathPrecision` fractional digits
/// (i.e., scaled by `10^mathPrecision`) in order to avoid double precision issues.
/// For example, with `mathPrecision = 2`, an `amount` of `1234` represents `12.34`.
///
/// Notes:
/// - This type is a pure model (no I/O).
/// - Invariants:
///   - `amount >= 0`.
///   - `0 <= mathPrecision <= 6`.
/// - Contract:
///   - `amount` is **non-negative** (the sign is not used to encode direction).
///   - `0 <= mathPrecision <= 6`.
/// **Non-negative amount policy.**
/// The monetary amount is modeled as a **non-negative** scaled integer.
/// The transaction direction (income/expense) is expressed by `category`
/// (or an equivalent movement type), **not** by the amount sign.
/// Consequently, all construction paths that ingest external data
/// (`fromDecimal`, `fromJson`) and mutation helpers (`copyWith`)
/// **normalize** any negative input to its absolute value.
/// Integrators must not rely on the amount sign to infer business meaning;
/// instead, they must use categorical fields.
/// This policy is enforced by unit tests to ensure consistent normalization and
/// round-trip behavior. Use `fromDecimal` for new monetary inputs; the default
/// constructor is intended for already scaled and validated data.
/// Minimal example:
/// ```dart
/// void main() {
///   final FinancialMovementModel m = FinancialMovementModel.fromDecimal(
///     id: 'txn123',
///     decimalAmount: 12.34,
///     date: DateTime(2025, 1, 1),
///     concept: 'Groceries',
///     category: 'Expense',
///     createdAt: DateTime(2025, 1, 2),
///     precision: 2,
///   );
///
///   // m.amount == 1234; m.decimalAmount == 12.34
///   print(m.toJson());
/// }
/// ```
///
/// JSON contract:
/// - Dates are serialized using [DateUtils.dateTimeToString].
/// - `mathPrecision` MUST be present to preserve round-trip fidelity.
/// Validation policy:
/// This type does not throw at construction time in release builds.
/// Validation is expected to be handled by mappers/repositories/ledger according
/// to domain rules (e.g., precision policy, temporal consistency).
class FinancialMovementModel extends Model {
  /// Creates a new immutable financial movement.
  const FinancialMovementModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.concept,
    required this.category,
    required this.createdAt,
    this.detailedDescription = '',
    this.mathPrecision = defaultMathPrecision,
  }) : assert(amount >= 0, 'amount cannot be negative');

  /// Builds a model from JSON.
  ///
  /// Missing `mathPrecision` falls back to [defaultMathPrecision].
  factory FinancialMovementModel.fromJson(Map<String, dynamic> json) {
    return FinancialMovementModel(
      id: Utils.getStringFromDynamic(json[FinancialMovementEnum.id.name]),
      amount:
          Utils.getIntegerFromDynamic(json[FinancialMovementEnum.amount.name])
              .abs(),
      date:
          DateUtils.dateTimeFromDynamic(json[FinancialMovementEnum.date.name]),
      concept:
          Utils.getStringFromDynamic(json[FinancialMovementEnum.concept.name]),
      category: Utils.getStringFromDynamic(
        json[FinancialMovementEnum.category.name],
      ),
      detailedDescription: Utils.getStringFromDynamic(
        json[FinancialMovementEnum.detailedDescription.name],
      ),
      createdAt: DateUtils.dateTimeFromDynamic(
        json[FinancialMovementEnum.createdAt.name],
      ),
      mathPrecision: json.containsKey(mathPrecisionKey)
          ? Utils.getIntegerFromDynamic(json[mathPrecisionKey])
          : defaultMathPrecision,
    );
  }

  /// Builds a model from a decimal amount (scales and rounds using `precision`).
  factory FinancialMovementModel.fromDecimal({
    required String id,
    required double decimalAmount,
    required DateTime date,
    required String concept,
    required String category,
    required DateTime createdAt,
    String detailedDescription = '',
    int precision = defaultMathPrecision,
  }) {
    final int factor = getFactor(precision);
    final int amount = (decimalAmount * factor).round().abs();

    return FinancialMovementModel(
      id: id,
      amount: amount,
      date: date,
      concept: concept,
      detailedDescription: detailedDescription,
      category: category,
      createdAt: createdAt,
      mathPrecision: precision,
    );
  }

  /// Default precision used to scale decimal amounts as integers.
  /// We recommend using **4** fractional digits by default for a balanced workflow
  /// (adjust according to interoperability constraints).
  static const int defaultMathPrecision = 4;

  /// Allowed precision bounds (inclusive).
  static const int minPrecision = 0;
  static const int maxPrecision = 6;
  static const String mathPrecisionKey = 'mathPrecision';

  /// Unique identifier.
  final String id;

  /// Scaled integer amount (`amount / 10^mathPrecision == decimalAmount`).
  final int amount;

  /// Fractional digits used to scale `amount`.
  final int mathPrecision;

  /// Derived decimal amount.
  double get decimalAmount => amount / getFactor(mathPrecision);

  static int getFactor(int precision) => pow(10, precision).toInt();

  /// Transaction date.
  final DateTime date;

  /// High-level concept (e.g., 'Salary', 'Groceries').
  final String concept;

  /// Optional detailed description.
  final String detailedDescription;

  /// Category (e.g., 'Income', 'Expense').
  final String category;

  /// Record creation timestamp.
  final DateTime createdAt;

  /// JSON serialization.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      FinancialMovementEnum.id.name: id,
      FinancialMovementEnum.amount.name: amount.abs(),
      FinancialMovementEnum.date.name: DateUtils.dateTimeToString(date),
      FinancialMovementEnum.concept.name: concept,
      FinancialMovementEnum.detailedDescription.name: detailedDescription,
      FinancialMovementEnum.category.name: category,
      FinancialMovementEnum.createdAt.name:
          DateUtils.dateTimeToString(createdAt),
      mathPrecisionKey: mathPrecision,
    };
  }

  /// Returns a copy with the provided fields replaced.
  @override
  FinancialMovementModel copyWith({
    String? id,
    int? amount,
    DateTime? date,
    String? concept,
    String? detailedDescription,
    String? category,
    DateTime? createdAt,
    int? mathPrecision,
  }) {
    return FinancialMovementModel(
      id: id ?? this.id,
      amount: amount?.abs() ?? this.amount.abs(),
      date: date ?? this.date,
      concept: concept ?? this.concept,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      mathPrecision: mathPrecision ?? this.mathPrecision,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FinancialMovementModel &&
            other.id == id &&
            other.amount == amount &&
            other.date == date &&
            other.concept == concept &&
            other.detailedDescription == detailedDescription &&
            other.category == category &&
            other.mathPrecision == mathPrecision &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      amount,
      date,
      concept,
      detailedDescription,
      category,
      createdAt,
      mathPrecision,
    );
  }

  @override
  String toString() {
    return 'FinancialMovementModel(id: $id, amount: $amount, date: $date, '
        'concept: "$concept", category: "$category", createdAt: $createdAt, mathPrecision: $mathPrecision)';
  }
}
