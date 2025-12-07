import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelGroupSyncConfig.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime lastRun = DateTime.utc(2025, 1, 10, 12, 30);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSyncConfigEnum.id.name: 'sync-1',
          ModelGroupSyncConfigEnum.groupId.name: 'group-001',
          ModelGroupSyncConfigEnum.mode.name: 'fromSheet',
          ModelGroupSyncConfigEnum.courseId.name: 'course-123',
          ModelGroupSyncConfigEnum.sourceSheetId.name: 'sheet-001',
          ModelGroupSyncConfigEnum.sourceRange.name: 'A2:D999',
          ModelGroupSyncConfigEnum.schedule.name: 'daily',
          ModelGroupSyncConfigEnum.strategy.name: 'fullReplace',
          ModelGroupSyncConfigEnum.lastResult.name: 'ok',
          ModelGroupSyncConfigEnum.lastRunAt.name:
              DateUtils.dateTimeToString(lastRun),
          ModelGroupSyncConfigEnum.lastJobId.name: 'job-987',
          ModelGroupSyncConfigEnum.lastErrorItemId.name: 'ERR-999',
          ModelGroupSyncConfigEnum.crud.name: <String, dynamic>{
            'recordId': 'sync-1',
            'createdBy': 'system@domain.com',
            'createdAt': '2025-01-01T10:00:00Z',
            'updatedBy': 'system@domain.com',
            'updatedAt': '2025-01-01T10:00:00Z',
            'version': 1,
          },
        };

        // Act
        final ModelGroupSyncConfig config = ModelGroupSyncConfig.fromJson(json);

        // Assert
        expect(config.id, 'sync-1');
        expect(config.groupId, 'group-001');
        expect(config.mode, ModelGroupSyncMode.fromSheet);
        expect(config.courseId, 'course-123');
        expect(config.sourceSheetId, 'sheet-001');
        expect(config.sourceRange, 'A2:D999');
        expect(config.schedule, ModelGroupSyncSchedule.daily);
        expect(config.strategy, ModelGroupSyncStrategy.fullReplace);
        expect(config.lastResult, ModelGroupSyncLastResult.ok);
        expect(config.lastRunAt?.toUtc(), lastRun);
        expect(config.lastJobId, 'job-987');
        expect(config.lastErrorItemId, 'ERR-999');

        expect(config.crud.recordId, 'sync-1');
        expect(config.crud.version, 1);
      },
    );

    test(
      'Given JSON without optional strings When fromJson is called Then defaults to empty strings',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSyncConfigEnum.id.name: 'sync-2',
          ModelGroupSyncConfigEnum.groupId.name: 'group-002',
          // mode omitted -> default manual
          // courseId omitted
          // sourceSheetId omitted
          // sourceRange omitted
          // schedule omitted -> default onDemand
          // strategy omitted -> default fullReplace
          // lastResult omitted -> default never
          // lastRunAt omitted
          // lastJobId omitted
          // lastErrorItemId omitted
          ModelGroupSyncConfigEnum.crud.name: <String, dynamic>{
            'recordId': 'sync-2',
            'createdBy': 'system@domain.com',
            'createdAt': '2025-01-01T10:00:00Z',
            'updatedBy': 'system@domain.com',
            'updatedAt': '2025-01-01T10:00:00Z',
          },
        };

        // Act
        final ModelGroupSyncConfig config = ModelGroupSyncConfig.fromJson(json);

        // Assert
        expect(config.mode, ModelGroupSyncMode.manual);
        expect(config.schedule, ModelGroupSyncSchedule.onDemand);
        expect(config.strategy, ModelGroupSyncStrategy.fullReplace);
        expect(config.lastResult, ModelGroupSyncLastResult.never);

        expect(config.courseId, '');
        expect(config.sourceSheetId, '');
        expect(config.sourceRange, '');
        expect(config.lastRunAt, isNull);
        expect(config.lastJobId, '');
        expect(config.lastErrorItemId, '');
      },
    );

    test(
      'Given JSON with unknown enum values When fromJson is called Then uses fallback defaults',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSyncConfigEnum.id.name: 'sync-3',
          ModelGroupSyncConfigEnum.groupId.name: 'group-003',
          ModelGroupSyncConfigEnum.mode.name: 'unknown-mode',
          ModelGroupSyncConfigEnum.schedule.name: 'unknown-schedule',
          ModelGroupSyncConfigEnum.strategy.name: 'unknown-strategy',
          ModelGroupSyncConfigEnum.lastResult.name: 'unknown-result',
          ModelGroupSyncConfigEnum.crud.name: <String, dynamic>{
            'recordId': 'sync-3',
            'createdBy': 'system@domain.com',
            'createdAt': '2025-01-01T10:00:00Z',
            'updatedBy': 'system@domain.com',
            'updatedAt': '2025-01-01T10:00:00Z',
          },
        };

        // Act
        final ModelGroupSyncConfig config = ModelGroupSyncConfig.fromJson(json);

        // Assert
        expect(config.mode, ModelGroupSyncMode.manual);
        expect(config.schedule, ModelGroupSyncSchedule.onDemand);
        expect(config.strategy, ModelGroupSyncStrategy.fullReplace);
        expect(config.lastResult, ModelGroupSyncLastResult.never);
      },
    );
  });

  group('ModelGroupSyncConfig.toJson & roundtrip', () {
    test(
      'Given a full config instance When toJson and fromJson Then preserves all fields in the JSON roundtrip',
      () {
        // Arrange
        final DateTime lastRun = DateTime.utc(2025, 2, 1, 14);

        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'sync-10',
          createdBy: 'system@domain.com',
          createdAt: DateTime.utc(2025, 1, 1, 10),
          updatedBy: 'system@domain.com',
          updatedAt: DateTime.utc(2025, 1, 1, 10),
          version: 2,
        );

        final ModelGroupSyncConfig original = ModelGroupSyncConfig(
          id: 'sync-10',
          groupId: 'group-010',
          mode: ModelGroupSyncMode.fromSheet,
          courseId: 'course-010',
          sourceSheetId: 'sheet-010',
          sourceRange: 'A2:F999',
          schedule: ModelGroupSyncSchedule.weekly,
          strategy: ModelGroupSyncStrategy.merge,
          lastResult: ModelGroupSyncLastResult.partialError,
          lastRunAt: lastRun,
          lastJobId: 'job-010',
          lastErrorItemId: 'ERR-010',
          crud: crud,
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelGroupSyncConfig roundtrip =
            ModelGroupSyncConfig.fromJson(json);

        // Assert
        expect(roundtrip.toJson(), equals(original.toJson()));
      },
    );

    test(
      'Given config without lastRunAt When toJson is called Then lastRunAt key is omitted',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'sync-11',
          createdBy: 'system@domain.com',
          createdAt: DateTime.utc(2025, 1, 1, 10),
          updatedBy: 'system@domain.com',
          updatedAt: DateTime.utc(2025, 1, 1, 10),
        );

        final ModelGroupSyncConfig config = ModelGroupSyncConfig(
          id: 'sync-11',
          groupId: 'group-011',
          mode: ModelGroupSyncMode.manual,
          schedule: ModelGroupSyncSchedule.onDemand,
          strategy: ModelGroupSyncStrategy.fullReplace,
          lastResult: ModelGroupSyncLastResult.never,
          crud: crud,
        );

        // Act
        final Map<String, dynamic> json = config.toJson();

        // Assert
        expect(
          json.containsKey(ModelGroupSyncConfigEnum.lastRunAt.name),
          isFalse,
        );
      },
    );
  });

  group('ModelGroupSyncConfig.copyWith', () {
    test(
      'Given a config instance When copyWith overrides some fields Then returns a new instance with updated values',
      () {
        // Arrange
        final DateTime lastRun = DateTime.utc(2025, 3, 1, 10);
        final DateTime newLastRun = DateTime.utc(2025, 3, 2, 11);

        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'sync-20',
          createdBy: 'system@domain.com',
          createdAt: DateTime.utc(2025, 1, 1, 10),
          updatedBy: 'system@domain.com',
          updatedAt: DateTime.utc(2025, 1, 1, 10),
          version: 1,
        );

        final ModelGroupSyncConfig original = ModelGroupSyncConfig(
          id: 'sync-20',
          groupId: 'group-020',
          mode: ModelGroupSyncMode.manual,
          courseId: 'course-020',
          sourceSheetId: 'sheet-020',
          sourceRange: 'A2:F999',
          schedule: ModelGroupSyncSchedule.daily,
          strategy: ModelGroupSyncStrategy.fullReplace,
          lastResult: ModelGroupSyncLastResult.ok,
          lastRunAt: lastRun,
          lastJobId: 'job-020',
          lastErrorItemId: 'ERR-020',
          crud: crud,
        );

        // Act
        final ModelGroupSyncConfig copy = original.copyWith(
          mode: ModelGroupSyncMode.fromSheet,
          courseId: 'course-020B',
          sourceRange: 'B2:G999',
          schedule: ModelGroupSyncSchedule.hourly,
          lastResult: ModelGroupSyncLastResult.error,
          lastRunAt: newLastRun,
          lastJobId: 'job-020B',
          lastErrorItemId: 'ERR-020B',
        );

        // Assert
        expect(copy.id, original.id);
        expect(copy.groupId, original.groupId);
        expect(copy.mode, ModelGroupSyncMode.fromSheet);
        expect(copy.courseId, 'course-020B');
        expect(copy.sourceRange, 'B2:G999');
        expect(copy.schedule, ModelGroupSyncSchedule.hourly);
        expect(copy.lastResult, ModelGroupSyncLastResult.error);
        expect(copy.lastRunAt, newLastRun);
        expect(copy.lastJobId, 'job-020B');
        expect(copy.lastErrorItemId, 'ERR-020B');
      },
    );

    test(
      'Given a config instance When copyWith is called with no parameters Then returns an equal instance',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'sync-21',
          createdBy: 'system@domain.com',
          createdAt: DateTime.utc(2025, 1, 1, 10),
          updatedBy: 'system@domain.com',
          updatedAt: DateTime.utc(2025, 1, 1, 10),
          version: 3,
        );

        final ModelGroupSyncConfig original = ModelGroupSyncConfig(
          id: 'sync-21',
          groupId: 'group-021',
          mode: ModelGroupSyncMode.mixed,
          courseId: 'course-021',
          sourceSheetId: 'sheet-021',
          sourceRange: 'A2:D999',
          schedule: ModelGroupSyncSchedule.weekly,
          strategy: ModelGroupSyncStrategy.merge,
          lastResult: ModelGroupSyncLastResult.partialError,
          lastRunAt: DateTime.utc(2025, 3, 5, 12),
          lastJobId: 'job-021',
          lastErrorItemId: 'ERR-021',
          crud: crud,
        );

        // Act
        final ModelGroupSyncConfig copy = original.copyWith();

        // Assert
        expect(copy.toJson(), equals(original.toJson()));
        expect(copy.toString(), equals(original.toString()));
        expect(copy.hashCode, equals(original.hashCode));
      },
    );
  });
}
