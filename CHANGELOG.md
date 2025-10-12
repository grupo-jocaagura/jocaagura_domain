# CHANGELOG Jocaagura Domain

This document follows the guidelines of [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.30.3] - 2025-10-12

### Added

- **Domain – `ModelAppVersion`:** modelo inmutable para versionamiento de apps.
  - Campos: `id`, `appName`, `version`, `buildNumber`, `platform`, `channel`,
    `minSupportedVersion`, `forceUpdate`, `artifactUrl`, `changelogUrl`, `commitSha`, `buildAt`.
  - `fromJson`/`toJson` para (de)serialización robusta.

- **Utils – Deep compare & hashing:**
  - `Utils.deepEqualsDynamic` para comparar recursivamente valores dinámicos (listas/mapas
    anidados).
  - `Utils.deepEqualsMap` para comparar mapas con llaves `String`.
  - `Utils.deepHash` para *hash* profundo (orden-independiente en mapas, orden-sensible en listas).

### Changed

- **ModelAppVersion (refactor):**
  - **Inmutabilidad reforzada:** `buildAt` se almacena siempre en **UTC**; `meta` queda envuelto en
    `Map.unmodifiable` tanto en el constructor como en `copyWith`.
  - **Igualdad y hashing:** `operator==` usa `Utils.deepEqualsMap` para `meta`; `hashCode` usa
    `Utils.deepHash` garantizando consistencia con la igualdad por contenido.
  - **JSON:** `fromJson` normaliza llaves de `meta` y endurece el *parsing*; `toJson` serializa
    `buildAt` como **UTC**.

### Docs

- **ModelAppVersion:** DartDoc detallada de contratos y comportamiento de JSON (UTC, `meta`
  inmutable).
- **Utils:** documentación y ejemplos de uso para `deepEqualsDynamic`, `deepEqualsMap` y `deepHash`.

### Tests

- **model_app_version_test.dart:**
  - Garantías de inmutabilidad (UTC, `meta` inmodificable).
  - Igualdad profunda y consistencia `hashCode`.
  - Cobertura de `copyWith`.
  - *Round-trip* JSON con mapas dinámicos y variaciones de zona horaria.

## [1.30.2] - 2025-10-12

### Added

- **Session – Side-effect hooks en `BlocSession`:**
  - `addFunctionToProcessTValueOnStream(key, callback, [executeNow=false])`: registra un *callback*
    que se dispara en **cada** emisión de `SessionState`, con opción de ejecución inmediata usando
    el estado actual.
  - `deleteFunctionToProcessTValueOnStream(key)`: elimina el *callback* registrado por su clave.
  - `containsFunctionToProcessValueOnStream(key)`: verifica si existe un *callback* para la clave
    dada.

### Tests

- **bloc_session_hooks_test.dart**: cobertura completa para registro, ejecución inmediata,
  eliminación, reemplazo y comportamiento de ciclo de vida (limpieza en `dispose()`).

### Notes

- Cambios **no rompientes**. Las APIs de hooks exponen de forma segura la funcionalidad subyacente
  de `BlocGeneral` sin modificar el flujo de sesión existente.

## [1.30.1] - 2025-09-24

### Changed

- **Session:** `BlocSession` ahora **extiende `BlocModule`** para unificar el ciclo de vida con el
  resto de BLoCs del paquete.

### Added

- **Session:** identificador estático `BlocSession.name` para trazabilidad y registros.

### Fixed

- **Lifecycle:** se **sobrescribe `dispose()`** en `BlocSession` para alinearlo con el contrato de
  `BlocModule`, garantizando liberación consistente de recursos.

### Notes

- No hay cambios en la API pública de métodos de `BlocSession`.
- Si tu código dependía del **tipo base anterior** en anotaciones genéricas o *type checks*, ajusta
  las restricciones para aceptar `BlocModule`.

## [1.30.0] - 2025-09-24

### Added

- **Ledger – Datos y demo visual:**
  - `defaultLedgerModel` (dataset liviano 2024: ingresos/egresos por categoría).
  - `ledger_example.dart`: página Flutter que renderiza **pie** y **barras** anuales por
    categoría/mes usando `CustomPainter` (sin dependencias externas).
- **Session – API de arranque rápido:**
  - `BlocSession.fromRepository(RepositoryAuth repo)`: *factory* recomendado que cablea
    automáticamente los *use cases* necesarios.
- **Session – Calidad de vida:**
  - `SessionError.error`: *alias* de `message` para acceso conveniente.
- **Auth – Pruebas Gateway/Repo:**
  - Suite completa para `GatewayAuthImpl`:
    - *Stubs* `_StubServiceSession` y *fake* `ErrorMapper`.
    - Cobertura de rutas felices (`Right`), errores de *payload* (`Left`) y excepciones de servicio.
    - Verificación del stream `authStateChanges` (`Right` con usuario/`null`, `Left` en error).
  - Suite completa para `RepositoryAuthImpl`:
    - *Stubs* `_StubGateway`, `_FakeErrorMapper`.
    - Cobertura de *happy paths*, errores del gateway, excepciones y stream `authStateChanges`.
    - Se expone `ackToVoid` (antes `_ackToVoid`) para mejorar testabilidad.

### Changed

