import 'dart:async';

import '../../jocaagura_domain.dart';

/// Simulates a session/auth service for development and tests.
///
/// - Emits auth state through a `BlocGeneral<Map<String, dynamic>?>`.
/// - Works exclusively with raw JSON-like `Map<String, dynamic>` payloads.
/// - Adds artificial latency and can force failures on sign-in flows.
/// - Any public method may `throw`; the Gateway/Repository layer must catch
///   and translate to domain errors (e.g., `ErrorItem`).
///
/// ### Quick start
/// ```dart
/// void main() async {
///   final ServiceSession svc = FakeServiceSession(
///     latency: const Duration(milliseconds: 50),
///   );
///
///   // Listen to auth state
///   final StreamSubscription sub = svc.authStateChanges().listen((e) {
///     print('authState: ${e == null ? 'SIGNED OUT' : 'SIGNED IN'}');
///   });
///
///   final Map<String, dynamic> user = await svc.signInUserAndPassword(
///     email: 'john@doe.com',
///     password: 'secret',
///   );
///   assert(user['email'] == 'john@doe.com');
///
///   await svc.logOutUser(user);
///   await sub.cancel();
///   svc.dispose();
/// }
/// ```
///
/// ### Notes
/// - This fake uses `email` as the user `id` in password flows.
/// - `refreshSession` expects `sessionJson['jwt']` to be a map-like object
///   containing token metadata; it will be replaced with refreshed values.
/// - Once `dispose()` is called, any further method invocation will throw
///   `StateError`.
class FakeServiceSession implements ServiceSession {
  /// Creates a new fake session service.
  ///
  /// - [latency]: artificial delay applied to async operations.
  /// - [throwOnSignIn]: when `true`, sign-in flows will throw `StateError`.
  /// - [initialUserJson]: optional initial signed-in payload; it will be
  ///   emitted immediately by `authStateChanges()`.
  FakeServiceSession({
    this.latency = const Duration(seconds: 3),
    this.throwOnSignIn = false,
    Map<String, dynamic>? initialUserJson,
  }) : _bloc = BlocGeneral<Map<String, dynamic>?>(initialUserJson) {
    _userJson = initialUserJson;
  }

  /// Artificial delay applied to async operations (default: 3s).
  final Duration latency;

  /// When `true`, any sign-in operation will throw a [StateError].
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

  /// Signs up or signs in with email & password and returns the user payload.
  ///
  /// **Preconditions**
  /// - [email] and [password] must be non-empty.
  ///
  /// **Throws**
  /// - [ArgumentError] if [email] or [password] is empty.
  /// - [StateError] when [throwOnSignIn] is `true`.
  ///
  /// **Postconditions**
  /// - Emits a non-null payload through [authStateChanges].
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

  /// Logs in with email & password and returns the user payload.
  ///
  /// **Preconditions**
  /// - [email] and [password] must be non-empty.
  ///
  /// **Throws**
  /// - [ArgumentError] if [email] or [password] is empty.
  /// - [StateError] when [throwOnSignIn] is `true`.
  ///
  /// **Postconditions**
  /// - Emits a non-null payload through [authStateChanges].
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

  /// Logs in with a simulated Google account and returns the user payload.
  ///
  /// **Throws**
  /// - [StateError] when [throwOnSignIn] is `true`.
  ///
  /// **Postconditions**
  /// - Emits a non-null payload through [authStateChanges].
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

  /// Accepts a previously stored session and considers it valid (silent sign-in).
  ///
  /// **Preconditions**
  /// - [sessionJson] must be non-empty (map-like).
  ///
  /// **Throws**
  /// - [StateError] if [sessionJson] is empty.
  ///
  /// **Postconditions**
  /// - Emits a non-null payload through [authStateChanges].
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

  /// Refreshes token metadata within the provided session payload.
  ///
  /// **Contract**
  /// - `sessionJson['jwt']` must be a map-like structure.
  ///
  /// **Throws**
  /// - [StateError] if [sessionJson] is empty.
  /// - May rethrow if `sessionJson['jwt']` is not map-like (depends on `Utils`).
  ///
  /// **Postconditions**
  /// - Returns and emits the same session with refreshed `jwt` fields.
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
    final Map<String, dynamic> next = Utils.mapFromDynamic(sessionJson);
    final Map<String, dynamic> jwt = Utils.mapFromDynamic(next['jwt']);
    jwt['accessToken'] = 'refreshed-token-${next['id'] ?? 'unknown'}';
    jwt['refreshedAt'] = now.toIso8601String();
    jwt['expiresAt'] = now.add(const Duration(hours: 1)).toIso8601String();
    next['jwt'] = jwt;
    _userJson = next;
    _bloc.value = _userJson;
    return _userJson!;
  }

  /// Sends a password recovery email.
  ///
  /// **Preconditions**
  /// - [email] must be non-empty.
  ///
  /// **Throws**
  /// - [ArgumentError] if [email] is empty.
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

  /// Logs out the current user and emits `null`.
  ///
  /// **Note**
  /// - The [sessionJson] argument is not validated; the fake always signs out.
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

  /// Returns the current user payload if signed in.
  ///
  /// **Throws**
  /// - [StateError] if there is no active session.
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

  /// Returns whether there is an active session.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   final ServiceSession svc = FakeServiceSession();
  ///   final Map<String, dynamic> r = await svc.isSignedIn();
  ///   print(r['isSignedIn']); // false
  /// }
  /// ```
  @override
  Future<Map<String, dynamic>> isSignedIn() async {
    _checkDisposed();
    await Future<void>.delayed(Duration.zero);
    return <String, dynamic>{'isSignedIn': _userJson != null};
  }

  /// Emits the auth state whenever it changes.
  ///
  /// **Throws**
  /// - [StateError] if called after [dispose].
  @override
  Stream<Map<String, dynamic>?> authStateChanges() {
    _checkDisposed();
    return _bloc.stream;
  }

  /// Releases resources. After calling this, any method invocation will throw.
  @override
  void dispose() {
    _bloc.dispose();
    _disposed = true;
  }
}
