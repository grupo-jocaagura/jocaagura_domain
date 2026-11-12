"""Build the atomic GraphQL commit payload on disk, without large argv values."""
import base64
import json
import os
from pathlib import Path
import sys

QUERY = '''mutation CreateVersionCommit($input: CreateCommitOnBranchInput!) {
  createCommitOnBranch(input: $input) { commit { oid url } }
}'''


def write_payload(output: Path, directory: Path, env: dict[str, str]) -> None:
    """Encode the two prepared files and preserve the exact-head CAS contract."""
    repository = env['GITHUB_REPOSITORY']
    run_id = env['RUN_ID']
    attempt = env['RUN_ATTEMPT']
    additions = [
        {'path': name, 'contents': base64.b64encode((directory / name).read_bytes()).decode('ascii')}
        for name in ('pubspec.yaml', 'CHANGELOG.md')
    ]
    payload = {
        'query': QUERY,
        'variables': {'input': {
            'branch': {'repositoryNameWithOwner': repository, 'branchName': env['TARGET_BRANCH']},
            'expectedHeadOid': env['EXPECTED_HEAD_OID'],
            'message': {
                'headline': 'chore(release): prepare version ' + env['TARGET_VERSION'],
                'body': (
                    f"Version authorized by @{env['AUTHORIZED_BY']}\n"
                    f"Workflow triggered by @{env['TRIGGERED_BY']}\n"
                    f'Run: https://github.com/{repository}/actions/runs/{run_id}\n'
                    f'Attempt: {attempt}\n'
                ),
            },
            'fileChanges': {'additions': additions},
            'clientMutationId': f'version-{run_id}-{attempt}',
        }},
    }
    output.write_text(json.dumps(payload), encoding='utf-8')


if __name__ == '__main__':
    write_payload(Path(sys.argv[1]), Path.cwd(), dict(os.environ))
