#!/bin/bash
# uninstall.sh — remove todos os jobs launchd da automação UTMify.
# Não apaga logs nem a config (~/.claude-utmify.conf).
set -uo pipefail
AGENTS="$HOME/Library/LaunchAgents"; PREFIX="com.brandon.utmify"; DOMAIN="gui/$(id -u)"
n=0
for f in "$AGENTS/$PREFIX."*.plist; do
  [ -e "$f" ] || continue
  lbl="$(basename "$f" .plist)"
  launchctl bootout "$DOMAIN/$lbl" >/dev/null 2>&1
  rm -f "$f"; echo "removido: $lbl"; n=$((n+1))
done
echo "$n job(s) removido(s). Logs e config preservados."
