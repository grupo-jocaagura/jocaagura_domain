"""Exercise preparation retries, provenance, drift and PR creation without live writes."""

import base64
import copy
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

import yaml

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))
SPEC = importlib.util.spec_from_file_location('version_pr', SCRIPTS / 'version_pull_request.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)
SOURCE = 'a' * 40
COMMIT = 'b' * 40
BRANCH = 'codex/prepare-version-2.1.0-aaaaaaaaaaaa'
PREFIX = f'repos/{MODULE.REPOSITORY}'


class FakeGitHub:
    def __init__(self):
        self.source = SOURCE
        self.branch = None
        self.commit = {'commit': {'verification': {'verified': True}},
                       'parents': [{'sha': SOURCE}],
                       'files': [{'filename': name, 'status': 'modified'} for name in MODULE.FILES]}
        self.contents = {}
        self.pull = None
        self.writes = []
        self.graphql_error = False
        self.drift_after_commit = False

    def request(self, path, body=None, *, missing_ok=False):
        if body is not None:
            self.writes.append((path, copy.deepcopy(body)))
        if path == f'{PREFIX}/git/ref/heads/develop':
            return {'object': {'sha': self.source}}
        if path == f'{PREFIX}/git/ref/heads/{BRANCH}':
            return None if self.branch is None else {'object': {'sha': self.branch}}
        if path == f'{PREFIX}/git/refs':
            self.branch = body['sha']
            return {'object': {'sha': self.branch}}
        if path == 'graphql':
            if self.graphql_error:
                return {'errors': [{'message': 'CAS rejected'}]}
            value = body['variables']['input']
            if value['expectedHeadOid'] != self.branch:
                raise ValueError('CAS rejected')
            self.contents = {item['path']: base64.b64decode(item['contents'])
                             for item in value['fileChanges']['additions']}
            self.branch = COMMIT
            if self.drift_after_commit:
                self.source = 'c' * 40
            return {'data': {'createCommitOnBranch': {'commit': {'oid': COMMIT}}}}
        if path == f'{PREFIX}/commits/{COMMIT}':
            return self.commit
        if path.startswith(f'{PREFIX}/contents/'):
            name = path.split('/contents/')[1].split('?')[0]
            return {'encoding': 'base64', 'content': base64.b64encode(self.contents[name]).decode()}
        if path.startswith(f'{PREFIX}/pulls?'):
            return [] if self.pull is None else [self.pull]
        if path == f'{PREFIX}/pulls':
            self.pull = {'number': 99, 'html_url': 'https://github.com/example/pull/99', 'state': 'open',
                         'base': {'ref': 'develop', 'repo': {'full_name': MODULE.REPOSITORY}},
                         'head': {'ref': BRANCH, 'sha': COMMIT, 'repo': {'full_name': MODULE.REPOSITORY}}}
            return self.pull
        raise AssertionError(f'Unexpected request: {path}')


class VersionPullRequestTest(unittest.TestCase):
    def setUp(self):
        scratch = tempfile.TemporaryDirectory()
        self.addCleanup(scratch.cleanup)
        self.directory = Path(scratch.name)
        (self.directory / 'pubspec.yaml').write_bytes(b'name: fixture\nversion: 2.1.0\n')
        (self.directory / 'CHANGELOG.md').write_bytes(
            b'# Changelog\n\n## Unreleased\n\n## [2.1.0] - 2026-11-12\n\n### Changed\n\n- Notes.\n')
        self.env = dict(GITHUB_REPOSITORY=MODULE.REPOSITORY, GITHUB_REF='refs/heads/develop',
                        EXPECTED_HEAD_OID=SOURCE, TARGET_VERSION='2.1.0', RUN_ID='123',
                        RUN_ATTEMPT='1', AUTHORIZED_BY='maintainer', TRIGGERED_BY='maintainer')
        self.api = FakeGitHub()

    def prepare(self):
        return MODULE.prepare_pull_request(self.api, self.directory, self.env)

    def test_creates_signed_atomic_branch_commit_and_pr_without_writing_develop(self):
        result = self.prepare()
        self.assertEqual(result['branch'], BRANCH)
        self.assertEqual(result['sha'], COMMIT)
        self.assertEqual(self.api.source, SOURCE)
        self.assertEqual([path for path, _ in self.api.writes],
                         [f'{PREFIX}/git/refs', 'graphql', f'{PREFIX}/pulls'])
        payload = self.api.writes[1][1]['variables']['input']
        self.assertEqual(payload['branch']['branchName'], BRANCH)
        self.assertEqual(payload['expectedHeadOid'], SOURCE)
        self.assertEqual({item['path'] for item in payload['fileChanges']['additions']}, set(MODULE.FILES))
        self.assertEqual(self.api.writes[2][1]['base'], 'develop')
        self.assertIn('Approve workflows to run', self.api.writes[2][1]['body'])

    def test_retry_reuses_exact_commit_and_pr_without_writes(self):
        first = self.prepare()
        self.api.writes.clear()
        self.assertEqual(self.prepare(), first)
        self.assertEqual(self.api.writes, [])

    def test_retry_on_later_date_reuses_original_commit(self):
        first = self.prepare()
        changelog = self.directory / 'CHANGELOG.md'
        changelog.write_bytes(changelog.read_bytes().replace(b'2026-11-12', b'2026-11-13'))
        self.api.writes.clear()
        self.assertEqual(self.prepare(), first)
        self.assertEqual(self.api.writes, [])

    def test_retry_recovers_branch_created_before_commit(self):
        self.api.branch = SOURCE
        self.prepare()
        self.assertEqual([path for path, _ in self.api.writes], ['graphql', f'{PREFIX}/pulls'])

    def test_retry_recovers_commit_created_before_pr(self):
        self.prepare()
        self.api.pull = None
        self.api.writes.clear()
        self.prepare()
        self.assertEqual([path for path, _ in self.api.writes], [f'{PREFIX}/pulls'])

    def test_stale_source_rejected_without_writes(self):
        self.api.source = 'c' * 40
        with self.assertRaisesRegex(ValueError, 'develop changed'):
            self.prepare()
        self.assertEqual(self.api.writes, [])

    def test_source_drift_after_commit_does_not_open_pr(self):
        self.api.drift_after_commit = True
        with self.assertRaisesRegex(ValueError, 'develop changed'):
            self.prepare()
        self.assertIsNone(self.api.pull)
        self.assertEqual(self.api.source, 'c' * 40)

    def test_wrong_context_rejected_without_writes(self):
        for key, value in [('GITHUB_REPOSITORY', 'someone/fork'), ('GITHUB_REF', 'refs/heads/master'),
                           ('EXPECTED_HEAD_OID', 'short'), ('TARGET_VERSION', '2.1.0;echo unsafe')]:
            with self.subTest(key=key), patch.dict(self.env, {key: value}):
                with self.assertRaisesRegex(ValueError, 'official develop'):
                    self.prepare()
        self.assertEqual(self.api.writes, [])

    def test_conflicting_notes_rejected_without_overwriting_branch(self):
        self.prepare()
        self.api.writes.clear()
        changelog = self.directory / 'CHANGELOG.md'
        changelog.write_bytes(changelog.read_bytes().replace(b'Notes.', b'Different notes.'))
        with self.assertRaisesRegex(ValueError, 'differs'):
            self.prepare()
        self.assertEqual(self.api.writes, [])

    def test_unverified_or_unrelated_commit_or_extra_files_rejected(self):
        self.prepare()
        for field in ['signature', 'parent', 'files']:
            with self.subTest(field=field):
                original = copy.deepcopy(self.api.commit)
                self.api.writes.clear()
                if field == 'signature':
                    self.api.commit['commit']['verification']['verified'] = False
                elif field == 'parent':
                    self.api.commit['parents'] = [{'sha': 'c' * 40}]
                else:
                    self.api.commit['files'].append({'filename': 'lib/model.dart', 'status': 'modified'})
                with self.assertRaisesRegex(ValueError, 'exactly one verified'):
                    self.prepare()
                self.assertEqual(self.api.writes, [])
                self.api.commit = original

    def test_closed_or_wrong_head_pr_is_never_reopened_or_updated(self):
        self.prepare()
        for field in ['state', 'head']:
            with self.subTest(field=field):
                original = copy.deepcopy(self.api.pull)
                self.api.writes.clear()
                if field == 'state':
                    self.api.pull['state'] = 'closed'
                else:
                    self.api.pull['head']['sha'] = 'c' * 40
                with self.assertRaisesRegex(ValueError, 'open official PR'):
                    self.prepare()
                self.assertEqual(self.api.writes, [])
                self.api.pull = original

    def test_graphql_error_prevents_pr_creation(self):
        self.api.graphql_error = True
        with self.assertRaisesRegex(ValueError, 'rejected the atomic'):
            self.prepare()
        self.assertIsNone(self.api.pull)

    def test_http_error_is_not_mistaken_for_missing_branch(self):
        response = subprocess_result(1, json.dumps({'status': '403'}))
        with patch.object(MODULE.subprocess, 'run', return_value=response):
            with self.assertRaisesRegex(ValueError, 'request failed'):
                MODULE.GitHub().request('some/path', missing_ok=True)

    def test_actual_gh_transport_sends_large_json_on_stdin(self):
        body = {'contents': 'x' * 200000}
        with patch.object(MODULE.subprocess, 'run', return_value=subprocess_result(0, '{}')) as run:
            MODULE.GitHub().request('graphql', body)
        self.assertEqual(run.call_args.args[0], ['gh', 'api', '--method', 'POST', 'graphql', '--input', '-'])
        self.assertEqual(json.loads(run.call_args.kwargs['input']), body)

    def test_actual_workflow_uses_pr_materialization_after_read_only_ci(self):
        workflow = yaml.safe_load((SCRIPTS.parent / 'workflows/prepare_version.yaml').read_text(encoding='utf-8'))
        job = workflow['jobs']['prepare_version']
        self.assertEqual(job['needs'], 'ci')
        self.assertEqual(job['permissions'], {'contents': 'write', 'pull-requests': 'write'})
        materialize = next(step for step in job['steps'] if step.get('id') == 'commit')
        self.assertEqual(materialize['run'], 'python3 .github/scripts/version_pull_request.py')
        self.assertEqual(materialize['env']['EXPECTED_HEAD_OID'], '${{ steps.head.outputs.oid }}')
        self.assertEqual(workflow['jobs']['ci']['permissions'], {'contents': 'read'})

    def test_actual_summary_does_not_report_ready_when_materialization_fails(self):
        workflow = yaml.safe_load((SCRIPTS.parent / 'workflows/prepare_version.yaml').read_text(encoding='utf-8'))
        summary = workflow['jobs']['prepare_version']['steps'][-1]['run']
        bash = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
        self.assertTrue(bash)
        output = self.directory / 'summary.md'
        env = dict(os.environ, JOB_STATUS='failure', STATE='NEW_PREPARATION',
                   AUTHORIZED_BY='maintainer', TRIGGERED_BY='maintainer', RUN_ATTEMPT='1',
                   TARGET_BRANCH='develop', GITHUB_REPOSITORY=MODULE.REPOSITORY,
                   RUN_ID='123', GITHUB_STEP_SUMMARY=output.as_posix())
        result = MODULE.subprocess.run([bash, '-c', summary], env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('VERSION_PREPARATION_FAILED', output.read_text(encoding='utf-8'))
        self.assertNotIn('VERSION_PR_READY', output.read_text(encoding='utf-8'))


def subprocess_result(code, stdout):
    return MODULE.subprocess.CompletedProcess([], code, stdout=stdout, stderr='')


if __name__ == '__main__':
    unittest.main()
