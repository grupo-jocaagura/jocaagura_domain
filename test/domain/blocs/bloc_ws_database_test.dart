import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../mocks_and_fakes/fake_db_repo.dart';

// -----------------------------------------------------------------------------
// Helpers de dominio para los tests
// -----------------------------------------------------------------------------

const String kDoc = 'user_001';

UserModel makeUser({
  String id = kDoc,
  String name = 'John Doe',
  String email = 'john.doe@example.com',
  String photo = 'https://example.com/profile.jpg',
  Map<String, dynamic> jwt = const <String, dynamic>{},
}) =>
    UserModel(
      id: id,
      displayName: name,
      email: email,
      photoUrl: photo,
      jwt: jwt,
    );

// Pequeño delay para permitir que fluyan eventos de streams/microtasks.
Future<void> flush() => Future<void>.delayed(const Duration(milliseconds: 1));

// -----------------------------------------------------------------------------
// Fake Repository (controlado por los tests)
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------

void main() {
  group('BlocWsDatabase<UserModel>', () {
    late FakeDbRepo<UserModel> repo;
    late FacadeWsDatabaseUsecases<UserModel> facade;
    late BlocWsDatabase<UserModel> bloc;

    setUp(() {
      repo = FakeDbRepo<UserModel>();
      facade = FacadeWsDatabaseUsecases<UserModel>.fromRepository(
        repository: repo,
        fromJson: UserModel.fromJson,
      );
      bloc = BlocWsDatabase<UserModel>(facade: facade);
    });

    tearDown(() {
      bloc.dispose();
    });

    test('estado inicial es idle()', () {
      final WsDbState<UserModel> s = bloc.value;
      expect(s.loading, isFalse);
      expect(s.isWatching, isFalse);
      expect(s.doc, isNull);
      expect(s.error, isNull);
      expect(s.docId, isEmpty);
    });

    test('readDoc éxito: actualiza doc, docId y limpia error', () async {
      final UserModel u = makeUser();
      repo.onRead = (String id) async => Right<ErrorItem, UserModel>(u);

      final Either<ErrorItem, UserModel> res = await bloc.readDoc(kDoc);
      expect(res.isRight, isTrue);

      final WsDbState<UserModel> s = bloc.value;
      expect(s.loading, isFalse);
      expect(s.docId, kDoc);
      expect(s.doc, equals(u));
      expect(s.error, isNull);
    });

    test('readDoc error: setea error y mantiene doc', () async {
      final UserModel u = makeUser();
      // Pre-cargar un doc en estado
      repo.onRead = (String id) async => Right<ErrorItem, UserModel>(u);
      await bloc.readDoc(kDoc);

      // Ahora simulamos error
      repo.onRead = (String id) async =>
          Left<ErrorItem, UserModel>(DatabaseErrorItems.notFound);

      final Either<ErrorItem, UserModel> res = await bloc.readDoc(kDoc);
      expect(res.isLeft, isTrue);

      final WsDbState<UserModel> s = bloc.value;
      expect(s.doc, equals(u)); // se mantiene
      expect(s.error, isNotNull);
      expect(s.error!.code, DatabaseErrorItems.notFound.code);
    });

    test('writeDoc éxito: actualiza doc', () async {
      final UserModel u = makeUser(name: 'Alice');
      repo.onWrite =
          (String id, UserModel e) async => Right<ErrorItem, UserModel>(u);

      final Either<ErrorItem, UserModel> res = await bloc.writeDoc(kDoc, u);
      expect(res.isRight, isTrue);

      final WsDbState<UserModel> s = bloc.value;
      expect(s.doc, equals(u));
      expect(s.docId, kDoc);
      expect(s.error, isNull);
    });

    test('writeDoc error: setea error', () async {
      final UserModel u = makeUser();
      repo.onWrite = (String id, UserModel e) async =>
          Left<ErrorItem, UserModel>(DatabaseErrorItems.conflict);

      final Either<ErrorItem, UserModel> res = await bloc.writeDoc(kDoc, u);
      expect(res.isLeft, isTrue);
      expect(bloc.value.error, isNotNull);
      expect(bloc.value.doc, isNull);
    });

    test('deleteDoc éxito: limpia doc si coincide el docId actual', () async {
      final UserModel u = makeUser();
      repo.onRead = (String id) async => Right<ErrorItem, UserModel>(u);
      await bloc.readDoc(kDoc);
      expect(bloc.value.doc, isNotNull);

      repo.onDelete = (String id) async => Right<ErrorItem, Unit>(Unit.value);

      final Either<ErrorItem, Unit> res = await bloc.deleteDoc(kDoc);
      expect(res.isRight, isTrue);
      expect(bloc.value.doc, isNull); // limpiado
    });

    test('existsDoc éxito: no altera doc; error permanece null', () async {
      final UserModel u = makeUser();
      repo.onRead = (String id) async => Right<ErrorItem, UserModel>(u);
      await bloc.readDoc(kDoc);

      repo.onExists = (String id) async => Right<ErrorItem, bool>(true);

      final Either<ErrorItem, bool> res = await bloc.existsDoc(kDoc);
      expect(res.isRight, isTrue);

      final WsDbState<UserModel> s = bloc.value;
      expect(s.doc, equals(u));
      expect(s.error, isNull);
    });

    test('mutateDoc/patchDoc/ensureDoc éxito: actualiza doc', () async {
      // ensureDoc -> crea si no existe (vía use cases llama a write)
      final UserModel base = makeUser();
      // read inexistente -> simulate notFound
      repo.onRead = (String _) async =>
          Left<ErrorItem, UserModel>(DatabaseErrorItems.notFound);
      repo.onWrite =
          (String _, UserModel e) async => Right<ErrorItem, UserModel>(e);

      final Either<ErrorItem, UserModel> ensured = await bloc.ensureDoc(
        docId: kDoc,
        create: () => base,
      );
      expect(ensured.isRight, isTrue);
      expect(bloc.value.doc, equals(base));

      // mutate -> read + write
      repo.onRead =
          (String _) async => Right<ErrorItem, UserModel>(bloc.value.doc!);
      repo.onWrite =
          (String _, UserModel e) async => Right<ErrorItem, UserModel>(e);
      final Either<ErrorItem, UserModel> mutated = await bloc.mutateDoc(
        kDoc,
        (UserModel current) => current.copyWith(displayName: 'Mutated'),
      );
      expect(mutated.isRight, isTrue);
      expect(bloc.value.doc!.displayName, 'Mutated');

      // patch -> read + write usando fromJson del facade
      repo.onRead =
          (String _) async => Right<ErrorItem, UserModel>(bloc.value.doc!);
      repo.onWrite =
          (String _, UserModel e) async => Right<ErrorItem, UserModel>(e);
      final Either<ErrorItem, UserModel> patched = await bloc.patchDoc(
        kDoc,
        <String, dynamic>{UserEnum.displayName.name: 'Patched'},
      );
      expect(patched.isRight, isTrue);
      expect(bloc.value.doc!.displayName, 'Patched');
    });

    test('watch: startWatch emite datos y stopWatch detiene/llama detach',
        () async {
      // Prepara repo.watch + read/write no usados aquí.
      // Arranca watch
      await bloc.startWatch(kDoc);
      expect(bloc.value.isWatching, isTrue);
      expect(bloc.value.docId, kDoc);

      // Emite un Right
      final UserModel u1 = makeUser(jwt: <String, dynamic>{'countRef': 1});
      repo.emit(kDoc, Right<ErrorItem, UserModel>(u1));
      await flush();
      expect(bloc.value.doc, equals(u1));

      // Emite un Left (error)
      repo.emit(kDoc, Left<ErrorItem, UserModel>(DatabaseErrorItems.timeout));
      await flush();
      expect(bloc.value.error, isNotNull);
      expect(bloc.value.error!.code, DatabaseErrorItems.timeout.code);

      // Stop
      await bloc.stopWatch(kDoc);
      expect(bloc.value.isWatching, isFalse);
      expect(repo.detachCount, greaterThan(0));
    });

    test('startWatch reinicia suscripción (prev detiene + detach)', () async {
      await bloc.startWatch(kDoc);
      final int before = repo.detachCount;

      // Reinicio
      await bloc.startWatch(kDoc);
      // Debió llamar a stopWatch internamente -> detach++
      expect(repo.detachCount, equals(before + 1));
      expect(bloc.value.isWatching, isTrue);
    });

    test('stopAllWatches cancela todos y pone isWatching=false', () async {
      await bloc.startWatch(kDoc);
      await bloc.startWatch('user_002');
      await flush();

      await bloc.stopAllWatches();
      expect(bloc.value.isWatching, isFalse);
      expect(repo.detachCount, greaterThanOrEqualTo(2));
    });

    test('dispose cancela watchers y llama detach para cada doc', () async {
      await bloc.startWatch(kDoc);
      await bloc.startWatch('user_002');
      bloc.dispose(); // best-effort (no await)

      // detach se invoca por cada doc observado
      expect(repo.detachCount, greaterThanOrEqualTo(2));
    });

    test('disposeStack delega a facade y devuelve Right(Unit)', () async {
      final Either<ErrorItem, Unit> res = await bloc.disposeStack();
      expect(res.isRight, isTrue);
      // La facade usa el repo real para dispose:
      expect(repo.disposed, isTrue);
    });
  });
}