- **Auth – Contratos y documentación (revisión de flujo):**
  - `GatewayAuth` documentado como **frontera segura de dominio** para operaciones de autenticación:
    - Contratos de comportamiento, manejo de errores e I/O (solo primitivos/JSON).
    - *DartDoc* por método con precondiciones y `Either` esperado, más ejemplo mínimo con *fake*.
  - `GatewayAuthImpl` alinea documentación: mapeo de errores y lógica del stream.
  - `authStateChanges` ahora documentado/emite `Either<ErrorItem, Map<String, dynamic>?>`.
- **Session – Constructor simplificado:**
  - `BlocSession` elimina el parámetro explícito `WatchAuthStateChangesUsecase`; ahora se obtiene
    vía la *fachada* `SessionUsecases`. Menos parámetros, inicialización y pruebas más claras.

### Fixed

- **Session:** corrección del **deep copy** en *session refresh* y en el **current user**, evitando
  compartir referencias internas de manera no intencional.

### Docs

- **RepositoryAuth / RepositoryAuthImpl:**
  - *DartDoc* ampliado: contratos de comportamiento, políticas de manejo de errores y semántica de
    métodos; ejemplo mínimo de uso.
- **GatewayAuth / GatewayAuthImpl:**
  - *DartDoc* exhaustivo alineado con los nuevos contratos, detalle de mapeo de errores y manejo de
    streams.

### Tests

- **GatewayAuthImpl / RepositoryAuthImpl:** mayor cobertura de ramas y *edge cases* (bloques
  `try-catch`, *acknowledgement*).
- **BlocSession:** `bloc_session_from_repository_test.dart`:
  - Transiciones de estado vía stream del repositorio (`boot`).
  - Flujos de autenticación (`logIn`, `logOut`).
  - Políticas post-dispose (`returnLastSnapshot`, `returnSessionError`).

### Migration notes

- **`BlocSession` (posible cambio rompiente):**
  - Si usabas el **constructor** con `WatchAuthStateChangesUsecase` como parámetro, migra a:
    - Constructor simplificado (sin ese parámetro), o
    - `BlocSession.fromRepository(repo)` como opción recomendada.
- **Streams de auth:**
  - Asegura que tu capa superior consuma `Either<ErrorItem, Map<String, dynamic>?>` en
    `authStateChanges`.
- **Ejemplos:**
  - Consulta `bloc_session_example.dart` y `ledger_example.dart` para patrones de integración de UI
    sin dependencias externas.

> **Notas:** El objetivo de esta versión es consolidar el **auth flow** con contratos claros,
> mejorar la testabilidad y ofrecer ejemplos prácticos de **ledger** y **sesión** listos para copiar
> en proyectos reales.

## [1.29.0] - 2025-09-24

### Added

- **Graph models (2D):** `ModelGraph`, `ModelPoint` y `ModelGraphAxisSpec` para representar datos
  tabulares o de series temporales.
- **ModelGraph – helpers y demos:**
  - `defaultModelGraph()` con 3 puntos por defecto y rangos de ejes automáticos.
  - `demoPizzaPrices2024Graph()` (precios mensuales de pizza en COP para 2024).
  - Constantes: `defaultModelPoint`, `defaultModelPoints`, `defaultXAxisSpec`, `defaultYAxisSpec`.
- **Example app:** `graph_example.dart` (`PizzaPricesApp`) con:
  - `BlocGeneral<ModelGraph>`, gráfico de línea y tabla de precios.
  - Inyección periódica de datos simulados cada 5 s.
  - Render propio sin dependencias vía `_SimpleLineChartPainter`.
  - Componentes `_Header`, `_GraphCard`, `_TableCard`.
- **Utils:**
  - `Utils.listEquals` (comparación superficial sensible al orden).
  - `Utils.listHash` (hash sensible al orden).

### Changed

- **JSON/robustez:**
  - `ModelGraph.fromJson`: parseo laxo de títulos (convierte dinámicos a `String`, vacíos → `''`).
  - `ModelPoint.fromJson`: maneja vectores nulos/no-map sin lanzar (devuelve vector inválido
    controlado).
- **Inmutabilidad:**
  - `ModelGraph.points` ahora es **inmodificable** tras construcción y en `copyWith`.
- **Nombres y organización (consistencia):**
  - Renombrados: `GraphAxisSpec` → `ModelGraphAxisSpec`.
  - Renombrados: `GraphAxisSpecEnum` → `ModelGraphAxisSpecEnum`.
  - Reubicados enums: `ModelGraphAxisSpecEnum` en `model_graph.dart`; `ModelPointEnum` en
    `model_point.dart`.
- **Cálculo numérico:**
  - `ModelVector.equalsApprox` usa tolerancia combinada absoluta/relativa con *ULP slack* para
    comparaciones de punto flotante más estables.

### Docs

- DartDoc ampliado y aclarado para:
  - `ModelGraph`, `ModelPoint`, `ModelGraphAxisSpec`: construcción, contratos, manejo de JSON y
    ejemplos de uso.
  - Utilidades JSON (`mapFromDynamic`, `listFromDynamic`, `convertJsonToList`, `getJsonEncode`) con
    ejemplos.

### Tests

- **ModelGraph:**
  - Parseo laxo de `fromJson`, inmutabilidad de `points`, igualdad por valor (`==`, `hashCode`),
    `copyWith` inmutable, `fromTable` (rango de ejes y mapeo X), *round-trip* JSON (incluye títulos
    `null`/vacíos).
