part of 'jocaagura_domain.dart';

/// Represents the absence of a meaningful value in a type-safe way.
///
/// Use this when an operation succeeds but has nothing to return.
/// It behaves like a "void value" that can be used in generics (e.g. Either).
///
/// ### Example
///
/// ```dart
/// Future<Either<ErrorItem, Unit>> delete(String docId) async {
///   try {
///     await _service.delete('canvases/$docId');
///     return Right(unit); // success with no payload
///   } catch (e, s) {
///     return Left(ErrorMapper.fromException(e, s));
///   }
/// }
/// ```
///
/// Equality is trivial: any `Unit` equals any other `Unit`. It's a singleton.
@immutable
class Unit {
  const Unit._();

  /// The single instance to use across the codebase.
  static const Unit value = Unit._();

  @override
  String toString() => 'unit';

  @override
  bool operator ==(Object other) => other is Unit;

  @override
  int get hashCode => 0;
}

/// Shorthand constant for the single [Unit] value.
/// Prefer returning `unit` on success in commands with no payload.
const Unit unit = Unit.value;
