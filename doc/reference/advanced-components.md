# PerKeyFifoExecutor
## `PerKeyFifoExecutor`: serializa tareas asíncronas **por clave** (FIFO)

Ejecutor liviano para garantizar **orden y exclusión** por *clave lógica* (p. ej. `docId`, `userId`, `cartId`).  
Las acciones con **la misma clave** se ejecutan **una detrás de otra** (FIFO). Acciones con **claves distintas** pueden correr **en paralelo**.

> Útil cuando debes **evitar carreras** de `write/update/delete` sobre el mismo recurso sin bloquear toda la app.

---

### TL;DR

- **FIFO por clave**: `A(k1) → B(k1) → C(k1)` se ejecutan en ese orden; `A(k1)` y `X(k2)` pueden solaparse.
- **No reentrante por clave**: no llames `withLock(k)` *desde dentro* de otra acción `withLock(k)` (crea espera circular).
- **Errores no rompen la cola**: se propagan al caller y la cola sigue con el siguiente item.
- **Dispose no cancela**: limpia colas futuras; lo que esté en vuelo termina normalmente.

---

### API (resumen)

```dart
class PerKeyFifoExecutor<K extends Object> {
  Future<R> withLock<R>(K key, Future<R> Function() action);
  void dispose();
}
````

---

### Ejemplo básico

```dart
final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();

Future<void> saveUser(String userId, Future<void> Function() ioSave) {
  return exec.withLock<void>(userId, () async {
    await ioSave(); // ¡serializado por userId!
  });
}
```

---

### Devuelve valores y propaga errores

```dart
final res = await exec.withLock<int>('u1', () async {
  // ... I/O ...
  return 42;
});
// res == 42

try {
  await exec.withLock('u1', () async => throw StateError('boom'));
} catch (e) {
  // recibes el error tal cual; la cola 'u1' sigue funcionando
}
```

---

### Paralelismo entre claves

```dart
Future.wait([
  exec.withLock('doc:1', () => writeDoc('1')), // A
  exec.withLock('doc:1', () => writeDoc('1')), // B (espera A)
  exec.withLock('doc:2', () => writeDoc('2')), // C (corre en paralelo con A)
]);
```

---

### Caso de uso: **Repository** con escrituras serializadas por `docId`

Si tu repo ya expone un flag como `serializeWrites`, reemplaza la lógica manual de colas por `PerKeyFifoExecutor`:

```dart
class RepositoryWsDatabaseImpl<T extends Model> implements RepositoryWsDatabase<T> {
  RepositoryWsDatabaseImpl({
    required this.gateway,
    required this.fromJson,
    bool serializeWrites = false,
  }) : _exec = serializeWrites ? PerKeyFifoExecutor<String>() : null;

  final GatewayWsDatabase gateway;
  final T Function(Map<String, dynamic>) fromJson;
  final PerKeyFifoExecutor<String>? _exec;

  @override
  Future<Either<ErrorItem, T>> write(String docId, T entity) {
    Future<Either<ErrorItem, T>> task() async {
      final res = await gateway.write(docId, entity.toJson());
      return res.fold(Left.new, (json) => Right(fromJson(json)));
    }
    return _exec == null ? task() : _exec!.withLock(docId, task);
  }

  @override
  Future<Either<ErrorItem, Unit>> delete(String docId) {
    Future<Either<ErrorItem, Unit>> task() => gateway.delete(docId);
    return _exec == null ? task() : _exec!.withLock(docId, task);
  }

