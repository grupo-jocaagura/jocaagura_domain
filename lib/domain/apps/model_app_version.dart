part of 'package:jocaagura_domain/jocaagura_domain.dart';

enum ModelAppVErsionEnum {
  id,
  appName,
  version,
  buildNumber,
  platform,
  channel,
  minSupportedVersion,
  forceUpdate,
  artifactUrl,
  changelogUrl,
  commitSha,
  buildAt,
  meta,
}

/// Immutable app version descriptor used across CI/CD and runtime checks.
class ModelAppVersion extends Model {
  const ModelAppVersion({
    required this.id,
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.channel,
    required this.buildAt,
    this.minSupportedVersion,
    this.forceUpdate = false,
    this.artifactUrl = '',
    this.changelogUrl = '',
    this.commitSha = '',
    this.meta = const <String, dynamic>{},
  });

  factory ModelAppVersion.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> jsonCopy = Map<String, dynamic>.from(json);
    return ModelAppVersion(
      id: Utils.getStringFromDynamic(jsonCopy[ModelAppVErsionEnum.id.name]),
      appName: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVErsionEnum.appName.name],
      ),
      version: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVErsionEnum.version.name],
      ),
      buildNumber: Utils.getIntegerFromDynamic(
        jsonCopy[ModelAppVErsionEnum.buildNumber.name],
      ),
      platform: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVErsionEnum.platform.name],
      ),
      channel: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVErsionEnum.channel.name],
      ),
      minSupportedVersion: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVErsionEnum.minSupportedVersion.name],
      ),
      forceUpdate: Utils.getBoolFromDynamic(
        jsonCopy[ModelAppVErsionEnum.forceUpdate.name],
      ),
      artifactUrl: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVErsionEnum.artifactUrl.name],
      ),
      changelogUrl: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVErsionEnum.changelogUrl.name],
      ),
      commitSha: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVErsionEnum.commitSha.name],
      ),
      buildAt: DateUtils.dateTimeFromDynamic(
        jsonCopy[ModelAppVErsionEnum.buildAt.name],
      ),
      meta: Utils.mapFromDynamic(jsonCopy[ModelAppVErsionEnum.meta.name]),
    );
  }

  final String id;
  final String appName;
  final String version; // SemVer string
  final int buildNumber; // Monotonic build number
  final String platform; // 'android' | 'ios' | 'web' | ...
  final String channel; // 'dev' | 'beta' | 'prod' | ...
  final String? minSupportedVersion;
  final bool forceUpdate;
  final String artifactUrl;
  final String changelogUrl;
  final String commitSha;
  final DateTime buildAt; // UTC
  final Map<String, dynamic> meta;

  @override
  ModelAppVersion copyWith({
    String? id,
    String? appName,
    String? version,
    int? buildNumber,
    String? platform,
    String? channel,
    String? minSupportedVersion,
    bool? forceUpdate,
    String? artifactUrl,
    String? changelogUrl,
    String? commitSha,
    DateTime? buildAt,
    Map<String, dynamic>? meta,
  }) =>
      ModelAppVersion(
        id: id ?? this.id,
        appName: appName ?? this.appName,
        version: version ?? this.version,
        buildNumber: buildNumber ?? this.buildNumber,
        platform: platform ?? this.platform,
        channel: channel ?? this.channel,
        minSupportedVersion: minSupportedVersion ?? this.minSupportedVersion,
        forceUpdate: forceUpdate ?? this.forceUpdate,
        artifactUrl: artifactUrl ?? this.artifactUrl,
        changelogUrl: changelogUrl ?? this.changelogUrl,
        commitSha: commitSha ?? this.commitSha,
        buildAt: buildAt ?? this.buildAt,
        meta: Map<String, dynamic>.unmodifiable(meta ?? this.meta),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelAppVErsionEnum.id.name: id,
        ModelAppVErsionEnum.appName.name: appName,
        ModelAppVErsionEnum.version.name: version,
        ModelAppVErsionEnum.buildNumber.name: buildNumber,
        ModelAppVErsionEnum.platform.name: platform,
        ModelAppVErsionEnum.channel.name: channel,
        ModelAppVErsionEnum.minSupportedVersion.name: minSupportedVersion,
        ModelAppVErsionEnum.forceUpdate.name: forceUpdate,
        ModelAppVErsionEnum.artifactUrl.name: artifactUrl,
        ModelAppVErsionEnum.changelogUrl.name: changelogUrl,
        ModelAppVErsionEnum.commitSha.name: commitSha,
        ModelAppVErsionEnum.buildAt.name: DateUtils.dateTimeToString(buildAt),
        ModelAppVErsionEnum.meta.name: meta,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModelAppVersion &&
        other.id == id &&
        other.appName == appName &&
        other.version == version &&
        other.buildNumber == buildNumber &&
        other.platform == platform &&
        other.channel == channel &&
        other.minSupportedVersion == minSupportedVersion &&
        other.forceUpdate == forceUpdate &&
        other.artifactUrl == artifactUrl &&
        other.changelogUrl == changelogUrl &&
        other.commitSha == commitSha &&
        other.buildAt.isAtSameMomentAs(buildAt) &&
        Utils.deepEqualsMap(other.meta, meta);
  }

  @override
  int get hashCode => Object.hash(
        id,
        appName,
        version,
        buildNumber,
        platform,
        channel,
        minSupportedVersion,
        forceUpdate,
        artifactUrl,
        changelogUrl,
        commitSha,
        buildAt.millisecondsSinceEpoch,
        meta.hashCode,
      );
}
