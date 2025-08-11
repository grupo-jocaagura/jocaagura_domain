part of '../../jocaagura_domain.dart';

/// Centralized BLoC for session flows using [SessionState] and `BlocGeneral`.
///
/// - Starts in [Unauthenticated].
/// - `boot()` subscribes to repo-level `authStateChanges` via
///   [WatchAuthStateChangesUsecase] (no silent login forced).
/// - Uses [Debouncer] to avoid rapid double actions on auth methods.
/// - When a usecase yields `Left(ErrorItem)`, the state is set to
///   `SessionError(err)` and **doesn't auto-revert** (UI decides next step).
///
/// ### Example
/// ```dart
/// final session = BlocSession(
///   usecases: SessionUsecases(
///     logInUserAndPassword: logInUC,
///     logOutUsecase: logOutUC,
///     signInUserAndPassword: signInUC,
///     recoverPassword: recoverUC,
///     logInSilently: silentUC,
///     loginWithGoogle: googleUC,
///     refreshSession: refreshUC,
///     getCurrentUser: getCurrentUC,
///   ),
///   watchAuthStateChanges: WatchAuthStateChangesUsecase(repositoryAuth),
/// );
///
/// // Start listening to backend-driven auth changes (no silent login here):
/// await session.boot();
///
/// // Log in:
/// final result = await session.logIn(email: 'me@mail.com', password: 'secret');
/// result.fold(
///   (e) => debugPrint('Login error: ${e.description}'),
///   (u) => debugPrint('Hi ${u.email}'),
/// );
///
/// // Read-only helpers:
/// final bool signed = session.isAuthenticated;
/// final UserModel me = session.currentUser; // defaultUserModel if not signed
///
/// // Clean up:
/// session.dispose();
/// ```
class BlocSession {
  BlocSession({
    required SessionUsecases usecases,
    required WatchAuthStateChangesUsecase watchAuthStateChanges,
    Debouncer? authDebouncer,
    Debouncer? refreshDebouncer,
  })  : _usecases = usecases,
        _watch = watchAuthStateChanges,
        _authDebouncer = authDebouncer ?? Debouncer(),
        _refreshDebouncer = refreshDebouncer ?? Debouncer(),
        _states = BlocGeneral<SessionState>(const Unauthenticated());

  // Facade de casos de uso (tu clase existente)
  final SessionUsecases _usecases;
  final WatchAuthStateChangesUsecase _watch;

  // Stream principal de estado
  final BlocGeneral<SessionState> _states;

  // Debouncers para evitar dobles taps
  final Debouncer _authDebouncer;
  final Debouncer _refreshDebouncer;

  StreamSubscription<Either<ErrorItem, UserModel?>>? _authSub;

  Future<void> cancelAuthSubscription() async {
    if (_authSub != null) {
      await _authSub!.cancel();
      _authSub = null;
    }
  }

  bool _disposed = false;

  Stream<SessionState> get sessionStream => _states.stream;

  /// Current user (never null). Returns [defaultUserModel] if not authenticated.
  UserModel get currentUser {
    final SessionState state = _states.value;
    if (state is Authenticated) {
      return state.user;
    }
    return defaultUserModel;
  }

