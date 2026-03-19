# Documentación de Modelos

Los diagramas UML de este proyecto utilizan colores para indicar el estado de implementación de cada modelo:
- **Verde:** El modelo ha sido completamente implementado y está incluido en el paquete actual.
- **Blanco/Gris:** El modelo está pendiente de implementación o en proceso de desarrollo.
- **Naranja:** El modelo está revisión y/o proceso de transformación.

  Una legenda correspondiente se encuentra incluida en cada diagrama para facilitar la interpretación de estos colores.

## 🧰 Servicios disponibles

Seccion en la que se listan los servicios disponibles en el dominio de la aplicación. Cada servicio tiene su implementación abstracta y una versión fake para pruebas unitarias. Los nombres de los archivos siguen un patrón consistente para facilitar su identificación y uso.
Esta seccion esta en evolución y se ira actualizando conforme se vayan implementando nuevos servicios o se modifiquen los existentes.

| Servicio                  | Abstracto (`lib/domain/services/`) | Fake (`lib/src/fakes/`)           |
|---------------------------|------------------------------------|-----------------------------------|
| 🗄️ Base de datos NoSQL   | `service_ws_database.dart`         | `fake_service_ws_database.dart`   |
| 🔐 Sesión / Autenticación | `service_session.dart`             | `fake_service_session.dart`       |
| 📍 Geolocalización        | `service_location.dart`            | `fake_service_location.dart`      |
| 🌀 Giroscopio             | `service_gyroscope.dart`           | `fake_service_gyroscope.dart`     |
| 🔔 Notificaciones         | `service_notifications.dart`       | `fake_service_notifications.dart` |
| 🧠 Preferencias locales   | `service_preferences.dart`         | `fake_service_preferences.dart`   |
| 📡 Conectividad           | `service_connectivity.dart`        | `fake_service_connectivity.dart`  |
| 🌐 HTTP genérico          | `service_http.dart`                | `fake_service_http.dart`          |

# Cómo integrar BlocSession (con FakeServiceSession para desarrollo)

Este fragmento muestra el cableado completo **UI → AppManager → Bloc → UseCase → Repository → Gateway → Service**, usando `BlocSession` y un `FakeServiceSession` para ambientes de **desarrollo/test**. Ajusta nombres si tu proyecto usa implementaciones distintas.

## 1) Infraestructura (Service → Gateway → Repository)

```dart
import 'package:jocaagura_domain/jocaagura_domain.dart';

final ServiceSession service = FakeServiceSession(
  latency: const Duration(milliseconds: 250), // simula red
  // Opcional: arrancar ya autenticado
  // initialUserJson: {
  //   'id': 'seed',
  //   'displayName': 'Seed',
  //   'photoUrl': 'https://fake.com/photo.png',
  //   'email': 'seed@x.com',
  //   'jwt': {
  //     'accessToken': 'seed-token',
  //     'issuedAt': DateTime.now().toIso8601String(),
  //     'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
  //   },
  // },
  // Opcional: forzar fallos de login/signin/google
  // throwOnSignIn: true,
);

// Implementación base sugerida (usa tu mapper y clases reales)
final ErrorMapper errorMapper = DefaultErrorMapper();
final GatewayAuth gateway = GatewayAuthBasic(
  service: service,
  errorMapper: errorMapper,
);
final RepositoryAuth repository = RepositoryAuthImpl(
  gateway: gateway,
  errorMapper: errorMapper,
);
```

## 2) Use cases + watcher de auth

```dart
final SessionUsecases usecases = SessionUsecases(
  logInUserAndPassword: LogInUserAndPasswordUsecase(repository),
  logOutUsecase: LogOutUsecase(repository),
  signInUserAndPassword: SignInUserAndPasswordUsecase(repository),
  recoverPassword: RecoverPasswordUsecase(repository),
  logInSilently: LogInSilentlyUsecase(repository),
  loginWithGoogle: LoginWithGoogleUsecase(repository),
  refreshSession: RefreshSessionUsecase(repository),
  getCurrentUser: GetCurrentUserUsecase(repository),
  watchAuthStateChangesUsecase: WatchAuthStateChangesUsecase(repository),
);
final WatchAuthStateChangesUsecase watchUC =
    WatchAuthStateChangesUsecase(repository);
```

## 3) Crear el BlocSession

```dart
final BlocSession sessionBloc = BlocSession(
  usecases: usecases,
  watchAuthStateChanges: watchUC,
  // Debouncers para prevenir doble tap (UI rápida)
  authDebouncer: Debouncer(milliseconds: 250),
  refreshDebouncer: Debouncer(milliseconds: 250),
);

// No fuerza silent-login: solo se suscribe a cambios del repo
await sessionBloc.boot()
```

