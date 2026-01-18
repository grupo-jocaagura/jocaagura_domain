part of '../jocaagura_domain.dart';

/// Debounces function calls by executing only the latest scheduled action.
///
/// Each call resets the internal timer. When the debounce duration elapses,
/// the **most recent** callback is executed and all previous pending callbacks
/// are discarded.
///
/// Typical use cases:
/// - Search input (avoid firing requests on every keystroke).
/// - Button taps or repeated events (collapse bursts into a single action).
///
/// Preconditions:
/// - [milliseconds] should be a positive value. Using `0` or negative values
///   may lead to immediate execution depending on the runtime.
///
/// Functional example:
/// ```dart
/// import 'dart:async';
///
/// void main() async {
///   final Debouncer debouncer = Debouncer(milliseconds: 300);
///
///   void onUserInput(String input) {
///     debouncer(() {
///       // Only the last input will reach this point after 300ms.
///       print('Executing action for input: $input');
///     });
///   }
///
///   onUserInput('Hello');
///   onUserInput('Hello, world');
///   onUserInput('Hello, world!');
///
///   // Give time for the debounced callback to run.
///   await Future<void>.delayed(const Duration(milliseconds: 350));
///
///   debouncer.dispose();
/// }
/// ```
///
/// Lifecycle:
/// - Call [dispose] to cancel any pending timer and prevent future executions.
/// - After disposal, calls to [call] are ignored.
class Debouncer {
  /// Creates a [Debouncer] with a debounce duration in milliseconds.
  ///
  /// If [milliseconds] is not provided, it defaults to 500ms.
  ///
  /// Preconditions:
  /// - [milliseconds] must be > 0 (debug-checked via assert).
  Debouncer({this.milliseconds = 500})
      : assert(milliseconds > 0, 'milliseconds must be > 0');

  /// Debounce duration in milliseconds before the action is executed.
  final int milliseconds;

  /// Internal [Timer] used to track the debounce window.
  Timer? _timer;

  bool _isDisposed = false;

  /// Whether this instance has been disposed.
  ///
  /// When `true`, [call] will ignore any incoming actions.
  bool get isDisposed => _isDisposed;

  /// Schedules [action] to run after the debounce duration.
  ///
  /// If called again before the duration elapses, the previous pending timer
  /// is canceled and the delay restarts, ensuring only the latest [action]
  /// is executed.
  ///
  /// After [dispose] is called, this method will not schedule any action.
  void call(void Function() action) {
    if (!_isDisposed) {
      _timer?.cancel();
      _timer = Timer(Duration(milliseconds: milliseconds), action);
    }
  }

  /// Cancels any pending timer and marks this instance as disposed.
  ///
  /// Calling [dispose] multiple times is safe (idempotent).
  /// After disposal, no further actions will be scheduled or executed.
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _timer?.cancel();
      _timer = null;
    }
  }
}
