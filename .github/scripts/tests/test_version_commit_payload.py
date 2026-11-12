"""Regression coverage for Linux's per-argument limit on large CHANGELOGs."""
import base64
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
SPEC = importlib.util.spec_from_file_location('version_payload', ROOT / '.github/scripts/version_commit_payload.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class VersionPayloadTest(unittest.TestCase):
    def test_protected_branch_is_rejected_before_reading_files(self):
        for branch in ('develop', 'master', 'feature/unrelated'):
            with self.subTest(branch=branch), self.assertRaisesRegex(ValueError, 'preparation branch'):
                MODULE.write_payload(Path('unused'), Path('unused'), {'TARGET_BRANCH': branch})

    def test_large_unicode_changelog_is_lossless_and_commit_stays_atomic(self):
        with tempfile.TemporaryDirectory() as scratch:
            directory = Path(scratch)
            pubspec = b'name: fixture\nversion: 2.0.0\n'
            changelog = ('# CHANGELOG\n\n- Migración de modelos y contratos.\n' * 10000).encode('utf-8')
            self.assertGreater(len(changelog), 131072)
            (directory / 'pubspec.yaml').write_bytes(pubspec)
            (directory / 'CHANGELOG.md').write_bytes(changelog)
            output = directory / 'payload.json'
            env = dict(GITHUB_REPOSITORY='grupo-jocaagura/jocaagura_domain',
                       RUN_ID='123', RUN_ATTEMPT='2', TARGET_BRANCH='codex/prepare-version-2.0.0-aaaaaaaaaaaa',
                       EXPECTED_HEAD_OID='a' * 40, TARGET_VERSION='2.0.0',
                       AUTHORIZED_BY='maintainer', TRIGGERED_BY='maintainer')
            MODULE.write_payload(output, directory, env)
            payload = json.loads(output.read_text(encoding='utf-8'))
            commit = payload['variables']['input']
            self.assertEqual(commit['expectedHeadOid'], 'a' * 40)
            self.assertEqual(commit['branch'], {'repositoryNameWithOwner': env['GITHUB_REPOSITORY'], 'branchName': env['TARGET_BRANCH']})
            additions = commit['fileChanges']['additions']
            self.assertEqual([item['path'] for item in additions], ['pubspec.yaml', 'CHANGELOG.md'])
            self.assertEqual(base64.b64decode(additions[0]['contents']), pubspec)
            self.assertEqual(base64.b64decode(additions[1]['contents']), changelog)
            self.assertEqual(commit['clientMutationId'], 'version-123-2')
            self.assertEqual(commit['message']['headline'], 'chore(release): prepare version 2.0.0')


if __name__ == '__main__':
    unittest.main()
