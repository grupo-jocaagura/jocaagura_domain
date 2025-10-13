import 'dart:async';

import '../../jocaagura_domain.dart';

/// JSON-first gateway over a [ServiceWsDb] that **multiplexes one backend
/// subscription per `docId`** and exposes results as `Either<ErrorItem, ...>`.
///
/// This gateway keeps a **shared** [BlocGeneral] channel per `docId` so that
/// multiple watchers do not duplicate the underlying `ServiceWsDb.documentStream`
/// subscription. It injects the logical identifier back into the payload under
/// [idKey] (unless the server already provides that field).
///
/// ## Lifecycle & Responsibilities
/// - Calling [watch] **increments** an internal reference counter for `docId`.
/// - The **caller is responsible** for eventually invoking [detachWatch] once
///   *all* subscriptions created via that `watch(docId)` have been cancelled.
///   Not doing so will keep the shared channel and the underlying backend
///   subscription alive until [releaseDoc] or [dispose] is invoked.
/// - [releaseDoc] forces immediate cleanup for a single `docId` regardless of
///   outstanding references (useful on logout or test teardown).
/// - [dispose] performs global teardown of all channels and should be called
///   when the gateway is no longer needed (e.g., app shutdown, test end).
///
/// > Important: cancelling a StreamSubscription returned by [watch] does **not**
/// > imply automatic detachment. You **must** call [detachWatch(docId)] to
/// > decrement the internal reference counter and allow the channel to close
/// > when it reaches zero.
///
/// ## Configuration
/// - [idKey] (default `'id'`): JSON key used to expose `docId`.
/// - [readAfterWrite] (default `false`): if `true`, `write()` performs a round-trip
///   `read()` and returns the authoritative payload.
/// - [treatEmptyAsMissing] (default `false`): if `true`, empty `{}` snapshots
///   are mapped to `Left(DatabaseErrorItems.notFound)`.
///
/// ## Error mapping
/// All failures are mapped using [ErrorMapper]:
/// - `fromPayload(json, location)` for business errors encoded in payloads.
/// - `fromException(error, stack, location)` for thrown exceptions.
///
/// ## Usage pattern
/// ```dart
/// final sub = gateway.watch('doc1').listen(onEvent, onError: onErr);
/// // ... later ...
/// await sub.cancel();        // 1) stop listening
/// gateway.detachWatch('doc1'); // 2) explicit detach (required)
/// ```
///
/// ## Anti-pattern
/// ```dart
/// final sub = gateway.watch('doc1').listen(onEvent);
/// await sub.cancel();           // ❌ Forgetting detach keeps channel alive
/// // gateway.detachWatch('doc1'); // Missing: channel not released
/// ```
/// ### Quick checklist
/// [ ] Keep a reference to your StreamSubscription(s) from watch(docId).
/// [ ] Call `await sub.cancel()` when you stop observing.
/// [ ] Immediately call `gateway.detachWatch(docId)` after cancelling the last subscription.
/// [ ] On forced flows (logout/test teardown), consider `gateway.releaseDoc(docId)`.
/// [ ] On global shutdown, call `gateway.dispose()` exactly once.
///
/// 🚫 Do not rely on subscription cancel to auto-detach — it is caller-managed by design.
class GatewayWsDbImpl implements GatewayWsDatabase {
  /// Creates a JSON-first gateway over a [ServiceWsDb].
  ///
  /// - [service]: underlying database service (`Map<String, dynamic>` payloads).
  /// - [collection]: collection name used to scope all operations.
  /// - [mapper]: optional [ErrorMapper]; defaults to [DefaultErrorMapper].
  /// - [idKey]: JSON key used to publish the `docId` when it is not present.
  /// - [readAfterWrite]: if `true`, `write()` returns the **service-saved snapshot**
  ///   from `saveDocument` (server-normalized) instead of echoing the input JSON.
  ///   This avoids an extra round-trip read while still returning authoritative data.
  /// - [treatEmptyAsMissing]: if `true`, empty `{}` snapshots are treated as "not found".
  GatewayWsDbImpl({
    required ServiceWsDb service,
    required String collection,
    ErrorMapper? mapper,
    String idKey = defaultIdKey,
    bool readAfterWrite = false,
    bool treatEmptyAsMissing = false,
  })  : _service = service,
        _collection = collection,
        _mapper = mapper ?? const DefaultErrorMapper(),
        _idKey = idKey,
        _readAfterWrite = readAfterWrite,
        _treatEmptyAsMissing = treatEmptyAsMissing;

  /// Default JSON key used to publish the document id in successful payloads.
  static const String defaultIdKey = 'id';

  /// Underlying JSON database service.
  final ServiceWsDb _service;

  /// Collection name this gateway operates on.
  final String _collection;

  /// Maps exceptions/payloads into [ErrorItem]s.
  final ErrorMapper _mapper;

  /// JSON key used to inject `docId` when server does not provide it.
  final String _idKey;

  /// When `true`, `write()` executes a `read()` and returns that payload.
  final bool _readAfterWrite;

