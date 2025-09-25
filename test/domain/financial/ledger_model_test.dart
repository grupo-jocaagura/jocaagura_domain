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

  group('LedgerModel — fromJson & toJson', () {
    test(
        'Given JSON válido When fromJson Then crea listas inmutables y calcula balances',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        LedgerEnum.nameOfLedger.name: 'Primary',
        LedgerEnum.incomeLedger.name: <Map<String, dynamic>>[
          FinancialMovementModel.fromDecimal(
            id: 'i1',
            decimalAmount: 10.50,
            date: DateTime(2025),
            concept: 'Salary',
            category: 'Income',
            createdAt: DateTime(2025),
            precision: 2,
          ).toJson(),
        ],
        LedgerEnum.expenseLedger.name: <Map<String, dynamic>>[
          FinancialMovementModel.fromDecimal(
            id: 'e1',
            decimalAmount: 3.25,
            date: DateTime(2025, 1, 2),
            concept: 'Groceries',
            category: 'Expense',
            createdAt: DateTime(2025, 1, 2),
            precision: 2,
          ).toJson(),
        ],
      };

      // Act
      final LedgerModel ledger = LedgerModel.fromJson(json);

      // Assert (inmutabilidad de colecciones)
      expect(
        () => ledger.incomeLedger.add(defaultMovement),
        throwsUnsupportedError,
      );
      expect(
        () => ledger.expenseLedger.add(defaultMovement),
        throwsUnsupportedError,
      );

      // Assert (balance entero y decimal)
      // 10.50 - 3.25 = 7.25
      expect(ledger.decimalBalance, closeTo(7.25, 1e-9));
      // Para el balance entero dependemos de precisión de cada movimiento (2):
      // 1050 - 325 = 725
      expect(ledger.balance, 725);

      // Round-trip
      final Map<String, dynamic> back = ledger.toJson();
      final LedgerModel again = LedgerModel.fromJson(back);
      expect(again, equals(ledger));
    });
  });

  group('LedgerModel — copyWith', () {
    test('Given nuevas listas When copyWith Then envuelve en unmodifiable', () {
      // Arrange
      final LedgerModel base = LedgerModel.fromJson(<String, dynamic>{
        LedgerEnum.nameOfLedger.name: 'Base',
        LedgerEnum.incomeLedger.name: const <Map<String, dynamic>>[],
        LedgerEnum.expenseLedger.name: const <Map<String, dynamic>>[],
      });

      final List<FinancialMovementModel> incomes = <FinancialMovementModel>[
        FinancialMovementModel.fromDecimal(
          id: 'i2',
          decimalAmount: 1.00,
          date: DateTime(2025, 1, 3),
          concept: 'Gift',
          category: 'Income',
          createdAt: DateTime(2025, 1, 3),
          precision: 2,
        ),
      ];

      // Act
      final LedgerModel updated = base.copyWith(incomeLedger: incomes);

      // Assert
      expect(updated.incomeLedger.length, 1);
      expect(
        () => updated.incomeLedger.add(defaultMovement),
        throwsUnsupportedError,
      );

      // Asegurar que la lista original externa puede mutar sin afectar al ledger
      incomes.add(defaultMovement);
      expect(
        updated.incomeLedger.length,
        1,
        reason: 'Debe permanecer inmutable',
      );
    });
  });

  group('LedgerModel — equality & hashCode', () {
    test(
        'Given dos libros con mismas entradas (mismo orden) Then son iguales y hash coincide',
        () {
      // Arrange
      final FinancialMovementModel i = FinancialMovementModel.fromDecimal(
        id: 'i3',
        decimalAmount: 2.00,
        date: DateTime(2025, 1, 4),
        concept: 'Sale',
        category: 'Income',
        createdAt: DateTime(2025, 1, 4),
        precision: 2,
      );
      final FinancialMovementModel e = FinancialMovementModel.fromDecimal(
        id: 'e3',
        decimalAmount: 1.50,
        date: DateTime(2025, 1, 5),
        concept: 'Food',
        category: 'Expense',
        createdAt: DateTime(2025, 1, 5),
        precision: 2,
      );

      final LedgerModel a = LedgerModel(
        nameOfLedger: 'Eq',
        incomeLedger: List<FinancialMovementModel>.unmodifiable(
          <FinancialMovementModel>[i],
        ),
        expenseLedger: List<FinancialMovementModel>.unmodifiable(
          <FinancialMovementModel>[e],
        ),
      );
      final LedgerModel b = LedgerModel(
        nameOfLedger: 'Eq',
        incomeLedger: List<FinancialMovementModel>.unmodifiable(
          <FinancialMovementModel>[i],
        ),
        expenseLedger: List<FinancialMovementModel>.unmodifiable(
          <FinancialMovementModel>[e],
        ),
      );

      // Assert
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('Given mismas entradas pero distinto orden Then no son iguales', () {
      // Arrange
      final FinancialMovementModel i1 = FinancialMovementModel.fromDecimal(
        id: 'iA',
        decimalAmount: 1.00,
        date: DateTime(2025),
        concept: 'A',
        category: 'Income',
        createdAt: DateTime(2025),
        precision: 2,
      );
      final FinancialMovementModel i2 = FinancialMovementModel.fromDecimal(
        id: 'iB',
        decimalAmount: 2.00,
        date: DateTime(2025, 1, 2),
        concept: 'B',
        category: 'Income',
        createdAt: DateTime(2025, 1, 2),
        precision: 2,
      );

      final LedgerModel a = LedgerModel(
        nameOfLedger: 'Order',
        incomeLedger: List<FinancialMovementModel>.unmodifiable(
          <FinancialMovementModel>[i1, i2],
        ),
        expenseLedger: const <FinancialMovementModel>[],
      );
      final LedgerModel b = LedgerModel(
        nameOfLedger: 'Order',
        incomeLedger: List<FinancialMovementModel>.unmodifiable(
          <FinancialMovementModel>[i2, i1],
        ),
        expenseLedger: const <FinancialMovementModel>[],
      );

      // Assert
      expect(a == b, isFalse);
    });
  });

  group('LedgerModel — constructor principal (riesgo documentado)', () {
    test(
        'Given listas MUTABLES al ctor Then el modelo puede ser mutable externamente (documentado)',
        () {
      // Este test ilustra el riesgo (no es un hard-fail): el ctor principal no envuelve.
      final List<FinancialMovementModel> incomes = <FinancialMovementModel>[];
      final LedgerModel ledger = LedgerModel(
        nameOfLedger: 'MutableCtor',
        incomeLedger: incomes,
        expenseLedger: const <FinancialMovementModel>[],
      );

      // Mutación externa
      incomes.add(defaultMovement);

      // El ledger "ve" el cambio porque comparte referencia.
      expect(
        ledger.incomeLedger.length,
        1,
        reason: 'Constructor principal no envuelve; riesgo documentado.',
      );
    });
  });

  group('LedgerModel.fromJson — Formas válidas de JSON', () {
    test(
      'Given listas bien formadas de Map<String,dynamic> '
      'When fromJson '
      'Then crea LedgerModel con balances correctos',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          LedgerEnum.nameOfLedger.name: 'Primary',
          LedgerEnum.incomeLedger.name: <Map<String, dynamic>>[
            FinancialMovementModel.fromDecimal(
              id: 'i1',
              decimalAmount: 100.00,
              date: DateTime(2025),
              concept: 'Salary',
              category: 'Income',
              createdAt: DateTime(2025),
              precision: 2,
            ).toJson(),
          ],
          LedgerEnum.expenseLedger.name: <Map<String, dynamic>>[
            FinancialMovementModel.fromDecimal(
              id: 'e1',
              decimalAmount: 30.50,
              date: DateTime(2025, 1, 2),
              concept: 'Groceries',
              category: 'Expense',
              createdAt: DateTime(2025, 1, 2),
              precision: 2,
            ).toJson(),
          ],
        };

        // Act
        final LedgerModel ledger = LedgerModel.fromJson(json);

        // Assert
        expect(ledger.nameOfLedger, 'Primary');
        expect(ledger.incomeLedger.length, 1);
        expect(ledger.expenseLedger.length, 1);
        expect(ledger.decimalBalance, closeTo(69.50, 1e-9));
        expect(ledger.balance, 6950);
      },
    );

    test(
      'Given listas de List<dynamic> mezclando Map y no-Map '
      'When fromJson '
      'Then ignora los no-Map y parsea solo los Map válidos',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          LedgerEnum.nameOfLedger.name: 'Mixed',
          LedgerEnum.incomeLedger.name: <dynamic>[
            // válido
            FinancialMovementModel.fromDecimal(
              id: 'i1',
              decimalAmount: 10.00,
              date: DateTime(2025, 1, 3),
              concept: 'Gift',
              category: 'Income',
              createdAt: DateTime(2025, 1, 3),
              precision: 2,
            ).toJson(),
            // ruido: no-Map
            42,
            'string',
            null,
            // válido con claves adicionales (deben ser ignoradas por el modelo)
            <String, dynamic>{
              ...FinancialMovementModel.fromDecimal(
                id: 'i2',
                decimalAmount: 5.50,
                date: DateTime(2025, 1, 4),
                concept: 'Tip',
                category: 'Income',
                createdAt: DateTime(2025, 1, 4),
                precision: 2,
              ).toJson(),
              'extra': 'ignore-me',
            },
          ],
          LedgerEnum.expenseLedger.name: <dynamic>[
            // válido
            FinancialMovementModel.fromDecimal(
              id: 'e1',
              decimalAmount: 3.00,
              date: DateTime(2025, 1, 5),
              concept: 'Snacks',
              category: 'Expense',
              createdAt: DateTime(2025, 1, 5),
              precision: 2,
            ).toJson(),
            // ruido: lista dentro de lista
            <int>[1, 2, 3],
          ],
        };

        // Act
        final LedgerModel ledger = LedgerModel.fromJson(json);

        // Assert: solo debe contar 2 ingresos válidos y 1 egreso válido
        expect(ledger.incomeLedger.length, 2);
        expect(ledger.expenseLedger.length, 1);

        // (10.00 + 5.50) - 3.00 = 12.50
        expect(ledger.decimalBalance, closeTo(12.50, 1e-9));
        expect(ledger.balance, 1250);
      },
    );

    test(
      'Given incomeLedger/expenseLedger ausentes (null) '
      'When fromJson '
      'Then crea listas vacías y balance en 0',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          LedgerEnum.nameOfLedger.name: 'Empty',
          // Sin incomeLedger
          // Sin expenseLedger
        };

        // Act
        final LedgerModel ledger = LedgerModel.fromJson(json);

        // Assert
        expect(ledger.incomeLedger, isEmpty);
        expect(ledger.expenseLedger, isEmpty);
        expect(ledger.balance, 0);
        expect(ledger.decimalBalance, 0.0);
      },
    );

    test(
      'Given movimientos con diferentes precisiones '
      'When fromJson '
      'Then balance entero/decimal respeta cada mathPrecision individual',
      () {
        // Arrange
        // i1: 12.3456 @ p=4 => 123456
        // i2:  1.20   @ p=2 =>   120
        // e1:  0.005  @ p=3 =>     5
        final Map<String, dynamic> json = <String, dynamic>{
          LedgerEnum.nameOfLedger.name: 'Precisions',
          LedgerEnum.incomeLedger.name: <Map<String, dynamic>>[
            FinancialMovementModel.fromDecimal(
              id: 'i1',
              decimalAmount: 12.3456,
              date: DateTime(2025, 1, 6),
              concept: 'A',
              category: 'Income',
              createdAt: DateTime(2025, 1, 6),
            ).toJson(),
            FinancialMovementModel.fromDecimal(
              id: 'i2',
              decimalAmount: 1.20,
              date: DateTime(2025, 1, 6),
              concept: 'B',
              category: 'Income',
              createdAt: DateTime(2025, 1, 6),
              precision: 2,
            ).toJson(),
          ],
          LedgerEnum.expenseLedger.name: <Map<String, dynamic>>[
            FinancialMovementModel.fromDecimal(
              id: 'e1',
              decimalAmount: 0.005,
              date: DateTime(2025, 1, 7),
              concept: 'Fee',
              category: 'Expense',
              createdAt: DateTime(2025, 1, 7),
              precision: 3,
            ).toJson(),
          ],
        };

        // Act
        final LedgerModel ledger = LedgerModel.fromJson(json);

        // Assert (decimal): 12.3456 + 1.20 - 0.005 = 13.5406
        expect(ledger.decimalBalance, closeTo(13.5406, 1e-9));

        // Assert (entero): depende de MoneyUtils.totalAmount(...)
        // que suma enteros ya escalados por movimiento y resta los de egresos.
        // Aquí verificamos consistencia con toJson->fromJson (round-trip).
        final LedgerModel again = LedgerModel.fromJson(ledger.toJson());
        expect(again.balance, ledger.balance);
        expect(again.decimalBalance, closeTo(ledger.decimalBalance, 1e-9));
      },
    );

    test(
      'Given amount negativo dentro de items (permitido por contrato de movimiento) '
      'When fromJson '
      'Then normaliza a positivo por política del modelo de movimiento',
      () {
        // Arrange: forzamos un item con amount negativo en el JSON bruto
        final FinancialMovementModel base = FinancialMovementModel.fromDecimal(
          id: 'i1',
          decimalAmount: 5.00,
          date: DateTime(2025, 1, 8),
          concept: 'Base',
          category: 'Income',
          createdAt: DateTime(2025, 1, 8),
          precision: 2,
        );
        final Map<String, dynamic> badIncome = <String, dynamic>{
          ...base.toJson(),
          FinancialMovementEnum.amount.name: -base.amount, // < 0
        };

        final Map<String, dynamic> json = <String, dynamic>{
          LedgerEnum.nameOfLedger.name: 'Negatives',
          LedgerEnum.incomeLedger.name: <Map<String, dynamic>>[badIncome],
          LedgerEnum.expenseLedger.name: <Map<String, dynamic>>[],
        };

        // Act
        final LedgerModel ledger = LedgerModel.fromJson(json);

        // Assert: el movimiento interno se normaliza (por FinancialMovementModel.fromJson)
        expect(ledger.incomeLedger.first.amount, base.amount);
        expect(ledger.decimalBalance, closeTo(5.00, 1e-9));
      },
    );
  });
}
