part of '../jocaagura_domain.dart';

/// An abstract class representing a BLoC (Business Logic Component) for managing entities.
///
/// This class serves as a base for defining BLoCs that manage the state and business logic
/// related to specific entities within the application. It provides a [dispose] method
/// for cleaning up resources, such as streams or subscriptions, when the BLoC is no longer needed.
///
/// Example usage:
///
/// ```dart
/// class UserBloc extends EntityBloc {
///   final StreamController<User> _userController = StreamController<User>();
///
///   Stream<User> get userStream => _userController.stream;
///
///   void addUser(User user) {
///     _userController.sink.add(user);
///   }
///
///   @override
///   void dispose() {
///     _userController.close();
///   }
/// }
/// ```
///
/// This class defines the contract for any BLoC implementation to ensure
/// proper resource management.
abstract class EntityBloc {
  const EntityBloc();

  /// Disposes of resources used by the BLoC.
  ///
  /// This method is intended to be overridden by subclasses to clean up
  /// resources such as streams, controllers, or subscriptions.
  void dispose();
}

/// [RepeatLastValueExtension] Retorna un nuevo Stream que repite el último valor emitido por este Stream.
///
/// [lastValue] es el último valor emitido por este Stream, que se repetirá en el nuevo Stream.
/// Si este Stream no emitió ningún valor, el [lastValue] será el primer valor emitido por el nuevo Stream.
///
/// Si [onCancel] es llamado en el nuevo Stream, se quitará el controlador de este Stream de la lista de controladores actuales.
///
/// Si [onError] es llamado en este Stream, el error será propagado al nuevo Stream y se cerrará el controlador del nuevo Stream.
///
/// Si [onDone] es llamado en este Stream, el nuevo Stream cerrará su controlador y no emitirá más eventos.
/// Creates a new instance of the `Stream` that repeats the `lastValue` parameter
/// whenever a new subscription is made.
extension RepeatLastValueExtension<T> on Stream<T> {
  Stream<T> call(T lastValue) {
    bool done = false;
    final Set<MultiStreamController<T>> currentListeners =
        <MultiStreamController<T>>{};
    listen(
      (T event) {
        for (final MultiStreamController<T> listener
            in currentListeners.toList()) {
          listener.addSync(event);
        }
      },
      onError: (Object error, StackTrace stack) {
        for (final MultiStreamController<T> listener
            in currentListeners.toList()) {
          listener.addErrorSync(error, stack);
        }
      },
      onDone: () {
        done = true;
        final List<MultiStreamController<T>> listenersSnapshot =
            currentListeners
                .toList(); // Snapshot to avoid concurrent modification
        for (final MultiStreamController<T> listener in listenersSnapshot) {
          listener.closeSync();
        }
        currentListeners.clear(); // Clear after iterating
      },
    );
    return Stream<T>.multi((final MultiStreamController<T> controller) {
      if (done) {
        controller.close();
        return;
      }
      currentListeners.add(controller);
      controller.add(lastValue);
      controller.onCancel = () {
        currentListeners.remove(controller);
      };
    });
  }
}
