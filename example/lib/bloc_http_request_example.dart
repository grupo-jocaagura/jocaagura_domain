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

    const FakeHttpRequestConfig httpConfig = FakeHttpRequestConfig(
      // Latencia artificial para que se note el loader global.
      latency: Duration(milliseconds: 800),

      // Respuestas simuladas por ruta (METHOD + espacio + uri.toString()).
      cannedResponses: <String, Map<String, dynamic>>{
        'GET https://example.com/profile': <String, dynamic>{
          'ok': true,
          'name': 'Alice',
          'role': 'student',
        },
        'POST https://example.com/login': <String, dynamic>{
          'ok': false,
          'error': <String, dynamic>{
            'code': 'AUTH_FAILED',
            'message': 'Usuario o contraseña inválidos',
          },
        },
        'DELETE https://example.com/session': <String, dynamic>{
          'ok': true,
          'deleted': true,
        },
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
