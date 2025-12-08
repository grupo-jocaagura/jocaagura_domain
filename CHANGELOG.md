# CHANGELOG Jocaagura Domain

This document follows the guidelines of [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.34.0] - 2025-12-08

> **Release acumulada.** Consolida los cambios de **1.33.1** → **1.33.3** sin adiciones extra.  
> Enfoque: estabilización de contratos, helpers de pruebas HTTP y consistencia en serialización.

### Added
- **HTTP – Testing helpers**
    - Helper estandarizado para **respuestas enlatadas (canned)** en flujos `GET/POST/PUT/DELETE`.
    - **Escenarios simulados**: `Timeout`, `Offline`, `Unexpected error`, `Bad JSON`.

### Changed
- **HTTP – Simulación y normalización**
    - Refactor para unificar el esquema de respuestas enlatadas y simplificar el **cableado de pruebas**.
    - **Normalización** de `raw response` (status/headers/body) antes del mapeo de éxito/error.

### Fixed
- **Domain – ModelAppVersion**
    - `buildAt` ahora se **persiste como cadena ISO-8601 UTC** (centinela `kDefaultBuildAtIso`) y expone `buildAtDateTime` como *getter*. Esto permite **instancias `const`** y evita *drift* entre plataformas.
- **Bloc – BlocHttpRequest**
    - Estabilizado el contrato para garantizar la **herencia correcta de `BlocModule`**.

### Docs
- Comentarios y notas aclarando:
    - El flujo `buildAt` (**string ISO + getter**).
    - Uso de helpers en pruebas HTTP y normalización previa al *mapper*.

### Tests
- Suites ampliadas para cubrir:
    - Escenarios HTTP simulados (timeout/offline/unexpected/bad-JSON).
    - Verificación de **normalización** previa al mapeo.
    - Casos de `ModelAppVersion` (ISO string + getter `buildAtDateTime`).

### Migration notes
- **HTTP tests**: reemplaza *fixtures* ad-hoc por el **helper de respuestas enlatadas**; ajusta aserciones si dependían del formato previo (especialmente en `headers`/`body` normalizados).
- **ModelAppVersion**: si consumías `buildAt` como `DateTime` directo, usa el **string ISO** almacenado o el *getter* `buildAtDateTime` para conversión.
- **BlocHttpRequest**: sin cambios de API pública; la corrección asegura tipado y ciclo de vida coherentes con `BlocModule`.



## [1.33.3] - 2025-12-08

### Added
- **HTTP testing helpers**
    - Helper estandarizado para **respuestas enlatadas (canned)** en flujos HTTP, facilitando la
      creación de fixtures repetibles para `GET/POST/PUT/DELETE`.
    - **Escenarios simulados** adicionales:
        - **Timeout**
        - **Offline** (sin conectividad)
        - **Unexpected error** (excepción no mapeada)
        - **Bad JSON** (payload no parseable)

### Changed
- **Simulación HTTP**: refactor para unificar el esquema de respuestas enlatadas y
  simplificar el **cableado de pruebas**.
- **Normalización** del **raw response** (status, headers, body) antes de pasar por el
  *mapper* de errores/éxitos, reduciendo casos borde de serialización y aserciones
  frágiles en tests.

### Tests
- Suites ampliadas para cubrir los nuevos escenarios (timeout/offline/unexpected/bad-JSON),
  verificando:
    - Normalización del *raw response* previa al mapeo.
    - Comportamiento consistente de los *mappers* de error del proyecto.
    - Idempotencia de los *fixtures* con respuestas enlatadas.

### Migration notes
- Sustituye *fixtures* o *mocks* ad-hoc por el **helper de respuestas enlatadas** para
  reducir duplicación y hacer las pruebas más declarativas.
- Si tus pruebas dependían del formato previo del *raw response*, ajusta aserciones a la
  **nueva normalización** (especialmente en `headers` y `body`).


## [1.33.2] - 2025-12-07
### Fixed
- hotfix para estabilizar el contrato de BlocHttpRequest para garantizar la correcta herencia de BlocModule.

## [1.33.1] - 2025-12-07
### Fixed
- Hotfix para estabilizar el contrato de `ModelAppVersion` al serializar `buildAt` y permitir `defaultModelAppVersion` totalmente constante.

### Fixed
- `ModelAppVersion` ahora persiste `buildAt` como cadena ISO-8601 UTC con `kDefaultBuildAtIso` (07 Dic 2025) como valor por defecto, evitando drift entre plataformas y habilitando instancias const en tree-shaking.
- Se agregó el *getter* `buildAtDateTime` que utiliza `DateUtils` para exponer el valor en `DateTime` sin sacrificar el almacenamiento en texto.