  /// When `true`, `{}` snapshots are mapped to [DatabaseErrorItems.notFound].
  final bool _treatEmptyAsMissing;

  /// Per-document channel registry (one [BlocGeneral] + service subscription per `docId`).
  final Map<String, _DocChannel> _channels = <String, _DocChannel>{};

  /// Internal disposed flag used to guard calls after [dispose].
  bool _isDisposed = false;

  /// Reads a document by [docId].
  ///
  /// Returns:
  /// - `Right(json ∪ {idKey: docId})` on success (server-provided `idKey` wins).
  /// - `Left(err)` if:
  ///   - [ErrorMapper.fromPayload] detects a business error in the payload, or
  ///   - an exception occurs (mapped with [ErrorMapper.fromException]), or
  ///   - when [treatEmptyAsMissing] is `true` and the payload is `{}`.
  ///
  /// Throws: never (errors are mapped to `Left`).
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String docId) async {
    _assertNotDisposed();
    try {
      final Map<String, dynamic> json = await _service.readDocument(
        collection: _collection,
        docId: docId,
      );

      final ErrorItem? payloadErr =
          _mapper.fromPayload(json, location: 'GatewayWsDatabase.read');
      if (payloadErr != null) {
        return Left<ErrorItem, Map<String, dynamic>>(payloadErr);
      }

      if (_treatEmptyAsMissing && json.isEmpty) {
        return Left<ErrorItem, Map<String, dynamic>>(
          DatabaseErrorItems.notFound,
        );
      }

      return Right<ErrorItem, Map<String, dynamic>>(_withId(docId, json));
    } catch (e, s) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _mapper.fromException(e, s, location: 'GatewayWsDatabase.read'),
      );
    }
  }

  /// Writes (creates/updates) a document with [docId] and JSON [json].
  ///
  /// Returns:
  /// - If [readAfterWrite] is `true`: `Right(_withId(docId, saved))`, where `saved`
  ///   is the server-normalized snapshot returned by [ServiceWsDb.saveDocument].
  ///   (No extra `read()` is performed.)
  /// - Otherwise: `Right(_withId(docId, json))`, preserving any server-provided `idKey`.
  ///
  /// Errors are mapped via [ErrorMapper.fromException].
  /// Throws: never (errors are mapped to `Left`).
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    String docId,
    Map<String, dynamic> json,
  ) async {
    _assertNotDisposed();
    try {
      final Map<String, dynamic> saved = await _service.saveDocument(
        collection: _collection,
        docId: docId,
        document: json,
      );
      if (_readAfterWrite) {
        return Right<ErrorItem, Map<String, dynamic>>(_withId(docId, saved));
      }
      return Right<ErrorItem, Map<String, dynamic>>(_withId(docId, json));
    } catch (e, s) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _mapper.fromException(e, s, location: 'GatewayWsDatabase.write'),
      );
    }
  }

  /// Deletes a document by [docId].
  ///
  /// Returns `Right(Unit.value)` on success; otherwise `Left(err)` via
  /// [ErrorMapper.fromException].
  ///
  /// Throws: never (errors are mapped to `Left`).
  @override
  Future<Either<ErrorItem, Unit>> delete(String docId) async {
    _assertNotDisposed();
    try {
      await _service.deleteDocument(collection: _collection, docId: docId);
      return Right<ErrorItem, Unit>(Unit.value);
    } catch (e, s) {
      return Left<ErrorItem, Unit>(
        _mapper.fromException(e, s, location: 'GatewayWsDatabase.delete'),
      );
    }
  }

  /// Returns the **shared** stream for [docId] and **increments** the
  /// per-document reference count.
  ///
  /// Emissions:
  /// - **Initial seed**: `Right({})` as the channel bootstrap value. This is emitted
  ///   regardless of [treatEmptyAsMissing]. Subsequent events come from the
  ///   underlying service.
  /// - Then: `Right(json ∪ {idKey: docId})` on valid payloads.
  /// - Or: `Left(err)` when:
  ///   - [ErrorMapper.fromPayload] detects business errors,
  ///   - the service reports an error (mapped via [ErrorMapper.fromException]),
  ///   - the source stream completes (`DatabaseErrorItems.streamClosed`).
  ///
  /// Note on [treatEmptyAsMissing]:
  /// - The `{}` → `notFound` mapping applies to **incoming service events**. The
  ///   initial seed `Right({})` is not converted.
  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch(String docId) {
    _assertNotDisposed();

    final _DocChannel channel = _channels.putIfAbsent(docId, () {
      final BlocGeneral<Either<ErrorItem, Map<String, dynamic>>> bloc =
          BlocGeneral<Either<ErrorItem, Map<String, dynamic>>>(
        Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{}),
      );

      return _DocChannel(
        bloc: bloc,
        sub: _service
            .documentStream(collection: _collection, docId: docId)
            .listen(
          (Map<String, dynamic> json) {
            final Either<ErrorItem, Map<String, dynamic>> event = _mapPayload(
              docId,
              json,
              location: 'GatewayWsDatabase.watch',
            );
            bloc.value = event;
          },
          onError: (Object error, StackTrace st) {
            final ErrorItem mapped = _mapper.fromException(
              error,
              st,
              location: 'GatewayWsDatabase.watch:onError',
            );
            bloc.value = Left<ErrorItem, Map<String, dynamic>>(mapped);
          },
          onDone: () {
            const ErrorItem closed = DatabaseErrorItems.streamClosed;
            bloc.value = Left<ErrorItem, Map<String, dynamic>>(closed);
          },
        ),
      );
    });

    channel.retain(); // ++refs
    return channel.bloc.stream;
  }

  /// Decrements the internal reference counter for [docId] and disposes the
  /// underlying per-doc channel (closing the backend subscription and the
  /// shared [BlocGeneral]) when the counter reaches zero.
  ///
  /// Caller responsibilities:
  /// - Invoke this **after** cancelling *all* subscriptions created via
  ///   [watch(docId)] from your component.
  /// - Safe to call multiple times; if the channel is not present, this is a no-op.
  @override
  void detachWatch(String docId) {
    final _DocChannel? ch = _channels[docId];
    if (ch == null) {
      return;
    }
    if (ch.release()) {
      ch.dispose();
      _channels.remove(docId);
    }
  }

  /// Forces immediate cleanup of the channel associated with [docId], regardless
  /// of its current reference count (useful for logout paths, navigation resets,
  /// or test teardown). Safe to call even if the doc is not currently watched.
  @override
  void releaseDoc(String docId) {
    final _DocChannel? ch = _channels.remove(docId);
    ch?.dispose();
  }

  /// Global teardown of the gateway. Disposes all active channels and prevents
  /// subsequent API calls (guarded by a debug `assert` in development builds).
  ///
  /// Notes:
  /// - This does **not** call [detachWatch] per doc; it directly disposes all
  ///   channels and clears internal state.
  /// - Treat the instance as terminal after calling this method.
  @override
  void dispose() {
    _isDisposed = true;
    for (final _DocChannel ch in _channels.values) {
      ch.dispose();
    }
    _channels.clear();
  }

  /// Injects the [docId] into [json] under [_idKey], **unless** the server
  /// already provided that field—in which case the server value is preserved.
  Map<String, dynamic> _withId(String docId, Map<String, dynamic> json) {
    if (json.containsKey(_idKey)) {
      return json;
    }
    return <String, dynamic>{...json, _idKey: docId};
  }

  /// Maps a raw JSON payload to `Either<ErrorItem, Map>`, applying:
  /// - [ErrorMapper.fromPayload] for business errors,
  /// - `{}` → `DatabaseErrorItems.notFound` when [treatEmptyAsMissing] is `true`,
  /// - otherwise injects `docId` via [_withId].
  Either<ErrorItem, Map<String, dynamic>> _mapPayload(
    String docId,
    Map<String, dynamic> json, {
    required String location,
  }) {
    final ErrorItem? payloadErr = _mapper.fromPayload(json, location: location);
    if (payloadErr != null) {
      return Left<ErrorItem, Map<String, dynamic>>(payloadErr);
    }
    if (_treatEmptyAsMissing && json.isEmpty) {
      return Left<ErrorItem, Map<String, dynamic>>(DatabaseErrorItems.notFound);
    }
    return Right<ErrorItem, Map<String, dynamic>>(_withId(docId, json));
  }

  /// Asserts the gateway has not been disposed. Intended for development builds.
  void _assertNotDisposed() {
    assert(!_isDisposed, 'GatewayWsDatabaseImpl is disposed');
  }
}

