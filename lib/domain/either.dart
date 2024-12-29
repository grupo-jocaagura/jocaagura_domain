part of '../jocaagura_domain.dart';

/// An abstract class representing an `Either` type, which can hold a value of
/// one of two types: [L] or [R].
///
/// This is commonly used to represent operations that can either succeed with
/// a value of type [R] or fail with a value of type [L].
///
/// Example usage:
///
/// ```dart
/// Either<String, int> divide(int a, int b) {
///   if (b == 0) {
///     return Left('Division by zero');
///   } else {
///     return Right(a ~/ b);
///   }
/// }
///
/// void main() {
///   final result = divide(10, 0);
///   result.when(
///     (error) => print('Error: $error'),
///     (value) => print('Result: $value'),
///   );
/// }
/// ```
@immutable
abstract class Either<L, R> {
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
  Left(this.value);

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
  Right(this.value);

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
