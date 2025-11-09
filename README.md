# Codex MCP Orchestrator

**Status:** Estável (daemon headless + auditoria)

## Visão Geral
Orquestrador para manter MCPs ativos com Codex CLI sob systemd-user, sem erros de TTY, com auditoria e logs UTC.

### Recursos
- Loop headless com PTY real
- Auditoria horária + cache MCP
- Scripts de smoke/audit
- Integração GitHub + systemd user

### Estrutura
~/.npm-global/bin/codex # wrapper
~/.npm-global/bin/codex-real # binário real
~/.local/bin/codex-daemon-shim # loop PTY
~/.codex/ # logs, cache, prompts
scripts/ # smoke, audit

### Comandos úteis
```bash
codex env:seed
systemctl --user status codex-daemon.service
./scripts/mcp-smoke.sh
./scripts/mcp-audit.sh
```

### Auditoria automática

* Executada via `codex-audit.timer` a cada 60 min
* Logs em `~/.codex/daemon.log` e `auto-run.log`

### Licença

MIT — ©2025 Refrimix DevOps / AI Stack Initiative
