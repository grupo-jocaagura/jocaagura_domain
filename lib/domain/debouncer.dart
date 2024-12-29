part of '../jocaagura_domain.dart';

/// A utility class for debouncing method calls to ensure that a function
/// is executed only once after a specified delay, even if it's called multiple
/// times within that time frame.
///
/// The [Debouncer] is commonly used to limit the rate at which a function
/// is called, such as in response to user input or search queries.
///
/// Example usage:
///
/// ```dart
/// void main() {
///   final debouncer = Debouncer(milliseconds: 300);
///
///   void onUserInput(String input) {
///     debouncer(() {
///       print('Executing action for input: $input');
///     });
///   }
///
///   // Simulating rapid user input
///   onUserInput('Hello');
///   onUserInput('Hello, world');
///   onUserInput('Hello, world!');
///
///   // Output will only print the last input after 300 milliseconds
/// }
/// ```
class Debouncer {
  /// Constructs a [Debouncer] with an optional delay in milliseconds.
  ///
  /// If [milliseconds] is not provided, it defaults to 500ms.
  Debouncer({this.milliseconds = 500});

  /// The delay duration in milliseconds before the action is executed.
  final int milliseconds;

  /// Internal [Timer] used to track the delay period.
  Timer? _timer;

  /// Calls the provided [action] after the debounce duration.
  ///
  /// If this method is called again within the debounce period, the previous
  /// timer is canceled, and the delay resets.
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
