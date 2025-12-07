import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelGroupSyncJob.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime started = DateTime.utc(2025, 1, 1, 10);
        final DateTime finished = DateTime.utc(2025, 1, 1, 10, 5);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSyncJobEnum.id.name: 'job-1',
          ModelGroupSyncJobEnum.groupId.name: 'group-001',
          ModelGroupSyncJobEnum.source.name: 'sheet',
          ModelGroupSyncJobEnum.type.name: 'full',
          ModelGroupSyncJobEnum.status.name: 'ok',
          ModelGroupSyncJobEnum.startedAt.name:
              DateUtils.dateTimeToString(started),
          ModelGroupSyncJobEnum.finishedAt.name:
              DateUtils.dateTimeToString(finished),
          ModelGroupSyncJobEnum.addedCount.name: 10,
          ModelGroupSyncJobEnum.removedCount.name: 2,
          ModelGroupSyncJobEnum.updatedCount.name: 3,
          ModelGroupSyncJobEnum.directoryApiCalls.name: 5,
          ModelGroupSyncJobEnum.groupSettingsApiCalls.name: 1,
          ModelGroupSyncJobEnum.errorItemId.name: 'ERR-123',
          ModelGroupSyncJobEnum.createdBy.name: 'system@domain.com',
        };

        // Act
        final ModelGroupSyncJob job = ModelGroupSyncJob.fromJson(json);

        // Assert
        expect(job.id, 'job-1');
        expect(job.groupId, 'group-001');
        expect(job.source, ModelGroupSyncJobSource.sheet);
        expect(job.type, ModelGroupSyncJobType.full);
        expect(job.status, ModelGroupSyncJobStatus.ok);
        expect(job.startedAt.toUtc(), started);
        expect(job.finishedAt?.toUtc(), finished);
        expect(job.addedCount, 10);
        expect(job.removedCount, 2);
        expect(job.updatedCount, 3);
        expect(job.directoryApiCalls, 5);
        expect(job.groupSettingsApiCalls, 1);
        expect(job.errorItemId, 'ERR-123');
        expect(job.createdBy, 'system@domain.com');
      },
    );

    test(
      'Given JSON without optional fields When fromJson is called Then uses defaults',
      () {
        // Arrange
        final DateTime started = DateTime.utc(2025, 1, 2, 9);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSyncJobEnum.id.name: 'job-2',
          ModelGroupSyncJobEnum.groupId.name: 'group-002',
          // source omitted -> default manual
          // type omitted   -> default full
          // status omitted -> default running
          ModelGroupSyncJobEnum.startedAt.name:
              DateUtils.dateTimeToString(started),
          // finishedAt omitted
          // counts omitted => default 0
          // api calls omitted => default 0
          // errorItemId omitted => ''
          // createdBy omitted => ''
        };

        // Act
        final ModelGroupSyncJob job = ModelGroupSyncJob.fromJson(json);

        // Assert
        expect(job.id, 'job-2');
        expect(job.groupId, 'group-002');
        expect(job.source, ModelGroupSyncJobSource.manual);
        expect(job.type, ModelGroupSyncJobType.full);
        expect(job.status, ModelGroupSyncJobStatus.running);
        expect(job.startedAt.toUtc(), started);
        expect(job.finishedAt, isNull);
        expect(job.addedCount, 0);
        expect(job.removedCount, 0);
        expect(job.updatedCount, 0);
        expect(job.directoryApiCalls, 0);
        expect(job.groupSettingsApiCalls, 0);
        expect(job.errorItemId, '');
        expect(job.createdBy, '');
      },
    );

    test(
      'Given JSON with unknown enum values When fromJson is called Then uses enum fallbacks',
      () {
        // Arrange
        final DateTime started = DateTime.utc(2025, 1, 3, 8);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSyncJobEnum.id.name: 'job-3',
          ModelGroupSyncJobEnum.groupId.name: 'group-003',
          ModelGroupSyncJobEnum.source.name: 'unknown-source',
          ModelGroupSyncJobEnum.type.name: 'unknown-type',
          ModelGroupSyncJobEnum.status.name: 'unknown-status',
          ModelGroupSyncJobEnum.startedAt.name:
              DateUtils.dateTimeToString(started),
        };

        // Act
        final ModelGroupSyncJob job = ModelGroupSyncJob.fromJson(json);

        // Assert
        expect(job.source, ModelGroupSyncJobSource.manual);
        expect(job.type, ModelGroupSyncJobType.full);
        expect(job.status, ModelGroupSyncJobStatus.running);
      },
    );
  });

  group('ModelGroupSyncJob.toJson & roundtrip', () {
    test(
      'Given a full job instance When toJson and fromJson Then preserves all fields in the JSON roundtrip',
      () {
        // Arrange
        final DateTime started = DateTime.utc(2025, 2, 1, 14);
        final DateTime finished = DateTime.utc(2025, 2, 1, 14, 10);

        final ModelGroupSyncJob original = ModelGroupSyncJob(
          id: 'job-10',
          groupId: 'group-010',
          source: ModelGroupSyncJobSource.course,
          type: ModelGroupSyncJobType.incremental,
          status: ModelGroupSyncJobStatus.ok,
          startedAt: started,
          finishedAt: finished,
          addedCount: 7,
          removedCount: 1,
          updatedCount: 4,
          directoryApiCalls: 3,
          groupSettingsApiCalls: 2,
          errorItemId: 'ERR-010',
          createdBy: 'admin@domain.com',
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelGroupSyncJob roundtrip = ModelGroupSyncJob.fromJson(json);

        // Assert
        expect(roundtrip.toJson(), equals(original.toJson()));
        expect(roundtrip.toString(), equals(original.toString()));
        expect(roundtrip.hashCode, equals(original.hashCode));
      },
    );

    test(
      'Given a job without finishedAt When toJson is called Then finishedAt key is omitted',
      () {
        // Arrange
        final DateTime started = DateTime.utc(2025, 2, 2, 9);

        final ModelGroupSyncJob job = ModelGroupSyncJob(
          id: 'job-11',
          groupId: 'group-011',
          source: ModelGroupSyncJobSource.manual,
          type: ModelGroupSyncJobType.full,
          status: ModelGroupSyncJobStatus.running,
          startedAt: started,
          addedCount: 0,
          removedCount: 0,
          updatedCount: 0,
          directoryApiCalls: 0,
          groupSettingsApiCalls: 0,
        );

        // Act
        final Map<String, dynamic> json = job.toJson();

        // Assert
        expect(
          json.containsKey(ModelGroupSyncJobEnum.finishedAt.name),
          isFalse,
        );
        // But errorItemId and createdBy are always present
        expect(json[ModelGroupSyncJobEnum.errorItemId.name], isA<String>());
        expect(json[ModelGroupSyncJobEnum.createdBy.name], isA<String>());
      },
    );
  });

  group('ModelGroupSyncJob.copyWith', () {
    test(
      'Given a job When copyWith overrides fields Then returns a new instance with updated values',
      () {
        // Arrange
        final DateTime started = DateTime.utc(2025, 3, 1, 10);
        final DateTime finished = DateTime.utc(2025, 3, 1, 10, 15);
        final DateTime newFinished = DateTime.utc(2025, 3, 1, 10, 20);

        final ModelGroupSyncJob original = ModelGroupSyncJob(
          id: 'job-20',
          groupId: 'group-020',
          source: ModelGroupSyncJobSource.sheet,
          type: ModelGroupSyncJobType.full,
          status: ModelGroupSyncJobStatus.running,
          startedAt: started,
          finishedAt: finished,
          addedCount: 5,
          removedCount: 1,
          updatedCount: 2,
          directoryApiCalls: 4,
          groupSettingsApiCalls: 1,
          errorItemId: 'ERR-020',
          createdBy: 'system@domain.com',
        );

        // Act
        final ModelGroupSyncJob copy = original.copyWith(
          status: ModelGroupSyncJobStatus.error,
          addedCount: 6,
          removedCount: 2,
          updatedCount: 3,
          directoryApiCalls: 10,
          groupSettingsApiCalls: 5,
          errorItemId: 'ERR-020B',
          createdBy: 'admin@domain.com',
          finishedAt: newFinished,
        );

        // Assert
        expect(copy.id, original.id);
        expect(copy.groupId, original.groupId);
        expect(copy.source, original.source);
        expect(copy.type, original.type);
        expect(copy.status, ModelGroupSyncJobStatus.error);
        expect(copy.finishedAt, newFinished);
        expect(copy.addedCount, 6);
        expect(copy.removedCount, 2);
        expect(copy.updatedCount, 3);
        expect(copy.directoryApiCalls, 10);
        expect(copy.groupSettingsApiCalls, 5);
        expect(copy.errorItemId, 'ERR-020B');
        expect(copy.createdBy, 'admin@domain.com');
      },
    );

    test(
      'Given a job When copyWith.finishedAtOverrideNull is used Then finishedAt becomes null',
      () {
        // Arrange
        final DateTime started = DateTime.utc(2025, 3, 2, 8);
        final DateTime finished = DateTime.utc(2025, 3, 2, 8, 10);

        final ModelGroupSyncJob original = ModelGroupSyncJob(
          id: 'job-21',
          groupId: 'group-021',
          source: ModelGroupSyncJobSource.manual,
          type: ModelGroupSyncJobType.incremental,
          status: ModelGroupSyncJobStatus.ok,
          startedAt: started,
          finishedAt: finished,
          addedCount: 1,
          removedCount: 0,
          updatedCount: 0,
          directoryApiCalls: 1,
          groupSettingsApiCalls: 0,
        );

        // Act
        final ModelGroupSyncJob copy = original.copyWith(
          finishedAtOverrideNull: () => true,
        );

        // Assert
        expect(original.finishedAt, isNotNull);
        expect(copy.finishedAt, isNull);
      },
    );

    test(
      'Given a job When copyWith is called without parameters Then returns an equal instance',
      () {
        // Arrange
        final ModelGroupSyncJob original = ModelGroupSyncJob(
          id: 'job-22',
          groupId: 'group-022',
          source: ModelGroupSyncJobSource.bulkImport,
          type: ModelGroupSyncJobType.full,
          status: ModelGroupSyncJobStatus.running,
          startedAt: DateTime.utc(2025, 3, 3, 9),
          addedCount: 20,
          removedCount: 5,
          updatedCount: 7,
          directoryApiCalls: 15,
          groupSettingsApiCalls: 3,
          errorItemId: 'ERR-022',
          createdBy: 'operator@domain.com',
        );

        // Act
        final ModelGroupSyncJob copy = original.copyWith();

        // Assert
        expect(copy.toJson(), equals(original.toJson()));
      },
    );
  });
}
