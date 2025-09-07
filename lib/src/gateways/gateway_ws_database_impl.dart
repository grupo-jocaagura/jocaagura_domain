import 'dart:async';

import '../../jocaagura_domain.dart';

/// Generic, JSON-first implementation of [GatewayWsDatabase] that multiplexes
/// a **single** underlying `ServiceWsDatabase` stream per `docId` using
/// [BlocGeneral].
///
/// ### Highlights
/// - **One service subscription per `docId`**: multiple watchers share the same
///   [BlocGeneral] channel to avoid duplicate backend subscriptions.
/// - **Either for success/failure**: all operations and the watch stream
///   surface `Either<ErrorItem, ...>`.
/// - **Id injection**: the returned JSON includes the `docId` under [idKey]
///   (unless the server already provided an `idKey` field).
/// - **Lifecycle**: calling [watch] increases a per-doc ref-count; you **must**
///   call [detachWatch] when you stop observing that `docId`. Use [releaseDoc]
///   for forced cleanup of a single doc, and [dispose] for global teardown.
///
/// ### Configuration
/// - [idKey] (default `'id'`): property name to inject into outgoing payloads
///   when the server does not include it.
/// - [readAfterWrite] (default `false`): when `true`, `write()` performs a
///   round-trip `read()` and returns the authoritative payload.
/// - [treatEmptyAsMissing] (default `false`): when `true`, `{}` snapshots are
///   converted to `Left(DatabaseErrorItems.notFound)`.
///
/// ### Example
/// ```dart
/// final service = FakeServiceWsDatabase();
/// final gateway = GatewayWsDatabaseImpl(
///   service: service,
///   collection: 'canvas',
///   mapper: DefaultErrorMapper(),
///   idKey: GatewayWsDatabaseImpl.defaultIdKey, // 'id'
///   readAfterWrite: false,
///   treatEmptyAsMissing: false,
/// );
///
/// // Write
/// final resWrite = await gateway.write('c1', {'name': 'Board'});
/// resWrite.fold(
///   (err) => print('write error: ${err.code}'),
///   (json) => print('saved: $json'), // contains {'id':'c1', ...}
/// );
///
/// // Watch (remember to detach!)
/// final sub = gateway.watch('c1').listen((either) {
///   either.fold(
///     (err) => print('watch error: ${err.code}'),
///     (json) => print('update: $json'),
///   );
/// });
///
/// // Later...
/// await sub.cancel();
/// gateway.detachWatch('c1'); // <— important: decrements ref-count
///
/// // Global teardown (tests/app shutdown)
/// gateway.dispose();
/// ```
class GatewayWsDatabaseImpl implements GatewayWsDatabase {
  /// Creates a gateway over a [ServiceWsDatabase] that stores JSON documents.
  ///
  /// - [service]: the underlying database service (JSON `Map<String, dynamic>`).
  /// - [collection]: collection name to scope operations.
  /// - [mapper]: optional [ErrorMapper]; defaults to [DefaultErrorMapper].
  /// - [idKey]: JSON key used to expose the `docId` in successful payloads.
  /// - [readAfterWrite]: when `true`, `write()` returns a fresh `read()` result.
  /// - [treatEmptyAsMissing]: when `true`, `{}` snapshots are treated as "not found".
  GatewayWsDatabaseImpl({
    required ServiceWsDatabase<Map<String, dynamic>> service,
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
  final ServiceWsDatabase<Map<String, dynamic>> _service;

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
  /// - `Right(json + {idKey: docId})` on success (keeps server-provided `idKey` if present).
  /// - `Left(...)` if the payload encodes a business error via [ErrorMapper.fromPayload],
  ///   or if an exception occurs (mapped with [ErrorMapper.fromException]).
  ///
  /// Behavior:
  /// - If [treatEmptyAsMissing] is `true` and the JSON is `{}`, returns
  ///   `Left(DatabaseErrorItems.notFound)`.
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
  /// - If [readAfterWrite] is `true`, performs an authoritative `read(docId)` and
  ///   returns its result.
  /// - Otherwise, returns the provided [json] with `{idKey: docId}` injected
  ///   (unless the server already provided an `idKey` field).
  ///
  /// Failures are mapped with [ErrorMapper.fromException].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    String docId,
    Map<String, dynamic> json,
  ) async {
    _assertNotDisposed();
    try {
      await _service.saveDocument(
        collection: _collection,
        docId: docId,
        document: json,
      );
      if (_readAfterWrite) {
        return read(docId); // authoritative
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
  /// Returns `Right(Unit.value)` on success; otherwise `Left(...)` mapped with
  /// [ErrorMapper.fromException].
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

  /// Returns the **shared** [BlocGeneral] stream for [docId] and **increments**
  /// the internal reference count for that document channel.
  ///
  /// Consumers (Repository/BLoC/UseCase) **must** call [detachWatch] once they
  /// cancel their subscription(s), so the gateway can release the underlying
  /// service subscription when no watchers remain.
  ///
  /// Emissions:
  /// - `Right(json + {idKey: docId})` on valid payloads.
  /// - `Left(...)` if the payload encodes a business error (via [ErrorMapper.fromPayload]),
  ///   on service errors (mapped with [ErrorMapper.fromException]), or when the
  ///   source stream completes (emits `DatabaseErrorItems.streamClosed`).
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

  /// Decrements the internal reference count for [docId] and disposes the
  /// underlying channel (closing the service subscription and the [BlocGeneral])
  /// when it reaches zero.
  ///
  /// Call this **after** canceling your `watch(docId)` subscription(s).
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

  /// Forces immediate cleanup of the channel associated with [docId]
  /// (e.g., logout, test teardown), regardless of its reference count.
  @override
  void releaseDoc(String docId) {
    final _DocChannel? ch = _channels.remove(docId);
    ch?.dispose();
  }

  /// Global teardown of the gateway. Disposes all active channels and prevents
  /// subsequent API calls (guarded by an [assert]).
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
      return json; // keep server value
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
/// single subscription to the underlying `ServiceWsDatabase` stream.
///
/// The channel uses a simple reference counter:
/// - [retain] increments watchers count,
/// - [release] decrements and returns `true` when count reaches zero,
/// - [dispose] cancels the service subscription and disposes the bloc.
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
  /// Returns `true` when reference count reaches **zero** (caller should dispose).
  bool release() {
    _refs -= 1;
    return _refs <= 0;
  }

  /// Cancels the underlying subscription and disposes the [BlocGeneral].
  void dispose() {
    bloc.dispose();
    sub.cancel();
  }
}
