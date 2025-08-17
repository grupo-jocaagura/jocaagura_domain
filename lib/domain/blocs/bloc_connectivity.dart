part of '../../jocaagura_domain.dart';

/// Reactive controller for connectivity state based on [BlocGeneral].
///
/// Responsibilities:
/// - Holds the latest [ConnectivityModel] value.
/// - Starts/stops watching the repository stream.
/// - Exposes imperative refresh helpers when needed.
///
/// ### Example
/// ```dart
/// final bloc = BlocConnectivity(
///   watch: WatchConnectivityUseCase(repo),
///   snapshot: GetConnectivitySnapshotUseCase(repo),
///   checkType: CheckConnectivityTypeUseCase(repo),
///   checkSpeed: CheckInternetSpeedUseCase(repo),
/// );
/// await bloc.loadInitial();
/// bloc.startWatching();
/// // ...
/// bloc.dispose();
/// ```
class BlocConnectivity extends BlocModule {
  BlocConnectivity({
    required WatchConnectivityUseCase watch,
    required GetConnectivitySnapshotUseCase snapshot,
    required CheckConnectivityTypeUseCase checkType,
    required CheckInternetSpeedUseCase checkSpeed,
    ConnectivityModel initial = defaultConnectivityModel,
  })  : _watch = watch,
        _snapshot = snapshot,
        _checkType = checkType,
        _checkSpeed = checkSpeed,
        _state = BlocGeneral<Either<ErrorItem, ConnectivityModel>>(
          Right<ErrorItem, ConnectivityModel>(initial),
        );

  final WatchConnectivityUseCase _watch;
  final GetConnectivitySnapshotUseCase _snapshot;
  final CheckConnectivityTypeUseCase _checkType;
  final CheckInternetSpeedUseCase _checkSpeed;

  final BlocGeneral<Either<ErrorItem, ConnectivityModel>> _state;
  StreamSubscription<Either<ErrorItem, ConnectivityModel>>? _sub;

  /// Stream of connectivity states.

  Stream<Either<ErrorItem, ConnectivityModel>> get stream => _state.stream;

  /// Current connectivity state.

  Either<ErrorItem, ConnectivityModel> get value => _state.value;

  /// Loads the initial snapshot and updates state.
  Future<void> loadInitial() async {
    final Either<ErrorItem, ConnectivityModel> res = await _snapshot();
    res.fold((ErrorItem error) {
      _state.value = Left<ErrorItem, ConnectivityModel>(error);
    }, (ConnectivityModel model) {
      _state.value = Right<ErrorItem, ConnectivityModel>(model);
    });
  }

  /// Subscribes to continuous updates.
  void startWatching() {
    _sub?.cancel();
    _sub = _watch().listen((Either<ErrorItem, ConnectivityModel> either) {
      either.fold((ErrorItem e) {
        _state.value = Left<ErrorItem, ConnectivityModel>(e);
      }, (ConnectivityModel model) {
        _state.value = Right<ErrorItem, ConnectivityModel>(model);
      });
    });
  }

  /// Cancels the updates subscription.
  void stopWatching() {
    _sub?.cancel();
    _sub = null;
  }

  /// Imperative refresh of "type" only; merges into current state.
  Future<void> refreshType() async {
    _state.value = await _checkType();
  }

  /// Imperative refresh of "speed" only; merges into current state.
  Future<void> refreshSpeed() async {
    _state.value = await _checkSpeed();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    _state.dispose();
  }
}
