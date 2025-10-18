part of '../jocaagura_domain.dart';

/// Implement a lightweight reactive holder that exposes a value and a broadcast stream.
///
/// This base class keeps a current value of type `T` and notifies subscribers
/// through a broadcast `Stream`. The stream is **seeded** using a custom extension
/// so that each subscription receives an initial value followed by updates.
///
/// ### Stream seeding semantics
/// - Accessing [stream] captures the **current** [value] at **getter time** (the "seed").
/// - Every new subscription to that returned stream receives the **captured seed first**,
///   then all subsequent updates.
/// - Each access to [stream] creates a new forwarded stream with its **own** captured seed.
/// - The forwarding is **eager**: the underlying source stream is listened to immediately,
///   even if no downstream subscriber attaches to the returned stream.
/// - If the underlying stream has already completed when a subscriber attaches,
///   the returned stream closes **without emitting the seed**.
///
/// ### Example
/// ```dart
/// void main() {
///   final MyBloc bloc = MyBloc(0);
///
///   final Stream<int> s1 = bloc.stream; // captures seed = 0
///   bloc.value = 1;
///
///   s1.listen((int v) {
///     // prints: 0 (seed captured at getter time), then 1, 2, ...
///     print(v);
///   });
///
///   bloc.value = 2;
/// }
/// ```
///
/// ### Contracts
/// - Setting [value] emits the new value on the stream while the controller is open.
/// - Adding to the stream after disposal will throw [StateError] from the underlying controller.
/// - This class does not persist history nor provides backpressure.
///
/// Subclasses may build richer behaviors on top of this primitive.
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
  /// Expose a broadcast stream seeded with the [value] captured at getter time.
  ///
  /// See class-level docs for the exact seeding semantics and lifecycle notes.
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
  /// Set a new value and notify subscribers via the stream.
  ///
  /// Throws:
  /// - [StateError] if the stream controller has been closed.
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