## 4) Usarlo en la UI

```
// Leer estado reactivo
StreamBuilder<SessionState>(
  stream: sessionBloc.sessionStream,
  initialData: const Unauthenticated(),
  builder: (_, snap) {
    final s = snap.data ?? const Unauthenticated();
    if (s is Authenticating) return const Text('Authenticating...');
    if (s is Refreshing) return const Text('Refreshing...');
    if (s is SessionError) return Text('Error: ${s.message.code}');
    if (s is Authenticated) return Text('Hi ${s.user.email}');
    return const Text('Signed out');
  },
);

// Acciones
final result = await sessionBloc.logIn(email: 'me@mail.com', password: 'secret');
result.fold(
  (err) => debugPrint('Login failed: ${err.code}'),
  (user) => debugPrint('Welcome ${user.email}'),
);

// Helpers
final bool isAuthed = sessionBloc.isAuthenticated;
final UserModel me = sessionBloc.currentUser; // defaultUserModel si no hay sesión
```

## 5) Recomendaciones y matices

* **Estado inicial:** `Unauthenticated`. `boot()` solo **escucha** `authStateChanges` del repo; no realiza `silent-login` automáticamente.
* **Errores:** `Left(ErrorItem)` → `SessionError(err)`. La UI decide si reintentar, mostrar modal, etc.
* **Silent/Refresh:** si no hay sesión previa, devuelven `null` y el BLoC permanece/queda en `Unauthenticated`.
* **Debouncer:** evita doble tap en botones. Si necesitas *concurrencia estricta*, puedes reemplazar por flags “in-flight”.
* **Secuencias rápidas:** para verificar `Refreshing → Authenticated` en tests, suscríbete **antes** de llamar a `refreshSession()` (los estados pueden emitirse muy seguido).
* **Dispose:** llama `sessionBloc.dispose()` en `dispose()` de tu widget/app.

## 6) FakeServiceSession (para desarrollo/test)

El `FakeServiceSession` es un **service** de bajo nivel que:

* Trabaja con `Map<String, dynamic>` (sin modelos del dominio).
* Emite `authStateChanges()` con el payload de usuario o `null`.
* Simula latencia (`latency`) y puede **arrancar logueado** (`initialUserJson`).
* Puede forzar error en flujos de login (`throwOnSignIn: true`).
* **Lanza** excepciones crudas (`ArgumentError`, `StateError`): el **Gateway** debe capturarlas y mapear a `ErrorItem`.

### Ejemplos rápidos

```dart
// Arrancar logueado
final svc = FakeServiceSession(
  latency: const Duration(milliseconds: 150),
  initialUserJson: {
    'id': 'seed',
    'displayName': 'Seed',
    'photoUrl': 'https://fake.com/photo.png',
    'email': 'seed@x.com',
    'jwt': {
      'accessToken': 'seed-token',
      'issuedAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    },
  },
);

// Forzar fallo de login
final svcFail = FakeServiceSession(throwOnSignIn: true);
```

> ⚠️ El fake es **solo** para desarrollo/pruebas. En producción, usa un `ServiceSession` real (SDK/REST), con su `GatewayAuth` mapeando errores a `ErrorItem` (apóyate en `SessionErrorItems`/`HttpErrorItems` para códigos estándar).

---
## Cómo integrar `BlocWsDatabase` (con `FakeServiceWsDatabase` para desarrollo)

Esta guía muestra el **cableado completo UI → BLoC → Facade → Repository → Gateway → Service** usando el **fake** de base de datos por WebSocket incluido en el paquete. Con esto puedes hacer **CRUD** y **watch (realtime)** sobre un documento sin depender aún de tu backend real.

> Flujo de capas  
> `UI` → `BlocWsDatabase<T>` → `FacadeWsDatabaseUsecases<T>` → `RepositoryWsDatabase<T>` → `GatewayWsDatabase` → `ServiceWsDatabase<Map<String,dynamic>>` *(Fake)*

---

### 1) Infraestructura (Service → Gateway → Repository → Facade → BLoC)

