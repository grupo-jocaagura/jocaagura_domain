part of '../../../../jocaagura_domain.dart';

/// Optional base for stream-focused use cases.
/// Mirrors the shape of [UseCase] but returns a Stream.
abstract class StreamUseCase<T, P> {
  Stream<T> call(P params);
}

/// Parameters for read-like operations.
class ReadParams {
  const ReadParams(this.docId);
  final String docId;
}

/// Parameters for write (upsert) operations.
class WriteParams<T extends Model> {
  const WriteParams(this.docId, this.entity);
  final String docId;
  final T entity;
}

/// Parameters for delete operations.
class DeleteParams {
  const DeleteParams(this.docId);
  final String docId;
}

/// Parameters for watch operations.
class WatchParams {
  const WatchParams(this.docId);
  final String docId;
}

/// Parameters for mutate (read–modify–write) operations.
class MutateParams<T extends Model> {
  const MutateParams(this.docId, this.transform);
  final String docId;

  /// Pure function that transforms the current entity into a new one.
  final T Function(T current) transform;
}

/// Parameters for JSON patch operations.
class PatchParams {
  const PatchParams(this.docId, this.patch);
  final String docId;

  /// Partial JSON to merge into the current entity's JSON representation.
  final Map<String, dynamic> patch;
}

/// Parameters for ensuring existence of a document.
class EnsureParams<T extends Model> {
  const EnsureParams({
    required this.docId,
    required this.create,
    this.updateIfExists,
  });

  final String docId;

  /// Factory used when the document does not exist.
  final T Function() create;

  /// Optional transformation to apply when the document exists.
  final T Function(T current)? updateIfExists;
}

/// Parameters for multi-read operations.
class ReadManyParams {
  const ReadManyParams(this.ids);
  final List<String> ids;
}

/// Parameters for multi-write operations.
class WriteManyParams<T extends Model> {
  const WriteManyParams(this.entries);

  /// Map of docId -> entity
  final Map<String, T> entries;
}

/// Parameters for multi-delete operations.
class DeleteManyParams {
  const DeleteManyParams(this.ids);
  final List<String> ids;
}

// ---------------------------------------------------------------------------
//  1) ReadDocUseCase
// ---------------------------------------------------------------------------

/// Reads a single entity `T` by [ReadParams.docId].
///
/// Returns `Right(T)` on success or `Left(ErrorItem)` on failure.
///
/// Example:
/// ```dart
/// final result = await ReadDocUseCase<UserModel>(repo).call(ReadParams('u1'));
/// result.fold(print, (u) => print('user: $u'));
/// ```
class ReadDocUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, T>, ReadParams> {
  ReadDocUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Future<Either<ErrorItem, T>> call(ReadParams params) =>
      _repo.read(params.docId);
}

// ---------------------------------------------------------------------------
//  2) WriteDocUseCase (Upsert)
// ---------------------------------------------------------------------------

/// Writes (creates/updates) a single entity at [WriteParams.docId].
///
/// Returns the authoritative `T` as `Right(T)`; `Left(ErrorItem)` on failure.
///
/// Example:
/// ```dart
/// final res = await WriteDocUseCase<UserModel>(repo)
///     .call(WriteParams('u1', user));
/// ```
class WriteDocUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, T>, WriteParams<T>> {
  WriteDocUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Future<Either<ErrorItem, T>> call(WriteParams<T> params) =>
      _repo.write(params.docId, params.entity);
}

// ---------------------------------------------------------------------------
//  3) DeleteDocUseCase
// ---------------------------------------------------------------------------

/// Deletes a single entity by [DeleteParams.docId].
///
/// Returns `Right(Unit)` on success; `Left(ErrorItem)` on failure.
///
/// Example:
/// ```dart
/// final res = await DeleteDocUseCase<UserModel>(repo).call(DeleteParams('u1'));
/// ```
class DeleteDocUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, Unit>, DeleteParams> {
  DeleteDocUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Future<Either<ErrorItem, Unit>> call(DeleteParams params) =>
      _repo.delete(params.docId);
}

