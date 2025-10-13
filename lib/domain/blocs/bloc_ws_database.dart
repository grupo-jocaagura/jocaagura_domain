part of '../../../../jocaagura_domain.dart';

/// Reactive BLoC for **document-centric** CRUD over a WebSocket-backed repository.
///
/// - Extends [BlocGeneral] to publish a single immutable [WsDbState] stream.
/// - Delegates all operations to a [FacadeWsDatabaseUsecases] (clean layering).
/// - Manages one or many `watch(docId)` subscriptions and detaches them
///   when stopped or on [dispose].
///
/// ### Semantics
/// - The BLoC publishes a **single** [WsDbState]: if multiple `docId` watches
///   are active, the **last incoming event wins** and updates `docId/doc/error`.
///   Prefer a single active document per BLoC instance in UI flows.
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
  /// - If a previous watch for the same [docId] exists, it is canceled first.
  /// - Updates state on each tick: sets `doc` or `error`.
  /// - When multiple watches are active, the **latest event** (from any watched
  ///   `docId`) will update the single [WsDbState] published by this BLoC.
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

  /// Stops a realtime watch for [docId] and detaches the underlying channel.
  /// Safe to call multiple times. When the last watch for the current `docId` is
  /// removed, `isWatching` is set to `false`.
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
  /// - Cancels all active watches and requests channel detachment.
  /// - Calls `super.dispose()` to close the [BlocGeneral] stream.
  ///
  /// Note:
  /// - Detach calls are intentionally **not awaited** (dispose is best-effort).
  ///   Add `// ignore: unawaited_futures` if your linter flags them.
  /// - This does **not** dispose the repository/gateway stack; use [disposeStack]
  ///   if this BLoC owns it.
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
      doc: value.doc,
      error: value.error,
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
      doc: value.doc,
      error: value.error,
    );
  }
}
