part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelSheetRow].
enum ModelSheetRowEnum {
  idRow,
  data,
}

/// Persisted normalized row payload governed by a table definition.
class ModelSheetRow extends Model {
  const ModelSheetRow({
    required this.idRow,
    required this.data,
  });

  factory ModelSheetRow.fromJson(Map<String, dynamic> json) {
    return ModelSheetRow(
      idRow: Utils.getStringFromDynamic(json[ModelSheetRowEnum.idRow.name]),
      data: Utils.mapFromDynamic(json[ModelSheetRowEnum.data.name]),
    );
  }

  final String idRow;
  final Map<String, dynamic> data;

  @override
  ModelSheetRow copyWith({
    String? idRow,
    Map<String, dynamic>? data,
  }) {
    return ModelSheetRow(
      idRow: idRow ?? this.idRow,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelSheetRowEnum.idRow.name: idRow,
        ModelSheetRowEnum.data.name: data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelSheetRow &&
          runtimeType == other.runtimeType &&
          idRow == other.idRow &&
          Utils.deepEqualsDynamic(data, other.data);

  @override
  int get hashCode => Object.hash(idRow, Utils.deepHash(data));

  @override
  String toString() => 'ModelSheetRow(${toJson()})';
}
