part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Contract for BLoC modules that manage [ModelAppVersion] state and persistence.
///
/// Goals:
/// - Keep implementations flexible (Sheets, REST, local cache, etc.).
/// - Provide a consistent minimum API across projects.
/// - Avoid forcing any specific storage, stream, or caching strategy.
abstract class BlocAppVersionInterface extends BlocModule {
  /// Returns the app version for the given [id] if present in memory/cache.
  ///
  /// Contract:
  /// - Never throws.
  /// - Returns `null` when the item is not present.
  ModelAppVersion? findById(String id);

  /// Returns a version by logical key if present in memory/cache.
  ///
  /// Common usage is to index by `appName/platform/channel`, but implementations
  /// may choose a different strategy as long as they are deterministic.
  ///
  /// Contract:
  /// - Never throws.
  /// - Returns `null` when the item is not present.
  ModelAppVersion? findByKey({
    required String appName,
    required String platform,
    required String channel,
  });

  /// Fetches all versions for a given [appName].
  ///
  /// Source-of-truth is implementation-defined (remote, local, mixed).
  ///
  /// Contract:
  /// - Never throws.
  /// - On failure returns an [ErrorItem].
  Future<Either<ErrorItem, List<ModelAppVersion>>> listByAppName(
    String appName,
  );

  /// Fetches all versions, optionally filtered.
  ///
  /// Contract:
  /// - Never throws.
  /// - On failure returns an [ErrorItem].
  Future<Either<ErrorItem, List<ModelAppVersion>>> listAll({
    String appName = '',
    String platform = '',
    String channel = '',
  });

  /// Creates or updates a version entry.
  ///
  /// Contract:
  /// - On success returns the persisted model (may include server-generated fields).
  /// - On failure returns an [ErrorItem].
  Future<Either<ErrorItem, ModelAppVersion>> upsert(ModelAppVersion model);

  /// Reads a version by [id] from the source-of-truth.
  ///
  /// Contract:
  /// - On success returns the model.
  /// - On failure returns an [ErrorItem] (including "not found").
  Future<Either<ErrorItem, ModelAppVersion>> readById(String id);

  /// Deletes a version by [id].
  ///
  /// Contract:
  /// - On success returns `true`.
  /// - On failure returns an [ErrorItem].
  Future<Either<ErrorItem, bool>> deleteById(String id);

  /// Canonical key used to index versions consistently across implementations.
  ///
  /// This is intentionally simple to keep consistency across consumers.
  String versionKey({
    required String appName,
    required String platform,
    required String channel,
  }) =>
      '${appName.trim().toLowerCase()}::'
      '${platform.trim().toLowerCase()}::'
      '${channel.trim().toLowerCase()}';

  /// Convenience helper: returns the latest version among [items] by [buildNumber].
  ///
  /// Contract:
  /// - Returns `null` if [items] is empty.
  /// - Never throws.
  ModelAppVersion? latestByBuildNumber(List<ModelAppVersion> items) {
    if (items.isEmpty) {
      return null;
    }

    ModelAppVersion best = items.first;
    for (final ModelAppVersion candidate in items.skip(1)) {
      if (candidate.buildNumber > best.buildNumber) {
        best = candidate;
      }
    }
    return best;
  }

  /// Determines whether the app should force an update based on version data.
  ///
  /// Strategy (intentionally minimal and deterministic):
  /// 1) If [latest.forceUpdate] is `true` and `latest.buildNumber > current.buildNumber`,
  ///    returns `true`.
  /// 2) If [minSupportedBuildNumber] is provided (>= 0) and
  ///    `current.buildNumber < minSupportedBuildNumber`, returns `true`.
  /// 3) Otherwise returns `false`.
  ///
  /// Notes:
  /// - This avoids SemVer parsing to keep the domain lightweight.
  /// - Implementations may still choose to incorporate SemVer checks externally.
  bool shouldForceUpdate({
    required ModelAppVersion current,
    required ModelAppVersion latest,
    int minSupportedBuildNumber = -1,
  }) {
    final bool isOutdated = latest.buildNumber > current.buildNumber;
    if (latest.forceUpdate && isOutdated) {
      return true;
    }

    if (minSupportedBuildNumber >= 0 &&
        current.buildNumber < minSupportedBuildNumber) {
      return true;
    }

    return false;
  }

  /// Attempts to parse a SemVer-like string into (major, minor, patch).
  ///
  /// Accepts: "1", "1.2", "1.2.3", optionally with suffixes like "-beta" or "+1".
  /// Returns `null` when it cannot parse a valid numeric trio.
  ///
  /// This helper is private-by-convention (no underscore because interface),
  /// but implementations should treat it as internal.
  List<int>? tryParseSemVer(String value) {
    final String core = value.trim().split('-').first.split('+').first;
    final List<String> parts = core.split('.');
    if (parts.isEmpty) {
      return null;
    }

    int parseAt(int i) {
      if (i >= parts.length) {
        return 0;
      }
      final int? v = int.tryParse(parts[i]);
      return v ?? -1;
    }

    final int major = parseAt(0);
    final int minor = parseAt(1);
    final int patch = parseAt(2);

    if (major < 0 || minor < 0 || patch < 0) {
      return null;
    }

    return <int>[major, minor, patch];
  }

  /// Optional SemVer-based force-update check (still minimal).
  ///
  /// Rule:
  /// - If [latest.forceUpdate] is true AND latest.version > current.version (SemVer),
  ///   returns true. If SemVer parsing fails, falls back to buildNumber.
  bool shouldForceUpdateBySemVerOrBuildNumber({
    required ModelAppVersion current,
    required ModelAppVersion latest,
  }) {
    final List<int>? c = tryParseSemVer(current.version);
    final List<int>? l = tryParseSemVer(latest.version);

    bool newerBySemVer(List<int> a, List<int> b) {
      for (int i = 0; i < 3; i++) {
        if (a[i] != b[i]) {
          return a[i] > b[i];
        }
      }
      return false;
    }

    final bool isNewer = (l != null && c != null)
        ? newerBySemVer(l, c)
        : (latest.buildNumber > current.buildNumber);

    return latest.forceUpdate && isNewer;
  }
}
