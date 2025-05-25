import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('LedgerModel', () {
    final FinancialMovementModel ingreso = FinancialMovementModel(
      id: '1',
      amount: 100000,
      date: DateTime(2025),
      concept: 'Salario',
      category: 'Ingreso',
      createdAt: DateTime(2025),
    );

    final FinancialMovementModel gasto = FinancialMovementModel(
      id: '2',
      amount: 40000,
      date: DateTime(2025, 01, 02),
      concept: 'Comida',
      category: 'Gasto',
      createdAt: DateTime(2025, 01, 02),
    );

    final LedgerModel ledger = LedgerModel(
      nameOfLedger: 'Mi Libro 2025',
      incomeLedger: <FinancialMovementModel>[ingreso],
      expenseLedger: <FinancialMovementModel>[gasto],
    );

    test('balance is calculated correctly', () {
      expect(ledger.balance, 60000);
    });

    test('decimalBalance is calculated correctly', () {
      expect(
        ledger.decimalBalance,
        ingreso.decimalAmount - gasto.decimalAmount,
      );
    });

    test('toJson produces correct map', () {
      final Map<String, dynamic> json = ledger.toJson();
      expect(json[LedgerEnum.nameOfLedger.name], 'Mi Libro 2025');
      expect((json[LedgerEnum.incomeLedger.name] as List<dynamic>).length, 1);
      expect((json[LedgerEnum.expenseLedger.name] as List<dynamic>).length, 1);
    });

    test('fromJson recreates object properly', () {
      final Map<String, dynamic> json = ledger.toJson();
      final LedgerModel recreated = LedgerModel.fromJson(json);
      expect(recreated.nameOfLedger, ledger.nameOfLedger);
      expect(recreated.balance, ledger.balance);
      expect(recreated.incomeLedger.first.id, '1');
    });

    test('copyWith modifies only specified fields', () {
      final LedgerModel modified = ledger.copyWith(nameOfLedger: 'Otro libro');
      expect(modified.nameOfLedger, 'Otro libro');
      expect(modified.incomeLedger, ledger.incomeLedger);
    });

    test('equality and hashCode behave correctly', () {
      final LedgerModel copy = ledger.copyWith();
      expect(copy, ledger);
      expect(copy.hashCode, ledger.hashCode);
    });

    test('toString includes balance and name', () {
      final String str = ledger.toString();
      expect(str.contains('Mi Libro 2025'), isTrue);
      expect(str.contains(ledger.decimalBalance.toString()), isTrue);
    });
  });
}
