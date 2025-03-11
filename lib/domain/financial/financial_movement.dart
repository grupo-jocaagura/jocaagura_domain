part of '../../jocaagura_domain.dart';

/// Enum que representa los campos de un movimiento financiero.
enum FinancialMovementEnum {
  /// Identificador único del movimiento financiero.
  id,

  /// Monto del movimiento en centavos para evitar problemas de precisión.
  amount,

  /// Fecha en la que se realizó la transacción.
  date,

  /// Concepto general del movimiento financiero.
  concept,

  /// Descripción detallada del movimiento financiero.
  detailedDescription,

  /// Categoría del movimiento financiero (e.g., "Ingreso", "Gasto").
  category,

  /// Fecha en la que se registró la transacción.
  createdAt,
}

/// Instancia por defecto de [FinancialMovementModel] para propósitos de inicialización o pruebas.
final FinancialMovementModel defaultMovement = FinancialMovementModel(
  id: 'fm001',
  amount: 1000,
  date: DateTime(2024, 07, 20),
  concept: 'Salary',
  detailedDescription: 'Monthly salary deposit',
  category: 'Income',
  createdAt: DateTime(2024, 07, 25),
);

/// Representa un movimiento financiero en el libro de cuentas de un usuario.
///
/// Esta clase es inmutable y extiende la base [Model] de `jocaagura_domain`.
/// Asegura consistencia financiera al registrar transacciones sin permitir modificaciones.
///
/// ### Ejemplo de uso:
/// ```dart
/// void main() {
///   final FinancialMovementModel movement = FinancialMovementModel(
///     id: 'txn123',
///     amount: 5000,
///     date: DateTime.now(),
///     concept: 'Compra de supermercado',
///     detailedDescription: 'Pago de alimentos en tienda local',
///     category: 'Gasto',
///     createdAt: DateTime.now(),
///   );
///
///   print(movement);
/// }
/// ```
///
/// Esta clase es útil para rastrear transacciones financieras en un sistema de contabilidad personal.
class FinancialMovementModel extends Model {
  /// Crea una nueva instancia de movimiento financiero.
  const FinancialMovementModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.concept,
    required this.category,
    required this.createdAt,
    this.detailedDescription = '',
  });

  /// Crea una instancia de [FinancialMovementModel] a partir de un JSON.
  factory FinancialMovementModel.fromJson(Map<String, dynamic> json) {
    return FinancialMovementModel(
      id: Utils.getStringFromDynamic(json[FinancialMovementEnum.id.name]),
      amount:
          Utils.getIntegerFromDynamic(json[FinancialMovementEnum.amount.name]),
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
    );
  }

  /// Identificador único del movimiento financiero.
  final String id;

  /// Monto de la transacción (en centavos para evitar problemas de precisión).
  final int amount;

  /// Fecha en la que se realizó la transacción.
  final DateTime date;

  /// Concepto del movimiento (e.g., "Salario", "Compra de supermercado").
  final String concept;

  /// Descripción detallada del movimiento financiero.
  final String detailedDescription;

  /// Categoría del movimiento (e.g., "Ingreso", "Gasto").
  final String category;

  /// Fecha de creación del registro del movimiento financiero.
  final DateTime createdAt;

  /// Convierte este modelo a un formato JSON.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      FinancialMovementEnum.id.name: id,
      FinancialMovementEnum.amount.name: amount,
      FinancialMovementEnum.date.name: DateUtils.dateTimeToString(date),
      FinancialMovementEnum.concept.name: concept,
      FinancialMovementEnum.detailedDescription.name: detailedDescription,
      FinancialMovementEnum.category.name: category,
      FinancialMovementEnum.createdAt.name:
          DateUtils.dateTimeToString(createdAt),
    };
  }

  /// Crea una copia de este modelo con valores modificados.
  @override
  FinancialMovementModel copyWith({
    String? id,
    int? amount,
    DateTime? date,
    String? concept,
    String? detailedDescription,
    String? category,
    DateTime? createdAt,
  }) {
    return FinancialMovementModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      concept: concept ?? this.concept,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Compara dos instancias de [FinancialMovementModel] para determinar si son iguales.
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
            other.createdAt == createdAt;
  }

  /// Genera un código hash único para esta instancia.
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
    );
  }

  /// Representación en cadena de texto del objeto.
  @override
  String toString() {
    return 'FinancialMovementModel(id: $id, amount: $amount, date: $date, '
        'concept: "$concept", category: "$category", createdAt: $createdAt)';
  }
}
