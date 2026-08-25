#!/bin/bash
# heartbeat.sh gravar <slug> <cliques> <nada_a_fazer>
# heartbeat.sh ler <slug>
set -uo pipefail
LOG_DIR="$HOME/Library/Logs/claude-utmify"
HB="$LOG_DIR/heartbeat.json"
mkdir -p "$LOG_DIR"
[ -f "$HB" ] || echo '{}' > "$HB"
ACAO="${1:-}"; SLUG="${2:-}"

case "$ACAO" in
  gravar)
    CLIQUES="${3:-0}"; NADA="${4:-false}"
    python3 - "$HB" "$SLUG" "$CLIQUES" "$NADA" <<'PY'
import json,sys,time,datetime
hb,slug,cliques,nada=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
try: d=json.load(open(hb))
except Exception: d={}
d[slug]={"ts":datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
         "epoch":int(time.time()),"cliques":int(cliques or 0),
         "nada_a_fazer":(nada=="true"),"status":"ok"}
json.dump(d,open(hb,"w"),ensure_ascii=False,indent=2)
PY
    ;;
  ler)
    python3 - "$HB" "$SLUG" <<'PY'
import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception: d={}
e=d.get(sys.argv[2])
print(json.dumps(e,ensure_ascii=False) if e else "")
PY
    ;;
  *) echo "uso: heartbeat.sh gravar|ler <slug> [...]"; exit 2 ;;
esac
