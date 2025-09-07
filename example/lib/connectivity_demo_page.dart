import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

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

/// Connectivity **Demo Page** — reference wiring for the full stack without external packages.
///
/// ### Purpose
/// - Show how UI consumes a **pure** `BlocConnectivity` that emits `Either<ErrorItem, ConnectivityModel>`.
/// - Demonstrate the **proposed flow** and separation of responsibilities (Clean Architecture):
///
/// ```text
/// UI → AppManager → Bloc → UseCase → Repository → Gateway → Service
/// ```
///
/// ### Design notes
/// - **The BLoC does not know about UI**: it never throws nor shows SnackBars.
/// - **Errors travel as domain data**: `Left(ErrorItem)`; the UI decides how to present them.
/// - We wrap the content in an `ErrorItemWidget` that centralizes UX for errors (SnackBar/Banner).
/// - This demo uses `FakeServiceConnectivity` for dev/testing. In production, replace it with a
///   real `ServiceConnectivity` backed by the platform (plugins/SDKs).
///
/// ### Lifecycle essentials
/// - Call `loadInitial()` once to fetch the first snapshot.
/// - Call `startWatching()` to subscribe to updates; `stopWatching()` on dispose/background.
/// - Always call `dispose()` on the BLoC and on the Service if it holds resources.
///
/// ### Why this matters
/// - Keeps **domain/UI decoupled**, simplifies testing, and prevents side-effects from leaking into logic.
/// - Uniform error semantics via `ErrorItem` across all modules in Jocaagura.
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
    // 1) Service (dev/test fake). In production: provide a real ServiceConnectivity
    _service = FakeServiceConnectivity(
      latencyConnectivity: const Duration(milliseconds: 80),
      latencySpeed: const Duration(milliseconds: 120),
      initial: const ConnectivityModel(
        connectionType: ConnectionTypeEnum.wifi,
        internetSpeed: 40,
      ),
    );
    // 2) Gateway: converts Service → raw payload (Map) and wraps exceptions as ErrorItem
    _gateway = GatewayConnectivityImpl(_service, const DefaultErrorMapper());
    // 3) Repository: maps payload → ConnectivityModel, detects business errors via ErrorMapper
    _repo = RepositoryConnectivityImpl(
      _gateway,
      errorMapper: const DefaultErrorMapper(),
    );
    // 4) Bloc: exposes Stream<Either<ErrorItem, ConnectivityModel>> to the UI (pure, no UI side-effects)
    _bloc = BlocConnectivity(
      watch: WatchConnectivityUseCase(_repo),
      snapshot: GetConnectivitySnapshotUseCase(_repo),
      checkType: CheckConnectivityTypeUseCase(_repo),
      checkSpeed: CheckInternetSpeedUseCase(_repo),
    );
    // Fetch initial snapshot once
    _bloc.loadInitial();
    // Start continuous updates — remember to stop on dispose in real screens
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
          // Either coming from the BLoC (no exceptions thrown)
          final Either<ErrorItem, ConnectivityModel> either =
              snap.data ?? _bloc.value;
          final ConnectivityModel m = either.isRight
              ? (either as Right<ErrorItem, ConnectivityModel>).value
              : _lastGood; // keep last good model when Left

          if (either.isRight) {
            _lastGood = (either as Right<ErrorItem, ConnectivityModel>).value;
          }

          // Handle Either<ErrorItem, ConnectivityModel> from the BLoC:
          // - Right → render UI with latest ConnectivityModel
          // - Left  → ErrorItemWidget emits UX (SnackBar/Banner) but we keep last good UI state
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
