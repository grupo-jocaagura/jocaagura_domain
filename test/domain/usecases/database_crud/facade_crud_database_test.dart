import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FacadeCrudDatabaseUsecases fromRepository', () {
    late _FakeRepository repo;
    late FacadeCrudDatabaseUsecases<_TestModel> facade;

    setUp(() {
      repo = _FakeRepository();
      facade = FacadeCrudDatabaseUsecases<_TestModel>.fromRepository(
        repository: repo,
        fromJson: _TestModel.fromJson,
      );
    });

    test(
        'Given repository When facade is created Then wires repository and use cases',
        () {
      expect(facade.repository, same(repo));
      expect(facade.read, isA<ReadDocUseCase<_TestModel>>());
      expect(facade.write, isA<WriteDocUseCase<_TestModel>>());
      expect(facade.delete, isA<DeleteDocUseCase<_TestModel>>());
      expect(facade.exists, isA<ExistsDocUseCase<_TestModel>>());
      expect(facade.mutate, isA<MutateDocUseCase<_TestModel>>());
      expect(facade.patchFields, isA<PatchDocFieldsUseCase<_TestModel>>());
      expect(facade.ensure, isA<EnsureDocUseCase<_TestModel>>());
      expect(facade.readMany, isA<ReadManyDocsUseCase<_TestModel>>());
      expect(facade.writeMany, isA<WriteManyDocsUseCase<_TestModel>>());
      expect(facade.deleteMany, isA<DeleteManyDocsUseCase<_TestModel>>());
    });

    test(
        'Given stored model When readDoc is called Then delegates to repository read',
        () async {
      const _TestModel model = _TestModel(id: 'u1', name: 'Alice');
      repo.seed(model);

      final Either<ErrorItem, _TestModel> result = await facade.readDoc('u1');

      expect(result, const Right<ErrorItem, _TestModel>(model));
      expect(repo.calls, <String>['read:u1']);
    });

    test(
        'Given model When writeDoc is called Then delegates to repository write',
        () async {
      const _TestModel model = _TestModel(id: 'u1', name: 'Alice');

      final Either<ErrorItem, _TestModel> result =
          await facade.writeDoc('u1', model);

      expect(result, const Right<ErrorItem, _TestModel>(model));
      expect(repo.saved['u1'], model);
      expect(repo.calls, <String>['write:u1:Alice']);
    });

    test(
        'Given existing model When deleteDoc is called Then delegates to repository delete',
        () async {
      repo.seed(const _TestModel(id: 'u1', name: 'Alice'));

      final Either<ErrorItem, Unit> result = await facade.deleteDoc('u1');

      expect(result, const Right<ErrorItem, Unit>(Unit.value));
      expect(repo.saved.containsKey('u1'), isFalse);
      expect(repo.calls, <String>['delete:u1']);
    });

    test('Given existing model When existsDoc is called Then returns true',
        () async {
      repo.seed(const _TestModel(id: 'u1', name: 'Alice'));

      final Either<ErrorItem, bool> result = await facade.existsDoc('u1');

      expect(result, const Right<ErrorItem, bool>(true));
    });

    test('Given missing model When existsDoc is called Then returns false',
        () async {
      final Either<ErrorItem, bool> result = await facade.existsDoc('missing');

      expect(result, const Right<ErrorItem, bool>(false));
    });

    test(
        'Given repository error When existsDoc is called Then propagates error',
        () async {
      repo.readErrors['u1'] = DatabaseErrorItems.unavailable;

      final Either<ErrorItem, bool> result = await facade.existsDoc('u1');

      expect(
        result,
        const Left<ErrorItem, bool>(DatabaseErrorItems.unavailable),
      );
    });

    test(
        'Given existing model When mutateDoc is called Then reads transforms and writes',
        () async {
      repo.seed(const _TestModel(id: 'u1', name: 'Alice'));

      final Either<ErrorItem, _TestModel> result = await facade.mutateDoc(
        'u1',
        (_TestModel current) => current.copyWith(name: 'Alice+'),
      );

      expect(
        result,
        const Right<ErrorItem, _TestModel>(
          _TestModel(id: 'u1', name: 'Alice+'),
        ),
      );
      expect(repo.saved['u1'], const _TestModel(id: 'u1', name: 'Alice+'));
      expect(repo.calls, <String>['read:u1', 'write:u1:Alice+']);
    });

    test(
        'Given existing model When patchDoc is called Then merges json and writes parsed model',
        () async {
      repo.seed(const _TestModel(id: 'u1', name: 'Alice'));

      final Either<ErrorItem, _TestModel> result = await facade.patchDoc(
        'u1',
        <String, dynamic>{'name': 'Patched', 'flag': true},
      );

      expect(
        result,
        const Right<ErrorItem, _TestModel>(
          _TestModel(id: 'u1', name: 'Patched', flag: true),
        ),
      );
      expect(
        repo.saved['u1'],
        const _TestModel(id: 'u1', name: 'Patched', flag: true),
      );
    });

    test('Given missing model When ensureDoc is called Then creates it',
        () async {
      final Either<ErrorItem, _TestModel> result = await facade.ensureDoc(
        docId: 'u2',
        create: () => const _TestModel(id: 'u2', name: 'Created'),
      );

      expect(
        result,
        const Right<ErrorItem, _TestModel>(
          _TestModel(id: 'u2', name: 'Created'),
        ),
      );
      expect(repo.calls, <String>['read:u2', 'write:u2:Created']);
    });

    test(
        'Given existing model and no update When ensureDoc is called Then returns current without write',
        () async {
      repo.seed(const _TestModel(id: 'u1', name: 'Alice'));

      final Either<ErrorItem, _TestModel> result = await facade.ensureDoc(
        docId: 'u1',
        create: () => const _TestModel(id: 'u1', name: 'Created'),
      );

      expect(
        result,
        const Right<ErrorItem, _TestModel>(
          _TestModel(id: 'u1', name: 'Alice'),
        ),
      );
      expect(repo.calls, <String>['read:u1']);
    });

    test(
        'Given existing model and update When ensureDoc is called Then writes updated model',
        () async {
      repo.seed(const _TestModel(id: 'u1', name: 'Alice'));

      final Either<ErrorItem, _TestModel> result = await facade.ensureDoc(
        docId: 'u1',
        create: () => const _TestModel(id: 'u1', name: 'Created'),
        updateIfExists: (_TestModel current) => current.copyWith(flag: true),
      );

      expect(
        result,
        const Right<ErrorItem, _TestModel>(
          _TestModel(id: 'u1', name: 'Alice', flag: true),
        ),
      );
      expect(repo.calls, <String>['read:u1', 'write:u1:Alice']);
    });

    test(
        'Given ids When readDocs is called Then reads sequentially and returns per-id results',
        () async {
      repo.seed(const _TestModel(id: 'u1', name: 'Alice'));

      final Either<ErrorItem, Map<String, Either<ErrorItem, _TestModel>>>
          result = await facade.readDocs(<String>['u1', 'missing']);

      final Map<String, Either<ErrorItem, _TestModel>> values = result.fold(
        (ErrorItem error) => fail('Expected Right but got $error'),
        (Map<String, Either<ErrorItem, _TestModel>> right) => right,
      );

      expect(
        values['u1'],
        const Right<ErrorItem, _TestModel>(
          _TestModel(id: 'u1', name: 'Alice'),
        ),
      );
      expect(
        values['missing'],
        const Left<ErrorItem, _TestModel>(DatabaseErrorItems.notFound),
      );
      expect(repo.calls, <String>['read:u1', 'read:missing']);
    });

    test(
        'Given entries When writeDocs is called Then writes sequentially and returns per-id results',
        () async {
      final Map<String, _TestModel> entries = <String, _TestModel>{
        'u1': const _TestModel(id: 'u1', name: 'Alice'),
        'u2': const _TestModel(id: 'u2', name: 'Bob'),
      };

      final Either<ErrorItem, Map<String, Either<ErrorItem, _TestModel>>>
          result = await facade.writeDocs(entries);

      expect(result.isRight, isTrue);
      expect(repo.calls, <String>['write:u1:Alice', 'write:u2:Bob']);
    });

    test(
        'Given ids When deleteDocs is called Then deletes sequentially and returns per-id results',
        () async {
      repo.seed(const _TestModel(id: 'u1', name: 'Alice'));
      repo.seed(const _TestModel(id: 'u2', name: 'Bob'));

      final Either<ErrorItem, Map<String, Either<ErrorItem, Unit>>> result =
          await facade.deleteDocs(<String>['u1', 'u2']);

      expect(result.isRight, isTrue);
      expect(repo.saved, isEmpty);
      expect(repo.calls, <String>['delete:u1', 'delete:u2']);
    });
  });
}

