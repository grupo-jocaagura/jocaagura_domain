import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake in-memory WebSocket-like NoSQL database for raw JSON documents.
///
/// This implementation keeps **cohesion with [BlocGeneral]** by storing per-
/// collection controllers. It provides realistic semantics for tests/POCs:
/// - **Seed emission** on subscription (configurable)
/// - **Defensive deep copies** on write/emit (configurable)
/// - **Content-based deduplication** (configurable)
/// - **Deterministic ordering** for collection snapshots (configurable)
/// - **Optional simulated latency and errors**
///
/// > Note: This class works **exclusively** with `Map<String, dynamic>`.
/// For typed models, use a Gateway/Repository that maps `T ↔ Map`.
///
/// ### Example
/// ```dart
/// final FakeServiceWsDatabase db = FakeServiceWsDatabase(
///   config: const WsDbConfig(
///     emitInitial: true,
///     deepCopies: true,
///     dedupeByContent: true,
///     orderCollectionsByKey: true,
///   ),
/// );
///
/// await db.saveDocument(
///   collection: 'users',
///   docId: 'u1',
///   document: <String, dynamic>{'name': 'Alice', 'age': 30},
/// );
///
/// final Map<String, dynamic> doc = await db.readDocument(
///   collection: 'users',
///   docId: 'u1',
/// );
/// print(doc); // {name: Alice, age: 30}
///
/// // Watch a single document
/// final StreamSubscription sub = db
///     .documentStream(collection: 'users', docId: 'u1')
///     .listen((Map<String, dynamic> data) => print('doc: $data'));
///
/// // Later...
/// await sub.cancel();
/// db.dispose();
/// ```
class FakeServiceWsDatabase implements ServiceWsDatabase<Map<String, dynamic>> {
  /// Creates a fake database with the provided [config].
  FakeServiceWsDatabase({WsDbConfig config = defaultWsDbConfig})
      : _config = config,
        _collections =
            BlocGeneral<Map<String, BlocGeneral<Map<String, dynamic>>>>(
          <String, BlocGeneral<Map<String, dynamic>>>{},
        );

  /// Runtime configuration for behavior toggles.
  final WsDbConfig _config;

  /// Root controller: collection name → inner document controller.
  final BlocGeneral<Map<String, BlocGeneral<Map<String, dynamic>>>>
      _collections;

  bool _disposed = false;

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('FakeServiceWsDatabase has been disposed');
    }
  }

  @override
  Future<void> saveDocument({
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
  }

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

      // Seed
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

      // Seed
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

  /// Experimental: Emits full raw snapshots (docId -> JSON document).
  ///
  /// Not part of the base [ServiceWsDatabase] interface. Use for advanced
  /// scenarios or testing when a raw map is more convenient than a list.
  Stream<Map<String, Map<String, dynamic>>> collectionRawStream({
    required String collection,
  }) {
    _ensureNotDisposed();
    _validate(collection: collection);
    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);

    return Stream<Map<String, Map<String, dynamic>>>.multi(
        (StreamController<Map<String, Map<String, dynamic>>> ctrl) {
      Map<String, Map<String, dynamic>>? last;

      Map<String, Map<String, dynamic>> buildRaw(Map<String, dynamic> raw) {
        final List<MapEntry<String, dynamic>> entries = _orderedEntries(raw);

        final Map<String, Map<String, dynamic>> out =
            <String, Map<String, dynamic>>{};
        for (final MapEntry<String, dynamic> e in entries) {
          final Map<String, dynamic> doc = Utils.mapFromDynamic(e.value);
          out[e.key] = _config.deepCopies ? _deepCopyMap(doc) : doc;
        }
        return out;
      }

      void emit(Map<String, Map<String, dynamic>> value) {
        if (_config.dedupeByContent) {
          if (last != null && _deepEqualsRaw(last!, value)) {
            return;
          }
          last = _deepCopyRaw(value);
        }
        if (!ctrl.isClosed) {
          ctrl.add(value);
        }
      }

      // Seed
      if (_config.emitInitial) {
        emit(buildRaw(inner.value));
      }

      final StreamSubscription<Map<String, dynamic>> sub =
          inner.stream.listen((Map<String, dynamic> docs) {
        emit(buildRaw(docs));
      });

      ctrl.onCancel = () => sub.cancel();
    });
  }

  @override
  Future<void> deleteDocument({
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
    // If doc doesn't exist, deletion is idempotent (no error).
  }

  @override
  void dispose() {
    for (final BlocGeneral<Map<String, dynamic>> controller
        in _collections.value.values) {
      controller.dispose();
    }
    _collections.dispose();
    _disposed = true;
  }

  // --- internals -------------------------------------------------------------

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

  Map<String, Map<String, dynamic>> _deepCopyRaw(
    Map<String, Map<String, dynamic>> src,
  ) {
    final Map<String, Map<String, dynamic>> out =
        <String, Map<String, dynamic>>{};
    src.forEach((String k, Map<String, dynamic> v) {
      out[k] = _deepCopyMap(v);
    });
    return out;
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

  bool _deepEqualsRaw(
    Map<String, Map<String, dynamic>> a,
    Map<String, Map<String, dynamic>> b,
  ) {
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
      if (!_deepEqualsMap(a[k]!, b[k]!)) {
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
}
