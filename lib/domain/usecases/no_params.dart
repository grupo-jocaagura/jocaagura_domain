part of '../../../jocaagura_domain.dart';

/// Represents the absence of input parameters.
///
/// Use this as the `P` type for [UseCase] implementations that do not require
/// any input. Prefer using `const NoParams()` to benefit from canonicalization.
///
/// ### Example
/// ```dart
/// void main() async {
///   // Typical usage with a use case that requires no input:
///   final result = await GetAppVersionUseCase()(const NoParams());
///   print('version: $result');
/// }
/// ```
class NoParams {
  const NoParams();
}
