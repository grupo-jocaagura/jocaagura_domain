part of '../../jocaagura_domain.dart';

/// Low-level session/auth service boundary.
///
/// - Returns raw JSON-like payloads (`Map<String, dynamic>`) or emits them in streams.
/// - Throws raw exceptions on failures. **Never** returns Either here.
/// - No dependency on domain models.
///
/// ### Semantics
/// - `authStateChanges`: emits a user payload (`Map`) when signed-in and `null` when signed-out.
/// - Implementations may include tokens/claims inside the payload.
///
/// ### Example
/// ```dart
/// final ServiceSession svc = MyServiceSession(); // concrete infra
/// final Map<String, dynamic> userJson = await svc.logInUserAndPassword(
///   email: 'user@mail.com',
///   password: 'secret',
/// );
/// print(userJson['email']);
/// ```
abstract class ServiceSession {
  Future<Map<String, dynamic>> signInUserAndPassword({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> logInUserAndPassword({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> logInWithGoogle();

  /// Silent login using previously stored session payload (tokens/claims).
  Future<Map<String, dynamic>> logInSilently(Map<String, dynamic> sessionJson);

  /// Refresh session using current session payload (tokens/claims).
  Future<Map<String, dynamic>> refreshSession(Map<String, dynamic> sessionJson);

  /// Sends recovery mail/code. Returns an ack payload.
  Future<Map<String, dynamic>> recoverPassword({required String email});

  /// Logs out using current session payload. Returns an ack payload.
  Future<Map<String, dynamic>> logOutUser(Map<String, dynamic> sessionJson);

  /// Returns current user payload if signed-in; **throws** if not.
  Future<Map<String, dynamic>> getCurrentUser();

  /// Returns `{ 'isSignedIn': bool }`.
  Future<Map<String, dynamic>> isSignedIn();

  /// Emits user payload when signed-in; `null` when signed-out.
  /// Stream errors should propagate as raw errors (will be caught at Gateway).
  Stream<Map<String, dynamic>?> authStateChanges();

  void dispose();
}
