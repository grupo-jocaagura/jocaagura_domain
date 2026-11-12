import importlib.util
import unittest
from pathlib import Path


SCRIPT_PATH = (
    Path(__file__).resolve().parents[1]
    / "release_policy.py"
)

SPEC = importlib.util.spec_from_file_location(
    "release_policy",
    SCRIPT_PATH,
)

assert SPEC is not None
assert SPEC.loader is not None

release_policy = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(release_policy)


class ReleasePolicyTest(unittest.TestCase):

    def test_given_patch_bump_when_validated_then_it_passes(self) -> None:
        release_policy.validate_release(
            current_version="1.43.1",
            target_version="1.43.2",
            changelog_versions=["1.43.2", "1.43.1"],
        )

    def test_given_same_version_when_validated_then_it_fails(self) -> None:
        with self.assertRaises(release_policy.ReleasePolicyError):
            release_policy.validate_release(
                current_version="1.43.1",
                target_version="1.43.1",
                changelog_versions=["1.43.1"],
            )

    def test_given_downgrade_when_validated_then_it_fails(self) -> None:
        with self.assertRaises(release_policy.ReleasePolicyError):
            release_policy.validate_release(
                current_version="1.43.1",
                target_version="1.42.9",
                changelog_versions=["1.42.9"],
            )

    def test_given_target_missing_from_latest_changelog_when_validated_then_it_fails(
        self,
    ) -> None:
        with self.assertRaises(release_policy.ReleasePolicyError):
            release_policy.validate_release(
                current_version="1.43.1",
                target_version="1.43.2",
                changelog_versions=["1.43.1"],
            )

    def test_given_invalid_semver_when_parsed_then_it_fails(self) -> None:
        with self.assertRaises(release_policy.ReleasePolicyError):
            release_policy.parse_version("1.43")

    def test_given_prerelease_when_parsed_then_it_fails(self) -> None:
        with self.assertRaises(release_policy.ReleasePolicyError):
            release_policy.parse_version("1.43.2-beta.1")


if __name__ == "__main__":
    unittest.main()