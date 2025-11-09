# MCP Codex Orchestrator — AGENTS Contract

## 1. Propósito
Garantir comportamento previsível e seguro dos agentes Codex MCP.

## 2. Regras gerais
- Não expor variáveis sensíveis (.env nunca no Git).
- Scripts idempotentes e autocontidos.
- Logs em `~/.codex/` com timestamp UTC e tag `[MCP:*]`.
- Daemon ativo e sem erros de TTY.

## 3. Estrutura de automação
- `~/.npm-global/bin/codex` → wrapper principal
- `~/.local/bin/codex-daemon-shim` → loop headless com PTY
- `codex-daemon.service` (systemd user)
- `scripts/mcp-smoke.sh` (smoke) e `scripts/mcp-audit.sh` (auditoria)
- `~/.codex/prompts/dual-mcp-orchestrator.toml` (prompt)

## 4. Contratos
1) Daemon ativo e logs limpos.  
2) Seed fixo: `dual-mcp-orchestrator`.  
3) Cache JSON válido e não-vazio.  
4) Scripts retornam 0.  
5) Erros sempre registrados.

## 5. Operação
- Smoke → Burn-in → Audit → Report

## 6. Estilo
- Bash estrito (`set -Eeuo pipefail`)
- Lint antes de PR
- Logs compactos

## 7. Commits
- Atômicos e auditáveis
- Tag `rescue/<ts>` para rollback
- CI: smoke + lint obrigatórios
