# MCP Codex Playbook

Blueprint to run Model Context Protocol (MCP) servers with the Codex CLI on WSL without colliding with Windows desktop IDE setups. Senior-friendly documentation, predictable scripts, and a vetted MCP catalogue keep automation reliable and compartmentalised.

## Vision
- Provide a reproducible MCP environment for Codex CLI operators working inside WSL2 Ubuntu 24.04.
- Avoid cross-contamination with Trae IDE or other desktop MCP clients by isolating binaries, configs, and credentials.
- Offer clear operational guardrails so teams can onboard quickly, audit confidently, and extend MCP coverage safely.

## Repository at a Glance
- `codex-config.toml` – canonical list of MCP servers + environment placeholders.
- `scripts/` – setup, validation, and dual-run orchestration helpers.
- `docs/` – setup guides, audit logs, usage recipes, and the prompting catalogue.
- `data/` – local working data (`.gitkeep` only; real vaults/databases stay untracked).
- `docs/reports/` – consolidated audit outputs (security findings, schema stubs, metrics).

## Why a Dedicated Codex Repository?
1. **Process isolation** – Codex CLI loads MCPs from `.mcp/` and `.env` scoped to WSL; Trae IDE stays on its own Windows path (`%USERPROFILE%\.trae\mcp`).
2. **Deterministic ops** – All installation and validation steps live in versioned scripts, eliminating “works on my machine” drift.
3. **Auditable baseline** – Security audits, dependency reports, and backup snapshots remain in `docs/reports/`, enabling repeatable compliance checks.
4. **Safer experimentation** – New MCPs or config tweaks can be trialled here without risking production IDE workflows.

## Quick Start Checklist
1. Clone the repository inside WSL2 (`/mnt/d/projetos/mcp-codex`).
2. Review the orchestrator prompt in `docs/PROMPT.md` if you need to bootstrap via Codex CLI.
3. Copy secrets template: `cp .env.example .env`.
4. Populate the `.env` using the guided wizard: `python scripts/setup-apis.py`.
5. Install MCP dependencies: `bash scripts/install_mcps.sh`.
6. Validate the configuration end-to-end: `python3 scripts/test-mcps.py`.

## Environment & Tooling
- **Prerequisites**: Node.js LTS 20.x, npm, Python 3.12 (WSL image default), and `codex` CLI (`npm i -g @smithery-ai/codex-cli`).
- **Key variables**: `GITHUB_TOKEN`, `BRAVE_API_KEY`, `EXA_API_KEY`, `CONTEXT7_API_KEY`, `PLAYWRIGHT_WS_ENDPOINT`, `OBSIDIAN_VAULT_PATH`, `SQLITE_DB_PATH`, `MEMORY_DB_PATH`, `TASK_MANAGER_FILE_PATH` (see `.env.example`).
- **Scripts**:
  - `scripts/setup-apis.py` – interactive `.env` builder with format validation.
  - `scripts/install_mcps.sh` – installs all MCP servers into `.mcp/` and refreshes config overlays.
  - `scripts/test-mcps.py` – inspects `codex-config.toml`, confirms binaries exist, optionally cross-checks the live CLI state.
  - `scripts/start-dual-mcp-daemon.sh` – optional background orchestrator for dual Codex + Trae workflows.

