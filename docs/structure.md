# Estrutura Técnica — MCP Orchestrator

* **scripts/**

  * `mcp-smoke.sh` — checa integridade.
  * `mcp-audit.sh` — auditoria horária.
* **systemd/**

  * `codex-daemon.service` — executa o shim.
  * `codex-audit.timer` — dispara auditoria.
* **.codex/**

  * `daemon.log`, `auto-run.log`, `mcp-health.json`.
