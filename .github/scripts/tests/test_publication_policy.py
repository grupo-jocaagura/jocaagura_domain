"""Release policy boundaries and integration with the required CI check."""

from copy import deepcopy
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import unittest
from unittest.mock import patch
from urllib.error import HTTPError, URLError

import yaml

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / ".github/scripts"))
from publication_policy import (PACKAGE, REPOSITORY, metadata, publication_state,
                            read_json, require_merged_commit, require_release_pr)

SHA = "a" * 40
SPEC = "name: jocaagura_domain\nversion: 0.1.0\nrepository: https://github.com/grupo-jocaagura/jocaagura_domain\n"
SPEC += 'environment:\n  sdk: ">=3.14.0 <4.0.0"\n  flutter: ">=3.50.0"\ndependencies:\n  flutter:\n    sdk: flutter\n  jocaagura_domain_core: ^1.3.0\n'

PR = {
    "base": {"ref": "master", "repo": {"full_name": REPOSITORY}},
    "head": {"ref": "develop", "repo": {"full_name": REPOSITORY}},
    "state": "closed", "merged_at": "2026-09-12T23:00:00Z", "merge_commit_sha": SHA,
}


def package(*versions):
    return {"name": PACKAGE, "versions": [{"version": v} for v in versions]}


class ReleasePolicyTests(unittest.TestCase):
    def test_canonical_publishable_sdk_only_identity(self):
        self.assertEqual(metadata(SPEC), "0.1.0")
        cases = [SPEC.replace("name: jocaagura_domain", "name: wrong_package"),
                 SPEC.replace("https://github.com/", "https://invalid.example/"),
                 SPEC + "publish_to: none\n", SPEC + "publish_to: null\n",
                 SPEC + "dependencies:\n  http: any\n",
                 SPEC + "dependency_overrides:\n  http: any\n",
                 SPEC.replace("0.1.0", "0.0.0"), SPEC.replace("0.1.0", "0.1.0-rc.1"),
                 SPEC.replace("0.1.0", "0.1.0+1"), SPEC.replace("0.1.0", "01.1.0")]
        for spec in cases:
            with self.subTest(spec=spec), self.assertRaises(ValueError):
                metadata(spec)

    def test_actual_repository_keeps_the_published_name_and_entrypoint(self):
        metadata((ROOT / "pubspec.yaml").read_text(encoding="utf-8"))
        self.assertTrue((ROOT / "lib/jocaagura_domain.dart").is_file())
        self.assertFalse((ROOT / "packages").exists())

    def test_official_pr_and_exact_merge_commit(self):
        require_release_pr(PR)
        require_release_pr(PR, merged_sha=SHA)
        for side, key, value in [("base", "ref", "develop"), ("head", "ref", "feature"),
                                 ("head", "repo", {"full_name": "fork/jocaagura_domain"}),
                                 ("base", "repo", {"full_name": "fork/jocaagura_domain"})]:
            wrong = deepcopy(PR)
            wrong[side][key] = value
            with self.subTest(side=side, key=key), self.assertRaises(ValueError):
                require_release_pr(wrong)
        for key, value in [("merged_at", None), ("state", "open"), ("merge_commit_sha", "b" * 40)]:
            wrong = dict(PR, **{key: value})
            with self.subTest(key=key), self.assertRaises(ValueError):
                require_release_pr(wrong, merged_sha=SHA)
        for wrong in [None, {}, {"head": None}]:
            with self.assertRaises(ValueError):
                require_release_pr(wrong)

    def test_absent_existing_and_new_versions(self):
        self.assertEqual(publication_state("0.1.0", None), "manual_first_publication")
        self.assertEqual(publication_state("0.1.0", package("0.0.1")), "ready_to_publish")
        self.assertEqual(publication_state("0.1.0", package("0.0.1", "0.1.0")), "already_published")
        self.assertEqual(publication_state("0.1.0", package("0.1.0-rc.1")), "ready_to_publish")
        # Numeric comparison, not lexicographic comparison.
        with self.assertRaises(ValueError):
            publication_state("0.2.0", package("0.10.0"))
        with self.assertRaises(ValueError):
            publication_state("0.0.1", package("0.0.1", "0.1.0"))

    def test_invalid_service_responses_fail_closed(self):
        for response in [{}, {"name": "other", "versions": [{"version": "0.0.1"}]},
                         {"name": PACKAGE, "versions": []},
                         {"name": PACKAGE, "versions": [None]},
                         {"name": PACKAGE, "versions": [{}]}, package("garbage")]:
            with self.subTest(response=response), self.assertRaises(ValueError):
                publication_state("0.1.0", response)
        url = "https://pub.dev/api/packages/jocaagura_domain"
        for status in [401, 403, 429, 500, 503]:
            with patch("publication_policy.urlopen", side_effect=HTTPError(url, status, "failure", {}, None)):
                with self.assertRaises(ValueError):
                    read_json(url, missing_ok=True)
        with patch("publication_policy.urlopen", side_effect=HTTPError(url, 404, "missing", {}, None)):
            self.assertIsNone(read_json(url, missing_ok=True))
            with self.assertRaises(ValueError):
                read_json(url)
        for error in [URLError("offline"), TimeoutError("timeout")]:
            with patch("publication_policy.urlopen", side_effect=error), self.assertRaises(OSError):
                read_json(url, missing_ok=True)
        with patch("publication_policy.urlopen", return_value=io.BytesIO(b"not json")), self.assertRaises(ValueError):
            read_json(url)

    def test_commit_provenance_rejects_associated_but_unmerged_or_different_pr(self):
        require_merged_commit(SHA, reader=lambda *args, **kwargs: [PR])
        for prs in [[], [dict(PR, merged_at=None)], [dict(PR, merge_commit_sha="b" * 40)], {}]:
            with self.subTest(prs=prs), self.assertRaises(ValueError):
                require_merged_commit(SHA, reader=lambda *args, **kwargs: prs)
        with self.assertRaises(ValueError):
            require_merged_commit("master")

    def test_provenance_uses_pagination(self):
        responses = [[dict(PR, merge_commit_sha="b" * 40)] * 100, [PR]]
        urls = []
        def reader(url, **kwargs):
            urls.append(url)
            return responses.pop(0)
        require_merged_commit(SHA, reader=reader)
        self.assertTrue(urls[1].endswith("page=2"))

    def test_failed_release_readiness_fails_required_master_check(self):
        bash = Path("C:/Program Files/Git/bin/bash.exe") if os.name == "nt" else Path("/bin/bash")
        self.assertTrue(bash.exists())
        ci = yaml.load((ROOT / ".github/workflows/validate_pr_master.yaml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        script = ci["jobs"]["validate_master_pr"]["steps"][0]["run"]
        for release, checks, expected in [("success", "success", 0), ("failure", "success", 1),
                                           ("skipped", "success", 1), ("success", "failure", 1),
                                           ("success", "cancelled", 1)]:
            result = subprocess.run([str(bash), "--noprofile", "--norc", "-e"], input=script,
                                    text=True, capture_output=True,
                                    env=dict(os.environ, RELEASE_RESULT=release, CI_RESULT=checks))
            self.assertEqual(result.returncode, expected, result.stderr)

    def test_publisher_supports_verified_tag_dispatch_and_serializes_uploads(self):
        publish = yaml.load((ROOT / ".github/workflows/publish.yaml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        self.assertEqual(set(publish["on"]), {"push", "workflow_dispatch"})
        self.assertEqual(publish["permissions"], {"contents": "read"})
        self.assertEqual(publish["concurrency"]["cancel-in-progress"], "false")
        self.assertNotIn("github.ref", publish["concurrency"]["group"])


if __name__ == "__main__":
    unittest.main()
