import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelCompleteFlow.immutable()', () {
    test(
        'Given steps with negative index When building immutable Then ignores negative-index steps',
        () {
      // Arrange
      final ModelFlowStep valid = ModelFlowStep.immutable(
        index: 10,
        title: 'A',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: -1,
        nextOnFailureIndex: -1,
      );

      final ModelFlowStep invalidEnd = ModelFlowStep.immutable(
        index: -1,
        title: 'END?',
        description: 'should not be stored',
        failureCode: 'END',
        nextOnSuccessIndex: -1,
        nextOnFailureIndex: -1,
      );

      // Act
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[invalidEnd, valid],
      );

      // Assert
      expect(flow.stepsByIndex.length, equals(1));
      expect(flow.stepsByIndex.containsKey(10), isTrue);
      expect(flow.stepsByIndex.containsKey(-1), isFalse);
    });

    test('Given duplicate indices When building immutable Then last write wins',
        () {
      // Arrange
      final ModelFlowStep first = ModelFlowStep.immutable(
        index: 10,
        title: 'First',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: -1,
        nextOnFailureIndex: -1,
      );

      final ModelFlowStep second = ModelFlowStep.immutable(
        index: 10,
        title: 'Second',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: -1,
        nextOnFailureIndex: -1,
      );

      // Act
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[first, second],
      );

      // Assert
      expect(flow.stepsByIndex[10]?.title, equals('Second'));
    });

    test(
        'Given immutable flow When mutating stepsByIndex Then throws UnsupportedError',
        () {
      // Arrange
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[
          ModelFlowStep.immutable(
            index: 1,
            title: 'A',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
        ],
      );

      // Assert
      expect(
        () => flow.stepsByIndex[2] = flow.stepsByIndex[1]!,
        throwsUnsupportedError,
      );
      expect(() => flow.stepsByIndex.remove(1), throwsUnsupportedError);
    });
  });

  group('ModelCompleteFlow.immutableFromMap()', () {
    test(
        'Given map containing negative key When building immutableFromMap Then ignores negative keys',
        () {
      // Arrange
      final Map<int, ModelFlowStep> map = <int, ModelFlowStep>{
        -1: ModelFlowStep.immutable(
          index: -1,
          title: 'END?',
          description: 'no',
          failureCode: 'END',
          nextOnSuccessIndex: -1,
          nextOnFailureIndex: -1,
        ),
        2: ModelFlowStep.immutable(
          index: 2,
          title: 'Ok',
          description: 'd',
          failureCode: 'X',
          nextOnSuccessIndex: -1,
          nextOnFailureIndex: -1,
        ),
      };

      // Act
      final ModelCompleteFlow flow = ModelCompleteFlow.immutableFromMap(
        name: 'Flow',
        description: 'Desc',
        stepsByIndex: map,
      );

      // Assert
      expect(flow.stepsByIndex.containsKey(-1), isFalse);
      expect(flow.stepsByIndex.containsKey(2), isTrue);
    });
  });

  group('ModelCompleteFlow.fromJson() / toJson()', () {
    test(
        'Given JSON with stepsByIndex map When parsing Then builds flow and keeps immutability',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        CompleteFlowEnum.name.name: 'AuthFlow',
        CompleteFlowEnum.description.name: 'Desc',
        CompleteFlowEnum.stepsByIndex.name: <String, dynamic>{
          '10': <String, dynamic>{
            FlowStepEnum.indexNumber.name: 10,
            FlowStepEnum.title.name: 'Authenticate',
            FlowStepEnum.description.name: 'd',
            FlowStepEnum.failureCode.name: 'AUTH_FAILED',
            FlowStepEnum.nextOnSuccessIndex.name: -1,
            FlowStepEnum.nextOnFailureIndex.name: -1,
          },
          '-1': <String, dynamic>{
            // should be ignored by ModelCompleteFlow due to key < 0
            FlowStepEnum.indexNumber.name: -1,
            FlowStepEnum.title.name: 'END',
            FlowStepEnum.description.name: 'd',
            FlowStepEnum.failureCode.name: 'END',
            FlowStepEnum.nextOnSuccessIndex.name: -1,
            FlowStepEnum.nextOnFailureIndex.name: -1,
          },
        },
      };

      // Act
      final ModelCompleteFlow flow = ModelCompleteFlow.fromJson(json);

      // Assert
      expect(flow.name, equals('AuthFlow'));
      expect(flow.stepsByIndex.containsKey(10), isTrue);
      expect(flow.stepsByIndex.containsKey(-1), isFalse);

      // Deep immutability (map itself)
      expect(
        () => flow.stepsByIndex[99] = flow.stepsByIndex[10]!,
        throwsUnsupportedError,
      );
    });

    test(
        'Given a flow When toJson and fromJson Then preserves equality (roundtrip)',
        () {
      // Arrange
      final ModelCompleteFlow original = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[
          ModelFlowStep.immutable(
            index: 20,
            title: 'B',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
            cost: const <String, double>{'latencyMs': 10},
          ),
          ModelFlowStep.immutable(
            index: 10,
            title: 'A',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: 20,
            nextOnFailureIndex: -1,
          ),
        ],
      );

      // Act
      final Map<String, dynamic> json = original.toJson();
      final ModelCompleteFlow roundtrip = ModelCompleteFlow.fromJson(json);

      // Assert
      expect(roundtrip, equals(original));
      expect(roundtrip.hashCode, equals(original.hashCode));
    });

    test(
        'Given JSON with non-map stepsByIndex When parsing Then uses safe defaults',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        CompleteFlowEnum.name.name: 'Flow',
        CompleteFlowEnum.description.name: 'Desc',
        CompleteFlowEnum.stepsByIndex.name: 'not a map',
      };

      // Act
      final ModelCompleteFlow flow = ModelCompleteFlow.fromJson(json);

      // Assert
      expect(flow.name, equals('Flow'));
      expect(flow.stepsByIndex, isEmpty);
      expect(flow.entryIndex, equals(-1));
    });
  });

  group('Views: stepsSorted / entryIndex / stepAt', () {
    test(
        'Given unsorted steps When reading stepsSorted Then returns them ordered by index',
        () {
      // Arrange
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[
          ModelFlowStep.immutable(
            index: 20,
            title: 'B',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
          ModelFlowStep.immutable(
            index: 10,
            title: 'A',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
        ],
      );

      // Act
      final List<ModelFlowStep> sorted = flow.stepsSorted;

      // Assert
      expect(
        sorted.map((ModelFlowStep s) => s.index).toList(),
        equals(<int>[10, 20]),
      );
      expect(() => sorted.add(sorted.first), throwsUnsupportedError);
    });

    test(
        'Given non-empty flow When reading entryIndex Then returns smallest index',
        () {
      // Arrange
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[
          ModelFlowStep.immutable(
            index: 5,
            title: 'A',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
          ModelFlowStep.immutable(
            index: 2,
            title: 'B',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
        ],
      );

      // Assert
      expect(flow.entryIndex, equals(2));
      expect(flow.stepAt(5)?.title, equals('A'));
      expect(flow.stepAt(999), isNull);
    });
  });

  group('Mutations: upsertStep / removeStepAt', () {
    test(
        'Given step with negative index When upserting Then returns same object',
        () {
      // Arrange
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
      );

      final ModelFlowStep end = ModelFlowStep.immutable(
        index: -1,
        title: 'END',
        description: 'd',
        failureCode: 'END',
        nextOnSuccessIndex: -1,
        nextOnFailureIndex: -1,
      );

      // Act
      final ModelCompleteFlow result = flow.upsertStep(end);

      // Assert
      expect(identical(result, flow), isTrue);
      expect(result.stepsByIndex, isEmpty);
    });

    test(
        'Given empty flow When upserting valid step Then adds it and returns new object',
        () {
      // Arrange
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
      );

      final ModelFlowStep step = ModelFlowStep.immutable(
        index: 10,
        title: 'A',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: -1,
        nextOnFailureIndex: -1,
      );

      // Act
      final ModelCompleteFlow result = flow.upsertStep(step);

      // Assert
      expect(identical(result, flow), isFalse);
      expect(result.stepsByIndex.containsKey(10), isTrue);
      expect(result.stepsByIndex[10]?.title, equals('A'));
    });

    test(
        'Given flow with same step When upserting equal step Then returns same object',
        () {
      // Arrange
      final ModelFlowStep step = ModelFlowStep.immutable(
        index: 10,
        title: 'A',
        description: 'd',
        failureCode: 'X',
        nextOnSuccessIndex: -1,
        nextOnFailureIndex: -1,
      );

      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[step],
      );

      // Act
      final ModelCompleteFlow result = flow.upsertStep(step);

      // Assert
      expect(identical(result, flow), isTrue);
    });

    test(
        'Given flow missing index When removeStepAt called Then returns same object',
        () {
      // Arrange
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[
          ModelFlowStep.immutable(
            index: 1,
            title: 'A',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
        ],
      );

      // Act
      final ModelCompleteFlow result = flow.removeStepAt(999);

      // Assert
      expect(identical(result, flow), isTrue);
    });

    test(
        'Given flow with index When removeStepAt called Then removes and returns new object',
        () {
      // Arrange
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[
          ModelFlowStep.immutable(
            index: 1,
            title: 'A',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
        ],
      );

      // Act
      final ModelCompleteFlow result = flow.removeStepAt(1);

      // Assert
      expect(identical(result, flow), isFalse);
      expect(result.stepsByIndex.containsKey(1), isFalse);
    });
  });

  group('ModelCompleteFlow.copyWith()', () {
    test(
        'Given flow When copyWith called with no args Then returns same object (identical)',
        () {
      // Arrange
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
      );

      // Act
      final ModelCompleteFlow copied = flow.copyWith();

      // Assert
      expect(identical(copied, flow), isTrue);
    });

    test(
        'Given flow When copyWith changes name Then returns new deeply immutable flow',
        () {
      // Arrange
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[
          ModelFlowStep.immutable(
            index: 1,
            title: 'A',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
        ],
      );

      // Act
      final ModelCompleteFlow updated = flow.copyWith(name: 'NewName');

      // Assert
      expect(identical(updated, flow), isFalse);
      expect(updated.name, equals('NewName'));
      expect(updated.stepsByIndex.containsKey(1), isTrue);

      // still unmodifiable
      expect(() => updated.stepsByIndex.remove(1), throwsUnsupportedError);
    });
  });

  group('HashCode contract', () {
    test('Given two equal flows When comparing Then hashCode is equal', () {
      // Arrange
      final ModelCompleteFlow a = ModelCompleteFlow.immutable(
        name: 'Flow',
        description: 'Desc',
        steps: <ModelFlowStep>[
          ModelFlowStep.immutable(
            index: 2,
            title: 'B',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
          ModelFlowStep.immutable(
            index: 1,
            title: 'A',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: 2,
            nextOnFailureIndex: -1,
          ),
        ],
      );

      final ModelCompleteFlow b = ModelCompleteFlow.immutableFromMap(
        name: 'Flow',
        description: 'Desc',
        stepsByIndex: <int, ModelFlowStep>{
          1: ModelFlowStep.immutable(
            index: 1,
            title: 'A',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: 2,
            nextOnFailureIndex: -1,
          ),
          2: ModelFlowStep.immutable(
            index: 2,
            title: 'B',
            description: 'd',
            failureCode: 'X',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
        },
      );

      // Assert
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
