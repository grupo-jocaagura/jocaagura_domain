import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelDriveFile', () {
    final DateTime createdAt = DateTime.utc(2026, 3, 14, 10, 20);
    final DateTime updatedAt = DateTime.utc(2026, 3, 14, 10, 45);

    final ModelDriveFile file = ModelDriveFile(
      id: 'file-contract-pdf',
      name: 'contract.pdf',
      mimeType: 'application/pdf',
      parentId: 'folder-clients-acme',
      path: '/clients/acme/contract.pdf',
      webUrl: 'https://workspace.jocaagura.dev/drive/files/file-contract-pdf',
      createdAt: createdAt,
      updatedAt: updatedAt,
      trashed: false,
      meta: const <String, dynamic>{
        'indexed': true,
        'source': 'workspace-backend',
      },
      sizeBytes: 245760,
      extension: 'pdf',
    );

    test(
      'Given a canonical drive file When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = file.toJson();
        final ModelDriveFile roundtrip = ModelDriveFile.fromJson(json);

        expect(roundtrip, file);
        expect(roundtrip.toJson(), file.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelDriveItemEnum.id.name: 'file-contract-pdf',
          ModelDriveItemEnum.name.name: 'contract.pdf',
          ModelDriveItemEnum.kind.name: 'file',
          ModelDriveItemEnum.mimeType.name: 'application/pdf',
          ModelDriveItemEnum.parentId.name: 'folder-clients-acme',
          ModelDriveItemEnum.path.name: '/clients/acme/contract.pdf',
          ModelDriveItemEnum.webUrl.name:
              'https://workspace.jocaagura.dev/drive/files/file-contract-pdf',
          ModelDriveItemEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          ModelDriveItemEnum.updatedAt.name:
              DateUtils.dateTimeToString(updatedAt),
          ModelDriveItemEnum.trashed.name: false,
          ModelDriveItemEnum.meta.name: <String, dynamic>{
            'indexed': true,
            'source': 'workspace-backend',
          },
          ModelDriveFileEnum.sizeBytes.name: 245760,
          ModelDriveFileEnum.extension.name: 'pdf',
        };

        final ModelDriveFile parsed = ModelDriveFile.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a drive file When copyWith overrides selected fields Then returns updated immutable copy',
      () {
        final ModelDriveFile copy = file.copyWith(
          name: 'contract-v2.pdf',
          sizeBytes: 512000,
          extension: 'pdf',
          meta: null,
        );

        expect(copy.kind, ModelDriveKindEnum.file);
        expect(copy.name, 'contract-v2.pdf');
        expect(copy.sizeBytes, 512000);
        expect(copy.meta, isNull);
        expect(copy.mimeType, file.mimeType);
        expect(copy, isNot(file));
      },
    );
  });
}
