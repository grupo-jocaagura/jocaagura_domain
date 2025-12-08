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

    // 1) Service: frontera con el mundo externo
    // En tu initState (antes de crear el Gateway):

    final FakeHttpRequestConfig httpConfig = FakeHttpRequestConfig(
      // Latencia artificial para que se note el loader global.
      latency: const Duration(milliseconds: 800),

      // Respuestas simuladas por ruta (METHOD + espacio + uri.toString()).
      cannedResponses: <String, Map<String, dynamic>>{
        'GET https://example.com/profile':
            FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://example.com/profile'),
          body: const <String, dynamic>{
            'data': <String, dynamic>{
              'name': 'Alice',
              'role': 'student',
            },
          },
          metadata: const <String, dynamic>{'requestId': 'req-profile-200'},
          timeout: const Duration(seconds: 5),
        ),
        'GET https://example.com/profile-pending':
            FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://example.com/profile-pending'),
          statusCode: 202,
          reasonPhrase: 'Accepted',
          body: const <String, dynamic>{
            'data': <String, dynamic>{
              'status': 'pending_verification',
              'etaSeconds': 30,
            },
          },
        ),
        'POST https://example.com/login':
            FakeHttpRequestConfig.cannedHttpResponse(
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
        'POST https://example.com/form-invalid':
            FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.post,
          uri: Uri.parse('https://example.com/form-invalid'),
          statusCode: 400,
          reasonPhrase: 'Bad Request',
          body: const <String, dynamic>{
            'error': <String, dynamic>{
              'code': 'VALIDATION_ERROR',
              'fields': <String, String>{
                'email': 'Formato inválido',
              },
            },
          },
        ),
        'GET https://example.com/admin':
            FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://example.com/admin'),
          statusCode: 403,
          reasonPhrase: 'Forbidden',
          body: const <String, dynamic>{
            'error': <String, dynamic>{
              'code': 'NOT_ALLOWED',
              'message': 'Rol insuficiente para acceder al recurso',
            },
          },
        ),
        'GET https://example.com/missing':
            FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://example.com/missing'),
          statusCode: 404,
          reasonPhrase: 'Not Found',
          body: const <String, dynamic>{
            'error': <String, dynamic>{
              'code': 'NOT_FOUND',
              'message': 'El recurso solicitado no existe',
            },
          },
        ),
        'POST https://example.com/orders':
            FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.post,
          uri: Uri.parse('https://example.com/orders'),
          statusCode: 409,
          reasonPhrase: 'Conflict',
          body: const <String, dynamic>{
            'error': <String, dynamic>{
              'code': 'ORDER_IN_PROGRESS',
              'message': 'Ya existe una orden en curso para este usuario',
            },
          },
        ),
        'GET https://example.com/rate-limit':
            FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://example.com/rate-limit'),
          statusCode: 429,
          reasonPhrase: 'Too Many Requests',
          body: const <String, dynamic>{
            'error': <String, dynamic>{
              'code': 'RATE_LIMITED',
              'retryAfterSeconds': 60,
            },
          },
        ),
        'PUT https://example.com/profile':
            FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.put,
          uri: Uri.parse('https://example.com/profile'),
          statusCode: 500,
          reasonPhrase: 'Server Error',
          body: const <String, dynamic>{
            'error': <String, dynamic>{
              'code': 'INTERNAL_ERROR',
              'message': 'Ocurrió un fallo inesperado procesando el perfil',
            },
          },
        ),
        'DELETE https://example.com/session':
            FakeHttpRequestConfig.cannedHttpResponse(
          method: HttpMethodEnum.delete,
          uri: Uri.parse('https://example.com/session'),
          body: const <String, dynamic>{
            'deleted': true,
          },
        ),
      },

      // Para este demo no necesitamos preconfigurar ModelConfigHttpRequest
      // ni rutas que lancen excepciones; dejamos los defaults:
      // cannedConfigs: const <String, ModelConfigHttpRequest>{},
      // errorRoutes: const <String, String>{},
    );