### Docs
- Comentarios del modelo aclaran el nuevo flujo (`buildAt` string + getter) y el uso del `hotfix` para pipelines de lanzamiento.

### Tests
- `test/domain/apps/model_app_version_test.dart` actualizado para validar la cadena ISO, el getter `buildAtDateTime` y el valor centinela `kDefaultBuildAtIso`.

## [1.33.0] - 2025-11-25

> Versión **acumulada** que integra las entregas **1.32.2** (ecosistema de Grupos + auditoría CRUD) y **1.32.1** (stack HTTP transversal). No añade funcionalidades extra fuera de lo ya incluido.

### Added
- **Ecosistema de Grupos**
    - `ModelGroup`, `ModelGroupMember`, `ModelGroupAlias`, `ModelGroupDynamicMembershipRule`.
    - `ModelGroupConfig` / `ModelGroupSettings`, `ModelGroupSyncConfig`, `ModelGroupSyncJob`, `ModelGroupLabels`.
    - Enfoque común: claves JSON con *enums*, `fromJson` robusto, `copyWith`, e igualdad por valor.
- **Auditoría CRUD**
    - `ModelCrudMetadata` (created/updated/deleted, actores, `version`) con helpers: `initialize`, `touchOnUpdate`, `markDeleted`.
    - `ModelCrudLogEntry` (entidad, operación, actor, fecha, `diff/env` opcionales).
- **Stack HTTP transversal (dominio)**
    - **Modelos:** `ModelConfigHttpRequest`, `StateHttpRequest`, `ModelTraceHttpRequest`.
    - **Contratos:** `AdapterHttpClient`, `ServiceHttpRequest`, `GatewayHttpRequest` (*never-throws*), `RepositoryHttpRequest`.
    - **Implementaciones:** `GatewayHttpRequestImpl`, `RepositoryHttpRequestImpl`, `FakeHttpRequest`/`FakeHttpRequestConfig`.
    - **Use cases:** GET/POST/PUT/DELETE, `retry`; **facade** `FacadeHttpRequestUsecases`.
    - **BLoC:** `BlocHttpRequest` con `Set<String>` de peticiones activas.
    - **Error mapping:** `DefaultHttpErrorMapper` (mapea `TimeoutException`→`HTTP_TIMEOUT`, añade `meta.transport='http'`, ajusta `code` según `statusCode/httpStatus`).
- **Utils**
    - `enumFromJson<T>()`, `stringListFromDynamic()`.

### Changed
- **Auth:** `GatewayAuthImpl` usa `DefaultHttpErrorMapper` para enriquecer errores basados en HTTP.
- **Repository HTTP:** `RepositoryHttpRequestImpl` expone `normalizeBody` (mejor testabilidad).

### Removed
- **Exports del dominio:** se retiran `HelperHttpRequestId` y `ModelResponseHttpRaw` (obsoletos en la API vigente).

### Docs
- Modelos de Grupos y Auditoría CRUD: propósito, contratos JSON, ejemplos ejecutables.
- Stack HTTP: guía y ejemplo `bloc_http_request_example.dart`; aclaraciones de nulabilidad en `ModelConfigHttpRequest`.

### Tests
- **Grupos:** baterías por modelo (round-trip JSON, `copyWith`, igualdad, campos faltantes/ inválidos).
- **CRUD:** `model_crud_metadata_test.dart`, `model_crud_log_entry_test.dart`.
- **HTTP:** cobertura amplia (BLoC, Gateway, Repository, Fake service, ErrorMapper, `ModelConfigHttpRequest`).

### Migration notes
- **HTTP errors:** si la UI depende de `code/meta`, contempla nuevos códigos estándar (`HTTP_TIMEOUT`, `HTTP_UNAUTHORIZED`, etc.) y `meta.transport='http'`.
- **Imports:** si consumías `HelperHttpRequestId` o `ModelResponseHttpRaw` desde el *barrel*, elimina esos imports o sustituye por utilidades vigentes.
- **Auditoría:** adopta `ModelCrudMetadata` embebido en entidades y registra eventos transversales con `ModelCrudLogEntry`.

> **Notas:** Cambios no rompientes (salvo limpieza de exports). Los módulos son *opt-in* y compatibles con Firestore/JSON.


## [1.32.2] - 2025-11-24

### Added

