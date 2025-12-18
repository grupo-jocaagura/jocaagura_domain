import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelFlowStep.immutable()', () {
    test(
        'Given mutable inputs When building immutable Then instance is not affected by later mutations',
        () {
      // Arrange
      final List<String> constraints = <String>['requiresInternet'];
      final Map<String, double> cost = <String, double>{
        'latencyMs': 250,
        'networkKb': 12.5,
      };

      // Act
      final ModelFlowStep step = ModelFlowStep.immutable(
        index: 10,
        title: 'Authenticate',
        description: 'Runs auth use case',
        failureCode: 'AUTH_FAILED',
        nextOnSuccessIndex: 11,
        nextOnFailureIndex: 99,
        constraints: constraints,
        cost: cost,
      );

      // Mutate originals after construction
      constraints.add('role:admin');
      cost['latencyMs'] = 999;

      // Assert
      expect(step.constraints, equals(<String>['requiresInternet']));
      expect(step.cost['latencyMs'], equals(250));
    });

    test(
        'Given immutable instance When mutating constraints/cost Then throws UnsupportedError',
        () {
      // Arrange
      final ModelFlowStep step = ModelFlowStep.immutable(
        index: 1,
        title: 't',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: -1,
        nextOnFailureIndex: -1,
        constraints: const <String>['a'],
        cost: const <String, double>{'latencyMs': 10},
      );

      // Assert
      expect(() => step.constraints.add('b'), throwsUnsupportedError);
      expect(() => step.cost['networkKb'] = 1.0, throwsUnsupportedError);
    });

    test(
        'Given non-finite/negative costs When building immutable Then normalizes to 0.0',
        () {
      // Arrange
      final Map<String, double> cost = <String, double>{
        'nan': double.nan,
        'inf': double.infinity,
        'neg': -1,
        'ok': 2.5,
      };

      // Act
      final ModelFlowStep step = ModelFlowStep.immutable(
        index: 1,
        title: 't',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: 2,
        nextOnFailureIndex: 3,
        cost: cost,
      );

      // Assert
      expect(step.cost['nan'], equals(0.0));
      expect(step.cost['inf'], equals(0.0));
      expect(step.cost['neg'], equals(0.0));
      expect(step.cost['ok'], equals(2.5));
    });
  });

  group('ModelFlowStep.fromJson()', () {
    test(
        'Given empty json When parsing Then uses safe defaults and returns deeply immutable instance',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{};

      // Act
      final ModelFlowStep step = ModelFlowStep.fromJson(json);

      // Assert
      expect(step.failureCode, equals(defaultModelFlowStepModel.failureCode));
      expect(step.constraints, isEmpty);
      expect(step.cost, isEmpty);

      // Deep immutability expectations (requires fromJson to return ModelFlowStep.immutable)
      expect(() => step.constraints.add('x'), throwsUnsupportedError);
      expect(() => step.cost['k'] = 1.0, throwsUnsupportedError);
    });

    test(
        'Given cost with dynamic values When parsing Then normalizes invalid to 0.0',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        FlowStepEnum.cost.name: <String, dynamic>{
          'latencyMs': '250',
          'nan': double.nan,
          'neg': -2,
        },
      };

      // Act
      final ModelFlowStep step = ModelFlowStep.fromJson(json);

      // Assert
      expect(step.cost['latencyMs'], equals(250.0));
      expect(step.cost['nan'], equals(0.0));
      expect(step.cost['neg'], equals(0.0));
    });

    test(
        'Given instance When toJson/fromJson Then preserves equality (roundtrip)',
        () {
      // Arrange
      final ModelFlowStep original = ModelFlowStep.immutable(
        index: 10,
        title: 'Authenticate',
        description: 'Runs auth use case',
        failureCode: 'AUTH_FAILED',
        nextOnSuccessIndex: 11,
        nextOnFailureIndex: 99,
        constraints: const <String>['requiresInternet'],
        cost: const <String, double>{'latencyMs': 250, 'networkKb': 12.5},
      );

      // Act
      final Map<String, dynamic> json = original.toJson();
      final ModelFlowStep roundtrip = ModelFlowStep.fromJson(json);

      // Assert
      expect(roundtrip, equals(original));
    });
  });

  group('ModelFlowStep.copyWith()', () {
    test(
        'Given instance When copyWith called with no args Then returns same object (identical)',
        () {
      // Arrange
      final ModelFlowStep step = ModelFlowStep.immutable(
        index: 1,
        title: 't',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: 2,
        nextOnFailureIndex: 3,
      );

      // Act
      final ModelFlowStep copied = step.copyWith();

      // Assert
      expect(identical(copied, step), isTrue);
    });

    test(
        'Given instance When copyWith changes one field Then returns a new object with updated value',
        () {
      // Arrange
      final ModelFlowStep step = ModelFlowStep.immutable(
        index: 1,
        title: 't',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: 2,
        nextOnFailureIndex: 3,
      );

      // Act
      final ModelFlowStep updated = step.copyWith(title: 'new');

      // Assert
      expect(identical(updated, step), isFalse);
      expect(updated.title, equals('new'));
      expect(updated.index, equals(step.index));
    });
  });

  group('Equality & hashCode', () {
    test('Given two equal instances When comparing Then hashCode is equal', () {
      // Arrange
      final ModelFlowStep a = ModelFlowStep.immutable(
        index: 1,
        title: 't',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: 2,
        nextOnFailureIndex: 3,
        constraints: const <String>['c1', 'c2'],
        cost: const <String, double>{'latencyMs': 10, 'networkKb': 1.5},
      );

      final ModelFlowStep b = ModelFlowStep.immutable(
        index: 1,
        title: 't',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: 2,
        nextOnFailureIndex: 3,
        constraints: const <String>['c1', 'c2'],
        cost: const <String, double>{'latencyMs': 10, 'networkKb': 1.5},
      );

      // Act + Assert
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test(
        'Given same cost entries with different insertion order When comparing Then equals and same hashCode',
        () {
      // Arrange
      final ModelFlowStep a = ModelFlowStep.immutable(
        index: 1,
        title: 't',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: 2,
        nextOnFailureIndex: 3,
        cost: const <String, double>{'aMs': 1, 'bKb': 2},
      );

      final ModelFlowStep b = ModelFlowStep.immutable(
        index: 1,
        title: 't',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: 2,
        nextOnFailureIndex: 3,
        cost: const <String, double>{'bKb': 2, 'aMs': 1}, // different insertion order
      );

      // Assert
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test(
        'Given a single instance When reading hashCode multiple times Then it is stable',
        () {
      // Arrange
      final ModelFlowStep step = ModelFlowStep.immutable(
        index: 7,
        title: 't',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: 8,
        nextOnFailureIndex: 9,
        cost: const <String, double>{'latencyMs': 123},
      );

      // Act
      final int h1 = step.hashCode;
      final int h2 = step.hashCode;

      // Assert
      expect(h1, equals(h2));
    });
  });
}
