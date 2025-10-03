// main.dart
import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// 0) Selección de flavor mediante --dart-define=FLAVOR=dev|qa|prod
const String kFlavor =
    String.fromEnvironment('FLAVOR', defaultValue: 'dev'); // dev por defecto

/// 1) Fábrica de ServiceSession por flavor.
/// En dev/qa usamos FakeServiceSession. En prod puedes inyectar tu servicio real.
/// Cambiar aquí es lo ÚNICO necesario para mover el flujo entre ambientes.
ServiceSession buildServiceForFlavor(String flavor) {
  switch (flavor) {
    case 'dev':
      return FakeServiceSession(
        latency: const Duration(milliseconds: 300),
        // throwOnSignIn: true, // descomenta para simular errores
      );
    case 'qa':
      // Aqui reemplaza por tu implementación QA cuando esté lista.
      return FakeServiceSession(
        latency: const Duration(milliseconds: 150),
      );
    case 'prod':
      // Aqui reemplaza por tu implementación real cuando esté lista.
      // return RealServiceSession(...);
      return FakeServiceSession(latency: const Duration(milliseconds: 80));
    default:
      return FakeServiceSession(latency: const Duration(milliseconds: 200));
  }
}

/// 2) Ensamble de dependencias:
/// ServiceSession → GatewayAuthImpl → RepositoryAuthImpl → BlocSession.fromRepository
BlocSession buildBlocSession() {
  final ServiceSession svc = buildServiceForFlavor(kFlavor);

  final GatewayAuth gateway = GatewayAuthImpl(
    svc,
    errorMapper: const DefaultErrorMapper(),
  );

  final RepositoryAuth repository = RepositoryAuthImpl(
    gateway: gateway,
    errorMapper: const DefaultErrorMapper(),
  );

  // Recomendado: usar el fromRepository que cablea todos los use cases.
  final BlocSession session = BlocSession.fromRepository(
    repository: repository,
    // postDisposePolicy: PostDisposePolicy.returnLastSnapshot, // opcional
  );
  return session;
}

void main() {
  runApp(const MyApp());
}

/// UI mínima para demostrar el flujo de autenticación end-to-end.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final BlocSession session;
  final TextEditingController email =
      TextEditingController(text: 'user@fake.com');
  final TextEditingController pass = TextEditingController(text: 'secret');

  @override
  void initState() {
    super.initState();
    session = buildBlocSession();
    // 3) Arrancamos la suscripción a cambios de autenticación
    session.boot();
  }

  @override
  void dispose() {
    session.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    );

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auth flow • Jocaagura (FakeService)'),
          actions: const <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'FLAVOR: $kFlavor',
                  style: TextStyle(
                    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: StreamBuilder<SessionState>(
          // 4) Observamos el estado de sesión desde el BLoC
          stream: session.stream,
          initialData: session.stateOrDefault, // binario amistoso
          builder: (BuildContext context, AsyncSnapshot<SessionState> snap) {
            final SessionState s = snap.data ?? session.stateOrDefault;

            Widget statusChip;
            if (s is Authenticating) {
              statusChip = const Chip(label: Text('Authenticating...'));
            } else if (s is Refreshing) {
              statusChip = const Chip(label: Text('Refreshing...'));
            } else if (s is SessionError) {
              statusChip = Chip(
                label: Text('Error: ${s.error.code}'),
                backgroundColor: Colors.red.withValues(alpha: .85),
              );
            } else if (s is Authenticated) {
              statusChip = const Chip(label: Text('Authenticated'));
            } else {
              statusChip = const Chip(label: Text('Unauthenticated'));
            }

            final String emailLabel = (s is Authenticated) ? s.user.email : '—';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    statusChip,
                    const SizedBox(width: 12),
                    Text(
                      'isAuthenticated: ${session.isAuthenticated}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Credentials',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'you@mail.com',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: pass,
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
                                final Either<ErrorItem, UserModel> r =
                                    await session.logIn(
                                  email: email.text,
                                  password: pass.text,
                                );
                                r.fold(
                                  (ErrorItem e) =>
                                      _toast(context, 'Login error: ${e.code}'),
                                  (UserModel u) =>
                                      _toast(context, 'Hello ${u.email}'),
                                );
                              },
                              child: const Text('Log In (email/pass)'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, UserModel> r =
                                    await session.signIn(
                                  email: email.text,
                                  password: pass.text,
                                );
                                r.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Sign In error: ${e.code}',
                                  ),
                                  (UserModel u) =>
                                      _toast(context, 'Welcome ${u.email}'),
                                );
                              },
                              child: const Text('Sign In (create)'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, UserModel> r =
                                    await session.logInWithGoogle();
                                r.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Google error: ${e.code}',
                                  ),
                                  (UserModel u) =>
                                      _toast(context, 'Google: ${u.email}'),
                                );
                              },
                              child: const Text('Log In with Google'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, void> r =
                                    await session.recoverPassword(
                                  email: email.text,
                                );
                                r.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Recover error: ${e.code}',
                                  ),
                                  (_) => _toast(
                                    context,
                                    'Recovery sent to ${email.text}',
                                  ),
                                );
                              },
                              child: const Text('Recover password'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Current user: $emailLabel'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, UserModel>? r =
                                    await session.logInSilently();
                                if (r == null && context.mounted) {
                                  _toast(context, 'No session to restore');
                                  return;
                                }
                                r?.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Silent error: ${e.code}',
                                  ),
                                  (UserModel u) =>
                                      _toast(context, 'Restored ${u.email}'),
                                );
                              },
                              child: const Text('Log In silently'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, UserModel>? r =
                                    await session.refreshSession();
                                if (r == null && context.mounted) {
                                  _toast(context, 'Nothing to refresh');
                                  return;
                                }
                                r?.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Refresh error: ${e.code}',
                                  ),
                                  (UserModel u) => _toast(
                                    context,
                                    'Refreshed for ${u.email}',
                                  ),
                                );
                              },
                              child: const Text('Refresh session'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, void>? r =
                                    await session.logOut();
                                if (r == null && context.mounted) {
                                  _toast(context, 'Already signed out');
                                  return;
                                }
                                r?.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Logout error: ${e.code}',
                                  ),
                                  (_) => _toast(context, 'Signed out'),
                                );
                              },
                              child: const Text('Log out'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}