// ---------------------------------------------------------------------------
//  4) ExistsDocUseCase
// ---------------------------------------------------------------------------

/// Checks whether a document exists by attempting a read and mapping:
/// - `Right(_)`  -> `Right(true)`
/// - `Left(DB_NOT_FOUND)` -> `Right(false)`
/// - Other `Left(_)` -> propagate error
///
/// Example:
/// ```dart
/// final res = await ExistsDocUseCase<UserModel>(repo).call(ReadParams('u1'));
/// ```
class ExistsDocUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, bool>, ReadParams> {
  ExistsDocUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Future<Either<ErrorItem, bool>> call(ReadParams params) async {
    final Either<ErrorItem, T> r = await _repo.read(params.docId);
    return r.fold((ErrorItem err) {
      if (err.code == DatabaseErrorItems.notFound.code) {
        return  Right<ErrorItem, bool>(false);
      }
      return Left<ErrorItem, bool>(err);
    }, (_) {
      return Right<ErrorItem, bool>(true);
    });
  }
}

// ---------------------------------------------------------------------------
//  5) ReadOrDefaultUseCase
// ---------------------------------------------------------------------------

/// Reads `T` by `docId`; if not found, returns the provided default `T`.
///
/// Example:
/// ```dart
/// final res = await ReadOrDefaultUseCase<UserModel>(
///   repo,
///   orElse: () => defaultUser,
/// ).call(ReadParams('u1'));
/// ```
class ReadOrDefaultUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, T>, ReadParams> {
  ReadOrDefaultUseCase(this._repo, {required T Function() orElse})
      : _orElse = orElse;

  final RepositoryWsDatabase<T> _repo;
  final T Function() _orElse;

  @override
  Future<Either<ErrorItem, T>> call(ReadParams params) async {
    final Either<ErrorItem, T> r = await _repo.read(params.docId);
    return r.fold((ErrorItem err) {
      if (err.code == DatabaseErrorItems.notFound.code) {
        return Right<ErrorItem, T>(_orElse());
      }
      return Left<ErrorItem, T>(err);
    }, (T entity) {
      return Right<ErrorItem, T>(entity);
    });
  }
}

// ---------------------------------------------------------------------------
//  6) WatchDocUseCase (Stream)
// ---------------------------------------------------------------------------

/// Watches a document in real-time and emits `Either<ErrorItem, T>`.
///
/// IMPORTANT:
/// - After canceling the subscription(s), callers **must** invoke
///   `repo.detachWatch(docId)` to allow resource cleanup in the gateway.
///
/// Example:
/// ```dart
/// final stream = WatchDocUseCase<UserModel>(repo).call(WatchParams('u1'));
/// final sub = stream.listen((either) { ... });
/// // later:
/// await sub.cancel();
/// repo.detachWatch('u1');
/// ```
class WatchDocUseCase<T extends Model>
    implements StreamUseCase<Either<ErrorItem, T>, WatchParams> {
  WatchDocUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Stream<Either<ErrorItem, T>> call(WatchParams params) =>
      _repo.watch(params.docId);
}

// ---------------------------------------------------------------------------
//  7) WatchDocUntilUseCase
// ---------------------------------------------------------------------------

/// Awaits until a watched document satisfies a given predicate, then completes.
///
/// The stream subscription is automatically canceled when the predicate
/// is satisfied. **Does not** call `detachWatch`; callers should handle
/// lifecycle and call `repo.detachWatch(docId)` when appropriate.
///
/// Example:
/// ```dart
/// final res = await WatchDocUntilUseCase<UserModel>(
///   repo,
///   predicate: (u) => u.status == 'ready',
/// ).call(WatchParams('u1'));
/// ```
class WatchDocUntilUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, T>, WatchParams> {
  WatchDocUntilUseCase(this._repo, {required bool Function(T) predicate})
      : _predicate = predicate;

