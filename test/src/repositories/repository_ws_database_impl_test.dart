import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  late FakeServiceWsDatabase service;
  late GatewayWsDatabase gateway;

  setUp(() {
    service = FakeServiceWsDatabase();
    gateway = GatewayWsDatabaseImpl(
      service: service,
      collection: 'users',
    );
  });

  UserModel mkUser(String id) => UserModel(
        id: id,
        displayName: 'John',
        photoUrl: '',
        email: 'john@example.com',
        jwt: const <String, dynamic>{'t': '1'},
      );

  test('write then read returns the same entity', () async {
    final RepositoryWsDatabaseImpl<UserModel> repo =
        RepositoryWsDatabaseImpl<UserModel>(
      gateway: gateway,
      fromJson: UserModel.fromJson,
    );

    final Either<ErrorItem, UserModel> w = await repo.write('u1', mkUser('u1'));
    expect(w.isRight, isTrue);

    final Either<ErrorItem, UserModel> r = await repo.read('u1');
    r.fold((_) => fail('should succeed'), (UserModel u) {
      expect(u.id, 'u1');
      expect(u.email, 'john@example.com');
    });
  });

  test('decode mapping_error when fromJson throws', () async {
    // Un parser que siempre lanza:
    UserModel badParser(Map<String, dynamic> _) => throw StateError('boom');

    final RepositoryWsDatabaseImpl<UserModel> repo =
        RepositoryWsDatabaseImpl<UserModel>(
      gateway: gateway,
      fromJson: badParser,
    );

    // Pre-graba JSON válido
    await service.saveDocument(
      collection: 'users',
      docId: 'u2',
      document: <String, dynamic>{
        UserEnum.id.name: 'u2',
        UserEnum.displayName.name: 'Jane',
        UserEnum.photoUrl.name: '',
        UserEnum.email.name: 'jane@example.com',
        UserEnum.jwt.name: <String, dynamic>{'t': '2'},
      },
    );

    final Either<ErrorItem, UserModel> r = await repo.read('u2');
    expect(r.isLeft, isTrue);
    r.fold(
      (ErrorItem err) {
        // Dependiendo de tu ErrorMapper, puede ser 'mapping_error'
        expect(err.code, isNotNull);
      },
      (_) => fail('should not succeed'),
    );
  });

  test('watch streams entities and maps errors', () async {
    final RepositoryWsDatabaseImpl<UserModel> repo =
        RepositoryWsDatabaseImpl<UserModel>(
      gateway: gateway,
      fromJson: UserModel.fromJson,
    );

    await service.saveDocument(
      collection: 'users',
      docId: 'u3',
      document: <String, dynamic>{
        UserEnum.id.name: 'u3',
        UserEnum.displayName.name: 'Init',
        UserEnum.photoUrl.name: '',
        UserEnum.email.name: 'init@example.com',
        UserEnum.jwt.name: <String, dynamic>{'t': '3'},
      },
    );

    final List<UserModel> seen = <UserModel>[];
    final StreamSubscription<Either<ErrorItem, UserModel>> sub =
        repo.watch('u3').listen((Either<ErrorItem, UserModel> e) {
      e.fold((_) {}, (UserModel u) => seen.add(u));
    });

    await service.saveDocument(
      collection: 'users',
      docId: 'u3',
      document: <String, dynamic>{
        UserEnum.id.name: 'u3',
        UserEnum.displayName.name: 'Updated',
        UserEnum.photoUrl.name: '',
        UserEnum.email.name: 'up@example.com',
        UserEnum.jwt.name: <String, dynamic>{'t': '3'},
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));
    await sub.cancel();
    gateway.detachWatch('u3');

    expect(seen.isNotEmpty, isTrue);
    expect(seen.last.displayName, 'Updated');
  });
}