- **Domain – Ecosistema de Grupos**
    - `ModelGroup`: entidad núcleo con estado, labels y metadatos.
    - `ModelGroupMember`: relación miembro–grupo (rol, tipo de entidad, suscripción) con validación
      básica de correos.
    - `ModelGroupAlias`: alias de correo con estado de *provisioning* y errores.
    - `ModelGroupConfig` / `ModelGroupSettings`: configuración técnica y de proveedor (e.g., Google
      Groups) y estado de sincronización.
    - `ModelGroupDynamicMembershipRule`: reglas de membresía dinámica.
    - `ModelGroupSyncConfig`: estrategia de sincronización desde fuentes externas (sheets/courses).
    - `ModelGroupSyncJob`: historial de ejecuciones (timestamps, contadores de cambios, uso de API).
    - `ModelGroupLabels`: garantiza `tags` como `List<String>` no nula.
    - **Comportamiento compartido**: claves JSON respaldadas por *enums*, `fromJson` robustos con
      *fallbacks*, `copyWith`, e igualdad por valor (`==`/`hashCode`).
- **Auditoría CRUD**
    - `ModelCrudMetadata`: metadatos de auditoría por registro (created/updated/deleted, actor/es,
      `version`) con `fromJson/toJson`, `copyWith` e *helpers* estáticos: `initialize`,
      `touchOnUpdate`, `markDeleted`.
    - `ModelCrudLogEntry`: registro de operación CRUD (tipo/entidad/actor/fecha) con `diff`/`env`
      opcionales; `copyWith` y serialización robusta.
- **Utils**
    - `enumFromJson<T>()`: parseo seguro de *enums* con *fallback*.
    - `stringListFromDynamic()`: normalización de entradas dinámicas a `List<String>`.

### Docs

- Documentación de modelos y *enums* nuevos: propósito, contratos JSON y ejemplos ejecutables.

### Tests

- **Grupos**: baterías para cada modelo (`model_group*_test.dart`, etc.) con *round-trips* JSON,
  `copyWith`, contratos de igualdad y manejo de campos faltantes/ inválidos.
- **CRUD**: `model_crud_metadata_test.dart`, `model_crud_log_entry_test.dart` (JSON round-trip,
  `copyWith`, *helpers* de ciclo de vida).
- **Utils**: pruebas de `enumFromJson` y `stringListFromDynamic`.

### Notes

- **Sin cambios rompientes** previstos. Los nuevos modelos son *opt-in* y compatibles con
  Firestore/JSON.
- Se recomienda estandarizar auditoría usando `ModelCrudMetadata` anidado en las entidades y
  registrar eventos transversales con `ModelCrudLogEntry`.

## [1.32.1] - 2025-11-18

### Added

- **HTTP transversal (dominio)**
  - **Modelos (`domain/http`):**
    - `ModelConfigHttpRequest` (config inmutable, round-trip JSON).
    - `StateHttpRequest` (ciclo: `Created/Running/Success/Failure/Cancelled`).
    - `ModelTraceHttpRequest` (traza en memoria para depuración/telemetría).
  - **Contratos:**
    - `AdapterHttpClient` (cliente bajo nivel).
    - `ServiceHttpRequest`, `GatewayHttpRequest` (*never-throws* con `ErrorItem`).
    - `RepositoryHttpRequest` (retorna `ModelConfigHttpRequest` en éxito).
  - **Implementaciones:**
    - `GatewayHttpRequestImpl`, `RepositoryHttpRequestImpl`.
    - `FakeHttpRequest` / `FakeHttpRequestConfig` (latencia, errores forzados, respuestas
      enlatadas).
  - **Use cases (`domain/usecases/http_request`):**
    - GET/POST/PUT/DELETE y `retry`, más `FacadeHttpRequestUsecases`.
  - **BLoC (`domain/blocs`):**
    - `BlocHttpRequest` con `Set<String>` de **peticiones activas** para reaccionar en UI.
  - **Enums/helpers:**
    - `HttpMethodEnum`, `HttpRequestLifecycleEnum`, `HttpRequestFailureEnum`.

- **Ejemplo end-to-end**
  - `bloc_http_request_example.dart`: cableado completo **Service → Gateway → Repository →
    Usecases → Facade → BlocHttpRequest**, ejecutando GET/POST/DELETE, mostrando set de activas y
    resultado (`ErrorItem` / `ModelConfigHttpRequest`).

- **Error mapping especializado**
  - `DefaultHttpErrorMapper`:
    - Envuelve `DefaultErrorMapper`.
    - Mapea `TimeoutException` → `HTTP_TIMEOUT`.
    - Añade `transport: 'http'` a `meta`.
    - Ajusta `code` con base en `statusCode/httpStatus` (p.ej. 401 → `HTTP_UNAUTHORIZED`).

### Changed

- **`GatewayAuthImpl`** ahora usa `DefaultHttpErrorMapper` para enriquecer los errores de
  autenticación basados en HTTP.
- **`RepositoryHttpRequestImpl`** expone `normalizeBody` (mejor testabilidad).
- **DartDoc** de `ModelConfigHttpRequest`: contratos de nulabilidad de `headers` y `body` aclarados.

### Removed

