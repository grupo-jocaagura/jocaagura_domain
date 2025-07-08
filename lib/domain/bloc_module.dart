part of '../jocaagura_domain.dart';

/// [BlocModule] defines a contract for disposable BLoC implementations.
///
/// Any class that represents a BLoC should implement [BlocModule] to
/// ensure a consistent lifecycle management pattern, especially when
/// used within [AppManager] or similar orchestrators.
///
/// Example:
/// ```dart
/// class BlocCounter implements BlocModule {
///   final BlocGeneral<int> _bloc = BlocGeneral<int>(0);
///
///   Stream<int> get stream => _bloc.stream;
///   int get value => _bloc.value;
///
///   void increment() => _bloc.value = _bloc.value + 1;
///
///   @override
///   void dispose() => _bloc.dispose();
/// }
/// ```
abstract class BlocModule {
  /// Const constructor for [BlocModule].
  const BlocModule();

  /// Disposes the resources associated with this module.
  ///
  /// Must be implemented to clean up streams, controllers, or listeners.
  void dispose();
}
