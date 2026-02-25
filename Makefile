CLAUDE_DIR := $(HOME)/.claude

LINKS := \
	$(CURDIR)/rules:$(CLAUDE_DIR)/rules \
	$(CURDIR)/global-CLAUDE.md:$(CLAUDE_DIR)/CLAUDE.md \
	$(CURDIR)/settings.json:$(CLAUDE_DIR)/settings.json

.PHONY: link

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
