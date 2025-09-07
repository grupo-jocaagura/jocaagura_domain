part of '../../../../jocaagura_domain.dart';

/// Minimal, transport-agnostic CRUD facade (no realtime/watch).
///
/// Useful for REST or any synchronous database where you only need
/// document-level CRUD, existence helpers, mutations, and batch ops.
///
/// Exposes both the **use case instances** and **convenience methods**.
///
/// ### Example
/// ```dart
/// final crud = FacadeCrudDatabaseUsecases<UserModel>.fromRepository(
///   repository: repo,
///   fromJson: UserModel.fromJson,
/// );
///
/// final got = await crud.readDoc('u1');
/// final saved = await crud.writeDoc('u1', someUser);
/// final del = await crud.deleteDoc('u1');
/// ```
class FacadeCrudDatabaseUsecases<T extends Model> {
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

  /// Convenience factory wiring the common defaults from a repository.
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

  /// Underlying repository (can be WS, REST, etc.).
  final RepositoryWsDatabase<T> repository;

  // Use cases (instances)
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