- **Exports del dominio**: se retiran `HelperHttpRequestId` y `ModelResponseHttpRaw` por **no uso**
  en la API actual.

### Tests

- Cobertura amplia de todo el *stack* HTTP:
  - **`BlocHttpRequest`**: seguimiento de activas, concurrencia, `retry`, emisiones de stream.
  - **`GatewayHttpRequestImpl`**: adaptación de metadatos, transformación de cuerpo, mapeo de
    errores.
  - **`RepositoryHttpRequestImpl`**: delegación y construcción de configuración.
  - **`FakeHttpRequest`**: respuestas enlatadas, eco, latencia y errores inyectados.
  - **`DefaultHttpErrorMapper`**: excepciones y payloads → `ErrorItem` con `meta` correcto.
  - **`ModelConfigHttpRequest`**: round-trip JSON, valores por defecto, `copyWith`.

### Migration notes

- **Error mapping**: si tu UI/presenters dependen de `code`/`meta`, revisa casos de
  `TimeoutException` y errores 4xx/5xx (ahora vienen con códigos HTTP explícitos y
  `meta.transport='http'`).
- **Exports eliminados**: si importabas `HelperHttpRequestId` o `ModelResponseHttpRaw` desde el
  *barrel*, migra a utilidades propias o a los modelos vigentes. (No afecta a la ruta estándar del
  flujo.)
- **`normalizeBody`** disponible públicamente en `RepositoryHttpRequestImpl` para pruebas finas.

> **Notas:** La versión introduce el **stack HTTP transversal** con ejemplo listo para copiar,
> mejora el **mapeo de errores** y eleva la **cobertura de pruebas**. Cambios no rompientes salvo
> posibles imports a símbolos retirados del *barrel*.

## [1.32.0] - 2025-10-19

> Publicación acumulada que **consolida** los cambios de **1.31.0 → 1.31.3**. No introduce cambios
> funcionales nuevos; sincroniza documentación, ejemplos y *exports* del paquete.

### Included from 1.31.3 (2025-10-19)

**Added**

- Parsers de atributos:
  - `AttributeModel.listFromDynamicTyped<T>(input, fromJsonT)` (parseo tipado desde JSON/String o
    dinámico; raíz `Iterable`; sólo objetos; omite fallas sin lanzar).
  - `AttributeModel.listFromDynamicShallow(input)` (parseo superficial con filtro
    `isDomainCompatible`).
  - Listas retornadas **mutables** (puede cambiar a `List.unmodifiable` en futuras versiones).
- Educación: nuevos modelos (`CompetencyStandard`, `LearningGoal`, `PerformanceIndicator`,
  `AchievementTriple`, `LearningItem`, `Assessment`) y enums (`ActorRole`, `ContentState`,
  `PerformanceLevel`). Ejemplo runnable `education_base_project.dart`.

**Changed**

- `ModelLearningGoal` con `LearningGoalEnum`, `extends Model`, `fromJson` robusto, `copyWith`,
  `==/hashCode`, `standard` anidado como **objeto** (fallback a `defaultCompetencyStandard`).
- Rediseño evaluación:
  - `ModelAssessment extends Model` + `AssessmentEnum`, `timeLimit: Duration` (ms via
    `timeLimitMs`), `items` inmutable.
  - `ModelLearningItem extends Model` + `LearningItemEnum`; `wrongAnswers: List<String>` →
    `wrongAnswerOne/Two/Three`; `achievements` → `achievementOne` (req.), `achievementTwo/Three` (
    opt.).

**Docs/Tests**

- DartDoc exhaustivo de parsers y modelos; suites con *round-trip*, defaults, assertions,
  determinismo e inmutabilidad de listas.

**Breaking** (recordatorio)

- `ModelLearningGoal.standard` serializa como **objeto** bajo `"standard"`.
- `ModelLearningItem` cambia forma JSON; ver 1.31.3 para guía de migración.

---

### Included from 1.31.2 (2025-10-18)

**Added**

- `ModelItem` (id/name/description/`type: ModelCategory`/`price: ModelPrice`/`attributes`) con
  *fallback* de `id`.
- `ModelPrice` (`mathPrecision`, `CurrencyEnum`, `decimalAmount`).
- `ModelCategory` (+ enum) con *slug* normalizado y `==/hashCode` por categoría canónica.
- `ModelAttribute<T>` (alias `AttributeModel<T>`) con helper `from<T>()` y validación de tipos
  soportados.
- Demo end‑to‑end (Store) *single‑file* sin dependencias externas, precisión financiera alineada con
  `ModelPrice`.

**Tests**

- `model_item_test.dart`, `model_price_test.dart`, `attribute_model_test.dart`,
  `model_category_test.dart`.

**Notes**

- Modelos **inmutables**, **serializables** y compatibles con Firestore. **Sin cambios rompientes**.

