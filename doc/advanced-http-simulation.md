# VirtualCrudService: simular un API REST (sin red) en Jocaagura

Este documento explica cómo usar `VirtualCrudService` para **simular el comportamiento de un API REST** sin networking real, con rutas, validaciones, estado in-memory y fallos determinísticos, integrado al flujo Jocaagura:

**UI → BlocHttpRequest → Facade (usecases) → Repository → Gateway → ServiceHttpRequest**

---

## ¿Qué problema resuelve?

Cuando quieres **probar o demostrar** el flujo completo (incluyendo `Either<ErrorItem, ModelConfigHttpRequest>`) pero sin backend real, `VirtualCrudService` te permite:

- Definir **rutas** (`/v1/...`) y su semántica (GET/POST/PUT/DELETE).
- Ejecutar **validaciones** y reglas de negocio.
- Mantener una **DB falsa en memoria** que muta con POST/PUT/DELETE.
- Emitir respuestas **JSON-like** para ser mapeadas por los mappers del pipeline.

---

## Qué es y qué no es

### Esto SÍ es
- Un **backend virtual** determinístico: routing, validaciones, persistencia in-memory.
- Un **laboratorio** para QA manual y pruebas locales.
- Una pieza que permite simular errores: `422/401/404/409/500` (o los que definas).

### Esto NO es
- Un cliente HTTP real, ni caching, ni auth real.
- Una recomendación de meter metadata en bodies en producción.
- Un reemplazo de un contrato formal de backend: es un simulador.

---

## Contrato: VirtualCrudService

Implementaciones típicas siguen este flow:

1) El transport (fake) llama `canHandle(ctx)` para decidir quién resuelve el request.  
2) Si es `true`, llama `handle(ctx)` para producir el payload JSON-like.  
3) En tests/escenarios, `reset()` deja el estado limpio y determinístico.

```dart
abstract class VirtualCrudService {
  /// Returns `true` if this service can resolve the incoming request.
  bool canHandle(RequestContext ctx);

  /// Handles the request and returns a JSON-like payload.
  Future<Map<String, dynamic>> handle(RequestContext ctx);

  /// Resets any internal state to keep tests isolated and deterministic.
  void reset();
}
```

### Reglas obligatorias

* `canHandle` **debe ser puro** (sin side effects, rápido).
* `handle` debe retornar un `Map<String, dynamic>` **JSON-like** (solo tipos serializables).
* `reset` debe limpiar toda la DB in-memory para evitar contaminación entre tests.

---

## Contrato: RequestContext (definición oficial)

`RequestContext` define el request de salida de forma agnóstica al transporte. Este contrato es el “centro” del determinismo.

```dart
class RequestContext {
  const RequestContext({
    required this.method,
    required this.uri,
    this.headers,
    this.body,
    this.timeout,
    this.metadata = const <String, dynamic>{},
  });

  /// HTTP-like method name (e.g. `GET`, `POST`, `PUT`, `DELETE`).
  final String method;

  /// Target endpoint.
  final Uri uri;

  /// Optional request headers.
  final Map<String, String>? headers;

  /// Optional request body (already decoded as a JSON-like map).
  final Map<String, dynamic>? body;

  /// Optional per-request timeout override.
  final Duration? timeout;

  /// Arbitrary test-only flags (e.g. force malformed response).
  final Map<String, dynamic> metadata;
}
```

### Ejemplo real de RequestContext (POST /v1/cats)

```dart
final RequestContext ctx = RequestContext(
  method: 'POST',
  uri: Uri.parse('https://petshop.jocaagura.dev/v1/cats'),
  headers: <String, String>{
    'content-type': 'application/json',
  },
  body: <String, dynamic>{
    'name': 'Michi Nuevo',
    'gender': 'female',
    'weightKg': 3.2,
    'ageYears': 1.0,
  },
  metadata: <String, dynamic>{
    'feature': 'vet',
    'operation': 'createCat',
    'testMode': true,
  },
);
```

---

## Roles en el ejemplo (separación de responsabilidades)

### 1) Fake Transport (simulación de transporte)

Ejemplo: `JocaaguraFakeHttpRequest`

* Recorre `services` en orden y elige el primer `canHandle == true`.
* Puede simular latencia y fallas determinísticas por ruta.
* No interpreta reglas de negocio ni valida payload: eso vive en el backend virtual.

### 2) VirtualCrudService (backend virtual)

Ejemplo: `VetCatsVirtualCrudService`, `AuthUsersVirtualCrudService`

* Interpreta el request (`method`, `uri`, `body`, etc.).
* Aplica validaciones y reglas.
* Mutación in-memory (POST/PUT/DELETE actualizan su DB).
* Define la forma del payload final que consumirá el mapper.

### 3) Adapter (puente de contrato)

Ejemplo: `ServiceHttpRequestAdapter`

* Traduce entre interfaces de transporte (Uri vs String url, delete void, etc.).
* Decide cómo se serializa `metadata` (headers, tags, body, query, etc.).
* Ideal para estandarizar decisiones “de laboratorio” sin contaminar capas superiores.

