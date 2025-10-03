part of '../../jocaagura_domain.dart';

/// Policy to define how getters behave **after** this BLoC has been disposed.
///
/// By default, we prefer a strict behavior (`throwStateError`) to surface
/// lifecycle issues early in development and testing. You can opt into more
/// tolerant behaviors to keep backward compatibility in legacy flows.
enum PostDisposePolicy {
  /// Strict: accessing any getter after `dispose()` throws a `StateError`.
  throwStateError,

  /// Lenient: getters return the **last cached** value (no new updates).
  ///
  /// - `state` returns the last `SessionState`.
  /// - `stateOrDefault` keeps its binary collapse behavior based on the
  ///   last cached state.
  /// - `currentUser` returns the last cached user or `defaultUserModel`.
  /// - `isAuthenticated` returns `false` if the last cached state was not
  ///   `Authenticated`.
  /// - `sessionStream`/`stream` return the same (now closed) Stream; callers
  ///   will typically receive an immediate replay of the last value and then
  ///   completion.
  returnLastSnapshot,

  /// Lenient: `state` returns `SessionError` with a standard `ErrorItem`.
  ///
  /// Helpers remain safe and backward compatible:
  /// - `stateOrDefault` returns `Unauthenticated`.
  /// - `currentUser` returns `defaultUserModel`.
  /// - `isAuthenticated` returns `false`.
  ///
  /// Streams behave like in `returnLastSnapshot` (closed, replaying last value).
  returnSessionError,
}

/// Centralized BLoC for session flows using [SessionState] and `BlocGeneral`.
///
/// Use [BlocSession.fromRepository] when you only have a [RepositoryAuth] and
/// want the BLoC to wire all use cases for you. This keeps callers decoupled
/// from concrete use-case classes and remains backward compatible.
///
/// ### Quick start (repository-only)
/// ```dart
/// final RepositoryAuth repo = RepositoryAuthImpl(gateway: ...);
///
/// final BlocSession session = BlocSession.fromRepository(
///   repository: repo,
///   // Optional:
///   // postDisposePolicy: PostDisposePolicy.returnLastSnapshot,
/// );
///
/// await session.boot(); // start listening to repo auth changes
///
/// final r = await session.logIn(email: 'me@mail.com', password: 'secret');
/// r.fold(
///   (e) => debugPrint('Login error: ${e.code}'),
///   (u) => debugPrint('Hello ${u.email}'),
/// );
///
/// session.dispose();
/// ```
///
/// See the class docs for details on state semantics, post-dispose policies,
/// and debouncing of auth/refresh actions.

class BlocSession {
  /// Creates a [BlocSession].
  ///
  /// The default [postDisposePolicy] is [PostDisposePolicy.throwStateError],
  /// which is recommended to surface lifecycle issues early. For legacy
  /// code paths that access getters after `dispose()`, you can opt into a
  /// lenient policy.
  BlocSession({
    required SessionUsecases usecases,
    Debouncer? authDebouncer,
    Debouncer? refreshDebouncer,
    this.postDisposePolicy = PostDisposePolicy.throwStateError,
  })  : _usecases = usecases,
        _authDebouncer = authDebouncer ?? Debouncer(),
        _refreshDebouncer = refreshDebouncer ?? Debouncer(),
        _states = BlocGeneral<SessionState>(const Unauthenticated());

  /// Convenience factory that wires the required use cases using only a
  /// [RepositoryAuth]. This keeps callers repository-centric and backward
  /// compatible with future improvements in the use case layer.
  ///
  /// - [repository]: the domain repository for auth operations.
  /// - [authDebouncer]/[refreshDebouncer]: optional debouncers.
  /// - [postDisposePolicy]: post-dispose behavior; defaults to strict mode.
  factory BlocSession.fromRepository({
    required RepositoryAuth repository,
    Debouncer? authDebouncer,
    Debouncer? refreshDebouncer,
    PostDisposePolicy postDisposePolicy = PostDisposePolicy.throwStateError,
  }) {
    final SessionUsecases usecases = SessionUsecases(
      logInUserAndPassword: LogInUserAndPasswordUsecase(repository),
      logOutUsecase: LogOutUsecase(repository),
      signInUserAndPassword: SignInUserAndPasswordUsecase(repository),
      recoverPassword: RecoverPasswordUsecase(repository),
      logInSilently: LogInSilentlyUsecase(repository),
      loginWithGoogle: LoginWithGoogleUsecase(repository),
      refreshSession: RefreshSessionUsecase(repository),
      getCurrentUser: GetCurrentUserUsecase(repository),
      watchAuthStateChangesUsecase: WatchAuthStateChangesUsecase(repository),
    );
    return BlocSession(
      usecases: usecases,
      authDebouncer: authDebouncer,
      refreshDebouncer: refreshDebouncer,
      postDisposePolicy: postDisposePolicy,
    );
  }

  // ---- Dependencies & holders ------------------------------------------------

  // Facade of use cases.
  final SessionUsecases _usecases;

  // Main state holder.
  final BlocGeneral<SessionState> _states;

  // Debouncers to avoid double taps.
  final Debouncer _authDebouncer;
  final Debouncer _refreshDebouncer;

  // Post-dispose behavior policy.
  final PostDisposePolicy postDisposePolicy;

  // Subscription to auth changes.
  StreamSubscription<Either<ErrorItem, UserModel?>>? _authSub;

  // Disposal flag.
  bool _disposed = false;

  // Standard error when accessing getters after dispose under lenient policy.
  static const ErrorItem _disposedError = ErrorItem(
    title: 'Bloc disposed',
    code: 'BLOC_DISPOSED',
    description: 'BlocSession has been disposed and cannot be accessed.',
  );

