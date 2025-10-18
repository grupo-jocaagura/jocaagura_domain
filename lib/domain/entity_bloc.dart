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

/// Re-expose a stream as a broadcast stream that **seeds** each subscription with [lastValue],
/// then forwards all subsequent events from the source.
///
/// ### Semantics
/// - The source is listened to **immediately** (eager) when this method is called,
///   not when the returned stream gets its first subscriber.
/// - The [lastValue] is the value captured **at call time**. Every subscription to the
///   returned stream receives this captured value **first**, then all forwarded updates.
/// - If the source stream has already completed by the time a subscriber attaches,
///   the returned stream **closes without emitting** the seed.
///
/// ### Notes
/// - Backpressure/pause/resume are not propagated to the source subscription.
/// - Consider keeping a single returned stream per holder when feasible to avoid
///   opening multiple source listeners.
///
/// ### Example
/// ```dart
/// void main() async {
///   final StreamController<int> src = StreamController<int>.broadcast();
///   final Stream<int> seeded = src.stream(42); // seed captured now
///
///   // Later ...
///   seeded.listen(print); // prints: 42 (seed), then forwarded values
///   src.add(43);          // prints: 43
///
///   await src.close();    // downstream completes
/// }
/// ```
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
