"""Run the canonical workflow's actual preparation code without GitHub writes."""
import base64
import contextlib
import io
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import textwrap
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[3]
WORKFLOW = (ROOT / '.github/workflows/prepare_version.yaml').read_text(encoding='utf-8')
PREPARE = textwrap.dedent(
    WORKFLOW.split("          python3 <<'PY'\n", 1)[1].split('\n          PY', 1)[0]
)
NOTES = '### Changed\n\n- Adopt canonical domain core models.'
SOURCE_GUARD = textwrap.dedent(
    WORKFLOW.split('          DISPATCH_SHA: ${{ github.sha }}\n        run: |\n', 1)[1].split('\n  ci:', 1)[0]
)


class SourceGuardTest(unittest.TestCase):
    def run_guard(self, **overrides):
        bash = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
        self.assertTrue(bash, 'Bash is required to exercise the actual workflow guard')
        env = dict(os.environ, GITHUB_REPOSITORY='grupo-jocaagura/jocaagura_domain',
                   SOURCE_REF='refs/heads/develop', EXPECTED_HEAD='a' * 40,
                   DISPATCH_SHA='a' * 40)
        env.update(overrides)
        return subprocess.run([bash, '-c', SOURCE_GUARD], env=env, capture_output=True).returncode

    def test_exact_develop_source_is_accepted(self):
        self.assertEqual(self.run_guard(), 0)

    def test_other_repository_is_rejected(self):
        self.assertNotEqual(self.run_guard(GITHUB_REPOSITORY='someone/fork'), 0)

    def test_other_branch_is_rejected(self):
        self.assertNotEqual(self.run_guard(SOURCE_REF='refs/heads/master'), 0)

    def test_stale_sha_is_rejected(self):
        self.assertNotEqual(self.run_guard(DISPATCH_SHA='b' * 40), 0)

    def test_missing_sha_is_rejected(self):
        self.assertNotEqual(self.run_guard(EXPECTED_HEAD=''), 0)


class PrepareVersionTest(unittest.TestCase):
    def setUp(self):
        scratch = ROOT / '.dart_tool'
        scratch.mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(dir=scratch, prefix='version-test-')
        self.directory = Path(self.temp.name).resolve()
        self.assertTrue(self.directory.is_relative_to(scratch.resolve()))
        self.addCleanup(self.temp.cleanup)
        self.pubspec = self.directory / 'pubspec.yaml'
        self.changelog = self.directory / 'CHANGELOG.md'
        self.pubspec.write_text('name: fixture\nversion: 1.43.2\n', encoding='utf-8')
        self.history = '\n## [1.43.2] - 2026-09-18\n\n### Fixed\n\n- Previous release.\n'
        self.changelog.write_text('# Changelog\n\n## Unreleased\n\n' + NOTES + '\n' + self.history, encoding='utf-8')

    def prepare(self, version='2.0.0', notes=NOTES, encoded=None):
        output = self.directory / 'outputs'
        output.write_text('', encoding='utf-8')
        env = {
            'TARGET_VERSION': version,
            'CHANGELOG_INPUT_BASE64': encoded if encoded is not None else base64.b64encode(notes.encode()).decode(),
            'GITHUB_OUTPUT': str(output),
            'PROMOTION': 'false',
        }
        previous = Path.cwd()
        code = 0
        try:
            os.chdir(self.directory)
            with patch.dict(os.environ, env), contextlib.redirect_stdout(io.StringIO()):
                try:
                    exec(compile(PREPARE, 'prepare_version.yaml', 'exec'), {})
                except SystemExit as error:
                    code = error.code
        finally:
            os.chdir(previous)
        return code, dict(line.split('=', 1) for line in output.read_text(encoding='utf-8').splitlines())

    def test_major_preparation_updates_both_files_and_preserves_history(self):
        code, outputs = self.prepare()
        self.assertEqual((code, outputs['state']), (0, 'NEW_PREPARATION'))
        self.assertIn('version: 2.0.0\n', self.pubspec.read_text())
        changelog = self.changelog.read_text()
        self.assertIn('## Unreleased\n', changelog)
        self.assertIn('## [2.0.0] - ', changelog)
        self.assertIn(NOTES, changelog)
        self.assertTrue(changelog.endswith(self.history))

    def test_identical_retry_has_no_mutation(self):
        self.prepare()
        before = self.pubspec.read_bytes(), self.changelog.read_bytes()
        code, outputs = self.prepare()
        self.assertEqual((code, outputs['state']), (0, 'VERSION_ALREADY_PREPARED'))
        self.assertEqual((self.pubspec.read_bytes(), self.changelog.read_bytes()), before)

    def test_retry_with_different_notes_fails_closed(self):
        self.prepare()
        before = self.pubspec.read_bytes(), self.changelog.read_bytes()
        code, outputs = self.prepare(notes='### Fixed\n\n- Different release.')
        self.assertEqual((code, outputs['state']), (1, 'VERSION_STATE_INCONSISTENT'))
        self.assertEqual((self.pubspec.read_bytes(), self.changelog.read_bytes()), before)

    def test_invalid_versions_fail_without_changes(self):
        for version in ['2.0.0-beta.1', '2.0.0+1', '02.0.0', '1.42.0', 'garbage']:
            with self.subTest(version=version):
                before = self.pubspec.read_bytes(), self.changelog.read_bytes()
                code, _ = self.prepare(version)
                self.assertEqual(code, 1)
                self.assertEqual((self.pubspec.read_bytes(), self.changelog.read_bytes()), before)

    def test_invalid_notes_encoding_is_rejected(self):
        code, outputs = self.prepare(encoded='not base64!')
        self.assertEqual((code, outputs['state']), (1, 'CHANGELOG_INPUT_INVALID'))

    def test_notes_cannot_inject_release_headings(self):
        code, outputs = self.prepare(notes=NOTES + '\n## [9.0.0] - 2026-11-11')
        self.assertEqual((code, outputs['state']), (1, 'CHANGELOG_INPUT_INVALID'))

    def test_duplicate_unreleased_is_rejected(self):
        self.changelog.write_text(self.changelog.read_text() + '\n## Unreleased\n')
        code, outputs = self.prepare()
        self.assertEqual((code, outputs['state']), (1, 'VERSION_STATE_INCONSISTENT'))

    def test_empty_unreleased_is_rejected(self):
        self.changelog.write_text('# Changelog\n\n## Unreleased\n' + self.history)
        code, outputs = self.prepare()
        self.assertEqual((code, outputs['state']), (1, 'UNRELEASED_EMPTY'))


if __name__ == '__main__':
    unittest.main()
