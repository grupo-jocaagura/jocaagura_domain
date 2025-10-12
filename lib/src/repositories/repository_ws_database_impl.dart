import 'dart:async';

import '../../jocaagura_domain.dart';

/// Generic implementation of [RepositoryWsDatabase] backed by a [GatewayWsDatabase].
///
/// Maps typed entities `T extends Model` using `entity.toJson()` and a `fromJson`
/// parser injected via constructor. All stream operations re-expose the gateway
/// streams mapped to `T` (no custom streams are created).
///
/// ### Error handling
/// - Deserialization failures are wrapped as `Left(mapping_error)` via the
///   provided [ErrorMapper].
///
/// ### Concurrency
/// - When [serializeWrites] is `true`, `write/delete` operations are serialized
///   **per docId** using a minimal FIFO chain to avoid overlaps.
///
/// ### Example
/// ```dart
/// void main(){
/// final repo = RepositoryWsDatabaseImpl<UserModel>(
///   gateway: gateway,
///   fromJson: UserModel.fromJson,
///   mapper: DefaultErrorMapper(),
///   serializeWrites: true,
/// );
///
/// final res = await repo.write('u1', someUser);
/// final got = await repo.read('u1');
/// final sub = repo.watch('u1').listen(...);
/// }
/// ```
class RepositoryWsDatabaseImpl<T extends Model>
    implements RepositoryWsDatabase<T> {
  RepositoryWsDatabaseImpl({
    required GatewayWsDatabase gateway,
    required this.fromJson,
    ErrorMapper? mapper,
    bool serializeWrites = false,
  })  : _gateway = gateway,
        _mapper = mapper ?? const DefaultErrorMapper(),
        _serializeWrites = serializeWrites;

  final GatewayWsDatabase _gateway;
  final T Function(Map<String, dynamic>) fromJson;
  final ErrorMapper _mapper;
  final bool _serializeWrites;

  /// Wraps [fromJson] to return Either with robust mapping_error on failures.
  Either<ErrorItem, T> Function(Map<String, dynamic>) get _decode =>
      (Map<String, dynamic> json) {
        try {
          final T entity = fromJson(json);
          return Right<ErrorItem, T>(entity);
        } catch (e, s) {
          // Si tienes tipos estándar en tu dominio, usa 'mapping_error'
          return Left<ErrorItem, T>(
            _mapper.fromException(
              e,
              s,
              location: 'RepositoryWsDatabaseImpl._decode',
            ),
          );
        }
      };

  // Simple per-key FIFO for optional write/delete serialization.
  final Map<String, Future<void>> _queues = <String, Future<void>>{};
  bool _isDisposed = false;

  @override
  Future<Either<ErrorItem, T>> read(String docId) async {
    _assertNotDisposed();
    final Either<ErrorItem, Map<String, dynamic>> res =
        await _gateway.read(docId);
    return res.fold(
      (ErrorItem l) => Left<ErrorItem, T>(l),
      (Map<String, dynamic> json) => _decode(json),
    );
  }

  @override
  Future<Either<ErrorItem, T>> write(String docId, T entity) {
    _assertNotDisposed();
    return _enqueuePerDoc<T>(
      docId,
      () async {
        final Either<ErrorItem, Map<String, dynamic>> res =
            await _gateway.write(docId, entity.toJson());
        return res.fold(
          (ErrorItem l) => Left<ErrorItem, T>(l),
          (Map<String, dynamic> json) => _decode(json),
        );
      },
    );
  }

  @override
  Future<Either<ErrorItem, Unit>> delete(String docId) {
    _assertNotDisposed();
    return _enqueuePerDoc<Unit>(
      docId,
      () => _gateway.delete(docId),
    );
  }

  @override
  Stream<Either<ErrorItem, T>> watch(String docId) {
    _assertNotDisposed();
    // Re-expose the gateway stream mapped to T (no custom streams).
    return _gateway.watch(docId).map(
          (Either<ErrorItem, Map<String, dynamic>> e) => e.fold(
            (ErrorItem l) => Left<ErrorItem, T>(l),
            (Map<String, dynamic> json) => _decode(json),
          ),
        );
  }

  @override
  void detachWatch(String docId) {
    _gateway.detachWatch(docId);
  }

  @override
  void releaseDoc(String docId) {
    _gateway.releaseDoc(docId);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _queues.clear();
    _gateway.dispose();
  }

  void _assertNotDisposed() {
    assert(!_isDisposed, 'RepositoryWsDatabaseImpl is disposed');
  }

  Future<Either<ErrorItem, R>> _enqueuePerDoc<R>(
    String docId,
    Future<Either<ErrorItem, R>> Function() createTask,
  ) async {
    if (!_serializeWrites) {
      return createTask();
    }

    final Future<void> prev = _queues[docId] ?? Future<void>.value();
    final Completer<void> gate = Completer<void>();
    _queues[docId] = prev.then((_) => gate.future);

    try {
      await prev;
      return await createTask();
    } finally {
      if (!gate.isCompleted) {
        gate.complete();
      }
      if (identical(_queues[docId], gate.future)) {
        _queues.remove(docId);
      }
    }
  }
}