- **ModelGraphAxisSpec (antes `GraphAxisSpec`):**
  - Des/serialización JSON (válidos y con ruido), `copyWith`, igualdad y `hashCode`, comportamiento
    con rangos min/max invertidos (sin validación automática).
- **ModelPoint:**
  - *Round-trip* JSON, igualdad y `copyWith`; robustez ante vectores nulos/no-map.
- **Utils:**
  - Cobertura para `listEquals` y `listHash`.

> **Notas:** No hay cambios en APIs existentes.

## [1.28.0] - 2025-09-24

### Added

- **FinancialMovementModel – Tests:** casos para normalización de montos, *round-trip* JSON y
  diferencias por `mathPrecision`.
- **Utils.listFromDynamic – Tests:** validación con entradas mixtas (ruido, llaves extra, `null`) y
  verificación de compatibilidad con `LedgerModel.fromJson`.
- **LedgerModel – Tests:** cobertura para JSON en formas válidas variadas, inmutabilidad, balance
  entero/decimal, igualdad/hash y sensibilidad al orden.

### Changed

- **FinancialMovementModel:**
  - **Política de no-negativos:** `fromDecimal`, `fromJson` y `copyWith` normalizan montos con
    `abs()`. El signo **no** codifica ingreso/egreso (lo define `category`).
  - **`mathPrecision`:** ahora se **lee/escribe** en JSON y forma parte de `==`/`hashCode`.
  - **`fromJson`:** usa `containsKey` para distinguir entre valor provisto y `defaultMathPrecision`.
- **LedgerModel (inmutabilidad):**
  - `fromJson` y `copyWith` envuelven listas con `List.unmodifiable`.
  - Se documenta que el **ctor principal** espera listas ya inmutables.
- **Igualdad/orden (`LedgerModel`):** se mantiene igualdad profunda **sensible al orden** y
  `hashCode` consistente con ese contrato.

### Fixed

- **LedgerModel:** corrección crítica en `_listHash` para usar `e.hashCode` (eliminado
  `e?.hashCode`) evitando discrepancias de hash.

### Docs

- **FinancialMovementModel:** contrato aclarado (entero escalado, uso recomendado de `fromDecimal`,
  límites de precisión) y ejemplo mínimo.
- **LedgerModel:** contrato de inmutabilidad, ejemplo mínimo y nota sobre costo de `toString()`.

> **Notas:**
> - El modelo financiero ahora **siempre** almacena montos no negativos; si tu lógica dependía del
    signo para distinguir ingreso/egreso, usa el campo `category`.
> - Al incorporarse `mathPrecision` a `==`/`hashCode`, comparaciones y *sets/maps* podrían cambiar
    si mezclas precisiones distintas para el mismo valor numérico.

## [1.27.0] - 2025-09-13

### Added

- **BlocOnboarding:** `AutoAdvancePolicy` para controlar con mayor granularidad cuándo el flujo
  avanza automáticamente al siguiente paso.

### Changed

- **BlocOnboarding – Navegación y contratos:**
  - `back()` evita el auto-avance incluso si el paso define `autoAdvanceAfter`, mejorando la
    previsibilidad de la UX; se ejecuta el `onEnter` del paso previo.
  - Se refinó el contrato de `onEnter`: no debe lanzar; devolver `Left(ErrorItem)` para permanecer
    en el paso; debe ser rápido (el trabajo pesado va a *use cases*); `null` implica éxito
    inmediato.
  - `autoAdvanceAfter` solo aplica tras un `onEnter` exitoso.

- **ErrorItem:**
  - Serialización/deserialización más robusta: niveles desconocidos hacen *fallback* a
    `ErrorLevelEnum.systemInfo`.
  - `copyWith(meta:)` retorna un mapa **inmodificable** para prevenir mutaciones accidentales.

### Docs

- DartDoc ampliado para `OnboardingStep`, `OnEnterResult`, `ErrorItem`, `ErrorLevelEnum` y
  `ErrorItemEnum`, incluyendo ejemplos de uso y pautas de UI.

### Tests

- **Onboarding:** suite completa que cubre configuración/arranque (pasos vacíos/no vacíos),
  `onEnter` (éxito, `Left(ErrorItem)`, excepción), `retryOnEnter`, `clearError`, `next/back` con
  cancelación de temporizadores, `currentStep` en múltiples estados, guardas de *race conditions*
  vía *epoch*, y preservación de errores en estados terminales (`skip`, `complete`).
- **Theme/Repository:** casos adicionales para robustez del *gateway* y verificación de
  normalización HEX en JSON (sin cambios de API).
- **ErrorItem:** *round-trip* JSON, *fallback* de niveles desconocidos, e inmutabilidad de `meta` en
  `copyWith`.

> **Notas:** No hay cambios incompatibles.
> - Si tus pruebas asumían auto-avance al usar `back()`, actualízalas al nuevo comportamiento.
> - Si tu código modificaba el mapa devuelto por `copyWith(meta: ...)`, clónalo antes de mutarlo.

## [1.26.2] - 2025-09-13

### Added

- **BlocOnboarding:** se introduce `AutoAdvancePolicy` para controlar con mayor granularidad cuándo
  el flujo avanza automáticamente al siguiente paso.

### Changed

- **ErrorItem:**
  - Serialización/deserialización más robusta: niveles de error desconocidos ahora hacen *fallback*
    a `ErrorLevelEnum.systemInfo`.
  - `copyWith(meta:)` devuelve un mapa **inmodificable** para evitar mutaciones accidentales.

### Docs

