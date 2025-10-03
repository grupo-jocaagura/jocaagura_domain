part of '../../jocaagura_domain.dart';

enum LedgerEnum { nameOfLedger, incomeLedger, expenseLedger }

/// Represents a financial ledger composed of incomes and expenses.
///
/// This model aggregates two collections of [FinancialMovementModel] and
/// exposes derived balances in both scaled integer (`balance`) and decimal
/// form (`decimalBalance`). It is intended to be *logically immutable*:
/// factories and `copyWith` wrap collections using `List.unmodifiable`.
///
/// **Immutability contract**
/// - The default constructor expects **already unmodifiable** lists; it does
///   not wrap them to preserve `const` usage and API compatibility.
/// - Prefer building instances via `fromJson` or `copyWith`, which enforce
///   unmodifiable collections internally.
/// - Mutating the provided lists *after* passing them to the constructor
///   breaks the immutability assumptions and may invalidate `==`/`hashCode`.
///
/// **Equality and hashing**
/// - Deep equality is performed in order (index-by-index).
/// - `hashCode` is derived from list contents to remain consistent with `==`.
///
/// Minimal example:
/// ```dart
/// void main() {
///   final LedgerModel ledger = LedgerModel.fromJson(<String, dynamic>{
///     'nameOfLedger': 'My Ledger',
///     'incomeLedger': <Map<String, dynamic>>[defaultMovement.toJson()],
///     'expenseLedger': <Map<String, dynamic>>[],
///   });
///   print(ledger.balance);        // total incomes - total expenses (scaled int)
///   print(ledger.decimalBalance); // decimal difference
/// }
/// ```
class LedgerModel extends Model {
  const LedgerModel({
    required this.nameOfLedger,
    required this.incomeLedger,
    required this.expenseLedger,
  });

  factory LedgerModel.fromJson(Map<String, dynamic> json) {
    final String name =
        Utils.getStringFromDynamic(json[LedgerEnum.nameOfLedger.name]);

    final List<Map<String, dynamic>> incomeRaw =
        Utils.listFromDynamic(json[LedgerEnum.incomeLedger.name]);
    final List<Map<String, dynamic>> expenseRaw =
        Utils.listFromDynamic(json[LedgerEnum.expenseLedger.name]);

    final List<FinancialMovementModel> incomes =
        incomeRaw.map(FinancialMovementModel.fromJson).toList(growable: false);
    final List<FinancialMovementModel> expenses =
        expenseRaw.map(FinancialMovementModel.fromJson).toList(growable: false);

    return LedgerModel(
      nameOfLedger: name,
      incomeLedger: List<FinancialMovementModel>.unmodifiable(incomes),
      expenseLedger: List<FinancialMovementModel>.unmodifiable(expenses),
    );
  }

  final String nameOfLedger;

  // Nota: siguen expuestos como List<...> para no romper API ni const-ctor.
  final List<FinancialMovementModel> incomeLedger;
  final List<FinancialMovementModel> expenseLedger;

  int get balance =>
      MoneyUtils.totalAmount(incomeLedger) -
      MoneyUtils.totalAmount(expenseLedger);

