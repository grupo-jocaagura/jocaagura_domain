part of 'package:jocaagura_domain/jocaagura_domain.dart';

abstract class BlocAclInterface extends BlocModule {
  /// Returns the ACL for a feature if present in memory/cache.
  ///
  /// Contract:
  /// - Never throws.
  /// - Returns `null` when the feature is not present.
  ModelAcl? findAcl(String feature);

  /// Upserts an ACL.
  ///
  /// Contract:
  /// - On success, returns the persisted ACL.
  /// - On failure, returns an [ErrorItem] describing why.
  Future<Either<ErrorItem, ModelAcl>> upsertAcl(ModelAcl acl);

  /// Fetches all ACLs for a user (source-of-truth is implementation-defined).
  ///
  /// Contract:
  /// - The returned map is keyed by `featureKey` (see [featureKey]).
  /// - On failure, returns an [ErrorItem].
  Future<Either<ErrorItem, Map<String, ModelAcl>>> getAllAcls(String email);

  /// Canonical key for feature indexing.
  ///
  /// This is intentionally simple to keep consistency across implementations.
  String featureKey(String feature) => feature.trim().toLowerCase();

  /// Returns the role for a feature if present; otherwise `RoleType.viewer`.
  ///
  /// Contract:
  /// - Never throws.
  /// - Must be deterministic for the same input.
  ///
  /// Default behavior uses [findAcl] + [featureKey].
  RoleType resolveRoleType(String feature) {
    final String key = featureKey(feature);
    final ModelAcl? acl = findAcl(key);
    return acl?.roleType ?? RoleType.viewer;
  }

  /// Returns true when there is an ACL for `feature` and it is trusted.
  bool canTrust(String feature) {
    final String key = featureKey(feature);
    final ModelAcl? acl = findAcl(key);
    return acl != null && acl.isValidAcl;
  }

  /// Returns true when current role is >= [minRole].
  bool hasAtLeast(String feature, RoleType minRole) {
    final RoleType current = resolveRoleType(feature);
    return _rank(current) >= _rank(minRole);
  }

  int _rank(RoleType r) {
    switch (r) {
      case RoleType.viewer:
        return 0;
      case RoleType.editor:
        return 1;
      case RoleType.admin:
        return 2;
    }
  }
}
