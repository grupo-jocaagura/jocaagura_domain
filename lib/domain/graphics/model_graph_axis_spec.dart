part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enum for [GraphAxisSpec] JSON fields.
enum GraphAxisSpecEnum {
  /// Human-readable axis title (e.g., "Month", "Price").
  title,

  /// Inclusive minimum bound of the axis range.
  min,

  /// Inclusive maximum bound of the axis range.
  max,
}

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
class GraphAxisSpec extends Model {
  const GraphAxisSpec({
    required this.title,
    required this.min,
    required this.max,
  });

  /// Builds a [GraphAxisSpec] from a JSON map.
  ///
  /// Expected keys: `"title"`, `"min"`, `"max"`.
  /// Never throws; invalid numeric shapes can yield non-finite values.
  factory GraphAxisSpec.fromJson(Map<String, dynamic> json) => GraphAxisSpec(
        title: Utils.getStringFromDynamic(json[GraphAxisSpecEnum.title.name]),
        min: Utils.getDouble(json[GraphAxisSpecEnum.min.name]),
        max: Utils.getDouble(json[GraphAxisSpecEnum.max.name]),
      );

  /// Axis title (human-readable).
  final String title;

  /// Inclusive minimum bound.
  final double min;

  /// Inclusive maximum bound.
  final double max;

  /// Returns a copy with optional overrides.
  @override
  GraphAxisSpec copyWith({String? title, double? min, double? max}) =>
      GraphAxisSpec(
        title: title ?? this.title,
        min: min ?? this.min,
        max: max ?? this.max,
      );

  /// Serializes this model to JSON
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        GraphAxisSpecEnum.title.name: title,
        GraphAxisSpecEnum.min.name: min,
        GraphAxisSpecEnum.max.name: max,
      };

  @override
  int get hashCode => Object.hash(title, min, max);

  /// Value-based equality on [title], [min], and [max].
  @override
  bool operator ==(Object other) =>
      other is GraphAxisSpec &&
      other.title == title &&
      other.min == min &&
      other.max == max;
}
