part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// JSON-first contract for WebSocket-backed, NoSQL-like data access.
///
/// All methods and streams operate on `Map<String, dynamic>` payloads (`JsonMap`)
/// to standardize transport and simplify cross-layer contracts.
///
/// ## Error contracts
/// - All `collection`/`docId` MUST be non-empty → otherwise throws [ArgumentError].
/// - [readDocument] throws [StateError] if the document does not exist.
/// - [documentStream] remains open even if the document does not exist yet:
///   implementations MAY either emit no events until creation or emit an error
///   event and keep the stream open (document this behavior).
/// - [collectionStream] SHOULD emit an empty list when no documents exist and
///   treat non-existent collections as empty.
///
/// ## Return contracts
/// - [saveDocument] SHOULD return the persisted document snapshot (server-
///   normalized), including server timestamps/ids if applicable.
/// - [deleteDocument] SHOULD return an acknowledgment payload (e.g., `{ 'ok': true }`)
///   or the last known snapshot if available; document the chosen strategy.
///
/// Call [dispose] to release resources and close underlying streams.
/// Multiple calls to [dispose] SHOULD be no-ops.
abstract class ServiceWsDb {
  /// Create or replace a document in [collection] identified by [docId] with [document].
  ///
  /// Returns the persisted snapshot (server-normalized).
  ///
  /// Throws:
  /// - [ArgumentError] if [collection] or [docId] is empty.
  Future<Map<String, dynamic>> saveDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> document,
  });

  /// Read a single document [docId] from [collection].
  ///
  /// Returns the stored document snapshot.
  ///
  /// Throws:
  /// - [ArgumentError] if [collection] or [docId] is empty.
  /// - [StateError] if the document does not exist.
  Future<Map<String, dynamic>> readDocument({
    required String collection,
    required String docId,
  });

  /// Stream realtime updates of a single document [docId] from [collection].
  ///
  /// The stream remains open even if the document does not exist yet. Implementations
  /// MAY either:
  /// - emit nothing until the document is created, or
  /// - emit an error event (e.g., `StateError('not found')`) and keep the stream open.
  ///
  /// Throws:
  /// - [ArgumentError] if [collection] or [docId] is empty.
  Stream<Map<String, dynamic>> documentStream({
    required String collection,
    required String docId,
  });

  /// Stream realtime snapshots of all documents contained in [collection].
  ///
  /// Implementations SHOULD emit an empty list when no documents are present and
  /// treat non-existent collections as empty.
  ///
  /// Throws:
  /// - [ArgumentError] if [collection] is empty.
  Stream<List<Map<String, dynamic>>> collectionStream({
    required String collection,
  });

  /// Delete a single document [docId] from [collection].
  ///
  /// Returns an acknowledgment payload, e.g. `{ 'ok': true }`.
  ///
  /// Throws:
  /// - [ArgumentError] if [collection] or [docId] is empty.
  Future<Map<String, dynamic>> deleteDocument({
    required String collection,
    required String docId,
  });

  /// Release resources and close underlying controllers/streams where applicable.
  ///
  /// It is safe to call this multiple times; subsequent calls SHOULD be no-ops.
  void dispose();
}
