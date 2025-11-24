import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelGroupMember.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 1, 1, 10);
        final DateTime updatedAt = DateTime.utc(2025, 1, 1, 11);

        final Map<String, dynamic> crudJson = <String, dynamic>{
          ModelCrudMetadataEnum.recordId.name: 'member-1',
          ModelCrudMetadataEnum.createdBy.name: 'system@domain.com',
          ModelCrudMetadataEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          ModelCrudMetadataEnum.updatedBy.name: 'admin@domain.com',
          ModelCrudMetadataEnum.updatedAt.name:
              DateUtils.dateTimeToString(updatedAt),
          ModelCrudMetadataEnum.version.name: 1,
        };

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupMemberEnum.id.name: 'member-1',
          ModelGroupMemberEnum.groupId.name: 'group-001',
          ModelGroupMemberEnum.email.name: 'user@domain.com',
          ModelGroupMemberEnum.userId.name: 'user-001',
          ModelGroupMemberEnum.role.name: ModelGroupMemberRole.owner.name,
          ModelGroupMemberEnum.entityType.name:
              ModelGroupMemberEntityType.user.name,
          ModelGroupMemberEnum.membershipId.name: 'mem-001',
          ModelGroupMemberEnum.source.name:
              ModelGroupMemberSource.fromCourse.name,
          ModelGroupMemberEnum.subscription.name:
              ModelGroupMemberSubscription.digest.name,
          ModelGroupMemberEnum.includeDerived.name: true,
          ModelGroupMemberEnum.active.name: true,
          ModelGroupMemberEnum.crud.name: crudJson,
        };

        // Act
        final ModelGroupMember member = ModelGroupMember.fromJson(json);

        // Assert
        expect(member.id, 'member-1');
        expect(member.groupId, 'group-001');
        expect(member.email, 'user@domain.com');
        expect(member.userId, 'user-001');
        expect(member.role, ModelGroupMemberRole.owner);
        expect(member.entityType, ModelGroupMemberEntityType.user);
        expect(member.membershipId, 'mem-001');
        expect(member.source, ModelGroupMemberSource.fromCourse);
        expect(
          member.subscription,
          ModelGroupMemberSubscription.digest,
        );
        expect(member.includeDerived, isTrue);
        expect(member.active, isTrue);

        expect(member.crud.recordId, 'member-1');
        expect(member.crud.createdBy, 'system@domain.com');
        expect(member.crud.createdAt.toUtc(), createdAt);
        expect(member.crud.updatedBy, 'admin@domain.com');
        expect(member.crud.updatedAt.toUtc(), updatedAt);
        expect(member.crud.version, 1);
      },
    );

    test(
      'Given JSON with missing bool fields When fromJson is called Then includeDerived=false and active=true',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupMemberEnum.id.name: 'member-2',
          ModelGroupMemberEnum.groupId.name: 'group-002',
          ModelGroupMemberEnum.email.name: 'user2@domain.com',
          ModelGroupMemberEnum.userId.name: 'user-002',
          ModelGroupMemberEnum.role.name: ModelGroupMemberRole.member.name,
          ModelGroupMemberEnum.entityType.name:
              ModelGroupMemberEntityType.user.name,
          ModelGroupMemberEnum.membershipId.name: 'mem-002',
          ModelGroupMemberEnum.source.name: ModelGroupMemberSource.manual.name,
          ModelGroupMemberEnum.subscription.name:
              ModelGroupMemberSubscription.allMail.name,
          ModelGroupMemberEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'member-2',
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
        final ModelGroupMember member = ModelGroupMember.fromJson(json);

        // Assert
        expect(member.includeDerived, isFalse);
        expect(member.active, isTrue);
      },
    );

    test(
      'Given JSON with null bool fields When fromJson is called Then includeDerived=false and active=true',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupMemberEnum.id.name: 'member-3',
          ModelGroupMemberEnum.groupId.name: 'group-003',
          ModelGroupMemberEnum.email.name: 'user3@domain.com',
          ModelGroupMemberEnum.userId.name: 'user-003',
          ModelGroupMemberEnum.role.name: ModelGroupMemberRole.member.name,
          ModelGroupMemberEnum.entityType.name:
              ModelGroupMemberEntityType.user.name,
          ModelGroupMemberEnum.membershipId.name: 'mem-003',
          ModelGroupMemberEnum.source.name: ModelGroupMemberSource.manual.name,
          ModelGroupMemberEnum.subscription.name:
              ModelGroupMemberSubscription.allMail.name,
          ModelGroupMemberEnum.includeDerived.name: null,
          ModelGroupMemberEnum.active.name: null,
          ModelGroupMemberEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'member-3',
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
        final ModelGroupMember member = ModelGroupMember.fromJson(json);

        // Assert
        expect(member.includeDerived, isFalse);
        expect(member.active, isTrue);
      },
    );

    test(
      'Given JSON with invalid email When fromJson is called Then email is normalized to empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupMemberEnum.id.name: 'member-4',
          ModelGroupMemberEnum.groupId.name: 'group-004',
          ModelGroupMemberEnum.email.name: 'not-an-email',
          ModelGroupMemberEnum.userId.name: 'user-004',
          ModelGroupMemberEnum.role.name: ModelGroupMemberRole.member.name,
          ModelGroupMemberEnum.entityType.name:
              ModelGroupMemberEntityType.user.name,
          ModelGroupMemberEnum.membershipId.name: 'mem-004',
          ModelGroupMemberEnum.source.name: ModelGroupMemberSource.manual.name,
          ModelGroupMemberEnum.subscription.name:
              ModelGroupMemberSubscription.allMail.name,
          ModelGroupMemberEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'member-4',
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
        final ModelGroupMember member = ModelGroupMember.fromJson(json);

        // Assert
        expect(member.email, '');
      },
    );

    test(
      'Given JSON with unknown enum values When fromJson is called Then defaults are applied',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupMemberEnum.id.name: 'member-5',
          ModelGroupMemberEnum.groupId.name: 'group-005',
          ModelGroupMemberEnum.email.name: 'user5@domain.com',
          ModelGroupMemberEnum.userId.name: 'user-005',
          ModelGroupMemberEnum.role.name: 'UNKNOWN_ROLE',
          ModelGroupMemberEnum.entityType.name: 'UNKNOWN_TYPE',
          ModelGroupMemberEnum.membershipId.name: 'mem-005',
          ModelGroupMemberEnum.source.name: 'UNKNOWN_SOURCE',
          ModelGroupMemberEnum.subscription.name: 'UNKNOWN_SUB',
          ModelGroupMemberEnum.includeDerived.name: true,
          ModelGroupMemberEnum.active.name: true,
          ModelGroupMemberEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'member-5',
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
        final ModelGroupMember member = ModelGroupMember.fromJson(json);

        // Assert
        expect(member.role, ModelGroupMemberRole.member);
        expect(
          member.entityType,
          ModelGroupMemberEntityType.user,
        );
        expect(member.source, ModelGroupMemberSource.manual);
        expect(
          member.subscription,
          ModelGroupMemberSubscription.allMail,
        );
      },
    );

    test(
      'Given JSON with null scalars When fromJson is called Then they fallback to empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupMemberEnum.id.name: null,
          ModelGroupMemberEnum.groupId.name: null,
          ModelGroupMemberEnum.email.name: null,
          ModelGroupMemberEnum.userId.name: null,
          ModelGroupMemberEnum.role.name: ModelGroupMemberRole.member.name,
          ModelGroupMemberEnum.entityType.name:
              ModelGroupMemberEntityType.user.name,
          ModelGroupMemberEnum.membershipId.name: null,
          ModelGroupMemberEnum.source.name: ModelGroupMemberSource.manual.name,
          ModelGroupMemberEnum.subscription.name:
              ModelGroupMemberSubscription.allMail.name,
          ModelGroupMemberEnum.crud.name: <String, dynamic>{
            ModelCrudMetadataEnum.recordId.name: 'member-6',
            ModelCrudMetadataEnum.createdBy.name: 'system',
            ModelCrudMetadataEnum.createdAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 6, 8),
            ),
            ModelCrudMetadataEnum.updatedBy.name: 'system',
            ModelCrudMetadataEnum.updatedAt.name: DateUtils.dateTimeToString(
              DateTime.utc(2025, 1, 6, 8),
            ),
          },
        };

        // Act
        final ModelGroupMember member = ModelGroupMember.fromJson(json);

        // Assert
        expect(member.id, '');
        expect(member.groupId, '');
        expect(member.email, '');
        expect(member.userId, '');
        expect(member.membershipId, '');
      },
    );
  });

  group('ModelGroupMember.toJson & roundtrip', () {
    test(
      'Given a full ModelGroupMember When toJson and fromJson Then preserves all fields (roundtrip)',
      () {
        // Arrange
        final DateTime createdAt = DateTime.utc(2025, 2, 1, 9);
        final DateTime updatedAt = DateTime.utc(2025, 2, 1, 10);

        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'member-10',
          createdBy: 'system@domain.com',
          createdAt: createdAt,
          updatedBy: 'admin@domain.com',
          updatedAt: updatedAt,
          version: 2,
        );

        final ModelGroupMember original = ModelGroupMember(
          id: 'member-10',
          groupId: 'group-010',
          email: 'user10@domain.com',
          userId: 'user-010',
          role: ModelGroupMemberRole.moderator,
          entityType: ModelGroupMemberEntityType.group,
          membershipId: 'mem-010',
          source: ModelGroupMemberSource.fromSheet,
          subscription: ModelGroupMemberSubscription.abridged,
          includeDerived: true,
          active: false,
          crud: crud,
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelGroupMember roundtrip = ModelGroupMember.fromJson(json);

        // Assert
        expect(roundtrip.toJson(), original.toJson());
        expect(roundtrip, original);
      },
    );
  });

  group('ModelGroupMember.copyWith', () {
    test(
      'Given a ModelGroupMember When copyWith overrides some fields Then returns a new instance with updated values',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'member-20',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 3, 1, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 3, 1, 8),
        );

        final ModelGroupMember original = ModelGroupMember(
          id: 'member-20',
          groupId: 'group-020',
          email: 'original@domain.com',
          userId: 'user-020',
          role: ModelGroupMemberRole.member,
          entityType: ModelGroupMemberEntityType.user,
          membershipId: 'mem-020',
          source: ModelGroupMemberSource.manual,
          subscription: ModelGroupMemberSubscription.allMail,
          includeDerived: false,
          active: true,
          crud: crud,
        );

        // Act
        final ModelGroupMember copy = original.copyWith(
          email: 'new@domain.com',
          role: ModelGroupMemberRole.owner,
          active: false,
          subscription: ModelGroupMemberSubscription.noEmail,
        );

        // Assert
        expect(copy.id, original.id);
        expect(copy.groupId, original.groupId);
        expect(copy.userId, original.userId);
        expect(copy.email, 'new@domain.com');
        expect(copy.role, ModelGroupMemberRole.owner);
        expect(
          copy.subscription,
          ModelGroupMemberSubscription.noEmail,
        );
        expect(copy.active, isFalse);
        expect(copy.includeDerived, isFalse);
        expect(copy.crud, same(crud));
        expect(copy, isNot(equals(original)));
        expect(copy.hashCode, isNot(equals(original.hashCode)));
        expect(copy.toString(), isNot(equals(original.toString())));
      },
    );

    test(
      'Given a ModelGroupMember When copyWith is called with no parameters Then returns an equal instance',
      () {
        // Arrange
        final ModelCrudMetadata crud = ModelCrudMetadata(
          recordId: 'member-21',
          createdBy: 'system',
          createdAt: DateTime.utc(2025, 3, 2, 8),
          updatedBy: 'system',
          updatedAt: DateTime.utc(2025, 3, 2, 8),
        );

        final ModelGroupMember original = ModelGroupMember(
          id: 'member-21',
          groupId: 'group-021',
          email: 'member21@domain.com',
          userId: 'user-021',
          role: ModelGroupMemberRole.member,
          entityType: ModelGroupMemberEntityType.user,
          membershipId: 'mem-021',
          source: ModelGroupMemberSource.manual,
          subscription: ModelGroupMemberSubscription.allMail,
          includeDerived: false,
          active: true,
          crud: crud,
        );

        // Act
        final ModelGroupMember copy = original.copyWith();

        // Assert
        expect(copy, original);
        expect(copy.toJson(), original.toJson());
      },
    );
  });
}
