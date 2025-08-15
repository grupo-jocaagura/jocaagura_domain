part of '../../../jocaagura_domain.dart';

/// Abstraction to access a JSON-like WebSocket database (canvas domain).
///
/// - Uses Either<ErrorItem, ...> for success/failure.
/// - Embeds the [docId] into the returned JSON under [idKey] (default: 'id').
/// - Maps thrown exceptions using [ErrorMapper].
abstract class GatewayWsDatabase {
  /// Reads a document by [docId]. Returns the raw JSON with [idKey] injected.
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String docId);

  /// Writes (create/update) a document. Returns the JSON considered authoritative:
  /// - if [readAfterWrite] is enabled, returns a fresh read;
  /// - otherwise returns the provided input (with [idKey] injected).
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    String docId,
    Map<String, dynamic> json,
  );

  /// Deletes a document. Returns [Unit] on success.
  Future<Either<ErrorItem, Unit>> delete(String docId);

  /// Watches a single document. Emits Either on each tick.
  /// - Right(json with [idKey])
  /// - Left(error) when the payload encodes a business error or on stream error
  ///   (the stream remains open if possible).
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch(String docId);

  void dispose();

  /// Cleans up resources related to [docId] (e.g. active listeners).
  void releaseDoc(String docId);

  /// Cleans up active watch on [docId], if any.
  void detachWatch(String docId);
}
