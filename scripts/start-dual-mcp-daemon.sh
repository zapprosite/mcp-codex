#!/usr/bin/env bash
set -Eeuo pipefail

echo "🚀 Iniciando Dual MCP Daemon..."
echo "Tempo: $(date)"

OUTDIR="${HOME}/.codex"
LOGDIR="${OUTDIR}/logs"
mkdir -p "${LOGDIR}" "${OUTDIR}/prompts"

# Instalar prompt orquestrador no diretório do usuário
REPO_PROMPT_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/prompts/dual-mcp-orchestrator.toml"
USER_PROMPT_FILE="${OUTDIR}/prompts/dual-mcp-orchestrator.toml"
if [[ -f "${REPO_PROMPT_FILE}" ]]; then
  cp -f "${REPO_PROMPT_FILE}" "${USER_PROMPT_FILE}"
fi

# Exportar secrets do ambiente atual, se definidos
export GITHUB_TOKEN="${GITHUB_TOKEN:-}"
export BRAVE_API_KEY="${BRAVE_API_KEY:-}"
export FIRECRAWL_API_KEY="${FIRECRAWL_API_KEY:-}"
export TAVILY_API_KEY="${TAVILY_API_KEY:-}"
export STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY:-}"

DAEMON_LOG="${LOGDIR}/daemon.log"

start_with_daemon_cmd() {
  if codex daemon:start --help >/dev/null 2>&1; then
    codex daemon:start \
      --profile=dual-mcp-orchestrator \
      --log-level=debug \
      --log-file="${DAEMON_LOG}" \
      --detach
    return 0
  fi
  return 1
}

start_with_fallback_exec() {
  # Fallback: iniciar processo em background usando codex exec (se disponível)
  if command -v codex >/dev/null 2>&1; then
    nohup codex exec -c features.background=true - < "${USER_PROMPT_FILE}" \
      >> "${DAEMON_LOG}" 2>&1 & echo $! > "${OUTDIR}/daemon.pid"
    echo "ℹ️  Fallback em uso (codex exec). Verifique logs em ${DAEMON_LOG}"
    return 0
  fi
  return 1
}

if start_with_daemon_cmd; then
  echo "🎉 Daemon iniciado com sucesso (daemon:start)."
else
  echo "⚠️  'codex daemon:start' não disponível; tentando fallback..."
  if start_with_fallback_exec; then
    echo "🎉 Daemon iniciado em modo fallback."
  else
    echo "❌ Não foi possível iniciar o daemon. Verifique instalação do Codex CLI."
    exit 1
  fi
fi

sleep 3 || true
echo "✅ Verificando MCPs..."
if codex mcp list --json >/dev/null 2>&1; then
  codex mcp list --json | jq -r '.servers[].name' || true
else
  echo "ℹ️  Comando 'codex mcp list' indisponível nesta versão."
fi

echo "Logs: tail -f ${DAEMON_LOG}"
echo "Monitor: (se disponível) codex daemon:status"