---

### Included from 1.31.1 (2025-10-18)

**Docs**

- `Bloc`/extensión: semántica **seeded stream** y contratos de ciclo de vida (sin
  historial/backpressure; `add/value` tras `dispose()` lanza). Ejemplos ejecutables; alineación
  entre `bloc.dart` y `entity_bloc.dart`.

> Documentación únicamente. **Sin cambios de API**.

---

### Included from 1.31.0 (2025-10-13)

**Resumen**

- Consolidación de **sesión**, **WS DB JSON‑first** y **utils** con ejemplos y suites de pruebas (
  ver release 1.31.0 para detalle y notas de migración de WS DB).

---

### Migration notes

- Esta versión **no añade** nuevas migraciones. Aplican las ya documentadas en **1.31.3** (
  educación) y **1.31.0** (WS DB renombres/contrato JSON‑first).

### Housekeeping

- Sincronización de `README/DartDoc` y ejemplos; verificación de *exports* en el *barrel* público.

## [1.31.3] - 2025-10-19

### Added

- **Domain/Model – Parsers de atributos tipados y superficiales**
  - `AttributeModel.listFromDynamicTyped<T>(input, fromJsonT)`: parseo **tipado** desde `String` (
    JSON) o entrada dinámica; decodifica, exige raíz `Iterable`, incluye solo objetos
    `{String,dynamic}`, aplica convertidor `fromJsonT`, y salta fallas sin lanzar.
  - `AttributeModel.listFromDynamicShallow(input)`: parseo **shallow** delegando en
    `Utils.listFromDynamic` y filtrando por compatibilidad de dominio.
  - Comportamientos clave:
    - Faltante `"name"` → `''` (vacío).
    - Entradas no objeto en arrays JSON → **ignoradas**.
    - Entradas no-`String` → rama `Utils`.
    - *Guard* superficial: incluir únicamente valores que pasen `isDomainCompatible`.
    - **Listas retornadas son mutables** (posible cambio futuro a `List.unmodifiable`).
- **Domain/Education – Nueva base curricular y evaluaciones**
  - Modelos: `CompetencyStandard`, `LearningGoal`, `PerformanceIndicator`, `AchievementTriple`,
    `LearningItem`, `Assessment`.
  - Enums de soporte: `ActorRole`, `ContentState`, `PerformanceLevel`.
  - Ejemplo runnable: `education_base_project.dart` con jerarquía completa hasta `Assessment`.

### Changed

- **Education – `ModelLearningGoal`**
  - `LearningGoalEnum` para claves JSON estables.
  - `ModelLearningGoal extends Model` con `fromJson` robusto (utilidades `Utils.*`), `copyWith`,
    `==/hashCode`, `toString()` → JSON, y **precondición** `version > 0`.
  - Anidado `standard` como **objeto completo** (usa `defaultCompetencyStandard` si falta).
- **Education – Rediseño de evaluación y reactivos asociados**
  - `ModelAssessment extends Model` con `AssessmentEnum`; `timeLimit: Duration` → serializa en **ms
    ** (`timeLimitMs`); lista `items` inmutable; `defaultModelAssessment`.
  - `ModelLearningItem extends Model` con `LearningItemEnum`:
    - `wrongAnswers: List<String>` → **campos** `wrongAnswerOne/Two/Three`.
    - `achievements: List<ModelPerformanceIndicator>` → **triple** `achievementOne` (req.),
      `achievementTwo/Three` (opt.).
    - `attributes` inmutables, `optionsShuffled([seed])`, `copyWith`, `==/hashCode`.

### Docs

- **Attribute parsers:** DartDoc exhaustivo para `listFromDynamicTyped<T>` (entradas aceptadas,
  conversión, *shallow checks*, claves faltantes, manejo de errores, orden, ejemplo runnable y
  limitaciones).
- **Education:** documentación de modelos y demo de evaluación (sumas/restas 3°) basada en
  `jocaagura_domain`.

### Tests

- **Atributos**
  - `attribute_model_list_typed_test.dart`: conversión `int` desde `String`, `DateTime` ISO8601,
    JSON inválido/objeto→vacío, rama `Utils` para no-`String`, `"name"` faltante→`''`, convertidor
    que lanza→**salta ítem**, tipo no compatible→**omitido**, `Iterable` explícito, ignora elementos
    no objeto.
  - `attribute_model_list_shallow_test.dart`: preserva heterogeneidad, JSON inválido/objeto→vacío,
    `"name"` faltante→`''`, valor no compatible→**omitido**, `null`→vacío, ignora no-objeto.
