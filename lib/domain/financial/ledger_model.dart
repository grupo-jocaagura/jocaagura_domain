part of '../../jocaagura_domain.dart';

enum LedgerEnum { nameOfLedger, incomeLedger, expenseLedger }

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

  // --- Deep equality/hash SIN paquetes externos (ordenada) ---
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
      hash = 37 * hash + (e?.hashCode ?? 0);
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
