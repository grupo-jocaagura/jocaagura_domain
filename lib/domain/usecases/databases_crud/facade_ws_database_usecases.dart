part of '../../../../jocaagura_domain.dart';

/// High-level facade bundling **all** WS-oriented use cases for a single
/// collection and entity type `T extends Model`.
///
/// This facade is a thin, discoverable layer for BLoCs/AppManager. It wires
/// the generic **document-centric** use cases that sit on top of a
/// `RepositoryWsDatabase<T>`. It exposes both:
/// - the **use case instances** (for composition), and
/// - **convenience methods** (for quick calls).
///
/// It does **not** create custom streams; streaming comes from the repository.
///
/// ### What’s included
/// - CRUD: read, write (upsert), delete
/// - Existence helpers: exists, readOrDefault (builder)
/// - Streaming: watch, watchUntil (builder), plus lifecycle helpers detach/release/dispose
/// - Mutations: mutate (read–modify–write), patchFields (JSON merge), ensure (create-if-missing)
/// - Batch: readMany, writeMany, deleteMany
///
/// ### Example
/// ```dart
/// final repo = RepositoryWsDatabaseImpl<UserModel>(
///   gateway: GatewayWsDatabaseImpl(
///     service: FakeServiceWsDatabase(),
///     collection: 'users',
///   ),
///   fromJson: UserModel.fromJson,
///   serializeWrites: true,
/// );
///
/// final facade = FacadeWsDatabaseUsecases<UserModel>.fromRepository(
///   repository: repo,
///   fromJson: UserModel.fromJson,
/// );
///
/// // Read
/// final r = await facade.readDoc('u1');
///
/// // Watch (remember to detach after cancel)
/// final sub = facade.watchDoc('u1').listen((either) { /* ... */ });
/// // ...
/// await sub.cancel();
/// facade.detach('u1');
///
/// // Mutate
/// final m = await facade.mutate(ReadParams('u1'), (u) => u.copyWith(displayName: 'Alice'));
///
/// // Teardown
/// await facade.disposeAll();
/// ```
class FacadeWsDatabaseUsecases<T extends Model> {
  /// Creates a facade with already-constructed use cases.
  ///
  /// Prefer using [fromRepository] for most scenarios.
  FacadeWsDatabaseUsecases({
    required this.repository,
    required this.read,
    required this.write,
    required this.delete,
    required this.exists,
    required this.watch,
    required this.mutate,
    required this.patchFields,
    required this.ensure,
    required this.readMany,
    required this.writeMany,
    required this.deleteMany,
    required this.detachWatch,
    required this.releaseDoc,
    required this.disposeUc,
    required this.readOrDefaultBuilder,
    required this.watchUntilBuilder,
  });

  /// Convenience factory wiring the common defaults from a repository.
  factory FacadeWsDatabaseUsecases.fromRepository({
    required RepositoryWsDatabase<T> repository,
    required T Function(Map<String, dynamic>) fromJson,
    ErrorMapper? myMapper,
  }) {
    final ErrorMapper mapper = myMapper ?? DefaultErrorMapper();

    final ReadDocUseCase<T> read = ReadDocUseCase<T>(repository);
    final WriteDocUseCase<T> write = WriteDocUseCase<T>(repository);
    final DeleteDocUseCase<T> delete = DeleteDocUseCase<T>(repository);
    final ExistsDocUseCase<T> exists = ExistsDocUseCase<T>(repository);
    final WatchDocUseCase<T> watch = WatchDocUseCase<T>(repository);
    final MutateDocUseCase<T> mutate = MutateDocUseCase<T>(repository);
    final PatchDocFieldsUseCase<T> patch =
        PatchDocFieldsUseCase<T>(repository, fromJson: fromJson);
    final EnsureDocUseCase<T> ensure = EnsureDocUseCase<T>(repository);
    final ReadManyDocsUseCase<T> readMany =
        ReadManyDocsUseCase<T>(repository, mapper: mapper);
    final WriteManyDocsUseCase<T> writeMany =
        WriteManyDocsUseCase<T>(repository, mapper: mapper);
    final DeleteManyDocsUseCase<T> deleteMany =
        DeleteManyDocsUseCase<T>(repository, mapper: mapper);
    final DetachWatchUseCase<T> detach = DetachWatchUseCase<T>(repository);
    final ReleaseDocUseCase<T> release = ReleaseDocUseCase<T>(repository);
    final DisposeWsDatabaseUseCase<T> dispose =
        DisposeWsDatabaseUseCase<T>(repository);

    ReadOrDefaultUseCase<T> readOrDefaultBuilder(T Function() orElse) {
      return ReadOrDefaultUseCase<T>(repository, orElse: orElse);
    }

    WatchDocUntilUseCase<T> watchUntilBuilder(bool Function(T) predicate) {
      return WatchDocUntilUseCase<T>(repository, predicate: predicate);
    }

    return FacadeWsDatabaseUsecases<T>(
      repository: repository,
      read: read,
      write: write,
      delete: delete,
      exists: exists,
      watch: watch,
      mutate: mutate,
      patchFields: patch,
      ensure: ensure,
      readMany: readMany,
      writeMany: writeMany,
      deleteMany: deleteMany,
      detachWatch: detach,
      releaseDoc: release,
      disposeUc: dispose,
      readOrDefaultBuilder: readOrDefaultBuilder,
      watchUntilBuilder: watchUntilBuilder,
    );
  }

