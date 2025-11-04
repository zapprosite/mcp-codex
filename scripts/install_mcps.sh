#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${ROOT_DIR}/codex-config.toml"
ENV_FILE="${ROOT_DIR}/.env"
NPM_PREFIX="${ROOT_DIR}/.mcp"

CODEX_CMD=""

log() {
  printf '%b\n' "$1"
}

check_dependencies() {
  log "🔍 Verificando dependências..."

  if ! command -v node >/dev/null 2>&1; then
    log "❌ Node.js não encontrado. Instale Node.js antes de prosseguir."
    exit 1
  fi

  if ! command -v npm >/dev/null 2>&1; then
    log "❌ npm não encontrado. Instale o npm antes de prosseguir."
    exit 1
  fi

  if command -v codex >/dev/null 2>&1; then
    CODEX_CMD="codex"
  elif command -v codex-cli >/dev/null 2>&1; then
    CODEX_CMD="codex-cli"
  else
    log "❌ Codex CLI não encontrado (tente instalar via npm i -g @smithery-ai/codex-cli)."
    exit 1
  fi

  log "✅ Dependências disponíveis."
}

detect_os() {
  case "${OSTYPE:-}" in
    darwin*) OS="macos";;
    linux-gnu*) OS="linux";;
    msys*|cygwin*) OS="windows";;
    *) OS="unknown";;
  esac

  case "${OS}" in
    macos) log "🍎 Sistema detectado: macOS";;
    linux) log "🐧 Sistema detectado: Linux";;
    windows) log "🪟 Sistema detectado: Windows via WSL/Cygwin";;
    *) log "❓ Sistema operacional não identificado (${OSTYPE:-desconhecido}).";;
  esac
}

load_env() {
  if [[ ! -f "${ENV_FILE}" ]]; then
    log "❌ Arquivo ${ENV_FILE} não encontrado. Copie .env.example para .env e preencha as variáveis."
    exit 1
  fi

  set -o allexport
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +o allexport
}

prepare_directories() {
  mkdir -p "${ROOT_DIR}/data"
  mkdir -p "${ROOT_DIR}/data/memory-store"
  mkdir -p "${NPM_PREFIX}"
  log "📁 Pacotes npm serão instalados em ${NPM_PREFIX}"
}

install_mcps() {
  log "📦 Instalando MCPs essenciais..."

  MCP_PACKAGES=(
    "@modelcontextprotocol/server-sequential-thinking"
    "@mkusaka/mcp-shell-server"
    "@modelcontextprotocol/server-github"
    "@brave/brave-search-mcp-server"
    "@mzxrai/mcp-webresearch"
    "@kazuph/mcp-taskmanager"
    "mcp-server-sqlite-npx"
    "@mokei/mcp-fetch"
    "@iachilles/memento"
    "@executeautomation/playwright-mcp-server"
    "@modelcontextprotocol/server-filesystem"
    "@wonderwhy-er/desktop-commander"
    "exa-mcp"
    "mcp-obsidian"
    "@upstash/context7-mcp"
    "@cyanheads/git-mcp-server"
  )

  if [[ "${OS}" == "macos" ]]; then
    MCP_PACKAGES+=("iterm-mcp")
  fi

  failed=()
  for package in "${MCP_PACKAGES[@]}"; do
    log "→ npm install --prefix ${NPM_PREFIX} ${package}"
    if ! npm install --no-save --prefix "${NPM_PREFIX}" "${package}"; then
      log "⚠️  Falha ao instalar ${package}"
      failed+=("${package}")
    fi
  done

  if (( ${#failed[@]} )); then
    log "❌ Não foi possível instalar os MCPs: ${failed[*]}"
    log "Reveja a conectividade com a npm registry ou ajuste os nomes dos pacotes."
    exit 1
  fi

  log "✅ MCPs instalados."
}

setup_codex() {
  log "⚙️ Configurando Codex CLI..."

  mkdir -p "${HOME}/.codex"
  mkdir -p "${HOME}/.codex/logs"

  if [[ ! -f "${CONFIG_FILE}" ]]; then
    log "❌ Arquivo ${CONFIG_FILE} não encontrado. Verifique o repositório."
    exit 1
  fi

  # Detecta estrutura [mcpServers.*] e avisa que pode ser incompatível com o Codex CLI
  if grep -q "^\[mcpServers" "${CONFIG_FILE}"; then
    log "⚠️  O arquivo usa a estrutura [mcpServers.*] (repo). O Codex CLI pode esperar [mcp_servers.*]."
    log "    Pulando cópia para ~/.codex/config.toml. Use o script de validação local:"
    log "    → python scripts/test-mcps.py"
  else
    if cp "${CONFIG_FILE}" "${HOME}/.codex/config.toml"; then
      log "✅ Configuração copiada para ~/.codex/config.toml"
    else
      log "❌ Não foi possível escrever em ~/.codex/config.toml (permissão negada?)."
      log "   Copie o arquivo manualmente ou execute este script com permissões elevadas."
      exit 1
    fi
  fi
}

verify_installation() {
  log "🔍 Verificando instalação..."

  if "${CODEX_CMD}" mcp list >/dev/null 2>&1; then
    log "✅ MCPs reconhecidos pelo Codex CLI:"
    "${CODEX_CMD}" mcp list
  else
    log "❌ Falha ao listar MCPs. Execute \"${CODEX_CMD} mcp status\" para detalhes."
  fi
}

main() {
  log "🎯 Iniciando instalação completa dos MCPs..."
  check_dependencies
  detect_os
  load_env
  prepare_directories
  install_mcps
  setup_codex
  verify_installation
  log ""
  log "🎉 Instalação concluída."
  log ""
  log "📋 Próximos passos:"
  log "1. Revise docs/API-SETUP-GUIDE.md para validar as chaves."
  log "2. Execute python scripts/setup-apis.py para automatizar o preenchimento do .env (opcional)."
  log "3. Rode python scripts/test-mcps.py para confirmar respostas básicas."
}

main "$@"
