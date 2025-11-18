part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Use case for executing an HTTP GET request through [RepositoryHttpRequest].
///
/// This use case encapsulates the common parameters required to issue a GET
/// and returns a domain-level [ModelConfigHttpRequest] describing the call.
///
/// Typical usage from a feature use case:
/// ```dart
/// class UsecaseUserFetchProfile {
///   const UsecaseUserFetchProfile(this._httpGet);
///
///   final UsecaseHttpRequestGet _httpGet;
///
///   Future<Either<ErrorItem, ModelConfigHttpRequest>> call() {
///     final Uri uri = Uri.parse('https://api.example.com/v1/users/me');
///     return _httpGet(
///       uri,
///       metadata: <String, Object?>{
///         'feature': 'userProfile',
///         'operation': 'fetchMe',
///       },
///     );
///   }
/// }
/// ```
class UsecaseHttpRequestGet {
  /// Creates a new [UsecaseHttpRequestGet] bound to a [RepositoryHttpRequest].
  const UsecaseHttpRequestGet(this._repository);

  final RepositoryHttpRequest _repository;

  /// Executes a GET request against the given [uri].
  ///
  /// Parameters:
  /// - [uri]: Target endpoint.
  /// - [headers]: Optional HTTP headers.
  /// - [timeout]: Optional per-request timeout.
  /// - [metadata]: Free-form metadata for diagnostics/telemetry.
  ///
  /// Returns:
  /// - `Either.left(ErrorItem)` when the repository detects a failure.
  /// - `Either.right(ModelConfigHttpRequest)` on success.
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return _repository.get(
      uri,
      headers: headers,
      timeout: timeout,
      metadata: metadata,
    );
  }
}

/// Use case for executing an HTTP POST request through [RepositoryHttpRequest].
///
/// This use case is responsible for issuing POST operations and returning a
/// domain-level [ModelConfigHttpRequest].
///
/// Example:
/// ```dart
/// class UsecaseAuthLogin {
///   const UsecaseAuthLogin(this._httpPost);
///
///   final UsecaseHttpRequestPost _httpPost;
///
///   Future<Either<ErrorItem, ModelConfigHttpRequest>> call({
///     required String username,
///     required String password,
///   }) {
///     final Uri uri = Uri.parse('https://api.example.com/v1/auth/login');
///     final Map<String, dynamic> body = <String, dynamic>{
///       'username': username,
///       'password': password,
///     };
///
///     return _httpPost(
///       uri,
///       body: body,
///       metadata: <String, Object?>{'feature': 'auth', 'operation': 'login'},
///     );
///   }
/// }
/// ```
class UsecaseHttpRequestPost {
  /// Creates a new [UsecaseHttpRequestPost] bound to a [RepositoryHttpRequest].
  const UsecaseHttpRequestPost(this._repository);

  final RepositoryHttpRequest _repository;

  /// Executes a POST request against the given [uri].
  ///
  /// Parameters:
  /// - [uri]: Target endpoint.
  /// - [headers]: Optional HTTP headers.
  /// - [body]: Optional JSON-like payload (`Map`, `List`, primitives).
  /// - [timeout]: Optional per-request timeout.
  /// - [metadata]: Free-form metadata for diagnostics/telemetry.
  ///
  /// Returns:
  /// - `Either.left(ErrorItem)` when the repository detects a failure.
  /// - `Either.right(ModelConfigHttpRequest)` on success.
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return _repository.post(
      uri,
      headers: headers,
      body: body,
      timeout: timeout,
      metadata: metadata,
    );
  }
}

/// Use case for executing an HTTP PUT request through [RepositoryHttpRequest].
///
/// Used to perform idempotent update operations while keeping the domain
/// uncluttered from transport details.
///
/// Example:
/// ```dart
/// class UsecaseUserUpdateProfile {
///   const UsecaseUserUpdateProfile(this._httpPut);
///
///   final UsecaseHttpRequestPut _httpPut;
///
///   Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
///     Map<String, dynamic> patch,
///   ) {
///     final Uri uri = Uri.parse('https://api.example.com/v1/users/me');
///
///     return _httpPut(
///       uri,
///       body: patch,
///       metadata: <String, Object?>{
///         'feature': 'userProfile',
///         'operation': 'updateMe',
///       },
///     );
///   }
/// }
/// ```
class UsecaseHttpRequestPut {
  /// Creates a new [UsecaseHttpRequestPut] bound to a [RepositoryHttpRequest].
  const UsecaseHttpRequestPut(this._repository);

  final RepositoryHttpRequest _repository;

  /// Executes a PUT request against the given [uri].
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> body = const <String, dynamic>{},
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return _repository.put(
      uri,
      headers: headers,
      body: body,
      timeout: timeout,
      metadata: metadata,
    );
  }
}

