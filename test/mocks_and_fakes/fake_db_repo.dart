import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

class FakeDbRepo<T extends Model> implements RepositoryWsDatabase<T> {
  FakeDbRepo();

  // Handlers configurables por test
  Future<Either<ErrorItem, T>> Function(String docId)? onRead;
  Future<Either<ErrorItem, T>> Function(String docId, T entity)? onWrite;
  Future<Either<ErrorItem, Unit>> Function(String docId)? onDelete;
  Future<Either<ErrorItem, bool>> Function(String docId)? onExists;

  // Watch por docId
  final Map<String, StreamController<Either<ErrorItem, T>>> _watchCtrls =
      <String, StreamController<Either<ErrorItem, T>>>{};

  // Contadores / banderas para aserciones
  int detachCount = 0;
  int releaseCount = 0;
  bool disposed = false;

  // -- RepositoryWsDatabase<T> API -------------------------------------------

  @override
  Future<Either<ErrorItem, T>> read(String docId) {
    assert(onRead != null, 'Configura onRead en el test');
    return onRead!(docId);
  }

  @override
  Future<Either<ErrorItem, T>> write(String docId, T entity) {
    assert(onWrite != null, 'Configura onWrite en el test');
    return onWrite!(docId, entity);
  }

  @override
  Future<Either<ErrorItem, Unit>> delete(String docId) {
    assert(onDelete != null, 'Configura onDelete en el test');
    return onDelete!(docId);
  }

  @override
  Stream<Either<ErrorItem, T>> watch(String docId) {
    return (_watchCtrls[docId] ??=
            StreamController<Either<ErrorItem, T>>.broadcast())
        .stream;
  }

  @override
  void detachWatch(String docId) {
    detachCount += 1;
    // No cerramos el controller para permitir re-uso en pruebas.
  }

  @override
  void releaseDoc(String docId) {
    releaseCount += 1;
    _watchCtrls.remove(docId)?.close();
  }

  @override
  void dispose() {
    disposed = true;
    for (final StreamController<Either<ErrorItem, T>> c in _watchCtrls.values) {
      c.close();
    }
    _watchCtrls.clear();
  }

  // Emisor para los tests
  void emit(String docId, Either<ErrorItem, T> event) {
    final StreamController<Either<ErrorItem, T>>? c = _watchCtrls[docId];
    if (c != null && !c.isClosed) {
      c.add(event);
    }
  }
}
