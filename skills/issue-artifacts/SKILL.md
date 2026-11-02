---
name: issue-artifacts
description: >-
  Create, update, read and restore GitHub issue artifacts (versioned Markdown documents, plans, links
  and self-contained HTML attached to an issue) with `gh issue artifact`. Use when attaching a plan,
  inventory, RCA, research summary, status board or prototype to an issue; when an issue's findings
  are scattered across comments or a comment corrects an earlier one; when asked to "add an
  artifact", "attach this to the issue", "make a dashboard/board on the issue"; or when reading,
  downloading or restoring an existing artifact. Not GitHub Actions artifacts (`gh run download`).
---

# Issue artifacts

Named, versioned content attached to an issue (public preview; requires `gh` ≥ 2.103.0). Re-check `gh issue artifact <cmd> --help` before relying on a flag — the surface is still moving.

## Where content goes

| Content | Home |
|---|---|
| Problem statement, requirements, DoD | Issue body (`company-issues` structure) |
| Something that happened: a PR merged, a decision, a step done | Comment |
| Current state that gets corrected or extended: inventory, plan, RCA, consumer list, rollout matrix | Artifact |
| Interactive view of that state: status board, filterable table, diagram | `embedded_html` artifact |
| Durable pointer: Notion page, Slack thread, dashboard, static report | `link` artifact |

The tell for an artifact: a comment that says "correction to the above" or re-posts an updated table. Edit the artifact instead; the old state stays in its version history.

Version history replaces "as of" notes and correction paragraphs. The artifact states the current truth plus its method and sources.

## Types

| `type` | Created from | Notes |
|---|---|---|
| `generic` | any text file, `--body`, `--body-file` | Default Markdown document |
| `plan` | `--type plan` | Currently renders the same as `generic`; use it for implementation plans so agents can filter on it |
| `embedded_html` | `.html`/`.htm` file, or `--type embedded_html` | Viewers see **Source** first and click **Preview**; runs in a restricted sandbox |
| `link` | a URL argument or `.url` file | Named after the host unless `--name` |

The type can't be changed after creation. To change it, create a new artifact.

## Naming

Decide at creation whether the artifact is **living** (edited as the work moves) or a **snapshot** (frozen output, never edited):

| Kind | Name | Examples |
|---|---|---|
| Living | `<Subject> <kind>`, no date: the history holds versions, and the name stays stable for links | `Floating tag inventory`, `China 1.36 rollout plan`, `Cluster status board` |
| Snapshot | `<Subject> <kind> YYYY-MM-DD HHMM UTC` | `CVE scan 2026-11-02 1540 UTC`, `Vertex cost export 2026-10-20 0900 UTC` |
| Link | What it points at, not the host | `Design doc Notion`, `Incident thread Slack` |

- Sentence case. `<kind>` is the noun a reader scans for: inventory, plan, RCA, board, scan, export, log.
- Snapshot time is when the data was captured, not when it was uploaded. Use UTC (`date -u +'%Y-%m-%d %H%M UTC'`).
- Never put a date in a living artifact's name or edit a snapshot. A newer snapshot is a new artifact; a snapshot that needs correcting has turned into a living artifact, so rename it and drop the date.
- Allowed characters: letters, numbers, spaces, `.`, `-`, `_`; the name must start and end with a letter or number. No `:` (so `1540`, not `15:40`), no `/`, `#` or parentheses. The API rejects anything else with a 422.

## Commands

```bash
# create — one artifact per positional; '#Name' suffix sets the name
gh issue artifact create <issue> 'plan.md#Rollout plan' 'board.html#Status board' -R owner/repo
gh issue artifact create <issue> https://notion.so/... --name 'Design doc' -R owner/repo
gh issue artifact create <issue> --type plan --name 'Implementation plan' --body-file plan.md -R owner/repo

gh issue artifact list <issue> --json number,name,type,url -R owner/repo
gh issue artifact view <issue> <n> --json versions --jq '.versions[]|"v\(.version) \(.createdAt) \(.actor.login)"'
gh issue artifact edit <issue> <n> --body-file new.md -R owner/repo          # new version
gh issue artifact edit <issue> <n> --restore-version 2 -R owner/repo         # restore = new version, history kept
gh issue artifact download <issue> [<n>...] --dir out --clobber -R owner/repo
```

- Write content to a file and pass `--body-file`; don't inline Markdown with `!` or backticks through zsh.
- `--name` and `--body` only work when creating a single artifact. For several, use the `file#Name` form.
- File-derived names have parentheses stripped; other invalid characters fail (see Naming). `#` in a positional starts the name.
- `download` names files `<n>-<Name-with-dashes>.{md,html,url}`; `--output -` writes one artifact to stdout.

## Traps

- **Silent writes.** Creating or editing an artifact adds no timeline event and doesn't bump the issue's `updated_at`, so watchers aren't told. On a shared issue, follow a meaningful new version with a one-line comment linking the artifact URL (`drafting-messages` voice).
- **Delete is permanent and takes the history with it.** Never delete and recreate to "start over"; edit, or restore a version. `delete` needs `--yes` non-interactively; ask first.
- **Empty `list` prints nothing and exits 0.** Before treating it as "no artifacts", confirm the issue number and repo with a known positive (`--json number` returns `[]` on a real issue with no artifacts).
- **REST list has no pagination metadata** (no Link header or total). Page with `per_page=100` until a page comes back short. Writes can return `429`; honour the delay. REST header: `X-GitHub-Api-Version: 2026-03-10`.
- **HTML runs viewer-side.** Keep it self-contained: inline CSS/JS and data, no external fetches, no tokens or internal hostnames you wouldn't put in a comment. Support `prefers-color-scheme` because GitHub renders it in the viewer's theme.
- **Shared artifacts are outward-facing.** Creating or editing an artifact on a team issue publishes content like a comment does. Show the user the content first. Ask before editing an artifact someone else created.
- Cross-linking rules still apply: never reference `lindeskar/*` from an artifact on a company issue (`personal-issues`).

## Verify

After create or edit, download and `cmp` against the source file. Under the sandbox, write to files: `diff - file` fails on stdin.

```bash
gh issue artifact download <issue> <n> --dir /tmp/claude/dl --clobber -R owner/repo
cmp /tmp/claude/dl/<n>-*.md source.md && echo match
```
