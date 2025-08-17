import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class _RepoStub implements RepositoryConnectivity {
  _RepoStub({
    required this.snapshotResult,
    required this.typeResult,
    required this.speedResult,
  });
  Either<ErrorItem, ConnectivityModel> snapshotResult;
  Either<ErrorItem, ConnectivityModel> typeResult;
  Either<ErrorItem, ConnectivityModel> speedResult;
  final StreamController<Either<ErrorItem, ConnectivityModel>> _ctrl =
      StreamController<Either<ErrorItem, ConnectivityModel>>.broadcast();

  void emit(Either<ErrorItem, ConnectivityModel> e) => _ctrl.add(e);

  @override
  Future<Either<ErrorItem, ConnectivityModel>> snapshot() async =>
      snapshotResult;
  @override
  Stream<Either<ErrorItem, ConnectivityModel>> watch() => _ctrl.stream;
  @override
  Future<Either<ErrorItem, ConnectivityModel>> checkType() async => typeResult;
  @override
  Future<Either<ErrorItem, ConnectivityModel>> checkSpeed() async =>
      speedResult;
  @override
  ConnectivityModel current() =>
      (snapshotResult as Right<ErrorItem, ConnectivityModel>).value;
}

void main() {
  group('BlocConnectivity', () {
    const ConnectivityModel initial = ConnectivityModel(
      connectionType: ConnectionTypeEnum.wifi,
      internetSpeed: 40,
    );
    const ConnectivityModel other = ConnectivityModel(
      connectionType: ConnectionTypeEnum.mobile,
      internetSpeed: 12,
    );
    const ErrorItem err = ErrorItem(
      title: 'err',
      code: 'E',
      description: 'x',
      errorLevel: ErrorLevelEnum.severe,
    );

    test('loadInitial sets Right', () async {
      final _RepoStub repo = _RepoStub(
        snapshotResult: Right<ErrorItem, ConnectivityModel>(initial),
        typeResult: Right<ErrorItem, ConnectivityModel>(initial),
        speedResult: Right<ErrorItem, ConnectivityModel>(initial),
      );
      final BlocConnectivity bloc = BlocConnectivity(
        watch: WatchConnectivityUseCase(repo),
        snapshot: GetConnectivitySnapshotUseCase(repo),
        checkType: CheckConnectivityTypeUseCase(repo),
        checkSpeed: CheckInternetSpeedUseCase(repo),
      );
      await bloc.loadInitial();
      expect(bloc.value.isRight, isTrue);
      final ConnectivityModel m =
          (bloc.value as Right<ErrorItem, ConnectivityModel>).value;
      expect(m, initial);
      bloc.dispose();
    });

    test('startWatching propagates Right and Left', () async {
      final _RepoStub repo = _RepoStub(
        snapshotResult: Right<ErrorItem, ConnectivityModel>(initial),
        typeResult: Right<ErrorItem, ConnectivityModel>(initial),
        speedResult: Right<ErrorItem, ConnectivityModel>(initial),
      );
      final BlocConnectivity bloc = BlocConnectivity(
        watch: WatchConnectivityUseCase(repo),
        snapshot: GetConnectivitySnapshotUseCase(repo),
        checkType: CheckConnectivityTypeUseCase(repo),
        checkSpeed: CheckInternetSpeedUseCase(repo),
      );
      bloc.startWatching();
      repo.emit(Right<ErrorItem, ConnectivityModel>(other));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect((bloc.value as Right<ErrorItem, ConnectivityModel>).value, other);

      repo.emit(Left<ErrorItem, ConnectivityModel>(err));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(bloc.value.isLeft, isTrue);

      bloc.dispose();
    });

    test('refreshType/refreshSpeed update value', () async {
      final _RepoStub repo = _RepoStub(
        snapshotResult: Right<ErrorItem, ConnectivityModel>(initial),
        typeResult: Right<ErrorItem, ConnectivityModel>(other),
        speedResult: Right<ErrorItem, ConnectivityModel>(other),
      );
      final BlocConnectivity bloc = BlocConnectivity(
        watch: WatchConnectivityUseCase(repo),
        snapshot: GetConnectivitySnapshotUseCase(repo),
        checkType: CheckConnectivityTypeUseCase(repo),
        checkSpeed: CheckInternetSpeedUseCase(repo),
      );
      await bloc.refreshType();
      expect((bloc.value as Right<ErrorItem, ConnectivityModel>).value, other);
      await bloc.refreshSpeed();
      expect((bloc.value as Right<ErrorItem, ConnectivityModel>).value, other);
      bloc.dispose();
    });

    test('stopWatching prevents further updates', () async {
      final _RepoStub repo = _RepoStub(
        snapshotResult: Right<ErrorItem, ConnectivityModel>(initial),
        typeResult: Right<ErrorItem, ConnectivityModel>(initial),
        speedResult: Right<ErrorItem, ConnectivityModel>(initial),
      );
      final BlocConnectivity bloc = BlocConnectivity(
        watch: WatchConnectivityUseCase(repo),
        snapshot: GetConnectivitySnapshotUseCase(repo),
        checkType: CheckConnectivityTypeUseCase(repo),
        checkSpeed: CheckInternetSpeedUseCase(repo),
      );
      bloc.startWatching();
      bloc.stopWatching();
      final Either<ErrorItem, ConnectivityModel> before = bloc.value;
      repo.emit(Right<ErrorItem, ConnectivityModel>(other));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(bloc.value, before);
      bloc.dispose();
    });
  });
}
