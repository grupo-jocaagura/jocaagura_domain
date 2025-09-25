import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

final DateTime testDate = DateTime(2024, 07, 20);
final DateTime createdAt = DateTime(2024, 07, 25);

void main() {
  group('FinancialMovementModel Tests', () {
    test('Constructor sets values correctly', () {
      expect(defaultMovement.id, 'fm001');
      expect(defaultMovement.amount, 1000);
      expect(defaultMovement.date, testDate);
      expect(defaultMovement.concept, 'Salary');
      expect(defaultMovement.detailedDescription, 'Monthly salary deposit');
      expect(defaultMovement.category, 'Income');
      expect(defaultMovement.createdAt, createdAt);
    });

    test('toJson returns correct map', () {
      final Map<String, dynamic> json = defaultMovement.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['id'], 'fm001');
      expect(json['amount'], 1000);
      expect(json['date'], testDate.toIso8601String());
      expect(json['concept'], 'Salary');
      expect(json['detailedDescription'], 'Monthly salary deposit');
      expect(json['category'], 'Income');
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('copyWith returns a modified instance', () {
      final FinancialMovementModel modifiedMovement = defaultMovement.copyWith(
        amount: 2000,
        concept: 'Bonus',
      );

      expect(modifiedMovement.id, defaultMovement.id);
      expect(modifiedMovement.amount, 2000);
      expect(modifiedMovement.concept, 'Bonus');
      expect(
        modifiedMovement.detailedDescription,
        defaultMovement.detailedDescription,
      );
      expect(modifiedMovement.category, defaultMovement.category);
      expect(modifiedMovement.createdAt, defaultMovement.createdAt);
    });

    test('copyWith without parameters returns identical instance', () {
      final FinancialMovementModel copiedMovement = defaultMovement.copyWith();
      expect(copiedMovement, equals(defaultMovement));
      expect(copiedMovement.hashCode, equals(defaultMovement.hashCode));
    });

    test('Equality operator works correctly', () {
      final FinancialMovementModel identicalMovement =
          defaultMovement.copyWith();
      expect(defaultMovement, equals(identicalMovement));
    });

    test('hashCode is consistent for equal objects', () {
      final FinancialMovementModel movement1 = defaultMovement;
      final FinancialMovementModel movement2 = defaultMovement.copyWith();
      expect(movement1.hashCode, movement2.hashCode);
    });

    test('Inequality operator works correctly', () {
      final FinancialMovementModel differentMovement =
          defaultMovement.copyWith(amount: 500);
      expect(defaultMovement, isNot(equals(differentMovement)));
    });

    test('toString returns a formatted string', () {
      final String movementString = defaultMovement.toString();
      expect(
        movementString,
        'FinancialMovementModel(id: fm001, amount: 1000, date: $testDate, '
        'concept: "Salary", category: "Income", createdAt: $createdAt, mathPrecision: ${FinancialMovementModel.defaultMathPrecision})',
      );
    });

    test('Handles empty JSON gracefully', () {
      final Map<String, dynamic> json = <String, dynamic>{};

      final FinancialMovementModel movement =
          FinancialMovementModel.fromJson(json);

      expect(movement.id, '');
      expect(movement.amount, 0);
      expect(movement.date, isA<DateTime>());
      expect(movement.concept, '');
      expect(movement.detailedDescription, '');
      expect(movement.category, '');
      expect(movement.createdAt, isA<DateTime>());
    });
  });

  group('FinancialMovementModel.fromJson Tests', () {
    test('Correctly creates an instance from a valid JSON', () {
      final Map<String, Object> json = <String, Object>{
        'id': 'fm001',
        'amount': 1500,
        'date': '2024-07-20T00:00:00.000Z',
        'concept': 'Freelance Work',
        'detailedDescription': 'Payment for a mobile app project',
        'category': 'freelance',
        'createdAt': '2024-07-25T00:00:00.000Z',
      };

      final FinancialMovementModel movement =
          FinancialMovementModel.fromJson(json);

      expect(movement.id, 'fm001');
      expect(movement.amount, 1500);
      expect(movement.date, DateTime.parse('2024-07-20T00:00:00.000Z'));
      expect(movement.concept, 'Freelance Work');
      expect(movement.detailedDescription, 'Payment for a mobile app project');
      expect(movement.category, 'freelance');
      expect(movement.createdAt, DateTime.parse('2024-07-25T00:00:00.000Z'));
    });

    test('Handles missing optional detailedDescription field', () {
      final Map<String, Object> json = <String, Object>{
        'id': 'fm002',
        'amount': 500,
        'date': '2024-07-22T00:00:00.000Z',
        'concept': 'Dinner',
        'category': 'food',
        'createdAt': '2024-07-25T00:00:00.000Z',
      };

      final FinancialMovementModel movement =
          FinancialMovementModel.fromJson(json);

      expect(movement.id, 'fm002');
      expect(movement.amount, 500);
      expect(movement.date, DateTime.parse('2024-07-22T00:00:00.000Z'));
      expect(movement.concept, 'Dinner');
      expect(movement.detailedDescription, ''); // Default empty string
      expect(movement.category, 'food');
      expect(movement.createdAt, DateTime.parse('2024-07-25T00:00:00.000Z'));
    });

    test('Handles missing required fields with default values or exceptions',
        () {
      final Map<String, String?> json = <String, String?>{
        'id': 'fm003',
        'amount': null,
        'date': '2024-07-22T00:00:00.000Z',
        'concept': 'Movie Night',
        'category': 'entertainment',
        'createdAt': '2024-07-25T00:00:00.000Z',
      };

      final FinancialMovementModel movement =
          FinancialMovementModel.fromJson(json);

      expect(movement.id, 'fm003');
      expect(movement.amount, 0); // Default to 0 if null
      expect(movement.date, DateTime.parse('2024-07-22T00:00:00.000Z'));
      expect(movement.concept, 'Movie Night');
      expect(movement.detailedDescription, ''); // Default empty string
      expect(movement.category, 'entertainment');
      expect(movement.createdAt, DateTime.parse('2024-07-25T00:00:00.000Z'));
    });

    test('Handles incorrect data types gracefully', () {
      final Map<String, Object?> json = <String, Object?>{
        'id': 12345,
        'amount': '2000', // Should be an integer
        'date': 'not a date',
        'concept': 'Car Repair',
        'category': 'transport',
        'createdAt': null, // Should be a valid timestamp
      };

      final FinancialMovementModel movement =
          FinancialMovementModel.fromJson(json);

      expect(movement.id, '12345'); // Converted to string
      expect(movement.amount, 2000); // Converted to integer
      expect(movement.date, isA<DateTime>()); // Should not throw error
      expect(movement.concept, 'Car Repair');
      expect(movement.detailedDescription, ''); // Default empty string
      expect(movement.category, 'transport');
      expect(movement.createdAt, isA<DateTime>());
    });

    test('Handles empty JSON gracefully', () {
      final Map<String, dynamic> json = <String, dynamic>{};

      final FinancialMovementModel movement =
          FinancialMovementModel.fromJson(json);

      expect(movement.id, '');
      expect(movement.amount, 0);
      expect(movement.date, isA<DateTime>());
      expect(movement.concept, '');
      expect(movement.detailedDescription, '');
      expect(movement.category, '');
      expect(movement.createdAt, isA<DateTime>());
    });
  });

  group('FinancialMovementModel Precision Handling', () {
    test('fromDecimal creates model with correct precision (4 decimales)', () {
      final FinancialMovementModel model = FinancialMovementModel.fromDecimal(
        id: 'tx001',
        decimalAmount: 1250.2536,
        date: DateTime(2024, 07, 20),
        concept: 'Test',
        category: 'Precision',
        createdAt: DateTime(2024, 07, 25),
      );

      expect(model.amount, 12502536);
      expect(model.mathPrecision, 4);
      expect(model.decimalAmount, closeTo(1250.2536, 0.0001));
    });

    test('decimalAmount conversion is correct for precision 2', () {
      final FinancialMovementModel model = FinancialMovementModel.fromDecimal(
        id: 'tx002',
        decimalAmount: 3000.25,
        date: DateTime(2024, 07, 20),
        concept: 'Test',
        category: 'Precision',
        createdAt: DateTime(2024, 07, 25),
        precision: 2,
      );

      expect(model.amount, 300025);
      expect(model.decimalAmount, 3000.25);
    });

    test('default precision is used if not specified', () {
      final FinancialMovementModel model = FinancialMovementModel.fromDecimal(
        id: 'tx003',
        decimalAmount: 10.1234,
        date: DateTime(2024, 07, 20),
        concept: 'Test',
        category: 'DefaultPrecision',
        createdAt: DateTime(2024, 07, 25),
      );

      expect(model.amount, 101234);
      expect(model.mathPrecision, FinancialMovementModel.defaultMathPrecision);
    });

    test('throws assertion error when decimalAmount is negative', () {
      final FinancialMovementModel decimalFinancial =
          FinancialMovementModel.fromDecimal(
        id: 'tx004',
        decimalAmount: -5.0,
        date: DateTime(2024, 07, 20),
        concept: 'Invalid',
        category: 'Negative',
        createdAt: DateTime(2024, 07, 25),
      );

      expect(
        decimalFinancial.amount,
        greaterThan(0),
      );
    });

    test('handles double with 8 decimal places at precision 4', () {
      final FinancialMovementModel model = FinancialMovementModel.fromDecimal(
        id: 'tx005',
        decimalAmount: 999.12345678,
        date: DateTime(2024, 07, 20),
        concept: 'HighPrecision',
        category: 'PrecisionTest',
        createdAt: DateTime(2024, 07, 25),
      );

      expect(model.amount, 9991235); // Rounded from 9991234.5678
      expect(model.decimalAmount, closeTo(999.1235, 0.0001));
    });
  });

  group('FinancialMovementModel — Constructor', () {
    test('Given amount >= 0 When construct Then succeeds', () {
      final FinancialMovementModel model = FinancialMovementModel(
        id: 'a',
        amount: 0,
        date: DateTime(2025),
        concept: 'Init',
        category: 'Income',
        createdAt: DateTime(2025),
        mathPrecision: 2,
      );
      expect(model.amount, 0);
      expect(model.mathPrecision, 2);
    });
  });

  group('fromDecimal', () {
    test('Given 12.3456@precision4 When fromDecimal Then amount=123456', () {
      final FinancialMovementModel m = FinancialMovementModel.fromDecimal(
        id: 'x',
        decimalAmount: 12.3456,
        date: DateTime(2025),
        concept: 'C',
        category: 'Income',
        createdAt: DateTime(2025),
      );
      expect(m.amount, 123456);
      expect(m.decimalAmount, closeTo(12.3456, 1e-9));
    });
  });

  group('JSON round-trip', () {
    test('Given model When toJson->fromJson Then equals original', () {
      final FinancialMovementModel original = FinancialMovementModel(
        id: 'id1',
        amount: 1234,
        date: DateTime(2025, 1, 1, 12, 30),
        concept: 'Groceries',
        detailedDescription: 'Local store',
        category: 'Expense',
        createdAt: DateTime(2025, 1, 2, 8),
        mathPrecision: 2,
      );
      final FinancialMovementModel copy =
          FinancialMovementModel.fromJson(original.toJson());
      expect(copy, equals(original));
      expect(copy.mathPrecision, 2);
    });
  });

  group('Equality & hashCode', () {
    test('Given same amount but different precision Then not equal', () {
      final FinancialMovementModel a = FinancialMovementModel(
        id: 'x',
        amount: 1000,
        date: DateTime(2025),
        concept: 'C',
        category: 'Income',
        createdAt: DateTime(2025),
        mathPrecision: 2,
      );
      final FinancialMovementModel b = a.copyWith(mathPrecision: 4);
      expect(a == b, isFalse);
      expect(a.hashCode == b.hashCode, isFalse);
    });
  });

  group('copyWith', () {
    test('Given base When copyWith amount Then returns new with updated field',
        () {
      final FinancialMovementModel base = FinancialMovementModel(
        id: 'i',
        amount: 1,
        date: DateTime(2025),
        concept: 'C',
        category: 'Income',
        createdAt: DateTime(2025),
      );
      final FinancialMovementModel c =
          base.copyWith(amount: 2, mathPrecision: 3);
      expect(c.amount, 2);
      expect(c.mathPrecision, 3);
      expect(c.id, base.id);
    });
  });

  group('FinancialMovementModel — Normalización de signo', () {
    test(
      'Given decimalAmount negativo '
      'When se construye con fromDecimal '
      'Then amount es no-negativo y coincide con |decimal| escalado',
      () {
        // Arrange
        const int precision = FinancialMovementModel.defaultMathPrecision;
        const double decimalAmount = -12.34;
        final DateTime now = DateTime(2025);

        // Act
        final FinancialMovementModel m = FinancialMovementModel.fromDecimal(
          id: 'neg-dec',
          decimalAmount: decimalAmount,
          date: now,
          concept: 'Test',
          category: 'Expense',
          createdAt: now,
        );

        // Assert
        expect(m.amount, isNonNegative);
        expect(m.decimalAmount, closeTo(decimalAmount.abs(), 1e-9));
        expect(m.mathPrecision, precision);
      },
    );

    test(
      'Given JSON con amount negativo '
      'When fromJson '
      'Then amount se normaliza a no-negativo',
      () {
        // Arrange
        final DateTime date = DateTime(2025, 1, 2, 10, 30);
        final DateTime created = DateTime(2025, 1, 3, 8);
        final Map<String, dynamic> json = <String, dynamic>{
          FinancialMovementEnum.id.name: 'neg-json',
          FinancialMovementEnum.amount.name: -1234,
          FinancialMovementEnum.date.name: DateUtils.dateTimeToString(date),
          FinancialMovementEnum.concept.name: 'Test',
          FinancialMovementEnum.detailedDescription.name: 'Desc',
          FinancialMovementEnum.category.name: 'Expense',
          FinancialMovementEnum.createdAt.name:
              DateUtils.dateTimeToString(created),
          FinancialMovementModel.mathPrecisionKey:
              FinancialMovementModel.defaultMathPrecision,
        };

        // Act
        final FinancialMovementModel m = FinancialMovementModel.fromJson(json);

        // Assert
        expect(m.amount, 1234);
        expect(
          m.decimalAmount,
          closeTo(
            1234 / FinancialMovementModel.getFactor(m.mathPrecision),
            1e-9,
          ),
        );
      },
    );

    test(
      'Given instancia válida '
      'When copyWith con amount negativo '
      'Then amount resultante es no-negativo',
      () {
        // Arrange
        final FinancialMovementModel base = FinancialMovementModel.fromDecimal(
          id: 'copy-neg',
          decimalAmount: 10.00,
          date: DateTime(2025),
          concept: 'Base',
          category: 'Income',
          createdAt: DateTime(2025),
          precision: 2,
        );

        // Act
        final FinancialMovementModel updated = base.copyWith(amount: -999);

        // Assert
        expect(updated.amount, 999);
        expect(updated.decimalAmount, closeTo(9.99, 1e-9));
      },
    );

    test(
      'Given instancia con amount positivo '
      'When toJson '
      'Then el amount serializado es no-negativo (sin alterar el valor)',
      () {
        // Arrange
        final FinancialMovementModel m = FinancialMovementModel.fromDecimal(
          id: 'tojson-pos',
          decimalAmount: -7.89,
          date: DateTime(2025),
          concept: 'Serialize',
          category: 'Income',
          createdAt: DateTime(2025),
          precision: 2,
        );

        // Act
        final Map<String, dynamic> json = m.toJson();

        // Assert
        expect(json[FinancialMovementEnum.amount.name], isNonNegative);
        expect(json[FinancialMovementEnum.amount.name], m.amount);
      },
    );
    test(
      'Given JSON completo con amount negativo '
      'When fromJson '
      'Then amount se normaliza a positivo y conserva el resto de campos',
      () {
        // Arrange
        final DateTime date = DateTime(2025, 1, 2, 10, 30);
        final DateTime createdAt = DateTime(2025, 1, 3, 8);
        const int precision = FinancialMovementModel.defaultMathPrecision;

        final Map<String, dynamic> json = <String, dynamic>{
          FinancialMovementEnum.id.name: 'neg-json-full',
          FinancialMovementEnum.amount.name: -1234,
          FinancialMovementEnum.date.name: DateUtils.dateTimeToString(date),
          FinancialMovementEnum.concept.name: 'Compra',
          FinancialMovementEnum.detailedDescription.name: 'Supermercado',
          FinancialMovementEnum.category.name: 'Expense',
          FinancialMovementEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          FinancialMovementModel.mathPrecisionKey: precision,
        };

        // Act
        final FinancialMovementModel m = FinancialMovementModel.fromJson(json);

        // Assert
        expect(m.id, 'neg-json-full');
        expect(m.amount, 1234, reason: 'Debe normalizar el signo a positivo');
        expect(m.date, date);
        expect(m.concept, 'Compra');
        expect(m.detailedDescription, 'Supermercado');
        expect(m.category, 'Expense');
        expect(m.createdAt, createdAt);
        expect(m.mathPrecision, precision);

        // Y el valor decimal debe coincidir con |amount| / 10^precision
        final double esperado =
            1234 / FinancialMovementModel.getFactor(precision);
        expect(m.decimalAmount, closeTo(esperado, 1e-9));
      },
    );
    test('fromJson: sin mathPrecision usa default', () {
      final Map<String, dynamic> json = <String, dynamic>{
        FinancialMovementEnum.id.name: 'id',
        FinancialMovementEnum.amount.name: 100,
        FinancialMovementEnum.date.name:
            DateUtils.dateTimeToString(DateTime(2025)),
        FinancialMovementEnum.concept.name: 'C',
        FinancialMovementEnum.detailedDescription.name: '',
        FinancialMovementEnum.category.name: 'Income',
        FinancialMovementEnum.createdAt.name:
            DateUtils.dateTimeToString(DateTime(2025)),
        // sin mathPrecisionKey
      };
      final FinancialMovementModel m = FinancialMovementModel.fromJson(json);
      expect(m.mathPrecision, FinancialMovementModel.defaultMathPrecision);
    });

    test('fromJson: con mathPrecision explícito respeta el valor (incluido 0)',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        FinancialMovementEnum.id.name: 'id',
        FinancialMovementEnum.amount.name: 100,
        FinancialMovementEnum.date.name:
            DateUtils.dateTimeToString(DateTime(2025)),
        FinancialMovementEnum.concept.name: 'C',
        FinancialMovementEnum.detailedDescription.name: '',
        FinancialMovementEnum.category.name: 'Income',
        FinancialMovementEnum.createdAt.name:
            DateUtils.dateTimeToString(DateTime(2025)),
        FinancialMovementModel.mathPrecisionKey: 0, // permitido
      };
      final FinancialMovementModel m = FinancialMovementModel.fromJson(json);
      expect(m.mathPrecision, 0);
    });
  });
}
