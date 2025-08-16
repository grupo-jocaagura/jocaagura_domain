part of '../../../jocaagura_domain.dart';

/// Repository boundary for connectivity features.
///
/// Adds policies/caching if required (kept minimal here). It keeps the domain
/// free from service details.
abstract class RepositoryConnectivity {
  Future<Either<ErrorItem, ConnectivityModel>> snapshot();
  Stream<Either<ErrorItem, ConnectivityModel>> watch();
  Future<Either<ErrorItem, ConnectivityModel>> checkType();
  Future<Either<ErrorItem, ConnectivityModel>> checkSpeed();
  ConnectivityModel current();
}