- DartDoc ampliado para `ErrorItem`, `ErrorLevelEnum` y `ErrorItemEnum`, con ejemplos de uso y
  pautas para UI.

### Tests

- Cobertura añadida para:
  - *Fallback* de niveles desconocidos en `errorLevel`.
  - *Round-trip* JSON de `ErrorItem`.
  - Inmutabilidad de `meta` en `copyWith`.
  - Casos básicos de `AutoAdvancePolicy` en `BlocOnboarding`.

> **Notas:** No hay cambios incompatibles. Si tu código mutaba el mapa retornado por
`copyWith(meta: ...)`, clónalo explícitamente antes de modificarlo. `AutoAdvancePolicy` mantiene el
> comportamiento por defecto previo salvo que definas una política específica.

## [1.26.1] - 2025-09-13

### Added

- **BlocOnboarding – Tests completos**:
  - Configuración y arranque (pasos vacíos / no vacíos).
  - Comportamiento de `onEnter`: éxito, error (`Left(ErrorItem)`) y excepciones.
  - `retryOnEnter` y `clearError`.
  - Navegación `next` y `back` con cancelación de temporizadores y transiciones de estado.
  - Verificación de `currentStep` en múltiples estados.
  - Guardas contra *race conditions* mediante el mecanismo de *epoch*.
  - Estados terminales (`skip`, `complete`) preservando errores.
  - Efectos de `dispose()` sobre temporizadores.

### Changed

- **BlocOnboarding – Navegación hacia atrás**:
  - `back()` ahora evita el auto-avance incluso si el paso tiene `autoAdvanceAfter`, ofreciendo una
    UX más predecible.
  - Se mantiene la ejecución de `onEnter` del paso previo.
- **OnboardingStep – Contratos y documentación**:
  - `onEnter` **no debe lanzar**; devolver `Left(ErrorItem)` para permanecer en el paso.
  - Debe ser rápido; trabajo pesado va a *use cases*.
  - `null` implica éxito inmediato.
  - `autoAdvanceAfter` solo aplica tras un `onEnter` exitoso.
  - Se refinó la documentación de `title`, `description`, `autoAdvanceAfter`, `onEnter` y del
    *typedef* `OnEnterResult`.

### Tests

- **Onboarding**: suite ampliada (ver “Added”).
- **Theme**: cobertura extendida y robustez del *gateway* (sin cambios de API).

### Docs

- Ejemplo adicional que cubre distintas configuraciones de `OnboardingStep` y resultados de
  `onEnter`.
- Aclaraciones de contrato en DartDoc para `OnboardingStep` y `OnEnterResult`.

> **Notas:** No hay cambios incompatibles. El cambio en `back()` mejora la previsibilidad del flujo;
> si tus pruebas asumían auto-avance al retroceder, actualízalas para reflejar el nuevo
> comportamiento.

## [1.26.0] - 2025-09-07

### Added

- **Pruebas robustas para `Utils`**  
  Cobertura extendida en `getDouble` y `getIntegerFromDynamic`:
  - Manejo de nulos, `NaN`, infinitos y valores no numéricos.
  - Parsing de números en notación científica (`3e2`, `-3e-2`, etc.).
  - Soporte para formatos internacionales (coma o punto como separador decimal, moneda, separadores
    de miles).
  - Garantía de fallback seguro (`0` para enteros, `NaN` o `defaultValue` para dobles).
  - Se incluyen los cambios tipo fix detallados en el changelog desde la version 1.25.0.

## [1.25.3] - 2025-09-07
### Added
- `ModelVector.fromXY(int x, int y)` factory constructor for convenient creation from integer coordinates.
- Integer-oriented getters `x` and `y` (using `.round()`, policy: .5 away from zero).
- `key` property providing a canonical `"x,y"` representation for map/set usage.
- `copyWithInts({int? x, int? y})` method to create safe copies overriding integer axes.

### Docs
- Extended DartDoc with examples for new methods and clarified rounding policy.
- Documented reversibility limitations when the original `dx`/`dy` are non-integers.

### Tests
- Added unit tests to validate:
  - Rounding policy for positive/negative decimals.
  - Stability of `key` and reversibility via `fromXY`.
  - `copyWithInts` behavior with partial overrides.
  - Factory `fromXY` producing expected doubles.

## [1.25.2] - 2025-09-07

### Added
- Nueva **GitHub Action ligera** para validar commits antes de merge:
  - Verificación de que **todos los commits estén firmados y verificados**.
  - Ejecución de **`flutter analyze`** para asegurar el cumplimiento de linters.
  - Validación de **`dart format`** en modo estricto.
  - Bloqueo de `dependency_overrides` en `pubspec.yaml`.

### Changed
- Ajustes en reglas de protección de ramas:
  - `develop` y `master` ahora requieren commits firmados, revisiones por PR y checks de estado obligatorios (incluyendo CodeQL).
  - Publicación automática a pub.dev únicamente desde `master` tras un merge exitoso.

### Security
- Integración con **CodeQL** en ramas `develop` y `master` para análisis de calidad y seguridad.
- Configuración de **bot con firmas SSH** para asegurar que los commits generados por automatizaciones tengan estado *Verified*.

## [1.25.1] - 2025-09-07

## Added

* **Documentación exhaustiva de estados de sesión**

  * `SessionState`, `Unauthenticated`, `Authenticating`, `Authenticated`, `Refreshing`, `SessionError` ahora tienen DartDoc claro sobre propósito, transiciones y expectativas de UI.
