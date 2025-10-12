part of 'package:jocaagura_domain/jocaagura_domain.dart';

enum ModelAppVersionEnum {
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
///
/// Guarantees:
/// - Instances are **immutable**: all fields are `final`; `meta` is wrapped with
///   `Map.unmodifiable`; `buildAt` is normalized to **UTC** on construction.
/// - JSON round-trip safety: `toJson()` and `fromJson(...)` preserve values,
///   coercing `buildAt` to UTC and normalizing `meta` keys via `Utils.mapFromDynamic`.
///
/// Equality & hashing:
/// - `==` compares all scalar fields and uses `Utils.deepEqualsMap` for `meta`.
/// - `hashCode` mixes all scalars and uses `Utils.deepHash(meta)` for deep hashing.
///   If `a == b`, then `a.hashCode == b.hashCode`.
///
/// Contracts & notes:
/// - `version` is expected to be a SemVer string (not validated here).
/// - `platform`/`channel` are free strings (e.g., `android`/`dev`).
/// - `buildNumber` is monotonic and non-negative in typical pipelines.
/// - `buildAt` must be a valid `DateTime`; it is stored as **UTC**.
/// - `meta` is a JSON-like map (string-keyed); raw maps will be normalized.
///
/// Minimal example:
/// ```dart
/// void main() {
///   final ModelAppVersion v = ModelAppVersion(
///     id: '42',
///     appName: 'Pixel',
///     version: '1.2.3',
///     buildNumber: 1203,
///     platform: 'android',
///     channel: 'prod',
///     buildAt: DateTime.now().toUtc(),
///     meta: <String, dynamic>{'commit': 'abc123', 'size': 4200},
///   );
///   final Map<String, dynamic> json = v.toJson();
///   final ModelAppVersion back = ModelAppVersion.fromJson(json);
///   assert(v == back);
/// }
/// ```
class ModelAppVersion extends Model {
  ModelAppVersion({
    required this.id,
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.channel,
    required DateTime buildAt,
    this.minSupportedVersion = '',
    this.forceUpdate = false,
    this.artifactUrl = '',
    this.changelogUrl = '',
    this.commitSha = '',
    Map<String, dynamic> meta = const <String, dynamic>{},
  })  : buildAt = buildAt.isUtc ? buildAt : buildAt.toUtc(),
        meta = Map<String, dynamic>.unmodifiable(meta);

  /// Creates an instance from a JSON-like map.
  ///
  /// Behavior:
  /// - Uses `Utils.get*` helpers for robust parsing of scalars.
  /// - `buildAt` is parsed via `DateUtils.dateTimeFromDynamic` and normalized to UTC.
  /// - `meta` is normalized to a string-keyed map via `Utils.mapFromDynamic`.
  ///
  /// Never throws for unknown keys; missing values default to constructor defaults.
  /// Invalid `buildAt` values are delegated to `DateUtils.dateTimeFromDynamic`.
  factory ModelAppVersion.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> jsonCopy = Map<String, dynamic>.from(json);
    final DateTime dt = DateUtils.dateTimeFromDynamic(
      jsonCopy[ModelAppVersionEnum.buildAt.name],
    );
    final DateTime buildAtUtc = dt.isUtc ? dt : dt.toUtc();

    return ModelAppVersion(
      id: Utils.getStringFromDynamic(jsonCopy[ModelAppVersionEnum.id.name]),
      appName: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVersionEnum.appName.name],
      ),
      version: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVersionEnum.version.name],
      ),
      buildNumber: Utils.getIntegerFromDynamic(
        jsonCopy[ModelAppVersionEnum.buildNumber.name],
      ),
      platform: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVersionEnum.platform.name],
      ),
      channel: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVersionEnum.channel.name],
      ),
      minSupportedVersion: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVersionEnum.minSupportedVersion.name],
      ),
      forceUpdate: Utils.getBoolFromDynamic(
        jsonCopy[ModelAppVersionEnum.forceUpdate.name],
      ),
      artifactUrl: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVersionEnum.artifactUrl.name],
      ),
      changelogUrl: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVersionEnum.changelogUrl.name],
      ),
      commitSha: Utils.getStringFromDynamic(
        jsonCopy[ModelAppVersionEnum.commitSha.name],
      ),
      buildAt: buildAtUtc,
      meta: Utils.mapFromDynamic(jsonCopy[ModelAppVersionEnum.meta.name]),
    );
  }

  final String id;
  final String appName;
  final String version; // SemVer string
  final int buildNumber; // Monotonic build number
  final String platform; // 'android' | 'ios' | 'web' | ...
  final String channel; // 'dev' | 'beta' | 'prod' | ...
  final String minSupportedVersion;
  final bool forceUpdate;
  final String artifactUrl;
  final String changelogUrl;
  final String commitSha;
  final DateTime buildAt; // UTC
  final Map<String, dynamic> meta;

  static final ModelAppVersion defaultModelAppVersion = ModelAppVersion(
    id: 'default',
    appName: 'app',
    version: '0.0.0',
    buildNumber: 0,
    platform: 'shared',
    channel: 'dev',
    buildAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );

  /// Returns a copy with selected fields replaced.
  ///
  /// `meta` is wrapped with `Map.unmodifiable` to preserve immutability.
  /// If `buildAt` is provided, it is stored as-is; ensure it is UTC if required.
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

  /// Serializes the model into a JSON map.
  ///
  /// Notes:
  /// - `buildAt` is emitted as a string using `DateUtils.dateTimeToString(buildAt.toUtc())`.
  /// - `meta` is emitted as stored (string-keyed, unmodifiable at runtime).
  ///
  /// Consumers should not mutate the returned map for long-lived sharing.
  /// If mutation is needed, clone it first.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelAppVersionEnum.id.name: id,
        ModelAppVersionEnum.appName.name: appName,
        ModelAppVersionEnum.version.name: version,
        ModelAppVersionEnum.buildNumber.name: buildNumber,
        ModelAppVersionEnum.platform.name: platform,
        ModelAppVersionEnum.channel.name: channel,
        ModelAppVersionEnum.minSupportedVersion.name: minSupportedVersion,
        ModelAppVersionEnum.forceUpdate.name: forceUpdate,
        ModelAppVersionEnum.artifactUrl.name: artifactUrl,
        ModelAppVersionEnum.changelogUrl.name: changelogUrl,
        ModelAppVersionEnum.commitSha.name: commitSha,
        ModelAppVersionEnum.buildAt.name:
            DateUtils.dateTimeToString(buildAt.toUtc()),
        ModelAppVersionEnum.meta.name: meta,
      };

  /// Two instances are equal when all scalar fields match, `buildAt` represents
  /// the same instant (`isAtSameMomentAs`) and `meta` is deep-equal via
  /// `Utils.deepEqualsMap`.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
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

  /// Mixes all scalar fields plus a deep hash of `meta`.
  ///
  /// Guarantee: if `a == b`, then `a.hashCode == b.hashCode`.
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
        Utils.deepHash(meta),
      );
}
