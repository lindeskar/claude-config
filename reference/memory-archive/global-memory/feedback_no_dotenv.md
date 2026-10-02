---
name: feedback-no-dotenv
description: User prefers explicit shell exports in README over .env files for local development config
metadata:
  type: feedback
---

For local dev configuration of personal Go projects, do NOT use `.env` files or `godotenv`-style loaders. Instead, document the required environment variables as `export` commands in the project README.

**Why:** Explicit shell exports keep secrets out of the repo by default (no `.env.example` drift, no risk of accidentally committing a real `.env`), and avoid pulling in a dotenv dependency for what is just `os.Getenv`.

**How to apply:**
- Skip `godotenv` and similar libraries in new project designs.
- Use stdlib `os.Getenv` / `os.LookupEnv` for config.
- In the README, provide copy-pasteable `export FOO=...` commands for each required env var, with placeholder values.
- Applies to personal/single-user projects. Multi-user services with config-loader frameworks are a separate case.
