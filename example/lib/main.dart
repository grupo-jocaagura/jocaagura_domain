import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// Abstraction to access a JSON-like WebSocket database (canvas domain).
///
/// - Uses Either con ErrorItem, ... for success/failure.
/// - Embeds the [docId] into the returned JSON under [idKey] (default: 'id').
/// - Maps thrown exceptions using [ErrorMapper].
abstract class GatewayWsDatabase {
  /// Reads a document by [docId]. Returns the raw JSON with [idKey] injected.
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String docId);

  /// Writes (create/update) a document. Returns the JSON considered authoritative:
  /// - if [readAfterWrite] is enabled, returns a fresh read;
  /// - otherwise returns the provided input (with [idKey] injected).
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    String docId,
    Map<String, dynamic> json,
  );

  /// Deletes a document. Returns [Unit] on success.
  Future<Either<ErrorItem, Unit>> delete(String docId);

  /// Watches a single document. Emits Either on each tick.
  /// - Right(json with [idKey])
  /// - Left(error) when the payload encodes a business error or on stream error
  ///   (the stream remains open if possible).
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch(String docId);

  void dispose();

  /// Cleans up resources related to [docId] (e.g. active listeners).
  void releaseDoc(String docId);

  /// Cleans up active watch on [docId], if any.
  void detachWatch(String docId);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: <Widget>[
          Text('Examples availables'),
          SizedBox(
            height: 16,
          ),
          _ListTile(
            label: 'UserModel',
            model: defaultUserModel,
          ),
          _ListTile(
            label: 'AddressModel',
            model: defaultAddressModel,
          ),
          _ListTile(
            label: 'StoreModel',
            model: defaultStoreModel,
          ),
          _NavigatorListTile(
            label: 'BlocSession demo',
            page: SessionDemoPage(),
          ),
          _NavigatorListTile(
            label: 'BlocWsDatabase demo',
            page: WsDatabaseUserDemoPage(),
          ),
          _NavigatorListTile(
            label: 'BlocConnectivity demo',
            page: ConnectivityDemoPage(),
          ),
          _NavigatorListTile(
            label: 'BlocLoading demo',
            page: BlocLoadingDemoPage(),
          ),
          _NavigatorListTile(
            label: 'BlocOnboarding demo',
            page: BlocOnboardingDemoPage(),
          ),
          _NavigatorListTile(
            label: 'BlocResponsive demo',
            page: BlocResponsiveDemoPage(),
          ),
        ],
      ),
    );
  }
}

class _NavigatorListTile extends StatelessWidget {
  const _NavigatorListTile({
    required this.label,
    required this.page,
  });

  final String label;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      leading: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => page,
          ),
        );
      },
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.label,
    required this.model,
  });

  final String label;
  final Model model;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        model.toString(),
      ),
    );
  }
}

class SessionDemoPage extends StatefulWidget {
  const SessionDemoPage({super.key});

  @override
  State<SessionDemoPage> createState() => _SessionDemoPageState();
}

