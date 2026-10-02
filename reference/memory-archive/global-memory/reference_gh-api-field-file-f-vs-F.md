---
name: gh-api-field-file-f-vs-F
description: gh api -f treats key=@file as a LITERAL string; only -F reads the file. Use -F body=@file to send a comment/PR body from a file
metadata:
  type: reference
---

`gh api` field flags differ in how they handle `@`:

- `-f`/`--raw-field key=value` — value is **always a literal string**, even `key=@path` (sends the literal text `@path`, does NOT read the file).
- `-F`/`--field key=value` — typed field; `key=@path` **reads the file contents** as the value (and does type coercion for non-`@` values like `true`/numbers).

So to POST/PATCH a PR/issue comment body from a file: `gh api repos/O/R/issues/N/comments -F body=@body.txt` (never `-f body=@body.txt` — that literally posts `@body.txt`). This is the safe way to pass bodies containing backticks/`$`/newlines/`!` without shell-quoting them.

**Either flag also switches the request to POST.** So they can't be used to add a query parameter to a *read*: `gh api repos/O/R/contents/<path> --field ref=<sha>` POSTs and returns nothing instead of reading the file at that ref. For GET reads, put the parameter in the path — `gh api 'repos/O/R/contents/<path>?ref=<sha>'` (quote it; `?` is a zsh glob char). Use `-X GET -F` only when you genuinely need typed params on a GET.

The trap is silent: with `-f` the request still succeeds (201), you just get a comment whose text is the path. Caught this building the gha-common `pr-comment` action — the unit test's `gh` stub read the file for both `-f` and `-F`, so it passed locally and only the live self-test revealed literal `@/…/body.txt` comment bodies. When stubbing `gh` for tests, model `-f` as literal so this class of bug fails fast. See [[check-local-clones-first]].
