part of '../../../../jocaagura_domain.dart';

/// Returns a fresh combined snapshot of connectivity.
///
/// ### Example
/// ```dart
/// final useCase = GetConnectivitySnapshotUseCase(repo);
/// final Either<ErrorItem, ConnectivityModel> res = await useCase();
/// ```
class GetConnectivitySnapshotUseCase {
  const GetConnectivitySnapshotUseCase(this._repo);
  final RepositoryConnectivity _repo;
  Future<Either<ErrorItem, ConnectivityModel>> call() => _repo.snapshot();
}

/// Emits connectivity updates.
///
/// ### Example
/// ```dart
/// final useCase = WatchConnectivityUseCase(repo);
/// final sub = useCase().listen((either) { /* ... */ });
/// ```
class WatchConnectivityUseCase {
  const WatchConnectivityUseCase(this._repo);
  final RepositoryConnectivity _repo;
  Stream<Either<ErrorItem, ConnectivityModel>> call() => _repo.watch();
}

/// Returns only the connection type.
class CheckConnectivityTypeUseCase {
  const CheckConnectivityTypeUseCase(this._repo);
  final RepositoryConnectivity _repo;
  Future<Either<ErrorItem, ConnectivityModel>> call() => _repo.checkType();
}

/// Returns only the internet speed (Mbps).
class CheckInternetSpeedUseCase {
  const CheckInternetSpeedUseCase(this._repo);
  final RepositoryConnectivity _repo;
  Future<Either<ErrorItem, ConnectivityModel>> call() => _repo.checkSpeed();
}
