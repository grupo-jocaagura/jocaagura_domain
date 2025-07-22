import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake implementation of [ServiceSession] for development and testing.
///
/// - Works exclusively with `UserModel?` values.
/// - Uses a [BlocGeneral] to emit auth state changes.
/// - Supports optional artificial latency and simulated sign-in failures.
class FakeServiceSession implements ServiceSession {
  /// Creates a fake session service.
  ///
  /// [latency] simulates network delay.
  /// [throwOnSignIn] simulates authentication errors.
  FakeServiceSession({
    this.latency = const Duration(seconds: 3),
    this.throwOnSignIn = false,
  }) : _bloc = BlocGeneral<UserModel?>(null);

  /// Simulated latency for operations (default: 3 seconds).
  final Duration latency;

  /// When true, [signInWithGoogle] will throw a [StateError].
  final bool throwOnSignIn;

  final BlocGeneral<UserModel?> _bloc;
  UserModel? _user;
  bool _disposed = false;

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('FakeServiceSession has been disposed');
    }
  }

  Stream<UserModel?> get userStream {
    _checkDisposed();
    return _bloc.stream;
  }

  UserModel? get currentUser {
    _checkDisposed();
    return _user;
  }

  Future<UserModel?> signInWithGoogle() async {
    _checkDisposed();
    if (throwOnSignIn) {
      throw StateError('Simulated authentication error');
    }
    await Future<void>.delayed(latency);
    // Simulate an authenticated user
    _user = const UserModel(
      id: 'fake_user',
      displayName: 'Fake User',
      photoUrl: 'https://fake.com/photo.png',
      email: 'fake@fake.com',
      jwt: <String, dynamic>{},
    );
    _bloc.value = _user;
    return _user;
  }

  @override
  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    _checkDisposed();
    if (username.isEmpty || password.isEmpty) {
      throw ArgumentError('Username and password must not be empty');
    }
    if (throwOnSignIn) {
      throw StateError('Simulated authentication error');
    }
    await Future<void>.delayed(latency);
    _user = UserModel(
      id: username,
      displayName: username,
      photoUrl: 'https://fake.com/photo.png',
      email: '$username@fake.com',
      jwt: const <String, dynamic>{},
    );
    _bloc.value = _user;
  }

  @override
  Future<void> signOut() async {
    _checkDisposed();
    await Future<void>.delayed(latency);
    _user = null;
    _bloc.value = null;
  }

  @override
  Future<bool> isSignedIn() async {
    _checkDisposed();
    await Future<void>.delayed(Duration.zero);
    return _user != null;
  }

  @override
  Stream<bool> authStateStream() {
    _checkDisposed();
    return _bloc.stream.map((UserModel? user) => user != null).distinct();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _disposed = true;
  }
}
