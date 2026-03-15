import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelDriveFolder', () {
    final DateTime createdAt = DateTime.utc(2026, 3, 14, 9);
    final DateTime updatedAt = DateTime.utc(2026, 3, 14, 10);

    final ModelDriveFolder folder = ModelDriveFolder(
      id: 'folder-clients',
      name: 'clients',
      parentId: null,
      path: '/clients',
      webUrl: 'https://workspace.jocaagura.dev/drive/folders/folder-clients',
      createdAt: createdAt,
      updatedAt: updatedAt,
      trashed: false,
      meta: const <String, dynamic>{
        'indexed': true,
        'source': 'workspace-backend',
      },
      childrenCount: 12,
    );

    test(
      'Given a canonical drive folder When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = folder.toJson();
        final ModelDriveFolder roundtrip = ModelDriveFolder.fromJson(json);

        expect(roundtrip, folder);
        expect(roundtrip.toJson(), folder.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelDriveItemEnum.id.name: 'folder-clients',
          ModelDriveItemEnum.name.name: 'clients',
          ModelDriveItemEnum.kind.name: 'folder',
          ModelDriveItemEnum.mimeType.name: 'application/vnd.jocaagura.folder',
          ModelDriveItemEnum.parentId.name: null,
          ModelDriveItemEnum.path.name: '/clients',
          ModelDriveItemEnum.webUrl.name:
              'https://workspace.jocaagura.dev/drive/folders/folder-clients',
          ModelDriveItemEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          ModelDriveItemEnum.updatedAt.name:
              DateUtils.dateTimeToString(updatedAt),
          ModelDriveItemEnum.trashed.name: false,
          ModelDriveItemEnum.meta.name: <String, dynamic>{
            'indexed': true,
            'source': 'workspace-backend',
          },
          ModelDriveFolderEnum.childrenCount.name: 12,
        };

        final ModelDriveFolder parsed = ModelDriveFolder.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a drive folder When copyWith overrides selected fields Then returns updated immutable copy',
      () {
        final ModelDriveFolder copy = folder.copyWith(
          path: '/',
          childrenCount: null,
        );

        expect(copy.kind, ModelDriveKindEnum.folder);
        expect(copy.mimeType, 'application/vnd.jocaagura.folder');
        expect(copy.path, '/');
        expect(copy.childrenCount, isNull);
        expect(copy.parentId, folder.parentId);
        expect(copy, isNot(folder));
      },
    );
  });
}
