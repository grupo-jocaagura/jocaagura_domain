part of '../jocaagura_domain.dart';

abstract class EntityBloc {
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
            in <MultiStreamController<T>>[...currentListeners]) {
          listener.addSync(event);
        }
      },
      onError: (Object error, StackTrace stack) {
        for (final MultiStreamController<T> listener
            in <MultiStreamController<T>>[...currentListeners]) {
          listener.addErrorSync(error, stack);
        }
      },
      onDone: () {
        done = true;
        for (final MultiStreamController<T> listener in currentListeners) {
          listener.closeSync();
        }
        currentListeners.clear();
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