- **Education**
  - `ModelLearningGoal`: *round-trip*, `copyWith`, *defaults* (incluye `standard`), `standard` como
    `String` JSON→`Utils.mapFromDynamic`, aserción `version <= 0` falla, igualdad/hash, `toString()`
    parseable con claves enum.
  - `CompetencyStandard`: *round-trip*, `copyWith`, *defaults*.
  - `Assessment`/`LearningItem`: *round-trip*, Durations en ms, determinismo de `optionsShuffled`,
    listas inmutables.

## [1.31.2] - 2025-10-18

### Added

- **Domain – Productos y precios**
  - `ModelItem`: entidad mínima y extensible (id, name, description, `type: ModelCategory`,
    `price: ModelPrice`, `attributes` dinámicos).
    - Lógica *fallback* de `id` cuando viene vacío (usa `category` normalizada).
  - `ModelPrice`: valor monetario con `mathPrecision`, `CurrencyEnum` (COP, USD, MXN, …) y
    `decimalAmount` para conversión precisa.
  - **Constantes:** `defaultModelItem`, `defaultModelPrice`.
- **Taxonomía**
  - `ModelCategory` (+ `ModelCategoryEnum`): modelo inmutable con *slug* canónico.
    - API pública: `fromJson`, `toJson`, `copyWith`, `normalizeCategory(String)`.
    - Igualdad/`hashCode` basados **solo** en `category` normalizada.
- **Atributos tipados**
  - `ModelAttribute<T>` (*alias* de `AttributeModel<T>`): atributos genéricos **compatibles con
    Firestore** (tipos soportados).
    - Helper `ModelAttribute.from<T>()` para construcción tipada con validación.
- **Demo end-to-end (Store)**
  - Ejemplo **single-file** listo para copiar (sin paquetes externos) mostrando:  
    `UI → AppManager → Bloc → UseCase → Repository → Gateway → Service`  
    usando `StoreModel`, `ModelItem`, `ModelPrice`, `ModelCategory`, `FinancialMovementModel` y
    `LedgerModel`.
    - Alinea precisión financiera con `ModelPrice(mathPrecision: 2)`.

**Tests**

- `model_item_test.dart`: *round-trip* JSON, *fallback* de `id`, `copyWith`, igualdad/`hashCode`,
  `toString`.
- `model_price_test.dart`: matemática decimal, *fallback* de moneda, *round-trip*, `copyWith`.
- `attribute_model_test.dart`: `from<T>()`, seguridad de tipos, *round-trip*, igualdad.
- `model_category_test.dart`: matriz de normalización (espacios/puntuación/caso), *round-trip*,
  igualdad basada en `category` normalizada, `copyWith`, `toJson` (trim de `description`).

### Docs

- DartDoc en **inglés** con ejemplo ejecutable para `ModelCategory`.
- Guía del ejemplo **pet store** con precisión financiera alineada a `ModelPrice`.

### Notes

- Todos los modelos son **inmutables** y **serializables** (compatibles con Firestore).
- **Sin cambios rompientes**: nuevas entidades y helpers son *opt-in*.
- Si tu lógica dependía del signo de montos para ingreso/egreso, usa el `category`/tipo del item en
  lugar de valores negativos.

## [1.31.1] - 2025-10-18

### Docs

- **Bloc / Extension (domain):** se clarifica el **semántico seed** del stream:
  - `Bloc.stream` es **seeded**: captura el valor **en el momento del getter** y **cada suscripción
    ** recibe primero ese *seed* y luego las actualizaciones.
  - Suscripción **ansiosa** a la fuente, comportamiento **broadcast**, y notas de ciclo de vida.
  - Caso fuente ya completada: el suscriptor se **cierra sin emitir** el seed.
- **Contratos explícitos:** pre/postcondiciones documentadas:
  - **Sin historial ni backpressure**; solo el *seed* actual y eventos futuros.
  - Llamar `add/value` tras `dispose()` **lanza** desde el controlador.
- **Ejemplos ejecutables:** se añaden `void main()` de referencia para uso correcto.
- **Consistencia:** DartDoc alineada entre `bloc.dart` y `entity_bloc.dart` (punto de extensión y
  notas de ciclo de vida).

> **Notas:** Solo documentación. **Sin cambios funcionales ni de API**.

## [1.31.0] - 2025-10-13

### Resumen práctico

Publicación acumulada que consolida **sesión**, **BD WebSocket JSON-first**, y **utilidades de
dominio** con ejemplos listos para copiar. Mejora la **testabilidad**, clarifica **contratos** y
simplifica la **integración** en apps nuevas o existentes.

### Puntos clave

- **Sesión**
  - `BlocSession` ahora extiende `BlocModule` (ciclo de vida unificado) y expone **hooks** de
    efectos secundarios por cambio de estado.
  - Nuevo `getCurrentUser()` con **debounce** y emisión
    `Authenticating → Authenticated/SessionError`.
  - Constructor simplificado y *factory* `BlocSession.fromRepository(...)` para *quick start*.
