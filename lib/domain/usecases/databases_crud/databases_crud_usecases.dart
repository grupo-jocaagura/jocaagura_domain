part of '../../../../jocaagura_domain.dart';

/// Defines a base interface for stream-oriented use cases.
///
/// Mirrors the shape of [`UseCase<R, P>`] but returns a `Stream<T>`
/// instead of a `Future<R>`. Use it for real-time/watch operations.
///
/// Contracts:
/// - Implementations must be cold or well-documented if hot.
/// - Cancellation must not leak resources; document lifecycle notes.
///
/// See also: [WatchDocUseCase].
abstract class StreamUseCase<T, P> {
  Stream<T> call(P params);
}

/// Parameters for read-like operations (single document).
///
/// Contracts:
/// - [docId] must be a non-empty string.
///
/// Example:
/// ```dart
/// void main() {
///   const ReadParams p = ReadParams('u1');
///   print(p.docId);
/// }
/// ```
class ReadParams {
  const ReadParams(this.docId);
  final String docId;
}

/// Parameters for write (upsert) operations.
///
/// Contracts:
/// - [docId] must be a non-empty string.
/// - [entity] must be a valid domain model (server-side validation may apply).
///
/// Example:
/// ```dart
/// void main() {
///   final WriteParams<UserModel> p = WriteParams<UserModel>('u1', defaultUser);
///   print('${p.docId} -> ${p.entity}');
/// }
/// ```
class WriteParams<T extends Model> {
  const WriteParams(this.docId, this.entity);
  final String docId;
  final T entity;
}

/// Parameters for delete operations.
///
/// Contracts:
/// - [docId] must be a non-empty string.
///
/// Example:
/// ```dart
/// void main() {
///   const DeleteParams p = DeleteParams('u1');
///   print(p.docId);
/// }
/// ```
class DeleteParams {
  const DeleteParams(this.docId);
  final String docId;
}

/// Parameters for watch (real-time) operations on a single document.
///
/// Contracts:
/// - [docId] must be a non-empty string.
/// - The caller is responsible for stream cancellation and for calling
///   `repo.detachWatch(docId)` after **all** subscriptions are canceled.
///
/// Example:
/// ```dart
/// void main() {
///   const WatchParams p = WatchParams('u1');
///   print(p.docId);
/// }
/// ```
class WatchParams {
  const WatchParams(this.docId);
  final String docId;
}

/// Parameters for read–modify–write mutations (pure transformation).
///
/// Contracts:
/// - [docId] must be a non-empty string.
/// - [transform] must be a **pure** function: no side effects, deterministic.
///
/// Example:
/// ```dart
/// void main() {
///   final MutateParams<UserModel> p = MutateParams<UserModel>(
///     'u1',
///     (u) => u.copyWith(displayName: 'Alice'),
///   );
///   print(p.docId);
/// }
/// ```
class MutateParams<T extends Model> {
  const MutateParams(this.docId, this.transform);
  final String docId;

  /// Pure function that transforms the current entity into a new one.
  final T Function(T current) transform;
}

/// Parameters for JSON patch operations (partial merge).
///
/// Contracts:
/// - [docId] must be a non-empty string.
/// - [patch] keys must match the entity JSON schema expected by `fromJson`.
///
/// Example:
/// ```dart
/// void main() {
///   const PatchParams p = PatchParams('u1', <String, dynamic>{'displayName': 'Alice'});
///   print('${p.docId} -> ${p.patch}');
/// }
/// ```
class PatchParams {
  const PatchParams(this.docId, this.patch);
  final String docId;

  /// Partial JSON to merge into the current entity's JSON representation.
  final Map<String, dynamic> patch;
}