## MCP Catalogue
| MCP | Package | Role in the stack | Why it ships here |
| --- | --- | --- | --- |
| `sequential_thinking` | `@modelcontextprotocol/server-sequential-thinking` | Structured reasoning agent | Baseline planning agent for Codex CLI automations. |
| `shell` | `@mkusaka/mcp-shell-server` | Sandboxed shell execution | Enables command execution with explicit audit trail. |
| `github` | `@modelcontextprotocol/server-github` | GitHub API bridge | Pulls issues/PRs without custom scripting; battle-tested despite deprecation notice. |
| `brave_search` | `@brave/brave-search-mcp-server` | Web search | Fast SERP access for research flows tied to Brave API keys. |
| `web_research` | `@mzxrai/mcp-webresearch` | Aggregated research agent | Combines Brave + Exa intelligence for richer summarisation. |
| `task_manager` | `@kazuph/mcp-taskmanager` | Task tracking | Persists multi-step workflows across sessions. |
| `sqlite` | `mcp-server-sqlite-npx` | Lightweight datastore | Gives Codex an embedded SQL surface pointing to `data/sqlite/mcp.sqlite`. |
| `fetch` | `d33naz-mcp-fetch` | HTTP client | Secure HTTP probing without leaking secrets, complementing CLI curl. |
| `memory` | `@iachilles/memento` | Long-term memory | Stores semantic notes in `data/memory-store/memento.db`. |
| `playwright` | `@executeautomation/playwright-mcp-server` | Browser automation | Bridges Codex with remote browsers via `PLAYWRIGHT_WS_ENDPOINT`. |
| `filesystem` | `@modelcontextprotocol/server-filesystem` | File access | Exposes project tree with respect to `FILESYSTEM_BASE_PATH`. |
| `desktop_commander` | `@wonderwhy-er/desktop-commander` | Desktop orchestration | Manages processes/files outside WSL when permitted. |
| `exa_search` | `exa-mcp` | Semantic web search | Taps Exa API for code-aware search tasks. |
| `obsidian` | `mcp-obsidian` | Knowledge vault connector | Syncs notes with `OBSIDIAN_VAULT_PATH`; ideal for Trae knowledge bases. |
| `context7` | `@upstash/context7-mcp` | Context7 document retrieval | Fetches embeddings/documents via Context7 API. |
| `git` | `@cyanheads/git-mcp-server` | Git operations | Adds read/write Git controls with token-based auth. |

## Validation Workflow
```bash
# Ensure environment keys and paths are correct
python3 scripts/validate-env.py

# Confirm MCP binaries/configuration and compare with codex CLI (optional)
python3 scripts/test-mcps.py --check-cli

# Quick CLI sanity check
codex mcp list
```

## Trae IDE Isolation Checklist
- Install Trae-specific MCP packages via `scripts/trae-mcp-setup.ps1` into `C:\Users\<user>\.trae\mcp`.
- Configure each Trae MCP with `node.exe` path + `dist/index.js` entrypoint (avoid `npx`).
- Set environment variables per MCP inside Trae (do **not** reuse the WSL `.env`).
- Use `FILESYSTEM_BASE_PATH` to restrict Codex filesystem reach and prevent cross-platform path leaks.
- When toggling between Codex CLI and Trae IDE, restart the Trae MCP panel after any `.env` or config change to keep transports in sync.

## Security & Audit Posture
- Pre-audit snapshot lives in branch `backup-pre-auditoria` plus `backup-pre-auditoria.tar.gz`.
- Hardened `.gitignore` keeps secrets, dependencies, caches, and binary artefacts out of version control.
- Historical cleanup executed with `git filter-repo` removed `.codex/`, `.vscode/`, and `artifacts/` from history; refer to `docs/SECURITY-AUDIT-2025-11.md` for exact commands.
- Audit evidence and metrics stored under `docs/reports/` for compliance reviews (`SECURITY_FINDINGS.json`, `CODE_METRICS.json`, `SCHEMA_BACKUP.sql`).
- Recommended pre-release check:
  ```bash
  git ls-files
  python3 scripts/validate-env.py
  python3 scripts/test-mcps.py
  ```

## Documentation Map
- `docs/PROMPT.md` – starter prompt for Codex CLI scaffolding.
- `docs/API-SETUP-GUIDE.md` – step-by-step credential acquisition for every MCP.
- `docs/MCP-USAGE-GUIDE.md` – command cheatsheet and troubleshooting flows.
- `docs/TRAe-MCP-SETUP.md` – deep dive on isolating Trae IDE MCPs.
- `docs/SECURITY-AUDIT-2025-11.md` – full audit narrative and remediation history.
- `docs/reports/` – machine-generated outputs from audits and diagnostics.

## Contributing & Support
- Follow the security-first workflow described in `CONTRIBUTING.md` (branch strategy, secret hygiene, testing expectations).
- Open issues describing new MCP requests or improvements to validation scripts.
- For incident response or secret rotation, start from `docs/reports/AUDIT_REPORT.md` and coordinate via the team’s secure channel.

---

Maintained by the MCP Codex engineering team. Feedback and PRs welcome.
