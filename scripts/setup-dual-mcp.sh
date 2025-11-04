#!/usr/bin/env bash
set -Eeuo pipefail

echo "🔧 Setup Dual MCP - Trae IDE + mcp-codex"
echo "========================================"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME}"
CODEX_MCP_REPO="${ROOT_DIR}"

# 1) Limpar PATH duplicado (Windows nodejs no WSL)
echo "📋 [1/5] Limpando PATH..."
if [[ -f "${HOME_DIR}/.bashrc" ]] && grep -q "Program Files.*nodejs" "${HOME_DIR}/.bashrc"; then
  sed -i '/Program Files.*nodejs/d' "${HOME_DIR}/.bashrc"
  echo "✅ PATH Windows removido (duplicado)"
else
  echo "ℹ️  Nada a remover do PATH"
fi

# 2) Node.js LTS no WSL
echo "📦 [2/5] Instalando Node.js LTS no WSL..."
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs npm
  echo "✅ Node 20 LTS instalado"
else
  echo "✅ Node já instalado: $(node -v)"
fi

# 3) Descobrir MCPs
echo "🔍 [3/5] Detectando MCPs..."
TRAE_MCP_PATH="/mnt/c/Users/${USER:-WindowsUser}/.trae/tools"
echo "Trae IDE MCPs em (esperado): ${TRAE_MCP_PATH}"
if [[ -d "${CODEX_MCP_REPO}" ]]; then
  echo "✅ Repositório mcp-codex: ${CODEX_MCP_REPO}"
else
  echo "⚠️  mcp-codex não encontrado em ${CODEX_MCP_REPO}"
fi

# 4) Gerar ~/.codex/config.toml unificada
echo "⚙️  [4/5] Gerando ~/.codex/config.toml..."
mkdir -p "${HOME_DIR}/.codex" "${HOME_DIR}/.codex/logs" "${HOME_DIR}/.codex/prompts"

cat > "${HOME_DIR}/.codex/config.toml" << 'CONFIG_TOML'
# Codex CLI - Configuração Dual MCP
# Trae IDE (Windows) + mcp-codex (WSL Repository)
# Data: 2025-11-04

[mcp_server_discovery]
auto_detect = true
include_local_repos = true
sync_interval = "5m"

# ============ MCPs DO TRAE IDE (Windows/WSL) ============

[[mcpServers]]
name = "github-trae"
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env = { GITHUB_TOKEN = "${GITHUB_TOKEN}" }
source = "trae-ide"
enabled = true

[[mcpServers]]
name = "brave-search-trae"
command = "npx"
args = ["-y", "@modelcontextprotocol/server-brave-search"]
env = { BRAVE_API_KEY = "${BRAVE_API_KEY}" }
source = "trae-ide"
enabled = true

[[mcpServers]]
name = "firecrawl-trae"
command = "npx"
args = ["-y", "firecrawl-mcp"]
env = { FIRECRAWL_API_KEY = "${FIRECRAWL_API_KEY}" }
source = "trae-ide"
enabled = true

[[mcpServers]]
name = "tavily-trae"
command = "npx"
args = ["-y", "@mcptools/mcp-tavily"]
env = { TAVILY_API_KEY = "${TAVILY_API_KEY}" }
source = "trae-ide"
enabled = true

[[mcpServers]]
name = "playwright-trae"
command = "npx"
args = ["-y", "@executeautomation/playwright-mcp-server"]
source = "trae-ide"
enabled = true

[[mcpServers]]
name = "fetch-trae"
command = "npx"
args = ["-y", "@mokei/mcp-fetch"]
env = { PYTHONIOENCODING = "utf-8" }
source = "trae-ide"
enabled = true

# ============ MCPs DO REPOSITÓRIO LOCAL (mcp-codex) ============

# OBS: As entradas abaixo assumem scripts locais (servers/*.js). Ajuste ou remova se não existirem.

[[mcpServers]]
name = "github-local"
command = "node"
args = ["${CODEX_MCP_REPO}/servers/github-mcp.js"]
env = { GITHUB_TOKEN = "${GITHUB_TOKEN}" }
source = "mcp-codex-local"
enabled = true

[[mcpServers]]
name = "codex-analysis"
command = "node"
args = ["${CODEX_MCP_REPO}/servers/code-analyzer-mcp.js"]
source = "mcp-codex-local"
enabled = true

[[mcpServers]]
name = "stripe-mcp"
command = "node"
args = ["${CODEX_MCP_REPO}/servers/stripe-mcp.js"]
env = { STRIPE_SECRET_KEY = "${STRIPE_SECRET_KEY}" }
source = "mcp-codex-local"
enabled = true

# ============ CONFIGURAÇÃO GLOBAL ============

[sync]
enabled = true
check_interval = "5m"
auto_update = true
log_file = "${HOME_DIR}/.codex/mcp-sync.log"

[logging]
level = "info"
format = "json"
output = "${HOME_DIR}/.codex/logs/codex.log"

[experimental]
mcp_discovery = true
auto_retry = true
parallel_execution = true
CONFIG_TOML

echo "✅ config.toml criado em ${HOME_DIR}/.codex/config.toml"

# 5) Testar MCPs
echo "🧪 [5/5] Testando MCPs..."
if command -v codex &>/dev/null; then
  if codex mcp list --json >/dev/null 2>&1; then
    codex mcp list --json > "${HOME_DIR}/.codex/mcp-servers.json" || true
    if command -v jq >/dev/null 2>&1; then
      echo "✅ MCP discovery: $(jq '.servers | length' < "${HOME_DIR}/.codex/mcp-servers.json" 2>/dev/null || echo n/a)"
    else
      echo "ℹ️  jq não instalado; veja ${HOME_DIR}/.codex/mcp-servers.json"
    fi
  else
    echo "⚠️  Comandos 'codex mcp' não disponíveis nesta versão do CLI."
  fi
else
  echo "⚠️  Codex CLI não instalado. Instale: npm install -g @openai/codex-cli (ou variante em uso)"
fi

echo "🎉 Setup concluído!"
echo "Próximos passos:"
echo "1) Exporte variáveis: export GITHUB_TOKEN=... BRAVE_API_KEY=... etc"
echo "2) Execute: codex mcp list (se suportado)"
echo "3) Inicie daemon (se suportado) com scripts/start-dual-mcp-daemon.sh"

