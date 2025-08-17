import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Demo page for `BlocLoading`.
///
/// ## What this page shows
/// - **Single action**: uses `loadingWhile` to run one task with a min visible time,
///   demonstrating anti-flicker UX.
/// - **Queued actions (FIFO)**: uses `queueLoadingWhile` to run 3 tasks in sequence.
///   Each task sets a **progressive message** ("Step 1/3", "Step 2/3", "Step 3/3").
///
/// ## How to wire the Bloc
/// - Preferred: obtain it from your **AppManager** (UI → AppManager → Bloc).
/// - Alternative: inject via constructor or create a local instance (this demo supports both).
///
/// ## Concurrency semantics (important)
/// - `loadingMsgWithFuture`: ignores overlapping calls (visual + execution).
/// - `loadingWhile<T>`: if already loading, **does not override UI** but still **executes** the action and returns its result.
/// - `queueLoadingWhile<T>`: serializes tasks (FIFO). Each task shows its own message.
///
/// UI text is bilingual for clarity to implementers.
class BlocLoadingDemoPage extends StatefulWidget {
  /// Optional injection of an existing BlocLoading.
  const BlocLoadingDemoPage({super.key, this.injected});
  static const String name = 'BlocLoadingDemoPage';

  final BlocLoading? injected;

  @override
  State<BlocLoadingDemoPage> createState() => _BlocLoadingDemoPageState();
}

class _BlocLoadingDemoPageState extends State<BlocLoadingDemoPage> {
  late final BlocLoading _bloc;
  late final bool _ownsBloc;

  // Simple in-page log to visualize execution/order for the queue demo.
  final List<String> _log = <String>[];

  @override
  void initState() {
    super.initState();

    // Preferred (commented): obtain from AppManager when available in your app:
    // _bloc = AppManager.of(context).config.blocLoading; _ownsBloc = false;
    //
    // This demo supports injection or local creation for portability.
    if (widget.injected != null) {
      _bloc = widget.injected!;
      _ownsBloc = false; // lifecycle managed by the caller
    } else {
      _bloc = BlocLoading();
      _ownsBloc = true; // dispose when page is disposed
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.dispose();
    }
    super.dispose();
  }

  Future<void> _runSingleAction() async {
    // Example: single action using loadingWhile with anti-flicker minShow.
    final int result = await _bloc.loadingWhile<int>(
      'Loading single action… / Cargando acción única…',
      () async {
        // Simulate quick job; minShow will keep overlay stable
        await Future<void>.delayed(const Duration(milliseconds: 220));
        return 42;
      },
      minShow: const Duration(milliseconds: 480),
    );

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Single action done. Result = $result')),
    );
  }

  Future<void> _runQueuedActions() async {
    setState(() {
      _log.clear();
      _log.add('Queue started…');
    });

    // We queue 3 tasks. Each one sets its own message and simulates different durations.
    final Future<int> t1 = _bloc.queueLoadingWhile<int>(
      'Step 1/3 — Preparing… / Paso 1/3 — Preparando…',
      () async {
        setState(() => _log.add('Task 1 started'));
        await Future<void>.delayed(const Duration(milliseconds: 650));
        setState(() => _log.add('Task 1 finished'));
        return 1;
      },
      minShow: const Duration(milliseconds: 160),
    );

    final Future<int> t2 = _bloc.queueLoadingWhile<int>(
      'Step 2/3 — Processing… / Paso 2/3 — Procesando…',
      () async {
        setState(() => _log.add('Task 2 started'));
        await Future<void>.delayed(const Duration(milliseconds: 180));
        setState(() => _log.add('Task 2 finished'));
        return 2;
      },
      minShow: const Duration(milliseconds: 160),
    );

    final Future<int> t3 = _bloc.queueLoadingWhile<int>(
      'Step 3/3 — Finalizing… / Paso 3/3 — Finalizando…',
      () async {
        setState(() => _log.add('Task 3 started'));
        await Future<void>.delayed(const Duration(milliseconds: 320));
        setState(() => _log.add('Task 3 finished'));
        return 3;
      },
      minShow: const Duration(milliseconds: 160),
    );

    final List<int> results = await Future.wait(<Future<int>>[t1, t2, t3]);

    if (!mounted) {
      return;
    }
    setState(() => _log.add('Queue done. Results = $results'));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Queued actions completed (FIFO)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use two streams:
    // - isLoadingStream (bool) to drive the overlay cheaply with distinct()
    // - loadingMsgStream (String) to show the current message text
    return Scaffold(
      appBar: AppBar(title: const Text('BlocLoading Demo')),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              // In-screen documentation for implementers.
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'How this demo works / Cómo funciona esta demo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '1) Single action — uses `loadingWhile` with a minimal visible time (`minShow`) to avoid flicker.',
                      ),
                      Text(
                        '   • If another loading is already active, it does NOT override the UI but still executes the action and returns its result.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2) Queued actions — uses `queueLoadingWhile` to serialize three tasks (FIFO).',
                      ),
                      Text(
                        '   • Each task sets its own progressive message: "Step 1/3", "Step 2/3", "Step 3/3".',
                      ),
                      Text(
                        '   • The overlay remains visible while tasks run one after another.',
                      ),
                      SizedBox(height: 8),
                      Text('3) Streams used:'),
                      Text(
                        '   • `isLoadingStream` (bool) → drives the overlay efficiently via `.distinct()`.',
                      ),
                      Text(
                        '   • `loadingMsgStream` (String) → provides the current message text.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _runSingleAction,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Run single action'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _runQueuedActions,
                      icon: const Icon(Icons.queue),
                      label: const Text('Run queued actions (FIFO)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tiny log area to visualize the order of events for the queue demo.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Execution log / Registro de ejecución',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_log.isEmpty)
                        const Text('No events yet / Aún no hay eventos.'),
                      if (_log.isNotEmpty)
                        ..._log.map((String e) => Text('• $e')),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay driven by isLoadingStream + loadingMsgStream
          StreamBuilder<bool>(
            stream: _bloc.isLoadingStream,
            initialData: _bloc.isLoading,
            builder: (BuildContext context, AsyncSnapshot<bool> snap) {
              final bool active = snap.data ?? false;
              if (!active) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const CircularProgressIndicator(),
                              const SizedBox(height: 12),
                              StreamBuilder<String>(
                                stream: _bloc.loadingMsgStream,
                                initialData: _bloc.loadingMsg,
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<String> s2,
                                ) {
                                  final String msg = s2.data ?? '';
                                  return Text(
                                    msg.isEmpty ? 'Loading…' : msg,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
