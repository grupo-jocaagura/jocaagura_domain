part of '../../jocaagura_domain.dart';

/// BLoC to manage **loading states** using a reactive `String` message.
///
/// - Emits the current loading message on [loadingMsgStream].
/// - Exposes [isLoading] and [isLoadingStream] for boolean-driven UIs.
/// - Ensures cleanup with `try/finally`.
/// - Provides [loadingWhile] to return a result with an optional [minShow]
///   to avoid flicker.
/// - Provides [queueLoadingWhile] to serialize loading tasks (FIFO) **opt-in**.
///
/// ### Concurrency semantics
/// If there is an active loading message, [loadingMsgWithFuture] ignores new
/// visual requests. Use [queueLoadingWhile] if you need sequential execution.
///
/// ### Example
/// ```dart
/// import 'package:jocaagura_domain/jocaagura_domain.dart';
///
/// Future<void> main() async {
///   final BlocLoading blocLoading = BlocLoading();
///
///   // Boolean stream for simple overlays:
///   blocLoading.isLoadingStream.listen((bool v) {});
///
///   final int value = await blocLoading.loadingWhile<int>(
///     'Loading…',
///     () async {
///       await Future<void>.delayed(const Duration(milliseconds: 50));
///       return 42;
///     },
///     minShow: const Duration(milliseconds: 80),
///   );
///   assert(value == 42);
///
///   // Queue multiple tasks (runs sequentially)
///   final Future<int> a = blocLoading.queueLoadingWhile<int>(
///     'A…',
///     () async => 1,
///   );
///   final Future<int> b = blocLoading.queueLoadingWhile<int>(
///     'B…',
///     () async => 2,
///   );
///   await Future.wait(<Future<int>>[a, b]);
///
///   blocLoading.dispose();
/// }
/// ```
class BlocLoading extends BlocModule {
  /// Internal controller holding the loading message.
  final BlocGeneral<String> _loadingController = BlocGeneral<String>('');

  /// BLoC identifier (useful for logs/registry).
  static const String name = 'blocLoading';

  bool _disposed = false;

  /// Reactive stream of the current loading message. Emits `''` when idle.
  Stream<String> get loadingMsgStream => _loadingController.stream;

  /// `true` when there is an active loading message (stream variant).
  Stream<bool> get isLoadingStream =>
      _loadingController.stream.map((String m) => m.isNotEmpty).distinct();

  /// Latest loading message.
  String get loadingMsg => _loadingController.value;

  /// `true` when there is an active loading message.
  bool get isLoading => loadingMsg.isNotEmpty;

  /// Sets the loading message.
  set loadingMsg(String val) {
    assert(!_disposed, 'BlocLoading has been disposed.');
    _loadingController.value = val;
  }

  /// Clears any loading message.
  void clearLoading() {
    loadingMsg = '';
  }

  /// Shows [msg] while awaiting [action], then clears the message.
  ///
  /// If already loading, it **keeps current policy** (no visual change), but
  /// still runs [action] and returns its result.
  ///
  /// When [minShow] > 0, ensures the message remains visible at least that time
  /// (helps avoid flicker on quick actions).
  Future<T> loadingWhile<T>(
    String msg,
    FutureOr<T> Function() action, {
    Duration minShow = Duration.zero,
  }) async {
    assert(!_disposed, 'BlocLoading has been disposed.');
    if (isLoading) {
      // Do not alter current visual state; still execute the action.
      return action();
    }

    loadingMsg = msg;
    final DateTime start = DateTime.now();
    try {
      final T result = await action();
      return result;
    } finally {
      final Duration elapsed = DateTime.now().difference(start);
      if (minShow > Duration.zero && elapsed < minShow) {
        await Future<void>.delayed(minShow - elapsed);
      }
      clearLoading();
    }
  }

  /// Original helper kept for backward compatibility.
  /// Overlapping calls are ignored visually and do **not** run another action.
  Future<void> loadingMsgWithFuture(
    String msg,
    FutureOr<void> Function() action,
  ) async {
    assert(!_disposed, 'BlocLoading has been disposed.');
    if (loadingMsg.isEmpty) {
      loadingMsg = msg;
      try {
        await action();
      } finally {
        clearLoading();
      }
    }
  }

  // ---- Optional FIFO queue (opt-in) ---------------------------------------

  Future<void> _queue = Future<void>.value();

  /// Queues loading tasks so they run sequentially (FIFO).
  /// Visual policy: one spinner at a time; each task sets/clears its message.
  Future<T> queueLoadingWhile<T>(
    String msg,
    Future<T> Function() action, {
    Duration minShow = Duration.zero,
  }) {
    assert(!_disposed, 'BlocLoading has been disposed.');
    final Completer<T> completer = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        final T r = await loadingWhile<T>(msg, action, minShow: minShow);
        if (!completer.isCompleted) {
          completer.complete(r);
        }
      } catch (e, s) {
        if (!completer.isCompleted) {
          completer.completeError(e, s);
        }
      }
    });
    return completer.future;
  }

  /// Disposes internal resources.
  @override
  void dispose() {
    _disposed = true;
    _loadingController.dispose();
  }
}