  void dispose() => _exec?.dispose();
}
```

**Ventajas**:

* Código más legible.
* Aísla la política de concurrencia (puedes cambiarla o desactivarla).
* Menos riesgo de fugas al manejar `Completer`s/`Future` en mapas.

---

### Patrón de *mutación segura* (read–modify–write)

```dart
Future<Either<ErrorItem, T>> mutate(String docId, Future<T> Function(T) f) {
  return exec.withLock(docId, () async {
    final cur = await repo.read(docId);            // 1) read
    final next = await f(cur.getOrElse(defaultT)); // 2) pure transform
    return repo.write(docId, next);                // 3) write
  });
}
```

Evitas que dos mutaciones competitivas sobre el mismo `docId` se pisen entre sí.

---

### Anti-patrones y buenas prácticas

* ❌ **Reentrancia por misma clave**:

  ```dart
  await exec.withLock('k', () async {
    // NO llames exec.withLock('k') aquí dentro
  });
  ```

  ✅ En su lugar: compón los pasos dentro **de la misma acción** o dispara otra acción **fuera**.

* ❌ **Usar `bool` para “estado de en vuelo”** como “lock manual” por clave → frágil ante errores.
  ✅ Usa `PerKeyFifoExecutor`: libera el lock en `finally` siempre.

* ✅ **Claves estables**: garantiza `==`/`hashCode` correctos (p. ej. usa `String`/`int` o value-objects bien definidos).

* ✅ **Time-outs** (si un backend puede bloquear): aplica un wrapper:

  ```dart
  await exec.withLock('k', () => action().timeout(const Duration(seconds: 8)));
  ```

* ✅ **Observabilidad**: si necesitas métricas, envuelve `withLock`:

  ```dart
  Future<R> instrumented<R>(String k, Future<R> Function() f) {
    final t0 = DateTime.now();
    return exec.withLock(k, () async {
      try { return await f(); }
      finally { log('$k took ${DateTime.now().difference(t0)}'); }
    });
  }
  ```

---

### Comparación rápida

| Problema                       | Sin executor                      | Con `PerKeyFifoExecutor`           |
|--------------------------------|-----------------------------------|------------------------------------|
| Dos `write(docId)` simultáneas | Posible **race** (última gana)    | **Orden garantizado** por `docId`  |
| Manejo de errores              | Fácil romper la cola              | `try/finally` embebido             |
| Complejidad                    | Mapas de `Completer`s, edge-cases | API única (`withLock`)             |
| Paralelismo entre claves       | Difícil de orquestar              | **Natural** (colas independientes) |

---

### Testing sugerido

```dart
test('serializa por clave y permite paralelo entre claves', () async {
  final exec = PerKeyFifoExecutor<String>();
  final List<String> log = [];

  Future<void> job(String k, String tag, int ms) async {
    await exec.withLock(k, () async {
      log.add('start $tag');
      await Future<void>.delayed(Duration(milliseconds: ms));
      log.add('end $tag');
    });
  }

  await Future.wait([
    job('A', 'A1', 50),
    job('A', 'A2', 10),
    job('B', 'B1', 30),
  ]);

  // A1 debe terminar antes que A2 (FIFO por A)
  final a1End = log.indexOf('end A1');
  final a2End = log.indexOf('end A2');
  expect(a1End, lessThan(a2End));

  // B1 puede intercalar con A1/A2 (paralelo por clave)
  expect(log.contains('end B1'), isTrue);
});
```

---

### Integración con BLoCs

* **Repository** serializa `write/delete`; el **BLoC** permanece simple (no necesita locks).
* En **streams realtime**, la serialización evita “rebote” de lecturas/escrituras sobre el mismo `docId`.

---

### Limpieza

* `dispose()` limpia las colas registradas.
  **Nota**: no cancela lo que ya corre; se usa para liberar memoria/referencias y que nuevas acciones no encadenen con anteriores.

---

### Caso extra: *per-user throttling* (misma idea, otra semántica)

```dart
final exec = PerKeyFifoExecutor<int>(); // userId

Future<void> updateSettings(int userId, Settings s) =>
    exec.withLock(userId, () => api.saveSettings(userId, s));