  /// Centralizes the post-dispose behavior according to [postDisposePolicy].
  T _guard<T>({
    required T Function() body,
    required T Function() lastSnapshot,
    required T Function() sessionErrorFallback,
  }) {
    if (!_disposed) {
      return body();
    }

    switch (postDisposePolicy) {
      case PostDisposePolicy.throwStateError:
        throw StateError('BlocSession has been disposed');
      case PostDisposePolicy.returnLastSnapshot:
        return lastSnapshot();
      case PostDisposePolicy.returnSessionError:
        return sessionErrorFallback();
    }
  }

  /// Canonical session stream (prefer `session.stream` in consumers).
  ///
  /// **Post-dispose behavior**:
  /// - Default: throws `StateError`.
  /// - `returnLastSnapshot` / `returnSessionError`: returns the same (closed)
  ///   stream; a late subscriber may receive the last replayed value and then
  ///   completion, but no further updates.
  Stream<SessionState> get sessionStream => _guard<Stream<SessionState>>(
        body: () => _states.stream,
        lastSnapshot: () => _states.stream,
        sessionErrorFallback: () => _states.stream,
      );

  /// Canonical alias so consumers can use `session.stream`.
  ///
  /// See [sessionStream] for post-dispose behavior.
  Stream<SessionState> get stream => sessionStream;

  /// Exact snapshot of the latest published [SessionState].
  ///
  /// This getter **reflects the internal state verbatim** without any mapping
  /// or fallback. It is suitable when the UI or tests must reason about
  /// intermediate states such as [Authenticating], [Refreshing], or [SessionError].
  ///
  /// Prefer this getter over [stateOrDefault] when you need full-fidelity
  /// transitions (e.g. progress indicators or error banners).
  ///
  /// **Post-dispose behavior**:
  /// - Default: throws `StateError`.
  /// - `returnLastSnapshot`: returns the last cached [SessionState].
  /// - `returnSessionError`: returns `SessionError(_disposedError)`.
  ///
  /// ### Example
  /// ```dart
  /// final SessionState s = session.state;
  /// if (s is SessionError) {
  ///   showError(s.message);
  /// }
  /// ```
  SessionState get state => _guard<SessionState>(
        body: () => _states.value,
        lastSnapshot: () => _states.value,
        sessionErrorFallback: () => const SessionError(_disposedError),
      );

  /// Synchronous **best-effort** snapshot for consumers that only care about
  /// “am I signed in or not?” without dealing with intermediate states.
  ///
  /// For **backward compatibility** with previous implementations, this getter
  /// collapses the internal state into:
  /// - [Authenticated] → returns the **current** `Authenticated` instance
  ///   (no new allocation).
  /// - Any other state (`Unauthenticated`, `Authenticating`, `Refreshing`,
  ///   `SessionError`) → returns `const Unauthenticated()`.
  ///
  /// Use [state] if you need the exact internal state; use this getter for
  /// simple binary checks in legacy code paths.
  ///
  /// **Post-dispose behavior**:
  /// - Default: throws `StateError`.
  /// - `returnLastSnapshot`: collapses based on the **last cached** state.
  /// - `returnSessionError`: returns `Unauthenticated` to keep binary helpers
  ///   harmless in legacy flows.
  ///
  /// ### Example
  /// ```dart
  /// // Binary reading without dealing with intermediate states:
  /// final bool signedIn = session.stateOrDefault is Authenticated;
  /// ```
  SessionState get stateOrDefault => _guard<SessionState>(
        body: () {
          final SessionState state = _states.value;
          if (state is Authenticated) {
            return state; // no allocation if already authed
          }
          return const Unauthenticated();
        },
        lastSnapshot: () {
          final SessionState s = _states.value;
          return s is Authenticated ? s : const Unauthenticated();
        },
        sessionErrorFallback: () => const Unauthenticated(),
      );

  /// Current user (never null). Returns [defaultUserModel] if not authenticated.
  ///
  /// **Post-dispose behavior**:
  /// - Default: throws `StateError`.
  /// - `returnLastSnapshot`: returns the last cached user or [defaultUserModel].
  /// - `returnSessionError`: returns [defaultUserModel] (safe helper).
  UserModel get currentUser => _guard<UserModel>(
        body: () {
          final SessionState s = _states.value;
          return s is Authenticated ? s.user : defaultUserModel;
        },
        lastSnapshot: () {
          final SessionState s = _states.value;
          return s is Authenticated ? s.user : defaultUserModel;
        },
        sessionErrorFallback: () => defaultUserModel,
      );

  /// True if state is [Authenticated].
  ///
  /// **Post-dispose behavior**:
  /// - Default: throws `StateError`.
  /// - `returnLastSnapshot`: returns the last cached truth value.
  /// - `returnSessionError`: returns `false` (safe helper).
  bool get isAuthenticated => _guard<bool>(
        body: () => _states.value is Authenticated,
        lastSnapshot: () => _states.value is Authenticated,
        sessionErrorFallback: () => false,
      );

  // ---- Lifecycle -------------------------------------------------------------

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('BlocSession has been disposed');
    }
  }

  /// Cancels the internal auth subscription if present.
  Future<void> cancelAuthSubscription() async {
    if (_authSub != null) {
      await _authSub!.cancel();
      _authSub = null;
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
    _authSub = _usecases.watchAuthStateChangesUsecase
        .call()
        .listen((Either<ErrorItem, UserModel?> event) {
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

  /// Disposes internal resources.
  void dispose() {
    if (_disposed) {
      return;
    }
    cancelAuthSubscription();
    _states.dispose();
    _disposed = true;
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
}
