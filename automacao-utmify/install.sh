#!/bin/bash
# install.sh — instalador idempotente da automação UTMify (macOS / launchd).
# Rode NO MAC:  ./install.sh
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS="$HOME/Library/LaunchAgents"
LOG_DIR="$HOME/Library/Logs/claude-utmify"
PREFIX="com.brandon.utmify"
DOMAIN="gui/$(id -u)"

# slug|HH|MM|HH_watchdog|MM_watchdog|habilitado
GRADE="
varredura-0600|06|00|06|20|1
varredura-0800|08|00|08|20|1
varredura-1200|12|00|12|20|1
varredura-1500|15|00|15|20|1
varredura-1700|17|00|17|20|1
varredura-1830|18|30|18|50|1
varredura-2000|20|00|20|20|1
varredura-2130|21|30|21|50|1
varredura-2230|22|30|22|50|1
ativar-2330|23|30|23|50|1
reset-prosperidade|23|45|00|05|0
"

echo "=============================================="
echo "  Instalando automação UTMify"
echo "  raiz : $RAIZ"
echo "  logs : $LOG_DIR"
echo "=============================================="

# ---- checagens de ambiente -------------------------------------------------
[ "$(uname)" = "Darwin" ] || { echo "❌ Isto é para macOS. Abortando."; exit 1; }
command -v launchctl >/dev/null || { echo "❌ launchctl ausente."; exit 1; }

CLAUDE_BIN="$(command -v claude || true)"
if [ -z "$CLAUDE_BIN" ]; then
  echo "❌ 'claude' não está no PATH. Instale o Claude Code CLI e rode de novo."
  exit 1
fi
echo "✅ claude: $CLAUDE_BIN"

echo -n "→ MCP claude-in-chrome: "
if claude mcp list 2>&1 | grep -qi 'claude-in-chrome'; then
  echo "✅ presente"
else
  echo "⚠️  AUSENTE"
  echo "   As rotinas vão ABORTAR no preflight até você registrar esse MCP."
  echo "   Registre com:  claude mcp add claude-in-chrome --scope user -- <comando do MCP>"
  echo "   (a instalação segue — os jobs ficam prontos, só não vão clicar ainda)"
fi

mkdir -p "$AGENTS" "$LOG_DIR"
chmod +x "$RAIZ"/bin/*.sh

# ---- config do usuário -----------------------------------------------------
CONF="$HOME/.claude-utmify.conf"
if [ ! -f "$CONF" ]; then
  cat > "$CONF" <<CONFEOF
# Configuração da automação UTMify. Editável.
CLAUDE_BIN="$CLAUDE_BIN"
CHROME_APP="Google Chrome"
TIMEOUT_SEG=1500
ALLOWED_TOOLS="mcp__claude-in-chrome__*,WebFetch,Read,Glob,Grep"
# Se as rotinas travarem pedindo permissão de ferramenta, ponha 1:
UTMIFY_SKIP_PERMS=0
CONFEOF
  chmod 600 "$CONF"
  echo "✅ config criada: $CONF (chmod 600)"
else
  echo "→ config já existe, preservada: $CONF"
fi

# ---- gerador de plist ------------------------------------------------------
escreve_plist() {
  local label="$1" prog="$2" arg1="$3" arg2="${4:-}" hh="$5" mm="$6"
  local file="$AGENTS/$label.plist"
  {
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
    echo '<plist version="1.0"><dict>'
    echo "  <key>Label</key><string>$label</string>"
    echo '  <key>ProgramArguments</key><array>'
    echo "    <string>/bin/bash</string>"
    echo "    <string>$prog</string>"
    echo "    <string>$arg1</string>"
    [ -n "$arg2" ] && echo "    <string>$arg2</string>"
    echo '  </array>'
    echo '  <key>RunAtLoad</key><false/>'
    echo '  <key>StartCalendarInterval</key><dict>'
    echo "    <key>Hour</key><integer>$((10#$hh))</integer>"
    echo "    <key>Minute</key><integer>$((10#$mm))</integer>"
    echo '  </dict>'
    echo "  <key>StandardOutPath</key><string>$LOG_DIR/launchd.out.log</string>"
    echo "  <key>StandardErrorPath</key><string>$LOG_DIR/launchd.err.log</string>"
    echo '  <key>EnvironmentVariables</key><dict>'
    echo "    <key>PATH</key><string>/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>"
    echo "    <key>HOME</key><string>$HOME</string>"
    echo '  </dict>'
    echo '  <key>ProcessType</key><string>Interactive</string>'
    echo '</dict></plist>'
  } > "$file"
  echo "$file"
}

carrega() {
  local label="$1" file="$2"
  launchctl bootout "$DOMAIN/$label" >/dev/null 2>&1
  if launchctl bootstrap "$DOMAIN" "$file" 2>/dev/null; then
    echo "   carregado: $label"
  else
    launchctl unload "$file" >/dev/null 2>&1
    launchctl load "$file" >/dev/null 2>&1 && echo "   carregado (legado): $label" \
      || echo "   ⚠️  falhou ao carregar: $label"
  fi
}

# ---- instalar cada job -----------------------------------------------------
echo
echo "→ instalando jobs..."
echo "$GRADE" | while IFS='|' read -r slug hh mm whh wmm hab; do
  [ -z "${slug:-}" ] && continue

  lbl="$PREFIX.$slug"
  f=$(escreve_plist "$lbl" "$RAIZ/bin/rodar-rotina.sh" "$slug" "" "$hh" "$mm")
  if [ "$hab" = "1" ]; then
    carrega "$lbl" "$f"
    echo "✅ $slug — $hh:$mm"
  else
    launchctl bootout "$DOMAIN/$lbl" >/dev/null 2>&1
    echo "⏸️  $slug — $hh:$mm (INSTALADO MAS DESABILITADO — ver REGRAS.md §6)"
  fi

  # watchdog (camada 4) — só para jobs habilitados
  if [ "$hab" = "1" ]; then
    wlbl="$PREFIX.wd.$slug"
    wf=$(escreve_plist "$wlbl" "$RAIZ/bin/watchdog.sh" "$slug" "$hh:$mm" "$whh" "$wmm")
    carrega "$wlbl" "$wf"
    echo "   └─ watchdog $whh:$wmm"
  fi
done

echo
echo "=============================================="
echo "  INSTALAÇÃO CONCLUÍDA"
echo "=============================================="
echo
echo "Comandos:"
echo "  ./bin/ctl.sh status                 # ver tudo"
echo "  ./bin/ctl.sh testar varredura-0600  # rodar agora, de verdade"
echo "  ./bin/ctl.sh off varredura-1500     # desligar uma rotina"
echo "  ./bin/ctl.sh on  varredura-1500     # religar"
echo "  tail -f \"$LOG_DIR/\$(date +%F).log\"   # acompanhar ao vivo"
echo
echo "⚠️  FALTA VOCÊ RODAR (precisa da sua senha):"
echo "     sudo pmset -c sleep 0 && sudo pmset -c displaysleep 5"