```

> Mismo patrón, diferente dominio: *evitas saturar el backend y garantizas orden por entidad*.

# Connectivity
## Conectividad (Service → Gateway → Repository → UseCases → Bloc)

## Objetivo

Exponer el estado de conectividad de forma **reactiva**, con **errores como datos** (`Either<ErrorItem, ConnectivityModel>`) y capas bien separadas, siguiendo la guía de estructura de Jocaagura.

```
UI → AppManager → Bloc → UseCase → Repository → Gateway → Service
```

> 🔗 Estructura y convenciones:
> [README_STRUCTURE.md](../../README_STRUCTURE.md)

---

## Modelo de dominio

```dart
// Ya incluido en jocaagura_domain
class ConnectivityModel extends Model {
  final ConnectionTypeEnum connectionType;
  final double internetSpeed; // Mbps
  bool get isConnected => connectionType != ConnectionTypeEnum.none;
}
```

---

## Paso a paso de la integración

### 1) Service (fuente de datos “baja”)

Responsable de hablar con la plataforma y entregar **tipo de conexión**, **velocidad**, y un **stream** de `ConnectivityModel`.

* En dev/tests: `FakeServiceConnectivity` (sin paquetes externos).
* En producción: implementa tu propio `ServiceConnectivity` (ej. usando plugins).

```dart
final service = FakeServiceConnectivity(
  latencyConnectivity: const Duration(milliseconds: 80),
  latencySpeed: const Duration(milliseconds: 120),
  initial: const ConnectivityModel(
    connectionType: ConnectionTypeEnum.wifi,
    internetSpeed: 40,
  ),
);
```

### 2) Gateway (I/O crudo + manejo de excepciones)

Convierte el Service a **payloads crudos** (`Map<String, dynamic>`) y **nunca lanza**: siempre retorna `Either<ErrorItem, Map>`.

```dart
final gateway = GatewayConnectivityImpl(service, DefaultErrorMapper());
```

### 3) Repository (mapeo a dominio + errores de negocio)

Convierte `Map` → `ConnectivityModel` y detecta **errores de negocio** en el payload con `ErrorMapper`.

```dart
final repo = RepositoryConnectivityImpl(
  gateway,
  errorMapper: DefaultErrorMapper(),
);
```

### 4) UseCases (APIs de aplicación)

* `GetConnectivitySnapshotUseCase`
* `WatchConnectivityUseCase`
* `CheckConnectivityTypeUseCase`
* `CheckInternetSpeedUseCase`

```dart
final watch     = WatchConnectivityUseCase(repo);
final snapshot  = GetConnectivitySnapshotUseCase(repo);
final checkType = CheckConnectivityTypeUseCase(repo);
final checkSpeed= CheckInternetSpeedUseCase(repo);
```
### 5) Bloc (reactivo y **puro**)

El BLoC **no conoce la UI**. Emite `Either<ErrorItem, ConnectivityModel>`.

```dart
final bloc = BlocConnectivity(
  watch: watch,
  snapshot: snapshot,
  checkType: checkType,
  checkSpeed: checkSpeed,
);

await bloc.loadInitial();
bloc.startWatching();
// ...
bloc.dispose();
```

### 6) UI (presentación y UX de errores)

La UI **decide** cómo mostrar los errores. Recomendamos envolver la vista con un `ErrorItemWidget` (SnackBar/Banner) y renderizar el `ConnectivityModel` cuando `Right`.

```dart
StreamBuilder<Either<ErrorItem, ConnectivityModel>>(
  stream: bloc.stream,
  initialData: bloc.value,
  builder: (context, snap) {
    final either = snap.data ?? bloc.value;
    return ErrorItemWidget( // muestra SnackBar cuando Left(ErrorItem)
      state: either as Either<ErrorItem, Object>,
      child: either.isRight
        ? Text('Type: ${ (either as Right).value.connectionType.name }')
        : const SizedBox.shrink(), // conserva último estado bueno si quieres
    );
  },
);
```

### 7) Contrato de Error (semántica)

* **Gateway**: mapea **excepciones** del Service → `Left(ErrorItem)`.
* **Repository**: detecta **errores de negocio** en el payload (`{'error': {...}}`, `ok:false`, etc.) → `Left(ErrorItem)`.
* **Bloc**: **no lanza**; re-emite `Left(ErrorItem)` o `Right(ConnectivityModel)`.

> Usa `DefaultErrorMapper()` si no necesitas uno específico.
> En producción, define códigos/semántica de `ErrorItem` y su mapping visual (warning/info/error).

---

## Ejemplo rápido (AppManager / DI)

```dart
class ConnectivityModule {
  late final ServiceConnectivity service;
  late final GatewayConnectivity gateway;
  late final RepositoryConnectivity repo;
  late final BlocConnectivity bloc;

