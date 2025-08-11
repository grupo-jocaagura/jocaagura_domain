import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake implementation of [ServiceSession] for development and testing.
///
/// - Works exclusively with `Map<String, dynamic>` payloads (no domain models).
/// - Uses a [BlocGeneral<Map<String, dynamic>?>] to emit auth state changes.
/// - Simulates latency and allows forcing auth failures by throwing exceptions.
/// - All methods may `throw`; the Gateway layer must catch & map to [ErrorItem].
///
/// ### Example
/// ```dart
/// final ServiceSession svc = FakeServiceSession(latency: Duration(milliseconds: 300));
///
/// // Email + password login
/// final Map<String, dynamic> userJson = await svc.logInUserAndPassword(
///   email: 'fake@fake.com',
///   password: 'secret',
/// );
///
/// // Listen changes
/// final sub = svc.authStateChanges().listen((payload) {
///   if (payload == null) {
///     print('Signed out');
///   } else {
///     print('Signed in as ${payload['email']}');
///   }
/// });
///
/// await svc.logOutUser(userJson);
/// await sub.cancel();
/// svc.dispose();
/// ```
class FakeServiceSession implements ServiceSession {
  FakeServiceSession({
    this.latency = const Duration(seconds: 3),
    this.throwOnSignIn = false,
    Map<String, dynamic>? initialUserJson,
  }) : _bloc = BlocGeneral<Map<String, dynamic>?>(initialUserJson) {
    _userJson = initialUserJson;
  }

  /// Simulated latency for operations (default: 3 seconds).
  final Duration latency;

  /// When true, any auth operation that logs in will throw a [StateError].
  final bool throwOnSignIn;

  final BlocGeneral<Map<String, dynamic>?> _bloc;

  Map<String, dynamic>? _userJson;
  bool _disposed = false;

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('FakeServiceSession has been disposed');
    }
  }

  Map<String, dynamic> _ack({
    required String message,
    Map<String, dynamic> extra = const <String, dynamic>{},
  }) {
    return <String, dynamic>{
      'ok': true,
      'message': message,
      ...extra,
    };
  }

  Map<String, dynamic> _buildUser({
    required String id,
    required String email,
    String? displayName,
  }) {
    final DateTime now = DateTime.now();
    return <String, dynamic>{
      'id': id,
      'displayName': displayName ?? email.split('@').first,
      'photoUrl':
          'https://jocaagura.com/blogjocaagura/wp-content/uploads/2021/08/avatar.png',
      'email': email,
      'jwt': <String, dynamic>{
        'accessToken': 'fake-token-$id',
        'issuedAt': now.toIso8601String(),
        'expiresAt': now.add(const Duration(hours: 1)).toIso8601String(),
      },
    };
  }

  @override
  Future<Map<String, dynamic>> signInUserAndPassword({
    required String email,
    required String password,
  }) async {
    _checkDisposed();
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password must not be empty');
    }
    if (throwOnSignIn) {
      throw StateError('Simulated sign-in failure');
    }
    await Future<void>.delayed(latency);
    // Simulate "account creation" followed by signed-in session.
    _userJson = _buildUser(id: email, email: email);
    _bloc.value = _userJson;
    return _userJson!;
  }

  @override
  Future<Map<String, dynamic>> logInUserAndPassword({
    required String email,
    required String password,
  }) async {
    _checkDisposed();
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password must not be empty');
    }
    if (throwOnSignIn) {
      throw StateError('Simulated login failure');
    }
    await Future<void>.delayed(latency);
    // Simulate login for an existing account.
    _userJson = _buildUser(id: email, email: email);
    _bloc.value = _userJson;
    return _userJson!;
  }

  @override
  Future<Map<String, dynamic>> logInWithGoogle() async {
    _checkDisposed();
    if (throwOnSignIn) {
      throw StateError('Simulated Google auth failure');
    }
    await Future<void>.delayed(latency);
    _userJson = _buildUser(
      id: 'google_user',
      email: 'fake@fake.com',
      displayName: 'Fake User',
    );
    _bloc.value = _userJson;
    return _userJson!;
  }

  @override
  Future<Map<String, dynamic>> logInSilently(
    Map<String, dynamic> sessionJson,
  ) async {
    _checkDisposed();
    await Future<void>.delayed(latency);
    // Accept provided session and "validate" it.
    if (sessionJson.isEmpty) {
      throw StateError('No session payload provided');
    }
    _userJson = Map<String, dynamic>.from(sessionJson);
    _bloc.value = _userJson;
    return _userJson!;
  }

  @override
  Future<Map<String, dynamic>> refreshSession(
    Map<String, dynamic> sessionJson,
  ) async {
    _checkDisposed();
    await Future<void>.delayed(latency);
    if (sessionJson.isEmpty) {
      throw StateError('No session payload to refresh');
    }
    final DateTime now = DateTime.now();
    final Map<String, dynamic> next = Map<String, dynamic>.from(sessionJson);
    final Map<String, dynamic> jwt =
        Map<String, dynamic>.from(Utils.mapFromDynamic(next['jwt']));
    jwt['accessToken'] = 'refreshed-token-${next['id'] ?? 'unknown'}';
    jwt['refreshedAt'] = now.toIso8601String();
    jwt['expiresAt'] = now.add(const Duration(hours: 1)).toIso8601String();
    next['jwt'] = jwt;
    _userJson = next;
    _bloc.value = _userJson;
    return _userJson!;
  }

  @override
  Future<Map<String, dynamic>> recoverPassword({required String email}) async {
    _checkDisposed();
    if (email.isEmpty) {
      throw ArgumentError('Email must not be empty');
    }
    await Future<void>.delayed(latency);
    return _ack(
      message: 'Recovery email sent',
      extra: <String, dynamic>{'email': email},
    );
  }

  @override
  Future<Map<String, dynamic>> logOutUser(
    Map<String, dynamic> sessionJson,
  ) async {
    _checkDisposed();
    await Future<void>.delayed(latency);
    _userJson = null;
    _bloc.value = null;
    return _ack(message: 'Logged out');
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    _checkDisposed();
    await Future<void>.delayed(Duration.zero);
    final Map<String, dynamic>? u = _userJson;
    if (u == null) {
      throw StateError('No active session');
    }
    return u;
  }

  @override
  Future<Map<String, dynamic>> isSignedIn() async {
    _checkDisposed();
    await Future<void>.delayed(Duration.zero);
    return <String, dynamic>{'isSignedIn': _userJson != null};
  }

  @override
  Stream<Map<String, dynamic>?> authStateChanges() {
    _checkDisposed();
    return _bloc.stream;
  }

  @override
  void dispose() {
    _bloc.dispose();
    _disposed = true;
  }
}
