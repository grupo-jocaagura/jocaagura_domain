part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Defines a virtual CRUD-like service used mainly in tests and local simulations.
///
/// Implementations typically follow this flow:
/// 1) Call [canHandle] to decide whether the service can resolve the incoming [RequestContext].
/// 2) If `true`, call [handle] to produce a JSON-like payload.
/// 3) Call [reset] between tests to keep internal state deterministic.
///
/// Contract:
/// - [canHandle] must be a pure, fast predicate with no side effects.
/// - [handle] must return a JSON-like map (only values that are JSON-encodable
///   in practice: num, bool, String, null, List, Map).
/// - [reset] must clear any in-memory state so tests remain isolated.
///
/// Error behavior:
/// - If [handle] is called with a context that the service cannot handle,
///   the implementation should throw a [StateError] (recommended) or return a
///   well-defined error payload. Pick one approach and keep it consistent.
///
/// This abstraction does not prescribe routing rules (priority/order) when multiple
/// services can handle the same request.
abstract class VirtualCrudService {
  /// Returns `true` if this service can resolve the incoming request.
  bool canHandle(RequestContext ctx);

  /// Handles the request and returns a JSON-like payload.
  ///
  /// Implementations should be deterministic for a given [ctx].
  Future<Map<String, dynamic>> handle(RequestContext ctx);

  /// Resets any internal state to keep tests isolated and deterministic.
  void reset();
}