  /// Underlying repository (useful for advanced orchestrations).
  final RepositoryWsDatabase<T> repository;

  // Core UCs (instances)
  final ReadDocUseCase<T> read;
  final WriteDocUseCase<T> write;
  final DeleteDocUseCase<T> delete;
  final ExistsDocUseCase<T> exists;
  final WatchDocUseCase<T> watch;
  final MutateDocUseCase<T> mutate;
  final PatchDocFieldsUseCase<T> patchFields;
  final EnsureDocUseCase<T> ensure;
  final ReadManyDocsUseCase<T> readMany;
  final WriteManyDocsUseCase<T> writeMany;
  final DeleteManyDocsUseCase<T> deleteMany;
  final DetachWatchUseCase<T> detachWatch;
  final ReleaseDocUseCase<T> releaseDoc;
  final DisposeWsDatabaseUseCase<T> disposeUc;

  // Builders for parameterized UCs
  final ReadOrDefaultUseCase<T> Function(T Function() orElse)
      readOrDefaultBuilder;
  final WatchDocUntilUseCase<T> Function(bool Function(T) predicate)
      watchUntilBuilder;

  // ---------------- Convenience methods (thin wrappers) ----------------

  /// Reads a document by [docId].
  Future<Either<ErrorItem, T>> readDoc(String docId) => read(ReadParams(docId));

  /// Writes (creates/updates) [entity] at [docId].
  Future<Either<ErrorItem, T>> writeDoc(String docId, T entity) =>
      write(WriteParams<T>(docId, entity));

  /// Deletes a document by [docId].
  Future<Either<ErrorItem, Unit>> deleteDoc(String docId) =>
      delete(DeleteParams(docId));

  /// Checks if a document exists.
  Future<Either<ErrorItem, bool>> existsDoc(String docId) =>
      exists(ReadParams(docId));

  /// Watches a document by [docId].
  Stream<Either<ErrorItem, T>> watchDoc(String docId) =>
      watch(WatchParams(docId));

  /// Builds a `ReadOrDefaultUseCase` with the provided default factory.
  ReadOrDefaultUseCase<T> readOrDefault(T Function() orElse) =>
      readOrDefaultBuilder(orElse);

  /// Builds a `WatchDocUntilUseCase` with the provided predicate.
  WatchDocUntilUseCase<T> watchUntil(bool Function(T) predicate) =>
      watchUntilBuilder(predicate);

  /// Applies a pure transform to a document and writes it back.
  Future<Either<ErrorItem, T>> mutateDoc(
    String docId,
    T Function(T current) transform,
  ) =>
      mutate(MutateParams<T>(docId, transform));

  /// Partially updates a document by merging [patch] into JSON.
  Future<Either<ErrorItem, T>> patchDoc(
    String docId,
    Map<String, dynamic> patch,
  ) =>
      patchFields(PatchParams(docId, patch));

  /// Ensures a document exists; creates or optionally updates it.
  Future<Either<ErrorItem, T>> ensureDoc({
    required String docId,
    required T Function() create,
    T Function(T current)? updateIfExists,
  }) =>
      ensure(
        EnsureParams<T>(
          docId: docId,
          create: create,
          updateIfExists: updateIfExists,
        ),
      );

  /// Reads multiple documents.
  Future<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>> readDocs(
    List<String> ids,
  ) =>
      readMany(ReadManyParams(ids));

  /// Writes multiple documents.
  Future<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>> writeDocs(
    Map<String, T> entries,
  ) =>
      writeMany(WriteManyParams<T>(entries));

  /// Deletes multiple documents.
  Future<Either<ErrorItem, Map<String, Either<ErrorItem, Unit>>>> deleteDocs(
    List<String> ids,
  ) =>
      deleteMany(DeleteManyParams(ids));

  /// Decrements the watch ref-count for [docId].
  Future<Either<ErrorItem, Unit>> detach(String docId) =>
      detachWatch(DeleteParams(docId));

  /// Force releases a document channel for [docId].
  Future<Either<ErrorItem, Unit>> release(String docId) =>
      releaseDoc(DeleteParams(docId));

  /// Disposes the repository/gateway stack.
  Future<Either<ErrorItem, Unit>> disposeAll() => disposeUc(const NoParams());
}