* **Getter `state` en `BlocSession`**

  * Exposición fiel del último `SessionState` publicado (útil para UI que necesita distinguir `Authenticating`, `Refreshing` o `SessionError`).
* **Páginas demo ampliadas en el example**

  * `SessionDemoPage` (flujo completo de sesión con `Either`).
  * `WsDatabaseUserDemoPage` (CRUD + watch en tiempo real con motor de cambios).
  * `ConnectivityDemoPage` (flujo puro de conectividad con `Either`).
  * `BlocLoadingDemoPage` (acción única con anti-flicker y cola FIFO).
  * `BlocResponsiveDemoPage` (grid responsivo, simulación de tamaño, métricas).
  * `BlocOnboardingDemoPage` (pasos con `onEnter` que retorna `Either`, auto-avance y manejo de errores).

## Changed

* **`BlocSession.stateOrDefault`**

  * Mantiene retrocompatibilidad simplificando a binario “autenticado / no autenticado”.
  * Si el estado es `Authenticated`, **devuelve la misma instancia** (sin reasignar).
  * Para cualquier otro estado, devuelve `const Unauthenticated()`.
* **Getters validados**

  * `stream`, `sessionStream`, `state`, `stateOrDefault`, `currentUser`, `isAuthenticated` verifican ciclo de vida.
  * Tras `dispose()`, el acceso lanza `StateError` con mensaje claro (contrato más seguro).
* **Alias canónico**

  * `stream` es el alias recomendado; `sessionStream` se mantiene para compatibilidad.

## Fixed

* **`refreshSession()` en fallo**

  * Si el repo retorna `Left`, el BLoC pasa a `SessionError` y **no permanece** en `Refreshing`.
* **Idempotencia de `boot()`**

  * Múltiples llamadas re-adjuntan la suscripción sin pérdidas de eventos.
* **`cancelAuthSubscription()`**

  * Al cancelar manualmente, el stream deja de reflejar cambios hasta volver a llamar a `boot()` (documentado y cubierto en tests).

## Tests

* **Suite de dispose y getters**

  * Acceso a getters tras `dispose()` → `StateError` esperado.
  * `stream`/`sessionStream` no emiten tras `dispose()`.
  * `stateOrDefault` es un **snapshot** y no provoca emisiones.
* **Cobertura de secuencias clave**

  * `refreshSession()` con `Left` → `SessionError`.
  * `boot()` idempotente y `cancelAuthSubscription()` en medio de sesión.
  * Debouncer en `logIn()` (múltiples llamadas rápidas → 1 hit a repo).

## Migration notes

* **Acceso tras `dispose()`**
  * Evita leer `bloc.state`, `bloc.currentUser`, `bloc.isAuthenticated` o `bloc.stream` después de disponer.
  * Si existe código heredado que pudiera acceder tras `dispose()`, rodéalo con `mounted` (en UI) o reordena el ciclo de vida.
  * Opción de compatibilidad temporal:
    ```dart
    SessionState safeState(BlocSession b) {
      try { return b.state; } catch (_) { return const Unauthenticated(); }
    }
    ```
* **Snapshots**

  * Para lógicas binarias, usa `stateOrDefault`.
  * Para lógicas de progreso/errores, usa `state`.

## Dev notes

* Si necesitas soportar versiones de Flutter sin `Color.withValues`, cambia a:

  ```dart
  void main(){
  color.withOpacity(0.75); // en lugar de withValues(alpha: 0.75)
  }
  ```

— Fin de 1.25.1 —


## [1.25.0] - 2025-08-17

### Fixed
- `BlocLoading`: evita `StateError` al invocar `hide()` tras `dispose()` y corrige emisiones duplicadas en operaciones rápidas encadenadas.
- `BlocResponsive`: corrige la clasificación inicial de `ScreenSize` en el primer frame y en cambios de tamaño (web/desktop), garantizando una emisión consistente.
- `BlocOnboarding`: maneja correctamente listas vacías de pasos (`[]`) y asegura que `onComplete` se dispare **una sola vez**. Cierre seguro de streams en `dispose()`.
- Demos: rutas e imports ajustados para compilar en `stable` sin advertencias; correcciones menores de tipografía y estilos.

### Changed
- Mejora no funcional del rendimiento en `BlocLoading` al consolidar colas internas para mostrar/ocultar estados de carga (sin cambios de API).
- Ajustes menores a los breakpoints documentados de `BlocResponsive` para reflejar con mayor claridad los límites recomendados (sin cambios de API).

### Docs
- DartDoc en **inglés** para `BlocLoading`, `BlocResponsive` y `BlocOnboarding`, incluyendo ejemplos de uso en Markdown y descripción de parámetros/enums.
- Comentarios explicativos añadidos en cada **demo page** para guiar la implementación paso a paso.
- Sección breve en el README principal enlazando a las demos y a la guía de adopción rápida de cada BLoC.

### Tests
- Grupos de pruebas con `flutter_test` por BLoC; casos agregados para:
  - Inicialización y `dispose()`.
  - Cambios de tamaño en `BlocResponsive`.
  - Flujos felices y escenarios borde en `BlocOnboarding`.
  - Condiciones de carrera en `BlocLoading`.

### CI
- Endurecimiento de validaciones de PR (análisis, formato y cobertura) y verificación de actualización del `CHANGELOG.md`.
- Mantención: workflows revisados para compatibilidad con `stable` actual.

