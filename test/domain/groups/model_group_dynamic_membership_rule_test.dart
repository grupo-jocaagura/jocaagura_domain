import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelGroupDynamicMembershipRule.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime evaluated = DateTime.utc(2025, 1, 10, 12, 30);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupDynamicMembershipRuleEnum.id.name: 'rule-1',
          ModelGroupDynamicMembershipRuleEnum.groupId.name: 'group-001',
          ModelGroupDynamicMembershipRuleEnum.expression.name:
              'user.department == "Engineering"',
          ModelGroupDynamicMembershipRuleEnum.status.name:
              ModelGroupDynamicMembershipRuleStatus.active.name,
          ModelGroupDynamicMembershipRuleEnum.lastEvaluatedAt.name:
              DateUtils.dateTimeToString(evaluated),
          ModelGroupDynamicMembershipRuleEnum.estimatedMembers.name: 42,
        };

        // Act
        final ModelGroupDynamicMembershipRule rule =
            ModelGroupDynamicMembershipRule.fromJson(json);

        // Assert
        expect(rule.id, 'rule-1');
        expect(rule.groupId, 'group-001');
        expect(
          rule.expression,
          'user.department == "Engineering"',
        );
        expect(
          rule.status,
          ModelGroupDynamicMembershipRuleStatus.active,
        );
        expect(rule.lastEvaluatedAt, isNotNull);
        expect(rule.lastEvaluatedAt!.toUtc(), evaluated);
        expect(rule.estimatedMembers, 42);
      },
    );

    test(
      'Given JSON without optional fields When fromJson is called Then lastEvaluatedAt=null and estimatedMembers defaults to 0',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupDynamicMembershipRuleEnum.id.name: 'rule-2',
          ModelGroupDynamicMembershipRuleEnum.groupId.name: 'group-002',
          ModelGroupDynamicMembershipRuleEnum.expression.name:
              'user.orgUnit == "/Students"',
          ModelGroupDynamicMembershipRuleEnum.status.name:
              ModelGroupDynamicMembershipRuleStatus.draft.name,
          // lastEvaluatedAt and estimatedMembers omitted on purpose
        };

        // Act
        final ModelGroupDynamicMembershipRule rule =
            ModelGroupDynamicMembershipRule.fromJson(json);

        // Assert
        expect(rule.lastEvaluatedAt, isNull);
        // getIntegerFromDynamic(null) → 0
        expect(rule.estimatedMembers, 0);
      },
    );

    test(
      'Given JSON with unknown status When fromJson is called Then status falls back to draft',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupDynamicMembershipRuleEnum.id.name: 'rule-3',
          ModelGroupDynamicMembershipRuleEnum.groupId.name: 'group-003',
          ModelGroupDynamicMembershipRuleEnum.expression.name:
              'user.isSuspended == false',
          ModelGroupDynamicMembershipRuleEnum.status.name: 'UNKNOWN_STATUS',
        };

        // Act
        final ModelGroupDynamicMembershipRule rule =
            ModelGroupDynamicMembershipRule.fromJson(json);

        // Assert
        expect(
          rule.status,
          ModelGroupDynamicMembershipRuleStatus.draft,
        );
      },
    );

    test(
      'Given JSON with non-integer estimatedMembers When fromJson is called Then estimatedMembers is parsed via getIntegerFromDynamic',
      () {
        // Arrange
        final Map<String, dynamic> jsonDouble = <String, dynamic>{
          ModelGroupDynamicMembershipRuleEnum.id.name: 'rule-4',
          ModelGroupDynamicMembershipRuleEnum.groupId.name: 'group-004',
          ModelGroupDynamicMembershipRuleEnum.expression.name:
              'user.department == "HR"',
          ModelGroupDynamicMembershipRuleEnum.status.name:
              ModelGroupDynamicMembershipRuleStatus.active.name,
          ModelGroupDynamicMembershipRuleEnum.estimatedMembers.name: 15.9,
        };

        final Map<String, dynamic> jsonString = <String, dynamic>{
          ModelGroupDynamicMembershipRuleEnum.id.name: 'rule-5',
          ModelGroupDynamicMembershipRuleEnum.groupId.name: 'group-005',
          ModelGroupDynamicMembershipRuleEnum.expression.name:
              'user.department == "Sales"',
          ModelGroupDynamicMembershipRuleEnum.status.name:
              ModelGroupDynamicMembershipRuleStatus.active.name,
          ModelGroupDynamicMembershipRuleEnum.estimatedMembers.name: '27',
        };

        // Act
        final ModelGroupDynamicMembershipRule ruleFromDouble =
            ModelGroupDynamicMembershipRule.fromJson(jsonDouble);
        final ModelGroupDynamicMembershipRule ruleFromString =
            ModelGroupDynamicMembershipRule.fromJson(jsonString);

        // Assert
        expect(ruleFromDouble.estimatedMembers, 15); // truncated
        expect(ruleFromString.estimatedMembers, 27);
      },
    );

    test(
      'Given JSON with null scalars When fromJson is called Then strings fall back to empty',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupDynamicMembershipRuleEnum.id.name: null,
          ModelGroupDynamicMembershipRuleEnum.groupId.name: null,
          ModelGroupDynamicMembershipRuleEnum.expression.name: null,
          ModelGroupDynamicMembershipRuleEnum.status.name:
              ModelGroupDynamicMembershipRuleStatus.draft.name,
        };

        // Act
        final ModelGroupDynamicMembershipRule rule =
            ModelGroupDynamicMembershipRule.fromJson(json);

        // Assert
        expect(rule.id, '');
        expect(rule.groupId, '');
        expect(rule.expression, '');
      },
    );
  });

  group('ModelGroupDynamicMembershipRule.toJson & roundtrip', () {
    test(
      'Given a full rule When toJson and fromJson Then preserves all fields (roundtrip)',
      () {
        // Arrange
        final DateTime evaluated = DateTime.utc(2025, 2, 1, 9, 45);

        final ModelGroupDynamicMembershipRule original =
            ModelGroupDynamicMembershipRule(
          id: 'rule-10',
          groupId: 'group-010',
          expression: 'user.isEnrolled == true',
          status: ModelGroupDynamicMembershipRuleStatus.active,
          lastEvaluatedAt: evaluated,
          estimatedMembers: 120,
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelGroupDynamicMembershipRule roundtrip =
            ModelGroupDynamicMembershipRule.fromJson(json);

        // Assert
        expect(roundtrip.toJson(), original.toJson());
        expect(roundtrip, original);
      },
    );

    test(
      'Given a rule without lastEvaluatedAt When toJson and fromJson Then estimatedMembers is preserved and lastEvaluatedAt stays null',
      () {
        // Arrange
        const ModelGroupDynamicMembershipRule original =
            ModelGroupDynamicMembershipRule(
          id: 'rule-11',
          groupId: 'group-011',
          expression: 'user.status == "ACTIVE"',
          status: ModelGroupDynamicMembershipRuleStatus.draft,
          estimatedMembers: 5,
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelGroupDynamicMembershipRule roundtrip =
            ModelGroupDynamicMembershipRule.fromJson(json);

        // Assert
        expect(roundtrip.lastEvaluatedAt, isNull);
        expect(roundtrip.estimatedMembers, 5);
        expect(roundtrip, original);
      },
    );
  });

  group('ModelGroupDynamicMembershipRule.copyWith', () {
    test(
      'Given a rule When copyWith overrides some fields Then returns a new instance with updated values',
      () {
        // Arrange
        final DateTime originalEval = DateTime.utc(2025, 3, 1, 8);
        final DateTime newEval = DateTime.utc(2025, 3, 2, 8);

        final ModelGroupDynamicMembershipRule original =
            ModelGroupDynamicMembershipRule(
          id: 'rule-20',
          groupId: 'group-020',
          expression: 'user.department == "Math"',
          status: ModelGroupDynamicMembershipRuleStatus.draft,
          lastEvaluatedAt: originalEval,
          estimatedMembers: 10,
        );

        // Act
        final ModelGroupDynamicMembershipRule copy = original.copyWith(
          expression: 'user.department == "Science"',
          status: ModelGroupDynamicMembershipRuleStatus.active,
          lastEvaluatedAt: newEval,
          estimatedMembers: 25,
        );

        // Assert
        expect(copy.id, original.id);
        expect(copy.groupId, original.groupId);
        expect(
          copy.expression,
          'user.department == "Science"',
        );
        expect(
          copy.status,
          ModelGroupDynamicMembershipRuleStatus.active,
        );
        expect(copy.lastEvaluatedAt, newEval);
        expect(copy.estimatedMembers, 25);
        expect(copy, isNot(equals(original)));
        expect(copy.hashCode, isNot(equals(original.hashCode)));
        expect(copy.toString(), isNot(equals(original.toString())));
      },
    );

    test(
      'Given a rule When copyWith uses lastEvaluatedAtOverrideNull Then lastEvaluatedAt becomes null',
      () {
        // Arrange
        final ModelGroupDynamicMembershipRule original =
            ModelGroupDynamicMembershipRule(
          id: 'rule-21',
          groupId: 'group-021',
          expression: 'user.orgUnit == "/Staff"',
          status: ModelGroupDynamicMembershipRuleStatus.active,
          lastEvaluatedAt: DateTime.utc(2025, 3, 3, 8),
          estimatedMembers: 50,
        );

        // Act
        final ModelGroupDynamicMembershipRule copy = original.copyWith(
          lastEvaluatedAtOverrideNull: () => true,
        );

        // Assert
        expect(copy.lastEvaluatedAt, isNull);
        expect(copy.estimatedMembers, original.estimatedMembers);
        expect(copy.id, original.id);
        expect(copy.groupId, original.groupId);
      },
    );

    test(
      'Given a rule When copyWith is called with no parameters Then returns an equal instance',
      () {
        // Arrange
        const ModelGroupDynamicMembershipRule original =
            ModelGroupDynamicMembershipRule(
          id: 'rule-22',
          groupId: 'group-022',
          expression: 'user.isStudent == true',
          status: ModelGroupDynamicMembershipRuleStatus.draft,
          estimatedMembers: 7,
        );

        // Act
        final ModelGroupDynamicMembershipRule copy = original.copyWith();

        // Assert
        expect(copy, original);
        expect(copy.toJson(), original.toJson());
      },
    );
  });
}
