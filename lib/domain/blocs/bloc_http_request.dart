part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Centralized HTTP request bloc based on [BlocGeneral].
///
/// Responsibilities:
/// - Exposes high-level methods (`get`, `post`, `put`, `delete`, `retry`)
///   that delegate to [FacadeHttpRequestUsecases].
/// - Keeps a single [BlocGeneral] instance holding a set of **active** requests:
///   `requestKey` values currently in-flight.
/// - Allows applications to have **one central place** to know which HTTP
///   requests are active at any given time (for loaders, dashboards, etc.).
///
/// This bloc does **not** store final results. From its perspective each HTTP
/// call is:
/// - Marked as active when it starts.
/// - Resolved as a `Future<Either<ErrorItem, ModelConfigHttpRequest>>`.
/// - Removed from the active set when the future completes (success/failure).
///
/// Error handling:
/// - This bloc assumes that lower layers (Service/Gateway/Repository) map
///   all failures into [ErrorItem] and never throw.
/// - If an exception bubbles up, it is considered a programming/configuration
///   error outside this bloc's responsibility.
///
/// Typical usage:
/// ```dart
/// final RepositoryHttpRequest repository = MyRepositoryHttpRequestImpl();
/// final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
///   get: UsecaseHttpRequestGet(repository),
///   post: UsecaseHttpRequestPost(repository),
///   put: UsecaseHttpRequestPut(repository),
///   delete: UsecaseHttpRequestDelete(repository),
///   retry: UsecaseHttpRequestRetry(repository),
/// );
///
/// final BlocHttpRequest blocHttpRequest = BlocHttpRequest(facade);
///
/// // In a feature bloc:
/// Future<void> loadProfile() async {
///   const String requestKey = 'userProfile.fetchMe';
///
///   final Either<ErrorItem, ModelConfigHttpRequest> result =
///       await blocHttpRequest.get(
///     requestKey: requestKey,
///     uri: Uri.parse('https://api.example.com/v1/users/me'),
///     metadata: <String, dynamic>{
///       'feature': 'userProfile',
///       'operation': 'fetchMe',
///     },
///   );
///
///   // Use result locally (success/failure)
/// }
///
/// // Somewhere else, to observe active requests:
/// blocHttpRequest.stream.listen((Set<String> active) {
///   debugPrint('Active HTTP requests: $active');
/// });
///
/// // Or using the BlocGeneral wiring:
/// blocHttpRequest.addFunctionToProcessActiveRequestsOnStream(
///   'logger',
///   (Set<String> active) => debugPrint('Active: $active'),
///   true,
/// );
/// ```
class BlocHttpRequest {
  /// Creates a new [BlocHttpRequest] with the given [facade].
  BlocHttpRequest(this._facade) : _bloc = BlocGeneral<Set<String>>(<String>{});

  /// Facade that groups all HTTP-related use cases.
  final FacadeHttpRequestUsecases _facade;

  /// Central reactive container for all **active** HTTP requests.
  ///
  /// Each entry in the set is an application-defined `requestKey`, which may
  /// represent a feature/operation (e.g. `"userProfile.fetchMe"`) or a more
  /// detailed identifier.
  final BlocGeneral<Set<String>> _bloc;

  /// Returns the current snapshot of active HTTP request keys.
  Set<String> get activeRequests => _bloc.value;

  /// Stream of active HTTP request keys.
  Stream<Set<String>> get stream => _bloc.stream;

  /// Returns `true` if the given [requestKey] is currently active.
  bool isActive(String requestKey) => _bloc.value.contains(requestKey);

  /// Marks [requestKey] as inactive if present.
  ///
  /// Normally this is handled internally, but it is provided in case the
  /// application needs to forcefully clear a stuck entry.
  void clear(String requestKey) {
    if (!_bloc.value.contains(requestKey)) {
      return;
    }
    final Set<String> next = Set<String>.from(_bloc.value)..remove(requestKey);
    _bloc.value = next;
  }

  /// Clears all active HTTP request keys.
  void clearAll() {
    if (_bloc.value.isEmpty) {
      return;
    }
    _bloc.value = <String>{};
  }

  // ---------------------------------------------------------------------------
  // 1) High-level HTTP operations: GET / POST / PUT / DELETE / RETRY
  // ---------------------------------------------------------------------------

