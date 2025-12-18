# Copilot / AI Agent Instructions

Purpose
- Help AI coding agents be immediately productive in this small repo: a script-based "Cloud Resource Cleanup and Cost Reporting" toolset.

Quick summary (big picture)
- This repository currently contains minimal script scaffolding: a `bin/` folder with `cleanup.sh` and an empty `config/` directory. There is no build system, package manifest, or tests detected.
- Primary flow: shell scripts in `bin/` perform operational tasks using configuration stored in `config/` or environment variables. Treat `bin/` as the executable surface and `config/` as the configuration surface.

What to look for and why
- Scripts: open files under `bin/` (e.g. [bin/cleanup.sh](bin/cleanup.sh)) to understand inputs, environment variables and external tools called (AWS/Google/Azure CLIs, jq, curl, etc.).
- Config: inspect `config/` for secrets, credential files, or YAML/JSON settings. If missing, expect runtime use of environment variables.
- No tests/CI: because there are no test or CI files, prioritize minimal, non-invasive changes and ask the repo owner before adding CI or credentials to the repo.

Developer workflows (how to run and debug)
- Running scripts: invoke shell scripts directly: `bash bin/cleanup.sh`. On Windows use WSL, Git Bash or an equivalent POSIX shell environment; do not assume PowerShell unless the repo contains PS scripts.
- Debugging: add `set -euo pipefail` and `set -x` temporarily to bash scripts to trace execution; keep changes minimal and reversible.

Project-specific conventions and patterns
- Executables live in `bin/` and should be small, self-contained shell scripts.
- Configuration lives in `config/` or via environment variables. Do not hardcode secrets into scripts.
- Keep changes to scripts idempotent and safe to run in dry-run mode; if adding flags, prefer `--dry-run`.

Integration points & external dependencies
- Expect shell tooling and cloud CLIs (e.g., `aws`, `gcloud`, `az`) rather than language-specific package managers. When adding integration code, document CLI versions in a short comment at the top of the script.

When editing or extending
- If you add new scripts, place them in `bin/` and document usage in a brief header comment (purpose, flags, required env vars).
- If you introduce new configuration files, place them under `config/` and reference them from scripts using a single top-level variable (example: `CONFIG_DIR="$(dirname \"$0\")/../config"`).
- Before making cross-cutting changes (adding CI, tests, or credentials handling), ask the repo owner for the intended target environment and credential storage strategy.

Examples (concrete)
- Run the cleanup script (POSIX shell):

  bash bin/cleanup.sh

- Typical header to add to a new script:

  #!/usr/bin/env bash
  set -euo pipefail
  # Purpose: brief description
  # Env: LIST required vars (e.g. CLOUD_PROJECT, AWS_PROFILE)

Notes and constraints
- There are no discoverable tests, CI configs, or readme documentation. Avoid making assumptions about cloud providers or credential storage. If you must choose defaults, prefer prompting the user or using environment variables.

If anything here is unclear or you want more specific rules (naming conventions, license, CI preferences), tell me which parts to expand and I will iterate.
