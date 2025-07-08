part of '../jocaagura_domain.dart';

/// A specialized reactive [Bloc] that allows multiple named listeners
/// to respond to stream updates.
///
/// This class is ideal for managing complex reactive state where you need
/// to bind multiple listeners (such as UI widgets or logic handlers)
/// to a shared stream of values.
///
/// Each function is associated with a key, allowing it to be removed or
/// replaced independently.
///
/// Example:
/// ```dart
/// final BlocGeneral<int> counterBloc = BlocGeneral<int>(0);
///
/// counterBloc.addFunctionToProcessTValueOnStream('logger', (value) {
///   print('Counter updated: $value');
/// }, true);
///
/// counterBloc.value = 42; // Triggers logger
///
/// counterBloc.deleteFunctionToProcessTValueOnStream('logger');
/// counterBloc.dispose();
/// ```
class BlocGeneral<T> extends Bloc<T> {
  /// Creates a [BlocGeneral] with the given initial value.
  ///
  /// Automatically sets up a subscription to dispatch events to all
  /// registered functions.
  BlocGeneral(super.initialValue) {
    _setStreamSubscription((T event) {
      for (final void Function(T val) element in _functionsMap.values) {
        element(event);
      }
    });
  }

  final Map<String, void Function(T val)> _functionsMap =
      <String, void Function(T val)>{};

  /// Adds a function to be called each time the stream emits a new value.
  ///
  /// The function is stored with the provided [key] and can be optionally
  /// executed immediately with the current value if [executeNow] is true.
  ///
  /// Example:
  /// ```dart
  /// bloc.addFunctionToProcessTValueOnStream('observer', (val) {
  ///   print('Observed: $val');
  /// }, true);
  /// ```
  void addFunctionToProcessTValueOnStream(
    String key,
    Function(T val) function, [
    bool executeNow = false,
  ]) {
    _functionsMap[key] = function;
    if (executeNow) {
      function(value);
    }
  }

  /// Removes the function associated with the given [key].
  ///
  /// Example:
  /// ```dart
  /// bloc.deleteFunctionToProcessTValueOnStream('observer');
  /// ```
  void deleteFunctionToProcessTValueOnStream(String key) {
    _functionsMap.remove(key);
  }

  /// Returns the current value of the bloc.
  ///
  /// This getter exists for compatibility with non-null-safe legacy code
  /// but should be avoided in favor of `value`.
  T get valueOrNull => value;

  /// Returns true if a function with the specified [key] is registered.
  ///
  /// Example:
  /// ```dart
  /// final exists = bloc.containsKeyFunction('logger');
  /// ```
  bool containsKeyFunction(String key) {
    return _functionsMap.containsKey(key);
  }

  /// Disposes of the internal stream and all registered functions.
  ///
  /// This is equivalent to calling [dispose] from [Bloc].
  /// Can be used for familiarity if developers prefer `close` instead.
  void close() {
    dispose();
  }
}