```dart
import 'package:jocaagura_domain/jocaagura_domain.dart';

// 1) Transporte (fake en memoria con streams por doc/colección)
final FakeServiceWsDatabase service = FakeServiceWsDatabase(
  // Opcional: simula latencia de red
  // latency: const Duration(milliseconds: 150),
);

// 2) Gateway (mapea errores, inyecta id, multiplexa watch por docId)
final GatewayWsDatabaseImpl gateway = GatewayWsDatabaseImpl(
  service: service,
  collection: 'users', // <- tu tabla/colección
);

// 3) Repository (JSON <-> Model + serialización de writes opcional)
final RepositoryWsDatabaseImpl<UserModel> repository =
    RepositoryWsDatabaseImpl<UserModel>(
  gateway: gateway,
  fromJson: UserModel.fromJson,
  serializeWrites: true, // evita solapes de escrituras por docId
);

// 4) Facade (agrupa todos los casos de uso: read/write/delete/watch/etc.)
final FacadeWsDatabaseUsecases<UserModel> facade =
    FacadeWsDatabaseUsecases<UserModel>.fromRepository(
  repository: repository,
  fromJson: UserModel.fromJson,
);

// 5) BLoC (publica WsDbState<T>: loading/error/doc/docId/isWatching)
final BlocWsDatabase<UserModel> bloc = BlocWsDatabase<UserModel>(facade: facade);
````

---

### 2) UI mínima (leer, escribir y observar un documento)

```dart
class UserDocPage extends StatefulWidget {
  const UserDocPage({super.key});
  @override
  State<UserDocPage> createState() => _UserDocPageState();
}

class _UserDocPageState extends State<UserDocPage> {
  final TextEditingController _id = TextEditingController(text: 'user_001');

  @override
  void dispose() {
    bloc.dispose(); // cierra stream de estado del BLoC
    _id.dispose();
    super.dispose();
  }