  ConnectivityModule() {
    service  = FakeServiceConnectivity(); // prod: tu Service real
    gateway  = GatewayConnectivityImpl(service, DefaultErrorMapper());
    repo     = RepositoryConnectivityImpl(gateway, errorMapper: DefaultErrorMapper());
    bloc     = BlocConnectivity(
      watch: WatchConnectivityUseCase(repo),
      snapshot: GetConnectivitySnapshotUseCase(repo),
      checkType: CheckConnectivityTypeUseCase(repo),
      checkSpeed: CheckInternetSpeedUseCase(repo),
    );
  }

  Future<void> init() async {
    await bloc.loadInitial();
    bloc.startWatching();
  }

  void dispose() {
    bloc.dispose();
    service.dispose();
  }
}
```

---

## Tests (solo `flutter_test`)

Se incluyen suites de ejemplo:

* `fake_service_connectivity_test.dart`
* `gateway_connectivity_impl_test.dart`
* `repository_connectivity_impl_test.dart`
* `bloc_connectivity_test.dart`

Ejecuta:

```bash
flutter test
```

---

## Consejos de producción

* Reemplaza `FakeServiceConnectivity` por un Service real (plugins/SDK).
* Centraliza la presentación de errores en un widget reusable o notificador global.
* Define códigos de error (`ErrorItem.code`) y su mapeo visual para UX consistente.
* Revisa linters y convenciones:
  [analysis_options.yaml](../../analysis_options.yaml)

---

# BlocOnboarding
## Propósito y flujo

`BlocOnboarding` orquesta un **flujo de onboarding por pasos** (tour inicial, permisos, configuración mínima). Cada paso puede ejecutar un **side-effect al entrar** (`onEnter`) que retorna `FutureOr<Either<ErrorItem, Unit>>`.

* Si `onEnter` retorna `Right(Unit)`, el paso es válido y puede **auto-avanzar** usando `autoAdvanceAfter`.
* Si `onEnter` retorna `Left(ErrorItem)` **o lanza una excepción**, el BLoC **no avanza** y expone el error en `state.error`. Las excepciones se mapean a `ErrorItem` usando `ErrorMapper` (por defecto `DefaultErrorMapper`).

**Flujo propuesto (Clean Architecture):**

```
UI → AppManager → BlocOnboarding
```

> Onboarding es **orquestación de UI**; típicamente no requiere Repository/Gateway/Service. Si necesitas I/O (p.ej. guardar bandera “onboardingDone”), hazlo dentro de `onEnter` del paso o en un UseCase invocado desde allí.

---

### Escenarios principales a implementar

* **Tour inicial de la app** (3–5 pantallas con mensajes).
* **Solicitud de permisos** (ubicación, notificaciones) con validación por paso.
* **Configuración mínima** (selección de idioma/tema, aceptación de T\&C).
* **Chequeos previos** (descarga de configuración remota, migraciones locales).

---

### Semántica de errores

* `onEnter` → `Either<ErrorItem, Unit>`

    * `Right(Unit)`: paso OK → si `autoAdvanceAfter` > 0, **programa avance**.
    * `Left(ErrorItem)`: **permanece** en el paso y setea `state.error`.
    * **Throw**: se mapea con `ErrorMapper` → `state.error`.
* La UI puede llamar `clearError()` y luego `retryOnEnter()` para reintentar el paso actual.

---

### Concurrencia y temporizadores

* **Solo un timer activo** a la vez (para `autoAdvanceAfter`).
* Cualquier comando (`start/next/back/skip/complete/retryOnEnter`) **cancela** el timer en curso.
* Protección contra **completions obsoletos**: el BLoC usa un “epoch” interno para **ignorar** resultados tardíos de `onEnter` si el usuario ya navegó a otro paso.

---

## API en breve

* `configure(List<OnboardingStep>)` — define los pasos.
* `start()` — entra a `stepIndex=0` (o `completed` si no hay pasos).
* `next() / back()` — navegación manual.
* `skip()` / `complete()` — termina el flujo (saltado o completado).
* `clearError()` — borra `state.error` sin cambiar paso.
* `retryOnEnter()` — re-ejecuta el `onEnter` del paso actual.
* `stateStream` / `state` — acceso reactivo y snapshot del estado.

`OnboardingStep`:

* `title`, `description` (opcionales).
* `autoAdvanceAfter?: Duration` — auto-avance tras éxito de `onEnter`.
* `onEnter?: FutureOr<Either<ErrorItem, Unit>> Function()` — side-effect al entrar.

---

## Ejemplo rápido

```dart
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:flutter/material.dart';