- **BD WebSocket (JSON-first)**
  - Nuevo **`ServiceWsDb`** y **`GatewayWsDbImpl`** con **multiplexing** y *reference counting*; *
    *`FakeServiceWsDb`** en memoria para pruebas.
  - BLoC `BlocWsDatabase` con ciclo de vida documentado y helpers (`existsDoc`, `ensureDoc`,
    `mutateDoc`, `patchDoc`).
- **Dominio / Utils**
  - `ModelAppVersion` inmutable (UTC, `meta` inmodificable, `deepEqualsMap`/`deepHash`).
  - Utilidades de igualdad/`hash` profundas para mapas y listas.

### Ejemplos incluidos

- **Contacts CRUD (WebSocket DB):** `bloc_ws_db_example.dart` (form + visor de estado, colección en
  vivo).
- **Ledger 2024:** `ledger_example.dart` (torta y barras con `CustomPainter`, sin dependencias
  externas).

### Documentación

- Contratos ampliados y ejemplos para **use cases de sesión**, `GatewayAuth/RepositoryAuth`,
  `FacadeCrudDatabaseUsecases`, `BlocWsDatabase` y `ModelAppVersion`.
- Aclaraciones de ciclo de vida (`dispose`, *watches* compartidos, “último evento gana”).

### Pruebas

- Suites completas para `GatewayAuthImpl`, `RepositoryAuthImpl`, `BlocSession` (hooks y
  `getCurrentUser`), `GatewayWsDbImpl`, `FakeServiceWsDb`, `BlocWsDatabase` y `ModelAppVersion`.

### Migración rápida

- **WS DB renombres**

  - `ServiceWsDatabase` → `ServiceWsDb`
  - `FakeServiceWsDatabase` → `FakeServiceWsDb`
  - `GatewayWsDatabaseImpl` → `GatewayWsDbImpl`

- **Contrato JSON-first**

  - Si usabas `ServiceWsDatabase<T>`, mueve el mapeo de tipos al **Repository/Gateway** y trabaja
    con
    `Map<String, dynamic>`.

- **BlocSession**

  - Reemplaza constructores antiguos por el simplificado o `BlocSession.fromRepository`.
  - Si utilizas `authStateChanges`, consume `Either<ErrorItem, Map<String, dynamic>?>`.

- **Hooks de sesión**

  - Usa `addFunctionToProcessTValueOnStream(key, fn, executeNow)` para efectos en segundo plano sin
    suscribirte al `Stream`.

> **Notas:** Cambios no rompientes salvo renombres de WS DB y ajustes de constructor/streams en
> sesión. Los ejemplos sirven como guía de integración inmediata.

## [1.30.5] - 2025-10-13

### Added

- **Session – `BlocSession.getCurrentUser()`**
    - Método público para consultar el **usuario actual** desde el repositorio.
    - Emite `Authenticating` → `Authenticated` (éxito) o `SessionError` (falla).
    - **Debounce** interno para evitar llamadas redundantes ante interacciones rápidas de UI.
    - Lanza `StateError` si se invoca tras `dispose()`.
- **Example – WebSocket DB (Contacts CRUD)**
    - `bloc_ws_db_example.dart`: demo completa de CRUD + *realtime* con
      `BlocWsDatabase<ContactModel>` y `ContactsCollectionBloc`.
    - Muestra `WsDbState`, *transition log* y lista en vivo.
    - Arquitectura ilustrada: `FakeServiceWsDb` → `GatewayWsDbImpl` → `RepositoryWsDatabaseImpl` →
      `FacadeWsDatabaseUsecases` → `BlocWsDatabase`.

### Changed

- **Use Cases (Session):**
    - `GetCurrentUserUsecase` ahora invoca correctamente `repository.getCurrentUser()` **sin
      parámetros**.

### Docs

- **Session Usecases:** DartDoc ampliado con contratos, parámetros, valores de retorno y ejemplos
  para:
    - `GetCurrentUserUsecase`, `LogInSilentlyUsecase`, `LogInUserAndPasswordUsecase`,
      `LoginWithGoogleUsecase`, `LogOutUsecase`, `RecoverPasswordUsecase`,
      `RefreshSessionUsecase`, `SignInUserAndPasswordUsecase`,
      `WatchAuthStateChangesUsecase`, y el agregador `SessionUsecases`.
- **CRUD Facade:** documentación extendida de `FacadeCrudDatabaseUsecases`
  (visión general, ejemplo integral, clarificación de constructores y distinción entre
  *use cases* individuales y métodos de conveniencia).

### Tests

- **BlocSession:** `bloc_session_get_current_user_test.dart`
    - Cubre éxito/falla, lógica de **debounce** y comportamiento post-`dispose()`.

