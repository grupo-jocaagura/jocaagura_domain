part of '../../../../jocaagura_domain.dart';

/// Reactive BLoC for **document-centric** CRUD over a WebSocket-backed repository.
///
/// - Extends [BlocGeneral] to publish a single immutable [WsDbState] stream.
/// - Delegates all operations to a [FacadeWsDatabaseUsecases] (clean layering).
/// - Manages **one or many `watch(docId)` subscriptions** and detaches them
///   from the gateway/repository when stopped or on [dispose].
///
/// ### What this BLoC is (and is not)
/// - ✅ A thin orchestration layer for UI/AppManager.
/// - ✅ Publishes **state** (`loading`, `error`, `doc`, `docId`, `isWatching`).
/// - ✅ No custom streams are created; it only updates its own state via
///   `BlocGeneral.value`.
/// - ❌ It does not transform JSON nor talk to services directly; that’s the
///   job of Repository/Gateway.
///
/// ### Usage
/// ```dart
/// final repo = RepositoryWsDatabaseImpl<UserModel>(
///   gateway: GatewayWsDatabaseImpl(
///     service: FakeServiceWsDatabase(),
///     collection: 'users',
///   ),
///   fromJson: UserModel.fromJson,
///   serializeWrites: true,
/// );
///
/// final facade = FacadeWsDatabaseUsecases<UserModel>.fromRepository(
///   repository: repo,
///   fromJson: UserModel.fromJson,
/// );
///
/// final bloc = BlocWsDatabase<UserModel>(facade: facade);
///
/// // Read once
/// final read = await bloc.readDoc('u1');
///
/// // Watch realtime
/// final sub = bloc.stream.listen((s) {
///   if (s.error != null) { /* show error */ }
///   if (s.doc != null)   { /* render document */ }
/// });
/// bloc.startWatch('u1');
///
/// // Later...
/// await bloc.stopWatch('u1');
/// await sub.cancel();
/// bloc.dispose(); // will detach remaining watches
/// ```
class BlocWsDatabase<T extends Model> extends BlocGeneral<WsDbState<T>> {
  /// Creates a BLoC wired to a [FacadeWsDatabaseUsecases].
  ///
  /// The initial state is [WsDbState.idle].
  BlocWsDatabase({required FacadeWsDatabaseUsecases<T> facade})
      : _facade = facade,
        super(WsDbState<T>.idle());

  /// Use cases facade (read/write/delete/watch/etc).
  final FacadeWsDatabaseUsecases<T> _facade;

  /// Active watch subscriptions by `docId`.
  final Map<String, StreamSubscription<Either<ErrorItem, T>>> _watchSubs =
      <String, StreamSubscription<Either<ErrorItem, T>>>{};

  // ---------------------------------------------------------------------------
  // One-shot operations
  // ---------------------------------------------------------------------------

  /// Reads a document and updates state.
  ///
  /// - Sets `loading=true` while fetching.
  /// - On success: `docId`, `doc`, `error=null`.
  /// - On failure: `error` populated, `doc` unchanged.
  Future<Either<ErrorItem, T>> readDoc(String docId) async {
    _setLoading(docId: docId, loading: true);
    final Either<ErrorItem, T> res = await _facade.readDoc(docId);
    res.fold(
      (ErrorItem err) => _setError(err),
      (T entity) => _setDoc(docId: docId, doc: entity),
    );
    _setLoading(loading: false);
    return res;
  }

  /// Writes (upserts) a document and updates state with the authoritative result.
  Future<Either<ErrorItem, T>> writeDoc(String docId, T entity) async {
    _setLoading(docId: docId, loading: true);
    final Either<ErrorItem, T> res = await _facade.writeDoc(docId, entity);
    res.fold(
      (ErrorItem err) => _setError(err),
      (T updated) => _setDoc(docId: docId, doc: updated),
    );
    _setLoading(loading: false);
    return res;
  }

  /// Deletes a document and clears it from state if it was the current `docId`.
  Future<Either<ErrorItem, Unit>> deleteDoc(String docId) async {
    _setLoading(docId: docId, loading: true);
    final Either<ErrorItem, Unit> res = await _facade.deleteDoc(docId);
    res.fold(
      (ErrorItem err) => _setError(err),
      (_) {
        if (value.docId == docId) {
          value = value.copyWith(doc: null);
        }
      },
    );
    _setLoading(loading: false);
    return res;
  }

  /// Checks existence of a document (does **not** alter `doc`).
  Future<Either<ErrorItem, bool>> existsDoc(String docId) async {
    _setLoading(docId: docId, loading: true);
    final Either<ErrorItem, bool> res = await _facade.existsDoc(docId);
    res.fold(_setError, (_) {});
    _setLoading(loading: false);
    return res;
  }

  /// Mutates a document using a pure transform and updates state with the result.
  Future<Either<ErrorItem, T>> mutateDoc(
    String docId,
    T Function(T current) transform,
  ) async {
    _setLoading(docId: docId, loading: true);
    final Either<ErrorItem, T> res = await _facade.mutateDoc(docId, transform);
    res.fold(_setError, (T updated) => _setDoc(docId: docId, doc: updated));
    _setLoading(loading: false);
    return res;
  }