/// Internal per-document channel holding the shared [BlocGeneral] and the
/// single subscription to the underlying `ServiceWsDb.documentStream`.
///
/// Reference counting:
/// - [retain] increments watchers count,
/// - [release] decrements and returns `true` when the count reaches **zero**,
/// - [dispose] cancels the service subscription and disposes the bloc.
///
/// Errors and completion are propagated to the outer gateway as `Left(...)`
/// values according to the mapping rules in [GatewayWsDbImpl.watch].
class _DocChannel {
  _DocChannel({required this.bloc, required this.sub});

  /// Shared reactive channel for this `docId`.
  final BlocGeneral<Either<ErrorItem, Map<String, dynamic>>> bloc;

  /// Single subscription to the service's `documentStream`.
  final StreamSubscription<Map<String, dynamic>> sub;

  int _refs = 0;

  /// Increments the watcher reference count.
  void retain() {
    _refs += 1;
  }

  /// Decrements the watcher reference count.
  ///
  /// Returns `true` when the count reaches **zero** (caller should dispose).
  /// Caller responsibility: ensure `retain()`/`release()` are balanced per watch lifecycle.
  bool release() {
    _refs -= 1;
    return _refs <= 0;
  }

  /// Disposes this per-document channel:
  /// - Cancels the single subscription to the underlying service stream.
  /// - Disposes the shared [BlocGeneral] used by all watchers of this `docId`.
  ///
  /// Called by the gateway when the reference count reaches zero or on global teardown.
  void dispose() {
    bloc.dispose();
    sub.cancel();
  }
}
