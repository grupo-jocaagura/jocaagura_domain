part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// ===========================================================================
/// GROUP SETTINGS
/// ===========================================================================

enum ModelGroupSettingsEnum {
  id,
  groupId,
  googleGroupId,
  whoCanViewGroup,
  whoCanViewMembership,
  whoCanJoin,
  whoCanPostMessage,
  messageModerationLevel,
  spamModerationLevel,
  includeInGlobalAddressList,
  membersCanPostAsTheGroup,
  isArchived,
  isCollaborativeInbox,
  rawSettings,
  fetchedAt,
}

/// Snapshot of provider-specific settings for a group.
class ModelGroupSettings extends Model {
  const ModelGroupSettings({
    required this.id,
    required this.groupId,
    required this.googleGroupId,
    required this.whoCanViewGroup,
    required this.whoCanViewMembership,
    required this.whoCanJoin,
    required this.whoCanPostMessage,
    required this.messageModerationLevel,
    required this.spamModerationLevel,
    required this.includeInGlobalAddressList,
    required this.membersCanPostAsTheGroup,
    required this.isArchived,
    required this.isCollaborativeInbox,
    required this.fetchedAt,
    this.rawSettings,
  });

  factory ModelGroupSettings.fromJson(Map<String, dynamic> json) {
    return ModelGroupSettings(
      id: json[ModelGroupSettingsEnum.id.name]?.toString() ?? '',
      groupId: json[ModelGroupSettingsEnum.groupId.name]?.toString() ?? '',
      googleGroupId:
          json[ModelGroupSettingsEnum.googleGroupId.name]?.toString() ?? '',
      whoCanViewGroup:
          json[ModelGroupSettingsEnum.whoCanViewGroup.name]?.toString() ?? '',
      whoCanViewMembership:
          json[ModelGroupSettingsEnum.whoCanViewMembership.name]?.toString() ??
              '',
      whoCanJoin:
          json[ModelGroupSettingsEnum.whoCanJoin.name]?.toString() ?? '',
      whoCanPostMessage:
          json[ModelGroupSettingsEnum.whoCanPostMessage.name]?.toString() ?? '',
      messageModerationLevel:
          json[ModelGroupSettingsEnum.messageModerationLevel.name]
                  ?.toString() ??
              '',
      spamModerationLevel:
          json[ModelGroupSettingsEnum.spamModerationLevel.name]?.toString() ??
              '',
      includeInGlobalAddressList: Utils.getBoolFromDynamic(
        json[ModelGroupSettingsEnum.includeInGlobalAddressList.name],
        defaultValueIfNull: true,
      ),
      membersCanPostAsTheGroup: Utils.getBoolFromDynamic(
        json[ModelGroupSettingsEnum.membersCanPostAsTheGroup.name],
        defaultValueIfNull: false,
      ),
      isArchived: Utils.getBoolFromDynamic(
        json[ModelGroupSettingsEnum.isArchived.name],
        defaultValueIfNull: false,
      ),
      isCollaborativeInbox: Utils.getBoolFromDynamic(
        json[ModelGroupSettingsEnum.isCollaborativeInbox.name],
        defaultValueIfNull: false,
      ),
      rawSettings: json[ModelGroupSettingsEnum.rawSettings.name] == null
          ? null
          : Utils.mapFromDynamic(
              json[ModelGroupSettingsEnum.rawSettings.name],
            ).cast<String, dynamic>(),
      fetchedAt: DateUtils.dateTimeFromDynamic(
        json[ModelGroupSettingsEnum.fetchedAt.name],
      ),
    );
  }

  final String id;
  final String groupId;
  final String googleGroupId;
  final String whoCanViewGroup;
  final String whoCanViewMembership;
  final String whoCanJoin;
  final String whoCanPostMessage;
  final String messageModerationLevel;
  final String spamModerationLevel;
  final bool includeInGlobalAddressList;
  final bool membersCanPostAsTheGroup;
  final bool isArchived;
  final bool isCollaborativeInbox;
  final Map<String, dynamic>? rawSettings;
  final DateTime fetchedAt;