  /// Patches a document by merging [patch] into its JSON representation.
  Future<Either<ErrorItem, T>> patchDoc(
    String docId,
    Map<String, dynamic> patch,
  ) async {
    _setLoading(docId: docId, loading: true);
    final Either<ErrorItem, T> res = await _facade.patchDoc(docId, patch);
    res.fold(_setError, (T updated) => _setDoc(docId: docId, doc: updated));
    _setLoading(loading: false);
    return res;
  }

  /// Ensures a document exists; creates or optionally updates it.
  Future<Either<ErrorItem, T>> ensureDoc({
    required String docId,
    required T Function() create,
    T Function(T current)? updateIfExists,
  }) async {
    _setLoading(docId: docId, loading: true);
    final Either<ErrorItem, T> res = await _facade.ensureDoc(
      docId: docId,
      create: create,
      updateIfExists: updateIfExists,
    );
    res.fold(_setError, (T entity) => _setDoc(docId: docId, doc: entity));
    _setLoading(loading: false);
    return res;
  }

  // Batch helpers are forwarded; state is not altered by default.
  Future<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>> readDocs(
    List<String> ids,
  ) =>
      _facade.readDocs(ids);

  Future<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>> writeDocs(
    Map<String, T> entries,
  ) =>
      _facade.writeDocs(entries);

  Future<Either<ErrorItem, Map<String, Either<ErrorItem, Unit>>>> deleteDocs(
    List<String> ids,
  ) =>
      _facade.deleteDocs(ids);

  // ---------------------------------------------------------------------------
  // Realtime watch
  // ---------------------------------------------------------------------------

  /// Starts (or restarts) a realtime watch for [docId].
  ///
  /// - Reuses underlying gateway channel (no duplicate backend subscriptions).
  /// - If there was a previous watch for the same [docId], it is canceled first.
  /// - Updates state on each tick: `doc` or `error` accordingly.
  Future<void> startWatch(String docId) async {
    await stopWatch(docId);

    _setWatching(docId: docId, isWatching: true);

    _watchSubs[docId] =
        _facade.watchDoc(docId).listen((Either<ErrorItem, T> e) {
      e.fold(
        (ErrorItem err) => _setError(err),
        (T entity) => _setDoc(docId: docId, doc: entity),
      );
    });
  }

  /// Stops a realtime watch for [docId] and detaches the underlying channel.
  ///
  /// Safe to call multiple times.
  Future<void> stopWatch(String docId) async {
    final StreamSubscription<Either<ErrorItem, T>>? sub =
        _watchSubs.remove(docId);
    if (sub != null) {
      await sub.cancel();
      await _facade.detach(docId);
    }
    if (!_watchSubs.containsKey(docId) && value.docId == docId) {
      _setWatching(isWatching: false);
    }
  }

  /// Stops all watches and detaches their channels.
  Future<void> stopAllWatches() async {
    final List<Future<void>> tasks = <Future<void>>[];
    for (final MapEntry<String, StreamSubscription<Either<ErrorItem, T>>> e
        in _watchSubs.entries) {
      tasks.add(e.value.cancel());
      tasks.add(_facade.detach(e.key));
    }
    _watchSubs.clear();
    await Future.wait(tasks);
    _setWatching(isWatching: false);
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Disposes the BLoC:
  /// - Cancels all active watches and detaches channels.
  /// - Calls `super.dispose()` to close the [BlocGeneral] stream.
  ///
  /// Note: it does **not** call `facade.disposeAll()` automatically because
  /// multiple BLoCs could share the same repository/gateway. If you own the
  /// stack, call [disposeStack] instead.
  @override
  void dispose() {
    // best-effort cleanup (no `await` in dispose)
    for (final StreamSubscription<Either<ErrorItem, T>> sub
        in _watchSubs.values) {
      sub.cancel();
    }
    _watchSubs.keys.forEach(_facade.detach);

    _watchSubs.clear();
    super.dispose();
  }

  /// Disposes the repository/gateway stack as well (if you own it).
  Future<Either<ErrorItem, Unit>> disposeStack() => _facade.disposeAll();

  // ---------------------------------------------------------------------------
  // Internal state helpers
  // ---------------------------------------------------------------------------

  void _setLoading({required bool loading, String? docId}) {
    value = value.copyWith(
      docId: docId ?? value.docId,
      loading: loading,
      // keep current doc/error
    );
  }

  void _setError(ErrorItem err) {
    value = value.copyWith(error: err);
  }

  void _setDoc({required String docId, required T doc}) {
    value = value.copyWith(
      docId: docId,
      doc: doc,
      error: null,
    );
  }

  void _setWatching({required bool isWatching, String? docId}) {
    value = value.copyWith(
      docId: docId ?? value.docId,
      isWatching: isWatching,
    );
  }
}
