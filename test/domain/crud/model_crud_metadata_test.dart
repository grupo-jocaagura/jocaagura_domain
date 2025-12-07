import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelCrudMetadata.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 1, 1, 10);
        final DateTime updatedAt = DateTime.utc(2025, 1, 2, 11, 30);
        final DateTime deletedAt = DateTime.utc(2025, 1, 3, 12);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelCrudMetadataEnum.recordId.name: 'group-001',
          ModelCrudMetadataEnum.createdBy.name: 'system@domain.com',
          ModelCrudMetadataEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          ModelCrudMetadataEnum.updatedBy.name: 'admin@domain.com',
          ModelCrudMetadataEnum.updatedAt.name:
              DateUtils.dateTimeToString(updatedAt),
          ModelCrudMetadataEnum.deleted.name: true,
          ModelCrudMetadataEnum.deletedBy.name: 'deleter@domain.com',
          ModelCrudMetadataEnum.deletedAt.name:
              DateUtils.dateTimeToString(deletedAt),
          ModelCrudMetadataEnum.version.name: 3,
        };

        // Act
        final ModelCrudMetadata metadata = ModelCrudMetadata.fromJson(json);

        // Assert
        expect(metadata.recordId, 'group-001');
        expect(metadata.createdBy, 'system@domain.com');
        expect(metadata.createdAt.toUtc(), createdAt);
        expect(metadata.updatedBy, 'admin@domain.com');
        expect(metadata.updatedAt.toUtc(), updatedAt);
        expect(metadata.deleted, isTrue);
        expect(metadata.deletedBy, 'deleter@domain.com');
        expect(metadata.deletedAt!.toUtc(), deletedAt);
        expect(metadata.version, 3);
      },
    );

    test(
      'Given minimal JSON payload When fromJson is called Then optional fields are null',
      () {
        // Arrange
        final DateTime nowCreated = DateTime.utc(2025, 1, 10, 8);
        final DateTime nowUpdated = DateTime.utc(2025, 1, 10, 8);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelCrudMetadataEnum.recordId.name: 'user-001',
          ModelCrudMetadataEnum.createdBy.name: 'system@domain.com',
          ModelCrudMetadataEnum.createdAt.name:
              DateUtils.dateTimeToString(nowCreated),
          ModelCrudMetadataEnum.updatedBy.name: 'system@domain.com',
          ModelCrudMetadataEnum.updatedAt.name:
              DateUtils.dateTimeToString(nowUpdated),
          // Optional fields not present
        };

        // Act
        final ModelCrudMetadata metadata = ModelCrudMetadata.fromJson(json);

        // Assert
        expect(metadata.recordId, 'user-001');
        expect(metadata.deleted, isNull);
        expect(metadata.deletedBy, isNull);
        expect(metadata.deletedAt, isNull);
        expect(metadata.version, isNull);
      },
    );
  });

  group('ModelCrudMetadata.toJson & roundtrip', () {
    test(
      'Given a complete ModelCrudMetadata When toJson and fromJson Then preserves all fields (roundtrip)',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 2, 1, 9);
        final DateTime updatedAt = DateTime.utc(2025, 2, 2, 10, 30);
        final DateTime deletedAt = DateTime.utc(2025, 2, 3, 11, 45);

        final ModelCrudMetadata original = ModelCrudMetadata(
          recordId: 'item-100',
          createdBy: 'system@domain.com',
          createdAt: createdAt,
          updatedBy: 'admin@domain.com',
          updatedAt: updatedAt,
          deleted: false,
          deletedBy: 'admin@domain.com',
          deletedAt: deletedAt,
          version: 5,
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelCrudMetadata roundtrip = ModelCrudMetadata.fromJson(json);

        // Assert: roundtrip JSON matches
        expect(roundtrip.toJson(), original.toJson());

        // Extra sanity checks
        expect(roundtrip.recordId, original.recordId);
        expect(roundtrip.createdBy, original.createdBy);
        expect(roundtrip.updatedBy, original.updatedBy);
        expect(roundtrip.deleted, original.deleted);
        expect(roundtrip.deletedBy, original.deletedBy);
        expect(roundtrip.version, original.version);
        expect(roundtrip.createdAt.toUtc(), createdAt);
        expect(roundtrip.updatedAt.toUtc(), updatedAt);
        expect(roundtrip.deletedAt!.toUtc(), deletedAt);
      },
    );

    test(
      'Given a metadata without optional fields When toJson and fromJson Then keeps optionals as null and omits them in JSON',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 3, 1, 8);
        final DateTime updatedAt = DateTime.utc(2025, 3, 1, 8);

        final ModelCrudMetadata original = ModelCrudMetadata(
          recordId: 'minimal-1',
          createdBy: 'system@domain.com',
          createdAt: createdAt,
          updatedBy: 'system@domain.com',
          updatedAt: updatedAt,
        );

        // Act
        final Map<String, dynamic> json = original.toJson();

        // Assert: JSON does not contain optional keys
        expect(
          json.containsKey(ModelCrudMetadataEnum.deleted.name),
          isFalse,
        );
        expect(
          json.containsKey(ModelCrudMetadataEnum.deletedBy.name),
          isFalse,
        );
        expect(
          json.containsKey(ModelCrudMetadataEnum.deletedAt.name),
          isFalse,
        );
        expect(
          json.containsKey(ModelCrudMetadataEnum.version.name),
          isFalse,
        );

        final ModelCrudMetadata roundtrip = ModelCrudMetadata.fromJson(json);

        // And roundtrip keeps nulls
        expect(roundtrip.deleted, isNull);
        expect(roundtrip.deletedBy, isNull);
        expect(roundtrip.deletedAt, isNull);
        expect(roundtrip.version, isNull);

        // JSON roundtrip is stable
        expect(roundtrip.toJson(), original.toJson());
      },
    );
  });

  group('ModelCrudMetadata.copyWith', () {
    test(
      'Given an instance When copyWith overrides common fields Then returns a new instance with updated values',
      () {
        // Arrange
        final ModelCrudMetadata original = ModelCrudMetadata(
          recordId: 'item-1',
          createdBy: 'creator@domain.com',
          createdAt: DateTime.utc(2025, 4, 1, 9),
          updatedBy: 'creator@domain.com',
          updatedAt: DateTime.utc(2025, 4, 1, 9),
          version: 1,
        );

        final DateTime newUpdatedAt = DateTime.utc(2025, 4, 2, 10);

        // Act
        final ModelCrudMetadata copy = original.copyWith(
          updatedBy: 'editor@domain.com',
          updatedAt: newUpdatedAt,
          version: 2,
        );

        // Assert
        expect(copy.recordId, original.recordId);
        expect(copy.createdBy, original.createdBy);
        expect(copy.createdAt, original.createdAt);
        expect(copy.updatedBy, 'editor@domain.com');
        expect(copy.updatedAt, newUpdatedAt);
        expect(copy.version, 2);
        expect(copy, isNot(equals(original)));
      },
    );

    test(
      'Given an instance with deleted=true When copyWith uses deletedOverrideNull Then deleted becomes null',
      () {
        // Arrange
        final ModelCrudMetadata original = ModelCrudMetadata(
          recordId: 'item-2',
          createdBy: 'system@domain.com',
          createdAt: DateTime.utc(2025, 5, 1, 8),
          updatedBy: 'system@domain.com',
          updatedAt: DateTime.utc(2025, 5, 1, 8),
          deleted: true,
        );

        // Act
        final ModelCrudMetadata cleared = original.copyWith(
          deletedOverrideNull: () => true,
        );

        // Assert
        expect(original.deleted, isTrue);
        expect(cleared.deleted, isNull);
      },
    );

    test(
      'Given an instance with version set When copyWith uses versionOverrideNull Then version becomes null',
      () {
        // Arrange
        final ModelCrudMetadata original = ModelCrudMetadata(
          recordId: 'item-3',
          createdBy: 'system@domain.com',
          createdAt: DateTime.utc(2025, 6, 1, 8),
          updatedBy: 'system@domain.com',
          updatedAt: DateTime.utc(2025, 6, 1, 8),
          version: 10,
        );

        // Act
        final ModelCrudMetadata cleared = original.copyWith(
          versionOverrideNull: () => true,
        );

        // Assert
        expect(original.version, 10);
        expect(cleared.version, isNull);
      },
    );
  });

  group('ModelCrudMetadata static helpers', () {
    test(
      'Given recordId and actor When initialize is called Then sets created/updated and version correctly',
      () {
        // Arrange
        final DateTime fixedNow = DateTime.utc(2025, 7, 1, 12);

        // Act
        final ModelCrudMetadata metadata = ModelCrudMetadata.initialize(
          recordId: 'group-001',
          actor: 'system@domain.com',
          timestamp: fixedNow,
        );

        // Assert
        expect(metadata.recordId, 'group-001');
        expect(metadata.createdBy, 'system@domain.com');
        expect(metadata.updatedBy, 'system@domain.com');
        expect(metadata.createdAt.toUtc(), fixedNow);
        expect(metadata.updatedAt.toUtc(), fixedNow);
        expect(metadata.deleted, isNull);
        expect(metadata.deletedBy, isNull);
        expect(metadata.deletedAt, isNull);
        expect(metadata.version, 1);

        // JSON roundtrip sanity
        final ModelCrudMetadata roundtrip =
            ModelCrudMetadata.fromJson(metadata.toJson());
        expect(roundtrip.toJson(), metadata.toJson());
      },
    );

    test(
      'Given explicit initialVersion When initialize is called Then uses provided version',
      () {
        // Arrange
        final DateTime fixedNow = DateTime.utc(2025, 7, 2, 8);

        // Act
        final ModelCrudMetadata metadata = ModelCrudMetadata.initialize(
          recordId: 'group-002',
          actor: 'user@domain.com',
          timestamp: fixedNow,
          initialVersion: 10,
        );

        // Assert
        expect(metadata.version, 10);
      },
    );

    test(
      'Given metadata without version When touchOnUpdate is called Then sets version to 1 and updates audit fields',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 7, 3, 9);
        final DateTime updatedAt = DateTime.utc(2025, 7, 3, 9);
        final DateTime touchTime = DateTime.utc(2025, 7, 4, 10, 30);

        final ModelCrudMetadata base = ModelCrudMetadata(
          recordId: 'item-001',
          createdBy: 'system@domain.com',
          createdAt: createdAt,
          updatedBy: 'system@domain.com',
          updatedAt: updatedAt,
          // version is null
        );

        // Act
        final ModelCrudMetadata touched = ModelCrudMetadata.touchOnUpdate(
          current: base,
          actor: 'editor@domain.com',
          timestamp: touchTime,
        );

        // Assert
        expect(touched.recordId, base.recordId);
        expect(touched.createdBy, base.createdBy);
        expect(touched.createdAt.toUtc(), createdAt);
        expect(touched.updatedBy, 'editor@domain.com');
        expect(touched.updatedAt.toUtc(), touchTime);
        expect(touched.version, 1);
      },
    );

    test(
      'Given metadata with version When touchOnUpdate is called Then increments version by 1',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 7, 5, 9);
        final DateTime updatedAt = DateTime.utc(2025, 7, 5, 9);
        final DateTime touchTime = DateTime.utc(2025, 7, 6, 11);

        final ModelCrudMetadata base = ModelCrudMetadata(
          recordId: 'item-002',
          createdBy: 'system@domain.com',
          createdAt: createdAt,
          updatedBy: 'system@domain.com',
          updatedAt: updatedAt,
          version: 3,
        );

        // Act
        final ModelCrudMetadata touched = ModelCrudMetadata.touchOnUpdate(
          current: base,
          actor: 'editor@domain.com',
          timestamp: touchTime,
        );

        // Assert
        expect(touched.version, 4);
        expect(touched.updatedBy, 'editor@domain.com');
        expect(touched.updatedAt.toUtc(), touchTime);
      },
    );

    test(
      'Given metadata with version When touchOnUpdate is called with bumpVersion=false Then version is preserved',
      () {
        // Arrange
        final ModelCrudMetadata base = ModelCrudMetadata(
          recordId: 'item-003',
          createdBy: 'system@domain.com',
          createdAt: DateTime.utc(2025, 7, 7, 8),
          updatedBy: 'system@domain.com',
          updatedAt: DateTime.utc(2025, 7, 7, 8),
          version: 5,
        );

        final DateTime touchTime = DateTime.utc(2025, 7, 7, 9);

        // Act
        final ModelCrudMetadata touched = ModelCrudMetadata.touchOnUpdate(
          current: base,
          actor: 'editor@domain.com',
          timestamp: touchTime,
          bumpVersion: false,
        );

        // Assert
        expect(touched.version, 5);
        expect(touched.updatedBy, 'editor@domain.com');
        expect(touched.updatedAt.toUtc(), touchTime);
      },
    );

    test(
      'Given initialized metadata When markDeleted is called Then sets deleted flags and increments version',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 7, 8, 8);
        final DateTime updatedAt = DateTime.utc(2025, 7, 8, 8);
        final DateTime deletedAt = DateTime.utc(2025, 7, 9, 9, 30);

        final ModelCrudMetadata base = ModelCrudMetadata(
          recordId: 'item-004',
          createdBy: 'system@domain.com',
          createdAt: createdAt,
          updatedBy: 'system@domain.com',
          updatedAt: updatedAt,
          version: 2,
        );

        // Act
        final ModelCrudMetadata deleted = ModelCrudMetadata.markDeleted(
          current: base,
          actor: 'admin@domain.com',
          timestamp: deletedAt,
        );

        // Assert
        expect(deleted.deleted, isTrue);
        expect(deleted.deletedBy, 'admin@domain.com');
        expect(deleted.deletedAt!.toUtc(), deletedAt);
        expect(deleted.version, 3);
      },
    );

    test(
      'Given metadata with version When markDeleted is called with bumpVersion=false Then keeps version unchanged',
      () {
        // Arrange
        final ModelCrudMetadata base = ModelCrudMetadata(
          recordId: 'item-005',
          createdBy: 'system@domain.com',
          createdAt: DateTime.utc(2025, 7, 10, 8),
          updatedBy: 'system@domain.com',
          updatedAt: DateTime.utc(2025, 7, 10, 8),
          version: 7,
        );

        final DateTime deletedAt = DateTime.utc(2025, 7, 11, 10);

        // Act
        final ModelCrudMetadata deleted = ModelCrudMetadata.markDeleted(
          current: base,
          actor: 'admin@domain.com',
          timestamp: deletedAt,
          bumpVersion: false,
        );

        // Assert
        expect(deleted.version, 7);
        expect(deleted.deleted, isTrue);
        expect(deleted.deletedBy, 'admin@domain.com');
        expect(deleted.deletedAt!.toUtc(), deletedAt);
      },
    );
  });
}
