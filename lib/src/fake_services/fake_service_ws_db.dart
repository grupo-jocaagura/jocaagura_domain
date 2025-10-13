import 'dart:async';

import '../../jocaagura_domain.dart';

/// In-memory, WebSocket-like NoSQL database for raw JSON (`Map<String, dynamic>`).
///
/// Behavior is aligned with [ServiceWsDb] contracts:
/// - `saveDocument` returns a server-normalized snapshot (here, the written payload).
/// - `readDocument` throws `StateError` if the document does not exist.
/// - `documentStream` stays open even if the document does not exist.
///   This implementation emits `{}` as the initial seed when `emitInitial` is true.
/// - `collectionStream` emits `[]` as the initial snapshot when empty; non-existent
///   collections are treated as empty.
///
/// Configuration toggles:
/// - `emitInitial`, `deepCopies`, `dedupeByContent`, `orderCollectionsByKey`,
///   `latency`, `throwOnSave`, `throwOnDelete`.
///
/// Disposal:
/// - `dispose()` is **idempotent** and releases all internal controllers.
///
/// This fake keeps **cohesion with [BlocGeneral]** using per-collection controllers
/// and realistic semantics for tests/POCs:
/// - **Seed emission** on subscription (`emitInitial`)
/// - **Defensive deep copies** on write/emit (`deepCopies`)
/// - **Content-based deduplication** (`dedupeByContent`)
/// - **Deterministic ordering** for collection snapshots (`orderCollectionsByKey`)
/// - **Optional simulated latency** and **forced errors** on save/delete
///
/// ### Contracts (aligned with [ServiceWsDb])
/// - `saveDocument` returns the **server-normalized snapshot** (aquí, el mismo
///   payload escrito, opcionalmente clonado).
/// - `readDocument` lanza `StateError` si el documento no existe.
/// - `documentStream` permanece abierto aunque el doc no exista (puede emitir nada
///   hasta que exista, o error y seguir abierto según se documente).
/// - `collectionStream` emite `[]` cuando no hay documentos (colección inexistente
///   se trata como vacía).
///
/// ### Error handling guidance
/// Esta clase **lanza** (`ArgumentError`, `StateError`) según contrato de Service.
/// En Clean Architecture, el **Gateway** debe **capturar y mapear** estas
/// excepciones a `ErrorItem` (ver `WsDbErrorMiniMapper` más abajo).
///
/// ### Example
/// ```dart
/// final FakeServiceWsDb db = FakeServiceWsDb(
///   config: const WsDbConfig(
///     emitInitial: true,
///     deepCopies: true,
///     dedupeByContent: true,
///     orderCollectionsByKey: true,
///     latency: Duration(milliseconds: 10),
///   ),
/// );
///
/// await db.saveDocument(
///   collection: 'users',
///   docId: 'u1',
///   document: <String, dynamic>{'name': 'Alice', 'age': 30},
/// );
///
/// final Map<String, dynamic> u1 = await db.readDocument(
///   collection: 'users',
///   docId: 'u1',
/// );
///
/// final StreamSubscription sub = db
///   .documentStream(collection: 'users', docId: 'u1')
///   .listen((Map<String, dynamic> data) => print('doc: $data'));
///
/// await sub.cancel();
/// db.dispose();
/// ```
class FakeServiceWsDb implements ServiceWsDb {
  /// Creates a fake database with the provided [config].
  FakeServiceWsDb({WsDbConfig config = defaultWsDbConfig})
      : _config = config,
        _collections =
            BlocGeneral<Map<String, BlocGeneral<Map<String, dynamic>>>>(
          <String, BlocGeneral<Map<String, dynamic>>>{},
        );

  /// Runtime configuration toggles.
  final WsDbConfig _config;

  /// Root controller: collection name → inner document controller (docId → JSON).
  final BlocGeneral<Map<String, BlocGeneral<Map<String, dynamic>>>>
      _collections;