class OnboardingExample extends StatefulWidget {
  const OnboardingExample({super.key});

  @override
  State<OnboardingExample> createState() => _OnboardingExampleState();
}

class _OnboardingExampleState extends State<OnboardingExample> {
  late final BlocOnboarding bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocOnboarding(); // o inyéctalo vía AppManager

    Either<ErrorItem, Unit> ok() => Right<ErrorItem, Unit>(Unit.value);
    Either<ErrorItem, Unit> err(String msg) => Left<ErrorItem, Unit>(
      ErrorItem(message: msg, code: 'ONB-STEP', severity: ErrorSeverity.blocking),
    );

    FutureOr<Either<ErrorItem, Unit>> requestNotifications() async {
      // Simula pedir permisos…
      final bool granted = true; // reemplaza con lógica real
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return granted ? ok() : err('Notifications are required');
    }

    FutureOr<Either<ErrorItem, Unit>> seedRemoteConfig() async {
      // Simula I/O (descarga de configuración)
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return ok();
    }

    bloc.configure(<OnboardingStep>[
      OnboardingStep(
        title: 'Welcome',
        description: 'Quick tour',
        onEnter: () => ok(),
        autoAdvanceAfter: const Duration(milliseconds: 700),
      ),
      OnboardingStep(
        title: 'Notifications',
        description: 'We will ask permission to keep you informed',
        onEnter: requestNotifications, // puede devolver Left(ErrorItem)
        autoAdvanceAfter: const Duration(milliseconds: 600),
      ),
      OnboardingStep(
        title: 'Setup',
        description: 'Loading remote config',
        onEnter: seedRemoteConfig,
        // sin autoAdvance: el usuario verá "Next"
      ),
    ]);

