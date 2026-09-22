#!/bin/bash
# watchdog.sh <slug> <hhmm_esperado>
# Roda 20 min depois do horário da rotina. Se o heartbeat daquela janela não
# existir (ou for velho), grita — notificação + arquivo no Desktop.
set -uo pipefail
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SLUG="${1:-}"; ESPERADO="${2:-}"
[ -z "$SLUG" ] && { echo "uso: watchdog.sh <slug> <hhmm>"; exit 2; }
LOG_DIR="$HOME/Library/Logs/claude-utmify"; mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/$(date +%Y-%m-%d).log"

ENTRADA="$("$RAIZ/bin/heartbeat.sh" ler "$SLUG")"
AGORA=$(date +%s)

grita() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') | watchdog          | ❌ $SLUG ($ESPERADO): $1" >> "$LOG"
  "$RAIZ/bin/notificar.sh" "$SLUG" "$1"
}

if [ -z "$ENTRADA" ]; then
  grita "NÃO RODOU — sem heartbeat nenhum para a rotina das $ESPERADO"
  exit 1
fi

HB_EPOCH=$(printf '%s' "$ENTRADA" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("epoch",0))' 2>/dev/null || echo 0)
IDADE=$(( AGORA - HB_EPOCH ))

# a janela válida é de 40 min: 20 de execução + os 20 de folga do watchdog
if [ "$IDADE" -gt 2400 ]; then
  MIN=$(( IDADE / 60 ))
  grita "heartbeat VELHO (${MIN} min) — a execução das $ESPERADO não aconteceu hoje"
  exit 1
fi

CLIQUES=$(printf '%s' "$ENTRADA" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("cliques",0))' 2>/dev/null || echo 0)
echo "$(date '+%Y-%m-%d %H:%M:%S') | watchdog          | ✅ $SLUG ($ESPERADO) ok — $CLIQUES clique(s), heartbeat de ${IDADE}s atrás" >> "$LOG"
exit 0