  final RepositoryWsDatabase<T> _repo;
  final bool Function(T) _predicate;

  @override
  Future<Either<ErrorItem, T>> call(WatchParams params) async {
    late final StreamSubscription<Either<ErrorItem, T>> sub;
    final Completer<Either<ErrorItem, T>> done =
        Completer<Either<ErrorItem, T>>();

    sub = _repo.watch(params.docId).listen((Either<ErrorItem, T> e) {
      e.fold((ErrorItem err) {
        // surface stream errors immediately
        if (!done.isCompleted) {
          done.complete(Left<ErrorItem, T>(err));
        }
      }, (T entity) {
        if (_predicate(entity) && !done.isCompleted) {
          done.complete(Right<ErrorItem, T>(entity));
        }
      });
    }, onError: (Object error, StackTrace st) {
      if (!done.isCompleted) {
        final ErrorItem mapped = DefaultErrorMapper()
            .fromException(error, st, location: 'WatchDocUntilUseCase.onError');
        done.complete(Left<ErrorItem, T>(mapped));
      }
    },);

    final Either<ErrorItem, T> result = await done.future;
    await sub.cancel();
    return result;
  }
}

// ---------------------------------------------------------------------------
//  8) MutateDocUseCase (read–modify–write)
// ---------------------------------------------------------------------------

/// Reads `T`, applies a pure transformation, then writes the result back.
///
/// Returns the updated entity or a mapped error.
///
/// Example:
/// ```dart
/// final res = await MutateDocUseCase<UserModel>(repo).call(
///   MutateParams('u1', (u) => u.copyWith(name: 'Alice')),
/// );
/// ```
class MutateDocUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, T>, MutateParams<T>> {
  MutateDocUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Future<Either<ErrorItem, T>> call(MutateParams<T> params) async {
    final Either<ErrorItem, T> r = await _repo.read(params.docId);
    return r.fold(
      (ErrorItem err) => Left<ErrorItem, T>(err),
      (T current) => _repo.write(params.docId, params.transform(current)),
    );
  }
}

// ---------------------------------------------------------------------------
//  9) PatchDocFieldsUseCase (JSON merge)
// ---------------------------------------------------------------------------

/// Performs a partial JSON merge on top of the current entity:
/// 1) Read `T`
/// 2) Convert to JSON via `toJson()`
/// 3) Merge the [PatchParams.patch] map (overrides keys)
/// 4) Map back to `T` (via repository parser) and write
///
/// Fails with `DB_NOT_FOUND` if document is missing.
///
/// Example:
/// ```dart
/// final res = await PatchDocFieldsUseCase<UserModel>(repo)
///     .call(PatchParams('u1', {'displayName': 'Alice'}));
/// ```
class PatchDocFieldsUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, T>, PatchParams> {
  PatchDocFieldsUseCase(
    this._repo, {
    required T Function(Map<String, dynamic>) fromJson,
  }) : _fromJson = fromJson;

  final RepositoryWsDatabase<T> _repo;
  final T Function(Map<String, dynamic>) _fromJson;