// Luego tu service queda así:
    final ServiceHttpRequest service = FakeHttpRequest(config: httpConfig);

    // 2) Gateway: mapea excepciones/payload a ErrorItem
    final GatewayHttpRequest gateway = GatewayHttpRequestImpl(
      service: service,
      errorMapper: const DefaultErrorMapper(),
    );

    // 3) Repository: devuelve ModelConfigHttpRequest como resultado de dominio
    final RepositoryHttpRequest repository = RepositoryHttpRequestImpl(
      gateway,
    );

    // 4) Usecases + fachada
    final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
      get: UsecaseHttpRequestGet(repository),
      post: UsecaseHttpRequestPost(repository),
      put: UsecaseHttpRequestPut(repository),
      delete: UsecaseHttpRequestDelete(repository),
      retry: UsecaseHttpRequestRetry(repository),
    );

    // 5) BlocHttpRequest: orquestador centralizado
    _blocHttpRequest = BlocHttpRequest(facade);

    // 6) Escuchamos el set de peticiones activas
    _activeSub = _blocHttpRequest.stream.listen((Set<String> active) {
      setState(() {
        _active = active;
      });
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

  Future<void> _doGetProfilePending() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.get(
      requestKey: 'demo.getProfilePending',
      uri: Uri.parse('https://example.com/profile-pending'),
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'getProfilePending',
      },
    );
    setState(() => _lastResult = result);
  }

  Future<void> _doGetAdminForbidden() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.get(
      requestKey: 'demo.getAdminForbidden',
      uri: Uri.parse('https://example.com/admin'),
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'getAdminForbidden',
      },
    );
    setState(() => _lastResult = result);
  }

  Future<void> _doGetMissingResource() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.get(
      requestKey: 'demo.getMissing',
      uri: Uri.parse('https://example.com/missing'),
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'getMissing',
      },
    );
    setState(() => _lastResult = result);
  }

  Future<void> _doGetRateLimited() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.get(
      requestKey: 'demo.getRateLimited',
      uri: Uri.parse('https://example.com/rate-limit'),
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'getRateLimited',
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

  Future<void> _doPostFormInvalid() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.post(
      requestKey: 'demo.postFormInvalid',
      uri: Uri.parse('https://example.com/form-invalid'),
      body: <String, dynamic>{
        'email': 'not-an-email',
      },
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'formInvalid',
      },
    );
    setState(() => _lastResult = result);
  }

  Future<void> _doPostOrderConflict() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.post(
      requestKey: 'demo.postOrderConflict',
      uri: Uri.parse('https://example.com/orders'),
      body: <String, dynamic>{
        'sku': 'SKU-123',
        'quantity': 1,
      },
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'orderConflict',
      },
    );
    setState(() => _lastResult = result);
  }

  Future<void> _doPutProfileServerError() async {
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _blocHttpRequest.put(
      requestKey: 'demo.putProfile',
      uri: Uri.parse('https://example.com/profile'),
      body: <String, dynamic>{
        'bio': 'New bio from demo',
      },
      metadata: <String, dynamic>{
        'feature': 'demo',
        'operation': 'updateProfile',
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
      (ErrorItem e) => '❌ ErrorItem:\ncode: ${e.code}\n'
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

  Widget _scenarioButton(String label, Future<void> Function() action) {
    return SizedBox(
      width: 220,
      child: FilledButton(
        onPressed: () => action(),
        child: Text(
          label,
          textAlign: TextAlign.center,
        ),
      ),
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Escenarios HTTP estandarizados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _scenarioButton('GET /profile (200 OK)', _doGetProfile),
                  _scenarioButton(
                    'GET /profile-pending (202 Accepted)',
                    _doGetProfilePending,
                  ),
                  _scenarioButton(
                    'POST /login (401 Unauthorized)',
                    _doPostLogin,
                  ),
                  _scenarioButton(
                    'POST /form-invalid (400 Bad Request)',
                    _doPostFormInvalid,
                  ),
                  _scenarioButton(
                    'GET /admin (403 Forbidden)',
                    _doGetAdminForbidden,
                  ),
                  _scenarioButton(
                    'GET /missing (404 Not Found)',
                    _doGetMissingResource,
                  ),
                  _scenarioButton(
                    'POST /orders (409 Conflict)',
                    _doPostOrderConflict,
                  ),
                  _scenarioButton(
                    'GET /rate-limit (429 Too Many)',
                    _doGetRateLimited,
                  ),
                  _scenarioButton(
                    'PUT /profile (500 Server Error)',
                    _doPutProfileServerError,
                  ),
                  _scenarioButton('DELETE /session (200 OK)', _doDeleteSession),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _blocHttpRequest.clearAll,
                  child: const Text('Limpiar activos'),
                ),
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

/// Panel que muestra el set de peticiones activas.
class _ActiveRequestsPanel extends StatelessWidget {
  const _ActiveRequestsPanel({required this.active});

  final Set<String> active;

  @override
  Widget build(BuildContext context) {
    final bool hasActive = active.isNotEmpty;
    final String text = hasActive
        ? 'Peticiones activas: ${active.join(', ')}'
        : 'Sin peticiones activas';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasActive
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.94)
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.7),
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
