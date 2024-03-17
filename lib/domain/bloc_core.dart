part of '../jocaagura_domain.dart';

/// The core class responsible for managing general and module BLoCs.
class BlocCore<T> {
  BlocCore([Map<String, BlocModule> map = const <String, BlocModule>{}]) {
    map.forEach((String key, BlocModule blocModule) {
      addBlocModule(key, blocModule);
    });
  }

  final Map<String, BlocGeneral<T>> _injector = <String, BlocGeneral<T>>{};
  final Map<String, BlocModule> _moduleInjector = <String, BlocModule>{};

  /// Returns a [BlocGeneral] instance for the given [key].
  ///
  /// Throws an [UnimplementedError] if the [BlocGeneral] for [key] has not been initialized.
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// final myBloc = MyBloc();
  /// blocCore.addBlocGeneral('myBloc', myBloc);
  ///
  /// final myBlocInstance = blocCore.getBloc<MyBloc>('myBloc');
  /// ```
  BlocGeneral<T> getBloc<T2>(String key) {
    final BlocGeneral<T>? tmp = _injector[key.toLowerCase()];

    if (tmp == null) {
      throw UnimplementedError('The BlocGeneral were not initialized');
    }

    return tmp;
  }

  /// [getBlocModule] Returns a [BlocModule] instance for the given [key].
  ///
  /// Throws an [UnimplementedError] if the [BlocModule] for [key] has not been initialized.
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// final myModule = MyModule();
  /// blocCore.addBlocModule('myModule', myModule);
  ///
  /// final myModuleInstance = blocCore.getBlocModule<MyModule>('myModule');
  /// ```
  V getBlocModule<V>(String key) {
    final BlocModule? tmp = _moduleInjector[key.toLowerCase()];
    if (tmp == null) {
      throw UnimplementedError('The BlocModule were not initialized');
    }
    return _moduleInjector[key.toLowerCase()] as V;
  }

  /// [addBlocGeneral] Adds a [BlocGeneral] instance to the injector with the given [key].
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// final myBloc = MyBloc();
  /// blocCore.addBlocGeneral('myBloc', myBloc);
  /// ```
  void addBlocGeneral(String key, BlocGeneral<T> blocGeneral) {
    _injector[key.toLowerCase()] = blocGeneral;
  }

  /// [isDisposed] Returns whether the injector and module injector are empty or not.
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// assert(blocCore.isDisposed == true);
  ///
  /// final myBloc = MyBloc();
  /// blocCore.addBlocGeneral('myBloc', myBloc);
  /// assert(blocCore.isDisposed == false);
  ///
  /// blocCore.dispose();
  /// assert(blocCore.isDisposed == true);
  /// ```
  bool get isDisposed => _injector.isEmpty && _moduleInjector.isEmpty;

  /// [addBlocModule] Adds a [BlocModule] instance to the module injector with the given [key].
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// final myModule = MyModule();
  /// blocCore.addBlocModule('myModule', myModule);
  /// ```
  void addBlocModule<BlocType>(String key, BlocModule blocModule) {
    _moduleInjector[key.toLowerCase()] = blocModule;
  }

  void deleteBlocGeneral(String key) {
    key = key.toLowerCase();
    _injector[key]?.dispose();
    _injector.remove(key);
  }

  void deleteBlocModule(String key) {
    key = key.toLowerCase();
    _moduleInjector[key]?.dispose();
    _moduleInjector.remove(key);
  }

  void dispose() {
    _injector.forEach(
      (String key, BlocGeneral<dynamic> value) {
        value.dispose();
      },
    );
    _moduleInjector.forEach(
      (String key, BlocModule value) {
        value.dispose();
      },
    );
    Future<void>.delayed(const Duration(milliseconds: 999), () {
      _injector.clear();
      _moduleInjector.clear();
    });
  }
}