  /// True if state is [Authenticated].
  bool get isAuthenticated => _states.value is Authenticated;

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('BlocSession has been disposed');
    }
  }

  /// Starts listening to repository-level auth changes.
  ///
  /// - `Right(null)` → `Unauthenticated`
  /// - `Right(user)` → `Authenticated(user)`
  /// - `Left(err)` → `SessionError(err)`
  ///
  /// Idempotent: cancels a previous subscription if already attached.
  Future<void> boot() async {
    _ensureNotDisposed();
    await cancelAuthSubscription();
    _authSub = _watch.call().listen((Either<ErrorItem, UserModel?> event) {
      event.fold(
        (ErrorItem err) => _states.value = SessionError(err),
        (UserModel? user) {
          if (user == null) {
            _states.value = const Unauthenticated();
          } else {
            _states.value = Authenticated(user);
          }
        },
      );
    });
  }

  /// Builds a minimal [UserModel] using email/password to satisfy usecases that
  /// read `jwt[LogInUserAndPasswordUsecase.passwordKey]` for credentials.
  UserModel _buildUserForCredentials({
    required String email,
    required String password,
  }) {
    return UserModel(
      id: email,
      displayName: email.split('@').first,
      photoUrl: '',
      email: email,
      jwt: <String, dynamic>{
        LogInUserAndPasswordUsecase.passwordKey: password,
      },
    );
  }

  // ---------- Public API ----------

  /// Performs **email+password login**.
  ///
  /// Debounced. Sets [Authenticating] while processing.
  Future<Either<ErrorItem, UserModel>> logIn({
    required String email,
    required String password,
  }) {
    _ensureNotDisposed();
    final Completer<Either<ErrorItem, UserModel>> completer =
        Completer<Either<ErrorItem, UserModel>>();
    _authDebouncer(() {
      _logInImpl(email: email, password: password, completer: completer);
    });
    return completer.future;
  }

  Future<void> _logInImpl({
    required String email,
    required String password,
    required Completer<Either<ErrorItem, UserModel>> completer,
  }) async {
    _states.value = const Authenticating();
    final UserModel req =
        _buildUserForCredentials(email: email, password: password);
    final Either<ErrorItem, UserModel> right =
        await _usecases.logInUserAndPassword.call(req);
    right.fold(
      (ErrorItem errorItem) => _states.value = SessionError(errorItem),
      (UserModel user) => _states.value = Authenticated(user),
    );
    completer.complete(right);
  }

  /// Performs **email+password sign up**.
  ///
  /// Debounced. Sets [Authenticating] while processing.
  Future<Either<ErrorItem, UserModel>> signIn({
    required String email,
    required String password,
  }) {
    _ensureNotDisposed();
    final Completer<Either<ErrorItem, UserModel>> completer =
        Completer<Either<ErrorItem, UserModel>>();
    _authDebouncer(() {
      _signInImpl(email: email, password: password, completer: completer);
    });
    return completer.future;
  }

  Future<void> _signInImpl({
    required String email,
    required String password,
    required Completer<Either<ErrorItem, UserModel>> completer,
  }) async {
    _states.value = const Authenticating();
    final UserModel req =
        _buildUserForCredentials(email: email, password: password);
    final Either<ErrorItem, UserModel> right =
        await _usecases.signInUserAndPassword.call(req);
    right.fold(
      (ErrorItem errorItem) => _states.value = SessionError(errorItem),
      (UserModel user) => _states.value = Authenticated(user),
    );
    completer.complete(right);
  }

  /// Performs **Google login**.
  ///
  /// Debounced. Sets [Authenticating] while processing.
  Future<Either<ErrorItem, UserModel>> logInWithGoogle() {
    _ensureNotDisposed();
    final Completer<Either<ErrorItem, UserModel>> completer =
        Completer<Either<ErrorItem, UserModel>>();
    _authDebouncer(() {
      _logInWithGoogleImpl(completer: completer);
    });
    return completer.future;
  }

  Future<void> _logInWithGoogleImpl({
    required Completer<Either<ErrorItem, UserModel>> completer,
  }) async {
    _states.value = const Authenticating();
    final Either<ErrorItem, UserModel> right =
        await _usecases.loginWithGoogle.call();
    right.fold(
      (ErrorItem errorItem) => _states.value = SessionError(errorItem),
      (UserModel user) => _states.value = Authenticated(user),
    );
    completer.complete(right);
  }

  /// Attempts **silent login** using the current authenticated user.
  ///
  /// If no current user is present, marks `Unauthenticated` and returns `null`.
  /// Debounced. Sets [Authenticating] while processing.
  Future<Either<ErrorItem, UserModel>?> logInSilently() {
    _ensureNotDisposed();
    if (_states.value is! Authenticated) {
      _states.value = const Unauthenticated();
      return Future<Either<ErrorItem, UserModel>?>.value();
    }
    final Completer<Either<ErrorItem, UserModel>> c =
        Completer<Either<ErrorItem, UserModel>>();
    _authDebouncer(() {
      _logInSilentlyImpl(completer: c);
    });
    return c.future;
  }

  Future<void> _logInSilentlyImpl({
    required Completer<Either<ErrorItem, UserModel>> completer,
  }) async {
    final Authenticated prev = _states.value as Authenticated;

    _states.value = const Authenticating();

    final Either<ErrorItem, UserModel> right =
        await _usecases.logInSilently.call(prev.user);
    right.fold(
      (ErrorItem errorItem) => _states.value = SessionError(errorItem),
      (UserModel user) => _states.value = Authenticated(user),
    );
    completer.complete(right);
  }

  /// Refreshes the current session.
  ///
  /// If not authenticated, marks `Unauthenticated` and returns `null`.
  /// Debounced separately from login actions.
  Future<Either<ErrorItem, UserModel>?> refreshSession() {
    _ensureNotDisposed();
    if (_states.value is! Authenticated) {
      _states.value = const Unauthenticated();
      return Future<Either<ErrorItem, UserModel>?>.value();
    }
    final Completer<Either<ErrorItem, UserModel>> completer =
        Completer<Either<ErrorItem, UserModel>>();
    _refreshDebouncer(() {
      _refreshImpl(completer: completer);
    });
    return completer.future;
  }

  Future<void> _refreshImpl({
    required Completer<Either<ErrorItem, UserModel>> completer,
  }) async {
    final Authenticated prev = _states.value as Authenticated;
    _states.value = Refreshing(prev);
    final Either<ErrorItem, UserModel> r =
        await _usecases.refreshSession.call(prev.user);
    r.fold(
      (ErrorItem e) => _states.value = SessionError(e),
      (UserModel u) => _states.value = Authenticated(u),
    );
    completer.complete(r);
  }

  /// Sends a password recovery instruction to [email].
  ///
  /// Does **not** change the session state on success.
  /// On failure, moves to `SessionError`.
  Future<Either<ErrorItem, void>> recoverPassword({
    required String email,
  }) async {
    _ensureNotDisposed();
    final UserModel probe = UserModel(
      id: email,
      displayName: email.split('@').first,
      photoUrl: '',
      email: email,
      jwt: const <String, dynamic>{},
    );
    final Either<ErrorItem, void> right =
        await _usecases.recoverPassword.call(probe);
    right.fold(
      (ErrorItem e) => _states.value = SessionError(e),
      (_) {}, // keep current state on success
    );
    return right;
  }

  /// Logs out the current user (if any).
  ///
  /// Sets `Authenticating` while processing. On success, `Unauthenticated`.
  Future<Either<ErrorItem, void>?> logOut() async {
    _ensureNotDisposed();
    if (_states.value is! Authenticated) {
      _states.value = const Unauthenticated();
      return null;
    }
    final Authenticated prev = _states.value as Authenticated;
    _states.value = const Authenticating();
    final Either<ErrorItem, void> right =
        await _usecases.logOutUsecase.call(prev.user);
    right.fold(
      (ErrorItem e) => _states.value = SessionError(e),
      (_) => _states.value = const Unauthenticated(),
    );
    return right;
  }

  /// Disposes internal resources.
  void dispose() {
    if (_disposed) {
      return;
    }
    cancelAuthSubscription();
    _states.dispose();
    _disposed = true;
  }
}
