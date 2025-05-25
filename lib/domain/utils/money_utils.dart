part of '../../jocaagura_domain.dart';

/// Utilidades transversales para operar sobre listas de movimientos financieros.
///
/// ### Ejemplo de uso
/// ```dart
/// final ingresos = ledger.incomeLedger;
/// final gastos = ledger.expenseLedger;
/// final balance = MoneyUtils.totalDecimalAmount(ingresos) - MoneyUtils.totalDecimalAmount(gastos);
/// final resumenPorCategoria = MoneyUtils.totalPerCategory(gastos);
/// ```
class MoneyUtils implements EntityUtil {
  /// Retorna la sumatoria total de los movimientos.
  static int totalAmount(List<FinancialMovementModel> movements) {
    return movements.fold(
      0,
      (int sum, FinancialMovementModel item) => sum + item.amount,
    );
  }

  /// Retorna la suma en formato decimal con precisión.
  static double totalDecimalAmount(List<FinancialMovementModel> movements) {
    if (movements.isEmpty) {
      return 0.0;
    }
    return movements.fold<double>(
      0.0,
      (double sum, FinancialMovementModel item) => sum + item.decimalAmount,
    );
  }

  /// Calcula el promedio de los movimientos.
  static double average(List<FinancialMovementModel> movements) {
    return movements.isEmpty
        ? 0.0
        : totalDecimalAmount(movements) / movements.length;
  }

  /// Filtra los movimientos por categoría.
  static List<FinancialMovementModel> filterByCategory(
    List<FinancialMovementModel> movements,
    String category,
  ) {
    return movements
        .where((FinancialMovementModel m) => m.category == category)
        .toList();
  }

  /// Agrupa los montos por categoría.
  static Map<String, int> totalPerCategory(
    List<FinancialMovementModel> movements,
  ) {
    final Map<String, int> result = <String, int>{};
    for (final FinancialMovementModel m in movements) {
      result[m.category] = (result[m.category] ?? 0) + m.amount;
    }
    return result;
  }

  /// Agrupa por categoría en decimal.
  static Map<String, double> totalDecimalPerCategory(
    List<FinancialMovementModel> movements,
  ) {
    final Map<String, double> result = <String, double>{};
    for (final FinancialMovementModel m in movements) {
      result[m.category] = (result[m.category] ?? 0) + m.decimalAmount;
    }
    return result;
  }

  /// Retorna los movimientos que se encuentran entre un rango de fechas, inclusive.
  static List<FinancialMovementModel> filterByDateRange(
    List<FinancialMovementModel> movements,
    DateTime start,
    DateTime end,
  ) {
    return movements
        .where(
          (FinancialMovementModel m) =>
              !m.date.isBefore(start) && !m.date.isAfter(end),
        )
        .toList();
  }

  /// Agrupa movimientos por año y mes (formato 'yyyy-MM') y suma sus montos enteros.
  static Map<String, int> totalByMonth(
    List<FinancialMovementModel> movements,
  ) {
    final Map<String, int> result = <String, int>{};
    for (final FinancialMovementModel m in movements) {
      final String key =
          '${m.date.year.toString().padLeft(4, '0')}-${m.date.month.toString().padLeft(2, '0')}';
      result[key] = (result[key] ?? 0) + m.amount;
    }
    return result;
  }

  /// Agrupa movimientos por año y mes y retorna montos decimales por cada agrupación.
  static Map<String, double> totalDecimalByMonth(
    List<FinancialMovementModel> movements,
  ) {
    final Map<String, double> result = <String, double>{};
    for (final FinancialMovementModel m in movements) {
      final String key =
          '${m.date.year.toString().padLeft(4, '0')}-${m.date.month.toString().padLeft(2, '0')}';
      result[key] = (result[key] ?? 0) + m.decimalAmount;
    }
    return result;
  }

  /// Devuelve el último movimiento registrado según la fecha.
  static FinancialMovementModel? getLatestMovement(
    List<FinancialMovementModel> movements,
  ) {
    if (movements.isEmpty) {
      return null;
    }
    movements.sort(
      (FinancialMovementModel a, FinancialMovementModel b) =>
          b.date.compareTo(a.date),
    );
    return movements.first;
  }

  /// Verifica si un movimiento con el mismo ID ya está registrado.
  static bool containsMovement(
    List<FinancialMovementModel> movements,
    String id,
  ) {
    return movements.any((FinancialMovementModel m) => m.id == id);
  }

  /// Ordena los movimientos por fecha (ascendente por defecto).
  static List<FinancialMovementModel> sortByDate(
    List<FinancialMovementModel> movements, {
    bool ascending = true,
  }) {
    final List<FinancialMovementModel> copy =
        List<FinancialMovementModel>.from(movements);
    copy.sort(
      (FinancialMovementModel a, FinancialMovementModel b) =>
          ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date),
    );
    return copy;
  }
}
