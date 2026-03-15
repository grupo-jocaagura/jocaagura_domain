part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Stable JSON keys used by [ModelSheetTable].
enum ModelSheetTableEnum {
  id,
  name,
  primaryKeyColumn,
  columns,
  rowsCount,
}

/// Structural definition of a normalized sheet table.
class ModelSheetTable extends Model {
  const ModelSheetTable({
    required this.id,
    required this.name,
    required this.primaryKeyColumn,
    required this.columns,
    this.rowsCount,
  });

  factory ModelSheetTable.fromJson(Map<String, dynamic> json) {
    return ModelSheetTable(
      id: Utils.getStringFromDynamic(json[ModelSheetTableEnum.id.name]),
      name: Utils.getStringFromDynamic(json[ModelSheetTableEnum.name.name]),
      primaryKeyColumn: Utils.getStringFromDynamic(
        json[ModelSheetTableEnum.primaryKeyColumn.name],
      ),
      columns: Utils.listFromDynamic(json[ModelSheetTableEnum.columns.name])
          .map((Map<String, dynamic> e) => ModelSheetColumn.fromJson(e))
          .toList(),
      rowsCount: json.containsKey(ModelSheetTableEnum.rowsCount.name)
          ? Utils.getIntegerFromDynamic(
              json[ModelSheetTableEnum.rowsCount.name],
            )
          : null,
    );
  }

  final String id;
  final String name;
  final String primaryKeyColumn;
  final List<ModelSheetColumn> columns;
  final int? rowsCount;

  @override
  ModelSheetTable copyWith({
    String? id,
    String? name,
    String? primaryKeyColumn,
    List<ModelSheetColumn>? columns,
    Object? rowsCount = _sheetUnset,
  }) {
    return ModelSheetTable(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryKeyColumn: primaryKeyColumn ?? this.primaryKeyColumn,
      columns: columns ?? this.columns,
      rowsCount: identical(rowsCount, _sheetUnset)
          ? this.rowsCount
          : rowsCount as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      ModelSheetTableEnum.id.name: id,
      ModelSheetTableEnum.name.name: name,
      ModelSheetTableEnum.primaryKeyColumn.name: primaryKeyColumn,
      ModelSheetTableEnum.columns.name:
          columns.map((ModelSheetColumn e) => e.toJson()).toList(),
    };
    if (rowsCount != null) {
      json[ModelSheetTableEnum.rowsCount.name] = rowsCount;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelSheetTable &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          primaryKeyColumn == other.primaryKeyColumn &&
          Utils.listEquals(columns, other.columns) &&
          rowsCount == other.rowsCount;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        primaryKeyColumn,
        Utils.listHash(columns),
        rowsCount,
      );

  @override
  String toString() => 'ModelSheetTable(${toJson()})';
}
