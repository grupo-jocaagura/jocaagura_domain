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
        'concept: "Salary", category: "Income", createdAt: $createdAt)',
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
}
