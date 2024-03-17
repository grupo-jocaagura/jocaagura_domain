part of '../jocaagura_domain.dart';

class BlocGeneral<T> extends Bloc<T> {
  BlocGeneral(super.initialValue) {
    _setStreamSubscription((T event) {
      for (final void Function(T val) element in _functionsMap.values) {
        element(event);
      }
    });
  }

  final Map<String, void Function(T val)> _functionsMap =
      <String, void Function(T val)>{};

  void addFunctionToProcessTValueOnStream(
    String key,
    Function(T val) function, [
    bool executeNow = false,
  ]) {
    _functionsMap[key.toLowerCase()] = function;
    if (executeNow) {
      function(value);
    }
  }

  void deleteFunctionToProcessTValueOnStream(String key) {
    _functionsMap.remove(key);
  }

  T get valueOrNull => value;
  bool containsKeyFunction(String key) {
    return _functionsMap.containsKey(key);
  }

  void close() {
    dispose();
  }
}
