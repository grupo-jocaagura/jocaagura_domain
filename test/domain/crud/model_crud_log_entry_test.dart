import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelCrudLogEntry.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime performedAt = DateTime.utc(2025, 1, 1, 10);
        final Map<String, dynamic> json = <String, dynamic>{
          ModelCrudLogEntryEnum.id.name: 'log-1',
          ModelCrudLogEntryEnum.entityType.name: 'Group',
          ModelCrudLogEntryEnum.entityId.name: 'group-001',
          ModelCrudLogEntryEnum.operation.name:
              ModelCrudOperationKind.update.name,
          ModelCrudLogEntryEnum.performedBy.name: 'admin@domain.com',
          ModelCrudLogEntryEnum.performedAt.name:
              DateUtils.dateTimeToString(performedAt),
          ModelCrudLogEntryEnum.diff.name: <String, dynamic>{
            'field': 'value',
            'oldValue': 'old',
            'newValue': 'new',
          },
          ModelCrudLogEntryEnum.env.name: 'dev',
          ModelCrudLogEntryEnum.errorItemId.name: 'ERR-123',
        };

        // Act
        final ModelCrudLogEntry entry = ModelCrudLogEntry.fromJson(json);

        // Assert
        expect(entry.id, 'log-1');
        expect(entry.entityType, 'Group');
        expect(entry.entityId, 'group-001');
        expect(entry.operation, ModelCrudOperationKind.update);
        expect(entry.performedBy, 'admin@domain.com');
        expect(
          entry.performedAt.toUtc(),
          performedAt,
          reason: 'performedAt should be parsed consistently',
        );
        expect(entry.diff, isNotNull);
        expect(entry.diff!['field'], 'value');
        expect(entry.env, 'dev');
        expect(entry.errorItemId, 'ERR-123');
      },
    );

    test(
      'Given JSON with unknown operation When fromJson is called Then uses create as fallback',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelCrudLogEntryEnum.id.name: 'log-2',
          ModelCrudLogEntryEnum.entityType.name: 'User',
          ModelCrudLogEntryEnum.entityId.name: 'user-001',
          ModelCrudLogEntryEnum.operation.name: 'unknown_operation',
          ModelCrudLogEntryEnum.performedBy.name: 'system',
          ModelCrudLogEntryEnum.performedAt.name:
              DateUtils.dateTimeToString(DateTime.utc(2025, 1, 2)),
        };

        // Act
        final ModelCrudLogEntry entry = ModelCrudLogEntry.fromJson(json);

        // Assert
        expect(entry.operation, ModelCrudOperationKind.create);
      },
    );

    test(
      'Given minimal JSON without optional fields When fromJson is called Then creates entry with null optionals',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelCrudLogEntryEnum.id.name: 'log-3',
          ModelCrudLogEntryEnum.entityType.name: 'Group',
          ModelCrudLogEntryEnum.entityId.name: 'group-002',
          ModelCrudLogEntryEnum.operation.name:
              ModelCrudOperationKind.delete.name,
          ModelCrudLogEntryEnum.performedBy.name: 'user@domain.com',
          ModelCrudLogEntryEnum.performedAt.name:
              DateUtils.dateTimeToString(DateTime.utc(2025, 1, 3)),
        };

        // Act
        final ModelCrudLogEntry entry = ModelCrudLogEntry.fromJson(json);

        // Assert
        expect(entry.id, 'log-3');
        expect(entry.diff, isNull);
        expect(entry.env, isNull);
        expect(entry.errorItemId, isNull);
      },
    );
  });

  group('ModelCrudLogEntry.toJson & roundtrip', () {
    test(
      'Given a complete ModelCrudLogEntry When toJson and fromJson Then preserves all fields (roundtrip)',
      () {
        // Arrange
        final DateTime performedAt = DateTime.utc(2025, 1, 4, 12, 30);
        final Map<String, dynamic> diff = <String, dynamic>{
          'field': 'v',
          'count': 1,
        };

        final ModelCrudLogEntry original = ModelCrudLogEntry(
          id: 'log-10',
          entityType: 'Group',
          entityId: 'group-010',
          operation: ModelCrudOperationKind.update,
          performedBy: 'admin@domain.com',
          performedAt: performedAt,
          diff: diff,
          env: 'prod',
          errorItemId: 'ERR-999',
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelCrudLogEntry roundtrip = ModelCrudLogEntry.fromJson(json);

        // Assert
        expect(
          Utils.deepEqualsMap(
            original.toJson(),
            roundtrip.toJson(),
          ),
          isTrue,
        );
      },
    );

    test(
      'Given an entry without optional fields When toJson and fromJson Then keeps optionals as null (roundtrip)',
      () {
        // Arrange
        final ModelCrudLogEntry original = ModelCrudLogEntry(
          id: 'log-11',
          entityType: 'User',
          entityId: 'user-999',
          operation: ModelCrudOperationKind.create,
          performedBy: 'system',
          performedAt: DateTime.utc(2025, 1, 5, 9),
        );

        // Act
        final Map<String, dynamic> json = original.toJson();

        // Assert (JSON should not contain optional keys)
        expect(json.containsKey(ModelCrudLogEntryEnum.diff.name), isFalse);
        expect(json.containsKey(ModelCrudLogEntryEnum.env.name), isFalse);
        expect(
          json.containsKey(ModelCrudLogEntryEnum.errorItemId.name),
          isFalse,
        );

        final ModelCrudLogEntry roundtrip = ModelCrudLogEntry.fromJson(json);

        // And roundtrip keeps nulls
        expect(roundtrip.diff, isNull);
        expect(roundtrip.env, isNull);
        expect(roundtrip.errorItemId, isNull);
        expect(roundtrip, original);
      },
    );
  });

  group('ModelCrudLogEntry.copyWith', () {
    test(
      'Given an entry When copyWith overrides some fields Then returns a new instance with updated values',
      () {
        // Arrange
        final ModelCrudLogEntry original = ModelCrudLogEntry(
          id: 'log-20',
          entityType: 'Group',
          entityId: 'group-020',
          operation: ModelCrudOperationKind.create,
          performedBy: 'user@domain.com',
          performedAt: DateTime.utc(2025, 1, 6),
          diff: const <String, dynamic>{'field': 'old'},
          env: 'dev',
          errorItemId: 'ERR-001',
        );

        // Act
        final ModelCrudLogEntry copy = original.copyWith(
          operation: ModelCrudOperationKind.update,
          env: 'qa',
        );

        // Assert
        expect(copy.id, original.id);
        expect(copy.operation, ModelCrudOperationKind.update);
        expect(copy.env, 'qa');
        expect(copy.diff, same(original.diff));
        expect(copy, isNot(equals(original)));
      },
    );

    test(
      'Given an entry with diff When copyWith uses diffOverrideNull Then diff is cleared to null',
      () {
        // Arrange
        final ModelCrudLogEntry original = ModelCrudLogEntry(
          id: 'log-21',
          entityType: 'Group',
          entityId: 'group-021',
          operation: ModelCrudOperationKind.update,
          performedBy: 'user@domain.com',
          performedAt: DateTime.utc(2025, 1, 7),
          diff: const <String, dynamic>{'field': 'value'},
        );

        // Act
        final ModelCrudLogEntry cleared = original.copyWith(
          diffOverrideNull: () => true,
        );

        // Assert
        expect(original.diff, isNotNull);
        expect(cleared.diff, isNull);
      },
    );
  });
}
