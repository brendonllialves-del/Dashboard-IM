#!/bin/bash
# ctl.sh — liga, desliga, testa e inspeciona as rotinas UTMify.
set -uo pipefail
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS="$HOME/Library/LaunchAgents"
LOG_DIR="$HOME/Library/Logs/claude-utmify"
PREFIX="com.brandon.utmify"
DOMAIN="gui/$(id -u)"
ACAO="${1:-status}"; SLUG="${2:-}"

uso() {
  cat <<'U'
uso: ctl.sh <comando> [slug]

  status              lista todas as rotinas, horários e último heartbeat
  on <slug>           liga a rotina
  off <slug>          desliga a rotina (o .plist continua no disco)
  testar <slug>       roda a rotina AGORA, de verdade, com log ao vivo
  agendar-teste <min> agenda um disparo real daqui a <min> minutos
  log [dia]           mostra o log (dia no formato AAAA-MM-DD, padrão hoje)
  heartbeat           mostra o heartbeat.json
  slugs               lista os slugs válidos
U
}

slugs() { ls "$AGENTS" 2>/dev/null | sed -n "s/^$PREFIX\.\([^.]*\)\.plist$/\1/p" | sort; }

case "$ACAO" in
  slugs) slugs ;;

  status)
    printf '%-22s %-8s %-10s %s\n' ROTINA HORÁRIO CARREGADA "ÚLTIMO HEARTBEAT"
    printf '%s\n' "-------------------------------------------------------------------------"
    for s in $(slugs); do
      f="$AGENTS/$PREFIX.$s.plist"
      h=$(/usr/libexec/PlistBuddy -c "Print :StartCalendarInterval:Hour" "$f" 2>/dev/null || echo "?")
      m=$(/usr/libexec/PlistBuddy -c "Print :StartCalendarInterval:Minute" "$f" 2>/dev/null || echo "?")
      launchctl print "$DOMAIN/$PREFIX.$s" >/dev/null 2>&1 && c="✅ sim" || c="⏸️  não"
      hb=$("$RAIZ/bin/heartbeat.sh" ler "$s" 2>/dev/null)
      [ -z "$hb" ] && hb="— nunca rodou —"
      printf '%-22s %02d:%02d    %-10s %s\n' "$s" "$h" "$m" "$c" "$hb"
    done
    ;;

  on)
    [ -z "$SLUG" ] && { uso; exit 2; }
    launchctl bootout "$DOMAIN/$PREFIX.$SLUG" >/dev/null 2>&1
    launchctl bootstrap "$DOMAIN" "$AGENTS/$PREFIX.$SLUG.plist" \
      && echo "✅ $SLUG ligada" || echo "❌ falhou"
    ;;

  off)
    [ -z "$SLUG" ] && { uso; exit 2; }
    launchctl bootout "$DOMAIN/$PREFIX.$SLUG" >/dev/null 2>&1 \
      && echo "⏸️  $SLUG desligada" || echo "⏸️  $SLUG já estava desligada"
    ;;

  testar)
    [ -z "$SLUG" ] && { uso; exit 2; }
    echo "▶️  rodando $SLUG AGORA (execução real, vai clicar na UTMify)..."
    echo "   log: $LOG_DIR/$(date +%F).log"
    echo
    "$RAIZ/bin/rodar-rotina.sh" "$SLUG"
    rc=$?
    echo
    [ $rc -eq 0 ] && echo "✅ terminou com SUCESSO (veredito do wrapper)" \
                  || echo "❌ terminou com FALHA (rc=$rc) — veja o log"
    exit $rc
    ;;

  agendar-teste)
    MIN="${2:-3}"
    [ -z "${SLUG:-}" ] && SLUG=""
    ALVO_SLUG="${3:-varredura-1200}"
    QUANDO_H=$(date -v +"${MIN}"M +%H 2>/dev/null || date -d "+${MIN} minutes" +%H)
    QUANDO_M=$(date -v +"${MIN}"M +%M 2>/dev/null || date -d "+${MIN} minutes" +%M)
    LBL="$PREFIX.teste-agendado"
    F="$AGENTS/$LBL.plist"
    cat > "$F" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LBL</string>
  <key>ProgramArguments</key><array>
    <string>/bin/bash</string><string>$RAIZ/bin/rodar-rotina.sh</string><string>$ALVO_SLUG</string>
  </array>
  <key>RunAtLoad</key><false/>
  <key>StartCalendarInterval</key><dict>
    <key>Hour</key><integer>$((10#$QUANDO_H))</integer>
    <key>Minute</key><integer>$((10#$QUANDO_M))</integer>
  </dict>
  <key>StandardOutPath</key><string>$LOG_DIR/launchd.out.log</string>
  <key>StandardErrorPath</key><string>$LOG_DIR/launchd.err.log</string>
  <key>EnvironmentVariables</key><dict>
    <key>PATH</key><string>/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    <key>HOME</key><string>$HOME</string>
  </dict>
</dict></plist>
PL
    launchctl bootout "$DOMAIN/$LBL" >/dev/null 2>&1
    launchctl bootstrap "$DOMAIN" "$F"
    echo "⏰ disparo REAL de '$ALVO_SLUG' agendado para $QUANDO_H:$QUANDO_M (daqui a ~$MIN min)."
    echo "   Feche o app do Claude e bloqueie a tela para valer o teste."
    echo "   Acompanhe:  tail -f $LOG_DIR/$(date +%F).log"
    echo "   Depois remova:  launchctl bootout $DOMAIN/$LBL && rm '$F'"
    ;;

  log)
    DIA="${2:-$(date +%F)}"
    F="$LOG_DIR/$DIA.log"
    [ -f "$F" ] && cat "$F" || echo "sem log para $DIA"
    ;;

  heartbeat)
    cat "$LOG_DIR/heartbeat.json" 2>/dev/null || echo "sem heartbeat ainda"
    ;;

  *) uso; exit 2 ;;
esac
