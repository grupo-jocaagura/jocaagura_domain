# Controlled Flutter releases

Reference: `grupo-jocaagura/jocaagura_domain_core@f00f35dc36e7a408f245dffc8d447a05061deb17`.
This adapts its release policy, notes, orchestration, publisher and tests to the
Flutter package. The package version is `2.0.0`, now published; evidence integration does not upload it again.

## Gates and authority

- `validate_pr.yaml` is read-only and reusable. It runs signatures, Python
  release-policy tests, Flutter 3.50.0 / Dart 3.14.0 format/analyze, Flutter tests,
  coverage >=90%, schemas and publication dry-run.
- `validate_pr_master.yaml` accepts only an official same-repository
  `develop -> master` PR. It checks a strictly increasing stable version, dated
  notes and eligibility against pub.dev. Its final `Validate PR to master` job
  fails if readiness or any reusable CI dependency fails/skips/cancels. That
  required check name is preserved.
- `publish.yaml` replaces `publish.yml`; there is only one upload command. A
  push to a branch or a PR cannot publish. Allowed entries are human-pushed
  stable version tags, or a tag dispatch with completed domain-specific CP-0.
- Before and after CI the publisher verifies the exact official merged release
  PR, current master SHA, live tag resolution, GitHub-verified commit signature,
  immutable tag rules, metadata and public version state. It rechecks before
  upload to reject drift or a newly published duplicate. Existing versions skip
  upload. Tags are never moved or deleted to recover a failure.
- The publisher has a global concurrency lock. `id-token: write` is limited to
  the actual upload job and the separate read-only OIDC probe. GitHub release
  creation and orchestration writes are isolated from CI/validation jobs.
- Pub.dev success is read back from its version endpoint (identity, version,
  repository and core constraint). A GitHub Release is evidence after upload,
  never evidence that a dispatch request alone uploaded anything.

## OIDC and existing configuration

The upload job uses the existing GitHub environment `pub.dev`, Flutter setup
and official `dart-lang/setup-dart@v1` for short-lived pub.dev authentication.
No PAT, service-account key or persistent pub.dev credential is introduced.
`GITHUB_TOKEN` is used for GitHub API access, not as a pub.dev publishing token.

`oidc_policy.py` verifies GitHub's RS256 signature/JWKS, expiry, issuer, pub.dev
audience, numeric repository/owner identities, environment/sub, workflow path,
event, ref, SHA, run and hosted-runner context. Upload mode also requires a
protected tag. No raw JWT is logged or included in artifacts.

`oidc_probe.yaml` obtains an actual signed identity with audience `https://pub.dev`
in environment `pub.dev`. It runs only for same-repository PRs or manual dispatch;
fork PRs cannot request it. It has no upload commands and contacts no pub.dev
upload API. The safe claims artifact is a **GitHub OIDC identity check**, not a
pub.dev upload or proof that pub.dev accepted the candidate's tag/event policy.

The maintainer confirms automated publishing was already configured. The current
browser session could not inspect package administration (insufficient permission),
so its exact saved policy is not claimed as independently observed. Before the
real upload, verify that the existing pub.dev configuration matches:

- repository `grupo-jocaagura/jocaagura_domain`;
- tag pattern `v{{version}}`;
- tag push for the first supervised upload; tag workflow_dispatch for subsequent
  automated dispatches;
- required GitHub environment `pub.dev` (if enforced there).

Official reference: https://dart.dev/tools/pub/automated-publishing
No settings on pub.dev were modified by this PR.

## Tag protection

Domain's active ruleset `27088011` protects `refs/tags/v*` against update,
deletion and force push, with no bypass. This follows the core's immutable-tag
rule. The validators re-read effective rules before upload and dispatch. No
release tags were created by the publisher homologation work.

Master's existing review, signature, linear-history and required-check rules
remain in place. Develop's disabled ruleset was observed, not silently enabled
or treated as equivalent to protection. CodeQL now analyzes Actions YAML rather
than the former non-executable `codeql.txt` placeholder.

## First real domain OIDC release and CP-0

Domain's real 2.0.0 OIDC upload completed successfully in
[run 43219171001](https://github.com/grupo-jocaagura/jocaagura_domain/actions/runs/43219171001).
The signed immutable tag `v2.0.0` resolves to master release commit
`675abfc904775b2e02dbeebd3890dbad1cd1f480` from the approved PR #222.
`evidence/cp0-2.0.0.json` now records **passed** for this package's own upload,
not the core's certification or a non-publishing probe.

The manifest combines GitHub-verified OIDC claims, the server's successful upload
response, independent hosted-version verification and the maintainer-provided
pub.dev Activity log excerpt. The downloaded archive hash was verified, and its
83 lib files plus pubspec/CHANGELOG match the authorized commit byte for byte.
Full certification: https://github.com/grupo-jocaagura/jocaagura_domain/issues/213#issuecomment-6823987382

`observed_claims.pub_dev_upload=not_executed` refers only to the identity-check
phase before upload. It is preserved verbatim; `publication.status=passed`, the
successful run and audit attribution document the subsequent real upload.

After this evidence PR is reviewed and merged to develop, it will accompany
future release candidates into master and their immutable tags. This removes
only the missing-CP-0 prerequisite: official PR provenance, version eligibility,
full CI, signature, live master/tag checks, concurrency and OIDC remain mandatory.
It does not publish a new package or dispatch any workflow by itself.

**Do not retry 2.0.0, move its tag or edit its frozen source.** The original
v2.0.0 tag still contains its historical pending manifest; it must not be changed
to backfill evidence. Future releases consume this passed manifest. If only
GitHub Release evidence needs repair, repair that step without uploading again.

## Reproduction and negative tests

```bash
python -m pip install -r .github/scripts/requirements.txt
python -m unittest discover -s .github/scripts/tests -v
actionlint -shellcheck=
python .github/scripts/publication_policy.py --metadata-only
# Only for a future, unpublished release candidate:
python .github/scripts/publication_policy.py --require-new
```

Unit/integration tests use fake service responses and actual Bash workflow
guards; they never upload or create real tags. They reject forks, wrong branch,
wrong SHA, unsigned source, moved/unprotected tags, missing CP-0, reused or
regressing versions, malformed/service-error responses, failed CI and invalid
JWT signatures, audience, issuer, environment, workflow or expiry.
