---
name: reference_renovate-dashboard-pending-section
description: Renovate's dependency-dashboard "Pending Status Checks" has two unrelated causes — the minimumReleaseAge quarantine and the ordinary prCreation!=immediate branch-first delay; tell them apart by whether the branch exists
metadata:
  type: reference
---

The dashboard section renders every branch with `result === 'pending'`, and two unrelated paths set that (`lib/workers/repository/update/branch/index.ts`):

- **Internal-checks quarantine** — `minimumReleaseAge`/`minimumConfidence` unmet. Requires `!branchExists`, so **no branch is pushed**. Can sit indefinitely when the candidate has no `releaseTimestamp` and `minimumReleaseAgeBehaviour` is the default `timestamp-required`.
- **`prCreation` != `immediate`** — the branch was just committed, so the PR is withheld pending branch status. **The branch exists.** Self-resolves once branch status settles, and `prNotPendingHours` (default 25) opens the PR regardless. `internalChecksAsSuccess` lets internal checks count toward that status.

**Discriminator: does the branch exist on the remote?** Branch present ⇒ the benign `prCreation` delay, not a cooldown — don't diagnose a cooldown problem from the section title alone. Check `git ls-remote --heads origin 'refs/heads/renovate/*'`, and read the repo's own config before blaming a shared preset: repo-local `renovate.json` layers over `globalExtends` and routinely sets its own `minimumReleaseAge`, `prCreation`, and concurrency limits.

Related trap in the same area: the docker datasource resolves `releaseTimestamp` **only** for Docker Hub (its own `releaseTimestampNote` says so, from `tag_last_pushed`) and does not implement `postprocessRelease`, so GAR/GCR/ghcr/ECR/Quay images are timestamp-less. A cooldown that appears to bite such an image is therefore something else — most often a concurrency limit surfacing as the separate **Rate-Limited** section. See [[feedback_verify-claims-against-source-not-docs]].
