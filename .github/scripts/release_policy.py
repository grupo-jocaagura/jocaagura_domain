#!/usr/bin/env python3

"""Validate release metadata for jocaagura_domain."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


SEMVER_PATTERN = re.compile(
    r"^(0|[1-9]\d*)\."
    r"(0|[1-9]\d*)\."
    r"(0|[1-9]\d*)"
    r"(?:-([0-9A-Za-z.-]+))?"
    r"(?:\+([0-9A-Za-z.-]+))?$"
)

CHANGELOG_VERSION_PATTERN = re.compile(
    r"^## \[(\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?)\]",
    re.MULTILINE,
)


class ReleasePolicyError(Exception):
    """Represent a release policy validation failure."""


def parse_version(value: str) -> tuple[int, int, int]:
    """Parse a stable semantic version into numeric components."""

    match = SEMVER_PATTERN.fullmatch(value)

    if match is None:
        raise ReleasePolicyError(f"Invalid semantic version: {value}")

    if match.group(4) is not None or match.group(5) is not None:
        raise ReleasePolicyError(
            f"Pre-release/build metadata is not supported: {value}"
        )

    return (
        int(match.group(1)),
        int(match.group(2)),
        int(match.group(3)),
    )


def read_pubspec_version(pubspec_path: Path) -> str:
    """Return the package version declared in pubspec.yaml."""

    for line in pubspec_path.read_text(encoding="utf-8").splitlines():
        if line.startswith("version:"):
            version = line.partition(":")[2].strip()

            if not version:
                break

            return version

    raise ReleasePolicyError(
        f"Version not found in {pubspec_path}"
    )


def read_changelog_versions(changelog_path: Path) -> list[str]:
    """Return documented versions from newest to oldest."""

    content = changelog_path.read_text(encoding="utf-8")

    versions = CHANGELOG_VERSION_PATTERN.findall(content)

    if not versions:
        raise ReleasePolicyError(
            f"No version entries found in {changelog_path}"
        )

    return versions


def validate_release(
    *,
    current_version: str,
    target_version: str,
    changelog_versions: list[str],
) -> None:
    """Validate the requested version transition."""

    current = parse_version(current_version)
    target = parse_version(target_version)

    if target <= current:
        raise ReleasePolicyError(
            f"Target version {target_version} must be greater "
            f"than current version {current_version}"
        )

    if not changelog_versions:
        raise ReleasePolicyError("CHANGELOG contains no versions")

    latest_changelog_version = changelog_versions[0]

    if latest_changelog_version != target_version:
        raise ReleasePolicyError(
            "Latest CHANGELOG version "
            f"{latest_changelog_version} does not match "
            f"target version {target_version}"
        )


def main() -> int:
    """Run release policy validation."""

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--target-version",
        required=True,
    )
    parser.add_argument(
        "--pubspec",
        default="pubspec.yaml",
    )
    parser.add_argument(
        "--changelog",
        default="CHANGELOG.md",
    )

    arguments = parser.parse_args()

    pubspec_path = Path(arguments.pubspec)
    changelog_path = Path(arguments.changelog)

    current_version = read_pubspec_version(pubspec_path)
    changelog_versions = read_changelog_versions(changelog_path)

    validate_release(
        current_version=current_version,
        target_version=arguments.target_version,
        changelog_versions=changelog_versions,
    )

    print(
        "Release policy validation passed: "
        f"{current_version} -> {arguments.target_version}"
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())