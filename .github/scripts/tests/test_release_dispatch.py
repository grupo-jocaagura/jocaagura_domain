"""Release orchestration boundaries, idempotency and workflow authorization."""

from copy import deepcopy
import json
import os
from pathlib import Path
import subprocess
import sys
import unittest

import yaml

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / '.github/scripts'))
from release_dispatch import dispatch_release, plan_release, require_context, require_cp0

SHA = 'a' * 40
SPEC = 'name: jocaagura_domain\nversion: 0.2.0\nrepository: https://github.com/grupo-jocaagura/jocaagura_domain\n'
SPEC += 'environment:\n  sdk: ">=3.14.0 <4.0.0"\n  flutter: ">=3.50.0"\ndependencies:\n  flutter:\n    sdk: flutter\n  jocaagura_domain_core: ^1.3.0\n'

NOTES = '## [0.2.0] - 2026-09-13\n\n- Consolidated changes.\n'
EVIDENCE = {'status': 'passed', 'package': 'jocaagura_domain', 'repository': 'grupo-jocaagura/jocaagura_domain', 'version': '2.0.0', 'observed_claims': {'repository': 'grupo-jocaagura/jocaagura_domain', 'environment': 'pub.dev', 'workflow_ref': 'grupo-jocaagura/jocaagura_domain/.github/workflows/publish.yaml@refs/tags/v2.0.0', 'iss': 'https://token.actions.githubusercontent.com', 'aud': 'https://pub.dev', 'event_name': 'workflow_dispatch', 'ref_type': 'tag', 'ref': 'refs/tags/v2.0.0', 'run_id': '789', 'sha': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'}, 'audit_log_attribution': {'run_id': '789', 'sha': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'url': 'https://pub.dev/packages/jocaagura_domain/activity-log'}}
PR = {'base': {'ref': 'master', 'repo': {'full_name': 'grupo-jocaagura/jocaagura_domain'}},
      'head': {'ref': 'develop', 'repo': {'full_name': 'grupo-jocaagura/jocaagura_domain'}},
      'state': 'closed', 'merged_at': '2026-09-13T00:00:00Z', 'merge_commit_sha': SHA}


def published(*versions):
    return lambda *args, **kwargs: {'name': 'jocaagura_domain', 'versions': [{'version': v} for v in versions]}


class FakeGitHub:
    def __init__(self):
        self.master = SHA
        self.ref = None
        self.prs = [deepcopy(PR)]
        self.calls = []
        self.dispatch_fails = False
        self.workflow_state = 'active'

    def read(self, url, **kwargs):
        self.calls.append(('GET', url))
        if url.endswith('/rulesets?includes_parents=true'):
            return [{'id': 1, 'target': 'tag', 'enforcement': 'active'}]
        if url.endswith('/rulesets/1'):
            return {'conditions': {'ref_name': {'include': ['refs/tags/v*'], 'exclude': []}},
                    'bypass_actors': [], 'rules': [{'type': 'update'}, {'type': 'deletion'}]}
        return self.prs

    def get(self, path, **kwargs):
        self.calls.append(('GET', path))
        if path == 'git/ref/heads/master':
            return {'object': {'sha': self.master}}
        if path == 'actions/workflows/publish.yaml':
            return {'state': self.workflow_state}
        if path == 'git/ref/tags/v0.2.0':
            return self.ref
        if path.startswith('git/tags/'):
            return {'object': {'type': 'commit', 'sha': SHA}}
        raise AssertionError(path)

    def post(self, path, body):
        self.calls.append(('POST', path, body))
        if path == 'git/refs':
            self.ref = {'object': {'type': 'commit', 'sha': body['sha']}}
        elif self.dispatch_fails:
            raise ValueError('Dispatch failed')


class ReleaseDispatchTests(unittest.TestCase):
    def setUp(self):
        self.github = FakeGitHub()
        self.plan = {'version': '0.2.0', 'sha': SHA, 'state': 'ready_to_publish'}

    def test_only_master_event_context_and_exact_sha(self):
        env = {'GITHUB_REPOSITORY': 'grupo-jocaagura/jocaagura_domain', 'GITHUB_REF': 'refs/heads/master', 'GITHUB_EVENT_NAME': 'push', 'GITHUB_SHA': SHA}
        require_context(env, SHA)
        require_context(dict(env, GITHUB_EVENT_NAME='workflow_dispatch'), SHA)
        for key, value in [('GITHUB_REF', 'refs/heads/develop'), ('GITHUB_EVENT_NAME', 'pull_request'), ('GITHUB_SHA', 'b' * 40), ('GITHUB_REPOSITORY', 'fork/repo')]:
            with self.subTest(key=key), self.assertRaises(ValueError):
                require_context(dict(env, **{key: value}), SHA)

    def test_cp0_requires_service_event_and_audit_completion(self):
        require_cp0(EVIDENCE)
        for wrong in [{}, dict(EVIDENCE, status='pending'), dict(EVIDENCE, audit_log_attribution={}), dict(EVIDENCE, observed_claims={'event_name': 'push', 'ref_type': 'tag'})]:
            with self.assertRaises(ValueError):
                require_cp0(wrong)

    def test_cp0_rejects_old_target_or_inconsistent_tag(self):
        for version, ref in [('0.1.0', 'refs/tags/v0.1.0'),
                             ('2.0.0', 'refs/tags/v0.1.0'),
                             ('2.0.0', 'refs/heads/master')]:
            wrong = deepcopy(EVIDENCE)
            wrong['version'] = version
            wrong['observed_claims']['ref'] = ref
            with self.subTest(version=version, ref=ref), self.assertRaises(ValueError):
                require_cp0(wrong)

    def test_plan_is_read_only_and_requires_exact_merged_pr(self):
        self.assertEqual(plan_release(SPEC, NOTES, SHA, EVIDENCE, self.github, published('0.1.0')), self.plan)
        self.assertTrue(all(call[0] == 'GET' for call in self.github.calls))
        for changed in [dict(PR, merged_at=None), dict(PR, merge_commit_sha='b' * 40), dict(PR, head={'ref': 'feature', 'repo': PR['head']['repo']})]:
            self.github.prs = [changed]
            with self.assertRaises(ValueError):
                plan_release(SPEC, NOTES, SHA, EVIDENCE, self.github, published('0.1.0'))

    def test_plan_rejects_patch_regression_first_publication_and_master_drift(self):
        for spec, reader in [(SPEC.replace('0.2.0', '0.2.1'), published('0.1.0')), (SPEC, published('0.3.0')), (SPEC, lambda *a, **k: None)]:
            with self.assertRaises(ValueError):
                plan_release(spec, NOTES.replace('0.2.0', '0.2.1') if '0.2.1' in spec else NOTES, SHA, EVIDENCE, self.github, reader)
        self.github.master = 'b' * 40
        with self.assertRaises(ValueError):
            plan_release(SPEC, NOTES, SHA, EVIDENCE, self.github, published('0.1.0'))

    def test_existing_version_never_inspects_or_mutates_its_tag(self):
        self.github.ref = {'object': {'type': 'commit', 'sha': 'b' * 40}}
        plan = plan_release(SPEC, NOTES, SHA, EVIDENCE, self.github, published('0.2.0'))
        self.assertEqual(plan['state'], 'already_published')
        self.github.calls.clear()
        self.assertEqual(dispatch_release(plan, self.github, published('0.2.0')), 'already_published')
        self.assertEqual(self.github.calls, [])

    def test_creates_tag_before_dispatch_with_version_ref(self):
        self.assertEqual(dispatch_release(self.plan, self.github, published('0.1.0')), 'publisher_dispatched')
        writes = [call for call in self.github.calls if call[0] == 'POST']
        self.assertEqual(writes, [('POST', 'git/refs', {'ref': 'refs/tags/v0.2.0', 'sha': SHA}), ('POST', 'actions/workflows/publish.yaml/dispatches', {'ref': 'v0.2.0'})])

    def test_dispatch_retry_keeps_created_tag(self):
        self.github.dispatch_fails = True
        with self.assertRaises(ValueError):
            dispatch_release(self.plan, self.github, published('0.1.0'))
        self.github.dispatch_fails = False
        dispatch_release(self.plan, self.github, published('0.1.0'))
        self.assertEqual(sum(call[:2] == ('POST', 'git/refs') for call in self.github.calls), 1)

    def test_conflicting_tag_cannot_dispatch_or_move(self):
        self.github.ref = {'object': {'type': 'commit', 'sha': 'b' * 40}}
        with self.assertRaises(ValueError):
            dispatch_release(self.plan, self.github, published('0.1.0'))
        self.assertFalse(any(call[0] == 'POST' for call in self.github.calls))

    def test_matching_annotated_tag_is_preserved(self):
        self.github.ref = {'object': {'type': 'tag', 'sha': 'b' * 40}}
        dispatch_release(self.plan, self.github, published('0.1.0'))
        self.assertEqual([call[1] for call in self.github.calls if call[0] == 'POST'], ['actions/workflows/publish.yaml/dispatches'])

    def test_fresh_version_check_prevents_stale_plan_upload(self):
        self.assertEqual(dispatch_release(self.plan, self.github, published('0.2.0')), 'already_published')
        self.assertEqual(self.github.calls, [])
        with self.assertRaises(ValueError):
            dispatch_release(self.plan, self.github, published('0.3.0'))
        self.assertEqual(self.github.calls, [])

    def test_master_drift_disabled_workflow_and_api_error_block_writes(self):
        self.github.master = 'b' * 40
        with self.assertRaises(ValueError):
            dispatch_release(self.plan, self.github, published('0.1.0'))
        self.github.master = SHA
        self.github.workflow_state = 'disabled_manually'
        with self.assertRaises(ValueError):
            dispatch_release(self.plan, self.github, published('0.1.0'))
        def unavailable(*args, **kwargs):
            raise OSError('service unavailable')
        with self.assertRaises(OSError):
            dispatch_release(self.plan, self.github, unavailable)
        self.assertFalse(any(call[0] == 'POST' for call in self.github.calls))

    def test_actual_publisher_guard_rejects_branch_dispatch_and_unrelated_events(self):
        workflow = yaml.load((ROOT / '.github/workflows/publish.yaml').read_text(), Loader=yaml.BaseLoader)
        script = workflow['jobs']['release_validation']['steps'][0]['run']
        bash = Path('C:/Program Files/Git/bin/bash.exe') if os.name == 'nt' else Path('/bin/bash')
        if not bash.exists():
            self.skipTest('Bash required')
        for event, ref, sender, valid in [('workflow_dispatch', 'tag', 'Bot', True), ('workflow_dispatch', 'branch', 'User', False), ('push', 'tag', 'User', True), ('push', 'tag', 'Bot', False), ('pull_request', 'tag', 'User', False)]:
            result = subprocess.run([str(bash), '--noprofile', '--norc', '-e'], input=script, text=True, capture_output=True, env=dict(os.environ, GITHUB_REPOSITORY='grupo-jocaagura/jocaagura_domain', EVENT_NAME=event, REF_TYPE=ref, SENDER_TYPE=sender))
            self.assertEqual(result.returncode == 0, valid)
        fork = subprocess.run([str(bash), '--noprofile', '--norc', '-e'], input=script, text=True, capture_output=True, env=dict(os.environ, GITHUB_REPOSITORY='fork/repo', EVENT_NAME='workflow_dispatch', REF_TYPE='tag', SENDER_TYPE='User'))
        self.assertNotEqual(fork.returncode, 0)

    def test_workflow_privileges_and_ci_are_required_before_dispatch(self):
        workflow = yaml.load((ROOT / '.github/workflows/release_after_merge.yaml').read_text(), Loader=yaml.BaseLoader)
        self.assertEqual(set(workflow['on']), {'push', 'workflow_dispatch'})
        self.assertEqual(workflow['on']['push']['branches'], ['master'])
        self.assertEqual(workflow['jobs']['dispatch']['needs'], ['plan', 'ci'])
        self.assertEqual(workflow['jobs']['dispatch']['permissions']['actions'], 'write')
        self.assertNotIn('actions', workflow['jobs']['plan']['permissions'])
        for job in ['plan', 'dispatch']:
            checkout = next(step for step in workflow['jobs'][job]['steps'] if step.get('uses', '').startswith('actions/checkout'))
            self.assertEqual(checkout['with']['ref'], 'master')
            self.assertEqual(checkout['with']['persist-credentials'], 'false')
        publisher = yaml.load((ROOT / '.github/workflows/publish.yaml').read_text(), Loader=yaml.BaseLoader)
        self.assertEqual(publisher['concurrency']['group'], 'pub-dev-release')
        self.assertEqual(publisher['jobs']['publish']['needs'], ['ci', 'release_validation'])


if __name__ == '__main__':
    unittest.main()
