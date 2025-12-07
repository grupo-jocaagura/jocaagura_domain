import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelGroupConfig.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 1, 1, 10);
        final DateTime updatedAt = DateTime.utc(2025, 1, 1, 11);
        final DateTime lastSyncAt = DateTime.utc(2025, 1, 1, 12, 30);

        final Map<String, dynamic> crudJson = <String, dynamic>{
          ModelCrudMetadataEnum.recordId.name: 'cfg-1',
          ModelCrudMetadataEnum.createdBy.name: 'system@domain.com',
          ModelCrudMetadataEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          ModelCrudMetadataEnum.updatedBy.name: 'admin@domain.com',
          ModelCrudMetadataEnum.updatedAt.name:
              DateUtils.dateTimeToString(updatedAt),
          ModelCrudMetadataEnum.version.name: 1,
        };

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupConfigEnum.id.name: 'cfg-1',
          ModelGroupConfigEnum.groupId.name: 'group-001',
          ModelGroupConfigEnum.googleGroupId.name: 'AAA-123',
          ModelGroupConfigEnum.email.name: 'soporte@domain.com',
          ModelGroupConfigEnum.resourceName.name: 'groups/AAA-123',
          ModelGroupConfigEnum.apiSource.name:
              ModelGroupConfigApiSource.cloudIdentity.name,
          ModelGroupConfigEnum.etagSettings.name: 'etag-xyz',
          ModelGroupConfigEnum.lastSyncStatus.name:
              ModelGroupConfigLastSyncStatus.ok.name,
          ModelGroupConfigEnum.lastSyncAt.name:
              DateUtils.dateTimeToString(lastSyncAt),
          ModelGroupConfigEnum.crud.name: crudJson,
        };

        // Act
        final ModelGroupConfig config = ModelGroupConfig.fromJson(json);

        // Assert
        expect(config.id, 'cfg-1');
        expect(config.groupId, 'group-001');
        expect(config.googleGroupId, 'AAA-123');
        expect(config.email, 'soporte@domain.com');
        expect(config.resourceName, 'groups/AAA-123');
        expect(config.apiSource, ModelGroupConfigApiSource.cloudIdentity);
        expect(config.etagSettings, 'etag-xyz');
        expect(config.lastSyncStatus, ModelGroupConfigLastSyncStatus.ok);
        expect(config.lastSyncAt?.toUtc(), lastSyncAt);

        expect(config.crud.recordId, 'cfg-1');
        expect(config.crud.createdBy, 'system@domain.com');
        expect(config.crud.createdAt.toUtc(), createdAt);
        expect(config.crud.updatedBy, 'admin@domain.com');
        expect(config.crud.updatedAt.toUtc(), updatedAt);
        expect(config.crud.version, 1);
      },
    );

    test(
      'Given JSON without resourceName, etagSettings and lastSyncAt '
      'When fromJson is called Then they use defaults',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupConfigEnum.id.name: 'cfg-2',
          ModelGroupConfigEnum.groupId.name: 'group-002',
          ModelGroupConfigEnum.googleGroupId.name: 'BBB-222',
          ModelGroupConfigEnum.email.name: 'info@domain.com',
          ModelGroupConfigEnum.apiSource.name:
              ModelGroupConfigApiSource.directory.name,
          ModelGroupConfigEnum.lastSyncStatus.name:
              ModelGroupConfigLastSyncStatus.never.name,
          ModelGroupConfigEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'cfg-2',
            ModelCrudMetadataEnum.createdBy.name: 'system',
            ModelCrudMetadataEnum.createdAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 2, 8),
            ),
            ModelCrudMetadataEnum.updatedBy.name: 'system',
            ModelCrudMetadataEnum.updatedAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 2, 8),
            ),
          },
        };

        // Act
        final ModelGroupConfig config = ModelGroupConfig.fromJson(json);

        // Assert
        expect(config.resourceName, '');
        expect(config.etagSettings, '');
        expect(config.lastSyncAt, isNull);
      },
    );

    test(
      'Given JSON with null resourceName and etagSettings '
      'When fromJson is called Then they are normalized to empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupConfigEnum.id.name: 'cfg-3',
          ModelGroupConfigEnum.groupId.name: 'group-003',
          ModelGroupConfigEnum.googleGroupId.name: 'CCC-333',
          ModelGroupConfigEnum.email.name: 'ventas@domain.com',
          ModelGroupConfigEnum.resourceName.name: null,
          ModelGroupConfigEnum.etagSettings.name: null,
          ModelGroupConfigEnum.apiSource.name:
              ModelGroupConfigApiSource.directory.name,
          ModelGroupConfigEnum.lastSyncStatus.name:
              ModelGroupConfigLastSyncStatus.never.name,
          ModelGroupConfigEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'cfg-3',
            ModelCrudMetadataEnum.createdBy.name: 'system',
            ModelCrudMetadataEnum.createdAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 3, 8),
            ),
            ModelCrudMetadataEnum.updatedBy.name: 'system',
            ModelCrudMetadataEnum.updatedAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 3, 8),
            ),
          },
        };

        // Act
        final ModelGroupConfig config = ModelGroupConfig.fromJson(json);

        // Assert
        expect(config.resourceName, '');
        expect(config.etagSettings, '');
      },
    );

    test(
      'Given JSON with unknown enum values '
      'When fromJson is called Then defaults are used for apiSource and lastSyncStatus',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupConfigEnum.id.name: 'cfg-4',
          ModelGroupConfigEnum.groupId.name: 'group-004',
          ModelGroupConfigEnum.googleGroupId.name: 'DDD-444',
          ModelGroupConfigEnum.email.name: 'unknown@domain.com',
          ModelGroupConfigEnum.apiSource.name: 'unknown_source',
          ModelGroupConfigEnum.lastSyncStatus.name: 'unknown_status',
          ModelGroupConfigEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'cfg-4',
            ModelCrudMetadataEnum.createdBy.name: 'system',
            ModelCrudMetadataEnum.createdAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 4, 8),
            ),
            ModelCrudMetadataEnum.updatedBy.name: 'system',
            ModelCrudMetadataEnum.updatedAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 4, 8),
            ),
          },
        };

        // Act
        final ModelGroupConfig config = ModelGroupConfig.fromJson(json);

        // Assert
        expect(
          config.apiSource,
          ModelGroupConfigApiSource.directory,
        );
        expect(
          config.lastSyncStatus,
          ModelGroupConfigLastSyncStatus.never,
        );
      },
    );

    test(
      'Given JSON with null scalars When fromJson is called Then they fallback to empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupConfigEnum.id.name: null,
          ModelGroupConfigEnum.groupId.name: null,
          ModelGroupConfigEnum.googleGroupId.name: null,
          ModelGroupConfigEnum.email.name: null,
          ModelGroupConfigEnum.apiSource.name:
              ModelGroupConfigApiSource.directory.name,
          ModelGroupConfigEnum.lastSyncStatus.name:
              ModelGroupConfigLastSyncStatus.never.name,
          ModelGroupConfigEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'cfg-5',
            ModelCrudMetadataEnum.createdBy.name: 'system',
            ModelCrudMetadataEnum.createdAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 5, 8),
            ),
            ModelCrudMetadataEnum.updatedBy.name: 'system',
            ModelCrudMetadataEnum.updatedAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 5, 8),
            ),
          },
        };

        // Act
        final ModelGroupConfig config = ModelGroupConfig.fromJson(json);

        // Assert
        expect(config.id, '');
        expect(config.groupId, '');
        expect(config.googleGroupId, '');
        expect(config.email, '');
      },
    );
  });

  group('ModelGroupConfig.toJson & roundtrip', () {
    test(
      'Given a full ModelGroupConfig When toJson and fromJson Then preserves all fields (roundtrip)',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 2, 1, 9);
        final DateTime updatedAt = DateTime.utc(2025, 2, 1, 10);
        final DateTime lastSyncAt = DateTime.utc(2025, 2, 1, 11, 30);

        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'cfg-10',
          createdBy: 'system@domain.com',
          createdAt: createdAt,
          updatedBy: 'admin@domain.com',
          updatedAt: updatedAt,
          version: 2,
        );

        final ModelGroupConfig original = ModelGroupConfig(
          id: 'cfg-10',
          groupId: 'group-010',
          googleGroupId: 'GGG-010',
          email: 'soporte-10@domain.com',
          resourceName: 'groups/GGG-010',
          apiSource: ModelGroupConfigApiSource.mixed,
          etagSettings: 'etag-010',
          lastSyncStatus: ModelGroupConfigLastSyncStatus.ok,
          lastSyncAt: lastSyncAt,
          crud: crud,
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelGroupConfig roundtrip = ModelGroupConfig.fromJson(json);

        // Assert
        expect(roundtrip.toJson(), original.toJson());
        expect(roundtrip, original);
      },
    );

    test(
      'Given a ModelGroupConfig without lastSyncAt When toJson is called Then lastSyncAt key is omitted',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'cfg-11',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 2, 2, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 2, 2, 8),
        );

        final ModelGroupConfig config = ModelGroupConfig(
          id: 'cfg-11',
          groupId: 'group-011',
          googleGroupId: 'GGG-011',
          email: 'alias-11@domain.com',
          apiSource: ModelGroupConfigApiSource.directory,
          lastSyncStatus: ModelGroupConfigLastSyncStatus.never,
          // resourceName / etagSettings default to ''
          crud: crud,
        );

        // Act
        final Map<String, dynamic> json = config.toJson();

        // Assert
        expect(
          json.containsKey(ModelGroupConfigEnum.lastSyncAt.name),
          isFalse,
        );
        expect(
          json[ModelGroupConfigEnum.resourceName.name],
          equals(''),
        );
        expect(
          json[ModelGroupConfigEnum.etagSettings.name],
          equals(''),
        );

        final ModelGroupConfig roundtrip = ModelGroupConfig.fromJson(json);
        expect(roundtrip.lastSyncAt, isNull);
        expect(roundtrip.toJson(), config.toJson());
        expect(roundtrip.hashCode, config.hashCode);
        expect(roundtrip.toString(), isA<String>());
      },
    );
  });

  group('ModelGroupConfig.copyWith', () {
    test(
      'Given a ModelGroupConfig When copyWith overrides some fields Then returns a new instance with updated values',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'cfg-20',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 3, 1, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 3, 1, 8),
        );

        final ModelGroupConfig original = ModelGroupConfig(
          id: 'cfg-20',
          groupId: 'group-020',
          googleGroupId: 'GGG-020',
          email: 'original@domain.com',
          resourceName: 'groups/GGG-020',
          apiSource: ModelGroupConfigApiSource.directory,
          etagSettings: 'etag-old',
          lastSyncStatus: ModelGroupConfigLastSyncStatus.never,
          crud: crud,
        );

        final DateTime newLastSync = DateTime.utc(2025, 3, 1, 12);

        // Act
        final ModelGroupConfig copy = original.copyWith(
          email: 'new@domain.com',
          apiSource: ModelGroupConfigApiSource.mixed,
          lastSyncStatus: ModelGroupConfigLastSyncStatus.ok,
          lastSyncAt: newLastSync,
          etagSettings: 'etag-new',
        );

        // Assert
        expect(copy.id, original.id);
        expect(copy.groupId, original.groupId);
        expect(copy.googleGroupId, original.googleGroupId);
        expect(copy.email, 'new@domain.com');
        expect(copy.apiSource, ModelGroupConfigApiSource.mixed);
        expect(
          copy.lastSyncStatus,
          ModelGroupConfigLastSyncStatus.ok,
        );
        expect(copy.lastSyncAt?.toUtc(), newLastSync);
        expect(copy.etagSettings, 'etag-new');
        expect(copy.crud, same(crud));
        expect(copy, isNot(equals(original)));
      },
    );

    test(
      'Given a ModelGroupConfig When copyWith is called with no parameters Then returns an equal instance',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'cfg-21',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 3, 2, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 3, 2, 8),
        );

        final ModelGroupConfig original = ModelGroupConfig(
          id: 'cfg-21',
          groupId: 'group-021',
          googleGroupId: 'GGG-021',
          email: 'cfg-21@domain.com',
          apiSource: ModelGroupConfigApiSource.directory,
          lastSyncStatus: ModelGroupConfigLastSyncStatus.never,
          crud: crud,
        );

        // Act
        final ModelGroupConfig copy = original.copyWith();

        // Assert
        expect(copy, original);
        expect(copy.toJson(), original.toJson());
      },
    );
  });
}
