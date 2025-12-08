# Módulo HTTP transversal en `jocaagura_domain`

> **Propósito:** Centralizar el flujo de peticiones HTTP en una arquitectura en capas, manteniendo:
>
> - Un único lugar para:
>   - Mapear errores de transporte/backend a `ErrorItem`.
>   - Exponer un estado agregador de peticiones activas (`BlocHttpRequest`).
> - UseCases simples y testeables.
> - Integración transparente con UIs Flutter (loaders, dashboards de red, etc.).

---

## 1. Visión general del flujo

El flujo completo (de abajo hacia arriba) es:

```text
ServiceHttpRequest  →  GatewayHttpRequest  →  RepositoryHttpRequest
               (Map)          (Either<ErrorItem, Map>)    (Either<ErrorItem, ModelConfigHttpRequest>)
                                     ↓
                       UsecaseHttpRequest{Get,Post,Put,Delete,Retry}
                                     ↓
                       FacadeHttpRequestUsecases
                                     ↓
                             BlocHttpRequest
                                     ↓
                                   UI
````

* **Service**: frontera con el mundo externo (cliente HTTP real o `FakeHttpRequest`).
* **Gateway**: captura excepciones / payloads de error y los traduce a `ErrorItem`.
* **Repository**: convierte JSON + metadata en un modelo de dominio `ModelConfigHttpRequest`.
* **Usecases + Facade**: exponen operaciones GET/POST/PUT/DELETE/RETRY para los casos de uso de negocio.
* **BlocHttpRequest**: orquestador transversal que solo sabe qué peticiones están **activas**.
* **UI**: usa el `BlocHttpRequest` para loaders globales y consume los resultados (`Either<ErrorItem, ModelConfigHttpRequest>`) de cada llamada.

---

## 2. Responsabilidades por capa

| Capa                        | Entrada                        | Salida                                                | Responsabilidad principal                                            |
|-----------------------------|--------------------------------|-------------------------------------------------------|----------------------------------------------------------------------|
| `ServiceHttpRequest`        | `uri`, `headers`, `body`, etc. | `Future<Map<String, dynamic>>` ó excepción            | Llamar al cliente HTTP real (o fake) y devolver JSON crudo.          |
| `GatewayHttpRequest`        | parámetros de request          | `Future<Either<ErrorItem, Map<String,dynamic>>>`      | Atrapar errores de transporte y mapear payloads a `ErrorItem`.       |
| `RepositoryHttpRequest`     | `Either<ErrorItem, Map>`       | `Either<ErrorItem, ModelConfigHttpRequest>`           | Convertir JSON + metadata en modelo de dominio (config de request).  |
| UseCases HTTP               | `uri` + parámetros             | `Either<ErrorItem, ModelConfigHttpRequest>`           | API de alto nivel orientada al dominio.                              |
| `FacadeHttpRequestUsecases` | usecases                       | mismos `Either`                                       | Agrupar todos los UseCases HTTP en un solo objeto.                   |
| `BlocHttpRequest`           | llamadas a `get/post/…`        | `Set<String>` (peticiones activas) + `Future<Either>` | Saber qué requests están en curso y liberar ese estado al finalizar. |

---

## 3. Modelos clave

### 3.1 `ModelConfigHttpRequest`

`RepositoryHttpRequestImpl` devuelve siempre un `ModelConfigHttpRequest` en el `Right` del `Either`:

* Contiene:

    * `method: HttpMethodEnum`
    * `uri: Uri`
    * `headers: Map<String, String>`
    * `body`: opcional (según método)
    * `timeout: Duration?`
    * `metadata: Map<String, dynamic>`

* Es la **foto de la configuración** utilizada para la llamada (útil para):

    * Logging / telemetry.
    * Reintentos (`UsecaseHttpRequestRetry`).
    * Auditoría.

### 3.2 `ErrorItem` y `Either`

Todas las fallas llegan al dominio como:

```dart
Either<ErrorItem, ModelConfigHttpRequest>
```

* `Left(ErrorItem)`: fallo de transporte, de backend, negocio, etc.
* `Right(ModelConfigHttpRequest)`: la llamada fue considerada exitosa (a nivel de transporte y convención de payload).

Los errores HTTP/Red más comunes están definidos como constantes (`kHttpTimeoutErrorItem`, `kHttpNoConnectionErrorItem`, `kHttpServerErrorItem`, etc.) y son usados por `DefaultHttpErrorMapper`.

---

## 4. `BlocHttpRequest`: orquestador de peticiones activas

### 4.1 ¿Qué hace?

* Mantiene un `BlocGeneral<Set<String>>` con los `requestKey` **actualmente activos**.
* Expone:

```
Set<String> get activeRequests;
Stream<Set<String>> get stream;
bool isActive(String requestKey);

