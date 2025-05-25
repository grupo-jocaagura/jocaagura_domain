import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('MoneyUtils', () {
    final List<FinancialMovementModel> movements = <FinancialMovementModel>[
      FinancialMovementModel(
        id: '1',
        amount: 1000,
        date: DateTime(2025),
        concept: 'Ingreso',
        category: 'Salario',
        createdAt: DateTime(2025),
      ),
      FinancialMovementModel(
        id: '2',
        amount: 500,
        date: DateTime(2025, 01, 02),
        concept: 'Gasto',
        category: 'Comida',
        createdAt: DateTime(2025, 01, 02),
      ),
      FinancialMovementModel(
        id: '3',
        amount: 1500,
        date: DateTime(2025, 02),
        concept: 'Ingreso Extra',
        category: 'Freelance',
        createdAt: DateTime(2025, 02),
      ),
    ];

    test('totalAmount returns correct sum', () {
      expect(MoneyUtils.totalAmount(movements), 3000);
    });

    test('totalDecimalAmount returns correct sum', () {
      expect(MoneyUtils.totalDecimalAmount(movements), closeTo(0.3, 0.0001));
    });

    test('average returns correct value', () {
      expect(MoneyUtils.average(movements), closeTo(0.1, 0.0001));
    });

    test('filterByCategory returns correct filtered list', () {
      final List<FinancialMovementModel> result =
          MoneyUtils.filterByCategory(movements, 'Salario');
      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('totalPerCategory returns correct grouping', () {
      final Map<String, int> result = MoneyUtils.totalPerCategory(movements);
      expect(result['Salario'], 1000);
      expect(result['Comida'], 500);
      expect(result['Freelance'], 1500);
    });

    test('filterByDateRange returns correct results', () {
      final List<FinancialMovementModel> result = MoneyUtils.filterByDateRange(
        movements,
        DateTime(2025),
        DateTime(2025, 01, 31),
      );
      expect(result.length, 2);
    });

    test('getLatestMovement returns the most recent', () {
      final FinancialMovementModel? latest =
          MoneyUtils.getLatestMovement(movements);
      expect(latest?.id, '3');
    });

    test('containsMovement finds existing ID', () {
      expect(MoneyUtils.containsMovement(movements, '2'), true);
      expect(MoneyUtils.containsMovement(movements, '999'), false);
    });

    test('sortByDate orders correctly ascending and descending', () {
      final List<FinancialMovementModel> asc = MoneyUtils.sortByDate(movements);
      final List<FinancialMovementModel> desc =
          MoneyUtils.sortByDate(movements, ascending: false);
      expect(asc.first.id, '1');
      expect(desc.first.id, '3');
    });

    test('totalByMonth and totalDecimalByMonth group correctly', () {
      final Map<String, int> intMap = MoneyUtils.totalByMonth(movements);
      final Map<String, double> doubleMap =
          MoneyUtils.totalDecimalByMonth(movements);
      expect(intMap['2025-01'], 1500);
      expect(intMap['2025-02'], 1500);
      expect(doubleMap['2025-01'], closeTo(0.15, 0.0001));
      expect(doubleMap['2025-02'], closeTo(0.15, 0.0001));
    });
  });
  group('MoneyUtils.totalDecimalPerCategory', () {
    test('returns correct map with aggregated decimal values', () {
      final List<FinancialMovementModel> movements = <FinancialMovementModel>[
        FinancialMovementModel(
          id: '1',
          amount: 1000,
          date: DateTime(2025),
          concept: 'Ingreso enero',
          category: 'Salario',
          createdAt: DateTime(2025),
        ),
        FinancialMovementModel(
          id: '2',
          amount: 500,
          date: DateTime(2025, 01, 02),
          concept: 'Ingreso febrero',
          category: 'Salario',
          createdAt: DateTime(2025, 01, 02),
        ),
        FinancialMovementModel(
          id: '3',
          amount: 300,
          date: DateTime(2025, 01, 03),
          concept: 'Gasto comida',
          category: 'Alimentación',
          createdAt: DateTime(2025, 01, 03),
        ),
      ];

      final Map<String, double> result =
          MoneyUtils.totalDecimalPerCategory(movements);

      expect(result.length, 2);
      expect(result.containsKey('Salario'), isTrue);
      expect(result.containsKey('Alimentación'), isTrue);
      expect(result['Salario'], closeTo((1000 + 500) / 10000, 0.0001));
      expect(result['Alimentación'], closeTo(300 / 10000, 0.0001));
    });

    test('returns empty map when input list is empty', () {
      final Map<String, double> result =
          MoneyUtils.totalDecimalPerCategory(<FinancialMovementModel>[]);
      expect(result, isEmpty);
    });
  });
}
