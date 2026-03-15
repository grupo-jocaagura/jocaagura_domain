part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelSheetColumn].
enum ModelSheetColumnEnum {
  name,
  type,
  required,
  defaultValue,
  isPrimaryKey,
}

/// Canonical column types supported by normalized sheet tables.
enum ModelSheetColumnTypeEnum {
  string,
  integer,
  number,
  boolean,
  dateTime,
  json,
}

/// Structural definition of a normalized table column.
class ModelSheetColumn extends Model {
  const ModelSheetColumn({
    required this.name,
    required this.type,
    required this.required,
    required this.isPrimaryKey,
    this.defaultValue,
  });

  factory ModelSheetColumn.fromJson(Map<String, dynamic> json) {
    return ModelSheetColumn(
      name: Utils.getStringFromDynamic(json[ModelSheetColumnEnum.name.name]),
      type: Utils.enumFromJson<ModelSheetColumnTypeEnum>(
        ModelSheetColumnTypeEnum.values,
        Utils.getStringFromDynamic(json[ModelSheetColumnEnum.type.name]),
        ModelSheetColumnTypeEnum.string,
      ),
      required: Utils.getBoolFromDynamic(
        json[ModelSheetColumnEnum.required.name],
      ),
      defaultValue: json.containsKey(ModelSheetColumnEnum.defaultValue.name)
          ? json[ModelSheetColumnEnum.defaultValue.name]
          : null,
      isPrimaryKey: Utils.getBoolFromDynamic(
        json[ModelSheetColumnEnum.isPrimaryKey.name],
      ),
    );
  }

  final String name;
  final ModelSheetColumnTypeEnum type;
  final bool required;
  final dynamic defaultValue;
  final bool isPrimaryKey;

  @override
  ModelSheetColumn copyWith({
    String? name,
    ModelSheetColumnTypeEnum? type,
    bool? required,
    Object? defaultValue = _sheetUnset,
    bool? isPrimaryKey,
  }) {
    return ModelSheetColumn(
      name: name ?? this.name,
      type: type ?? this.type,
      required: required ?? this.required,
      defaultValue: identical(defaultValue, _sheetUnset)
          ? this.defaultValue
          : defaultValue,
      isPrimaryKey: isPrimaryKey ?? this.isPrimaryKey,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelSheetColumnEnum.name.name: name,
      ModelSheetColumnEnum.type.name: type.name,
      ModelSheetColumnEnum.required.name: required,
      ModelSheetColumnEnum.isPrimaryKey.name: isPrimaryKey,
    };
    if (defaultValue != _sheetUnset) {
      json[ModelSheetColumnEnum.defaultValue.name] = defaultValue;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelSheetColumn &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          required == other.required &&
          Utils.deepEqualsDynamic(defaultValue, other.defaultValue) &&
          isPrimaryKey == other.isPrimaryKey;

  @override
  int get hashCode => Object.hash(
        name,
        type,
        required,
        Utils.deepHash(defaultValue),
        isPrimaryKey,
      );

  @override
  String toString() => 'ModelSheetColumn(${toJson()})';
}

const Object _sheetUnset = Object();
