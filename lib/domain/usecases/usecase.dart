part of '../../../jocaagura_domain.dart';

/// Defines the base contract for application use cases.
///
/// A use case receives an input of type `P` and asynchronously produces a
/// result of type `T`. Implementations should document their preconditions,
/// postconditions, and error behavior (exceptions vs. domain error types).
///
/// ### Example
/// ```dart
/// void main() async {
///   // Example use case returning a String with no input parameters.
///   final UseCase<String, NoParams> ping = _PingUseCase();
///   final String out = await ping(const NoParams());
///   print(out); // "pong"
/// }
///
/// class _PingUseCase implements UseCase<String, NoParams> {
///   @override
///   Future<String> call(NoParams params) async => 'pong';
/// }
/// ```
abstract class UseCase<T, P> {
  Future<T> call(P params);
}