  @override
  Future<Either<ErrorItem, T>> call(PatchParams params) async {
    final Either<ErrorItem, T> r = await _repo.read(params.docId);
    return r.fold(
      (ErrorItem err) => Left<ErrorItem, T>(err),
      (T current) async {
        final Map<String, dynamic> merged = <String, dynamic>{
          ...current.toJson(),
          ...params.patch,
        };
        final T updated = _fromJson(merged);
        return _repo.write(params.docId, updated);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 10) EnsureDocUseCase (ensure existence; optional update if exists)
// ---------------------------------------------------------------------------

/// Ensures a document exists:
/// - If not found, creates it using [EnsureParams.create].
/// - If found and [EnsureParams.updateIfExists] is provided, updates it.
/// - Otherwise, returns the existing entity as-is.
///
/// Example:
/// ```dart
/// final res = await EnsureDocUseCase<UserModel>(repo).call(
///   EnsureParams<UserModel>(
///     docId: 'u1',
///     create: () => defaultUser,
///     updateIfExists: (u) => u.copyWith(flag: true),
///   ),
/// );
/// ```
class EnsureDocUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, T>, EnsureParams<T>> {
  EnsureDocUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Future<Either<ErrorItem, T>> call(EnsureParams<T> params) async {
    final Either<ErrorItem, T> r = await _repo.read(params.docId);
    return r.fold((ErrorItem err) async {
      if (err.code == DatabaseErrorItems.notFound.code) {
        return _repo.write(params.docId, params.create());
      }
      return Left<ErrorItem, T>(err);
    }, (T current) async {
      if (params.updateIfExists != null) {
        return _repo.write(params.docId, params.updateIfExists!(current));
      }
      return Right<ErrorItem, T>(current);
    });
  }
}

// ---------------------------------------------------------------------------
// 11) ReadManyDocsUseCase
// ---------------------------------------------------------------------------

/// Reads multiple documents and returns a per-id result map:
/// `Right({ id: Either<ErrorItem, T>, ... })`
///
/// The overall operation succeeds unless an unexpected exception occurs.
///
/// Example:
/// ```dart
/// final res = await ReadManyDocsUseCase<UserModel>(repo)
///     .call(ReadManyParams(['u1','u2']));
/// ```
class ReadManyDocsUseCase<T extends Model>
    implements
        UseCase<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>,
            ReadManyParams> {
  ReadManyDocsUseCase(this._repo, {ErrorMapper? mapper})
      : _mapper = mapper ?? DefaultErrorMapper();

  final RepositoryWsDatabase<T> _repo;
  final ErrorMapper _mapper;

  @override
  Future<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>> call(
    ReadManyParams params,
  ) async {
    try {
      final Map<String, Either<ErrorItem, T>> out =
          <String, Either<ErrorItem, T>>{};
      for (final String id in params.ids) {
        out[id] = await _repo.read(id);
      }
      return Right<ErrorItem, Map<String, Either<ErrorItem, T>>>(out);
    } catch (e, s) {
      return Left<ErrorItem, Map<String, Either<ErrorItem, T>>>(
        _mapper.fromException(e, s, location: 'ReadManyDocsUseCase.call'),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 12) WriteManyDocsUseCase
// ---------------------------------------------------------------------------

/// Writes multiple documents and returns a per-id result map:
/// `Right({ id: Either<ErrorItem, T>, ... })`
///
/// Execution is sequential for determinism (helps tests and ordering).
///
/// Example:
/// ```dart
/// final res = await WriteManyDocsUseCase<UserModel>(repo)
///     .call(WriteManyParams<UserModel>({'u1': user1, 'u2': user2}));
/// ```
class WriteManyDocsUseCase<T extends Model>
    implements
        UseCase<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>,
            WriteManyParams<T>> {
  WriteManyDocsUseCase(this._repo, {ErrorMapper? mapper})
      : _mapper = mapper ?? DefaultErrorMapper();

  final RepositoryWsDatabase<T> _repo;
  final ErrorMapper _mapper;

  @override
  Future<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>> call(
    WriteManyParams<T> params,
  ) async {
    try {
      final Map<String, Either<ErrorItem, T>> out =
          <String, Either<ErrorItem, T>>{};
      for (final MapEntry<String, T> e in params.entries.entries) {
        out[e.key] = await _repo.write(e.key, e.value);
      }
      return Right<ErrorItem, Map<String, Either<ErrorItem, T>>>(out);
    } catch (e, s) {
      return Left<ErrorItem, Map<String, Either<ErrorItem, T>>>(
        _mapper.fromException(e, s, location: 'WriteManyDocsUseCase.call'),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 13) DeleteManyDocsUseCase
// ---------------------------------------------------------------------------

/// Deletes multiple documents and returns a per-id result map:
/// `Right({ id: Either<ErrorItem, Unit>, ... })`
///
/// Example:
/// ```dart
/// final res = await DeleteManyDocsUseCase<UserModel>(repo)
///     .call(DeleteManyParams(['u1','u2']));
/// ```
class DeleteManyDocsUseCase<T extends Model>
    implements
        UseCase<Either<ErrorItem, Map<String, Either<ErrorItem, Unit>>>,
            DeleteManyParams> {
  DeleteManyDocsUseCase(this._repo, {ErrorMapper? mapper})
      : _mapper = mapper ?? DefaultErrorMapper();

  final RepositoryWsDatabase<T> _repo;
  final ErrorMapper _mapper;

  @override
  Future<Either<ErrorItem, Map<String, Either<ErrorItem, Unit>>>> call(
    DeleteManyParams params,
  ) async {
    try {
      final Map<String, Either<ErrorItem, Unit>> out =
          <String, Either<ErrorItem, Unit>>{};
      for (final String id in params.ids) {
        out[id] = await _repo.delete(id);
      }
      return Right<ErrorItem, Map<String, Either<ErrorItem, Unit>>>(out);
    } catch (e, s) {
      return Left<ErrorItem, Map<String, Either<ErrorItem, Unit>>>(
        _mapper.fromException(e, s, location: 'DeleteManyDocsUseCase.call'),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 14) DetachWatchUseCase
// ---------------------------------------------------------------------------

/// Decrements the watch ref-count for a given `docId`.
///
/// This call should follow subscription cancellation(s) on the corresponding
/// watch stream to allow the gateway to release resources.
///
/// Example:
/// ```dart
/// await sub.cancel();
/// await DetachWatchUseCase<UserModel>(repo).call(DeleteParams('u1'));
/// ```
class DetachWatchUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, Unit>, DeleteParams> {
  DetachWatchUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Future<Either<ErrorItem, Unit>> call(DeleteParams params) async {
    try {
      _repo.detachWatch(params.docId);
      return Right<ErrorItem, Unit>(Unit.value);
    } catch (e, s) {
      return Left<ErrorItem, Unit>(
        DefaultErrorMapper().fromException(
          e,
          s,
          location: 'DetachWatchUseCase.call',
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 15) ReleaseDocUseCase
// ---------------------------------------------------------------------------

/// Forces immediate cleanup of a document channel (logout/teardown/tests).
///
/// Example:
/// ```dart
/// await ReleaseDocUseCase<UserModel>(repo).call(DeleteParams('u1'));
/// ```
class ReleaseDocUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, Unit>, DeleteParams> {
  ReleaseDocUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Future<Either<ErrorItem, Unit>> call(DeleteParams params) async {
    try {
      _repo.releaseDoc(params.docId);
      return Right<ErrorItem, Unit>(Unit.value);
    } catch (e, s) {
      return Left<ErrorItem, Unit>(
        DefaultErrorMapper().fromException(
          e,
          s,
          location: 'ReleaseDocUseCase.call',
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 16) DisposeWsDatabaseUseCase
// ---------------------------------------------------------------------------

/// Disposes the repository/gateway stack gracefully.
/// After this, further repository calls are undefined.
///
/// Example:
/// ```dart
/// await DisposeWsDatabaseUseCase<UserModel>(repo).call(const NoParams());
/// ```
class DisposeWsDatabaseUseCase<T extends Model>
    implements UseCase<Either<ErrorItem, Unit>, NoParams> {
  DisposeWsDatabaseUseCase(this._repo);
  final RepositoryWsDatabase<T> _repo;

  @override
  Future<Either<ErrorItem, Unit>> call(NoParams params) async {
    try {
      _repo.dispose();
      return Right<ErrorItem, Unit>(Unit.value);
    } catch (e, s) {
      return Left<ErrorItem, Unit>(
        DefaultErrorMapper().fromException(
          e,
          s,
          location: 'DisposeWsDatabaseUseCase.call',
        ),
      );
    }
  }
}
