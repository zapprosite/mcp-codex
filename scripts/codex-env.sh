#!/usr/bin/env bash
set -Eeuo pipefail

# Wrapper para carregar o .env do repositório antes de executar comandos do Codex CLI.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
ENV_FILE="${PROJECT_ROOT}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  printf '❌ Arquivo %s não encontrado. Copie .env.example para .env e preencha as variáveis.\n' "${ENV_FILE}" >&2
  exit 1
fi

set -o allexport
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +o allexport

printf '[OK] .env carregado (%s).\n' "${ENV_FILE}"

if [[ $# -eq 0 ]]; then
  printf '[INFO] Nenhum comando informado. Abrindo um shell com .env carregado.\n'
  exec bash --login
fi

printf '[RUN] %s\n' "$*"
exec "$@"