  UserModel _buildUser(String id) => UserModel(
        id: id,
        displayName: 'John Doe',
        photoUrl: 'https://example.com/profile.jpg',
        email: 'john.doe@example.com',
        jwt: const <String, dynamic>{},
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WsDatabase — Demo')),
      body: StreamBuilder<WsDbState<UserModel>>(
        stream: bloc.stream,
        initialData: bloc.value,
        builder: (_, snap) {
          final s = snap.data ?? WsDbState<UserModel>.idle();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _id,
                decoration: const InputDecoration(labelText: 'docId'),
              ),
              const SizedBox(height: 12),
              if (s.loading) const LinearProgressIndicator(),
              if (s.error != null) Text('Error: ${s.error!.code}'),
              if (s.doc != null) ...[
                Text('id: ${s.doc!.id}'),
                Text('name: ${s.doc!.displayName}'),
                Text('email: ${s.doc!.email}'),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => bloc.readDoc(_id.text.trim()),
                    child: const Text('Read'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final id = _id.text.trim();
                      bloc.writeDoc(id, _buildUser(id));
                    },
                    child: const Text('Write / Upsert'),
                  ),
                  ElevatedButton(
                    onPressed: () => bloc.startWatch(_id.text.trim()),
                    child: const Text('Watch'),
                  ),
                  ElevatedButton(
                    onPressed: () => bloc.stopWatch(_id.text.trim()),
                    child: const Text('Stop watch'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

### 3) (Opcional) Smoke test de realtime sin backend

Para “ver” el `watch` en vivo, puedes simular que el servidor actualiza el documento cada segundo con el **ticker** (usa el *Service* directamente, como si fuese el backend):

```
// Simula cambios del servidor incrementando un contador en jwt.countRef
final WsDocTicker ticker = WsDocTicker(
  service: service,
  collection: 'users',
  docId: 'user_001',
  seedMode: SeedMode.minimalCountOnly, // crea si falta
);

// Arranca (y detén) el motor cuando quieras
await ticker.start();       // incrementa cada segundo
// await ticker.stop();
```

---

### 4) Buenas prácticas y matices

* **Colecciones:** el `GatewayWsDatabaseImpl` está **anclado a una colección** (`collection: 'users'`). Si necesitas otra tabla, crea **otro gateway** (y normalmente su repo/facade/bloc).
* **Watch eficiente:** el gateway **multiplexa** por `docId` (un solo canal compartido). Tras cancelar un watch, el BLoC llama a `detach()` para liberar recursos.
* **Errores coherentes:** todo devuelve `Either<ErrorItem, …>`. En UI, si llega `Left`, muestra `error.code/title/description`.
* **Serialización de escrituras:** `serializeWrites: true` evita condiciones de carrera si la UI dispara varios writes rápidos al mismo doc.
* **Dispose:** llama `bloc.dispose()` al cerrar la pantalla. Si **eres dueño** de toda la pila, puedes además invocar `facade.disposeAll()` en un punto global (p. ej., logout).
* **Migración a backend real:** reemplaza `FakeServiceWsDatabase` por tu `ServiceWsDatabase` real (WS/SDK), manteniendo Gateway/Repository/Facade/BLoC **idénticos**.
* **REST sin realtime:** si tu backend es sincrónico, usa la `FacadeCrudDatabaseUsecases<T>` (sin `watch`) con tu propio repositorio/servicio.

> Con este patrón mantienes UI limpia, capas testeables y un camino directo de “**fake en desarrollo** → **backend real en producción**” sin reescribir la app.

----
# Unit
## `Unit`: éxito sin carga útil (type-safe)

`Unit` representa *la ausencia de un valor significativo* de forma **segura para tipos**.  
Úsalo cuando una operación **sucede** pero **no tiene nada que devolver**. Es equivalente al “`void` con valor”, ideal para *genéricos* (`Either`, `Future`, `Stream`, `UseCase`, etc.).

### ¿Por qué no `void`, `Null` o `bool`?
- **`void`** no puede ser usado como valor (no cabe en `Either`, `Future.value`, colecciones, etc.).
- **`Null`** introduce ambigüedad con null-safety y no expresa éxito.
- **`bool`** confunde éxito/fracaso con *estado lógico*; los errores deberían viajar en un `Left(ErrorItem)` y no como `false`.

`Unit` evita esos problemas y mantiene la semántica clara:  
**Right(unit) = éxito sin datos**.

---

### API
```dart
@immutable
class Unit {
  const Unit._();
  static const Unit value = Unit._();
  @override String toString() => 'unit';
  @override bool operator ==(Object other) => other is Unit;
  @override int get hashCode => 0;
}
const Unit unit = Unit.value;
````

---

### Casos de uso comunes

1. **Comandos** (crear/actualizar/eliminar) que no retornan entidad

```dart
Future<Either<ErrorItem, Unit>> deleteUser(String id) async {
  try {
    await api.delete('/users/$id');
    return Right(unit); // éxito sin payload
  } catch (e, s) {
    return Left(mapper.fromException(e, s));
  }
}
```

2. **Use cases** sin retorno

```dart
class DetachWatchUseCase<T> implements UseCase<Either<ErrorItem, Unit>, DeleteParams> {
  DetachWatchUseCase(this.repo);
  final RepositoryWsDatabase<T> repo;

  @override
  Future<Either<ErrorItem, Unit>> call(DeleteParams p) async {
    repo.detachWatch(p.docId);
    return Right(unit);
  }
}
```

3. **Batch/operaciones por id** (map de resultados)

```dart
Future<Either<ErrorItem, Map<String, Either<ErrorItem, Unit>>>> deleteMany(List<String> ids) async {
  final Map<String, Either<ErrorItem, Unit>> out = {};
  for (final id in ids) {
    out[id] = await deleteUser(id);
  }
  return Right(out);
}
```

4. **Streams/eventos** donde solo importa la *señal*

```
final StreamController<Unit> tick = StreamController<Unit>.broadcast();
// emitir una señal
tick.add(unit);
// escuchar señales
tick.stream.listen((_) => print('tick!'));
```

5. **Adaptar APIs** para composición

```
// convertir Future<void> -> Future<Either<ErrorItem, Unit>>
Future<Either<ErrorItem, Unit>> wrap(Future<void> f) async {
  try { await f; return Right(unit); }
  catch (e, s) { return Left(mapper.fromException(e, s)); }
}
```

---

### Patrones con `Either`

```
final Either<ErrorItem, Unit> res = await deleteUser('u1');

res.fold(
  (err) => logger.error(err.code),
  (_)   => logger.info('Deleted!'),
);

// map / flatMap siguen funcionando (el valor es estable)
final Either<ErrorItem, Unit> chained = res.map((_) => unit);
```

---

### En BLoC

```dart
Future<void> onStopWatch(String id) async {
  value = value.copyWith(loading: true);
  final result = await facade.detach(id); // Either<ErrorItem, Unit>
  result.fold(
    (err) => value = value.copyWith(error: err),
    (_)    => value = value.copyWith(isWatching: false, error: null),
  );
  value = value.copyWith(loading: false);
}
```

---

### Testing con `Unit`

```
test('delete returns Right(unit)', () async {
  final r = await deleteUser('u1');
  expect(r, isA<Right<ErrorItem, Unit>>());
  // o más explícito:
  r.fold(
    (_) => fail('expected Right'),
    (u) => expect(u, unit),
  );
});
```

---

### Recomendaciones

* Devuelve `Either<ErrorItem, Unit>` en **comandos**; usa `Either<ErrorItem, T>` en **queries**.
* Evita mezclar `Unit` con significados como “sin cambios” o “cancelado”; si necesitas distinguirlos, crea **tipos específicos** (`CommandResult` con variantes, por ejemplo).
* Prefiere el alias `unit` para escribir menos y mantener consistencia.


