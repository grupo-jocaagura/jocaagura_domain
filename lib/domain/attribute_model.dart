part of '../jocaagura_domain.dart';

enum AttributeEnum {
  name,
  value,
}

class AttributeModel<T> extends Model {
  const AttributeModel({
    required this.value,
    required this.name,
  });

  final T value;
  final String name;

  @override
  AttributeModel<T> copyWith({
    String? name,
    T? value,
  }) =>
      AttributeModel<T>(
        value: value ?? this.value,
        name: name ?? this.name,
      );

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      AttributeEnum.value.name: value,
      AttributeEnum.name.name: name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeModel &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          name == other.name &&
          hashCode == other.hashCode;

  @override
  int get hashCode => '$value$name'.hashCode;

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

AttributeModel<T> attributeModelfromJson<T>(
  Map<String, dynamic> json,
  T Function(dynamic) fromJsonT,
) {
  dynamic value = json['value'];
  value = fromJsonT(value);
  return AttributeModel<T>(
    name: json[AttributeEnum.name.name]?.toString() ?? '',
    value: value as T,
  );
}
