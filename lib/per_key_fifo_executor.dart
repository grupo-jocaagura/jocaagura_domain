part of 'jocaagura_domain.dart';

/// Executes asynchronous actions in **FIFO order per key**.
///
/// Each key `K` has its own serial queue. Actions enqueued with the same key
/// run one after another (FIFO). Actions enqueued with different keys can run
/// in parallel.
///
/// **Non-reentrancy:** do not call `withLock` **for the same key** from within
/// the locked action; that would create a circular wait. Compose steps inside
/// a single action or chain from the outside instead.
///
/// Keys must provide stable `==` and `hashCode`.
///
/// ### Example
/// ```dart
/// final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
///
/// Future<void> saveUser(String userId, Future<void> Function() ioSave) {
///   return exec.withLock<String>(userId, () async {
///     await ioSave(); // serialized per userId
///     return 'ok'; // any return type works (String here)
///   });
/// }
/// ```
///
/// ### Disposal
/// Calling [dispose] clears internal queues. In-flight actions are **not**
/// cancelled and will complete normally. New actions after dispose no longer
/// chain to previous ones for the same key (they may overlap).
class PerKeyFifoExecutor<K extends Object> {
  final Map<K, Future<void>> _queues = <K, Future<void>>{};

  /// Schedules [action] to run **after** the current chain for [key] completes.
  ///
  /// Returns the result of [action] or rethrows its error. The action runs
  /// exclusively for its key (FIFO). Different keys do not block each other.
  Future<R> withLock<R>(K key, Future<R> Function() action) async {
    final Future<void> previous = _queues[key] ?? Future<void>.value();
    final Completer<void> gate = Completer<void>();
    _queues[key] = previous.then((_) => gate.future);

    try {
      await previous;
      final R result = await action();
      return result;
    } finally {
      if (!gate.isCompleted) {
        gate.complete();
      }
      if (identical(_queues[key], gate.future)) {
        _queues.remove(key);
      }
    }
  }

  /// Clears all queues. Pending actions continue; new actions won't be chained.
  void dispose() => _queues.clear();
}
