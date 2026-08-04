SHELL := /bin/bash

CLAUDE_DIR := $(HOME)/.claude

LINKS := \
	$(CURDIR)/rules:$(CLAUDE_DIR)/rules \
	$(CURDIR)/skills:$(CLAUDE_DIR)/skills \
	$(CURDIR)/global-CLAUDE.md:$(CLAUDE_DIR)/CLAUDE.md \
	$(CURDIR)/settings.json:$(CLAUDE_DIR)/settings.json

.PHONY: link unlink relink lint

link: ## Symlink config files to ~/.claude
	@for pair in $(LINKS); do \
		src=$${pair%%:*}; dst=$${pair##*:}; \
		if [ -L "$$dst" ]; then \
			echo "$$dst already linked"; \
		elif [ -e "$$dst" ]; then \
			echo "error: $$dst already exists — back it up first" >&2; exit 1; \
		else \
			ln -s "$$src" "$$dst"; \
			echo "linked $$dst -> $$src"; \
		fi; \
	done

unlink: ## Remove symlinks (only if they point into this repo)
	@for pair in $(LINKS); do \
		src=$${pair%%:*}; dst=$${pair##*:}; \
		if [ ! -L "$$dst" ]; then \
			echo "$$dst is not a symlink — skipping"; \
		elif [ "$$(readlink "$$dst")" != "$$src" ]; then \
			echo "warning: $$dst points to $$(readlink "$$dst"), not $$src — skipping" >&2; \
		else \
			rm "$$dst"; \
			echo "unlinked $$dst"; \
		fi; \
	done

relink: unlink link ## Recreate all symlinks

# Byte budget for always-loaded context: global-CLAUDE.md plus every rules/*.md
# that has no `paths:` frontmatter. Path-scoped rules load only when Claude reads
# a matching file, so they are measured but not budgeted. Raise deliberately.
RULES_BUDGET_BYTES := 44000

lint: ## Validate settings.json and detect drift
	@jq empty settings.json && echo "✓ settings.json is valid JSON"
	@always=""; scoped=""; \
		for f in global-CLAUDE.md rules/*.md; do \
			if head -n1 "$$f" | grep -q '^---$$' && awk 'NR>1 && /^---$$/{exit} NR>1' "$$f" | grep -q '^paths:'; then \
				scoped="$$scoped $$f"; \
			else \
				always="$$always $$f"; \
			fi; \
		done; \
		total=$$(cat $$always | wc -c | tr -d ' '); \
		nscoped=$$(echo $$scoped | wc -w | tr -d ' '); \
		scopedbytes=$$([ -n "$$scoped" ] && cat $$scoped | wc -c | tr -d ' ' || echo 0); \
		if [ "$$total" -gt "$(RULES_BUDGET_BYTES)" ]; then \
			echo "error: always-loaded context is $$total bytes (budget $(RULES_BUDGET_BYTES))" >&2; \
			echo "  slim the rules, add paths: frontmatter, or move detail to reference/, a skill, or the work wiki" >&2; \
			exit 1; \
		fi; \
		echo "✓ always-loaded context: $$total bytes (budget $(RULES_BUDGET_BYTES))"; \
		echo "  ($$nscoped path-scoped rule(s), $$scopedbytes bytes, excluded)"
	@dupes=$$(jq -r '.permissions.allow[]' settings.json | sort | uniq -d); \
		if [ -n "$$dupes" ]; then \
			echo "error: duplicate permissions:" >&2; \
			echo "$$dupes" >&2; \
			exit 1; \
		fi; \
		echo "✓ no duplicate permissions"
	@webfetch=$$(jq -r '.permissions.allow[] | select(startswith("WebFetch(domain:")) | sub("WebFetch\\(domain:"; "") | sub("\\)"; "")' settings.json | sort -u); \
		sandbox=$$(jq -r '.sandbox.network.allowedDomains[] | select(startswith("*") | not)' settings.json | sort -u); \
		only_fetch=$$(comm -23 <(echo "$$webfetch") <(echo "$$sandbox")); \
		only_sandbox=$$(comm -13 <(echo "$$webfetch") <(echo "$$sandbox")); \
		if [ -n "$$only_fetch" ] || [ -n "$$only_sandbox" ]; then \
			echo "warning: WebFetch and sandbox domain lists differ:" >&2; \
			[ -n "$$only_fetch" ]   && echo "  in WebFetch only:"  >&2 && echo "$$only_fetch"   | sed 's/^/    /' >&2; \
			[ -n "$$only_sandbox" ] && echo "  in sandbox only:"   >&2 && echo "$$only_sandbox" | sed 's/^/    /' >&2; \
		else \
			echo "✓ WebFetch and sandbox domains agree"; \
		fi