> **Notas:** No hay cambios incompatibles. No se requiere migración.


## [1.24.2] - 2025-08-17

### Added
- Actualización menor en `BlocLoading` para soportar FiFo en la cola de tareas.
- Se agrega demo para `BlocLoading` en `bloc_loading_demo_page.dart`.
- Se agrega `BlocOnboarding` para gestionar estados de onboarding en aplicaciones.
- Se agrega `BlocResponsive` para manejar estados de UI responsiva en aplicaciones con diferentes resoluciones y pantallas.

## [1.24.1] - 2025-08-17

### Fixed
- Corrección de advertencias menores en la implementación de conectividad y manejo de streams.
- Ajustes en la documentación de los nuevos módulos y ejemplos agregados.
- Mejoras menores en la robustez de los tests unitarios para los servicios de conectividad y WebSocket.
- Actualización de dependencias para mantener la compatibilidad con las últimas versiones de Flutter y Dart.

## [1.24.0] - 2025-08-15

#### ✅ Added
- **Stack WS Database (end-to-end)**
  - `GatewayWsDatabaseImpl` (ref-count por `docId`, multiplexing con `BlocGeneral`, `detachWatch`/`releaseDoc`/`dispose`).
  - `RepositoryWsDatabaseImpl<T extends Model>` (mapeo `fromJson/toJson`, opcional serialización de `write/delete` por `docId`).
  - **Usecases CRUD & WS**:
    - `databases_crud_usecases.dart`
    - `facade_crud_database.dart`
    - `facade_ws_database_usecases.dart`
  - **Estado y config**:
    - `ws_db_state.dart` (estado inmutable `WsDbState<T>`)
    - `ws_db_config.dart` (valores por defecto / helpers)
  - **BLoC**:
    - `bloc_ws_database.dart` (orquestación thin; sin streams ad-hoc; mira/actualiza `WsDbState`)
- **Infra fake para desarrollo/pruebas**
  - `fake_service_ws_database.dart` con `documentStream`/`collectionStream`, lectura/escritura y borrado por colección+id.
  - `ws_database_user_demo_page.dart` (example) con ticker opcional que incrementa `jwt.countRef` en vivo.
  - `home_page.dart` (example) como entrada de demo.
- **Utilidades transversales**
  - `Unit` (tipo “valor nulo” seguro para `Either` y comandos sin payload).
  - `PerKeyFifoExecutor<K>` (ejecutor FIFO por clave para serializar tareas por `docId`).
- **Tests**
  - `bloc_ws_database_test.dart`
  - `gateway_ws_database_impl.test.dart`
  - `repository_ws_database_impl.test.dart`
  - `fake_service_ws_database.test.dart`
  - `per_key_fifo_executor_test.dart`
  - `unit_test.dart`
  - `fake_db_repo.dart` (mocks & fakes auxiliares)

#### 🔄 Changed
- Contratos de gateway/repositorio **document-centricos** y transport-agnostic:
  - `GatewayWsDatabase`: énfasis en *watch por documento* con canal compartido y manejo explícito de ciclo de vida (`detachWatch`/`releaseDoc`).
  - `RepositoryWsDatabase<T>`: agrega helpers de ciclo de vida y opción de **serializar escrituras por `docId`**.
- Mapeo de errores unificado mediante `DefaultErrorMapper` en todas las capas.

#### 🩹 Fixed
- Posibles **leaks** de suscripción cuando varios watchers observaban el mismo `docId`: ahora se hace **ref-count** y se libera la suscripción real al llegar a cero referencias.

#### 🧭 Migration notes
- Si usas `watch(docId)`, **después de cancelar tu `StreamSubscription` llama siempre a `detachWatch(docId)`** para liberar el canal subyacente.
- Para comandos sin retorno, retorna `Right(unit)` en lugar de `void`.
- Para evitar carreras al escribir/borrar la misma entidad, usa el `RepositoryWsDatabaseImpl` con `serializeWrites: true` o el utilitario `PerKeyFifoExecutor`.

#### 📚 Docs
- README actualizado con:
  - **“Cómo integrar BlocWsDatabase (con FakeServiceWsDatabase)”**
  - Snippets dedicados de **`Unit`** y **`PerKeyFifoExecutor`** (casos de uso comunes).

## [1.23.1] - 2025-08-11

### Fixed
- Correcciones menores y ajustes en la implementación de `GatewayAuth` y `RepositoryAuth` para mejorar la compatibilidad y robustez.
- Documentación actualizada y ampliada en los nuevos archivos y clases agregadas.
- Se resolvieron advertencias y errores menores detectados en pruebas unitarias y análisis estático.

## [1.23.0] - 2025-08-11
Actualización cambios de master

## [1.22.0] - 2025-08-10
- Agregamos la clase BlocResponsive, BlocOnboarding y BlocLoading para mejorar la gestión de estados en aplicaciones con diferentes resoluciones y pantallas.

## [1.21.2] - 2025-07-22
- Corregido error de formateo en changelog al agregar la versión `1.21.1` (error de formato en el encabezado de la versión).

## [1.21.1] - 2025-07-22
- Revisados y resueltos los `TODO` pendientes en el código.
- Sincronizada la rama `develop` con `master`.
- Corregido el error de análisis estático (“Angle brackets will be interpreted as HTML”) en el comentario de `fake_service_preferences.dart` (ajuste de espacios en `Map<String, dynamic>`).

