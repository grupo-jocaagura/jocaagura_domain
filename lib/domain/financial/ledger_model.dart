part of '../../jocaagura_domain.dart';

/// Enum que representa los campos de un libro contable.
enum LedgerEnum {
  /// Nombre del libro contable.
  nameOfLedger,

  /// Lista de ingresos.
  incomeLedger,

  /// Lista de egresos.
  expenseLedger,
}

/// Representa un libro contable que agrupa los movimientos financieros de un usuario.
///
/// Cada libro contiene una lista de ingresos y egresos, calculando totales y permitiendo
/// operaciones básicas de análisis financiero.
class LedgerModel extends Model {
  /// Crea una instancia de [LedgerModel].
  const LedgerModel({
    required this.nameOfLedger,
    required this.incomeLedger,
    required this.expenseLedger,
  });

  /// Crea una instancia de [LedgerModel] a partir de un JSON.
  factory LedgerModel.fromJson(Map<String, dynamic> json) {
    return LedgerModel(
      nameOfLedger:
          Utils.getStringFromDynamic(json[LedgerEnum.nameOfLedger.name]),
      incomeLedger: Utils.listFromDynamic(json[LedgerEnum.incomeLedger.name])
          .map(FinancialMovementModel.fromJson)
          .toList(),
      expenseLedger: Utils.listFromDynamic(json[LedgerEnum.expenseLedger.name])
          .map(FinancialMovementModel.fromJson)
          .toList(),
    );
  }

  /// Nombre del libro contable.
  final String nameOfLedger;

  /// Lista de ingresos.
  final List<FinancialMovementModel> incomeLedger;

  /// Lista de egresos.
  final List<FinancialMovementModel> expenseLedger;

  /// Retorna el saldo total del libro (ingresos - egresos).
  int get balance =>
      MoneyUtils.totalAmount(incomeLedger) -
      MoneyUtils.totalAmount(expenseLedger);

  /// Retorna el saldo total del libro en formato decimal.
  double get decimalBalance =>
      MoneyUtils.totalDecimalAmount(incomeLedger) -
      MoneyUtils.totalDecimalAmount(expenseLedger);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      LedgerEnum.nameOfLedger.name: nameOfLedger,
      LedgerEnum.incomeLedger.name:
          incomeLedger.map((FinancialMovementModel e) => e.toJson()).toList(),
      LedgerEnum.expenseLedger.name:
          expenseLedger.map((FinancialMovementModel e) => e.toJson()).toList(),
    };
  }

  @override
  LedgerModel copyWith({
    String? nameOfLedger,
    List<FinancialMovementModel>? incomeLedger,
    List<FinancialMovementModel>? expenseLedger,
  }) {
    return LedgerModel(
      nameOfLedger: nameOfLedger ?? this.nameOfLedger,
      incomeLedger: incomeLedger ?? this.incomeLedger,
      expenseLedger: expenseLedger ?? this.expenseLedger,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LedgerModel &&
            nameOfLedger == other.nameOfLedger &&
            incomeLedger == other.incomeLedger &&
            expenseLedger == other.expenseLedger;
  }

  @override
  int get hashCode => Object.hash(nameOfLedger, incomeLedger, expenseLedger);

  @override
  String toString() {
    return 'LedgerModel(name: $nameOfLedger, balance: $decimalBalance)';
  }
}
