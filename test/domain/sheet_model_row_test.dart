import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelSheetRow', () {
    const ModelSheetRow row = ModelSheetRow(
      idRow: 'CUST-001',
      data: <String, dynamic>{
        'customerId': 'CUST-001',
        'fullName': 'Acme SAS',
        'isActive': true,
        'profile': <String, dynamic>{'tier': 'gold'},
      },
    );

    test(
      'Given a canonical row When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = row.toJson();
        final ModelSheetRow roundtrip = ModelSheetRow.fromJson(json);

        expect(roundtrip, row);
        expect(roundtrip.toJson(), row.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelSheetRowEnum.idRow.name: 'CUST-001',
          ModelSheetRowEnum.data.name: <String, dynamic>{
            'customerId': 'CUST-001',
            'fullName': 'Acme SAS',
            'isActive': true,
            'profile': <String, dynamic>{'tier': 'gold'},
          },
        };

        final ModelSheetRow parsed = ModelSheetRow.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a row When copyWith overrides fields Then returns updated copy',
      () {
        final ModelSheetRow copy = row.copyWith(
          idRow: 'CUST-002',
          data: <String, dynamic>{
            'customerId': 'CUST-002',
            'fullName': 'Beta SAS',
            'isActive': false,
          },
        );

        expect(copy.idRow, 'CUST-002');
        expect(copy.data['customerId'], 'CUST-002');
        expect(copy.data['isActive'], false);
        expect(copy, isNot(row));
      },
    );
  });
}
