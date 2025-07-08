import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake in-memory WebSocket-based NoSQL database for raw JSON documents.
///
/// - Works exclusively with `Map<String, dynamic>` JSON maps.
/// - Uses a single root `BlocGeneral` to manage per-collection controllers.
/// - Automatically initializes empty collections on first access.
/// - Emits `{}` for missing documents in streams.
/// - Supports optional artificial latency and simulated errors.
class FakeServiceWsDatabase implements ServiceWsDatabase<Map<String, dynamic>> {
  /// Creates a fake database.
  ///
  /// [latency] simulates backend delays.
  /// [throwOnSave] simulates errors during save/delete operations.
  FakeServiceWsDatabase({
    this.latency = Duration.zero,
    this.throwOnSave = false,
  }) : _collectionControllers =
            BlocGeneral<Map<String, BlocGeneral<Map<String, dynamic>>>>(
          <String, BlocGeneral<Map<String, dynamic>>>{},
        );

  /// Simulated latency for operations (default: none).
  final Duration latency;

  /// Simulate failures on save/delete when true (default: false).
  final bool throwOnSave;

  /// Root controller storing a map from collection names to their document controllers.
  final BlocGeneral<Map<String, BlocGeneral<Map<String, dynamic>>>>
      _collectionControllers;

  @override
  Future<void> saveDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> document,
  }) async {
    _validate(collection: collection, docId: docId);
    await Future<void>.delayed(latency);
    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);
    if (throwOnSave) {
      throw StateError('Simulated save error');
    }

    final Map<String, dynamic> current = inner.value;
    inner.value = <String, dynamic>{...current, docId: document};
  }

  @override
  Future<Map<String, dynamic>> readDocument({
    required String collection,
    required String docId,
  }) async {
    _validate(collection: collection, docId: docId);
    await Future<void>.delayed(latency);
    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);
    if (!inner.value.containsKey(docId)) {
      throw StateError('Document not found');
    }
    final Map<String, dynamic> doc = Utils.mapFromDynamic(inner.value[docId]);
    return doc;
  }

  @override
  Stream<Map<String, dynamic>> documentStream({
    required String collection,
    required String docId,
  }) {
    _validate(collection: collection, docId: docId);
    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);

    return inner.stream.map((Map<String, dynamic> docs) {
      return Utils.mapFromDynamic(docs[docId]);
    }).distinct();
  }

  @override
  Stream<List<Map<String, dynamic>>> collectionStream({
    required String collection,
  }) {
    _validate(collection: collection);
    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);

    return inner.stream.map((Map<String, dynamic> docs) {
      final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
      for (final MapEntry<String, dynamic> entry in docs.entries) {
        result.add(Utils.mapFromDynamic(entry.value));
      }
      return result;
    });
  }

  @override
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    _validate(collection: collection, docId: docId);
    await Future<void>.delayed(latency);
    final BlocGeneral<Map<String, dynamic>> inner =
        _ensureCollection(collection);

    if (throwOnSave) {
      throw StateError('Simulated delete error');
    }

    final Map<String, dynamic> current = inner.value;
    if (current.containsKey(docId)) {
      final Map<String, dynamic> updated = <String, dynamic>{...current}
        ..remove(docId);
      inner.value = updated;
    }
  }

  @override
  void dispose() {
    for (final BlocGeneral<Map<String, dynamic>> controller
        in _collectionControllers.value.values) {
      controller.dispose();
    }
    _collectionControllers.dispose();
  }

  /// Ensures a controller exists for [collection], creating it if absent.
  ///
  /// Throws [StateError] if [throwOnSave] is true and the collection is missing.
  BlocGeneral<Map<String, dynamic>> _ensureCollection(String collection) {
    final Map<String, BlocGeneral<Map<String, dynamic>>> rootMap =
        _collectionControllers.value;
    if (!rootMap.containsKey(collection)) {
      if (throwOnSave) {
        throw StateError('Collection not found');
      }
      // Create and register a new inner controller
      final BlocGeneral<Map<String, dynamic>> newInner =
          BlocGeneral<Map<String, dynamic>>(<String, dynamic>{});
      final Map<String, BlocGeneral<Map<String, dynamic>>> updatedRoot =
          <String, BlocGeneral<Map<String, dynamic>>>{...rootMap}
            ..[collection] = newInner;
      _collectionControllers.value = updatedRoot;
      return newInner;
    }
    return rootMap[collection]!;
  }

  /// Validates input parameters, throwing [ArgumentError] on invalid values.
  void _validate({required String collection, String? docId}) {
    if (collection.isEmpty) {
      throw ArgumentError('collection must not be empty');
    }
    if (docId != null && docId.isEmpty) {
      throw ArgumentError('docId must not be empty');
    }
  }
}
