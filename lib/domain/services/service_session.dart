part of '../../jocaagura_domain.dart';

/// Abstract service for user session management.
///
/// Provides methods to sign in, sign out, query authentication state,
/// and listen to authentication changes.
///
/// ⚠️ FOR DEVELOPMENT PURPOSES ONLY: Fake implementations should not be used in production.
///
/// Example:
/// ```dart
/// final ServiceSession session = FakeServiceSession();
/// await session.signIn(username: 'test', password: 'password');
/// final bool signed = await session.isSignedIn();
/// print(signed); // true
/// session.authStateStream().listen((isSignedIn) {
///   print('Auth state changed: \$isSignedIn');
/// });
/// ```
abstract class ServiceSession {
  /// Signs in a user with given [username] and [password].
  ///
  /// Throws [ArgumentError] if either field is empty.
  Future<void> signIn({
    required String username,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Returns whether a user is currently signed in.
  Future<bool> isSignedIn();

  /// Emits authentication state changes: `true` when signed in, `false` when signed out.
  Stream<bool> authStateStream();

  /// Disposes internal resources.
  void dispose();
}