## [1.21.0] - 2025-07-09
- Se crea la clase `FakeServiceHttp` para simular el comportamiento de un servicio HTTP en pruebas unitarias.
- Se actualiza el readme para incluir ejemplos de uso de las clases `FakeServiceHttp`, `FakeServiceSesion`, `FakeServiceWsDatabase`, `FakeServiceGeolocation`, `FakeServiceGyroscope`, `FakeServiceNotifications`, `FakeServiceConnectivity` y `FakeServicePreferences`.

## [1.20.2] - 2025-07-08
- Se crea la clase `FakeServiceSesion` para simular el comportamiento de un servicio de sesión en pruebas unitarias.
- Se crea la clase `FakeServiceWsDatabase` para simular el comportamiento de un servicio de base de datos WebSocket en pruebas unitarias.
- Se crea la clase `FakeServiceGeolocation` para simular el comportamiento de un servicio de geolocalización en pruebas unitarias.
- Se crea la clase `FakeServiceGyroscope` para simular el comportamiento de un servicio de giroscopio en pruebas unitarias.
- Se crea la clase `FakeServiceNotifications` para simular el comportamiento de un servicio de notificaciones en pruebas unitarias.
- Se crea la clase `FakeServiceConnectivity` para simular el comportamiento de un servicio de conectividad en pruebas unitarias.
- Se crea la clase `FakeServicePreferences` para simular el comportamiento de un servicio de preferencias en pruebas unitarias.


## [1.20.1] - 2025-07-07

### Fixed
- Se documenta y agrega el archivo `README_STRUCTURE.md` con la guía recomendada de estructura de carpetas y arquitectura para proyectos basados en `jocaagura_domain`.

## [1.20.0] - 2025-07-06

### Changed
- Documentación ampliada y mejorada para las clases `BlocGeneral` y `BlocModule`, incluyendo ejemplos de uso detallados en DartDoc y explicaciones sobre la gestión de listeners y el ciclo de vida de los BLoC.

## [1.19.0] - 2025-05-25

### Added
- Nueva clase `LedgerModel` que representa un libro contable con ingresos y egresos separados, y permite el cálculo de saldo total y decimal.
- Enum `LedgerEnum` para mantener uniformidad en las claves JSON utilizadas por `LedgerModel`.
- Funcionalidades en `MoneyUtils` para:
  - `totalAmount`, `totalDecimalAmount`
  - `average`, `filterByCategory`
  - `totalPerCategory`, `totalDecimalPerCategory`
- Métodos adicionales útiles como:
  - `getLatestMovement`, `containsMovement`
  - `sortByDate`, `filterByDateRange`
  - `totalByMonth`, `totalDecimalByMonth`

### Added (Tests)
- Pruebas unitarias para `LedgerModel`: serialización, igualdad, cálculo de saldos y `copyWith`.
- Pruebas unitarias para `MoneyUtils`: validaciones de agregación, filtros y agrupaciones por categoría y mes.

### Changed
- Documentación enriquecida con ejemplos de uso en DartDoc para `MoneyUtils`.


## [1.18.1] - 2025-05-18
chore(github): reestructura develop desde master y actualiza workflows


## [1.18.0] - 2025-05-18

### Added
- Nueva estructura estándar de errores:
  - `HttpErrorItems`: Manejo de errores HTTP comunes como 404, 401, 500, con niveles de severidad (`danger`, `severe`, `warning`, `systemInfo`).
  - `WebSocketErrorItems`: Representación de errores típicos de WebSocket como fallos de conexión, cierre inesperado o mensajes malformados.
  - `NetworkErrorItems`: Para errores como sin conexión, timeout o servidor inaccesible.
- Inclusión de métodos estáticos `fromCode()` y `fromStatusCode()` en las clases anteriores.
- Clave estandarizada `meta['source']` y validadores para `meta['httpCode']` y similares.

### Updated
- `ErrorItem` ahora soporta un campo `errorLevel` de tipo `ErrorLevelEnum`.
  - El valor por defecto es `ErrorLevelEnum.systemInfo` para obligar a definirlo explícitamente.
  - Se agregó `toString()` actualizado para incluir el `errorLevel`.
- Documentación de cada clase de error fue ampliada con enlaces a los estándares utilizados (MDN, Flutter API).

### Tests
- Se agregaron pruebas unitarias para `HttpErrorItems`, `WebSocketErrorItems`, y `NetworkErrorItems` incluyendo validación de `errorLevel`, `fromCode()` y fallback `unknown()`.
- Se probaron los casos límite y el mapeo correcto desde códigos conocidos.

### Docs
- Actualizado el `README.md` para reflejar las nuevas capacidades de los modelos de error y sus usos sugeridos.


## [1.17.1] - 2025-05-18

### Updated
- Enhanced the financial movement model to support up to 4 decimal places for mathematical precision and to prevent negative amounts at the model level.

### Fixed
- Minor patches in `analysis_options.yaml` to remove dependencies no longer used in the updated implementation.


## [1.17.0] - 2025-03-25

### Added
- Implemented the financial movement model to manage financial transactions.

## [1.16.0] - 2025-01-25

### Added
- Configured GitHub Actions secrets to securely store sensitive data required for workflows.
- Validated and updated the GitHub maintainers group to ensure proper repository access and management.

### Updated
- Enhanced the `README` file with updated repository details and instructions for contributors.

