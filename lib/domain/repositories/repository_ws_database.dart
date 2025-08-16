part of '../../../jocaagura_domain.dart';

/// Repository abstraction for JSON-over-WebSocket CRUD using domain [Model]s.
///
/// Converts between typed entities `T extends Model` and raw JSON handled by
/// [GatewayWsDatabase]. All operations expose `Either<ErrorItem, ...>` to follow
/// the success/failure pattern.
///
/// ### Responsibilities
/// - `read/write/delete`: async CRUD mapped to/from `T`.
/// - `watch`: real-time updates for a single `docId`, emitting `Either<ErrorItem, T>`.
/// - Lifecycle: `detachWatch`, `releaseDoc`, and `dispose` are forwarded to the
///   underlying [GatewayWsDatabase] implementation.
///
/// **Concurrency (optional):**
/// If [serializeWrites] is `true`, `write` and `delete` are serialized **per docId**
/// to prevent race conditions (FIFO), using an internal lightweight queue.
///
/// ### Example
/// ```dart
/// // Suppose we have a UserModel that extends Model and provides fromJson:
/// // class UserModel extends Model { ...; static UserModel fromJson(Map<String,dynamic> j) => ...; }
///
/// final gateway = GatewayWsDatabaseImpl(
///   service: FakeServiceWsDatabase(),
///   collection: 'users',
///   mapper: DefaultErrorMapper(),
/// );
///
/// final RepositoryWsDatabase<UserModel> repo = RepositoryWsDatabaseImpl<UserModel>(
///   gateway: gateway,
///   fromJson: UserModel.fromJson,     // required parser
///   serializeWrites: true,            // optional: serialize per docId
/// );
///
/// // Write
/// final user = UserModel(...);
/// final w = await repo.write(user.id, user);
/// w.fold((err) => print('write error: ${err.code}'), (ok) => print('saved: $ok'));
///
/// // Read
/// final r = await repo.read(user.id);
/// r.fold((err) => print('read error: ${err.code}'), (u) => print('user: $u'));
///
/// // Watch (remember to detach after cancel)
/// final sub = repo.watch(user.id).listen((either) {
///   either.fold(
///     (err) => print('watch error: ${err.code}'),
///     (u) => print('update: $u'),
///   );
/// });
/// // ...
/// await sub.cancel();
/// repo.detachWatch(user.id);
///
/// // Teardown
/// repo.dispose();
/// ```
abstract class RepositoryWsDatabase<T extends Model> {
  /// Reads an entity by [docId].
  ///
  /// Returns `Right(T)` on success, or `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, T>> read(String docId);

  /// Writes (create/update) the entity [entity] at [docId].
  ///
  /// Returns `Right(T)` representing the authoritative entity after write,
  /// or `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, T>> write(String docId, T entity);

  /// Deletes the entity at [docId]. Returns `Right(Unit)` on success.
  Future<Either<ErrorItem, Unit>> delete(String docId);

  /// Watches real-time updates for [docId], emitting `Either<ErrorItem, T>`.
  ///
  /// IMPORTANT: After canceling the subscription(s), callers **must** invoke
  /// [detachWatch] to allow resource cleanup in the underlying gateway.
  Stream<Either<ErrorItem, T>> watch(String docId);

  /// Decrements ref-count for [docId] watchers and releases resources when zero.
  void detachWatch(String docId);

  /// Forces immediate cleanup of a specific [docId] (logout/teardown/tests).
  void releaseDoc(String docId);

  /// Global teardown. After calling this, further API usage is undefined.
  void dispose();
}
