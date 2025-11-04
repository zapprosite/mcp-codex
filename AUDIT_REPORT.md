# 🔍 MCP Codex Repo Audit (2025-11-04)

Status: Completed – Aggressive scan across config, security, and tooling.

## Overview
- Purpose: Repository configures multiple MCP servers for Codex CLI.
- Source files: Mainly configuration, docs, and helper scripts (no app runtime).
- Notable dirs: `docs/`, `scripts/`, `logs/`, `data/`, `.mcp/` (vendors), `.vscode/`.
- CI/CD: No GitHub Actions workflows found.
- Git: No commits yet on `main`; no remote configured.

## Key Findings
1) High-risk: Secrets previously hardcoded in `codex-config.toml` (now sanitized)
   - Replaced literals with env placeholders: `${GITHUB_TOKEN}`, `${BRAVE_API_KEY}`, `${FIRECRAWL_API_KEY}`, `${TAVILY_API_KEY}`, `${CONTEXT7_API_KEY}`, `${TESTSPRITE_API_KEY}`.
   - Action: Rotate exposed tokens; store only in `.env`/OS env. Avoid committing secrets.

2) `.env` contains real tokens (kept out of git)
   - Good: `.env` appears ignored by git.
   - Action: Keep local-only; rotate tokens listed in `.env` for safety.

3) Dependency vulnerabilities (from `.mcp/package.json` → `npm audit`)
   - Total: 5 (High: 2, Moderate: 3, Critical: 0)
   - Notable: `playwright` (GHSA-7mvr-c777-76hp) – update to `>= 1.55.1`.
   - See `SECURITY_FINDINGS.json` for summary.

4) Portability risk
   - `mcpServers.fetch` uses a Windows-specific uvx path; prefer a cross-platform executable or env-driven path.

5) Stripe / DB
   - Stripe: Only mentioned in docs; no integration code detected.
   - Database: No SQLite DB/migrations present; generated stub `SCHEMA_BACKUP.sql`.

## Code/Repo Metrics
- See `CODE_METRICS.json`.
- Scope excludes `.git` and `.mcp` vendor content.

## Produced Artifacts
- `AUDIT_REPORT.md` (this file)
- `SECURITY_FINDINGS.json` (sanitization + npm audit summary)
- `TEST_RESULTS.log` (E2E/DB/Stripe status)
- `CODE_METRICS.json` (structure overview)
- `SCHEMA_BACKUP.sql` (stub – no schema found)

## Recommendations
- Rotate all tokens found in `codex-config.toml` and `.env`.
- Keep secrets exclusively in environment or a secrets manager.
- Pin and update vulnerable deps in `.mcp` (ensure `playwright >= 1.55.1`).
- Replace Windows-only paths with cross-platform commands or env-var indirection.
- Add CI (GitHub Actions) for lint/audit checks and secret scanning (e.g., `gitleaks`).
- Commit an updated `.env.example` mirroring required keys (already present) and keep `.env` ignored.

## Next Steps (Optional)
- Create GitHub repo + remote; push sanitized config.
- Add CI to run `npm audit` in `.mcp` and a basic secret scan on PRs.
- If planning UI tests later, add a minimal Playwright smoke test harness.
