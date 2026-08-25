#!/bin/bash
# preflight.sh — checa Chrome e MCP antes de deixar a rotina rodar.
# saída: 0 = tudo certo | 1 = aviso (segue) | 2 = abortar
set -uo pipefail
SLUG="${1:-?}"
CHROME_APP="${CHROME_APP:-Google Chrome}"
CONF="$HOME/.claude-utmify.conf"; [ -f "$CONF" ] && . "$CONF"
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODIGO=0

echo "[preflight] verificando Chrome..."
if ! pgrep -x "$CHROME_APP" >/dev/null 2>&1; then
  echo "[preflight] Chrome NÃO está rodando — abrindo agora."
  open -a "$CHROME_APP" 2>/dev/null
  for i in 1 2 3 4 5 6 7 8 9 10; do
    sleep 2
    pgrep -x "$CHROME_APP" >/dev/null 2>&1 && break
  done
  if pgrep -x "$CHROME_APP" >/dev/null 2>&1; then
    echo "[preflight] Chrome subiu. Avisando o Brandon (pode precisar de login)."
    "$RAIZ/bin/notificar.sh" "$SLUG" "Chrome estava fechado — abri. Confira se está logado na UTMify." aviso
    CODIGO=1
  else
    echo "[preflight] Chrome NÃO subiu. Abortando."
    exit 2
  fi
else
  echo "[preflight] Chrome de pé (pid $(pgrep -x "$CHROME_APP" | head -1))."
fi

echo "[preflight] verificando MCP claude-in-chrome..."
MCP_OUT="$(claude mcp list 2>&1)"
echo "$MCP_OUT" | sed 's/^/[preflight]   /'
if ! echo "$MCP_OUT" | grep -qi 'claude-in-chrome'; then
  echo "[preflight] ❌ MCP claude-in-chrome NÃO registrado para o Claude Code do terminal."
  echo "[preflight]    Sem ele a rotina não clica em nada. Abortando em vez de fingir sucesso."
  "$RAIZ/bin/notificar.sh" "$SLUG" "MCP claude-in-chrome ausente no terminal — rotina abortada" aviso
  exit 2
fi
echo "[preflight] MCP claude-in-chrome presente."
exit $CODIGO
