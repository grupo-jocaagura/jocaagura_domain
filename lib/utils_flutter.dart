import 'dart:ui' show Offset;

import 'package:jocaagura_domain_core/jocaagura_domain_models.dart'
    show ModelVector;

/// Flutter conversions for canonical core values.
///
/// Import `package:jocaagura_domain/jocaagura_domain.dart` to use these helpers.
/// Replace `ModelVector.fromOffset(value)` with
/// `UtilsFlutter.fromOffset(value)`, and `vector.offset` with
/// `UtilsFlutter.toOffset(vector)`.
abstract final class UtilsFlutter {
  /// Copies both [offset] components into a canonical [ModelVector].
  ///
  /// Preserves doubles without rounding, clamping or validation, including
  /// signed zero, infinity and NaN, as the historical factory did.
  static ModelVector fromOffset(Offset offset) =>
      ModelVector(offset.dx, offset.dy);

  /// Copies both [vector] components into a Flutter [Offset].
  ///
  /// Preserves doubles without rounding, clamping or validation, as the
  /// historical `ModelVector.offset` getter did.
  static Offset toOffset(ModelVector vector) => Offset(vector.dx, vector.dy);
}
