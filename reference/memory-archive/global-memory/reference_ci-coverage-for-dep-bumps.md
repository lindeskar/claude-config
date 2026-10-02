---
name: ci-coverage-for-dep-bumps
description: Green CI on a dependency/toolchain bump proves less than it looks — check whether the bumped thing ships in the runtime artifact, and whether any job runs the production build
metadata:
  type: reference
---

When asked whether CI can be trusted to show a dependency or toolchain bump is safe, establish two things before answering yes:

1. **Does the bumped component ship in the runtime artifact?** A build-only toolchain bump — e.g. the Node version of a builder stage whose only output is static assets copied into a runtime image with no Node in it — can only break the build, so a successful build *is* the verification. Read the Dockerfile's final stage to confirm what actually ships. A library bump ships code into the artifact, so runtime behaviour matters and the bar is higher.

2. **Does any job execute the production build?** Browser-level suites frequently point at a dev server: Playwright's `webServer: npm run dev` serves unbundled modules through the dev pipeline, so nothing exercises the minified, tree-shaken output. A build step that only proves compilation leaves prod-only bundling regressions invisible. Check `webServer.command` / the equivalent, not just that a browser suite exists.

Also confirm the workflow's `paths:` filter matches the changed files, or the suite you are relying on never ran at all — a Dockerfile-only change does not trigger a workflow filtered on `ui/**`. [[verify-ci-trigger-rules]] is the authoring-side twin of the same check.

Report which of these hold rather than reporting "CI is green", and name the residual gap.