  @override
  ModelGroupSettings copyWith({
    String? id,
    String? groupId,
    String? googleGroupId,
    String? whoCanViewGroup,
    String? whoCanViewMembership,
    String? whoCanJoin,
    String? whoCanPostMessage,
    String? messageModerationLevel,
    String? spamModerationLevel,
    bool? includeInGlobalAddressList,
    bool? membersCanPostAsTheGroup,
    bool? isArchived,
    bool? isCollaborativeInbox,
    Map<String, dynamic>? rawSettings,
    bool? Function()? rawSettingsOverrideNull,
    DateTime? fetchedAt,
  }) {
    return ModelGroupSettings(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      googleGroupId: googleGroupId ?? this.googleGroupId,
      whoCanViewGroup: whoCanViewGroup ?? this.whoCanViewGroup,
      whoCanViewMembership: whoCanViewMembership ?? this.whoCanViewMembership,
      whoCanJoin: whoCanJoin ?? this.whoCanJoin,
      whoCanPostMessage: whoCanPostMessage ?? this.whoCanPostMessage,
      messageModerationLevel:
          messageModerationLevel ?? this.messageModerationLevel,
      spamModerationLevel: spamModerationLevel ?? this.spamModerationLevel,
      includeInGlobalAddressList:
          includeInGlobalAddressList ?? this.includeInGlobalAddressList,
      membersCanPostAsTheGroup:
          membersCanPostAsTheGroup ?? this.membersCanPostAsTheGroup,
      isArchived: isArchived ?? this.isArchived,
      isCollaborativeInbox: isCollaborativeInbox ?? this.isCollaborativeInbox,
      rawSettings: rawSettingsOverrideNull != null
          ? null
          : rawSettings ?? this.rawSettings,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelGroupSettingsEnum.id.name: id,
      ModelGroupSettingsEnum.groupId.name: groupId,
      ModelGroupSettingsEnum.googleGroupId.name: googleGroupId,
      ModelGroupSettingsEnum.whoCanViewGroup.name: whoCanViewGroup,
      ModelGroupSettingsEnum.whoCanViewMembership.name: whoCanViewMembership,
      ModelGroupSettingsEnum.whoCanJoin.name: whoCanJoin,
      ModelGroupSettingsEnum.whoCanPostMessage.name: whoCanPostMessage,
      ModelGroupSettingsEnum.messageModerationLevel.name:
          messageModerationLevel,
      ModelGroupSettingsEnum.spamModerationLevel.name: spamModerationLevel,
      ModelGroupSettingsEnum.includeInGlobalAddressList.name:
          includeInGlobalAddressList,
      ModelGroupSettingsEnum.membersCanPostAsTheGroup.name:
          membersCanPostAsTheGroup,
      ModelGroupSettingsEnum.isArchived.name: isArchived,
      ModelGroupSettingsEnum.isCollaborativeInbox.name: isCollaborativeInbox,
      ModelGroupSettingsEnum.fetchedAt.name:
          DateUtils.dateTimeToString(fetchedAt),
    };
    if (rawSettings != null) {
      json[ModelGroupSettingsEnum.rawSettings.name] = rawSettings;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelGroupSettings &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          googleGroupId == other.googleGroupId &&
          whoCanViewGroup == other.whoCanViewGroup &&
          whoCanViewMembership == other.whoCanViewMembership &&
          whoCanJoin == other.whoCanJoin &&
          whoCanPostMessage == other.whoCanPostMessage &&
          messageModerationLevel == other.messageModerationLevel &&
          spamModerationLevel == other.spamModerationLevel &&
          includeInGlobalAddressList == other.includeInGlobalAddressList &&
          membersCanPostAsTheGroup == other.membersCanPostAsTheGroup &&
          isArchived == other.isArchived &&
          isCollaborativeInbox == other.isCollaborativeInbox &&
          rawSettings == other.rawSettings &&
          fetchedAt == other.fetchedAt;

  @override
  int get hashCode => Object.hash(
        id,
        groupId,
        googleGroupId,
        whoCanViewGroup,
        whoCanViewMembership,
        whoCanJoin,
        whoCanPostMessage,
        messageModerationLevel,
        spamModerationLevel,
        includeInGlobalAddressList,
        membersCanPostAsTheGroup,
        isArchived,
        isCollaborativeInbox,
        rawSettings,
        fetchedAt,
      );

  @override
  String toString() => 'ModelGroupSettings(${toJson()})';
}
