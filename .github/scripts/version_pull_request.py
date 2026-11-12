"""Materialize a signed version commit and a reviewable PR without bypassing rulesets."""

import base64
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
from urllib.parse import urlencode

from version_commit_payload import write_payload

REPOSITORY = 'grupo-jocaagura/jocaagura_domain'
BASE = 'develop'
FILES = ('pubspec.yaml', 'CHANGELOG.md')


class GitHub:
    """Use gh's job token; JSON travels on stdin, including large file contents."""

    def request(self, path, body=None, *, missing_ok=False):
        command = ['gh', 'api', '--method', 'GET' if body is None else 'POST', path]
        if body is not None:
            command += ['--input', '-']
        result = subprocess.run(command, input=json.dumps(body) if body is not None else None,
                                capture_output=True, text=True, encoding='utf-8')
        try:
            data = json.loads(result.stdout)
        except json.JSONDecodeError:
            data = None
        if result.returncode:
            if missing_ok and isinstance(data, dict) and str(data.get('status')) == '404':
                return None
            raise ValueError(f'GitHub request failed: {path}; no success is assumed')
        if data is None:
            raise ValueError(f'GitHub returned no JSON: {path}')
        return data


def comparable(name, content, version):
    """Retries on a later day may reuse only the identical dated release block."""
    if name != 'CHANGELOG.md':
        return content
    pattern = rb'(?m)^## \[' + re.escape(version.encode()) + rb'\] - \d{4}-\d{2}-\d{2}(?=\r?$)'
    normalized, count = re.subn(pattern, b'## [target] - DATE', content)
    if count != 1:
        raise ValueError('Expected exactly one dated target release block')
    return normalized


def prepare_pull_request(api, directory, env):
    source = env['EXPECTED_HEAD_OID']
    version = env['TARGET_VERSION']
    if (env['GITHUB_REPOSITORY'] != REPOSITORY or env['GITHUB_REF'] != f'refs/heads/{BASE}'
            or not re.fullmatch(r'[0-9a-f]{40}', source)
            or not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', version)):
        raise ValueError('Version preparation requires the official develop source and stable version')
    prefix = f'repos/{REPOSITORY}'
    branch = f'codex/prepare-version-{version}-{source[:12]}'

    def require_source():
        if api.request(f'{prefix}/git/ref/heads/{BASE}')['object']['sha'] != source:
            raise ValueError('develop changed; plan again using its exact current SHA')

    require_source()
    ref_path = f'{prefix}/git/ref/heads/{branch}'
    ref = api.request(ref_path, missing_ok=True)
    if ref is None:
        require_source()
        ref = api.request(f'{prefix}/git/refs', {'ref': f'refs/heads/{branch}', 'sha': source})
    sha = ref['object']['sha']
    if sha == source:
        require_source()
        # A retry can recover a branch created before the commit request failed.
        with tempfile.TemporaryDirectory() as scratch:
            payload_path = Path(scratch) / 'commit.json'
            write_payload(payload_path, directory, dict(env, TARGET_BRANCH=branch))
            response = api.request('graphql', json.loads(payload_path.read_text(encoding='utf-8')))
        if response.get('errors'):
            raise ValueError('GitHub rejected the atomic version commit')
        sha = response['data']['createCommitOnBranch']['commit']['oid']

    commit = api.request(f'{prefix}/commits/{sha}')
    if (not commit['commit']['verification']['verified']
            or [parent['sha'] for parent in commit['parents']] != [source]
            or {item['filename'] for item in commit['files']} != set(FILES)
            or any(item['status'] != 'modified' for item in commit['files'])):
        raise ValueError('Preparation branch must contain exactly one verified two-file commit on the source')
    for name in FILES:
        remote = api.request(f'{prefix}/contents/{name}?{urlencode({"ref": sha})}')
        if remote['encoding'] != 'base64':
            raise ValueError('Cannot verify prepared file contents')
        content = base64.b64decode(remote['content'])
        if comparable(name, content, version) != comparable(name, (directory / name).read_bytes(), version):
            raise ValueError('Existing preparation differs from the authorized version or notes; never overwrite it')
    if api.request(ref_path)['object']['sha'] != sha:
        raise ValueError('Preparation branch changed during verification')
    require_source()
    query = urlencode({'state': 'all', 'head': f'{REPOSITORY.split("/")[0]}:{branch}',
                       'base': BASE, 'per_page': 100})
    pulls = api.request(f'{prefix}/pulls?{query}')
    if len(pulls) > 1:
        raise ValueError('Ambiguous preparation pull requests')
    if pulls:
        pull = pulls[0]
    else:
        pull = api.request(f'{prefix}/pulls', {
            'title': f'chore(release): prepare {version}', 'head': branch, 'base': BASE,
            'body': (
                f'Prepare **{version}** from exact develop source `{source}`.\n\n'
                f'Verified atomic commit: `{sha}`. Only pubspec.yaml and CHANGELOG.md change.\n\n'
                'A collaborator must select **Approve workflows to run** if GitHub holds the '
                'GITHUB_TOKEN-created PR runs for approval. Required CI, CodeQL, an independent '
                'review and resolved conversations remain mandatory. No bypass, approval, merge, '
                'tag or publication is performed by preparation.\n\n'
                f'Run: https://github.com/{REPOSITORY}/actions/runs/{env["RUN_ID"]}\n\n'
                'Refs #213.'
            ),
        })
    if (pull['state'] != 'open' or pull['base']['ref'] != BASE
            or pull['head']['ref'] != branch or pull['head']['sha'] != sha
            or pull['head']['repo']['full_name'] != REPOSITORY
            or pull['base']['repo']['full_name'] != REPOSITORY):
        raise ValueError('Preparation requires an open official PR with the exact verified head')
    require_source()
    return {'branch': branch, 'sha': sha, 'url': f'https://github.com/{REPOSITORY}/commit/{sha}',
            'pr_url': pull['html_url'], 'pr_number': str(pull['number']), 'verified': 'true'}


if __name__ == '__main__':
    result = prepare_pull_request(GitHub(), Path.cwd(), dict(os.environ))
    with Path(os.environ['GITHUB_OUTPUT']).open('a', encoding='utf-8') as output:
        for key, value in result.items():
            output.write(f'{key}={value}\n')
    print(f'Version preparation PR: {result["pr_url"]}')
