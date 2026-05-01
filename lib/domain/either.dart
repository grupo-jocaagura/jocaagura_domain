part of '../jocaagura_domain.dart';

/// Represents a value that can be either [Left] or [Right].
///
/// Use [Left] to represent a failure or alternative value, and [Right] to
/// represent a successful value.
///
/// Functional example:
/// ```dart
/// Either<String, int> divide(int dividend, int divisor) {
///   if (divisor == 0) {
///     return const Left<String, int>('Division by zero');
///   }
///
///   return Right<String, int>(dividend ~/ divisor);
/// }
///
/// void main() {
///   final Either<String, int> result = divide(10, 2);
///
///   final String message = result.when<String>(
///     (String error) => 'Error: $error',
///     (int value) => 'Result: $value',
///   );
///
///   print(message);
/// }
/// ```
///
/// Contract:
/// - [Left] contains a value of type [L].
/// - [Right] contains a value of type [R].
/// - [when] and [fold] execute only the callback matching the current variant.
@immutable
abstract class Either<L, R> {
  /// Creates an immutable [Either] value.
  const Either();

  /// Executes one of the provided functions depending on the value type.
  ///
  /// If the value is a [Left], the [left] function is executed with the value
  /// of type [L]. If the value is a [Right], the [right] function is executed
  /// with the value of type [R].
  T when<T>(
    T Function(L) left,
    T Function(R) right,
  ) {
    if (this is Left<L, R>) {
      return left((this as Left<L, R>).value);
    }
    return right((this as Right<L, R>).value);
  }

  /// Indicates whether the value is of type [Left].
  bool get isLeft => this is Left<L, R>;

  /// Indicates whether the value is of type [Right].
  bool get isRight => this is Right<L, R>;

  /// Executes one of the provided functions depending on the value type.
  ///
  /// This is similar to [when] but may be more concise in some contexts.
  T fold<T>(
    T Function(L) onLeft,
    T Function(R) onRight,
  ) {
    return this is Left<L, R>
        ? onLeft((this as Left<L, R>).value)
        : onRight((this as Right<L, R>).value);
  }
}

/// Represents a value of type [L] in the [Either] type.
class Left<L, R> extends Either<L, R> {
  /// Constructs a [Left] object containing a value of type [L].
  const Left(this.value);

  /// The value of type [L].
  final L value;

  @override
  bool operator ==(Object other) {
    return other is Left<L, R> &&
        runtimeType == other.runtimeType &&
        value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Represents a value of type [R] in the [Either] type.
class Right<L, R> extends Either<L, R> {
  /// Constructs a [Right] object containing a value of type [R].
  const Right(this.value);

  /// The value of type [R].
  final R value;

  @override
  bool operator ==(Object other) {
    return other is Right<L, R> &&
        runtimeType == other.runtimeType &&
        value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
