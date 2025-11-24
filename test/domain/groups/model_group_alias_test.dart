import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelGroupAlias.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 1, 1, 10);
        final DateTime updatedAt = DateTime.utc(2025, 1, 1, 11);

        final Map<String, dynamic> crudJson = <String, dynamic>{
          ModelCrudMetadataEnum.recordId.name: 'alias-1',
          ModelCrudMetadataEnum.createdBy.name: 'system@domain.com',
          ModelCrudMetadataEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          ModelCrudMetadataEnum.updatedBy.name: 'system@domain.com',
          ModelCrudMetadataEnum.updatedAt.name:
              DateUtils.dateTimeToString(updatedAt),
          ModelCrudMetadataEnum.version.name: 1,
        };

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupAliasEnum.id.name: 'alias-1',
          ModelGroupAliasEnum.groupId.name: 'group-001',
          ModelGroupAliasEnum.aliasEmail.name: 'soporte@domain.com',
          ModelGroupAliasEnum.status.name: ModelGroupAliasStatus.pending.name,
          ModelGroupAliasEnum.errorItemId.name: 'ERR-123',
          ModelGroupAliasEnum.crud.name: crudJson,
        };

        // Act
        final ModelGroupAlias alias = ModelGroupAlias.fromJson(json);

        // Assert
        expect(alias.id, 'alias-1');
        expect(alias.groupId, 'group-001');
        expect(alias.aliasEmail, 'soporte@domain.com');
        expect(alias.status, ModelGroupAliasStatus.pending);
        expect(alias.errorItemId, 'ERR-123');

        expect(alias.crud.recordId, 'alias-1');
        expect(alias.crud.createdBy, 'system@domain.com');
        expect(alias.crud.createdAt.toUtc(), createdAt);
        expect(alias.crud.updatedBy, 'system@domain.com');
        expect(alias.crud.updatedAt.toUtc(), updatedAt);
        expect(alias.crud.version, 1);
      },
    );

    test(
      'Given JSON without errorItemId When fromJson is called Then errorItemId defaults to empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupAliasEnum.id.name: 'alias-2',
          ModelGroupAliasEnum.groupId.name: 'group-002',
          ModelGroupAliasEnum.aliasEmail.name: 'info@domain.com',
          ModelGroupAliasEnum.status.name: ModelGroupAliasStatus.active.name,
          ModelGroupAliasEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'alias-2',
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
        final ModelGroupAlias alias = ModelGroupAlias.fromJson(json);

        // Assert
        expect(alias.errorItemId, '');
      },
    );

    test(
      'Given JSON with null errorItemId When fromJson is called Then errorItemId is normalized to empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupAliasEnum.id.name: 'alias-3',
          ModelGroupAliasEnum.groupId.name: 'group-003',
          ModelGroupAliasEnum.aliasEmail.name: 'ventas@domain.com',
          ModelGroupAliasEnum.status.name: ModelGroupAliasStatus.error.name,
          ModelGroupAliasEnum.errorItemId.name: null,
          ModelGroupAliasEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'alias-3',
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
        final ModelGroupAlias alias = ModelGroupAlias.fromJson(json);

        // Assert
        expect(alias.errorItemId, '');
      },
    );

    test(
      'Given JSON with unknown status When fromJson is called Then defaults status to active',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupAliasEnum.id.name: 'alias-4',
          ModelGroupAliasEnum.groupId.name: 'group-004',
          ModelGroupAliasEnum.aliasEmail.name: 'unknown@domain.com',
          ModelGroupAliasEnum.status.name: 'SOMETHING_ELSE',
          ModelGroupAliasEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'alias-4',
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
        final ModelGroupAlias alias = ModelGroupAlias.fromJson(json);

        // Assert
        expect(alias.status, ModelGroupAliasStatus.active);
      },
    );

    test(
      'Given JSON with null scalars When fromJson is called Then they fallback to empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupAliasEnum.id.name: null,
          ModelGroupAliasEnum.groupId.name: null,
          ModelGroupAliasEnum.aliasEmail.name: null,
          ModelGroupAliasEnum.status.name: ModelGroupAliasStatus.pending.name,
          ModelGroupAliasEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'alias-5',
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
        final ModelGroupAlias alias = ModelGroupAlias.fromJson(json);

        // Assert
        expect(alias.id, '');
        expect(alias.groupId, '');
        expect(alias.aliasEmail, '');
      },
    );
  });

  group('ModelGroupAlias.toJson & roundtrip', () {
    test(
      'Given a full ModelGroupAlias When toJson and fromJson Then preserves all fields (roundtrip)',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 2, 1, 9);
        final DateTime updatedAt = DateTime.utc(2025, 2, 1, 10);

        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'alias-10',
          createdBy: 'system@domain.com',
          createdAt: createdAt,
          updatedBy: 'admin@domain.com',
          updatedAt: updatedAt,
          version: 2,
        );

        final ModelGroupAlias original = ModelGroupAlias(
          id: 'alias-10',
          groupId: 'group-010',
          aliasEmail: 'soporte-10@domain.com',
          status: ModelGroupAliasStatus.error,
          errorItemId: 'ERR-999',
          crud: crud,
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelGroupAlias roundtrip = ModelGroupAlias.fromJson(json);

        // Assert: JSON roundtrip matches
        expect(roundtrip.toJson(), original.toJson());

        // And equality is preserved
        expect(roundtrip, original);
        expect(roundtrip.hashCode == original.hashCode, true);
        expect(roundtrip.toString() == original.toString(), true);
      },
    );

    test(
      'Given a ModelGroupAlias with default errorItemId When toJson is called Then errorItemId key is present with empty string',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'alias-11',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 2, 2, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 2, 2, 8),
        );

        final ModelGroupAlias alias = ModelGroupAlias(
          id: 'alias-11',
          groupId: 'group-011',
          aliasEmail: 'alias-11@domain.com',
          status: ModelGroupAliasStatus.active,
          // errorItemId omitted → default ''
          crud: crud,
        );

        // Act
        final Map<String, dynamic> json = alias.toJson();

        // Assert
        expect(json.containsKey(ModelGroupAliasEnum.errorItemId.name), isTrue);
        expect(
          json[ModelGroupAliasEnum.errorItemId.name],
          equals(''),
        );

        final ModelGroupAlias roundtrip = ModelGroupAlias.fromJson(json);
        expect(roundtrip.errorItemId, '');
        expect(roundtrip.toJson(), alias.toJson());
      },
    );
  });

  group('ModelGroupAlias.copyWith', () {
    test(
      'Given a ModelGroupAlias When copyWith overrides some fields Then returns a new instance with updated values',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'alias-20',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 3, 1, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 3, 1, 8),
        );

        final ModelGroupAlias original = ModelGroupAlias(
          id: 'alias-20',
          groupId: 'group-020',
          aliasEmail: 'original@domain.com',
          status: ModelGroupAliasStatus.pending,
          errorItemId: 'ERR-OLD',
          crud: crud,
        );

        // Act
        final ModelGroupAlias copy = original.copyWith(
          aliasEmail: 'new@domain.com',
          status: ModelGroupAliasStatus.active,
          errorItemId: 'ERR-NEW',
        );

        // Assert
        expect(copy.id, original.id);
        expect(copy.groupId, original.groupId);
        expect(copy.aliasEmail, 'new@domain.com');
        expect(copy.status, ModelGroupAliasStatus.active);
        expect(copy.errorItemId, 'ERR-NEW');
        expect(copy.crud, same(crud));
        expect(copy, isNot(equals(original)));
      },
    );

    test(
      'Given a ModelGroupAlias When copyWith is called with no parameters Then returns an equal instance',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'alias-21',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 3, 2, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 3, 2, 8),
        );

        final ModelGroupAlias original = ModelGroupAlias(
          id: 'alias-21',
          groupId: 'group-021',
          aliasEmail: 'alias-21@domain.com',
          status: ModelGroupAliasStatus.error,
          crud: crud,
        );

        // Act
        final ModelGroupAlias copy = original.copyWith();

        // Assert
        expect(copy, original);
        expect(copy.toJson(), original.toJson());
      },
    );
  });
}