/// Parameters for ensuring a document exists (optionally updating if present).
///
/// Semantics:
/// - Creates a new entity with [create] if the document is missing.
/// - If it exists and [updateIfExists] is provided, updates it and returns the new value.
/// - Otherwise, returns the current value.
///
/// Contracts:
/// - [docId] non-empty.
/// - [create] returns a valid `T`.
/// - If provided, [updateIfExists] must be pure and deterministic.
///
/// Example:
/// ```dart
/// void main() {
///   final EnsureParams<UserModel> p = EnsureParams<UserModel>(
///     docId: 'u1',
///     create: () => defaultUser,
///     updateIfExists: (u) => u.copyWith(flag: true),
///   );
///   print(p.docId);
/// }
/// ```
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

/// Parameters for multi-read operations (by ids).
///
/// Contracts:
/// - [ids] must not be empty; each id must be a non-empty string.
///
/// Example:
/// ```dart
/// void main() {
///   const ReadManyParams p = ReadManyParams(<String>['u1','u2']);
///   print(p.ids.length);
/// }
/// ```
class ReadManyParams {
  const ReadManyParams(this.ids);
  final List<String> ids;
}

/// Parameters for multi-write (upsert) operations.
///
/// Semantics:
/// - Keys are document ids; values are the entities to upsert.
/// - Execution order may matter for deterministic tests; see use case docs.
///
/// Contracts:
/// - [entries] must not be empty; keys must be non-empty.
///
/// Example:
/// ```dart
/// void main() {
///   final WriteManyParams<UserModel> p = WriteManyParams<UserModel>(
///     <String, UserModel>{'u1': defaultUser},
///   );
///   print(p.entries.keys.first);
/// }
/// ```
class WriteManyParams<T extends Model> {
  const WriteManyParams(this.entries);

  /// Map of docId -> entity
  final Map<String, T> entries;
}

/// Parameters for multi-delete operations.
///
/// Contracts:
/// - [ids] must not be empty; each id must be a non-empty string.
///
/// Example:
/// ```dart
/// void main() {
///   const DeleteManyParams p = DeleteManyParams(<String>['u1','u2']);
///   print(p.ids);
/// }
/// ```
class DeleteManyParams {
  const DeleteManyParams(this.ids);
  final List<String> ids;
}

// ---------------------------------------------------------------------------
//  1) ReadDocUseCase
// ---------------------------------------------------------------------------

/// Reads a single entity `T` by [ReadParams.docId].
///
/// Returns:
/// - `Right(T)` on success.
/// - `Left(ErrorItem)` on failure (including `DB_NOT_FOUND`).
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryWsDatabase<UserModel> repo = MyRepo<UserModel>();
///   final result = await ReadDocUseCase<UserModel>(repo).call(const ReadParams('u1'));
///   result.fold(
///     (e) => print('read error: ${e.code}'),
///     (u) => print('user: ${u.email}'),
///   );
/// }
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
/// Returns:
/// - `Right(T)` with the authoritative value returned by the repository.
/// - `Left(ErrorItem)` on failure.
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryWsDatabase<UserModel> repo = MyRepo<UserModel>();
///   final res = await WriteDocUseCase<UserModel>(repo)
///       .call(WriteParams<UserModel>('u1', defaultUser));
///   res.fold(
///     (e) => print('write error: ${e.code}'),
///     (u) => print('saved: ${u.id}'),
///   );
/// }
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
/// Returns:
/// - `Right(Unit)` on success.
/// - `Left(ErrorItem)` on failure (including `DB_NOT_FOUND`).
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryWsDatabase<UserModel> repo = MyRepo<UserModel>();
///   final res = await DeleteDocUseCase<UserModel>(repo).call(const DeleteParams('u1'));
///   res.fold(
///     (e) => print('delete error: ${e.code}'),
///     (_) => print('deleted'),
///   );
/// }
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
/// - `Right(_)`                 → `Right(true)`
/// - `Left(DB_NOT_FOUND)`       → `Right(false)`
/// - `Left(other error)`        → propagate as `Left`
///
/// Contracts:
/// - Repository must signal not-found with `DatabaseErrorItems.notFound.code`.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final res = await ExistsDocUseCase<UserModel>(repo).call(const ReadParams('u1'));
///   res.fold(
///     (e) => print('exists error: ${e.code}'),
///     (exists) => print('exists? $exists'),
///   );
/// }
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
        return Right<ErrorItem, bool>(false);
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
/// Returns:
/// - `Right(T)` with either the stored or default entity.
/// - `Left(ErrorItem)` for errors other than not-found.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final res = await ReadOrDefaultUseCase<UserModel>(
///     repo,
///     orElse: () => defaultUser,
///   ).call(const ReadParams('u1'));
///   res.fold(
///     (e) => print('read error: ${e.code}'),
///     (u) => print('user: ${u.id}'),
///   );
/// }
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
/// Lifecycle:
/// - After canceling **all** subscriptions for a given `docId`, callers **must**
///   invoke `repo.detachWatch(docId)` to allow the gateway to release resources.
/// - The stream is cold/hot depending on repository semantics.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final stream = WatchDocUseCase<UserModel>(repo).call(const WatchParams('u1'));
///   final sub = stream.listen((either) {
///     either.fold(
///       (e) => print('watch error: ${e.code}'),
///       (u) => print('update: ${u.id}'),
///     );
///   });
///
///   // ... later
///   await sub.cancel();
///   repo.detachWatch('u1');
/// }
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

