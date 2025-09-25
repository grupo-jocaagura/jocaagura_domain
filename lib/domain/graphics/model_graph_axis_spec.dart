part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enum for [ModelGraphAxisSpec] JSON fields.
enum ModelGraphAxisSpecEnum {
  /// Human-readable axis title (e.g., "Month", "Price").
  title,

  /// Inclusive minimum bound of the axis range.
  min,

  /// Inclusive maximum bound of the axis range.
  max,
}

/// Default X axis: title "X", range [0, 10].
const ModelGraphAxisSpec defaultXAxisSpec = ModelGraphAxisSpec(
  title: 'X',
  min: 0.0,
  max: 10.0,
);

/// Default Y axis: title "Y", range [0, 100].
const ModelGraphAxisSpec defaultYAxisSpec = ModelGraphAxisSpec(
  title: 'Y',
  min: 0.0,
  max: 100.0,
);

/// Describes metadata for a simple 2D chart axis.
///
/// Holds a human-readable [title] and an inclusive numeric range
/// defined by [min] and [max]. The model is immutable and supports
/// JSON (de)serialization and value-based equality.
///
/// **Contracts**
/// - `fromJson` is lenient and never throws:
///   - [title] is stringified via `Utils.getStringFromDynamic`.
///   - [min] and [max] are parsed via `Utils.getDouble`, which may return
///     `double.nan` for invalid inputs.
/// - No invariant checks are enforced here:
///   - `min` may be greater than `max`.
///   - Non-finite values (`NaN`, `±Infinity`) may be accepted.
///   Validate these in higher layers if required.
///
/// **Example**
/// ```dart
/// void main() {
///   // Construction
///   const GraphAxisSpec x = GraphAxisSpec(title: 'Month', min: 1.0, max: 12.0);
///   const GraphAxisSpec y = GraphAxisSpec(title: 'Price', min: 55000.0, max: 65000.0);
///   print(x.toJson()); // { "title": "Month", "min": 1.0, "max": 12.0 }
///
///   // JSON round-trip
///   final Map<String, dynamic> j = <String, dynamic>{
///     'title': 'Units',
///     'min': 0,
///     'max': 100,
///   };
///   final GraphAxisSpec a = GraphAxisSpec.fromJson(j);
///   print('${a.title} [${a.min}, ${a.max}]'); // Units [0.0, 100.0]
/// }
/// ```
class ModelGraphAxisSpec extends Model {
  const ModelGraphAxisSpec({
    required this.title,
    required this.min,
    required this.max,
  });

  /// Builds a [ModelGraphAxisSpec] from a JSON map.
  ///
  /// Expected keys: `"title"`, `"min"`, `"max"`.
  /// Never throws; invalid numeric shapes can yield non-finite values.
  factory ModelGraphAxisSpec.fromJson(Map<String, dynamic> json) =>
      ModelGraphAxisSpec(
        title:
            Utils.getStringFromDynamic(json[ModelGraphAxisSpecEnum.title.name]),
        min: Utils.getDouble(json[ModelGraphAxisSpecEnum.min.name]),
        max: Utils.getDouble(json[ModelGraphAxisSpecEnum.max.name]),
      );

  /// Axis title (human-readable).
  final String title;

  /// Inclusive minimum bound.
  final double min;

  /// Inclusive maximum bound.
  final double max;

  /// Returns a copy with optional overrides.
  @override
  ModelGraphAxisSpec copyWith({String? title, double? min, double? max}) =>
      ModelGraphAxisSpec(
        title: title ?? this.title,
        min: min ?? this.min,
        max: max ?? this.max,
      );

  /// Serializes this model to JSON
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelGraphAxisSpecEnum.title.name: title,
        ModelGraphAxisSpecEnum.min.name: min,
        ModelGraphAxisSpecEnum.max.name: max,
      };

  @override
  int get hashCode => Object.hash(title, min, max);

  /// Value-based equality on [title], [min], and [max].
  @override
  bool operator ==(Object other) =>
      other is ModelGraphAxisSpec &&
      other.title == title &&
      other.min == min &&
      other.max == max;
}