---

## Resolución de colisiones: ¿qué pasa si 2 services pueden manejar?

**Regla del transport:** elige el **primer** service registrado cuyo `canHandle` retorne `true`.

Buenas prácticas para evitar sorpresas:

* Cada service debe ser **dueño** de un namespace (por ejemplo `/v1/cats`).
* Evita “pescar” rutas genéricas (ej. “todo lo que sea /v1/*”).
* Recomendación (debug): si detectas que más de uno podría manejar, loguea una alerta.

---

## Qué pasa con rutas no soportadas

Recomendación consistente para simulación:

* Si `handle` recibe un request que **no soporta**, debe lanzar `StateError`.
* El fake transport (o el adapter) decide si:

    * Deja explotar el error (útil en tests para detectar rutas mal definidas), o
    * Lo traduce a un FAIL consistente (`unhandled_route`).

En el ejemplo, se prefiere **`StateError`** para detectar errores temprano durante desarrollo.

---

## Contrato de respuesta: Response payload (OK/FAIL)

Para que el pipeline pueda mapear a `Either<ErrorItem, ModelConfigHttpRequest>`, necesitas respuestas consistentes.

En el ejemplo se usa un shape “Jocaagura-friendly” no obligatorio, típicamente generado por:
`FakeHttpRequestConfig.cannedHttpResponse(...)`

### Reglas mínimas recomendadas

* **OK**: incluir `statusCode`, `reasonPhrase`, `method`, `uri`, `body`, `metadata`.
* **FAIL**: incluir **`ok:false`** y un error mappeable (`code`, `message`, y opcional `error{...}`).

> Nota: si tu backend real no usa este shape, modela el raw payload aquí y cambia el mapper (o ajusta el service virtual para emitir lo esperado).

---

## Ejemplos copy–paste de payloads

> Los siguientes ejemplos son “semánticos” (campos clave). El orden puede variar.

### OK: GET /v1/cats (list)

```json
{
  "ok": true,
  "method": "GET",
  "uri": "https://petshop.jocaagura.dev/v1/cats",
  "statusCode": 200,
  "reasonPhrase": "OK",
  "metadata": {
    "feature": "vet",
    "resource": "cats",
    "operation": "listCats"
  },
  "body": {
    "items": [
      {
        "id": "cat-001",
        "name": "Mandarina",
        "animalType": "feline",
        "gender": "female",
        "weightKg": 3.6,
        "status": "active",
        "createdAt": "2025-05-09T10:00:00.000Z",
        "updatedAt": "2026-01-14T10:00:00.000Z"
      }
    ]
  }
}
```

### OK: GET /v1/cats/cat-001 (detail)

```json
{
  "ok": true,
  "method": "GET",
  "uri": "https://petshop.jocaagura.dev/v1/cats/cat-001",
  "statusCode": 200,
  "reasonPhrase": "OK",
  "metadata": {
    "feature": "vet",
    "resource": "cats",
    "operation": "getCat",
    "id": "cat-001"
  },
  "body": {
    "item": {
      "id": "cat-001",
      "name": "Mandarina",
      "animalType": "feline",
      "gender": "female",
      "weightKg": 3.6,
      "status": "active",
      "createdAt": "2025-05-09T10:00:00.000Z",
      "updatedAt": "2026-01-14T10:00:00.000Z"
    }
  }
}
```

### FAIL: 422 validation_error (POST /v1/cats)

```json
{
  "ok": false,
  "method": "POST",
  "uri": "https://petshop.jocaagura.dev/v1/cats",
  "statusCode": 422,
  "reasonPhrase": "Unprocessable Entity",
  "metadata": {
    "source": "VetCatsVirtualCrudService",
    "feature": "vet",
    "resource": "cats",
    "operation": "createCat"
  },
  "code": "validation_error",
  "message": "name is required",
  "error": {
    "code": "validation_error",
    "message": "name is required",
    "title": "Unprocessable Entity"
  }
}
```

### FAIL: 409 delete_forbidden (DELETE /v1/cats/cat-002)

```json
{
  "ok": false,
  "method": "DELETE",
  "uri": "https://petshop.jocaagura.dev/v1/cats/cat-002",
  "statusCode": 409,
  "reasonPhrase": "Conflict",
  "metadata": {
    "source": "VetCatsVirtualCrudService",
    "feature": "vet",
    "resource": "cats",
    "operation": "deleteCat",
    "id": "cat-002"
  },
  "code": "delete_forbidden",
  "message": "Forced demo error: Kira cannot be deleted",
  "error": {
    "code": "delete_forbidden",
    "message": "Forced demo error: Kira cannot be deleted",
    "title": "Conflict"
  }
}
```

---

## Tabla de endpoints (por service)

### VetCatsVirtualCrudService

| Method | Path         | Description | Body mínimo              | OK body shape        | Error codes esperados |
|--------|--------------|-------------|--------------------------|----------------------|-----------------------|
| GET    | /v1/cats     | List cats   | —                        | `{ "items": [...] }` | 500 (transport), —    |
| GET    | /v1/cats/:id | Cat detail  | —                        | `{ "item": {...} }`  | 404                   |
| POST   | /v1/cats     | Create cat  | `{name, weightKg, ...}`  | `{ "item": {...} }`  | 422, 500              |
| PUT    | /v1/cats/:id | Update cat  | `{name, weightKg?, ...}` | `{ "item": {...} }`  | 404, 422              |
| DELETE | /v1/cats/:id | Delete cat  | —                        | `{}` (204)           | 404, 409              |

### AuthUsersVirtualCrudService

| Method | Path           | Description | Body mínimo           | OK body shape                     | Error codes esperados |
|--------|----------------|-------------|-----------------------|-----------------------------------|-----------------------|
| POST   | /v1/auth/login | Login       | `{email, password}`   | `{ "user": {...}, "jwt": {...} }` | 422, 401, 404         |
| GET    | /v1/users/me   | Me          | — (usa Authorization) | `{ "user": {...} }`               | 401, 404              |
| GET    | /v1/users      | List users  | —                     | `{ "items": [...] }`              | —                     |
| GET    | /v1/users/:id  | Get by id   | —                     | `{ "item": {...} }`               | 404                   |

---

## Determinismo: IDs y fechas (guía concreta)

Para evitar flaky tests y snapshots inconsistentes, adopta una de estas estrategias:

### Estrategia 1: contador incremental por reset

* Mantén `int _nextId = 100;` y en `reset()` lo reinicias.
* IDs: `cat-${_nextId++}`.

### Estrategia 2: reloj fijo interno

* Define `final DateTime _fixedNow = DateTime.parse('2026-01-01T00:00:00Z');`
* En tests, usa siempre `_fixedNow` o `_fixedNow.add(Duration(...))`.

> Si tu service usa `DateTime.now()`, el UI/diffs de JSON pueden cambiar entre ejecuciones.

---

## JSON-safe: helper mínimo recomendado

Si tu service construye payloads complejos, estandariza una función de saneamiento:

```dart
Object? jsonSafe(Object? v) {
  if (v == null) return null;
  if (v is num || v is bool || v is String) return v;
  if (v is DateTime) return v.toIso8601String();
  if (v is Uri) return v.toString();
  if (v is Duration) return v.inMilliseconds;

  if (v is Map) {
    return v.map((dynamic k, dynamic val) => MapEntry('$k', jsonSafe(val)));
  }

  if (v is Iterable) {
    return v.map(jsonSafe).toList();
  }

  // Fallback: conviértelo a string para no romper el encoder
  return v.toString();
}
```

---

## Adapter: 2 ejemplos críticos

### 1) DELETE como “void” en transporte, pero Map en contrato superior

En el ejemplo, el adapter:

* llama `delete(url...)` al transport (void)
* retorna un canned response 204 para mantener el contrato `Future<Map<String,dynamic>>`

### 2) Metadata serializada como headers/tags

En el ejemplo:

* `metadata['headers']` se fusiona con headers reales
* se añade un `x-tags` (solo para demo) cuando `metadata` no está vacío

Esto te permite:

* simular auth (Bearer) sin ensuciar capas
* pasar flags de test (`testMode`, `forceMalformed`, etc.) sin romper el dominio

---

## QA manual: escenarios rápidos (verificables)

Con la UI demo:

* Refresh → `GET /v1/cats`
* Tap item → `GET /v1/cats/:id`
* Create → `POST /v1/cats`
* Update → `PUT /v1/cats/:id`
* Delete → `DELETE /v1/cats/:id`

Escenarios sugeridos:

* `name=""` → `422 validation_error`
* `name="gato-error"` → `500 forced_create_error` *(match exacto)*
* borrar “Kira” → `409 delete_forbidden`
* activar `FakeHttpRequestConfig.errorRoutes[...]` → error determinístico por ruta

---

## Troubleshooting rápido

### “ERR_UNEXPECTED”

Suele significar:

* excepción de transporte (errorRoutes / throwOnX / StateError), o
* payload no reconocido por el mapper.

Checklist:

* `errorRoutes` (¿forzando error?)
* `throwOnPost/Put/Delete` (si aplica)
* `FAIL` incluye `ok:false` + `code/message`
* payload JSON-safe (sin DateTime/Uri/Duration crudos)

### Mi service no intercepta requests

Probables causas:

* mismatch en `host/scheme/port`
* namespace incorrecto (`/v1/...`)
* `canHandle` demasiado estricto o demasiado laxo

---

## Checklist final (para crear un VirtualCrudService nuevo)

* [ ] `canHandle` rápido, puro y dueño de un namespace
* [ ] `handle` implementa rutas REST + validaciones + estado in-memory
* [ ] `reset` limpia DB y re-siembra datos
* [ ] Respuestas OK/FAIL consistentes y JSON-safe
* [ ] FAIL mappeable: `ok:false`, `code`, `message` (y `error{...}` opcional)
* [ ] Tabla de endpoints documentada (Method/Path/Body/OK/Errors)
* [ ] Estrategia de determinismo (ids/fechas) definida
