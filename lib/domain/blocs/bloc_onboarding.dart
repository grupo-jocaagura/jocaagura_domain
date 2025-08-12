part of '../../jocaagura_domain.dart';

/// A BLoC (Business Logic Component) for managing onboarding processes.
///
/// The `BlocOnboarding` class handles a sequence of asynchronous initialization
/// functions during the onboarding phase of an application. It provides
/// progress updates through a stream and allows dynamically adding new
/// functions to the onboarding process.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/bloc_onboarding.dart';
/// import 'dart:async';
///
/// void main() async {
///   final blocOnboarding = BlocOnboarding([
///     () async {
///       print('Task 1 started');
///       await Future.delayed(Duration(seconds: 1));
///       print('Task 1 completed');
///     },
///     () async {
///       print('Task 2 started');
///       await Future.delayed(Duration(seconds: 1));
///       print('Task 2 completed');
///     },
///   ]);
///
///   // Listen to progress messages
///   blocOnboarding.msgStream.listen((message) {
///     print('Onboarding Message: $message');
///   });
///
///   // Start the onboarding process
///   await blocOnboarding.execute(Duration(seconds: 2));
/// }
/// ```
class BlocOnboarding extends BlocModule {
  /// Creates an instance of `BlocOnboarding` with the provided list of onboarding functions.
  ///
  /// The [delayInSeconds] parameter specifies an initial delay before the
  /// onboarding execution starts.
  BlocOnboarding(
    List<FutureOr<void> Function()> initialList, {
    this.delayInSeconds = 1,
    this.onError,
    this.startingMsg = initialMsg,
    this.workingMsg = completingMsg,
    this.finishedMsg = completedMsg,
  })  : assert(delayInSeconds >= 0, 'Delay must be non-negative'),
        _progress = BlocGeneral<double>(0.0) {
    _blocOnboardingList.addAll(initialList);
  }

  final int delayInSeconds;
  final String startingMsg;
  final String workingMsg;
  final String finishedMsg;

  static const String initialMsg = 'Starting';
  static const String completingMsg = 'working';
  static const String completedMsg = 'Completed';

  /// The name identifier for the BLoC, used for tracking or debugging.
  static const String name = 'onboardingBloc';

  /// A list of asynchronous functions to execute during onboarding.
  final List<FutureOr<void> Function()> _blocOnboardingList =
      <FutureOr<void> Function()>[];

  /// Optional error callback for handling task failures.
  final void Function(Object error, StackTrace stack)? onError;

  /// Internal controller for progress messages.
  final BlocGeneral<String> _blocMsg = BlocGeneral<String>('');

  /// Controller for numeric progress (0.0 to 1.0).
  final BlocGeneral<double> _progress;

  /// Clears all onboarding tasks.
  ///
  /// Use this to reset the onboarding flow for reuse.
  void clearFunctions() {
    _blocOnboardingList.clear();
  }

  /// A stream of progress messages.
  ///
  /// This stream emits updates as the onboarding process progresses.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocOnboarding.msgStream.listen((message) {
  ///   print('Onboarding Message: $message');
  /// });
  /// ```
  Stream<String> get msgStream => _blocMsg.stream;

  /// Stream of progress as a double between 0.0 and 1.0.
  Stream<double> get progressStream => _progress.stream;

  /// Current message.
  String get msg => _blocMsg.value;

  /// Current progress.
  double get progress => _progress.value;

  /// Adds a new function to the onboarding process.
  ///
  /// The [function] is a `FutureOr` task to be executed as part of onboarding.
  /// Returns the updated length of the onboarding function list.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocOnboarding.addFunction(() async {
  ///   await Future.delayed(Duration(seconds: 1));
  ///   print('New Task Completed');
  /// });
  /// ```
  int addFunction(FutureOr<void> Function() function) {
    _blocOnboardingList.add(function);
    return _blocOnboardingList.length;
  }

  /// Executes onboarding functions with optional delay.
  ///
  /// Each task runs sequentially. Progress is updated after each step.
  Future<void> execute(Duration delay) async {
    final int total = _blocOnboardingList.length;
    if (total == 0) {
      return;
    }
    _blocMsg.value = startingMsg;
    await Future<void>.delayed(delay);
    int completed = 0;

    for (final FutureOr<void> Function() task in _blocOnboardingList) {
      try {
        await task();
      } catch (e, s) {
        onError?.call(e, s);
      } finally {
        completed++;
        _progress.value = completed / total;
        _blocMsg.value = '${total - completed} $workingMsg';
      }
    }
    _blocMsg.value = finishedMsg;
    await Future<void>.delayed(delay);
    _blocMsg.value = '';
  }

  /// Releases resources held by the BLoC.
  ///
  /// This method must be called when the BLoC is no longer needed to prevent
  /// memory leaks.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocOnboarding.dispose();
  /// ```
  @override
  FutureOr<void> dispose() {
    _blocMsg.dispose();
    _progress.dispose();
  }
}
