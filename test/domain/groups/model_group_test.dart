import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelGroup.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 1, 1, 10);
        final DateTime updatedAt = DateTime.utc(2025, 1, 2, 11, 30);

        final Map<String, dynamic> crudJson = <String, dynamic>{
          ModelCrudMetadataEnum.recordId.name: 'group-001',
          ModelCrudMetadataEnum.createdBy.name: 'system@domain.com',
          ModelCrudMetadataEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          ModelCrudMetadataEnum.updatedBy.name: 'admin@domain.com',
          ModelCrudMetadataEnum.updatedAt.name:
              DateUtils.dateTimeToString(updatedAt),
          ModelCrudMetadataEnum.version.name: 1,
        };

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupEnum.id.name: 'group-001',
          ModelGroupEnum.name.name: '5A Matemáticas 2025',
          ModelGroupEnum.description.name: 'Math group',
          ModelGroupEnum.email.name: 'group-001@school.test',
          ModelGroupEnum.state.name: ModelGroupState.archived.name,
          ModelGroupEnum.courseId.name: 'course-001',
          ModelGroupEnum.projectId.name: 'project-001',
          ModelGroupEnum.driveFolderId.name: 'folder-001',
          ModelGroupEnum.crud.name: crudJson,
          // labels omitted here to not depend on ModelGroupLabels internals.
        };

        // Act
        final ModelGroup group = ModelGroup.fromJson(json);

        // Assert
        expect(group.id, 'group-001');
        expect(group.name, '5A Matemáticas 2025');
        expect(group.description, 'Math group');
        expect(group.email, 'group-001@school.test');
        expect(group.state, ModelGroupState.archived);
        expect(group.courseId, 'course-001');
        expect(group.projectId, 'project-001');
        expect(group.driveFolderId, 'folder-001');

        expect(group.crud.recordId, 'group-001');
        expect(group.crud.createdBy, 'system@domain.com');
        expect(group.crud.createdAt.toUtc(), createdAt);
        expect(group.crud.updatedBy, 'admin@domain.com');
        expect(group.crud.updatedAt.toUtc(), updatedAt);
        expect(group.crud.version, 1);
      },
    );

    test(
      'Given JSON with missing optional fields When fromJson is called Then string fields default to empty string and labels is null',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupEnum.id.name: 'group-002',
          ModelGroupEnum.name.name: 'Minimal group',
          // No description, email, courseId, projectId, driveFolderId, labels
          ModelGroupEnum.state.name: ModelGroupState.active.name,
          ModelGroupEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'group-002',
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
        final ModelGroup group = ModelGroup.fromJson(json);

        // Assert
        expect(group.description, '');
        expect(group.email, '');
        expect(group.courseId, '');
        expect(group.projectId, '');
        expect(group.driveFolderId, '');
        expect(group.labels, isNull);
      },
    );

    test(
      'Given JSON with unknown state When fromJson is called Then defaults state to active',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupEnum.id.name: 'group-003',
          ModelGroupEnum.name.name: 'Unknown state group',
          ModelGroupEnum.state.name: 'NON_EXISTENT_STATE',
          ModelGroupEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'group-003',
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
        final ModelGroup group = ModelGroup.fromJson(json);

        // Assert
        expect(group.state, ModelGroupState.active);
      },
    );

    test(
      'Given JSON with explicit nulls for string fields When fromJson is called Then string fields are normalized to empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupEnum.id.name: 'group-004',
          ModelGroupEnum.name.name: 'Null fields group',
          ModelGroupEnum.description.name: null,
          ModelGroupEnum.email.name: null,
          ModelGroupEnum.courseId.name: null,
          ModelGroupEnum.projectId.name: null,
          ModelGroupEnum.driveFolderId.name: null,
          ModelGroupEnum.state.name: ModelGroupState.active.name,
          ModelGroupEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'group-004',
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
        final ModelGroup group = ModelGroup.fromJson(json);

        // Assert
        expect(group.description, '');
        expect(group.email, '');
        expect(group.courseId, '');
        expect(group.projectId, '');
        expect(group.driveFolderId, '');
      },
    );
  });

  group('ModelGroup.toJson & roundtrip', () {
    test(
      'Given a full ModelGroup When toJson and fromJson Then preserves all fields (roundtrip)',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 2, 1, 9);
        final DateTime updatedAt = DateTime.utc(2025, 2, 2, 10, 30);

        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'group-010',
          createdBy: 'system@domain.com',
          createdAt: createdAt,
          updatedBy: 'admin@domain.com',
          updatedAt: updatedAt,
          version: 2,
        );

        final ModelGroup original = ModelGroup(
          id: 'group-010',
          name: 'Full group',
          description: 'A fully defined group',
          email: 'group-010@school.test',
          state: ModelGroupState.deleted,
          courseId: 'course-010',
          projectId: 'project-010',
          driveFolderId: 'drive-folder-010',
          crud: crud,
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelGroup roundtrip = ModelGroup.fromJson(json);

        // Assert: JSON roundtrip matches
        expect(roundtrip.toJson(), original.toJson());

        // And equality is preserved
        expect(roundtrip, original);
      },
    );

    test(
      'Given a ModelGroup with defaults When toJson and fromJson Then empty-string fields remain empty and keys are present',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'group-011',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 2, 3, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 2, 3, 8),
        );

        final ModelGroup original = ModelGroup(
          id: 'group-011',
          name: 'Default group',
          state: ModelGroupState.active,
          crud: crud,
          // description/email/courseId/projectId/driveFolderId use defaults: ''
        );

        // Act
        final Map<String, dynamic> json = original.toJson();

        // Assert: keys must exist with empty string values
        expect(json[ModelGroupEnum.description.name], '');
        expect(json[ModelGroupEnum.email.name], '');
        expect(json[ModelGroupEnum.courseId.name], '');
        expect(json[ModelGroupEnum.projectId.name], '');
        expect(json[ModelGroupEnum.driveFolderId.name], '');
        expect(json.containsKey(ModelGroupEnum.labels.name), isFalse);

        final ModelGroup roundtrip = ModelGroup.fromJson(json);

        // And roundtrip keeps empty strings and null labels
        expect(roundtrip.description, '');
        expect(roundtrip.email, '');
        expect(roundtrip.courseId, '');
        expect(roundtrip.projectId, '');
        expect(roundtrip.driveFolderId, '');
        expect(roundtrip.labels, isNull);

        // JSON roundtrip stable
        expect(roundtrip.toJson(), original.toJson());
      },
    );
  });

  group('ModelGroup.copyWith', () {
    test(
      'Given a group When copyWith overrides some fields Then returns a new instance with updated values',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'group-020',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 3, 1, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 3, 1, 8),
        );

        final ModelGroup original = ModelGroup(
          id: 'group-020',
          name: 'Original name',
          description: 'Original description',
          email: 'original@mail.test',
          state: ModelGroupState.active,
          courseId: 'course-original',
          projectId: 'project-original',
          driveFolderId: 'drive-original',
          crud: crud,
        );

        // Act
        final ModelGroup copy = original.copyWith(
          name: 'New name',
          description: 'New description',
          email: 'new@mail.test',
          state: ModelGroupState.deleted,
          courseId: 'course-new',
          projectId: 'project-new',
          driveFolderId: 'drive-new',
        );

        // Assert
        expect(copy.id, original.id);
        expect(copy.name, 'New name');
        expect(copy.description, 'New description');
        expect(copy.email, 'new@mail.test');
        expect(copy.state, ModelGroupState.deleted);
        expect(copy.courseId, 'course-new');
        expect(copy.projectId, 'project-new');
        expect(copy.driveFolderId, 'drive-new');
        expect(copy.crud, same(crud));
        expect(copy, isNot(equals(original)));
      },
    );
  });
}