  double get decimalBalance =>
      MoneyUtils.totalDecimalAmount(incomeLedger) -
      MoneyUtils.totalDecimalAmount(expenseLedger);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        LedgerEnum.nameOfLedger.name: nameOfLedger,
        LedgerEnum.incomeLedger.name: incomeLedger
            .map((FinancialMovementModel e) => e.toJson())
            .toList(growable: false),
        LedgerEnum.expenseLedger.name: expenseLedger
            .map((FinancialMovementModel e) => e.toJson())
            .toList(growable: false),
      };

  @override
  LedgerModel copyWith({
    String? nameOfLedger,
    List<FinancialMovementModel>? incomeLedger,
    List<FinancialMovementModel>? expenseLedger,
  }) {
    return LedgerModel(
      nameOfLedger: nameOfLedger ?? this.nameOfLedger,
      // copy defensiva e inmutable si vienen nuevas listas
      incomeLedger: incomeLedger == null
          ? this.incomeLedger
          : List<FinancialMovementModel>.unmodifiable(incomeLedger),
      expenseLedger: expenseLedger == null
          ? this.expenseLedger
          : List<FinancialMovementModel>.unmodifiable(expenseLedger),
    );
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  static int _listHash<T>(List<T> list) {
    int hash = 17;
    for (final T e in list) {
      hash = 37 * hash + e.hashCode;
    }
    return hash;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LedgerModel &&
          nameOfLedger == other.nameOfLedger &&
          _listEquals(incomeLedger, other.incomeLedger) &&
          _listEquals(expenseLedger, other.expenseLedger);

  @override
  int get hashCode => Object.hash(
        nameOfLedger,
        _listHash(incomeLedger),
        _listHash(expenseLedger),
      );

  @override
  String toString() =>
      'LedgerModel(name: $nameOfLedger, balance: $decimalBalance)';
}

/// Builds a lightweight demo ledger for 2024 in Colombia.
///
/// - Income: monthly salary (25th of each month).
/// - Expenses: rent (1st), utilities (15th), groceries (7th), transport pass (10th),
///   entertainment (20th).
///
/// The dataset is intentionally **small** (one record per category per month)
/// to keep samples/snippets fast while still looking realistic.
///
/// Example:
/// ```dart
/// void main() {
///   final LedgerModel ledger = defaultLedgerModel();
///   print(ledger.incomeLedger.length);  // 12
///   print(ledger.expenseLedger.length); // 12 * 5 = 60
/// }
/// ```
LedgerModel defaultLedgerModel({
  String region = 'Colombia',
  int salaryMonthly = 3500000,
  int rentMonthly = 1500000,
  int utilitiesMonthly = 250000,
  int groceriesMonthly = 260000,
  int transportMonthly = 160000,
  int entertainmentMonthly = 100000,
}) {
  final List<FinancialMovementModel> incomes = defaultIncomeLedger2024(
    salaryMonthly: salaryMonthly,
  );
  final List<FinancialMovementModel> expenses = defaultExpenseLedger2024(
    rentMonthly: rentMonthly,
    utilitiesMonthly: utilitiesMonthly,
    groceriesMonthly: groceriesMonthly,
    transportMonthly: transportMonthly,
    entertainmentMonthly: entertainmentMonthly,
  );

  return LedgerModel(
    incomeLedger: List<FinancialMovementModel>.unmodifiable(incomes),
    expenseLedger: List<FinancialMovementModel>.unmodifiable(expenses),
    nameOfLedger: 'Income',
  );
}

/// Minimal income ledger for 2024: one salary entry per month (25th).
List<FinancialMovementModel> defaultIncomeLedger2024({
  required int salaryMonthly,
}) {
  final List<FinancialMovementModel> list = <FinancialMovementModel>[];
  for (int m = 1; m <= 12; m++) {
    final DateTime d = DateTime(2024, m, 25);
    list.add(
      FinancialMovementModel(
        id: 'inc-salary-$m',
        amount: salaryMonthly,
        date: d,
        concept: 'Salario',
        detailedDescription: 'Salario mensual',
        category: 'Salario',
        createdAt: d,
      ),
    );
  }
  return list;
}

/// Minimal expense ledger for 2024: one record per category per month.
List<FinancialMovementModel> defaultExpenseLedger2024({
  required int rentMonthly,
  required int utilitiesMonthly,
  required int groceriesMonthly,
  required int transportMonthly,
  required int entertainmentMonthly,
}) {
  final List<FinancialMovementModel> list = <FinancialMovementModel>[];
  for (int m = 1; m <= 12; m++) {
    // 1) Arriendo (día 1)
    final DateTime rentDate = DateTime(2024, m);
    list.add(
      FinancialMovementModel(
        id: 'exp-rent-$m',
        amount: rentMonthly,
        date: rentDate,
        concept: 'Arriendo',
        detailedDescription: 'Arriendo mensual',
        category: 'Arriendo',
        createdAt: rentDate,
      ),
    );

    // 2) Servicios (día 15)
    final DateTime utilDate = DateTime(2024, m, 15);
    list.add(
      FinancialMovementModel(
        id: 'exp-utils-$m',
        amount: utilitiesMonthly,
        date: utilDate,
        concept: 'Servicios',
        detailedDescription: 'Luz/agua/internet',
        category: 'Servicios',
        createdAt: utilDate,
      ),
    );

    // 3) Mercado (día 7)
    final DateTime grocDate = DateTime(2024, m, 7);
    list.add(
      FinancialMovementModel(
        id: 'exp-groceries-$m',
        amount: groceriesMonthly,
        date: grocDate,
        concept: 'Mercado',
        detailedDescription: 'Supermercado mensual',
        category: 'Mercado',
        createdAt: grocDate,
      ),
    );

    // 4) Transporte (día 10)
    final DateTime trnDate = DateTime(2024, m, 10);
    list.add(
      FinancialMovementModel(
        id: 'exp-transport-$m',
        amount: transportMonthly,
        date: trnDate,
        concept: 'Transporte',
        detailedDescription: 'Abono/recargas',
        category: 'Transporte',
        createdAt: trnDate,
      ),
    );

    // 5) Entretenimiento (día 20)
    final DateTime entDate = DateTime(2024, m, 20);
    list.add(
      FinancialMovementModel(
        id: 'exp-entertainment-$m',
        amount: entertainmentMonthly,
        date: entDate,
        concept: 'Entretenimiento',
        detailedDescription: 'Ocio mensual',
        category: 'Entretenimiento',
        createdAt: entDate,
      ),
    );
  }
  return list;
}
