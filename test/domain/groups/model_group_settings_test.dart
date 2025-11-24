import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelGroupSettings.fromJson', () {
    test(
      'Given full JSON payload When fromJson is called Then maps all fields correctly',
      () {
        // Arrange
        final DateTime fetched = DateTime.utc(2025, 1, 10, 12, 30);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSettingsEnum.id.name: 'settings-1',
          ModelGroupSettingsEnum.groupId.name: 'group-001',
          ModelGroupSettingsEnum.googleGroupId.name: 'AAA-BBB-CCC',
          ModelGroupSettingsEnum.whoCanViewGroup.name: 'ALL_MEMBERS_CAN_VIEW',
          ModelGroupSettingsEnum.whoCanViewMembership.name:
              'ALL_MEMBERS_CAN_VIEW',
          ModelGroupSettingsEnum.whoCanJoin.name: 'INVITED_CAN_JOIN',
          ModelGroupSettingsEnum.whoCanPostMessage.name: 'ALL_MEMBERS_CAN_POST',
          ModelGroupSettingsEnum.messageModerationLevel.name: 'MODERATE_NONE',
          ModelGroupSettingsEnum.spamModerationLevel.name: 'MODERATE',
          ModelGroupSettingsEnum.includeInGlobalAddressList.name: true,
          ModelGroupSettingsEnum.membersCanPostAsTheGroup.name: false,
          ModelGroupSettingsEnum.isArchived.name: true,
          ModelGroupSettingsEnum.isCollaborativeInbox.name: true,
          ModelGroupSettingsEnum.rawSettings.name: <String, dynamic>{
            'whoCanViewGroup': 'ALL_MEMBERS_CAN_VIEW',
            'archiveOnly': false,
          },
          ModelGroupSettingsEnum.fetchedAt.name:
              DateUtils.dateTimeToString(fetched),
        };

        // Act
        final ModelGroupSettings settings = ModelGroupSettings.fromJson(json);

        // Assert
        expect(settings.id, 'settings-1');
        expect(settings.groupId, 'group-001');
        expect(settings.googleGroupId, 'AAA-BBB-CCC');
        expect(settings.whoCanViewGroup, 'ALL_MEMBERS_CAN_VIEW');
        expect(settings.whoCanViewMembership, 'ALL_MEMBERS_CAN_VIEW');
        expect(settings.whoCanJoin, 'INVITED_CAN_JOIN');
        expect(settings.whoCanPostMessage, 'ALL_MEMBERS_CAN_POST');
        expect(settings.messageModerationLevel, 'MODERATE_NONE');
        expect(settings.spamModerationLevel, 'MODERATE');
        expect(settings.includeInGlobalAddressList, isTrue);
        expect(settings.membersCanPostAsTheGroup, isFalse);
        expect(settings.isArchived, isTrue);
        expect(settings.isCollaborativeInbox, isTrue);
        expect(
          settings.rawSettings['whoCanViewGroup'],
          'ALL_MEMBERS_CAN_VIEW',
        );
        expect(settings.rawSettings['archiveOnly'], isFalse);
        expect(settings.fetchedAt.toUtc(), fetched);
      },
    );

    test(
      'Given JSON without bool flags When fromJson is called Then defaults are applied',
      () {
        // Arrange
        final DateTime fetched = DateTime.utc(2025, 1, 11, 8);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSettingsEnum.id.name: 'settings-2',
          ModelGroupSettingsEnum.groupId.name: 'group-002',
          ModelGroupSettingsEnum.googleGroupId.name: 'GGG-HHH-III',
          ModelGroupSettingsEnum.whoCanViewGroup.name: 'ALL_MEMBERS_CAN_VIEW',
          ModelGroupSettingsEnum.whoCanViewMembership.name:
              'ALL_MEMBERS_CAN_VIEW',
          ModelGroupSettingsEnum.whoCanJoin.name: 'INVITED_CAN_JOIN',
          ModelGroupSettingsEnum.whoCanPostMessage.name: 'ALL_MEMBERS_CAN_POST',
          ModelGroupSettingsEnum.messageModerationLevel.name: 'MODERATE_NONE',
          ModelGroupSettingsEnum.spamModerationLevel.name: 'MODERATE',
          // All boolean flags omitted on purpose
          ModelGroupSettingsEnum.fetchedAt.name:
              DateUtils.dateTimeToString(fetched),
        };

        // Act
        final ModelGroupSettings settings = ModelGroupSettings.fromJson(json);

        // Assert
        expect(
          settings.includeInGlobalAddressList,
          isTrue,
          reason: 'Default when missing is true',
        );
        expect(
          settings.membersCanPostAsTheGroup,
          isFalse,
          reason: 'Default when missing is false',
        );
        expect(settings.isArchived, isFalse);
        expect(settings.isCollaborativeInbox, isFalse);
      },
    );

    test(
      'Given JSON without rawSettings When fromJson is called Then rawSettings is an empty map',
      () {
        // Arrange
        final DateTime fetched = DateTime.utc(2025, 1, 12, 9);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSettingsEnum.id.name: 'settings-3',
          ModelGroupSettingsEnum.groupId.name: 'group-003',
          ModelGroupSettingsEnum.googleGroupId.name: 'JJJ-KKK-LLL',
          ModelGroupSettingsEnum.whoCanViewGroup.name: 'OWNERS_ONLY',
          ModelGroupSettingsEnum.whoCanViewMembership.name: 'OWNERS_ONLY',
          ModelGroupSettingsEnum.whoCanJoin.name: 'INVITED_CAN_JOIN',
          ModelGroupSettingsEnum.whoCanPostMessage.name: 'ALL_MEMBERS_CAN_POST',
          ModelGroupSettingsEnum.messageModerationLevel.name: 'MODERATE_NONE',
          ModelGroupSettingsEnum.spamModerationLevel.name: 'MODERATE',
          ModelGroupSettingsEnum.includeInGlobalAddressList.name: true,
          ModelGroupSettingsEnum.membersCanPostAsTheGroup.name: false,
          ModelGroupSettingsEnum.isArchived.name: false,
          ModelGroupSettingsEnum.isCollaborativeInbox.name: false,
          // rawSettings omitted
          ModelGroupSettingsEnum.fetchedAt.name:
              DateUtils.dateTimeToString(fetched),
        };

        // Act
        final ModelGroupSettings settings = ModelGroupSettings.fromJson(json);

        // Assert
        expect(settings.rawSettings, isA<Map<String, dynamic>>());
        expect(settings.rawSettings, isEmpty);
      },
    );

    test(
      'Given JSON with rawSettings as JSON string When fromJson is called Then rawSettings is parsed map',
      () {
        // Arrange
        final DateTime fetched = DateTime.utc(2025, 1, 13, 10);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSettingsEnum.id.name: 'settings-4',
          ModelGroupSettingsEnum.groupId.name: 'group-004',
          ModelGroupSettingsEnum.googleGroupId.name: 'MMM-NNN-OOO',
          ModelGroupSettingsEnum.whoCanViewGroup.name: 'ALL_MEMBERS_CAN_VIEW',
          ModelGroupSettingsEnum.whoCanViewMembership.name:
              'ALL_MEMBERS_CAN_VIEW',
          ModelGroupSettingsEnum.whoCanJoin.name: 'INVITED_CAN_JOIN',
          ModelGroupSettingsEnum.whoCanPostMessage.name: 'ALL_MEMBERS_CAN_POST',
          ModelGroupSettingsEnum.messageModerationLevel.name: 'MODERATE_NONE',
          ModelGroupSettingsEnum.spamModerationLevel.name: 'MODERATE',
          ModelGroupSettingsEnum.includeInGlobalAddressList.name: true,
          ModelGroupSettingsEnum.membersCanPostAsTheGroup.name: false,
          ModelGroupSettingsEnum.isArchived.name: false,
          ModelGroupSettingsEnum.isCollaborativeInbox.name: false,
          ModelGroupSettingsEnum.rawSettings.name:
              '{"whoCanViewGroup":"ALL_MEMBERS_CAN_VIEW","flag":true}',
          ModelGroupSettingsEnum.fetchedAt.name:
              DateUtils.dateTimeToString(fetched),
        };

        // Act
        final ModelGroupSettings settings = ModelGroupSettings.fromJson(json);

        // Assert
        expect(
          settings.rawSettings['whoCanViewGroup'],
          'ALL_MEMBERS_CAN_VIEW',
        );
        expect(settings.rawSettings['flag'], isTrue);
      },
    );
  });

  group('ModelGroupSettings.toJson & roundtrip', () {
    test(
      'Given a full settings instance When toJson and fromJson Then preserves all fields in the JSON roundtrip',
      () {
        // Arrange
        final DateTime fetched = DateTime.utc(2025, 2, 1, 14);

        final ModelGroupSettings original = ModelGroupSettings(
          id: 'settings-10',
          groupId: 'group-010',
          googleGroupId: 'PPP-QQQ-RRR',
          whoCanViewGroup: 'ALL_MEMBERS_CAN_VIEW',
          whoCanViewMembership: 'ALL_MEMBERS_CAN_VIEW',
          whoCanJoin: 'INVITED_CAN_JOIN',
          whoCanPostMessage: 'ALL_MEMBERS_CAN_POST',
          messageModerationLevel: 'MODERATE_NONE',
          spamModerationLevel: 'MODERATE',
          includeInGlobalAddressList: true,
          membersCanPostAsTheGroup: true,
          isArchived: false,
          isCollaborativeInbox: true,
          fetchedAt: fetched,
          rawSettings: const <String, dynamic>{
            'whoCanViewGroup': 'ALL_MEMBERS_CAN_VIEW',
            'archiveOnly': false,
            'customFlag': 123,
          },
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelGroupSettings roundtrip = ModelGroupSettings.fromJson(json);

        // Assert (compare JSON, not object identity due to Map equality)
        expect(roundtrip.toJson(), equals(original.toJson()));
        expect(
          roundtrip.rawSettings['customFlag'],
          original.rawSettings['customFlag'],
        );
      },
    );

    test(
      'Given settings without rawSettings in JSON When roundtrip Then rawSettings is preserved as empty map',
      () {
        // Arrange
        final DateTime fetched = DateTime.utc(2025, 2, 2, 9);

        final Map<String, dynamic> json = <String, dynamic>{
          ModelGroupSettingsEnum.id.name: 'settings-11',
          ModelGroupSettingsEnum.groupId.name: 'group-011',
          ModelGroupSettingsEnum.googleGroupId.name: 'SSS-TTT-UUU',
          ModelGroupSettingsEnum.whoCanViewGroup.name: 'ALL_MEMBERS_CAN_VIEW',
          ModelGroupSettingsEnum.whoCanViewMembership.name:
              'ALL_MEMBERS_CAN_VIEW',
          ModelGroupSettingsEnum.whoCanJoin.name: 'INVITED_CAN_JOIN',
          ModelGroupSettingsEnum.whoCanPostMessage.name: 'ALL_MEMBERS_CAN_POST',
          ModelGroupSettingsEnum.messageModerationLevel.name: 'MODERATE_NONE',
          ModelGroupSettingsEnum.spamModerationLevel.name: 'MODERATE',
          ModelGroupSettingsEnum.includeInGlobalAddressList.name: true,
          ModelGroupSettingsEnum.membersCanPostAsTheGroup.name: false,
          ModelGroupSettingsEnum.isArchived.name: false,
          ModelGroupSettingsEnum.isCollaborativeInbox.name: false,
          ModelGroupSettingsEnum.fetchedAt.name:
              DateUtils.dateTimeToString(fetched),
        };

        // Act
        final ModelGroupSettings settings = ModelGroupSettings.fromJson(json);
        final Map<String, dynamic> outJson = settings.toJson();

        // Assert
        expect(settings.rawSettings, isEmpty);
        expect(
          outJson[ModelGroupSettingsEnum.rawSettings.name],
          isA<Map<String, dynamic>>(),
        );
      },
    );
  });

  group('ModelGroupSettings.copyWith', () {
    test(
      'Given a settings instance When copyWith overrides some fields Then returns a new instance with updated values',
      () {
        // Arrange
        final DateTime fetched = DateTime.utc(2025, 3, 1, 10);
        final DateTime newFetched = DateTime.utc(2025, 3, 2, 10);

        final ModelGroupSettings original = ModelGroupSettings(
          id: 'settings-20',
          groupId: 'group-020',
          googleGroupId: 'VVV-WWW-XXX',
          whoCanViewGroup: 'ALL_MEMBERS_CAN_VIEW',
          whoCanViewMembership: 'ALL_MEMBERS_CAN_VIEW',
          whoCanJoin: 'INVITED_CAN_JOIN',
          whoCanPostMessage: 'ALL_MEMBERS_CAN_POST',
          messageModerationLevel: 'MODERATE_NONE',
          spamModerationLevel: 'MODERATE',
          includeInGlobalAddressList: true,
          membersCanPostAsTheGroup: false,
          isArchived: false,
          isCollaborativeInbox: true,
          fetchedAt: fetched,
          rawSettings: const <String, dynamic>{
            'flag': true,
          },
        );

        // Act
        final ModelGroupSettings copy = original.copyWith(
          whoCanViewGroup: 'OWNERS_ONLY',
          isArchived: true,
          fetchedAt: newFetched,
          rawSettings: <String, dynamic>{
            'flag': false,
            'extra': 'value',
          },
        );

        // Assert
        expect(copy.id, original.id);
        expect(copy.groupId, original.groupId);
        expect(copy.googleGroupId, original.googleGroupId);

        expect(copy.whoCanViewGroup, 'OWNERS_ONLY');
        expect(copy.isArchived, isTrue);
        expect(copy.fetchedAt, newFetched);

        expect(copy.rawSettings['flag'], isFalse);
        expect(copy.rawSettings['extra'], 'value');
      },
    );

    test(
      'Given a settings instance When copyWith is called with no parameters Then returns an equal instance',
      () {
        // Arrange
        final DateTime fetched = DateTime.utc(2025, 3, 3, 11);

        final ModelGroupSettings original = ModelGroupSettings(
          id: 'settings-21',
          groupId: 'group-021',
          googleGroupId: 'YYY-ZZZ-AAA',
          whoCanViewGroup: 'ALL_MEMBERS_CAN_VIEW',
          whoCanViewMembership: 'ALL_MEMBERS_CAN_VIEW',
          whoCanJoin: 'INVITED_CAN_JOIN',
          whoCanPostMessage: 'ALL_MEMBERS_CAN_POST',
          messageModerationLevel: 'MODERATE_NONE',
          spamModerationLevel: 'MODERATE',
          includeInGlobalAddressList: true,
          membersCanPostAsTheGroup: false,
          isArchived: false,
          isCollaborativeInbox: false,
          fetchedAt: fetched,
          rawSettings: const <String, dynamic>{'flag': true},
        );

        // Act
        final ModelGroupSettings copy = original.copyWith();

        // Assert
        expect(copy.toJson(), equals(original.toJson()));
        expect(copy.hashCode, equals(original.hashCode));
        expect(copy.toString(), equals(original.toString()));
      },
    );
  });
}
