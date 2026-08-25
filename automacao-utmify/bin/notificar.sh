#!/bin/bash
# notificar.sh <slug> <mensagem> [aviso]
# Notificação nativa do macOS + arquivo bem visível no Desktop.
set -uo pipefail
SLUG="${1:-?}"; MSG="${2:-falha}"; TIPO="${3:-falha}"
LOG_DIR="$HOME/Library/Logs/claude-utmify"; mkdir -p "$LOG_DIR"
QUANDO="$(date '+%d/%m/%Y %H:%M:%S')"
ALVO="$HOME/Desktop/⚠️ ROTINA-UTMIFY-FALHOU.txt"

TITULO="⚠️ Rotina UTMify falhou"
[ "$TIPO" = "aviso" ] && TITULO="⚠️ Rotina UTMify — atenção"

osascript -e "display notification \"[$SLUG] $MSG\" with title \"$TITULO\" sound name \"Basso\"" 2>/dev/null

{
  echo "=========================================="
  echo "  $QUANDO"
  echo "  ROTINA : $SLUG"
  echo "  TIPO   : $TIPO"
  echo "  MOTIVO : $MSG"
  echo "  LOG    : $LOG_DIR/$(date +%Y-%m-%d).log"
  echo "=========================================="
  echo
} >> "$ALVO"

echo "[notificar] $SLUG :: $MSG" >> "$LOG_DIR/$(date +%Y-%m-%d).log"