  /// Executes a GET request and tracks [requestKey] as active while running.
  ///
  /// Returns the same [Either] produced by the underlying use case.
  Future<Either<ErrorItem, ModelConfigHttpRequest>> get({
    required String requestKey,
    required Uri uri,
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    _markActive(requestKey);
    final Either<ErrorItem, ModelConfigHttpRequest> result = await _facade.get(
      uri,
      headers: headers,
      timeout: timeout,
      metadata: metadata,
    );
    _markInactive(requestKey);
    return result;
  }

  /// Executes a POST request and tracks [requestKey] as active while running.
  Future<Either<ErrorItem, ModelConfigHttpRequest>> post({
    required String requestKey,
    required Uri uri,
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    _markActive(requestKey);
    final Either<ErrorItem, ModelConfigHttpRequest> result = await _facade.post(
      uri,
      headers: headers,
      body: body,
      timeout: timeout,
      metadata: metadata,
    );
    _markInactive(requestKey);
    return result;
  }

  /// Executes a PUT request and tracks [requestKey] as active while running.
  Future<Either<ErrorItem, ModelConfigHttpRequest>> put({
    required String requestKey,
    required Uri uri,
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    _markActive(requestKey);
    final Either<ErrorItem, ModelConfigHttpRequest> result = await _facade.put(
      uri,
      headers: headers,
      body: body,
      timeout: timeout,
      metadata: metadata,
    );
    _markInactive(requestKey);
    return result;
  }

  /// Executes a DELETE request and tracks [requestKey] as active while running.
  Future<Either<ErrorItem, ModelConfigHttpRequest>> delete({
    required String requestKey,
    required Uri uri,
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    _markActive(requestKey);
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _facade.delete(
      uri,
      headers: headers,
      timeout: timeout,
      metadata: metadata,
    );
    _markInactive(requestKey);
    return result;
  }

  /// Retries a previous configuration and tracks [requestKey] as active while running.
  ///
  /// It is the caller's responsibility to provide a meaningful [requestKey],
  /// which may or may not be the same as the original call.
  Future<Either<ErrorItem, ModelConfigHttpRequest>> retry({
    required String requestKey,
    required ModelConfigHttpRequest previousConfig,
    Map<String, dynamic> extraMetadata = const <String, dynamic>{},
  }) async {
    _markActive(requestKey);
    final Either<ErrorItem, ModelConfigHttpRequest> result =
        await _facade.retry(
      previousConfig,
      extraMetadata: extraMetadata,
    );
    _markInactive(requestKey);
    return result;
  }

  // ---------------------------------------------------------------------------
  // 2) BlocGeneral wiring helpers
  // ---------------------------------------------------------------------------

  /// Adds a function to be called each time the active requests set changes.
  ///
  /// This is a thin wrapper over [BlocGeneral.addFunctionToProcessTValueOnStream].
  ///
  /// Example:
  /// ```dart
  /// blocHttpRequest.addFunctionToProcessActiveRequestsOnStream(
  ///   'logger',
  ///   (Set<String> active) => debugPrint('Active: $active'),
  ///   true,
  /// );
  /// ```
  void addFunctionToProcessActiveRequestsOnStream(
    String key,
    void Function(Set<String> active) function, [
    bool executeNow = false,
  ]) {
    _bloc.addFunctionToProcessTValueOnStream(
      key,
      function,
      executeNow,
    );
  }

  /// Removes a previously registered function associated with [key].
  ///
  /// This is a thin wrapper over [BlocGeneral.deleteFunctionToProcessTValueOnStream].
  void deleteFunctionToProcessActiveRequestsOnStream(String key) {
    _bloc.deleteFunctionToProcessTValueOnStream(key);
  }

  /// Returns `true` if a function with the specified [key] is registered.
  ///
  /// This is a thin wrapper over [BlocGeneral.containsKeyFunction].
  bool containsKeyFunction(String key) {
    return _bloc.containsKeyFunction(key);
  }

  // ---------------------------------------------------------------------------
  // 3) Internal helpers
  // ---------------------------------------------------------------------------

  void _markActive(String requestKey) {
    final Set<String> next = Set<String>.from(_bloc.value)..add(requestKey);
    _bloc.value = next;
  }

  void _markInactive(String requestKey) {
    if (!_bloc.value.contains(requestKey)) {
      return;
    }
    final Set<String> next = Set<String>.from(_bloc.value)..remove(requestKey);
    _bloc.value = next;
  }

  /// Disposes the internal [BlocGeneral].
  void dispose() {
    _bloc.dispose();
  }

  bool get hasActiveRequests => _bloc.value.isNotEmpty;
}
