part of '../jocaagura_domain.dart';

/// Represents a value that can be one of two possible branches: [Left] or
/// [Right].
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
  const Either();

  /// Executes one function depending on whether this value is [Left] or [Right].
  ///
  /// If the value is a [Left], the [left] function is executed with the value
  /// of type [L]. If the value is a [Right], the [right] function is executed
  /// with the value of type [R].
  ///
  /// The generic type [T] is the common return type produced by both branches.
  /// It does not cast or reinterpret this [Either] as [T].
  ///
  /// Prefer [map] when only the [Right] value must be transformed.
  /// Prefer [mapLeft] when only the [Left] value must be transformed.
  /// Prefer [match] when both branches must be resolved explicitly.
  ///
  /// Example:
  /// ```dart
  /// final String label = result.when<String>(
  ///   (String error) => 'error: $error',
  ///   (int value) => 'value: $value',
  /// );
  /// ```
  T when<T>(T Function(L) left, T Function(R) right) {
    return match<T>(left: left, right: right);
  }

  /// Indicates whether the value is of type [Left].
  bool get isLeft => this is Left<L, R>;

  /// Indicates whether the value is of type [Right].
  bool get isRight => this is Right<L, R>;

  /// Resolves both branches explicitly and returns a common type [T].
  ///
  /// Use this when both [Left] and [Right] need custom handling and both
  /// handlers must produce the same output type.
  ///
  /// Example:
  /// ```dart
  /// final int code = result.match<int>(
  ///   left: (String error) => -1,
  ///   right: (int value) => value,
  /// );
  /// ```
  T match<T>({
    required T Function(L left) left,
    required T Function(R right) right,
  }) {
    if (this is Left<L, R>) {
      return left((this as Left<L, R>).value);
    }
    return right((this as Right<L, R>).value);
  }

  /// Transforms the [Right] value while preserving any [Left] unchanged.
  ///
  /// Use this when only the successful value must be projected into another
  /// type.
  ///
  /// Example:
  /// ```dart
  /// final Either<String, String> text = result.map<String>(
  ///   (int value) => value.toString(),
  /// );
  /// ```
  Either<L, T> map<T>(T Function(R right) transform) {
    if (this is Left<L, R>) {
      return Left<L, T>((this as Left<L, R>).value);
    }
    return Right<L, T>(transform((this as Right<L, R>).value));
  }

  /// Transforms the [Left] value while preserving any [Right] unchanged.
  ///
  /// Use this when only the error or alternative branch must be mapped.
  ///
  /// Example:
  /// ```dart
  /// final Either<ErrorItem, int> mapped = result.mapLeft<ErrorItem>(
  ///   (String message) => ErrorItem(...),
  /// );
  /// ```
  Either<T, R> mapLeft<T>(T Function(L left) transform) {
    if (this is Left<L, R>) {
      return Left<T, R>(transform((this as Left<L, R>).value));
    }
    return Right<T, R>((this as Right<L, R>).value);
  }

  /// Chains another operation that also returns an [Either].
  ///
  /// If this value is [Left], the original left value is preserved. If this
  /// value is [Right], [transform] is executed and its result is returned.
  ///
  /// Example:
  /// ```dart
  /// return documentResult.flatMap<ModelUser>(
  ///   (ModelPersistedDocument document) => ModelUser.fromDocument(document),
  /// );
  /// ```
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) transform) {
    if (this is Left<L, R>) {
      return Left<L, T>((this as Left<L, R>).value);
    }
    return transform((this as Right<L, R>).value);
  }

  /// Executes [action] when this value is [Left] without changing the result.
  ///
  /// This is useful for logs, metrics or traces.
  ///
  /// Example:
  /// ```dart
  /// return result.onLeft((ErrorItem error) => logger.warning(error.code));
  /// ```
  Either<L, R> onLeft(void Function(L left) action) {
    if (this is Left<L, R>) {
      action((this as Left<L, R>).value);
    }
    return this;
  }

  /// Executes [action] when this value is [Right] without changing the result.
  ///
  /// This is useful for logs, metrics or traces.
  ///
  /// Example:
  /// ```dart
  /// return result.onRight((ModelUser user) => logger.info(user.id));
  /// ```
  Either<L, R> onRight(void Function(R right) action) {
    if (this is Right<L, R>) {
      action((this as Right<L, R>).value);
    }
    return this;
  }

  /// Executes one of the provided functions depending on the value type.
  ///
  /// This is kept for compatibility with existing code. Prefer [match] in new
  /// code when both branches must be resolved explicitly, [map] when only the
  /// [Right] value must change, and [mapLeft] when only the [Left] value must
  /// change.
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return match<T>(left: onLeft, right: onRight);
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