/// Use case for executing an HTTP DELETE request through [RepositoryHttpRequest].
///
/// Example:
/// ```dart
/// class UsecaseUserDeleteSession {
///   const UsecaseUserDeleteSession(this._httpDelete);
///
///   final UsecaseHttpRequestDelete _httpDelete;
///
///   Future<Either<ErrorItem, ModelConfigHttpRequest>> call() {
///     final Uri uri = Uri.parse('https://api.example.com/v1/sessions/current');
///     return _httpDelete(
///       uri,
///       metadata: <String, Object?>{
///         'feature': 'auth',
///         'operation': 'logout',
///       },
///     );
///   }
/// }
/// ```
class UsecaseHttpRequestDelete {
  /// Creates a new [UsecaseHttpRequestDelete] bound to a [RepositoryHttpRequest].
  const UsecaseHttpRequestDelete(this._repository);

  final RepositoryHttpRequest _repository;

  /// Executes a DELETE request against the given [uri].
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return _repository.delete(
      uri,
      headers: headers,
      timeout: timeout,
      metadata: metadata,
    );
  }
}

/// Use case for retrying a previously configured HTTP request.
///
/// This use case is method-aware: it inspects [ModelConfigHttpRequest.method]
/// and delegates to the appropriate repository call (GET, POST, PUT, DELETE).
///
/// Typical usage:
/// ```dart
/// Future<Either<ErrorItem, ModelConfigHttpRequest>> retryLastCall(
///   UsecaseHttpRequestRetry retry,
///   ModelConfigHttpRequest lastConfig,
/// ) {
///   return retry(
///     lastConfig,
///     extraMetadata: <String, Object?>{'retry': true},
///   );
/// }
/// ```
class UsecaseHttpRequestRetry {
  /// Creates a new [UsecaseHttpRequestRetry] bound to a [RepositoryHttpRequest].
  const UsecaseHttpRequestRetry(this._repository);

  final RepositoryHttpRequest _repository;

  /// Retries the given [previousConfig], optionally enriching [extraMetadata].
  ///
  /// The final metadata passed to the repository will be:
  /// `previousConfig.metadata` merged with [extraMetadata], where
  /// [extraMetadata] wins on key collisions.
  Future<Either<ErrorItem, ModelConfigHttpRequest>> call(
    ModelConfigHttpRequest previousConfig, {
    Map<String, dynamic> extraMetadata = const <String, dynamic>{},
  }) {
    final Map<String, dynamic> mergedMetadata = <String, dynamic>{
      ...previousConfig.metadata,
      ...extraMetadata,
    };

    switch (previousConfig.method) {
      case HttpMethodEnum.get:
        return _repository.get(
          previousConfig.uri,
          headers: previousConfig.headers,
          timeout: previousConfig.timeout,
          metadata: mergedMetadata,
        );
      case HttpMethodEnum.post:
        return _repository.post(
          previousConfig.uri,
          headers: previousConfig.headers,
          body: previousConfig.body,
          timeout: previousConfig.timeout,
          metadata: mergedMetadata,
        );
      case HttpMethodEnum.put:
        return _repository.put(
          previousConfig.uri,
          headers: previousConfig.headers,
          body: previousConfig.body,
          timeout: previousConfig.timeout,
          metadata: mergedMetadata,
        );
      case HttpMethodEnum.patch:
        // If PATCH is added to RepositoryHttpRequest in the future, this
        // branch can be updated accordingly. For now it falls back to POST.
        return _repository.post(
          previousConfig.uri,
          headers: previousConfig.headers,
          body: previousConfig.body,
          timeout: previousConfig.timeout,
          metadata: mergedMetadata,
        );
      case HttpMethodEnum.delete:
        return _repository.delete(
          previousConfig.uri,
          headers: previousConfig.headers,
          timeout: previousConfig.timeout,
          metadata: mergedMetadata,
        );
    }
  }
}

/// Facade aggregating all HTTP request use cases.
///
/// This class is meant to be injected into blocs/managers that need to issue
/// HTTP calls in a centralized and testable way, without depending on the
/// underlying [RepositoryHttpRequest] directly.
///
/// Example:
/// ```dart
/// class BlocSomeFeature {
///   BlocSomeFeature(this._http);
///
///   final FacadeHttpRequestUsecases _http;
///
///   Future<void> loadData() async {
///     final Uri uri = Uri.parse('https://api.example.com/v1/data');
///     final Either<ErrorItem, ModelConfigHttpRequest> result = await _http.get(
///       uri,
///       metadata: <String, Object?>{'feature': 'someFeature'},
///     );
///
///     result.fold(
///       (ErrorItem error) {
///         // Handle error in the feature bloc.
///       },
///       (ModelConfigHttpRequest config) {
///         // Optionally store config for retry/telemetry.
///       },
///     );
///   }
/// }
/// ```
class FacadeHttpRequestUsecases {
  /// Creates a new [FacadeHttpRequestUsecases] grouping all HTTP use cases.
  const FacadeHttpRequestUsecases({
    required this.get,
    required this.post,
    required this.put,
    required this.delete,
    required this.retry,
  });

  /// Use case for GET operations.
  final UsecaseHttpRequestGet get;

  /// Use case for POST operations.
  final UsecaseHttpRequestPost post;

  /// Use case for PUT operations.
  final UsecaseHttpRequestPut put;

  /// Use case for DELETE operations.
  final UsecaseHttpRequestDelete delete;

  /// Use case for retrying a previous HTTP configuration.
  final UsecaseHttpRequestRetry retry;
}