void clear(String requestKey);
void clearAll();

Future<Either<ErrorItem, ModelConfigHttpRequest>> get(...);
Future<Either<ErrorItem, ModelConfigHttpRequest>> post(...);
Future<Either<ErrorItem, ModelConfigHttpRequest>> put(...);
Future<Either<ErrorItem, ModelConfigHttpRequest>> delete(...);
Future<Either<ErrorItem, ModelConfigHttpRequest>> retry(...);
```

* Para wiring adicional:

```dart
void addFunctionToProcessActiveRequestsOnStream(
  String key,
  void Function(Set<String> active) function, [
  bool executeNow = false,
]);

void deleteFunctionToProcessActiveRequestsOnStream(String key);

bool containsKeyFunction(String key);
```

### 4.2 ¿Qué **no** hace?

* **No** guarda los resultados finales (ni los `ErrorItem`).
* **No** decide qué hacer con el error (eso es responsabilidad de los BLoCs de features / UI).
* **No** modela estados intermedios (loading, success, failure) por request; solo sabe si un `requestKey` está activo o no.

### 4.3 Ciclo de vida típico (GET)

1. `BlocHttpRequest.get(requestKey: 'user.fetchMe', uri: ...)` es invocado.
2. `_markActive('user.fetchMe')` agrega el key al set interno.
3. Se delega a `FacadeHttpRequestUsecases.get` → Repository → Gateway → Service.
4. Cuando el `Future` se resuelve:

    * Se obtiene `Either<ErrorItem, ModelConfigHttpRequest>`.
    * `_markInactive('user.fetchMe')` lo elimina del set activo.
    * Se retorna el `Either` al llamador.

La UI, al escuchar `stream`, puede mostrar loaders globales o paneles de estado en función de `activeRequests`.

---

## 5. Fake HTTP para desarrollo y pruebas

### 5.1 `FakeHttpRequestConfig`

Permite configurar el comportamiento del `FakeHttpRequest`:

```dart
const FakeHttpRequestConfig httpConfig = FakeHttpRequestConfig(
  latency: Duration(milliseconds: 800), // Latencia artificial global

  // Respuestas simuladas por ruta: "METHOD <uri.toString()>".
  cannedResponses: <String, Map<String, dynamic>>{
    'GET https://example.com/profile': FakeHttpRequestConfig.cannedHttpResponse(
      method: HttpMethodEnum.get,
      uri: Uri.parse('https://example.com/profile'),
      statusCode: 200,
      headers: const <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
      body: const <String, dynamic>{
        'data': <String, dynamic>{
          'name': 'Alice',
          'role': 'student',
        },
      },
      metadata: const <String, dynamic>{'requestId': 'req-123'},
      timeout: const Duration(seconds: 5),
    ),
    'POST https://example.com/login': FakeHttpRequestConfig.cannedHttpResponse(
      method: HttpMethodEnum.post,
      uri: Uri.parse('https://example.com/login'),
      statusCode: 401,
      reasonPhrase: 'Unauthorized',
      body: const <String, dynamic>{
        'error': <String, dynamic>{
          'code': 'AUTH_FAILED',
          'message': 'Usuario o contraseña inválidos',
        },
      },
    ),
    'DELETE https://example.com/session': FakeHttpRequestConfig.cannedHttpResponse(
      method: HttpMethodEnum.delete,
      uri: Uri.parse('https://example.com/session'),
      body: const <String, dynamic>{
        'deleted': true,
      },
    ),
  },

  // Rutas que fuerzan errores de transporte.
  errorRoutes: <String, String>{
    // Simula un timeout de transporte (TimeoutException).
    'GET https://example.com/slow-timeout': 'timeout',

    // Simula falta de conexión de red (SocketException).
    'GET https://example.com/offline': 'offline',

    // Cualquier otro string se propaga como StateError(message).
    // 'GET https://example.com/unexpected': 'unexpected_state',
  },

  // Opcionales:
  // cannedConfigs: <String, ModelConfigHttpRequest>{},
);
```

> `cannedHttpResponse` asegura que cada payload contenga el mismo shape que se obtendría al procesar un `http.Response` serializado: `method`, `uri`, `statusCode`, `reasonPhrase`, `headers`, `body`, `metadata`, `timeout` (ms) y las banderas `fake/source`.
> El `FakeHttpRequest` normaliza internamente estos campos para que el `GatewayHttpRequest` y el `RepositoryHttpRequest` puedan:
>
> * Inspeccionar `statusCode` / `reasonPhrase`.
> * Reconstruir `ModelConfigHttpRequest.timeout` desde el campo `timeout` (milisegundos).

Luego se instancia el service:

```dart
final ServiceHttpRequest service = FakeHttpRequest(config: httpConfig);
```

### 5.2 Comportamiento de errores simulados

`FakeHttpRequest` interpreta las entradas de `errorRoutes` así:

* Si el valor es `'timeout'` → lanza un `TimeoutException('Simulated HTTP timeout for <key>')`.
* Si el valor es `'offline'` → lanza un `SocketException('Simulated offline mode')`.
* Para cualquier otro valor → lanza un `StateError(message)` con el texto configurado.

Esto permite:

* Probar el mapeo de timeouts (`kHttpTimeoutErrorItem`).
* Probar fallos de red/offline (`kHttpNoConnectionErrorItem`).
* Probar errores genéricos de transporte/backend mediante `StateError`.

### 5.3 Echo por defecto

Cuando una ruta **no** está registrada en `cannedResponses` ni en `cannedConfigs` y tampoco aparece en `errorRoutes`, `FakeHttpRequest` devuelve un **payload de eco**:

```
<Map<String, dynamic>>{
  'method': 'GET' | 'POST' | ...,
  'uri': uri.toString(),
  'headers': <String, String>{...} // o vacío,
  'body': body,                   // solo para métodos con body,
  'timeoutMs': timeout?.inMilliseconds,
  'metadata': metadata,
  'fake': true,
  'source': 'FakeHttpRequest',
}
```

En particular, para `GET`:

* La firma de `get` **no acepta `body` de request**, por lo que el eco tendrá `body: null`.
* No se incluye `statusCode` ni `reasonPhrase` (no se simula una respuesta HTTP completa).

> Recomendación: usa el echo solo para *smoke tests* rápidos (ver que el wiring funciona).
> Para tests que validen comportamiento HTTP real (códigos de estado, errores de negocio, etc.) registra siempre la ruta en `cannedResponses` o `cannedConfigs`.

---

## 6. Mapeo de errores HTTP (`DefaultHttpErrorMapper`)

`GatewayHttpRequestImpl` recibe un `ErrorMapper`. La implementación recomendada para HTTP es:

```dart
final GatewayHttpRequest gateway = GatewayHttpRequestImpl(
  service: service,
  errorMapper: const DefaultHttpErrorMapper(),
);
```

Características de `DefaultHttpErrorMapper`:

* Envuelve a `DefaultErrorMapper` (genérico) y agrega contexto HTTP (`meta['transport'] = 'http'`).
* Casos especiales:

    * `TimeoutException` → `HTTP_TIMEOUT` (`kHttpTimeoutErrorItem`).
    * `SocketException` (ej. `'offline'` en `errorRoutes`) → `HTTP_NO_CONNECTION` (`kHttpNoConnectionErrorItem`).
    * Payloads con `statusCode` / `httpStatus` → ajusta `code` según la tabla estándar:

| Status | `ErrorItem.code`         | Recom. UI                               |
|--------|--------------------------|-----------------------------------------|
| 400    | `HTTP_BAD_REQUEST`       | Revisar inputs; mensaje de validación.  |
| 401    | `HTTP_UNAUTHORIZED`      | Forzar login / renov. credenciales.     |
| 403    | `HTTP_FORBIDDEN`         | Mostrar “no tienes permisos”.           |
| 404    | `HTTP_NOT_FOUND`         | Avisar recurso no disponible.           |
| 409    | `HTTP_CONFLICT`          | Mostrar conflicto (ej. versión/estado). |
| 429    | `HTTP_TOO_MANY_REQUESTS` | Mostrar rate limit, sugerir reintento.  |
| 5xx    | `HTTP_SERVER_ERROR`      | Modal de error servidor + reintento.    |

---

## 7. Demo completo: `HttpRequestDemoApp`

Este demo minimalista muestra el flujo completo:

* `FakeHttpRequest` con latencia.
* `GatewayHttpRequestImpl` + `DefaultHttpErrorMapper`.
* `RepositoryHttpRequestImpl`.
* `FacadeHttpRequestUsecases`.
* `BlocHttpRequest` como orquestador.
* UI Flutter con:

    * Loader global en AppBar.
    * Panel de peticiones activas.
    * Resultado en texto (`ErrorItem` vs `ModelConfigHttpRequest`).

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  runApp(const HttpRequestDemoApp());
}

/// Demo minimalista del flujo HTTP transversal de jocaagura_domain.
///
/// Muestra:
/// - Cómo cablear Service → Gateway → Repository → Usecases → Facade → BlocHttpRequest.
/// - Cómo lanzar GET/POST/DELETE y observar:
///   - El set de peticiones activas.
///   - El resultado (ErrorItem vs ModelConfigHttpRequest).
class HttpRequestDemoApp extends StatefulWidget {
  const HttpRequestDemoApp({super.key});

  @override
  State<HttpRequestDemoApp> createState() => _HttpRequestDemoAppState();
}

class _HttpRequestDemoAppState extends State<HttpRequestDemoApp> {
  late final BlocHttpRequest _blocHttpRequest;
  StreamSubscription<Set<String>>? _activeSub;
  Set<String> _active = <String>{};
  Either<ErrorItem, ModelConfigHttpRequest>? _lastResult;

  @override
  void initState() {
    super.initState();

    // 1) Service: frontera con el mundo externo.
    const FakeHttpRequestConfig httpConfig = FakeHttpRequestConfig(
      latency: Duration(milliseconds: 800),
      cannedResponses: <String, Map<String, dynamic>>{
        'GET https://example.com/profile': FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://example.com/profile'),
          statusCode: 200,
          headers: const <String, String>{
            'content-type': 'application/json; charset=utf-8',
          },
          body: const <String, dynamic>{
            'data': <String, dynamic>{
              'name': 'Alice',
              'role': 'student',
            },
          },
          metadata: const <String, dynamic>{'requestId': 'req-123'},
          timeout: const Duration(seconds: 5),
        ),
        'POST https://example.com/login': FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.post,
          uri: Uri.parse('https://example.com/login'),
          statusCode: 401,
          reasonPhrase: 'Unauthorized',
          body: const <String, dynamic>{
            'error': <String, dynamic>{
              'code': 'AUTH_FAILED',
              'message': 'Usuario o contraseña inválidos',
            },
          },
        ),
        'DELETE https://example.com/session': FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.delete,
          uri: Uri.parse('https://example.com/session'),
          body: const <String, dynamic>{
            'deleted': true,
          },
        ),
      },
      errorRoutes: <String, String>{
        'GET https://example.com/slow-timeout': 'timeout',
        'GET https://example.com/offline': 'offline',
      },
    );

    final ServiceHttpRequest service = FakeHttpRequest(config: httpConfig);

    // 2) Gateway: mapea excepciones/payload a ErrorItem.
    final GatewayHttpRequest gateway = GatewayHttpRequestImpl(
      service: service,
      errorMapper: const DefaultHttpErrorMapper(),
    );

    // 3) Repository: devuelve ModelConfigHttpRequest como resultado de dominio.
    final RepositoryHttpRequest repository = RepositoryHttpRequestImpl(gateway);

    // 4) Usecases + fachada.
    final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
      get: UsecaseHttpRequestGet(repository),
      post: UsecaseHttpRequestPost(repository),
      put: UsecaseHttpRequestPut(repository),
      delete: UsecaseHttpRequestDelete(repository),
      retry: UsecaseHttpRequestRetry(repository),
    );

    // 5) BlocHttpRequest: orquestador centralizado.
    _blocHttpRequest = BlocHttpRequest(facade);

    // 6) Escuchamos el set de peticiones activas.
    _activeSub = _blocHttpRequest.stream.listen((Set<String> active) {
      setState(() => _active = active);
    });
  }

  @override
  void dispose() {
    _activeSub?.cancel();
    _blocHttpRequest.dispose();
    super.dispose();
  }

  Future<void> _doGetProfile() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.get(
      requestKey: 'demo.getProfile',
      uri: Uri.parse('https://example.com/profile'),
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'getProfile',
      },
    );
    setState(() => _lastResult = result);
  }

  Future<void> _doPostLogin() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.post(
      requestKey: 'demo.postLogin',
      uri: Uri.parse('https://example.com/login'),
      body: <String, dynamic>{
        'username': 'demo',
        'password': 'wrong',
      },
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'login',
      },
    );
    setState(() => _lastResult = result);
  }

  Future<void> _doDeleteSession() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.delete(
      requestKey: 'demo.deleteSession',
      uri: Uri.parse('https://example.com/session'),
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'logout',
      },
    );
    setState(() => _lastResult = result);
  }

  String _formatResult() {
    final Either<ErrorItem, ModelConfigHttpRequest>? r = _lastResult;
    if (r == null) {
      return 'Sin resultado aún. Toca un botón para hacer una petición.';
    }

    return r.fold(
      (ErrorItem e) => '❌ ErrorItem:\n'
          'code: ${e.code}\n'
          'title: ${e.title}\n'
          'description: ${e.description}\n'
          'meta: ${e.meta}',
      (ModelConfigHttpRequest cfg) => '✅ ModelConfigHttpRequest:\n'
          'method: ${cfg.method.name}\n'
          'uri: ${cfg.uri}\n'
          'headers: ${cfg.headers}\n'
          'timeout: ${cfg.timeout}\n'
          'metadata: ${cfg.metadata}\n\n'
          'toJson():\n${cfg.toJson()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTTP Request Demo – jocaagura_domain',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HTTP Request Demo'),
          actions: <Widget>[
            if (_active.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(child: _GlobalLoadingDot()),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _ActiveRequestsPanel(active: _active),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: _doGetProfile,
                      child: const Text('GET /profile (ok)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _doPostLogin,
                      child: const Text('POST /login (error)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: _doDeleteSession,
                      child: const Text('DELETE /session (ok)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _blocHttpRequest.clearAll,
                      child: const Text('Limpiar activos'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Text(
                        _formatResult(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const _HelperNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveRequestsPanel extends StatelessWidget {
  const _ActiveRequestsPanel({required this.active});

  final Set<String> active;

  @override
  Widget build(BuildContext context) {
    final bool hasActive = active.isNotEmpty;
    final String text =
        hasActive ? 'Peticiones activas: ${active.join(', ')}' : 'Sin peticiones activas';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasActive
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.94)
            : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Icon(
              hasActive ? Icons.cloud_upload : Icons.cloud_done,
              size: 20,
              color: hasActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalLoadingDot extends StatefulWidget {
  const _GlobalLoadingDot();

  @override
  State<_GlobalLoadingDot> createState() => _GlobalLoadingDotState();
}

class _GlobalLoadingDotState extends State<_GlobalLoadingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(
        Icons.circle,
        size: 10,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _HelperNote extends StatelessWidget {
  const _HelperNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Tip: En producción, reemplaza el FakeServiceHttpRequest por tu client real.\n'
      'Este ejemplo solo muestra el flujo transversal y el rol de BlocHttpRequest.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 11),
    );
  }
}
```

