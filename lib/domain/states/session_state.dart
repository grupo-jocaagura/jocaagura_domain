part of '../../jocaagura_domain.dart';

/// Base sealed class for all session states.
///
/// Each subclass represents a distinct phase in the user session lifecycle.
/// Consumers (UI, middleware) should use `is` checks or pattern matching to
/// handle transitions explicitly.
sealed class SessionState {
  const SessionState();
}

/// No authenticated user is present.
///
/// This is both the **initial state** of [BlocSession] and the fallback
/// used by [BlocSession.stateOrDefault] for simplicity in legacy paths.
///
/// UI may use this state to show login prompts or public-only flows.
class Unauthenticated extends SessionState {
  const Unauthenticated();
}

/// A login or sign-up operation is currently in progress.
///
/// This state is transient and always followed by either:
/// - [Authenticated] on success, or
/// - [SessionError] on failure.
///
/// UIs should treat it as a cue to display spinners or disable inputs.
class Authenticating extends SessionState {
  const Authenticating();
}

/// The user is fully authenticated and the session contains a [UserModel].
///
/// This is the only “stable” authenticated state.
///
/// Equality is **shallow**: consumers should compare the inner [user]
/// if they need to detect profile updates.
class Authenticated extends SessionState {
  const Authenticated(this.user);
  final UserModel user;
}

/// A refresh of the current [Authenticated] user is in progress.
///
/// Carries the [previous] authenticated instance to allow UI to continue
/// showing user details while the refresh completes.
///
/// Always transitions to either:
/// - [Authenticated] with a new user payload, or
/// - [SessionError] on failure.
class Refreshing extends SessionState {
  const Refreshing(this.previous);
  final Authenticated previous;
}

/// An unrecoverable error occurred during a session operation.
///
/// - **Important:** This state does **not auto-revert** to
///   [Unauthenticated] or any other state.
///   The UI or higher-level orchestrator must decide the next step
///   (retry, force logout, show error modal, etc.).
///
/// Contains the original [ErrorItem] for mapping or displaying details.
class SessionError extends SessionState {
  const SessionError(this.message);
  final ErrorItem message;

  ErrorItem get error => message;
}
