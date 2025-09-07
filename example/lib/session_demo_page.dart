import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

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
  late final WatchAuthStateChangesUsecase _watchUC;
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

    _watchUC = WatchAuthStateChangesUsecase(_repo);
    _bloc = BlocSession(
      usecases: _usecases,
      watchAuthStateChanges: _watchUC,
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
