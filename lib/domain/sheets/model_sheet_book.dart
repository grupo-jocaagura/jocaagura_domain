part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelSheetBook].
enum ModelSheetBookEnum {
  id,
  name,
  tables,
}

/// Logical book that groups normalized tables.
class ModelSheetBook extends Model {
  const ModelSheetBook({
    required this.id,
    required this.name,
    required this.tables,
  });

  factory ModelSheetBook.fromJson(Map<String, dynamic> json) {
    return ModelSheetBook(
      id: Utils.getStringFromDynamic(json[ModelSheetBookEnum.id.name]),
      name: Utils.getStringFromDynamic(json[ModelSheetBookEnum.name.name]),
      tables: Utils.listFromDynamic(json[ModelSheetBookEnum.tables.name])
          .map((Map<String, dynamic> e) => ModelSheetTable.fromJson(e))
          .toList(),
    );
  }

  final String id;
  final String name;
  final List<ModelSheetTable> tables;

  @override
  ModelSheetBook copyWith({
    String? id,
    String? name,
    List<ModelSheetTable>? tables,
  }) {
    return ModelSheetBook(
      id: id ?? this.id,
      name: name ?? this.name,
      tables: tables ?? this.tables,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelSheetBookEnum.id.name: id,
        ModelSheetBookEnum.name.name: name,
        ModelSheetBookEnum.tables.name:
            tables.map((ModelSheetTable e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelSheetBook &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          Utils.listEquals(tables, other.tables);

  @override
  int get hashCode => Object.hash(id, name, Utils.listHash(tables));

  @override
  String toString() => 'ModelSheetBook(${toJson()})';
}