> **Notas:** Cambios no rompientes. Asegúrate de no invocar `getCurrentUser()` después de
`dispose()` y considera el **debounce** al escribir pruebas o automatizaciones de UI.

## [1.30.4] - 2025-10-12

### Added

- **DB (JSON-first):** `ServiceWsDb` — servicio abstracto estilo WebSocket/NoSQL que opera *
  *exclusivamente** con `Map<String, dynamic>`:
  - Operaciones: `save`, `read`, `delete`, `documentStream`, `collectionStream`.
- **DB Fake:** `FakeServiceWsDb` — implementación en memoria para pruebas/desarrollo:
  - Latencia configurable, simulación de errores, *deep copy*, *de-dupe* por contenido y *hooks*
    para inspección interna.
- **Gateway WS:** `GatewayWsDbImpl` — capa multiplexada sobre `ServiceWsDb`:
  - **Multiplexing:** comparte una sola suscripción por `docId`.
  - **Reference counting:** `watch` / `detachWatch` y `releaseDoc` para *lifecycle* eficiente;
    `dispose` para *teardown* global.
  - **Error mapping:** todo a `Either<ErrorItem, …>` vía `ErrorMapper`.
  - **Configuración:** `idKey` personalizado, `readAfterWrite`, `treatEmptyAsMissing`.
- **Mapper de errores:** `WsDbErrorMiniMapper` para mapear `ArgumentError`/`StateError` a JSON de
  error estructurado.
- **Example:** `bloc_ws_db_example.dart` — demo completa CRUD + *realtime* de **Contactos**:
  - UI de dos paneles (formulario + visor de estado).
  - `BlocWsDatabase<ContactModel>` (documento) y `ContactsCollectionBloc` (colección).
  - Muestra `WsDbState`, *ledger* de transiciones y lista en vivo.
  - Flujo recomendado: `FakeServiceWsDb` → `GatewayWsDbImpl` → `RepositoryWsDatabaseImpl` →
    `FacadeWsDatabaseUsecases` → `BlocWsDatabase`.

### Changed

- **Estandarización de nombres (WS DB):**
  - `ServiceWsDatabase` → **`ServiceWsDb`**
  - `FakeServiceWsDatabase` → **`FakeServiceWsDb`**
  - `GatewayWsDatabaseImpl` → **`GatewayWsDbImpl`**

### Deprecated

- **`ServiceWsDatabase<T>`:** marcado como `@Deprecated` en favor del enfoque **JSON-first**; el
  *type mapping* queda en Repository/Gateway.

### Docs

- **`bloc_ws_database.dart`:**
  - Aclara que publica un único *stream* de `WsDbState` (el **último evento gana** cuando hay
    múltiples `watch` activos).
  - Documenta `dispose`: *best-effort* para desprender *watches* y **no** dispone *stacks*
    compartidos.
  - Mejora la descripción de ciclo de vida de *watch* (`startWatch`, `stopWatch`, `stopAllWatches`).

### Tests

- **FakeServiceWsDb:** suite integral (operaciones básicas, configuración, manejo de errores).
- **GatewayWsDbImpl:** lectura, escritura, borrado y *watch*; mapeo de errores y *lifecycle* por
  referencias.
- **BlocWsDatabase:** `bloc_ws_database_ext_test.dart`
  - Estado ante `read/write/delete` (`doc`, `loading`, `error`).
  - `startWatch`/`stopWatch`/`stopAllWatches`, *facade* detachment y coordinación de `watchUntil`.
  - *Lifecycle:* `dispose` cancela suscripciones sin disponer repos compartidos.
  - *Helpers:* `existsDoc`, `ensureDoc`, `mutateDoc`, `patchDoc`.

### Migration notes

- **Renombres:** actualiza imports y tipos a `ServiceWsDb`, `FakeServiceWsDb`, `GatewayWsDbImpl`.
- **Deprecación:** si usabas `ServiceWsDatabase<T>`, migra al contrato **JSON-first** (
  `Map<String, dynamic>`); mueve el mapeo de tipos a Repository/Gateway.
- **Comportamiento de `treatEmptyAsMissing`:** si tu servicio devuelve `{}` para *not found*,
  habilita esta opción en el Gateway para recibir un `Left(ErrorItem)` consistente.
- **Multiplexing:** si tenías *watch* duplicados por `docId`, ahora se comparte la suscripción;
  considera llamar `detachWatch`/`releaseDoc` al desmontar widgets para liberar referencias.

> **Notas:** No hay cambios incompatibles fuera de los **renombres** y la **deprecación** indicada.
> El ejemplo de **Contactos** sirve como guía de integración sin dependencias externas.

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
  inmodificable).
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
