# Contexto do Setup (08/11/2025)

## Ambiente
- SO: Windows 11 Pro (C: SSD SATA 110GB + D: NVME Gen3)
- WSL: Ubuntu 24.04, /mnt/d/projetos
- IDE: Trae (fork VS Code)
- Node: v22.21.0
- Codex CLI: v0.56.0

## Configuração MCP
- Manifesto: /mnt/d/projetos/mcp-codex/.mcp/servers.json
- Include: ~/.codex/config.toml aponta para servers.json
- 16 MCPs configurados (13 ativos):
  - Ativos: brave_search, context7, desktop_commander, exa_search, filesystem, git, github, memory, playwright, sequential_thinking, shell, sqlite, task_manager
  - Desativados temporariamente: fetch, obsidian, web_research (handshake failures)
- Env: carregado via scripts/codex-env.sh (mantém .env sem expor secrets)
- Allowlist: /mnt/d/projetos, /home/zappro (filesystem + desktop_commander)
- Timeouts: 45-90s por MCP

## Status
- wsl.conf: metadata,umask=22,fmask=11 ✅
- Permissões node_modules/.bin: +x aplicado ✅
- .vscode/settings.json: otimizado para drvfs (watcherExclude, polling=false) ✅

## Próximos Passos
1. Reativar fetch: testar @mokei/mcp-fetch vs d33naz-mcp-fetch
2. Obsidian: validar OBSIDIAN_VAULT_PATH existe e tem allow
3. Web_research: confirmar BRAVE_API_KEY e EXA_API_KEY válidos
4. Aplicar settings.json em outros repos (zappro-mvp, ollama/projeto-sollama, Land-Refrimix)

## Comandos Úteis
Recarregar env e listar MCPs
cd /mnt/d/projetos/mcp-codex && source scripts/codex-env.sh && codex mcp list

Teste funcional
codex "Liste os arquivos em /mnt/d/projetos/mcp-codex"
codex "Liste 3 PRs abertas em openai/openai-python"

Reativar MCP (exemplo: fetch)
cd /mnt/d/projetos/mcp-codex/.mcp
npx -y d33naz-mcp-fetch --help # se OK:
jq '.servers += {"fetch":{"command":"npx","args":["-y","d33naz-mcp-fetch"],"startup_timeout_sec":90}}' servers.json > servers.json.tmp && mv servers.json.tmp servers.json

text