    // Arranca el flujo
    WidgetsBinding.instance.addPostFrameCallback((_) => bloc.start());
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OnboardingState>(
      stream: bloc.stateStream,
      initialData: bloc.state,
      builder: (BuildContext context, AsyncSnapshot<OnboardingState> snap) {
        final OnboardingState s = snap.data ?? OnboardingState.idle();

        // Muestra error bloqueante (si lo hay)
        final Widget errorBanner = (s.error != null)
            ? MaterialBanner(
                content: Text(s.error!.message),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      bloc.clearError();
                      bloc.retryOnEnter(); // reintenta el paso
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            : const SizedBox.shrink();

        return Scaffold(
          appBar: AppBar(title: const Text('Onboarding')),
          body: Column(
            children: <Widget>[
              errorBanner,
              Expanded(
                child: Center(
                  child: Text(
                    'Step ${s.stepIndex + 1} / ${s.totalSteps}\n'
                    'Status: ${s.status}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: OutlinedButton(onPressed: bloc.back, child: const Text('Back'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: bloc.next, child: const Text('Next'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: bloc.skip, child: const Text('Skip'))),
                    const SizedBox(width: 8),
                    Expanded(child: FilledButton(onPressed: bloc.complete, child: const Text('Complete'))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

**Notas del ejemplo**

* El segundo paso simula pedir permisos y puede fallar → la UI muestra el `MaterialBanner` con “Retry”.
* `autoAdvanceAfter` solo se agenda cuando `onEnter` finaliza con `Right(Unit)`.
* Los botones manuales siempre **cancelan timers** activos antes de navegar.

---

### Buenas prácticas

* Mantén `onEnter` **rápido**; si requiere I/O, muestra feedback de carga en la UI (por ejemplo, con tu `BlocLoading`) mientras esperas el `Either`.
* Usa `ErrorMapper` custom si deseas enriquecer `location`, `code` o `severity`.
* Prueba el flujo con **pasos que fallan** y valida `retryOnEnter()` en la UI.

---

### Pruebas (incluidas en el paquete)

* **Core**: estados iniciales, `configure/start/next/back/skip/complete`.
* **Timers**: auto-avance condicionado por éxito, cancelación y reprogramación en navegación.
* **onEnter (async & errors)**: lanzamientos mapeados a `ErrorItem`, `clearError + retryOnEnter`, y protección contra completions obsoletos (epoch guard).

---
# BlocResponsive

## BlocResponsive — validación visual de breakpoints (microsección)

**Objetivo.** Verificar y documentar cómo la app adapta layout (márgenes, gutters, columnas, área de trabajo y tipo de dispositivo) según el ancho del viewport, usando `BlocResponsive` y su demo.

### Cómo usar la Demo

1. Registra y abre `BlocResponsiveDemoPage` (incluida en `example/`).
2. Usa los **switches**:

    * **Show grid overlay**: muestra/oculta columnas y gutters.
    * **Simulate size (sliders)**: mueve `Width/Height` para probar distintos anchos sin cambiar de dispositivo.
    * **Show AppBar** (en la AppBar): alterna la política y observa `screenHeightWithoutAppbar`.
3. Observa en **Metrics**:

    * `Device` cambia entre **MOBILE / TABLET / DESKTOP / TV** según los umbrales de `ScreenSizeConfig`.
    * `Columns`, `Margin`, `Gutter`, `Column width`, `Work area` y `Drawer` se actualizan en vivo.
    * En **DESKTOP/TV** el `Work area` aplica el porcentaje configurado (no ocupa el 100% del viewport).

### Checklist de QA (aceptación)

* [ ] Al cruzar los breakpoints de `ScreenSizeConfig` cambia `Device` y `Columns` correctamente.
* [ ] `marginWidth` y `gutterWidth` se recalculan al variar el ancho; la grilla se mantiene alineada.
* [ ] `columnWidth` = `(workArea − márgenes − gutters) / columns` (sin valores negativos).
* [ ] En **DESKTOP/TV**, `workArea.width` respeta el **porcentaje** configurado; en **MOBILE/TABLET** usa el ancho total.
* [ ] `widthByColumns(n)` incluye gutters entre columnas y nunca supera `workArea.width`.
* [ ] Con “Show AppBar” desactivado, `screenHeightWithoutAppbar` = `size.height`.
* [ ] No hay “parpadeos”: al mover sliders, métricas y grilla cambian de forma estable.

### Integración recomendada (app real)

```dart
class MyLayout extends StatelessWidget {
  const MyLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final BlocResponsive responsive = AppManager.of(context).config.blocResponsive;

    // Mantén sincronizado el tamaño del viewport con el bloc.
    responsive.setSizeFromContext(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.marginWidth),
      child: SizedBox(
        width: responsive.widthByColumns(4).clamp(0, responsive.workAreaSize.width),
        child: Text('Device: ${responsive.deviceType} • Cols: ${responsive.columnsNumber}'),
      ),
    );
  }
}
```

### Pruebas sin Flutter (headless)

```dart
final bloc = BlocResponsive();
bloc.setSizeForTesting(const Size(1280, 800));
expect(bloc.isDesktop, isTrue);
expect(bloc.columnsNumber, bloc.sizeConfig.desktopColumnsNumber);
expect(bloc.widthByColumns(3) <= bloc.workAreaSize.width, isTrue);
bloc.dispose();
```

> 🧭 Arquitectura: **UI → AppManager → BlocResponsive** (infra de presentación, sin I/O).
> 🔧 Configuración: todos los umbrales y porcentajes provienen de `ScreenSizeConfig` (config-driven, sin “magic numbers”).
