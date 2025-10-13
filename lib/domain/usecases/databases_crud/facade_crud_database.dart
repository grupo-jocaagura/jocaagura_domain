part of '../../../../jocaagura_domain.dart';

/// Provide a transport-agnostic CRUD facade (no realtime/watch).
///
/// This facade wires the standard CRUD use cases on top of a
/// `RepositoryWsDatabase<T>` and exposes both:
/// - The **use case instances** (e.g., [read], [write], …), and
/// - **Convenience methods** (e.g., [readDoc], [writeDoc], …).
///
/// When to use:
/// - REST-like or synchronous databases where you do not need realtime streams.
/// - Service layers that want a small, explicit surface for document-level ops.
///
/// Design notes:
/// - Batch operations are executed **sequentially** for determinism (helps
///   testing and ordering). Consider repository-level bulk ops for throughput.
/// - [existsDoc] relies on the repository mapping "not found" to
///   `DatabaseErrorItems.notFound.code`.
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryWsDatabase<UserModel> repo = MyRepo<UserModel>();
///
///   final FacadeCrudDatabaseUsecases<UserModel> crud =
///       FacadeCrudDatabaseUsecases<UserModel>.fromRepository(
///     repository: repo,
///     fromJson: UserModel.fromJson,
///   );
///
///   // Create/update
///   final UserModel alice = UserModel(id: 'u1', email: 'a@b.com');
///   final writeRes = await crud.writeDoc('u1', alice);
///
///   // Read
///   final readRes = await crud.readDoc('u1');
///
///   // Exists
///   final existsRes = await crud.existsDoc('u1');
///
///   // Patch (partial JSON)
///   final patchRes = await crud.patchDoc('u1', <String, dynamic>{'displayName': 'Alice'});
///
///   // Mutate (read–modify–write)
///   final mutateRes = await crud.mutateDoc('u1', (u) => u.copyWith(displayName: 'Alice+'));
///
///   // Ensure
///   final ensureRes = await crud.ensureDoc(
///     docId: 'u2',
///     create: () => UserModel(id: 'u2', email: 'x@y.com'),
///     updateIfExists: (u) => u.copyWith(flag: true),
///   );
///
///   // Many
///   final readManyRes  = await crud.readDocs(<String>['u1','u2']);
///   final writeManyRes = await crud.writeDocs(<String, UserModel>{'u1': alice});
///   final deleteManyRes= await crud.deleteDocs(<String>['u1','u2']);
///
///   // Delete
///   final delRes = await crud.deleteDoc('u1');
/// }
/// ```
class FacadeCrudDatabaseUsecases<T extends Model> {
  /// Creates a CRUD facade by composing explicit use cases.
  ///
  /// Parameters:
  /// - [repository]: underlying repository (WS/REST/etc.).
  /// - [read]/[write]/[delete]/…: injected use case instances.
  ///
  /// Notes:
  /// - Prefer [FacadeCrudDatabaseUsecases.fromRepository] unless you need
  ///   custom wiring (e.g., specialized mappers or instrumentation).
  FacadeCrudDatabaseUsecases({
    required this.repository,
    required this.read,
    required this.write,
    required this.delete,
    required this.exists,
    required this.mutate,
    required this.patchFields,
    required this.ensure,
    required this.readMany,
    required this.writeMany,
    required this.deleteMany,
  });

  /// Convenience factory that wires common defaults from a repository.
  ///
  /// Parameters:
  /// - [repository]: the underlying repository.
  /// - [fromJson]: factory used by [patchDoc] to rebuild `T` after merging JSON.
  /// - [myMapper]: optional error mapper for *many* operations; defaults to
  ///   [DefaultErrorMapper].
  ///
  /// Returns:
  /// - A fully-wired CRUD facade with deterministic (sequential) *many* ops.
  ///
  /// Caveats:
  /// - Ensure [fromJson] matches the JSON produced by `T.toJson()`.
  factory FacadeCrudDatabaseUsecases.fromRepository({
    required RepositoryWsDatabase<T> repository,
    required T Function(Map<String, dynamic>) fromJson,
    ErrorMapper? myMapper,
  }) {
    final ErrorMapper mapper = myMapper ?? const DefaultErrorMapper();

    return FacadeCrudDatabaseUsecases<T>(
      repository: repository,
      read: ReadDocUseCase<T>(repository),
      write: WriteDocUseCase<T>(repository),
      delete: DeleteDocUseCase<T>(repository),
      exists: ExistsDocUseCase<T>(repository),
      mutate: MutateDocUseCase<T>(repository),
      patchFields: PatchDocFieldsUseCase<T>(repository, fromJson: fromJson),
      ensure: EnsureDocUseCase<T>(repository),
      readMany: ReadManyDocsUseCase<T>(repository, mapper: mapper),
      writeMany: WriteManyDocsUseCase<T>(repository, mapper: mapper),
      deleteMany: DeleteManyDocsUseCase<T>(repository, mapper: mapper),
    );
  }

  /// Underlying repository (WS, REST, etc.).
  final RepositoryWsDatabase<T> repository;

  /// Use case instances (single-document operations and helpers).
  final ReadDocUseCase<T> read;
  final WriteDocUseCase<T> write;
  final DeleteDocUseCase<T> delete;
  final ExistsDocUseCase<T> exists;
  final MutateDocUseCase<T> mutate;
  final PatchDocFieldsUseCase<T> patchFields;
  final EnsureDocUseCase<T> ensure;
  final ReadManyDocsUseCase<T> readMany;
  final WriteManyDocsUseCase<T> writeMany;
  final DeleteManyDocsUseCase<T> deleteMany;

  // ---------------- Convenience methods ----------------

  Future<Either<ErrorItem, T>> readDoc(String docId) => read(ReadParams(docId));

  Future<Either<ErrorItem, T>> writeDoc(String docId, T entity) =>
      write(WriteParams<T>(docId, entity));

  Future<Either<ErrorItem, Unit>> deleteDoc(String docId) =>
      delete(DeleteParams(docId));

  Future<Either<ErrorItem, bool>> existsDoc(String docId) =>
      exists(ReadParams(docId));

  Future<Either<ErrorItem, T>> mutateDoc(
    String docId,
    T Function(T current) transform,
  ) =>
      mutate(MutateParams<T>(docId, transform));

  Future<Either<ErrorItem, T>> patchDoc(
    String docId,
    Map<String, dynamic> patch,
  ) =>
      patchFields(PatchParams(docId, patch));

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

  Future<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>> readDocs(
    List<String> ids,
  ) =>
      readMany(ReadManyParams(ids));

  Future<Either<ErrorItem, Map<String, Either<ErrorItem, T>>>> writeDocs(
    Map<String, T> entries,
  ) =>
      writeMany(WriteManyParams<T>(entries));

  Future<Either<ErrorItem, Map<String, Either<ErrorItem, Unit>>>> deleteDocs(
    List<String> ids,
  ) =>
      deleteMany(DeleteManyParams(ids));
}