class _TestModel extends Model {
  const _TestModel({
    required this.id,
    required this.name,
    this.flag = false,
  });

  factory _TestModel.fromJson(Map<String, dynamic> json) {
    return _TestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      flag: json['flag'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final bool flag;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'flag': flag,
    };
  }

  @override
  _TestModel copyWith({
    String? id,
    String? name,
    bool? flag,
  }) {
    return _TestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      flag: flag ?? this.flag,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _TestModel &&
        other.id == id &&
        other.name == name &&
        other.flag == flag;
  }

  @override
  int get hashCode => Object.hash(id, name, flag);
}

class _FakeRepository implements RepositoryWsDatabase<_TestModel> {
  final Map<String, _TestModel> saved = <String, _TestModel>{};
  final Map<String, ErrorItem> readErrors = <String, ErrorItem>{};
  final List<String> calls = <String>[];

  void seed(_TestModel model) {
    saved[model.id] = model;
  }

  @override
  Future<Either<ErrorItem, _TestModel>> read(String docId) async {
    calls.add('read:$docId');

    final ErrorItem? forcedError = readErrors[docId];
    if (forcedError != null) {
      return Left<ErrorItem, _TestModel>(forcedError);
    }

    final _TestModel? model = saved[docId];
    if (model == null) {
      return const Left<ErrorItem, _TestModel>(DatabaseErrorItems.notFound);
    }

    return Right<ErrorItem, _TestModel>(model);
  }

  @override
  Future<Either<ErrorItem, _TestModel>> write(
    String docId,
    _TestModel entity,
  ) async {
    calls.add('write:$docId:${entity.name}');
    saved[docId] = entity;
    return Right<ErrorItem, _TestModel>(entity);
  }

  @override
  Future<Either<ErrorItem, Unit>> delete(String docId) async {
    calls.add('delete:$docId');
    saved.remove(docId);
    return const Right<ErrorItem, Unit>(Unit.value);
  }

  @override
  Stream<Either<ErrorItem, _TestModel>> watch(String docId) {
    final _TestModel? model = saved[docId];
    if (model == null) {
      return Stream<Either<ErrorItem, _TestModel>>.value(
        const Left<ErrorItem, _TestModel>(DatabaseErrorItems.notFound),
      );
    }

    return Stream<Either<ErrorItem, _TestModel>>.value(
      Right<ErrorItem, _TestModel>(model),
    );
  }

  @override
  void detachWatch(String docId) {}

  @override
  void releaseDoc(String docId) {}

  @override
  void dispose() {}
}