  bool _disposed = false;

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('FakeServiceWsDb has been disposed');
    }
  }

  // ---------------------------------------------------------------------------
  // ServiceWsDb
  // ---------------------------------------------------------------------------

  /// {@macro ServiceWsDb.saveDocument}
  @override
  Future<Map<String, dynamic>> saveDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> document,
  }) async {
    _ensureNotDisposed();
    _validate(collection: collection, docId: docId);
    if (_config.throwOnSave) {
      throw StateError('Simulated save error');
    }
    if (_config.latency != Duration.zero) {
      await Future<void>.delayed(_config.latency);
    }

    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);
    final Map<String, dynamic> current = inner.value;

    final Map<String, dynamic> safeDoc =
        _config.deepCopies ? _deepCopyMap(document) : document;

    inner.value = <String, dynamic>{...current, docId: safeDoc};

    // Snapshot "server-normalized" (en este fake es el mismo payload).
    return _config.deepCopies ? _deepCopyMap(safeDoc) : safeDoc;
  }

  /// {@macro ServiceWsDb.readDocument}
  @override
  Future<Map<String, dynamic>> readDocument({
    required String collection,
    required String docId,
  }) async {
    _ensureNotDisposed();
    _validate(collection: collection, docId: docId);
    if (_config.latency != Duration.zero) {
      await Future<void>.delayed(_config.latency);
    }

    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);

    if (!inner.value.containsKey(docId)) {
      throw StateError('Document not found');
    }
    final Map<String, dynamic> doc = Utils.mapFromDynamic(inner.value[docId]);
    return _config.deepCopies ? _deepCopyMap(doc) : doc;
  }

  /// {@macro ServiceWsDb.documentStream}
  @override
  Stream<Map<String, dynamic>> documentStream({
    required String collection,
    required String docId,
  }) {
    _ensureNotDisposed();
    _validate(collection: collection, docId: docId);
    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);

    return Stream<Map<String, dynamic>>.multi(
        (StreamController<Map<String, dynamic>> ctrl) {
      Map<String, dynamic>? last;

      void emit(Map<String, dynamic> value) {
        final Map<String, dynamic> out =
            _config.deepCopies ? _deepCopyMap(value) : value;

        if (_config.dedupeByContent) {
          if (last != null && _deepEqualsMap(last!, out)) {
            return;
          }
          last = _deepCopyMap(out);
        }
        if (!ctrl.isClosed) {
          ctrl.add(out);
        }
      }

      // Seed (puede ser {} si aún no existe).
      if (_config.emitInitial) {
        final Map<String, dynamic> first =
            Utils.mapFromDynamic(inner.value[docId]);
        emit(first);
      }

      final StreamSubscription<Map<String, dynamic>> sub =
          inner.stream.listen((Map<String, dynamic> docs) {
        final Map<String, dynamic> v = Utils.mapFromDynamic(docs[docId]);
        emit(v);
      });

      ctrl.onCancel = () => sub.cancel();
    });
  }

  /// {@macro ServiceWsDb.collectionStream}
  @override
  Stream<List<Map<String, dynamic>>> collectionStream({
    required String collection,
  }) {
    _ensureNotDisposed();
    _validate(collection: collection);
    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);

    return Stream<List<Map<String, dynamic>>>.multi(
        (StreamController<List<Map<String, dynamic>>> ctrl) {
      List<Map<String, dynamic>>? last;

      List<Map<String, dynamic>> buildSnapshot(Map<String, dynamic> raw) {
        final List<MapEntry<String, dynamic>> entries = _orderedEntries(raw);

        final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
        for (final MapEntry<String, dynamic> e in entries) {
          final Map<String, dynamic> doc = Utils.mapFromDynamic(e.value);
          list.add(_config.deepCopies ? _deepCopyMap(doc) : doc);
        }
        return list;
      }

      void emit(List<Map<String, dynamic>> value) {
        if (_config.dedupeByContent) {
          if (last != null && _deepEqualsList(last!, value)) {
            return;
          }
          last = _deepCopyList(value);
        }
        if (!ctrl.isClosed) {
          ctrl.add(value);
        }
      }

      if (_config.emitInitial) {
        emit(buildSnapshot(inner.value));
      }

      final StreamSubscription<Map<String, dynamic>> sub =
          inner.stream.listen((Map<String, dynamic> docs) {
        emit(buildSnapshot(docs));
      });

      ctrl.onCancel = () => sub.cancel();
    });
  }

  /// {@macro ServiceWsDb.deleteDocument}
  @override
  Future<Map<String, dynamic>> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    _ensureNotDisposed();
    _validate(collection: collection, docId: docId);
    if (_config.throwOnDelete) {
      throw StateError('Simulated delete error');
    }
    if (_config.latency != Duration.zero) {
      await Future<void>.delayed(_config.latency);
    }

    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);
    final Map<String, dynamic> current = inner.value;

    if (current.containsKey(docId)) {
      final Map<String, dynamic> updated = <String, dynamic>{...current}
        ..remove(docId);
      inner.value = updated;
    }
    // Idempotente si no existe.
    return <String, dynamic>{'ok': true};
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    for (final BlocGeneral<Map<String, dynamic>> controller
        in _collections.value.values) {
      controller.dispose();
    }
    _collections.dispose();
    _disposed = true;
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  BlocGeneral<Map<String, dynamic>> _ensureCollection(String collection) {
    final Map<String, BlocGeneral<Map<String, dynamic>>> root =
        _collections.value;
    if (!root.containsKey(collection)) {
      final BlocGeneral<Map<String, dynamic>> inner =
          BlocGeneral<Map<String, dynamic>>(<String, dynamic>{});
      final Map<String, BlocGeneral<Map<String, dynamic>>> updated =
          <String, BlocGeneral<Map<String, dynamic>>>{...root}..[collection] =
              inner;
      _collections.value = updated;
      return inner;
    }
    return root[collection]!;
  }

  void _validate({required String collection, String? docId}) {
    if (collection.isEmpty) {
      throw ArgumentError('collection must not be empty');
    }
    if (docId != null && docId.isEmpty) {
      throw ArgumentError('docId must not be empty');
    }
  }

  List<MapEntry<String, dynamic>> _orderedEntries(Map<String, dynamic> raw) {
    final List<MapEntry<String, dynamic>> list = raw.entries.toList();
    if (_config.orderCollectionsByKey) {
      list.sort(
        (MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) =>
            a.key.compareTo(b.key),
      );
    }
    return list;
  }

  Map<String, dynamic> _deepCopyMap(Map<String, dynamic> src) {
    final Map<String, dynamic> out = <String, dynamic>{};
    src.forEach((String k, dynamic v) {
      out[k] = _deepCopyDynamic(v);
    });
    return out;
  }

  List<Map<String, dynamic>> _deepCopyList(List<Map<String, dynamic>> src) {
    return <Map<String, dynamic>>[
      for (final Map<String, dynamic> m in src) _deepCopyMap(m),
    ];
  }

  dynamic _deepCopyDynamic(dynamic v) {
    if (v is Map) {
      return _deepCopyMap(Utils.mapFromDynamic(v));
    } else if (v is List) {
      return <dynamic>[for (final dynamic x in v) _deepCopyDynamic(x)];
    }
    return v; // primitives
  }

  bool _deepEqualsMap(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (final String k in a.keys) {
      if (!b.containsKey(k)) {
        return false;
      }
      if (!_deepEqualsDynamic(a[k], b[k])) {
        return false;
      }
    }
    return true;
  }

  bool _deepEqualsList(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (!_deepEqualsMap(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }

  bool _deepEqualsDynamic(dynamic a, dynamic b) {
    if (identical(a, b)) {
      return true;
    }
    if (a is Map && b is Map) {
      return _deepEqualsMap(Utils.mapFromDynamic(a), Utils.mapFromDynamic(b));
    }
    if (a is List && b is List) {
      if (a.length != b.length) {
        return false;
      }
      for (int i = 0; i < a.length; i++) {
        if (!_deepEqualsDynamic(a[i], b[i])) {
          return false;
        }
      }
      return true;
    }
    return a == b;
  }

  /// Registers a side-effect function that will be invoked on every emission
  /// of the internal `_collections` stream.
  ///
  /// - [key]: Unique identifier for the registered function. Re-adding with the
  ///   same key replaces the previous function (implementation-dependent).
  /// - [function]: Callback invoked with the latest snapshot of `_collections`.
  ///   The snapshot represents the in-memory state driving the fake database.
  /// - [executeNow]: If `true`, the function is invoked immediately with the
  ///   current snapshot before returning.
  ///
  /// ### Contracts
  /// - The callback MUST be fast and side-effect safe; avoid heavy work on the
  ///   UI thread. If you need async work, schedule it explicitly.
  /// - The function MUST NOT throw; uncaught exceptions may break listeners.
  /// - Callbacks are keyed and can be replaced/removed via [deleteFunctionToProcessTValueOnStream].
  ///
  /// ### Example
  /// ```dart
  /// void main() {
  ///   final FakeServiceWsDb db = FakeServiceWsDb();
  ///   int hits = 0;
  ///
  ///   db.addFunctionToProcessTValueOnStream('count', (Map<String, dynamic> _) {
  ///     hits++;
  ///   }, true); // executeNow => runs once immediately
  ///
  ///   // Any operation that mutates `_collections` will trigger the hook.
  ///   db.saveDocument(collection: 'users', docId: 'u1', document: <String, dynamic>{'n':'A'});
  ///
  ///   // Later…
  ///   db.deleteFunctionToProcessTValueOnStream('count');
  ///   db.dispose();
  /// }
  /// ```
  void addFunctionToProcessTValueOnStream(
    String key,
    Function(Map<String, dynamic> val) function, [
    bool executeNow = false,
  ]) {
    _collections.addFunctionToProcessTValueOnStream(key, function, executeNow);
  }

  /// Removes a previously registered function identified by [key].
  ///
  /// If no function exists for [key], this is a no-op.
  ///
  /// ### Example
  /// ```dart
  /// db.deleteFunctionToProcessTValueOnStream('logger');
  /// ```
  void deleteFunctionToProcessTValueOnStream(String key) {
    _collections.deleteFunctionToProcessTValueOnStream(key);
  }

  /// Returns whether a function is currently registered for [key].
  ///
  /// Useful for debugging/guarding idempotent registrations.
  ///
  /// ### Example
  /// ```dart
  /// if (!db.containsFunctionToProcessValueOnStream('audit')) {
  ///   db.addFunctionToProcessTValueOnStream('audit', (Map<String, dynamic> s) { /* … */ });
  /// }
  /// ```
  bool containsFunctionToProcessValueOnStream(String key) {
    return _collections.containsKeyFunction(key);
  }
}
