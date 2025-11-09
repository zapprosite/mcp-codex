#!/usr/bin/env bash
set -Eeuo pipefail

# Wrapper para carregar o .env do repositório antes de executar comandos do Codex CLI.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
ENV_FILE="${PROJECT_ROOT}/.env"

verify_required_vars() {
  local required_vars=(
    "GITHUB_TOKEN"
    "BRAVE_API_KEY"
    "EXA_API_KEY"
    "CONTEXT7_API_KEY"
    "SQLITE_DB_PATH"
    "FILESYSTEM_BASE_PATH"
    "MEMORY_DB_PATH"
  )
  local missing=()

  for name in "${required_vars[@]}"; do
    if [[ -z "${!name:-}" ]]; then
      missing+=("${name}")
    fi
  done

  if (( ${#missing[@]} )); then
    printf '⚠️  Variáveis obrigatórias ausentes: %s\n' "$(IFS=','; echo "${missing[*]}")"
    printf '   Confirme %s e reabra o shell antes de usar MCPs dependentes.\n' "${ENV_FILE}"
  fi
}

if [[ ! -f "${ENV_FILE}" ]]; then
  printf '❌ Arquivo %s não encontrado. Copie .env.example para .env e preencha as variáveis.\n' "${ENV_FILE}" >&2
  exit 1
fi

set -o allexport
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +o allexport

verify_required_vars

printf '[OK] .env carregado (%s).\n' "${ENV_FILE}"

if [[ $# -eq 0 ]]; then
  printf '[INFO] Nenhum comando informado. Abrindo um shell com .env carregado.\n'
  exec bash --login
fi

printf '[RUN] %s\n' "$*"
exec "$@"