## [1.15.2] - 2024-12-29

### Fixed

- Translation of the changelog to English.
- Completion and translation of inline documentation to English.
- Extended unit tests.
- Updated linter package.

## [1.15.1] - 2024-08-25

### Fixed

- Minor changes in DartDoc formatting without affecting the code or its functionality.

## [1.15.0] - 2024-08-25

### Added

- `MedicalRecordModel`: Added model, tests, and DartDoc documentation for the patient's state in the dentist app.

## [1.14.0] - 2024-08-25

### Added

- `MedicationModel`: Added model, tests, and DartDoc documentation for the appointment model.

## [1.13.0] - 2024-08-25

### Added

- `AppointmentModel`: Added model, tests, and DartDoc documentation for the appointment model.
- `ContactModel`: Added model, tests, and DartDoc documentation for the contact model.

## [1.12.1] - 2024-08-07

### Changed

- `AnimalModel`: Added DartDoc documentation for the model.

## [1.12.0] - 2024-08-07

### Added

- `AnimalModel`: Added the model to start work on the animal class.

## [1.11.0] - 2024-08-04

### Added

- `AcceptanceModel`: Added model for legally accepting medical treatment.

## [1.10.0] - 2024-08-04

### Added

- `TreatmentPlanModel`: Added treatment plan for the patient.

## [1.9.0] - 2024-07-28

### Added

- `MedicalTreatmentModel`: Added model to manage treatments for patients.

### Changed

- Minor formatting fixes for `dental_condition_model`, `dental_condition_model_test`, and `medical_diagnosis_model`.

## [1.8.0] - 2024-07-24

### Added

- `DentalConditionModel`: Added model and documentation for the dental condition.

## [1.7.1] - 2024-07-22

### Changed

- `MedicalDiagnosisModel`: Added documentation for developers in the file.

## [1.7.0] - 2024-07-22

### Added

- `MedicalDiagnosisModel`: Added model to ensure diagnostics.

## [1.6.1] - 2024-07-21

### Changed

- `medical_diagnosis_tab_model_test`: Increased test coverage.

## [1.6.0] - 2024-07-21

### Changed

- `signature_model`: Updated to include hashCode.

### Added

- `MedicalDiagnosisTabModel`: Added model for medical diagnosis collection and its unit tests.

## [1.5.0] - 2024-07-07

### Changed

- Upgraded `flutter_lints` to version 4.0.0 in dev dependencies.

### Added

- `SignatureModel`: Added model for user signature with its unit tests.

## [1.4.2] - 2024-06-30

### Added

- `Colors`: Added a color map to the UML diagram with an explanation in the README to improve visualization of the implementation state of models.

### Fixed

- `UML Diagram`: Updated to reflect the implementation state of models:
  - `Either`, `Left`, `Right`: Confirmed.
  - `Model`, `UserModel`, `AttributeModel<T>`: Confirmed.
  - `Bloc`, `BlocModule`, `BlocGeneral<T>`, `BlocCore`: Confirmed.
  - `UI`: `ModelMainMenuModel` confirmed.
  - `Connectivity`: `ConnectionTypeEnum`, `ConnectivityModel` confirmed.
  - `Citizen`: `PersonModel` under review, `LegalIdModel` confirmed.
  - `Obituary`: `ObituaryModel`, `DeathRecordModel` confirmed.
  - `Shops`: `StoreModel` confirmed.
  - `Geolocation`: `AddressModel` confirmed.

## [1.4.1] - 2024-06-30

### Fixed

- `version`: Corrected to initialize work with new models.

## [1.4.0] - 2024-06-30

### Added

- `uml_diagrams`: Added diagrams with more models for future work.

## [1.3.1] - 2024-05-25

### Fixed

- Typing consistency adjustments in the `Either` class.

## [1.3.0] - 2024-05-10

### Added

- `ConnectivityModel` class and corresponding documentation.

## [1.2.1]

- Added `Debouncer` class.
- Added documentation in the README file.

## [1.0.0]

- Added `Either` class.
- Approved for production.

## [0.3.2]

- Added `DeathRecordModel` into `ObituaryModel`.

## [0.3.1]

- Fixed `fromJson` factory constructor in `LegalIdModel`.

## [0.3.0]

- Added `LegalIdModel`.

## [0.2.0]

- Added `DeathRecordModel`.

## [0.1.2]

- Minor fix to `ObituaryModel` to include `vigilDate` and `burialDate` in parameters.
- Increased unit test coverage.

## [0.1.01]

- Changed officially to beta.
- Minor fix to `ObituaryModel` to include `message` in parameters.

## [0.0.9]

- Added `ObituaryModel`.
- Minor fix to `PersonModel` to cover variable names properly.
- Increased `PersonModel` and `DateUtils` test coverage.

## [0.0.8]

- Added DateTime-to-String utility.

## [0.0.71]

- Changed attributes in Models to `Map<String, AttributeModel<dynamic>>`.

## [0.0.7]

- Completed `PersonModel` with subModelClass (`AttributeModel`) for information.

## [0.0.6]

- Completed `StoreModel` with formatted options.

## [0.0.5]

- Added `StoreModel`.

## [0.0.4]

- Added `AddressModel`.

## [0.0.3]

- Added `Utils` class for JSON conversion management.
- Improved unit test coverage.

## [0.0.2]

- Added `UserModel` and established some immutable conditions.

## [0.0.1]

- Added initial abstract class `Model`.