/// Awaits until a watched document satisfies a predicate, then completes.
///
/// Semantics:
/// - Subscribes to `watch(docId)` and resolves on the first `Right(T)`
///   where `predicate(entity)` is `true`.
/// - On stream `Left(ErrorItem)` or `onError`, completes with `Left`.
/// - Cancels its own subscription before completing.
/// - **Does not** call `detachWatch(docId)` (caller owns lifecycle).
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final r = await WatchDocUntilUseCase<UserModel>(
///     repo,
///     predicate: (u) => u.status == 'ready',
///   ).call(const WatchParams('u1'));
///   r.fold(
///     (e) => print('until error: ${e.code}'),
///     (u) => print('ready: ${u.id}'),
///   );
/// }
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

    sub = _repo.watch(params.docId).listen(
      (Either<ErrorItem, T> e) {
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
      },
      onError: (Object error, StackTrace st) {
        if (!done.isCompleted) {
          final ErrorItem mapped = const DefaultErrorMapper().fromException(
            error,
            st,
            location: 'WatchDocUntilUseCase.onError',
          );
          done.complete(Left<ErrorItem, T>(mapped));
        }
      },
    );

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
/// Contracts:
/// - `transform` must be pure and deterministic.
/// - Concurrency: last-write-wins if no repository-level concurrency control.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final r = await MutateDocUseCase<UserModel>(repo).call(
///     MutateParams<UserModel>('u1', (u) => u.copyWith(displayName: 'Alice')),
///   );
///   r.fold(
///     (e) => print('mutate error: ${e.code}'),
///     (u) => print('updated: ${u.displayName}'),
///   );
/// }
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
/// 1) `read`
/// 2) `toJson()`
/// 3) shallow merge with [PatchParams.patch] (patch keys override)
/// 4) `fromJson(merged)`
/// 5) `write`
///
/// Returns:
/// - `Right(T)` with the updated entity.
/// - `Left(DB_NOT_FOUND)` if the document is missing.
/// - `Left(ErrorItem)` on other failures.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final r = await PatchDocFieldsUseCase<UserModel>(
///     repo,
///     fromJson: (m) => UserModel.fromJson(m),
///   ).call(const PatchParams('u1', <String, dynamic>{'displayName': 'Alice'}));
///   r.fold(
///     (e) => print('patch error: ${e.code}'),
///     (u) => print('patched: ${u.displayName}'),
///   );
/// }
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
/// - Otherwise, returns the existing entity.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final r = await EnsureDocUseCase<UserModel>(repo).call(
///     EnsureParams<UserModel>(
///       docId: 'u1',
///       create: () => defaultUser,
///       updateIfExists: (u) => u.copyWith(flag: true),
///     ),
///   );
///   r.fold(
///     (e) => print('ensure error: ${e.code}'),
///     (u) => print('ensured: ${u.id}'),
///   );
/// }
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
/// Execution:
/// - Sequential for determinism (useful for tests and predictable ordering).
/// - Consider batching/pipelining at repository level for performance.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final r = await ReadManyDocsUseCase<UserModel>(repo)
///       .call(const ReadManyParams(<String>['u1','u2']));
///   r.fold(
///     (e) => print('read many error: ${e.code}'),
///     (map) => print('u1 -> ${map['u1']}'),
///   );
/// }
/// ```
class ReadManyDocsUseCase<T extends Model>
    implements
        UseCase<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>,
            ReadManyParams> {
  ReadManyDocsUseCase(this._repo, {ErrorMapper? mapper})
      : _mapper = mapper ?? const DefaultErrorMapper();

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
/// Execution:
/// - Sequential for determinism. For throughput, consider repository-level
///   bulk ops if available.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final r = await WriteManyDocsUseCase<UserModel>(repo)
///       .call(WriteManyParams<UserModel>(<String, UserModel>{
///         'u1': defaultUser,
///       }));
///   r.fold(
///     (e) => print('write many error: ${e.code}'),
///     (map) => print('u1 -> ${map['u1']}'),
///   );
/// }
/// ```
class WriteManyDocsUseCase<T extends Model>
    implements
        UseCase<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>,
            WriteManyParams<T>> {
  WriteManyDocsUseCase(this._repo, {ErrorMapper? mapper})
      : _mapper = mapper ?? const DefaultErrorMapper();

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
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final r = await DeleteManyDocsUseCase<UserModel>(repo)
///       .call(const DeleteManyParams(<String>['u1','u2']));
///   r.fold(
///     (e) => print('delete many error: ${e.code}'),
///     (map) => print('u1 -> ${map['u1']}'),
///   );
/// }
/// ```
class DeleteManyDocsUseCase<T extends Model>
    implements
        UseCase<Either<ErrorItem, Map<String, Either<ErrorItem, Unit>>>,
            DeleteManyParams> {
  DeleteManyDocsUseCase(this._repo, {ErrorMapper? mapper})
      : _mapper = mapper ?? const DefaultErrorMapper();

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
/// Semantics:
/// - Call this **after** canceling subscription(s) created via [WatchDocUseCase].
/// - Allows the gateway to close channels and free resources.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final sub = WatchDocUseCase<UserModel>(repo)
///       .call(const WatchParams('u1'))
///       .listen((_) {});
///   await sub.cancel();
///   await DetachWatchUseCase<UserModel>(repo).call(const DeleteParams('u1'));
/// }
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
        const DefaultErrorMapper().fromException(
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
/// Semantics:
/// - Stronger than `detachWatch`: force-release resources immediately.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   await ReleaseDocUseCase<UserModel>(repo).call(const DeleteParams('u1'));
/// }
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
        const DefaultErrorMapper().fromException(
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
///
/// Semantics:
/// - After this call, further repository operations are undefined and may throw.
/// - Idempotent disposal should be handled by the repository.
///
/// Example:
/// ```dart
/// void main() async {
///   final repo = MyRepo<UserModel>();
///   final r = await DisposeWsDatabaseUseCase<UserModel>(repo).call(const NoParams());
///   r.fold(
///     (e) => print('dispose error: ${e.code}'),
///     (_) => print('disposed'),
///   );
/// }
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
        const DefaultErrorMapper().fromException(
          e,
          s,
          location: 'DisposeWsDatabaseUseCase.call',
        ),
      );
    }
  }
}
