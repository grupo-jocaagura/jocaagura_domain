import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelSheetColumn', () {
    const ModelSheetColumn column = ModelSheetColumn(
      name: 'customerId',
      type: ModelSheetColumnTypeEnum.string,
      required: true,
      isPrimaryKey: true,
    );

    test(
      'Given a canonical column When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = column.toJson();
        final ModelSheetColumn roundtrip = ModelSheetColumn.fromJson(json);

        expect(roundtrip, column);
        expect(roundtrip.toJson(), column.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelSheetColumnEnum.name.name: 'customerId',
          ModelSheetColumnEnum.type.name: 'string',
          ModelSheetColumnEnum.required.name: true,
          ModelSheetColumnEnum.defaultValue.name: null,
          ModelSheetColumnEnum.isPrimaryKey.name: true,
        };

        final ModelSheetColumn parsed = ModelSheetColumn.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a column When copyWith overrides fields Then returns updated copy',
      () {
        final ModelSheetColumn copy = column.copyWith(
          name: 'customerName',
          type: ModelSheetColumnTypeEnum.json,
          defaultValue: <String, dynamic>{'tier': 'gold'},
          isPrimaryKey: false,
        );

        expect(copy.name, 'customerName');
        expect(copy.type, ModelSheetColumnTypeEnum.json);
        expect(copy.defaultValue, <String, dynamic>{'tier': 'gold'});
        expect(copy.isPrimaryKey, isFalse);
        expect(copy, isNot(column));
      },
    );
  });
}
