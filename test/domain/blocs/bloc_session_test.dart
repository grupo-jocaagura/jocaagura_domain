import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../mocks_and_fakes/fake_repository_auth.dart';

// Helper para esperar estados sin colgar
Future<SessionState> waitForState(
  Stream<SessionState> state,
  bool Function(SessionState) pred, {
  Duration timeout = const Duration(seconds: 1),
}) =>
    state.firstWhere(pred).timeout(timeout);

void main() {
  group('BlocSession', () {
    late FakeRepositoryAuth repo;
    late SessionUsecases usecases;
    late BlocSession bloc;
    late WatchAuthStateChangesUsecase watchUC;

    final Debouncer tinyAuthDebouncer = Debouncer(milliseconds: 1);
    final Debouncer tinyRefreshDebouncer = Debouncer(milliseconds: 1);

    setUp(() {
      repo = FakeRepositoryAuth();
      usecases = SessionUsecases(
        logInUserAndPassword: LogInUserAndPasswordUsecase(repo),
        logOutUsecase: LogOutUsecase(repo),
        signInUserAndPassword: SignInUserAndPasswordUsecase(repo),
        recoverPassword: RecoverPasswordUsecase(repo),
        logInSilently: LogInSilentlyUsecase(repo),
        loginWithGoogle: LoginWithGoogleUsecase(repo),
        refreshSession: RefreshSessionUsecase(repo),
        getCurrentUser: GetCurrentUserUsecase(repo),
        watchAuthStateChangesUsecase: WatchAuthStateChangesUsecase(repo),
      );
      watchUC = WatchAuthStateChangesUsecase(repo);
      bloc = BlocSession(
        usecases: usecases,
        watchAuthStateChanges: watchUC,
        authDebouncer: tinyAuthDebouncer,
        refreshDebouncer: tinyRefreshDebouncer,
      );
    });

    tearDown(() async {
      bloc.dispose();
    });

    test('boot() se suscribe a authStateChanges y refleja cambios', () async {
      final List<SessionState> states = <SessionState>[];
      final StreamSubscription<SessionState> sub =
          bloc.sessionStream.listen(states.add);

      await bloc.boot();

      repo.emitAuth(Right<ErrorItem, UserModel?>(null));
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Unauthenticated,
      );
      expect(states.last, isA<Unauthenticated>());

      const UserModel u = UserModel(
        id: 'id1',
        displayName: 'u1',
        photoUrl: '',
        email: 'u1@x.com',
        jwt: <String, dynamic>{},
      );
      repo.emitAuth(Right<ErrorItem, UserModel?>(u));
      await waitForState(
        bloc.sessionStream,
        (SessionState state) => state is Authenticated,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect((states.last as Authenticated).user.email, 'u1@x.com');

      const ErrorItem err = ErrorItem(
        title: 'Bang',
        code: 'ERR_X',
        description: 'fail',
      );
      repo.emitAuth(Left<ErrorItem, UserModel?>(err));
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is SessionError,
      );
      expect((states.last as SessionError).message.code, 'ERR_X');

      await sub.cancel();
    });

    test('logIn() éxito → Authenticated; contador repo == 1', () async {
      final Either<ErrorItem, UserModel> r =
          await bloc.logIn(email: 'me@mail.com', password: 'secret');
      expect(r.isRight, isTrue);
      expect(repo.logInUserAndPasswordCalls, 1);

      final SessionState s = await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );
      expect((s as Authenticated).user.email, 'me@mail.com');
    });

    test('logIn() error → SessionError', () async {
      repo.nextLoginResult = Left<ErrorItem, UserModel>(
        const ErrorItem(title: 'Bad', code: 'ERR_LOGIN', description: 'nope'),
      );
      final Either<ErrorItem, UserModel> r =
          await bloc.logIn(email: 'me@mail.com', password: 'secret');
      expect(r.isLeft, isTrue);

      final SessionState s = await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is SessionError,
      );
      expect((s as SessionError).message.code, 'ERR_LOGIN');
    });

    test('signIn() éxito → Authenticated', () async {
      final Either<ErrorItem, UserModel> r =
          await bloc.signIn(email: 'new@user.com', password: 'abc');
      expect(r.isRight, isTrue);

      final SessionState s = await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );
      expect((s as Authenticated).user.email, 'new@user.com');
    });

    test('logInWithGoogle() éxito → Authenticated', () async {
      final Either<ErrorItem, UserModel> r = await bloc.logInWithGoogle();
      expect(r.isRight, isTrue);

      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );
    });

    test('logInSilently() sin sesión → null y Unauthenticated', () async {
      final Either<ErrorItem, UserModel>? r = await bloc.logInSilently();
      expect(r, isNull);

      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Unauthenticated,
      );
    });

    test('logInSilently() con sesión → actualiza usuario', () async {
      await bloc.boot();
      const UserModel base = UserModel(
        id: 'idA',
        displayName: 'a',
        photoUrl: '',
        email: 'a@x.com',
        jwt: <String, dynamic>{'t': 1},
      );
      repo.emitAuth(Right<ErrorItem, UserModel?>(base));
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );

      repo.nextSilentResult = Right<ErrorItem, UserModel>(
        base.copyWith(jwt: <String, dynamic>{'t': 2}),
      );

      final Either<ErrorItem, UserModel>? r = await bloc.logInSilently();
      expect(r, isNotNull);
      expect(r!.isRight, isTrue);

      final SessionState s = await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );
      expect((s as Authenticated).user.jwt['t'], 2);
    });

    test('refreshSession() sin sesión → null y Unauthenticated', () async {
      final Either<ErrorItem, UserModel>? r = await bloc.refreshSession();
      expect(r, isNull);

      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Unauthenticated,
      );
    });

    test('recoverPassword() éxito → no cambia estado (usamos getters)',
        () async {
      await bloc.boot();
      const UserModel u = UserModel(
        id: 'idC',
        displayName: 'c',
        photoUrl: '',
        email: 'c@x.com',
        jwt: <String, dynamic>{},
      );
      repo.emitAuth(Right<ErrorItem, UserModel?>(u));
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );

      final bool wasAuthed = bloc.isAuthenticated;
      final String currentEmail = bloc.currentUser.email;

      final Either<ErrorItem, void> r =
          await bloc.recoverPassword(email: 'c@x.com');
      expect(r.isRight, isTrue);

      // No esperamos nueva emisión: validamos con getters
      expect(bloc.isAuthenticated, wasAuthed);
      expect(bloc.currentUser.email, currentEmail);
    });

    test('recoverPassword() error → SessionError', () async {
      repo.nextRecoverResult = Left<ErrorItem, void>(
        const ErrorItem(title: 'x', code: 'ERR_REC', description: 'fail'),
      );
      final Either<ErrorItem, void> r =
          await bloc.recoverPassword(email: 'z@x.com');
      expect(r.isLeft, isTrue);

      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is SessionError,
      );
    });

    test('logOut() autenticado → Unauthenticated', () async {
      await bloc.boot();
      const UserModel u = UserModel(
        id: 'idD',
        displayName: 'd',
        photoUrl: '',
        email: 'd@x.com',
        jwt: <String, dynamic>{},
      );
      repo.emitAuth(Right<ErrorItem, UserModel?>(u));
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );

      final Either<ErrorItem, void>? r = await bloc.logOut();
      expect(r, isNotNull);
      expect(r!.isRight, isTrue);

      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Unauthenticated,
      );
    });

    test('logOut() sin sesión → null y Unauthenticated (getter)', () async {
      final Either<ErrorItem, void>? r = await bloc.logOut();
      expect(r, isNull);
      expect(
        bloc.isAuthenticated,
        isFalse,
      ); // más robusto que esperar nueva emisión
    });

    test('currentUser devuelve defaultUserModel cuando no autenticado',
        () async {
      expect(bloc.isAuthenticated, isFalse);
      final UserModel cu = bloc.currentUser;
      expect(cu.id, defaultUserModel.id);
    });

    test('isAuthenticated refleja el estado', () async {
      expect(bloc.isAuthenticated, isFalse);
      await bloc.boot();
      repo.emitAuth(
        Right<ErrorItem, UserModel?>(
          const UserModel(
            id: 'idE',
            displayName: 'e',
            photoUrl: '',
            email: 'e@x.com',
            jwt: <String, dynamic>{},
          ),
        ),
      );
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );
      expect(bloc.isAuthenticated, isTrue);
    });

    test('Debouncer: dos logIn rápidos → 1 llamada al repo', () async {
      unawaited(bloc.logIn(email: 'fast@x.com', password: '1'));
      final Either<ErrorItem, UserModel> r2 =
          await bloc.logIn(email: 'fast@x.com', password: '2');

      expect(r2.isRight, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(repo.logInUserAndPasswordCalls, 1);
    });
    test('logInWithGoogle() error → SessionError', () async {
      repo.nextGoogleResult = Left<ErrorItem, UserModel>(
        const ErrorItem(
          title: 'google',
          code: 'ERR_GOOGLE',
          description: 'fail',
        ),
      );
      final Either<ErrorItem, UserModel> r = await bloc.logInWithGoogle();
      expect(r.isLeft, isTrue);

      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is SessionError,
      );
      final SessionState s = await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is SessionError,
      );
      expect((s as SessionError).message.code, 'ERR_GOOGLE');
    });

    test('logInSilently() con sesión pero repo falla → SessionError', () async {
      await bloc.boot();
      const UserModel base = UserModel(
        id: 'idS',
        displayName: 's',
        photoUrl: '',
        email: 's@x.com',
        jwt: <String, dynamic>{},
      );
      repo.emitAuth(Right<ErrorItem, UserModel?>(base));
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );

      repo.nextSilentResult = Left<ErrorItem, UserModel>(
        const ErrorItem(
          title: 'silent',
          code: 'ERR_SILENT',
          description: 'boom',
        ),
      );
      final Either<ErrorItem, UserModel>? r = await bloc.logInSilently();
      expect(r, isNotNull);
      expect(r!.isLeft, isTrue);

      final SessionState s = await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is SessionError,
      );
      expect((s as SessionError).message.code, 'ERR_SILENT');
    });

    test('refreshSession() con sesión → Refreshing → Authenticated', () async {
      await bloc.boot();
      const UserModel base = UserModel(
        id: 'idB',
        displayName: 'b',
        photoUrl: '',
        email: 'b@x.com',
        jwt: <String, dynamic>{'t': 1},
      );

      // 1) Autenticamos con el "base"
      repo.emitAuth(Right<ErrorItem, UserModel?>(base));
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated && s.user.email == base.email,
      );

      final UserModel copyUser = base.copyWith(jwt: <String, dynamic>{'t': 99});
      repo.nextRefreshResult = Right<ErrorItem, UserModel>(copyUser);

      final Completer<void> sawRefreshing = Completer<void>();
      final Completer<void> sawAuthenticated = Completer<void>();
      bool canCaptureAuthenticated = false;
      UserModel? finalUser;

      final StreamSubscription<SessionState> sub =
          bloc.sessionStream.listen((SessionState s) {
        if (s is Refreshing && !sawRefreshing.isCompleted) {
          canCaptureAuthenticated = true; // <-- habilita la captura
          sawRefreshing.complete();
          return;
        }
        if (canCaptureAuthenticated &&
            s is Authenticated &&
            !sawAuthenticated.isCompleted) {
          finalUser = s.user; // <-- este ya es el post-refresh
          sawAuthenticated.complete();
        }
      });

      // 4) Disparamos el refresh
      final Either<ErrorItem, UserModel>? r = await bloc.refreshSession();
      expect(r, isNotNull);
      expect(r!.isRight, isTrue);

      // 5) Verificamos la secuencia y el contenido
      await sawRefreshing.future.timeout(const Duration(seconds: 1));
      await sawAuthenticated.future.timeout(const Duration(seconds: 1));
      await sub.cancel();

      expect(finalUser?.email, base.email);
      expect(finalUser?.jwt['t'], 99); // ✅ ya no es 1
    });
  });
  group('BlocSession getters: stream & stateOrDefault', () {
    late FakeRepositoryAuth repo;
    late SessionUsecases usecases;
    late BlocSession bloc;
    late WatchAuthStateChangesUsecase watchUC;

    // Debouncers ultrarrápidos para no ralentizar los tests.
    final Debouncer tinyAuthDebouncer = Debouncer(milliseconds: 1);
    final Debouncer tinyRefreshDebouncer = Debouncer(milliseconds: 1);

    setUp(() {
      repo = FakeRepositoryAuth();
      usecases = SessionUsecases(
        logInUserAndPassword: LogInUserAndPasswordUsecase(repo),
        logOutUsecase: LogOutUsecase(repo),
        signInUserAndPassword: SignInUserAndPasswordUsecase(repo),
        recoverPassword: RecoverPasswordUsecase(repo),
        logInSilently: LogInSilentlyUsecase(repo),
        loginWithGoogle: LoginWithGoogleUsecase(repo),
        refreshSession: RefreshSessionUsecase(repo),
        getCurrentUser: GetCurrentUserUsecase(repo),
        watchAuthStateChangesUsecase: WatchAuthStateChangesUsecase(repo),
      );
      watchUC = WatchAuthStateChangesUsecase(repo);
      bloc = BlocSession(
        usecases: usecases,
        watchAuthStateChanges: watchUC,
        authDebouncer: tinyAuthDebouncer,
        refreshDebouncer: tinyRefreshDebouncer,
      );
    });

    tearDown(() {
      bloc.dispose();
    });

    test(
        'stream y sessionStream reciben misma traza de estados (4 transiciones)',
        () async {
      final List<Type> a = <Type>[];
      final List<Type> b = <Type>[];

      final StreamSubscription<SessionState> subA =
          bloc.stream.listen((SessionState s) => a.add(s.runtimeType));
      final StreamSubscription<SessionState> subB =
          bloc.sessionStream.listen((SessionState s) => b.add(s.runtimeType));

      await bloc.boot();

      // 1) Right(null) -> Unauthenticated (explícito, aunque ya recibimos uno por replay)
      repo.emitAuth(Right<ErrorItem, UserModel?>(null));
      await waitForState(bloc.stream, (SessionState s) => s is Unauthenticated);

      // 2) Right(user1) -> Authenticated
      const UserModel user1 = UserModel(
        id: 'u1',
        displayName: 'u1',
        photoUrl: '',
        email: 'u1@x.com',
        jwt: <String, dynamic>{'v': 1},
      );
      repo.emitAuth(Right<ErrorItem, UserModel?>(user1));
      await waitForState(bloc.stream, (SessionState s) => s is Authenticated);

      // 3) Right(null) -> Unauthenticated
      repo.emitAuth(Right<ErrorItem, UserModel?>(null));
      await waitForState(bloc.stream, (SessionState s) => s is Unauthenticated);

      // 4) Right(user2) -> Authenticated (cambiar el payload para evitar colisiones de igualdad)
      const UserModel user2 = UserModel(
        id: 'u1', // puede ser el mismo id
        displayName: 'u1',
        photoUrl: '',
        email: 'u1@x.com',
        jwt: <String, dynamic>{
          'v': 2,
        }, // <-- cambia algo (ej. jwt) para asegurar nueva emisión
      );
      repo.emitAuth(Right<ErrorItem, UserModel?>(user2));
      await waitForState(bloc.stream, (SessionState s) => s is Authenticated);

      // Dar un tick para drenar microtasks
      await Future<void>.delayed(const Duration(milliseconds: 5));

      await subA.cancel();
      await subB.cancel();

      // Normalizamos: nos quedamos con las 4 últimas (puede haber 1 replay inicial)
      List<Type> norm(List<Type> xs) =>
          xs.length <= 4 ? xs : xs.sublist(xs.length - 4);

      expect(
        norm(a),
        <Type>[Unauthenticated, Authenticated, Unauthenticated, Authenticated],
      );
      expect(
        norm(b),
        <Type>[Unauthenticated, Authenticated, Unauthenticated, Authenticated],
      );
    });

    test('stateOrDefault → Unauthenticated cuando no hay sesión', () {
      // Estado inicial del BlocSession es Unauthenticated.
      final SessionState s = bloc.stateOrDefault;
      expect(s, isA<Unauthenticated>());
    });

    test('stateOrDefault → Authenticated(currentUser) cuando hay sesión',
        () async {
      await bloc.boot();
      const UserModel u = UserModel(
        id: 'id-auth',
        displayName: 'auth',
        photoUrl: '',
        email: 'auth@x.com',
        jwt: <String, dynamic>{'k': 1},
      );

      repo.emitAuth(Right<ErrorItem, UserModel?>(u));
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated && s.user.email == u.email,
      );

      final SessionState snapshot = bloc.stateOrDefault;
      expect(snapshot, isA<Authenticated>());
      final Authenticated a = snapshot as Authenticated;
      // Debe reflejar el mismo usuario expuesto por currentUser.
      expect(a.user.email, bloc.currentUser.email);
      expect(a.user.jwt['k'], 1);
    });

    test('stateOrDefault no emite nuevos estados (es snapshot sin efectos)',
        () async {
      // Suscripción para contar emisiones.
      int emissions = 0;
      final StreamSubscription<SessionState> sub =
          bloc.sessionStream.listen((_) => emissions++);

      // 1) Llamar a stateOrDefault en frío no debe emitir nada.
      final int before = emissions;
      final SessionState snap1 = bloc.stateOrDefault;
      expect(snap1, isA<Unauthenticated>());
      expect(emissions, before);

      // 2) Autenticar y volver a consultar snapshot tampoco debe emitir.
      await bloc.boot();
      const UserModel u = UserModel(
        id: 'idZ',
        displayName: 'z',
        photoUrl: '',
        email: 'z@x.com',
        jwt: <String, dynamic>{},
      );
      repo.emitAuth(Right<ErrorItem, UserModel?>(u));
      await waitForState(
        bloc.sessionStream,
        (SessionState s) => s is Authenticated,
      );

      final int before2 = emissions;
      final SessionState snap2 = bloc.stateOrDefault;
      expect(snap2, isA<Authenticated>());
      expect(
        emissions,
        before2,
        reason: 'stateOrDefault no debe provocar emisiones',
      );

      await sub.cancel();
    });

    test('stream se puede escuchar normalmente (sanity check)', () async {
      final List<SessionState> seen = <SessionState>[];
      final StreamSubscription<SessionState> sub = bloc.stream.listen(seen.add);

      await bloc.boot();
      repo.emitAuth(Right<ErrorItem, UserModel?>(null));
      await waitForState(bloc.stream, (SessionState s) => s is Unauthenticated);

      expect(seen.last, isA<Unauthenticated>());
      await sub.cancel();
    });

    test(
        'tras dispose(), nueva suscripción recibe ÚLTIMO estado y luego cierra',
        () async {
      // Dejamos el último estado conocido en Unauthenticated (estado inicial).
      // Si quisieras, podrías dejarlo en Authenticated y verificar ese caso.
      bloc.dispose();

      final List<SessionState> seen = <SessionState>[];
      bool done = false;

      final StreamSubscription<SessionState> sub = bloc.stream.listen(
        seen.add,
        onDone: () => done = true,
        onError: (_) {}, // por seguridad
      );

      // Damos un tiny tick para permitir la primera emisión y cierre.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();

      // Esperamos una única emisión (el último valor) y cierre del stream.
      expect(seen.length, 1);
      expect(seen.first, isA<Unauthenticated>());
      expect(done, isTrue);
    });
    test('stateOrDefault es snapshot y NO emite por sí mismo', () async {
      int emissions = 0;
      final StreamSubscription<SessionState> sub =
          bloc.stream.listen((_) => emissions++);

      final int before = emissions;
      final SessionState snap = bloc.stateOrDefault;
      expect(snap, isA<Unauthenticated>());
      expect(emissions, before);

      await sub.cancel();
    });
  });
}
