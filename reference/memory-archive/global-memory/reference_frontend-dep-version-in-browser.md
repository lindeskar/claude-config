---
name: frontend-dep-version-in-browser
description: Confirming which version of a frontend dep a deployed bundle contains — react-router sets window.__reactRouterVersion in production builds; build-time Node is never observable
metadata:
  type: reference
---

To confirm which version of a frontend dependency a *deployed* bundle actually contains, look for a library-injected global before reaching for anything more elaborate.

**react-router** assigns `window.__reactRouterVersion` at module load, guarded by a browser check and a try/catch. The assignment is in its `dist/production` build, not just `dist/development`, and survives Vite/rollup minification and tree-shaking (assigning to a global is a side effect, so the bundler keeps it). So `window.__reactRouterVersion` in the browser console reports the exact version serving that page. **React's** version is embedded too — react-dom throws at runtime if react and react-dom disagree — but is not exposed on a global; React DevTools reports it.

To find whether another library exposes something similar: `npm pack <pkg>@<ver>`, extract, and grep `dist/production` for a version global. Confirm it survives your bundler by installing the repo's exact lockfile and building — grep the emitted chunk. Build to a scratch `--outDir` when the normal output directory holds tracked files, since Vite empties it.

**The build-time Node version is not observable from the browser and cannot be** — nothing embeds it in the bundle. When the runtime image only serves built static assets (Node lives in a builder stage that is discarded), there is no Node at runtime at all, so the question has no answer to find. To surface build metadata deliberately, inject it with a Vite `define`.

See [[ci-coverage-for-dep-bumps]] for what green CI does and doesn't prove about such a bump.