---

## 8. Checklist de integración en una app real

1. **Implementar `ServiceHttpRequest`** usando tu cliente favorito (`http`, `dio`, etc.).
2. **Instanciar `GatewayHttpRequestImpl`** con `DefaultHttpErrorMapper` o tu mapper custom.
3. **Usar `RepositoryHttpRequestImpl`** como entry point de dominio.
4. **Construir `FacadeHttpRequestUsecases`** con los UseCases estándar.
5. **Crear un único `BlocHttpRequest`** y compartirlo (por ejemplo, vía `InheritedWidget`, `Provider`, `AppManager`).
6. **En los BLoCs de features**:

    * Llamar a `_blocHttpRequest.get/post/...` con un `requestKey` semántico.
    * Usar el `Either` para decidir UI/estado local.
7. **En la UI global**:

    * Escuchar `blocHttpRequest.stream` para loaders, badges de red, etc.
    * Usar `clear` / `clearAll` solo para recuperar estados atípicos (bugs, cancelaciones manuales).

> **Nota importante (echo por defecto):**
> Cuando una ruta **no** está registrada en `cannedResponses` ni en `cannedConfigs`, `FakeHttpRequest` devuelve un **echo** de la llamada en lugar de una respuesta HTTP completa.
> Ese payload incluye `method`, `uri`, `headers`, `body`, `metadata`, `timeoutMs`, `fake` y `source`, pero **no** contiene necesariamente `statusCode` ni `reasonPhrase`.
> Si necesitas probar un `body` de respuesta o inspeccionar `statusCode`, debes registrar la ruta en `cannedResponses` o `cannedConfigs`.