class _SessionDemoPageState extends State<SessionDemoPage> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;

  late final ServiceSession _service;
  late final ErrorMapper _errorMapper;
  late final GatewayAuth _gateway;
  late final RepositoryAuth _repo;

  late final SessionUsecases _usecases;
  late final BlocSession _bloc;

  @override
  void initState() {
    super.initState();

    _emailCtrl = TextEditingController(text: 'demo@x.com');
    _passCtrl = TextEditingController(text: 'secret');

    // Infra de ejemplo (puedes cambiar latency o arrancar logueado con initialUserJson)
    _service = FakeServiceSession(
      latency: const Duration(milliseconds: 250),
      // initialUserJson: { ... } // si quieres arrancar logueado
    );

    // Ajusta estos nombres si en tu paquete son distintos
    _errorMapper = const DefaultErrorMapper();
    _gateway = GatewayAuthImpl(_service, errorMapper: _errorMapper);
    _repo = RepositoryAuthImpl(gateway: _gateway, errorMapper: _errorMapper);

    _usecases = SessionUsecases(
      logInUserAndPassword: LogInUserAndPasswordUsecase(_repo),
      logOutUsecase: LogOutUsecase(_repo),
      signInUserAndPassword: SignInUserAndPasswordUsecase(_repo),
      recoverPassword: RecoverPasswordUsecase(_repo),
      logInSilently: LogInSilentlyUsecase(_repo),
      loginWithGoogle: LoginWithGoogleUsecase(_repo),
      refreshSession: RefreshSessionUsecase(_repo),
      getCurrentUser: GetCurrentUserUsecase(_repo),
      watchAuthStateChangesUsecase: WatchAuthStateChangesUsecase(_repo),
    );

    _bloc = BlocSession(
      usecases: _usecases,
      authDebouncer: Debouncer(milliseconds: 250),
      refreshDebouncer: Debouncer(milliseconds: 250),
    );

    // Nos suscribimos a cambios del repo (no fuerza silent-login)
    _bloc.boot();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bloc.dispose();
    super.dispose();
  }

  Future<void> _handleEither<T>(
    Either<ErrorItem, T> r, {
    String success = 'OK',
  }) async {
    r.fold(
      (ErrorItem e) => _showSnack('${e.title} • ${e.code}'),
      (_) => _showSnack(success),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget _stateChip(SessionState s) {
    if (s is Authenticating) {
      return const Chip(label: Text('Authenticating'));
    }
    if (s is Refreshing) {
      return const Chip(label: Text('Refreshing'));
    }
    if (s is Authenticated) {
      return const Chip(label: Text('Authenticated'));
    }
    if (s is SessionError) {
      return Chip(label: Text('Error: ${s.message.code}'));
    }
    return const Chip(label: Text('Unauthenticated'));
    // Unauthenticated
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Demo')),
      body: StreamBuilder<SessionState>(
        stream: _bloc.sessionStream,
        initialData: const Unauthenticated(),
        builder: (BuildContext _, AsyncSnapshot<SessionState> snap) {
          final SessionState state = snap.data ?? const Unauthenticated();
          final UserModel current = _bloc.currentUser;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Row(
                children: <Widget>[
                  _stateChip(state),
                  const SizedBox(width: 12),
                  Text(_bloc.isAuthenticated ? 'signed in' : 'signed out'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Current user:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                current == defaultUserModel
                    ? '(defaultUserModel)'
                    : '${current.email}\nJWT: ${current.jwt}',
              ),
              const Divider(height: 32),

              // Email + password
              Text(
                'Email & Password',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      final Either<ErrorItem, UserModel> r = await _bloc.logIn(
                        email: _emailCtrl.text.trim(),
                        password: _passCtrl.text,
                      );
                      await _handleEither<UserModel>(r, success: 'Logged in!');
                    },
                    child: const Text('Log In'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final Either<ErrorItem, UserModel> r = await _bloc.signIn(
                        email: _emailCtrl.text.trim(),
                        password: _passCtrl.text,
                      );
                      await _handleEither<UserModel>(r, success: 'Signed up!');
                    },
                    child: const Text('Sign Up'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final Either<ErrorItem, void> r =
                          await _bloc.recoverPassword(
                        email: _emailCtrl.text.trim(),
                      );
                      await _handleEither<void>(r, success: 'Recovery sent!');
                    },
                    child: const Text('Recover'),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Social / session ops
              Text(
                'Session Ops',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () async {
                      final Either<ErrorItem, UserModel> r =
                          await _bloc.logInWithGoogle();
                      await _handleEither<UserModel>(r, success: 'Google OK!');
                    },
                    child: const Text('Google Login'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final Either<ErrorItem, UserModel>? r =
                          await _bloc.logInSilently();
                      if (r == null) {
                        _showSnack('No current session for silent login');
                        return;
                      }
                      await _handleEither<UserModel>(
                        r,
                        success: 'Silent login OK!',
                      );
                    },
                    child: const Text('Silent Login'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final Either<ErrorItem, UserModel>? r =
                          await _bloc.refreshSession();
                      if (r == null) {
                        _showSnack('No session to refresh');
                        return;
                      }
                      await _handleEither<UserModel>(r, success: 'Refreshed!');
                    },
                    child: const Text('Refresh'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final Either<ErrorItem, void>? r = await _bloc.logOut();
                      if (r == null) {
                        _showSnack('Already signed out');
                        return;
                      }
                      await _handleEither<void>(r, success: 'Logged out!');
                    },
                    child: const Text('Log Out'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await _bloc.boot();
                      _showSnack('Listening to authStateChanges...');
                    },
                    child: const Text('Reboot listener'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nota sobre configuración rápida del fake
              Text(
                'Tip: ajusta la latencia o arranca logueado usando FakeServiceSession(latency: ..., initialUserJson: ...)',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ErrorItemWidget extends StatefulWidget {
  const ErrorItemWidget({
    required this.state,
    required this.child,
    super.key,
    this.showAsSnackBar = true,
  });

  final Either<ErrorItem, Object> state;
  final Widget child;
  final bool showAsSnackBar;

  @override
  State<ErrorItemWidget> createState() => _ErrorItemWidgetState();
}

class _ErrorItemWidgetState extends State<ErrorItemWidget> {
  String? _lastFingerprint;

  @override
  void initState() {
    super.initState();
    _maybeNotifyError(widget.state);
  }

  @override
  void didUpdateWidget(covariant ErrorItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _maybeNotifyError(widget.state);
    }
  }

  void _maybeNotifyError(Either<ErrorItem, Object> either) {
    if (!either.isLeft) {
      return;
    }
    final ErrorItem e = (either as Left<ErrorItem, Object>).value;
    final String fp = '${e.code}:${e.description.hashCode}';
    if (_lastFingerprint == fp) {
      return;
    }
    _lastFingerprint = fp;

    if (widget.showAsSnackBar && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.title}: ${e.description}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Connectivity **Demo Page** — reference wiring for the full stack without external packages.
///
/// ### Purpose
/// - Show how UI consumes a **pure** `BlocConnectivity` that emits `Either<ErrorItem, ConnectivityModel>`.
/// - Demonstrate the **proposed flow** and separation of responsibilities (Clean Architecture):
///
/// ```text
/// UI → AppManager → Bloc → UseCase → Repository → Gateway → Service
/// ```
///
/// ### Design notes
/// - **The BLoC does not know about UI**: it never throws nor shows SnackBars.
/// - **Errors travel as domain data**: `Left(ErrorItem)`; the UI decides how to present them.
/// - We wrap the content in an `ErrorItemWidget` that centralizes UX for errors (SnackBar/Banner).
/// - This demo uses `FakeServiceConnectivity` for dev/testing. In production, replace it with a
///   real `ServiceConnectivity` backed by the platform (plugins/SDKs).
///
/// ### Lifecycle essentials
/// - Call `loadInitial()` once to fetch the first snapshot.
/// - Call `startWatching()` to subscribe to updates; `stopWatching()` on dispose/background.
/// - Always call `dispose()` on the BLoC and on the Service if it holds resources.
///
/// ### Why this matters
/// - Keeps **domain/UI decoupled**, simplifies testing, and prevents side-effects from leaking into logic.
/// - Uniform error semantics via `ErrorItem` across all modules in Jocaagura.
class ConnectivityDemoPage extends StatefulWidget {
  const ConnectivityDemoPage({super.key});
  static const String name = 'ConnectivityDemoPage';

  @override
  State<ConnectivityDemoPage> createState() => _ConnectivityDemoPageState();
}

class _ConnectivityDemoPageState extends State<ConnectivityDemoPage> {
  late final FakeServiceConnectivity _service;
  late final GatewayConnectivity _gateway;
  late final RepositoryConnectivity _repo;
  late final BlocConnectivity _bloc;

  ConnectivityModel _lastGood = const ConnectivityModel(
    connectionType: ConnectionTypeEnum.none,
    internetSpeed: 0,
  );

  @override
  void initState() {
    super.initState();
    // 1) Service (dev/test fake). In production: provide a real ServiceConnectivity
    _service = FakeServiceConnectivity(
      latencyConnectivity: const Duration(milliseconds: 80),
      latencySpeed: const Duration(milliseconds: 120),
      initial: const ConnectivityModel(
        connectionType: ConnectionTypeEnum.wifi,
        internetSpeed: 40,
      ),
    );
    // 2) Gateway: converts Service → raw payload (Map) and wraps exceptions as ErrorItem
    _gateway = GatewayConnectivityImpl(_service, const DefaultErrorMapper());
    // 3) Repository: maps payload → ConnectivityModel, detects business errors via ErrorMapper
    _repo = RepositoryConnectivityImpl(
      _gateway,
      errorMapper: const DefaultErrorMapper(),
    );
    // 4) Bloc: exposes Stream<Either<ErrorItem, ConnectivityModel>> to the UI (pure, no UI side-effects)
    _bloc = BlocConnectivity(
      watch: WatchConnectivityUseCase(_repo),
      snapshot: GetConnectivitySnapshotUseCase(_repo),
      checkType: CheckConnectivityTypeUseCase(_repo),
      checkSpeed: CheckInternetSpeedUseCase(_repo),
    );
    // Fetch initial snapshot once
    _bloc.loadInitial();
    // Start continuous updates — remember to stop on dispose in real screens
    _bloc.startWatching();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connectivity Demo')),
      body: StreamBuilder<Either<ErrorItem, ConnectivityModel>>(
        stream: _bloc.stream,
        initialData: _bloc.value,
        builder: (
          BuildContext context,
          AsyncSnapshot<Either<ErrorItem, ConnectivityModel>> snap,
        ) {
          // Either coming from the BLoC (no exceptions thrown)
          final Either<ErrorItem, ConnectivityModel> either =
              snap.data ?? _bloc.value;
          final ConnectivityModel m = either.isRight
              ? (either as Right<ErrorItem, ConnectivityModel>).value
              : _lastGood; // keep last good model when Left

          if (either.isRight) {
            _lastGood = (either as Right<ErrorItem, ConnectivityModel>).value;
          }

          // Handle Either<ErrorItem, ConnectivityModel> from the BLoC:
          // - Right → render UI with latest ConnectivityModel
          // - Left  → ErrorItemWidget emits UX (SnackBar/Banner) but we keep last good UI state
          return ErrorItemWidget(
            state: either as Either<ErrorItem, Object>,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Type:  ${m.connectionType.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Speed: ${m.internetSpeed.toStringAsFixed(1)} Mbps'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () => _service
                            .simulateConnection(ConnectionTypeEnum.none),
                        child: const Text('Go Offline'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service
                            .simulateConnection(ConnectionTypeEnum.wifi),
                        child: const Text('Wi‑Fi'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service
                            .simulateConnection(ConnectionTypeEnum.mobile),
                        child: const Text('Mobile'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.simulateSpeed(
                          (((m.internetSpeed + 10).clamp(0.0, 9999.0)) as num)
                              .toDouble(),
                        ),
                        child: const Text('+10 Mbps'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.simulateSpeed(
                          (((m.internetSpeed - 10).clamp(0.0, 9999.0)) as num)
                              .toDouble(),
                        ),
                        child: const Text('−10 Mbps'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.startSpeedJitter(),
                        child: const Text('Start Jitter'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.stopSpeedJitter(),
                        child: const Text('Stop Jitter'),
                      ),
                      ElevatedButton(
                        onPressed: _bloc.refreshType,
                        child: const Text('Refresh Type'),
                      ),
                      ElevatedButton(
                        onPressed: _bloc.refreshSpeed,
                        child: const Text('Refresh Speed'),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          _service.simulateErrorOnCheckConnectivityOnce();
                          _bloc.refreshType();
                        },
                        child: const Text('Sim error: check type'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _service.simulateErrorOnCheckSpeedOnce();
                          _bloc.refreshSpeed();
                        },
                        child: const Text('Sim error: check speed'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _service.simulateStreamErrorOnce();
                          _service.simulateSpeed(
                            m.internetSpeed + 1,
                          ); // trigger next stream event
                        },
                        child: const Text('Sim error: stream'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BlocResponsiveDemoPage extends StatefulWidget {
  /// Permite inyectar una instancia existente (p. ej. desde AppManager).
  /// Si viene null, la página crea y dispone su propio bloc.
  const BlocResponsiveDemoPage({super.key, this.injected});
  static const String name = 'BlocResponsiveDemoPage';

  final BlocResponsive? injected;

  @override
  State<BlocResponsiveDemoPage> createState() => _BlocResponsiveDemoPageState();
}

class _BlocResponsiveDemoPageState extends State<BlocResponsiveDemoPage> {
  late final BlocResponsive _bloc;
  late final bool _ownsBloc; // ¿Quién es dueño del ciclo de vida?

  bool _showGrid = true; // Muestra/oculta la superposición de columnas
  bool _simulateSize = false; // Activa el modo “simular tamaño”
  double _simWidth = 1024; // Ancho simulado
  double _simHeight = 720; // Alto simulado

  @override
  void initState() {
    super.initState();
    // 📦 Inyección opcional desde AppManager/configuración externa.
    if (widget.injected != null) {
      _bloc = widget.injected!;
      _ownsBloc = false; // No lo disponemos nosotros.
    } else {
      _bloc = BlocResponsive(); // Uso “standalone” para la demo.
      _ownsBloc = true; // Lo disponemos en dispose().
    }
  }

  @override
  void dispose() {
    // Si la UI creó el bloc, también debe disponerlo.
    if (_ownsBloc) {
      _bloc.dispose();
    }
    super.dispose();
  }

  /// Mantiene el bloc sincronizado con el tamaño actual.
  /// - En modo normal, usa `MediaQuery` a través de `setSizeFromContext`.
  /// - En modo simulado, empuja valores manuales con `setSizeForTesting`.
  void _syncSize(BuildContext context) {
    if (_simulateSize) {
      _bloc.setSizeForTesting(Size(_simWidth, _simHeight));
    } else {
      _bloc.setSizeFromContext(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📌 Importante: Sincroniza el tamaño DESPUÉS del frame para evitar
    // loops de rebuild (especialmente útil si llamas desde `build`).
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSize(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('BlocResponsive Demo'),
        actions: <Widget>[
          // Política de AppBar encapsulada en el bloc (presentación).
          // Si tu layout oculta la AppBar, `screenHeightWithoutAppbar` lo refleja.
          Row(
            children: <Widget>[
              const Text('Show AppBar', style: TextStyle(fontSize: 12)),
              Switch(
                value: _bloc.showAppbar,
                onChanged: (bool v) {
                  setState(() => _bloc.showAppbar = v);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),

      // Nos suscribimos al stream de tamaño de pantalla para actualizar métricas.
      body: StreamBuilder<Size>(
        stream: _bloc.appScreenSizeStream,
        initialData: _bloc.value,
        builder: (BuildContext context, AsyncSnapshot<Size> _) {
          // Re-sincroniza en cada rebuild significativo
          _syncSize(context);

          // 📐 Lee todas las métricas derivadas del bloc.
          final Size size = _bloc.size;
          final Size work = _bloc.workAreaSize;
          final int cols = _bloc.columnsNumber;
          final double margin = _bloc.marginWidth;
          final double gutter = _bloc.gutterWidth;
          final double colW = _bloc.columnWidth;
          final double drawerW = _bloc.drawerWidth;
          final ScreenSizeEnum device = _bloc.deviceType;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _DocCard(), // Guía en pantalla (qué hace y cómo se usa)
              const SizedBox(height: 12),

              // Controles de demo: grid overlay, simulación de tamaño (sliders)
              _ControlsCard(
                showGrid: _showGrid,
                simulateSize: _simulateSize,
                simWidth: _simWidth,
                simHeight: _simHeight,
                onToggleGrid: (bool v) => setState(() => _showGrid = v),
                onToggleSim: (bool v) {
                  setState(() {
                    _simulateSize = v;
                    _syncSize(context);
                  });
                },
                onWidthChanged: (double v) {
                  setState(() {
                    _simWidth = v;
                    _syncSize(context);
                  });
                },
                onHeightChanged: (double v) {
                  setState(() {
                    _simHeight = v;
                    _syncSize(context);
                  });
                },
              ),
              const SizedBox(height: 12),

              // Métricas “en vivo” para entender los cálculos de layout.
              _MetricsCard(
                device: device,
                size: size,
                work: work,
                cols: cols,
                margin: margin,
                gutter: gutter,
                colW: colW,
                drawer: drawerW,
                appBarHeight: _bloc.appBarHeight,
                heightWithoutAppBar: _bloc.screenHeightWithoutAppbar,
              ),
              const SizedBox(height: 12),

              // Vista previa de la grilla (columnas + gutters) respetando márgenes.
              _GridPreview(
                showGrid: _showGrid,
                cols: cols,
                margin: margin,
                gutter: gutter,
                columnWidth: colW,
                workArea: work,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Tarjeta con documentación en pantalla para el implementador.
/// Explica el propósito, el flujo y la forma recomendada de integración.
class _DocCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle s = Theme.of(context).textTheme.bodyMedium!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: s,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'How this demo works / Cómo funciona',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '1) The UI keeps the bloc in sync with the current viewport size.',
              ),
              Text(
                '   Use `setSizeFromContext(context)` in widgets, or `setSize(Size)` in headless tests.',
              ),
              SizedBox(height: 6),
              Text(
                '2) BlocResponsive computes device type, margins, gutters, columns and work area from the size and config.',
              ),
              Text(
                '   For desktop/TV it uses a percentage of the viewport as work area (config-driven).',
              ),
              SizedBox(height: 6),
              Text(
                '3) The grid preview draws columns respecting margins and gutters; useful to validate breakpoints.',
              ),
              SizedBox(height: 12),
              Text(
                'Clean Architecture: UI → AppManager → BlocResponsive (presentation infra).',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de controles de la demo.
/// - Muestra/oculta la grilla.
/// - Activa sliders para simular tamaños sin depender del dispositivo real.
class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    required this.showGrid,
    required this.simulateSize,
    required this.simWidth,
    required this.simHeight,
    required this.onToggleGrid,
    required this.onToggleSim,
    required this.onWidthChanged,
    required this.onHeightChanged,
  });

  final bool showGrid;
  final bool simulateSize;
  final double simWidth;
  final double simHeight;
  final ValueChanged<bool> onToggleGrid;
  final ValueChanged<bool> onToggleSim;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onHeightChanged;

  @override
  Widget build(BuildContext context) {
    final TextStyle s = Theme.of(context).textTheme.bodyMedium!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: s,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Controls / Controles',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Show grid overlay'),
                      value: showGrid,
                      onChanged: onToggleGrid,
                      dense: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Simulate size (sliders)'),
                      value: simulateSize,
                      onChanged: onToggleSim,
                      dense: true,
                    ),
                  ),
                ],
              ),

              // Sliders visibles solo si activamos el modo de simulación.
              if (simulateSize) ...<Widget>[
                const SizedBox(height: 8),
                const Text('Width'),
                Slider(
                  min: 320,
                  max: 2560,
                  divisions: 224, // paso ~10 px
                  label: simWidth.toStringAsFixed(0),
                  value: simWidth.clamp(320, 2560),
                  onChanged: onWidthChanged,
                ),
                const Text('Height'),
                Slider(
                  min: 480,
                  max: 1600,
                  divisions: 112,
                  label: simHeight.toStringAsFixed(0),
                  value: simHeight.clamp(480, 1600),
                  onChanged: onHeightChanged,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de métricas: muestra en vivo todos los cálculos que hace el bloc.
/// Útil para validar breakpoints y coherencia de grilla en QA/manual testing.
class _MetricsCard extends StatelessWidget {
  const _MetricsCard({
    required this.device,
    required this.size,
    required this.work,
    required this.cols,
    required this.margin,
    required this.gutter,
    required this.colW,
    required this.drawer,
    required this.appBarHeight,
    required this.heightWithoutAppBar,
  });

  final ScreenSizeEnum device;
  final Size size;
  final Size work;
  final int cols;
  final double margin;
  final double gutter;
  final double colW;
  final double drawer;
  final double appBarHeight;
  final double heightWithoutAppBar;

  @override
  Widget build(BuildContext context) {
    final TextStyle s = Theme.of(context).textTheme.bodyMedium!;
    final String deviceName = device.toString().split('.').last.toUpperCase();

    String fmtSize(Size x) =>
        '${x.width.toStringAsFixed(0)} × ${x.height.toStringAsFixed(0)}';
    String px(num v) => '${v.toStringAsFixed(0)} px';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: s,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Metrics / Métricas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('Device: $deviceName'),
              Text('Viewport size: ${fmtSize(size)}'),
              Text('Work area: ${fmtSize(work)}  (drawer: ${px(drawer)})'),
              Text('Columns: $cols  •  Column width: ${px(colW)}'),
              Text(
                'Margin width: ${px(margin)}  •  Gutter width: ${px(gutter)}',
              ),
              Text(
                'AppBar height: ${px(appBarHeight)}  •  Height w/o AppBar: ${px(heightWithoutAppBar)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vista previa de la grilla basada en las métricas del bloc.
/// Dibuja columnas y gutters respetando los márgenes; no usa LayoutBuilder
/// porque queremos que las medidas provengan del bloc (fuente de verdad).
class _GridPreview extends StatelessWidget {
  const _GridPreview({
    required this.showGrid,
    required this.cols,
    required this.margin,
    required this.gutter,
    required this.columnWidth,
    required this.workArea,
  });

  final bool showGrid;
  final int cols;
  final double margin;
  final double gutter;
  final double columnWidth;
  final Size workArea;

  @override
  Widget build(BuildContext context) {
    // Altura fija para visualizar sin depender del alto real del viewport.
    const double previewHeight = 180;

    // Construimos la fila: col, gutter, col, gutter, ...
    final List<Widget> rowChildren = <Widget>[];
    for (int i = 0; i < cols; i++) {
      rowChildren.add(
        Container(
          width: columnWidth,
          height: previewHeight,
          decoration: BoxDecoration(
            color: Colors.blueGrey.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.5)),
          ),
        ),
      );
      if (i < cols - 1) {
        rowChildren.add(SizedBox(width: gutter));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Grid preview / Vista de grilla',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // Contenedor ancho = workArea + márgenes a cada lado.
            // Esto permite ver claramente cómo influyen los márgenes globales.
            Container(
              width: workArea.width + margin * 2,
              constraints: const BoxConstraints(minHeight: previewHeight + 24),
              decoration: BoxDecoration(
                color: Colors.black12.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: margin),
                child: Stack(
                  children: <Widget>[
                    // Fondo “área de trabajo” para distinguir del viewport.
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // Fila de columnas + gutters (scroll horizontal por si el ancho no alcanza).
                    if (showGrid)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: rowChildren),
                        ),
                      ),

                    // Mensaje cuando se oculta la grilla.
                    if (!showGrid)
                      const Positioned.fill(
                        child: Center(
                          child: Text(
                            'Grid overlay disabled',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Demo page for `BlocOnboarding` with async `onEnter` returning `Either<ErrorItem, Unit>`.
///
/// ─────────────────────────────────────────────────────────────────────────────
/// PURPOSE / PROPÓSITO
/// - Orquestar un flujo de onboarding por pasos, donde cada paso puede ejecutar
///   un side-effect asíncrono (p.ej., pedir permisos, cargar configuración,
///   migraciones locales, fetch remoto inicial, aceptar Términos, etc.).
/// - `onEnter` devuelve Either:
///     • Right(Unit) → éxito; se **agenda** auto-avance si el paso lo define.
///     • Left(ErrorItem) → error de negocio; el flujo se **detiene** en el paso
///       y expone `state.error` para que la UI decida (retry/back/skip).
/// - Si `onEnter` **lanza** una excepción, `ErrorMapper.fromException` la
///   traduce a `ErrorItem` y el flujo se detiene en el paso (sin auto-avance).
///
/// ─────────────────────────────────────────────────────────────────────────────
/// ARCHITECTURE / ARQUITECTURA
/// UI → AppManager → BlocOnboarding → (use cases invocados dentro de onEnter)
/// *El BLoC no mapea dominio ni consume servicios directamente; solo orquesta.*
///
/// ─────────────────────────────────────────────────────────────────────────────
/// COMMON USE CASES / CASOS DE USO
/// 1) Permissions gate: solicitar permisos y continuar solo si son otorgados.
/// 2) Warm-up: precargar Remote Config / Feature Flags / tokens efímeros.
/// 3) Data seed/migrations: inicializar BD local o migrar esquemas.
/// 4) Legal gates: EULA/Privacy/Consent con persistencia y verificación.
/// 5) First-run checks: conectividad mínima, versión soportada, etc.
///
/// ─────────────────────────────────────────────────────────────────────────────
/// ERROR HANDLING / MANEJO DE ERRORES
/// - En fallos **esperados**: devuelve `Left(ErrorItem)` desde `onEnter`.
/// - En fallos **inesperados**: deja que lance → el BLoC usa `ErrorMapper`.
/// - La UI puede: mostrar el error, ofrecer `Retry onEnter`, `Back`, `Skip`.
/// - `retryOnEnter()` no cambia índice; limpia `state.error` y reejecuta el
///   `onEnter` del paso actual. Útil tras resolver la causa (p.ej., usuario
///   habilitó permisos en ajustes, restauró red, etc.).
///
/// ─────────────────────────────────────────────────────────────────────────────
/// TESTING TIPS
/// - Usa delays cortos (20-100ms) para comprobar auto-avance.
/// - Valida: Right → avanza; Left → no avanza + error; throw → mapeado.
/// - Prueba `retryOnEnter()` y navegación `back/next` cancelando timers.
///
/// ─────────────────────────────────────────────────────────────────────────────
class BlocOnboardingDemoPage extends StatefulWidget {
  const BlocOnboardingDemoPage({super.key, this.injected});
  static const String name = 'BlocOnboardingDemoPage';

  /// Optional injection of an existing BlocOnboarding (managed upstream).
  final BlocOnboarding? injected;

  @override
  State<BlocOnboardingDemoPage> createState() => _BlocOnboardingDemoPageState();
}

class _BlocOnboardingDemoPageState extends State<BlocOnboardingDemoPage> {
  late final BlocOnboarding _bloc;
  late final bool _ownsBloc;
  StreamSubscription<OnboardingState>? _sub;

  // Log en pantalla para visualizar el orden de eventos y estados.
  final List<String> _log = <String>[];

  // Simuladores:
  bool _failStep2AsLeft = false; // devuelve Left(ErrorItem) en paso 2
  bool _throwStep2 = false; // lanza excepción en paso 2 (ErrorMapper)

  // Helper para registrar mensajes en la UI.
  void _logMsg(String msg) {
    if (!mounted) {
      return;
    }
    setState(() => _log.add(msg));
  }

  @override
  void initState() {
    super.initState();
    // Preferido: inyectar desde AppManager. Si no hay, se crea localmente
    // (usando DefaultErrorMapper).
    _bloc = widget.injected ?? BlocOnboarding();
    _ownsBloc = widget.injected == null;

    _configureSteps();

    // Escucha del estado para feedback y para loguear transiciones.
    _sub = _bloc.stateStream.listen((OnboardingState s) {
      if (!mounted) {
        return;
      }
      _logMsg(
        'STATE → status=${s.status}, step=${s.stepIndex}/${s.totalSteps}, error=${s.error != null}',
      );
      if (s.status == OnboardingStatus.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding completed')),
        );
      } else if (s.status == OnboardingStatus.skipped) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding skipped')),
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (_ownsBloc) {
      _bloc.dispose();
    }
    super.dispose();
  }

  /// Define los pasos del onboarding. Reinvocar esta función cuando cambien
  /// flags de simulación para que los closures capturen el nuevo estado.
  void _configureSteps() {
    _bloc.configure(<OnboardingStep>[
      // STEP 1 — Welcome (Right + auto-advance)
      OnboardingStep(
        title: 'Welcome',
        description: 'Short tour starts here',
        onEnter: () async {
          _logMsg('onEnter: Welcome (step 1)');
          await Future<void>.delayed(const Duration(milliseconds: 120));
          return Right<ErrorItem, Unit>(
            Unit.value,
          ); // éxito → permitirá auto-avance
        },
        autoAdvanceAfter: const Duration(milliseconds: 900),
      ),

      // STEP 2 — Permissions (Left o throw según toggles)
      OnboardingStep(
        title: 'Permissions',
        description: 'Request minimal permissions',
        onEnter: () async {
          _logMsg('onEnter: Permissions (step 2)');
          await Future<void>.delayed(const Duration(milliseconds: 120));

          if (_throwStep2) {
            // Fallo inesperado → será mapeado por ErrorMapper
            throw StateError('Simulated thrown exception in step 2');
          }

          if (_failStep2AsLeft) {
            // Fallo esperado de negocio (no lanzar)
            return Left<ErrorItem, Unit>(
              const ErrorItem(
                title: 'Permissions required',
                code: 'PERM_DENIED',
                description: 'User denied permissions (simulated Left)',
                meta: <String, dynamic>{'source': 'demo'},
              ),
            );
          }

          return Right<ErrorItem, Unit>(Unit.value); // éxito
        },
        autoAdvanceAfter: const Duration(milliseconds: 900),
      ),

      // STEP 3 — Finish (Right sin auto-advance)
      OnboardingStep(
        title: 'Finish',
        description: 'You are all set',
        onEnter: () async {
          _logMsg('onEnter: Finish (step 3)');
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return Right<ErrorItem, Unit>(Unit.value);
        },
        // sin auto-avance: el usuario decide finalizar/omitir
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BlocOnboarding Demo (Either onEnter)')),
      body: StreamBuilder<OnboardingState>(
        stream: _bloc.stateStream,
        initialData: _bloc.state,
        builder: (BuildContext context, AsyncSnapshot<OnboardingState> snap) {
          final OnboardingState s = snap.data ?? OnboardingState.idle();
          final OnboardingStep? step = _bloc.currentStep;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _DocCardIntro(),
              const SizedBox(height: 12),

              // Simuladores de fallo en paso 2
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Simulators / Simuladores',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Fail step 2 as Left(ErrorItem)'),
                        value: _failStep2AsLeft,
                        onChanged: (bool v) {
                          setState(() => _failStep2AsLeft = v);
                          _configureSteps();
                        },
                      ),
                      SwitchListTile(
                        title: const Text(
                          'Throw in step 2 (mapped by ErrorMapper)',
                        ),
                        value: _throwStep2,
                        onChanged: (bool v) {
                          setState(() => _throwStep2 = v);
                          _configureSteps();
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tip: Enciende uno u otro (no ambos) para ver la diferencia entre Left(ErrorItem) '
                        'y una excepción mapeada por ErrorMapper.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              _ControlsRow(
                state: s,
                onStart: _bloc.start,
                onNext: _bloc.next,
                onBack: _bloc.back,
                onSkip: _bloc.skip,
                onComplete: _bloc.complete,
                onRetryOnEnter: _bloc.retryOnEnter,
                onClearError: () => _bloc.clearError(), // helper explícito
              ),

              const SizedBox(height: 12),

              // Panel de error (podrías cambiar por tu ErrorItemWidget si ya lo tienes)
              if (s.error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error: ${s.error?.title ?? ''} '
                            '${s.error?.code != null ? '(${s.error!.code})' : ''}\n'
                            '${s.error?.description ?? s.error.toString()}',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              _StateCard(state: s, step: step),
              const SizedBox(height: 12),

              _DocCardUseCases(),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Execution log / Registro de ejecución',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (_log.isEmpty) const Text('No events yet.'),
                      if (_log.isNotEmpty)
                        ..._log.map((String e) => Text('• $e')),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Card con una explicación introductoria y reglas clave.
class _DocCardIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle base = Theme.of(context).textTheme.bodyMedium!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: base,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'How it works / Cómo funciona',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Each step defines an optional `onEnter` side-effect returning `Either<ErrorItem, Unit>`.',
              ),
              Text(
                '• On Right(Unit): the step may auto-advance after its configured delay.',
              ),
              Text(
                '• On Left(ErrorItem): the flow stays on the current step and exposes `state.error`.',
              ),
              Text(
                '• If `onEnter` throws: `ErrorMapper.fromException` maps the exception to `ErrorItem`.',
              ),
              SizedBox(height: 12),
              Text(
                'Commands / Comandos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'start(), next(), back(), skip(), complete(), retryOnEnter(), clearError()',
              ),
              SizedBox(height: 12),
              Text(
                'Concurrency / Concurrencia',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Solo hay un timer de auto-avance activo. Cualquier comando cancela el timer en curso.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card con casos de uso y patrones recomendados.
class _DocCardUseCases extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle base = Theme.of(context).textTheme.bodyMedium!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: base,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Use cases & patterns / Casos de uso y patrones',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Permissions gate: ejecuta un caso de uso que solicite permisos; si el usuario niega → Left(ErrorItem); si acepta → Right(Unit).',
              ),
              Text(
                '• Warm-up (Remote Config / Flags): lee flags; en failure controlado → Left(ErrorItem) y ofrece retry.',
              ),
              Text(
                '• Migrations / Seed: corre migraciones locales; en error controlado → Left; en error inesperado → throw (ErrorMapper).',
              ),
              Text(
                '• Legal gates (EULA/Privacy): si el usuario no acepta → Left(ErrorItem).',
              ),
              Text(
                '• First-run network check: si no hay red mínima → Left para que la UI guíe al usuario.',
              ),
              SizedBox(height: 12),
              Text('UI tips', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '• Usa `retryOnEnter()` tras corregir la causa (p.ej., habilitar permisos).',
              ),
              Text('• Considera exponer botones Back/Skip según tu UX.'),
              Text(
                '• Puedes reemplazar el panel de error por tu `ErrorItemWidget` si ya lo tienes.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.state,
    required this.onStart,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onComplete,
    required this.onRetryOnEnter,
    required this.onClearError,
  });

  final OnboardingState state;
  final VoidCallback onStart;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onComplete;
  final VoidCallback onRetryOnEnter;
  final VoidCallback onClearError;

  @override
  Widget build(BuildContext context) {
    final bool running = state.status == OnboardingStatus.running;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        FilledButton(
          onPressed: running ? null : onStart,
          child: const Text('Start'),
        ),
        OutlinedButton(
          onPressed: running && state.stepIndex > 0 ? onBack : null,
          child: const Text('Back'),
        ),
        OutlinedButton(
          onPressed: running ? onNext : null,
          child: const Text('Next'),
        ),
        OutlinedButton(
          onPressed: running ? onSkip : null,
          child: const Text('Skip'),
        ),
        OutlinedButton(
          onPressed: running || state.totalSteps == 0 ? onComplete : null,
          child: const Text('Complete'),
        ),
        FilledButton.tonal(
          onPressed: running && state.error != null ? onRetryOnEnter : null,
          child: const Text('Retry onEnter'),
        ),
        OutlinedButton(
          onPressed: running && state.error != null ? onClearError : null,
          child: const Text('Clear error'),
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.state, required this.step});

  final OnboardingState state;
  final OnboardingStep? step;

  @override
  Widget build(BuildContext context) {
    final String statusText =
        state.status.toString().split('.').last.toUpperCase();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Status: $statusText',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('Steps: ${state.totalSteps}'),
              Text('Index: ${state.stepIndex}  (1-based: ${state.stepNumber})'),
              const SizedBox(height: 12),
              if (step != null) ...<Widget>[
                const Text(
                  'Current step',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text('• Title: ${step!.title}'),
                Text('• Description: ${step!.description ?? '-'}'),
                Text(
                  '• Auto-advance: ${step!.autoAdvanceAfter?.inMilliseconds ?? 0} ms',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Note: auto-advance occurs only after a successful onEnter (Right(Unit)).',
                ),
              ] else
                const Text('No active step'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Demo page for `BlocLoading`.
///
/// ## What this page shows
/// - **Single action**: uses `loadingWhile` to run one task with a min visible time,
///   demonstrating anti-flicker UX.
/// - **Queued actions (FIFO)**: uses `queueLoadingWhile` to run 3 tasks in sequence.
///   Each task sets a **progressive message** ("Step 1/3", "Step 2/3", "Step 3/3").
///
/// ## How to wire the Bloc
/// - Preferred: obtain it from your **AppManager** (UI → AppManager → Bloc).
/// - Alternative: inject via constructor or create a local instance (this demo supports both).
///
/// ## Concurrency semantics (important)
/// - `loadingMsgWithFuture`: ignores overlapping calls (visual + execution).
/// - `loadingWhile<T>`: if already loading, **does not override UI** but still **executes** the action and returns its result.
/// - `queueLoadingWhile<T>`: serializes tasks (FIFO). Each task shows its own message.
///
/// UI text is bilingual for clarity to implementers.
class BlocLoadingDemoPage extends StatefulWidget {
  /// Optional injection of an existing BlocLoading.
  const BlocLoadingDemoPage({super.key, this.injected});
  static const String name = 'BlocLoadingDemoPage';

  final BlocLoading? injected;

  @override
  State<BlocLoadingDemoPage> createState() => _BlocLoadingDemoPageState();
}

class _BlocLoadingDemoPageState extends State<BlocLoadingDemoPage> {
  late final BlocLoading _bloc;
  late final bool _ownsBloc;

  // Simple in-page log to visualize execution/order for the queue demo.
  final List<String> _log = <String>[];

  @override
  void initState() {
    super.initState();

    // Preferred (commented): obtain from AppManager when available in your app:
    // _bloc = AppManager.of(context).config.blocLoading; _ownsBloc = false;
    //
    // This demo supports injection or local creation for portability.
    if (widget.injected != null) {
      _bloc = widget.injected!;
      _ownsBloc = false; // lifecycle managed by the caller
    } else {
      _bloc = BlocLoading();
      _ownsBloc = true; // dispose when page is disposed
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.dispose();
    }
    super.dispose();
  }

  Future<void> _runSingleAction() async {
    // Example: single action using loadingWhile with anti-flicker minShow.
    final int result = await _bloc.loadingWhile<int>(
      'Loading single action… / Cargando acción única…',
      () async {
        // Simulate quick job; minShow will keep overlay stable
        await Future<void>.delayed(const Duration(milliseconds: 220));
        return 42;
      },
      minShow: const Duration(milliseconds: 480),
    );

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Single action done. Result = $result')),
    );
  }

  Future<void> _runQueuedActions() async {
    setState(() {
      _log.clear();
      _log.add('Queue started…');
    });

    // We queue 3 tasks. Each one sets its own message and simulates different durations.
    final Future<int> t1 = _bloc.queueLoadingWhile<int>(
      'Step 1/3 — Preparing… / Paso 1/3 — Preparando…',
      () async {
        setState(() => _log.add('Task 1 started'));
        await Future<void>.delayed(const Duration(milliseconds: 650));
        setState(() => _log.add('Task 1 finished'));
        return 1;
      },
      minShow: const Duration(milliseconds: 160),
    );

    final Future<int> t2 = _bloc.queueLoadingWhile<int>(
      'Step 2/3 — Processing… / Paso 2/3 — Procesando…',
      () async {
        setState(() => _log.add('Task 2 started'));
        await Future<void>.delayed(const Duration(milliseconds: 180));
        setState(() => _log.add('Task 2 finished'));
        return 2;
      },
      minShow: const Duration(milliseconds: 160),
    );

    final Future<int> t3 = _bloc.queueLoadingWhile<int>(
      'Step 3/3 — Finalizing… / Paso 3/3 — Finalizando…',
      () async {
        setState(() => _log.add('Task 3 started'));
        await Future<void>.delayed(const Duration(milliseconds: 320));
        setState(() => _log.add('Task 3 finished'));
        return 3;
      },
      minShow: const Duration(milliseconds: 160),
    );

    final List<int> results = await Future.wait(<Future<int>>[t1, t2, t3]);

    if (!mounted) {
      return;
    }
    setState(() => _log.add('Queue done. Results = $results'));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Queued actions completed (FIFO)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use two streams:
    // - isLoadingStream (bool) to drive the overlay cheaply with distinct()
    // - loadingMsgStream (String) to show the current message text
    return Scaffold(
      appBar: AppBar(title: const Text('BlocLoading Demo')),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              // In-screen documentation for implementers.
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'How this demo works / Cómo funciona esta demo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '1) Single action — uses `loadingWhile` with a minimal visible time (`minShow`) to avoid flicker.',
                      ),
                      Text(
                        '   • If another loading is already active, it does NOT override the UI but still executes the action and returns its result.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2) Queued actions — uses `queueLoadingWhile` to serialize three tasks (FIFO).',
                      ),
                      Text(
                        '   • Each task sets its own progressive message: "Step 1/3", "Step 2/3", "Step 3/3".',
                      ),
                      Text(
                        '   • The overlay remains visible while tasks run one after another.',
                      ),
                      SizedBox(height: 8),
                      Text('3) Streams used:'),
                      Text(
                        '   • `isLoadingStream` (bool) → drives the overlay efficiently via `.distinct()`.',
                      ),
                      Text(
                        '   • `loadingMsgStream` (String) → provides the current message text.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _runSingleAction,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Run single action'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _runQueuedActions,
                      icon: const Icon(Icons.queue),
                      label: const Text('Run queued actions (FIFO)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tiny log area to visualize the order of events for the queue demo.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Execution log / Registro de ejecución',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_log.isEmpty)
                        const Text('No events yet / Aún no hay eventos.'),
                      if (_log.isNotEmpty)
                        ..._log.map((String e) => Text('• $e')),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay driven by isLoadingStream + loadingMsgStream
          StreamBuilder<bool>(
            stream: _bloc.isLoadingStream,
            initialData: _bloc.isLoading,
            builder: (BuildContext context, AsyncSnapshot<bool> snap) {
              final bool active = snap.data ?? false;
              if (!active) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const CircularProgressIndicator(),
                              const SizedBox(height: 12),
                              StreamBuilder<String>(
                                stream: _bloc.loadingMsgStream,
                                initialData: _bloc.loadingMsg,
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<String> s2,
                                ) {
                                  final String msg = s2.data ?? '';
                                  return Text(
                                    msg.isEmpty ? 'Loading…' : msg,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// WsDatabaseUserDemoPage
/// ---------------------------------------------------------------------------
///
/// # Propósito de esta demo
///
/// Mostrar, de punta a punta, **cómo orquestar un CRUD + realtime (watch)**
/// sobre documentos con un *stack* por capas:
///
/// 1) **ServiceWsDatabase**  → transporte (aquí, un Fake in-memory con semántica
///    de WebSocket: streams por doc/colección).
/// 2) **GatewayWsDatabase**  → mapea excepciones a ErrorItem, inyecta `id` y
///    multiplexa los watch por docId (un solo stream compartido por doc).
/// 3) **RepositoryWsDatabase<T>** → mapea JSON ↔️ Model (T) y opcionalmente
///    **serializa escrituras por docId** para evitar carreras.
/// 4) **Use cases + Facade** → casos de uso transversales (read, write, watch…)
///    expuestos en una fachada amigable para la UI.
/// 5) **BlocWsDatabase<T>** → capa reactiva para la vista: publica un único
///    `WsDbState<T>` con `loading/error/doc/docId/isWatching`.
///
/// # ¿Por qué esta arquitectura?
///
/// - **Separación de responsabilidades:** cada capa resuelve un problema y la UI
///   solo consume *casos de uso*.
/// - **Reutilizable y testeable:** puedes cambiar Service (REST, WS real, etc.)
///   sin tocar BLoC ni UI; Gateway y Repository tienen unit tests sencillos.
/// - **Streams eficientes:** el Gateway crea **un solo** canal por `docId` y lo
///   comparte entre todos los observadores; libera memoria cuando nadie observa.
/// - **Errores coherentes:** Los errores en transporte/payload se estandariza
///   vía `ErrorItem`, lo que simplifica la UI.
///
/// # Qué puedes hacer desde la UI
///
/// - **Read**, **Write/Upsert**, **Delete**, **Exists**
/// - **Ensure** (crear si falta, actualizar si existe)
/// - **Mutate** (leer → transformar → escribir)
/// - **Patch** (merge parcial de JSON)
/// - **Watch/Stop watch** (realtime)
/// - **Auto +1/sec**: un “motor” que simula cambios en servidor para ver el
///   watch en vivo (incrementa un contador en el documento).
///
/// # Tips de integración en tu app
///
/// - Si compartes Repository/Gateway entre varias pantallas, llama
///   `bloc.dispose()` para cerrar la UI, y `facade.disposeAll()` **solo** si
///   eres dueño del stack (p.ej. al cerrar sesión).
/// - Tras cancelar un `watch`, recuerda llamar a `facade.detach(...)`
///   (el BLoC lo hace por ti en `stopWatch` y `dispose`).
/// - Si tu backend emite snapshots vacíos cuando el doc no existe, configura el
///   Gateway con `treatEmptyAsMissing` en true.
///
class WsDatabaseUserDemoPage extends StatefulWidget {
  const WsDatabaseUserDemoPage({super.key});

  @override
  State<WsDatabaseUserDemoPage> createState() => _WsDatabaseUserDemoPageState();
}

class _WsDatabaseUserDemoPageState extends State<WsDatabaseUserDemoPage> {
  // Capas (5): Service → Gateway → Repository → Facade → Bloc
  late final FakeServiceWsDatabase _service;
  late final GatewayWsDatabaseImpl _gateway;
  late final RepositoryWsDatabaseImpl<UserModel> _repository;
  late final FacadeWsDatabaseUsecases<UserModel> _facade;
  late final BlocWsDatabase<UserModel> _bloc;

  // Un pequeño "motor" para simular cambios en el servidor y ver el watch.
  WsDocTicker? _ticker;

  // Campos de UI para construir un UserModel de prueba.
  final TextEditingController _docIdCtrl =
      TextEditingController(text: 'user_001');
  final TextEditingController _nameCtrl =
      TextEditingController(text: 'John Doe');
  final TextEditingController _emailCtrl =
      TextEditingController(text: 'john.doe@example.com');
  final TextEditingController _photoCtrl =
      TextEditingController(text: 'https://example.com/profile.jpg');

  @override
  void initState() {
    super.initState();

    // (1) Service: fake WebSocket-like DB en memoria (streams por doc/colección).
    _service = FakeServiceWsDatabase();

    // (2) Gateway: mapea excepciones a ErrorItem, inyecta 'id',
    //     multiplexa watch por docId y maneja payload errors.
    _gateway = GatewayWsDatabaseImpl(
      service: _service,
      collection: 'users',
      // idKey/readAfterWrite/treatEmptyAsMissing → defaults conservadores.
    );

    // (3) Repository: mapea JSON ↔️ UserModel y (opcional) serializa writes
    //     por docId para evitar solapamientos (útil con UI impaciente).
    _repository = RepositoryWsDatabaseImpl<UserModel>(
      gateway: _gateway,
      fromJson: UserModel.fromJson,
      serializeWrites: true,
    );

    // (4) Facade: agrupa los casos de uso (read, write, watch, batch, etc.)
    _facade = FacadeWsDatabaseUsecases<UserModel>.fromRepository(
      repository: _repository,
      fromJson: UserModel.fromJson,
    );

    // (5) Bloc: publica WsDbState<T> (loading/error/doc/docId/isWatching)
    _bloc = BlocWsDatabase<UserModel>(facade: _facade);

    // Motor de cambios “servidor”: actualiza un campo contador en el doc.
    // - Usa el Service directamente para simular eventos “externos”
    //   (el Gateway/Repo/Bloc observarán los cambios como en producción).
    _ticker = WsDocTicker(
      service: _service,
      collection: 'users',
      docId: _docIdCtrl.text.trim(),
      seedMode: SeedMode.none, // no crea doc si no existe
    );
  }

  @override
  void dispose() {
    // Buen ciudadano: detiene motor y cierra BLoC/stream de estado.
    _ticker?.stop();
    _bloc.dispose();
    _docIdCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  /// Construye un UserModel desde los campos de UI.
  ///
  /// Nota: en esta demo el `jwt` es vacío; el motor (_ticker_) toca este campo
  /// para simular cambios en caliente (por ejemplo `jwt.countRef`).
  UserModel _buildUser(String id) => UserModel(
        id: id,
        displayName: _nameCtrl.text.trim(),
        photoUrl: _photoCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        jwt: const <String, dynamic>{},
      );

  void _snack(String msg) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WsDatabase Demo — UserModel')),
      // La vista se suscribe al stream de estado del BLoC.
      body: StreamBuilder<WsDbState<UserModel>>(
        stream: _bloc.stream,
        initialData: _bloc.value,
        builder: (BuildContext context, AsyncSnapshot<WsDbState<UserModel>> s) {
          final WsDbState<UserModel> state =
              s.data ?? WsDbState<UserModel>.idle();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _Header(loading: state.loading, isWatching: state.isWatching),
              const SizedBox(height: 12),
              _DocIdField(controller: _docIdCtrl),
              const SizedBox(height: 8),
              _TextField(label: 'Display name', controller: _nameCtrl),
              const SizedBox(height: 8),
              _TextField(label: 'Email', controller: _emailCtrl),
              const SizedBox(height: 8),
              _TextField(label: 'Photo URL', controller: _photoCtrl),
              const SizedBox(height: 16),

              // ----------------------------------------------------------------
              // Botones de acciones (un botón = un caso de uso)
              // ----------------------------------------------------------------
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  // READ: carga un doc por id → actualiza state.doc/docId
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.readDoc(id);
                      res.fold(
                        (ErrorItem e) => _snack('READ error: ${e.code}'),
                        (UserModel u) => _snack('READ ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Read'),
                  ),

                  // WRITE / UPSERT: persiste el doc → devuelve versión autoritativa
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final UserModel user = _buildUser(id);
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.writeDoc(id, user);
                      res.fold(
                        (ErrorItem e) => _snack('WRITE error: ${e.code}'),
                        (UserModel u) => _snack('WRITE ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Write / Upsert'),
                  ),

                  // DELETE: elimina por id → si es el doc activo, lo limpia del state
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, Unit> res =
                          await _bloc.deleteDoc(id);
                      res.fold(
                        (ErrorItem e) => _snack('DELETE error: ${e.code}'),
                        (_) => _snack('DELETE ok'),
                      );
                    },
                    child: const Text('Delete'),
                  ),

                  // EXISTS: no altera el doc del state, solo informa si existe
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, bool> res =
                          await _bloc.existsDoc(id);
                      res.fold(
                        (ErrorItem e) => _snack('EXISTS error: ${e.code}'),
                        (bool exists) => _snack('EXISTS: $exists'),
                      );
                    },
                    child: const Text('Exists'),
                  ),

                  // ENSURE: crea si falta, opcionalmente actualiza si existe
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.ensureDoc(
                        docId: id,
                        create: () => _buildUser(id),
                        updateIfExists: (UserModel u) =>
                            u.copyWith(displayName: '${u.displayName} ✅'),
                      );
                      res.fold(
                        (ErrorItem e) => _snack('ENSURE error: ${e.code}'),
                        (UserModel u) => _snack('ENSURE ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Ensure'),
                  ),

                  // MUTATE: lectura → transformación pura → escritura
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.mutateDoc(
                        id,
                        (UserModel u) =>
                            u.copyWith(displayName: '${u.displayName} *'),
                      );
                      res.fold(
                        (ErrorItem e) => _snack('MUTATE error: ${e.code}'),
                        (UserModel u) => _snack('MUTATE ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Mutate name'),
                  ),

                  // PATCH: merge parcial de JSON (útil para “editar por campos”)
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.patchDoc(id, <String, dynamic>{
                        UserEnum.displayName.name:
                            '${_nameCtrl.text.trim()} (patched)',
                      });
                      res.fold(
                        (ErrorItem e) => _snack('PATCH error: ${e.code}'),
                        (UserModel u) => _snack('PATCH ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Patch name'),
                  ),

                  // WATCH: inicia la observación realtime del doc via Gateway/Repo
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      await _bloc.startWatch(id);
                      _snack('Watch started for $id');
                    },
                    child: const Text('Watch'),
                  ),

                  // STOP WATCH: cancela suscripción y “detach” del canal compartido
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      await _bloc.stopWatch(id);
                      _snack('Watch stopped for $id');
                    },
                    child: const Text('Stop watch'),
                  ),

                  // “Motor” que simula actualizaciones de servidor:
                  // - Asegura doc
                  // - Inicia watch
                  // - Empieza a incrementar un contador cada segundo
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      await _bloc.ensureDoc(
                        docId: id,
                        create: () => _buildUser(id),
                      );

                      _bloc.startWatch(id); // verás los cambios en vivo
                      await _ticker?.start(id);

                      _snack('Auto +1/sec started on $id');
                    },
                    child: const Text('Auto +1/sec (start)'),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await _ticker?.stop();
                      _snack('Auto +1/sec stopped');
                    },
                    child: const Text('Auto +1/sec (stop)'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Estado del BLoC (lo que debería consumir tu UI real)
              _StateView(state: state),

              const SizedBox(height: 80),
              const SizedBox(height: 12),

              // Vista de “raw” (desde Service directly) para enseñar el JSON crudo
              // que viaja por la capa de transporte. Útil para depurar el watch.
              _RawCountView(
                service: _service,
                collection: 'users',
                docId: _docIdCtrl.text,
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- UI bits ---------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.loading, required this.isWatching});

  final bool loading;
  final bool isWatching;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (loading)
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Text('Loading: $loading'),
        const SizedBox(width: 16),
        Text('Watching: $isWatching'),
      ],
    );
  }
}

class _DocIdField extends StatelessWidget {
  const _DocIdField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'docId',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({required this.state});
  final WsDbState<UserModel> state;

  @override
  Widget build(BuildContext context) {
    final ErrorItem? err = state.error;
    final UserModel? user = state.doc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Bloc state:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _kv('docId', state.docId),
        _kv('loading', state.loading.toString()),
        _kv('isWatching', state.isWatching.toString()),
        const SizedBox(height: 12),
        if (err != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.93),
              border: Border.all(color: Colors.red.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Error: ${err.code}\n${err.title}\n${err.description}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (user != null) ...<Widget>[
          const SizedBox(height: 12),
          const Text('User:', style: TextStyle(fontWeight: FontWeight.bold)),
          _kv('id', user.id),
          _kv('displayName', user.displayName),
          _kv('email', user.email),
          _kv('photoUrl', user.photoUrl),
          _kv('jwt(json)', Utils.mapToString(user.jwt)),
        ],
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 120, child: Text('$k:')),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}

/// Cómo sembrar/actualizar el doc para que el watch “se vea”:
///
/// Este motor usa **el Service directamente** para simular cambios producidos por
/// el servidor. Así el Repository/Gateway/Bloc “ven” actualizaciones como en
/// producción.
///
/// - `seedMode` define qué hacer si el doc no existe (no crearlo, crearlo con
///   mínimo, o crearlo con una factoría custom).
/// - En esta variante el contador vive dentro de `jwt.countRef` (clave común
///   que siempre está en los JSON de usuario). Si prefieres un campo de nivel
///   superior (`count`), adapta `_ensureCountField/_tick` y la UI de `_RawCountView`.
enum SeedMode {
  /// No crea el documento si no existe. El ticker solo incrementa si ya hay doc.
  none,

  /// Crea un doc mínimo: solo {'count': 0} o el campo que decidas.
  minimalCountOnly,

  /// Crea usando una factoría custom (por ejemplo, traer un JSON externo).
  customFactory,
}

/// Tiny engine que incrementa cada [interval] un contador dentro del JSON.
///
/// - Garantiza que el doc tenga el campo contador.
/// - Cada tick: lee el JSON actual, incrementa y guarda.
/// - Usa **ServiceWsDatabase** para simular backend y que el *watch* dispare.
///
/// Si decides mover el contador a otra ruta (p.ej. `count` toplevel),
/// ajusta el merge en `_ensureCountField/_tick` y la vista `_RawCountView`.
class WsDocTicker {
  WsDocTicker({
    required ServiceWsDatabase<Map<String, dynamic>> service,
    required String collection,
    required String docId,
    this.interval = const Duration(seconds: 1),
    this.seedMode = SeedMode.minimalCountOnly,
    this.seedFactory,
  })  : _service = service,
        _collection = collection,
        _docId = docId;

  final ServiceWsDatabase<Map<String, dynamic>> _service;
  final String _collection;
  String _docId;
  final Duration interval;

  /// Estrategia para crear doc si está ausente.
  final SeedMode seedMode;

  /// Factoría opcional para SeedMode.customFactory. Recibe `docId` y devuelve el JSON base.
  final Map<String, dynamic> Function(String docId)? seedFactory;

  Timer? _timer;
  bool get isRunning => _timer != null;

  Future<void> start([String? docId]) async {
    if (docId != null) {
      _docId = docId;
    }
    if (_timer != null) {
      return;
    }

    await _ensureCountField();
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _ensureCountField() async {
    try {
      final Map<String, dynamic> json = await _service.readDocument(
        collection: _collection,
        docId: _docId,
      );

      // Contador embebido en jwt.countRef — cambia aquí si usas otra ruta.
      final Map<String, dynamic> jwt = Utils.mapFromDynamic(json['jwt']);
      if (!jwt.containsKey('countRef')) {
        final Map<String, dynamic> merged = <String, dynamic>{
          ...json,
          'jwt': <String, dynamic>{...jwt, 'countRef': 0},
        };
        await _service.saveDocument(
          collection: _collection,
          docId: _docId,
          document: merged,
        );
      }
    } catch (_) {
      // Doc ausente
      if (seedMode == SeedMode.none) {
        return;
      }

      Map<String, dynamic> base = const <String, dynamic>{};
      if (seedMode == SeedMode.customFactory) {
        base = seedFactory?.call(_docId) ?? const <String, dynamic>{};
      }

      await _service.saveDocument(
        collection: _collection,
        docId: _docId,
        document: <String, dynamic>{
          ...base,
          'jwt': <String, dynamic>{'countRef': 0},
        },
      );
    }
  }

  Future<void> _tick() async {
    try {
      final Map<String, dynamic> json = await _service.readDocument(
        collection: _collection,
        docId: _docId,
      );

      final Map<String, dynamic> jwt = Utils.mapFromDynamic(json['jwt']);
      final int current = Utils.getIntegerFromDynamic(jwt['countRef']);

      final Map<String, dynamic> next = <String, dynamic>{
        ...json,
        'jwt': <String, dynamic>{...jwt, 'countRef': current + 1},
      };

      await _service.saveDocument(
        collection: _collection,
        docId: _docId,
        document: next,
      );
    } catch (_) {
      if (seedMode == SeedMode.none) {
        return;
      }

      Map<String, dynamic> base = const <String, dynamic>{};
      if (seedMode == SeedMode.customFactory) {
        base = seedFactory?.call(_docId) ?? const <String, dynamic>{};
      }
      await _service.saveDocument(
        collection: _collection,
        docId: _docId,
        document: <String, dynamic>{
          ...base,
          'jwt': <String, dynamic>{'countRef': 0},
        },
      );
    }
  }
}

/// Vista auxiliar que muestra el **JSON crudo** que emite el Service al hacer
/// watch del documento. Es útil para depurar si las actualizaciones llegan.
///
/// **Nota:** En esta demo el ticker incrementa `jwt.countRef`. Si decides
/// mostrar ese valor, extrae `raw['jwt']['countRef']`. Aquí se deja el ejemplo
/// simple con `raw['count']` para ilustrar que puedes adaptar el render a la
/// ruta que uses en tu payload.
class _RawCountView extends StatelessWidget {
  const _RawCountView({
    required this.service,
    required this.collection,
    required this.docId,
  });

  final ServiceWsDatabase<Map<String, dynamic>> service;
  final String collection;
  final String docId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: service.documentStream(collection: collection, docId: docId),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snap) {
        final Map<String, dynamic> raw = snap.data ?? const <String, dynamic>{};

        // Si usas jwt.countRef:
        // final int count = Utils.getIntegerFromDynamic(
        //   Utils.mapFromDynamic(raw['jwt'])['countRef'],
        // );
        // Para mantener el ejemplo original, se deja 'count' toplevel:
        final int count = Utils.getIntegerFromDynamic(raw['count']);

        return Row(
          children: <Widget>[
            const Text(
              'Raw count: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('$raw : $count'),
          ],
        );
      },
    );
  }
}
