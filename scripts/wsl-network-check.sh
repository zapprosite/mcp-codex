#!/usr/bin/env bash

# WSL Network Diagnostics for MCP Proxy
# - Checks external HTTPS reachability
# - Verifies local service at localhost:6274
# - Validates HTTP response code/content-type for provided URL
# Usage:
#   ./scripts/wsl-network-check.sh [URL]
# Default URL:
DEFAULT_URL="http://localhost:6274/?MCP_PROXY_AUTH_TOKEN=cddfcac4f660818eedb05ce0be83ce56e13869cda283ba7af0fd83ac1ac7f2f3"

set -euo pipefail

URL="${1:-$DEFAULT_URL}"
PORT=6274

log() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

ensure_tools() {
  if ! command -v curl >/dev/null 2>&1; then
    log "curl não encontrado; instalando curl, ca-certificates e wget" 
    sudo apt update -y
    sudo apt install -y curl ca-certificates wget
  fi
}

print_versions() {
  log "Versões de ferramentas:"
  curl --version | head -n 1 || true
  if command -v wget >/dev/null 2>&1; then
    wget --version | head -n 1 || true
  fi
}

check_external_https() {
  log "Verificando HTTPS externo (example.com)" 
  local status
  status=$(curl -I -sS https://example.com | head -n 1 || true)
  echo "HTTPS example.com: ${status}"
}

check_local_port() {
  log "Checando porta local ${PORT} via /dev/tcp"
  if (echo > "/dev/tcp/localhost/${PORT}") >/dev/null 2>&1; then
    echo "port ${PORT}: open"
  else
    echo "port ${PORT}: closed"
  fi
}

check_url() {
  log "Testando URL: ${URL}"
  local out
  out=$(curl -sS -o /dev/null -w '%{http_code} %{content_type}\n' "${URL}" || true)
  echo "HTTP status/content-type: ${out}"
}

main() {
  log "Iniciando diagnóstico de rede WSL"
  ensure_tools
  print_versions
  check_external_https
  check_local_port
  check_url
  log "Diagnóstico concluído"
}

main "$@"

