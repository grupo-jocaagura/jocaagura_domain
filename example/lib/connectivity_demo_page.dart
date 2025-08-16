import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Simple demo page wiring the whole stack **without external packages**.
///
/// Intended for examples/tests. In production, wire these through your
/// AppManager and DI as per Jocaagura guidelines.
/// Shows a SnackBar (or any UX) when the incoming state is Left(ErrorItem).
/// It de-duplicates the same error by a simple fingerprint.
class ErrorItemWidget extends StatefulWidget {
  const ErrorItemWidget({
    required this.state,
    required this.child,
    super.key,
    this.showAsSnackBar = true,
  });

  final Either<ErrorItem, Object> state;
  final Widget child;
  final bool showAsSnackBar;

  @override
  State<ErrorItemWidget> createState() => _ErrorItemWidgetState();
}

class _ErrorItemWidgetState extends State<ErrorItemWidget> {
  String? _lastFingerprint;

  @override
  void initState() {
    super.initState();
    _maybeNotifyError(widget.state);
  }

  @override
  void didUpdateWidget(covariant ErrorItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _maybeNotifyError(widget.state);
    }
  }

  void _maybeNotifyError(Either<ErrorItem, Object> either) {
    if (!either.isLeft) {
      return;
    }
    final ErrorItem e = (either as Left<ErrorItem, Object>).value;
    final String fp = '${e.code}:${e.description.hashCode}';
    if (_lastFingerprint == fp) {
      return;
    }
    _lastFingerprint = fp;

    if (widget.showAsSnackBar && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.title}: ${e.description}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Simple demo page wiring the whole stack **without external packages**.
///
/// Intended for examples/tests. In production, wire these through your
/// AppManager and DI as per Jocaagura guidelines.
class ConnectivityDemoPage extends StatefulWidget {
  const ConnectivityDemoPage({super.key});
  static const String name = 'ConnectivityDemoPage';

  @override
  State<ConnectivityDemoPage> createState() => _ConnectivityDemoPageState();
}

class _ConnectivityDemoPageState extends State<ConnectivityDemoPage> {
  late final FakeServiceConnectivity _service;
  late final GatewayConnectivity _gateway;
  late final RepositoryConnectivity _repo;
  late final BlocConnectivity _bloc;

  ConnectivityModel _lastGood = const ConnectivityModel(
    connectionType: ConnectionTypeEnum.none,
    internetSpeed: 0,
  );

  @override
  void initState() {
    super.initState();
    _service = FakeServiceConnectivity(
      latencyConnectivity: const Duration(milliseconds: 80),
      latencySpeed: const Duration(milliseconds: 120),
      initial: const ConnectivityModel(
        connectionType: ConnectionTypeEnum.wifi,
        internetSpeed: 40,
      ),
    );
    _gateway = GatewayConnectivityImpl(_service, DefaultErrorMapper());
    _repo = RepositoryConnectivityImpl(
      _gateway,
      errorMapper: DefaultErrorMapper(),
    );
    _bloc = BlocConnectivity(
      watch: WatchConnectivityUseCase(_repo),
      snapshot: GetConnectivitySnapshotUseCase(_repo),
      checkType: CheckConnectivityTypeUseCase(_repo),
      checkSpeed: CheckInternetSpeedUseCase(_repo),
    );
    _bloc.loadInitial();
    _bloc.startWatching();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connectivity Demo')),
      body: StreamBuilder<Either<ErrorItem, ConnectivityModel>>(
        stream: _bloc.stream,
        initialData: _bloc.value,
        builder: (
          BuildContext context,
          AsyncSnapshot<Either<ErrorItem, ConnectivityModel>> snap,
        ) {
          final Either<ErrorItem, ConnectivityModel> either =
              snap.data ?? _bloc.value;
          final ConnectivityModel m = either.isRight
              ? (either as Right<ErrorItem, ConnectivityModel>).value
              : _lastGood; // keep last good model when Left

          if (either.isRight) {
            _lastGood = (either as Right<ErrorItem, ConnectivityModel>).value;
          }

          return ErrorItemWidget(
            state: either as Either<ErrorItem, Object>,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Type:  ${m.connectionType.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Speed: ${m.internetSpeed.toStringAsFixed(1)} Mbps'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () => _service
                            .simulateConnection(ConnectionTypeEnum.none),
                        child: const Text('Go Offline'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service
                            .simulateConnection(ConnectionTypeEnum.wifi),
                        child: const Text('Wi‑Fi'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service
                            .simulateConnection(ConnectionTypeEnum.mobile),
                        child: const Text('Mobile'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.simulateSpeed(
                          (((m.internetSpeed + 10).clamp(0.0, 9999.0)) as num)
                              .toDouble(),
                        ),
                        child: const Text('+10 Mbps'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.simulateSpeed(
                          (((m.internetSpeed - 10).clamp(0.0, 9999.0)) as num)
                              .toDouble(),
                        ),
                        child: const Text('−10 Mbps'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.startSpeedJitter(),
                        child: const Text('Start Jitter'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.stopSpeedJitter(),
                        child: const Text('Stop Jitter'),
                      ),
                      ElevatedButton(
                        onPressed: _bloc.refreshType,
                        child: const Text('Refresh Type'),
                      ),
                      ElevatedButton(
                        onPressed: _bloc.refreshSpeed,
                        child: const Text('Refresh Speed'),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          _service.simulateErrorOnCheckConnectivityOnce();
                          _bloc.refreshType();
                        },
                        child: const Text('Sim error: check type'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _service.simulateErrorOnCheckSpeedOnce();
                          _bloc.refreshSpeed();
                        },
                        child: const Text('Sim error: check speed'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _service.simulateStreamErrorOnce();
                          _service.simulateSpeed(
                            m.internetSpeed + 1,
                          ); // trigger next stream event
                        },
                        child: const Text('Sim error: stream'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
