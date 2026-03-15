import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelSheetTable', () {
    const ModelSheetColumn pkColumn = ModelSheetColumn(
      name: 'customerId',
      type: ModelSheetColumnTypeEnum.string,
      required: true,
      isPrimaryKey: true,
    );

    const ModelSheetColumn nameColumn = ModelSheetColumn(
      name: 'fullName',
      type: ModelSheetColumnTypeEnum.string,
      required: true,
      defaultValue: '',
      isPrimaryKey: false,
    );

    const ModelSheetTable table = ModelSheetTable(
      id: 'tbl_customers',
      name: 'customers',
      primaryKeyColumn: 'customerId',
      columns: <ModelSheetColumn>[
        pkColumn,
        nameColumn,
      ],
      rowsCount: 128,
    );

    test(
      'Given a canonical table When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = table.toJson();
        final ModelSheetTable roundtrip = ModelSheetTable.fromJson(json);

        expect(roundtrip, table);
        expect(roundtrip.toJson(), table.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelSheetTableEnum.id.name: 'tbl_customers',
          ModelSheetTableEnum.name.name: 'customers',
          ModelSheetTableEnum.primaryKeyColumn.name: 'customerId',
          ModelSheetTableEnum.columns.name: <Map<String, dynamic>>[
            pkColumn.toJson(),
            nameColumn.toJson(),
          ],
          ModelSheetTableEnum.rowsCount.name: 128,
        };

        final ModelSheetTable parsed = ModelSheetTable.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a table When copyWith overrides fields Then returns updated copy',
      () {
        final ModelSheetTable copy = table.copyWith(
          name: 'customers_archive',
          rowsCount: null,
        );

        expect(copy.name, 'customers_archive');
        expect(copy.rowsCount, isNull);
        expect(copy.primaryKeyColumn, table.primaryKeyColumn);
        expect(copy.columns, table.columns);
        expect(copy, isNot(table));
      },
    );
  });
}
