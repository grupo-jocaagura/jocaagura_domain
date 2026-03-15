import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelDriveItem', () {
    final DateTime createdAt = DateTime.utc(2026, 3, 14, 10);
    final DateTime updatedAt = DateTime.utc(2026, 3, 14, 10, 15);

    final ModelDriveItem item = ModelDriveItem(
      id: 'folder-clients-acme',
      name: 'acme',
      kind: ModelDriveKindEnum.folder,
      mimeType: 'application/vnd.jocaagura.folder',
      parentId: 'folder-clients',
      path: '/clients/acme',
      webUrl:
          'https://workspace.jocaagura.dev/drive/folders/folder-clients-acme',
      createdAt: createdAt,
      updatedAt: updatedAt,
      trashed: false,
      meta: const <String, dynamic>{
        'indexed': true,
        'source': 'workspace-backend',
      },
    );

    test(
      'Given a canonical drive item When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = item.toJson();
        final ModelDriveItem roundtrip = ModelDriveItem.fromJson(json);

        expect(roundtrip, item);
        expect(roundtrip.toJson(), item.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelDriveItemEnum.id.name: 'folder-clients-acme',
          ModelDriveItemEnum.name.name: 'acme',
          ModelDriveItemEnum.kind.name: 'folder',
          ModelDriveItemEnum.mimeType.name: 'application/vnd.jocaagura.folder',
          ModelDriveItemEnum.parentId.name: 'folder-clients',
          ModelDriveItemEnum.path.name: '/clients/acme',
          ModelDriveItemEnum.webUrl.name:
              'https://workspace.jocaagura.dev/drive/folders/folder-clients-acme',
          ModelDriveItemEnum.createdAt.name:
              DateUtils.dateTimeToString(createdAt),
          ModelDriveItemEnum.updatedAt.name:
              DateUtils.dateTimeToString(updatedAt),
          ModelDriveItemEnum.trashed.name: false,
          ModelDriveItemEnum.meta.name: <String, dynamic>{
            'indexed': true,
            'source': 'workspace-backend',
          },
        };

        final ModelDriveItem parsed = ModelDriveItem.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a drive item When copyWith overrides selected fields Then returns updated immutable copy',
      () {
        final ModelDriveItem copy = item.copyWith(
          name: 'acme-archive',
          parentId: null,
          webUrl: null,
        );

        expect(copy.name, 'acme-archive');
        expect(copy.parentId, isNull);
        expect(copy.webUrl, isNull);
        expect(copy.mimeType, item.mimeType);
        expect(copy.kind, item.kind);
        expect(copy, isNot(item));
      },
    );
  });
}
