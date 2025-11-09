#!/usr/bin/env bash
set -Eeuo pipefail

SEED_EXPECT="dual-mcp-orchestrator"
WRAP="$HOME/.npm-global/bin/codex"
REAL="$HOME/.npm-global/bin/codex-real"
LOG_DIR="$HOME/.codex"
DAEMON_LOG="$LOG_DIR/daemon.log"
AUTO_LOG="$LOG_DIR/auto-run.log"
HEALTH="$LOG_DIR/mcp-health.json"

ts(){ date -u +'%Y-%m-%dT%H:%M:%SZ'; }
say(){ printf '%s %s\n' "[$(ts)]" "$*"; }

echo "== MCP SMOKE =="

# 1) Caminhos e binários
say "-- paths"
command -v codex || { echo "codex não no PATH"; exit 1; }
[[ -x "$WRAP" ]] || { echo "wrapper ausente: $WRAP"; exit 1; }
[[ -x "$REAL" ]] || { echo "codex-real ausente: $REAL"; exit 1; }
echo "wrapper: $WRAP"
echo "real   : $REAL"

# 2) Wrapper sanity
say "-- wrapper sanity"
if grep -q "/usr/local/bin" "$WRAP"; then
  echo "ERRO: wrapper ainda referencia /usr/local/bin"
  exit 1
else
  echo "OK: wrapper sem /usr/local/bin"
fi

# 3) Seed somente
say "-- seed"
codex env:seed | grep -qx "$SEED_EXPECT" && echo "OK: seed=$SEED_EXPECT" || { echo "ERRO: seed incorreta"; exit 1; }

# 4) Serviço systemd de usuário
say "-- systemd"
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user is-enabled codex-daemon.service || true
  systemctl --user is-active codex-daemon.service || systemctl --user status codex-daemon.service --no-pager || true
else
  echo "systemd indisponível; usando fallback"
fi

# 5) Cache MCP
say "-- cache"
if [[ -s "$HEALTH" ]]; then
  BYTES=$(wc -c < "$HEALTH")
  echo "mcp-health.json: ${BYTES} bytes"
  if command -v jq >/dev/null 2>&1; then
    jq -e . "$HEALTH" >/dev/null && echo "OK: JSON válido" || echo "WARN: JSON inválido"
  fi
else
  echo "sem cache ainda"
fi

# 6) Logs
say "-- logs (tails)"
[[ -f "$AUTO_LOG"   ]] && { echo "--- auto-run.log (últimas 20) ---"; tail -n 20 "$AUTO_LOG"; } || echo "sem auto-run.log"
[[ -f "$DAEMON_LOG" ]] && { echo "--- daemon.log   (últimas 50) ---"; tail -n 50 "$DAEMON_LOG"; } || echo "sem daemon.log"

# 7) Execução mínima do CLI para exercitar MCPs
say "-- probe"
CODEX_FORCE_PSEUDOTTY=0 "$REAL" mcp list --json >/dev/null 2>&1 && echo "OK: codex mcp list" || echo "WARN: mcp list falhou (consultar daemon.log)"

# 8) Resumo
say "-- summary"
echo "SEED: $SEED_EXPECT"
echo "WRAP: $WRAP"
echo "REAL: $REAL"
echo "LOGS: $LOG_DIR/(auto-run.log, daemon.log, mcp-health.json)"
