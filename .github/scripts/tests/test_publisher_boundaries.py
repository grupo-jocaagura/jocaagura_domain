"""Reject untrusted OIDC identities, mutable tags and incorrect hosted evidence."""
from copy import deepcopy
from datetime import datetime, timedelta, timezone
import os
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

import jwt
from cryptography.hazmat.primitives.asymmetric import rsa

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / '.github/scripts'))
from oidc_policy import validate_claims, signed_claims, ISSUER, AUDIENCE, REPOSITORY
from publication_policy import require_tag_source, require_immutable_tags
from verify_publication import verify_response

SHA = 'a' * 40
ENV = dict(GITHUB_REPOSITORY=REPOSITORY, GITHUB_SHA=SHA, GITHUB_REF='refs/tags/v2.0.0',
           GITHUB_REF_TYPE='tag', GITHUB_EVENT_NAME='push', GITHUB_RUN_ID='123')
CLAIMS = dict(iss=ISSUER, aud=AUDIENCE, repository=REPOSITORY, repository_id='723526906',
              repository_owner_id='193098028', sub=f'repo:{REPOSITORY}:environment:pub.dev',
              environment='pub.dev', sha=SHA, ref='refs/tags/v2.0.0', ref_type='tag',
              event_name='push', run_id='123', runner_environment='github-hosted',
              workflow_ref=f'{REPOSITORY}/.github/workflows/publish.yaml@refs/tags/v2.0.0',
              ref_protected='true')


class OidcPolicyTest(unittest.TestCase):
    def test_exact_signed_identity_can_authorize_publish_context(self):
        evidence = validate_claims(CLAIMS, ENV, 'publish')
        self.assertEqual(evidence['result'], 'signed_claims_verified')
        self.assertEqual(evidence['pub_dev_upload'], 'not_executed')
        self.assertNotIn('token', evidence)

    def test_wrong_audience_issuer_repo_workflow_environment_sha_and_ref_are_rejected(self):
        for key, value in [('iss', 'https://example.com'), ('aud', 'not-pub.dev'),
                           ('repository', 'fork/repo'), ('repository_id', '1'),
                           ('repository_owner_id', '1'), ('sub', 'repo:fork/repo:environment:pub.dev'),
                           ('environment', 'another'), ('sha', 'b' * 40),
                           ('workflow_ref', 'other/workflow'), ('ref', 'refs/heads/develop'),
                           ('ref_type', 'branch'), ('event_name', 'pull_request'),
                           ('run_id', '999'), ('ref_protected', 'false'),
                           ('runner_environment', 'self-hosted')]:
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_claims(dict(CLAIMS, **{key: value}), ENV, 'publish')

    def test_probe_is_not_a_publication_certificate(self):
        env = dict(ENV, GITHUB_REF='refs/pull/1/merge', GITHUB_REF_TYPE='branch', GITHUB_EVENT_NAME='pull_request')
        claims = dict(CLAIMS, ref=env['GITHUB_REF'], ref_type='branch', event_name='pull_request',
                      workflow_ref=f'{REPOSITORY}/.github/workflows/oidc_probe.yaml@refs/pull/1/merge')
        self.assertEqual(validate_claims(claims, env, 'probe')['mode'], 'probe')
        with self.assertRaises(ValueError):
            validate_claims(claims, env, 'publish')

    def test_jwt_verifies_signature_issuer_audience_and_expiration(self):
        key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
        now = datetime.now(timezone.utc)
        claims = dict(CLAIMS, iat=now, exp=now + timedelta(minutes=5))
        with patch('jwt.PyJWKClient') as client:
            client.return_value.get_signing_key_from_jwt.return_value.key = key.public_key()
            token = jwt.encode(claims, key, algorithm='RS256')
            self.assertEqual(signed_claims(token)['repository'], REPOSITORY)
            for bad in [dict(claims, aud='wrong'), dict(claims, iss='https://wrong'),
                        dict(claims, exp=now - timedelta(minutes=1))]:
                with self.assertRaises(jwt.InvalidTokenError):
                    signed_claims(jwt.encode(bad, key, algorithm='RS256'))
            other = rsa.generate_private_key(public_exponent=65537, key_size=2048)
            with self.assertRaises(jwt.InvalidTokenError):
                signed_claims(jwt.encode(claims, other, algorithm='RS256'))


class ImmutableSourceTest(unittest.TestCase):
    def setUp(self):
        self.rules = {'conditions': {'ref_name': {'include': ['refs/tags/v*'], 'exclude': []}},
                      'bypass_actors': [], 'rules': [{'type': 'update'}, {'type': 'deletion'}]}
        self.master = SHA
        self.tag = SHA
        self.verified = True

    def reader(self, url, **kwargs):
        if url.endswith('/rulesets?includes_parents=true'):
            return [{'id': 1, 'target': 'tag', 'enforcement': 'active'}]
        if url.endswith('/rulesets/1'):
            return self.rules
        if url.endswith('/git/ref/heads/master'):
            return {'object': {'sha': self.master}}
        if '/commits/' in url:
            return {'commit': {'verification': {'verified': self.verified}}}
        if '/git/ref/tags/' in url:
            return {'object': {'sha': self.tag, 'type': 'commit'}}
        raise AssertionError(url)

    def test_exact_signed_master_and_immutable_tag_pass(self):
        require_tag_source(SHA, 'v2.0.0', reader=self.reader)

    def test_master_drift_tag_drift_and_unverified_commit_fail(self):
        for field, value in [('master', 'b' * 40), ('tag', 'b' * 40), ('verified', False)]:
            with self.subTest(field=field), patch.object(self, field, value), self.assertRaises(ValueError):
                require_tag_source(SHA, 'v2.0.0', reader=self.reader)

    def test_no_tag_rules_or_rules_with_bypass_or_exclusions_fail(self):
        with self.assertRaises(ValueError):
            require_immutable_tags(reader=lambda *a, **k: [])
        for changed in [dict(self.rules, rules=[{'type': 'deletion'}]),
                        dict(self.rules, bypass_actors=[{'actor_id': 5}]),
                        dict(self.rules, conditions={'ref_name': {'include': ['refs/tags/v*'], 'exclude': ['refs/tags/v2*']}})]:
            with patch.object(self, 'rules', changed), self.assertRaises(ValueError):
                require_immutable_tags(reader=self.reader)


class HostedEvidenceTest(unittest.TestCase):
    def test_exact_hosted_identity_is_required(self):
        response = {'version': '2.0.0', 'pubspec': {'name': 'jocaagura_domain', 'version': '2.0.0',
                    'repository': f'https://github.com/{REPOSITORY}',
                    'dependencies': {'jocaagura_domain_core': '^1.3.0'}}}
        verify_response(response, '2.0.0')
        for changed in [None, dict(response, version='1.43.0'), dict(response, pubspec={})]:
            with self.assertRaises(ValueError):
                verify_response(changed, '2.0.0')


if __name__ == '__main__':
    unittest.main()
