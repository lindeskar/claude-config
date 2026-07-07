---
name: feedback_sandbox-network-test-assertion-failure
description: Sandboxed test runs that hit the network can fail as plain assertion mismatches (nil/empty results), not "operation not permitted" — suspect the sandbox before filing a code bug
metadata:
  type: feedback
---

When a local test run (`go test`, etc.) fails **deterministically** with empty/nil/short results that look like a logic bug, suspect the **command sandbox blocked outbound network** before concluding it's a real regression or filing an issue.

The trap: the sandbox network block does NOT always surface as an "Operation not permitted" / connection error. If the code-under-test **swallows the fetch error** (drops the failed result and continues), the failure shows up downstream as an ordinary **assertion mismatch** — e.g. a test expecting fetched URLs gets `nil`, or a count comes back short. Nothing in the output says "sandbox."

**Why:** In this session three `agentreview/vertex_test.go` tests fetched real `https://example.com` URLs (not a local server). They passed in CI (network available) but failed every time in my sandboxed `go test` runs, because the errored fetch was dropped and `FetchedURLs` came back nil. I read the deterministic failure as a master regression and filed a partly-wrong issue ("no network needed — uses the fake/replay path") — the opposite of the truth. The real fix (annotell/kognic-github-app#360) made the tests hermetic via a `RoundTripper` to a local server.

**How to apply:** If a sandboxed test fails with nil/empty/short results and the assertion involves anything fetched (URLs, HTTP, external hosts), rerun the specific test with the sandbox disabled *before* diagnosing it as a code bug or opening an issue. If it passes with network, it's a test-hermeticity gap, not a regression. Also: CI passing while a test fails locally is a strong tell it's an environment (network) difference, not the code. Related: [[feedback_verify-claims-against-source-not-docs]].
