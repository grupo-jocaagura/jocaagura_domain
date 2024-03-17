part of '../jocaagura_domain.dart';

/// [Bloc] A generic class that implements a reactive programming pattern using Streams.
abstract class Bloc<T> {
  /// [Bloc] Constructs a new `Bloc` instance with the given `initialValue`.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// ```
  Bloc(T initialValue) {
    _value = initialValue;
  }

  late T _value;

  /// [getValue] Returns the current value of the bloc.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// print(myBloc.value); // 'initial value'
  /// ```
  T get value => _value;
  final StreamController<T> _streamController = StreamController<T>.broadcast();

  /// [stream] Returns the stream of the current bloc value.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc.stream.listen((value) => print(value)); // 'initial value'
  /// ```
  Stream<T> get stream => _streamController.stream(value);

  /// [isClosed] access granted to check if the current _streamController is
  /// closed
  bool get isClosed => _streamController.isClosed;

  /// [value] Sets the current value of the bloc to `val` and notifies subscribers.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc.value = 'new value'; // The stream will emit 'new value'
  /// ```
  set value(T val) {
    _streamController.sink.add(val);
    _value = val;
  }

  StreamSubscription<T>? _suscribe;

  /// [isSubscribeActive] Returns `true` if the stream subscription is currently active, `false` otherwise.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// print(myBloc.isSubscribeActive); // false
  /// myBloc._setStreamSubsciption((value) => print(value));
  /// print(myBloc.isSubscribeActive); // true
  /// ```
  bool get isSubscribeActive => !(_suscribe == null);

  /// [_desuscribeStream] Cancels the current stream subscription.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc._setStreamSubsciption((value) => print(value));
  /// myBloc._desuscribeStream(); // Subscription is cancelled
  /// ```
  void _desuscribeStream() {
    _suscribe?.cancel();
    _suscribe = null;
  }

  /// Sets a new subscription to the stream of events.
  /// [_setStreamSubscription] Sets a new stream subscription with the given `function`.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc._setStreamSubsciption((value) => print(value));
  /// myBloc.value = 'new value'; // 'new value' is printed to console
  /// ```
  void _setStreamSubscription(void Function(T event) function) {
    _desuscribeStream();
    _suscribe = stream.listen((T event) {
      function(event);
    });
  }

  /// [dispose] Disposes of the `Bloc` by cancelling the subscription to the stream of events
  /// and closing the stream controller.
  /// Closes the stream and cancels the current stream subscription.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc._setStreamSubsciption((value) => print(value));
  /// myBloc.dispose(); // Subscription is cancelled and stream is closed
  /// ```
  void dispose() {
    _desuscribeStream();
    _streamController.close();
  }
}
