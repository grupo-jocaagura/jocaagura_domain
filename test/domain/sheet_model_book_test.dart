import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelSheetBook', () {
    const ModelSheetColumn pkColumn = ModelSheetColumn(
      name: 'customerId',
      type: ModelSheetColumnTypeEnum.string,
      required: true,
      isPrimaryKey: true,
    );

    const ModelSheetTable table = ModelSheetTable(
      id: 'tbl_customers',
      name: 'customers',
      primaryKeyColumn: 'customerId',
      columns: <ModelSheetColumn>[pkColumn],
      rowsCount: 128,
    );

    const ModelSheetBook book = ModelSheetBook(
      id: 'book_customers',
      name: 'Customer Master Data',
      tables: <ModelSheetTable>[table],
    );

    test(
      'Given a canonical book When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = book.toJson();
        final ModelSheetBook roundtrip = ModelSheetBook.fromJson(json);

        expect(roundtrip, book);
        expect(roundtrip.toJson(), book.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelSheetBookEnum.id.name: 'book_customers',
          ModelSheetBookEnum.name.name: 'Customer Master Data',
          ModelSheetBookEnum.tables.name: <Map<String, dynamic>>[
            table.toJson(),
          ],
        };

        final ModelSheetBook parsed = ModelSheetBook.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a book When copyWith overrides fields Then returns updated copy',
      () {
        final ModelSheetBook copy = book.copyWith(
          name: 'Customer Archive',
          tables: const <ModelSheetTable>[],
        );

        expect(copy.name, 'Customer Archive');
        expect(copy.tables, isEmpty);
        expect(copy.id, book.id);
        expect(copy, isNot(book));
      },
    );
  });
}
