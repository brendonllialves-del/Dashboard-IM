#!/bin/bash
# rodar-rotina.sh — wrapper de execução das rotinas UTMify no Mac.
#
# Uso:  rodar-rotina.sh <slug>
#   slugs: varredura-0600 varredura-0800 varredura-1200 varredura-1500
#          varredura-1700 varredura-1830 varredura-2000 varredura-2130
#          varredura-2230 ativar-2330 reset-prosperidade
#
# Regra de ouro deste script: SÓ grava heartbeat de sucesso se a execução
# devolver o bloco <<<UTMIFY-RESULT>>> comprovando clique confirmado (ou
# comprovando explicitamente que não havia nada a fazer). Sem prova, é FALHA.

set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$HOME/Library/Logs/claude-utmify"
HEARTBEAT="$LOG_DIR/heartbeat.json"
CONF="$HOME/.claude-utmify.conf"

# ---- configuração (sobrescrevível por ~/.claude-utmify.conf) ----------------
CLAUDE_BIN="${CLAUDE_BIN:-$(command -v claude || echo /usr/local/bin/claude)}"
CHROME_APP="${CHROME_APP:-Google Chrome}"
TIMEOUT_SEG="${TIMEOUT_SEG:-1500}"
ALLOWED_TOOLS="${ALLOWED_TOOLS:-mcp__claude-in-chrome__*,WebFetch,Read,Glob,Grep}"
UTMIFY_SKIP_PERMS="${UTMIFY_SKIP_PERMS:-0}"
[ -f "$CONF" ] && . "$CONF"

SLUG="${1:-}"
[ -z "$SLUG" ] && { echo "uso: $0 <slug>"; exit 2; }

mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/$(date +%Y-%m-%d).log"
INICIO_EPOCH=$(date +%s)

log() { printf '%s | %-18s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')" "$SLUG" "$*" | tee -a "$LOG"; }
sep() { printf '%s\n' "--------------------------------------------------------------------------" >> "$LOG"; }

sep
log "INÍCIO da rotina"

# ---- 1. política de orçamento conforme o horário (REGRAS.md §3) ------------
HORA_AGORA=$(date +%H%M | sed 's/^0*//'); HORA_AGORA=${HORA_AGORA:-0}
case "$SLUG" in
  varredura-0600|varredura-0800) POLITICA="TODAS" ;;
  varredura-1700|varredura-1830|varredura-2000) POLITICA="SO_PROSPERIDADE" ;;
  varredura-1200|varredura-1500|varredura-2130|varredura-2230) POLITICA="NENHUMA" ;;
  ativar-2330) POLITICA="ATIVACAO" ;;
  reset-prosperidade) POLITICA="RESET" ;;
  *) log "ERRO: slug desconhecido '$SLUG'"; exit 2 ;;
esac
log "política de orçamento: $POLITICA"

# ---- 2. preflight: Chrome de pé e logado ----------------------------------
"$RAIZ/bin/preflight.sh" "$SLUG" >> "$LOG" 2>&1
PRE=$?
if [ "$PRE" -eq 2 ]; then
  log "ABORTADO no preflight — Chrome indisponível. Nada foi executado."
  "$RAIZ/bin/notificar.sh" "$SLUG" "Chrome indisponível — rotina não executou"
  exit 3
fi
[ "$PRE" -eq 1 ] && log "AVISO do preflight (segue mesmo assim)"

# ---- 3. montar o prompt ---------------------------------------------------
case "$POLITICA" in
  ATIVACAO) BASE="$RAIZ/prompts/ativar.md" ;;
  RESET)    BASE="$RAIZ/prompts/reset-prosperidade.md" ;;
  *)        BASE="$RAIZ/prompts/varredura.md" ;;
esac
[ -f "$BASE" ] || { log "ERRO: prompt não encontrado: $BASE"; exit 2; }

PROMPT_FILE="$(mktemp -t utmify-prompt)"
{
  echo "SLUG_DA_ROTINA: $SLUG"
  echo "HORARIO_BRT: $(date '+%Y-%m-%d %H:%M')"
  echo "POLITICA_DE_ORCAMENTO: $POLITICA"
  echo
  echo "===== REGRAS (fonte única de verdade) ====="
  cat "$RAIZ/REGRAS.md"
  echo
  echo "===== MECÂNICA, FONTES E CONTRATO DE SAÍDA ====="
  cat "$RAIZ/prompts/_comum.md"
  echo
  echo "===== INSTRUÇÃO DA ROTINA ====="
  cat "$BASE"
} > "$PROMPT_FILE"
log "prompt montado ($(wc -c < "$PROMPT_FILE" | tr -d ' ') bytes) a partir de $(basename "$BASE")"

# ---- 4. executar o Claude Code headless, acordado -------------------------
SAIDA="$(mktemp -t utmify-saida)"
PERM_ARGS=(--allowedTools "$ALLOWED_TOOLS")
[ "$UTMIFY_SKIP_PERMS" = "1" ] && PERM_ARGS=(--dangerously-skip-permissions)

log "executando: $CLAUDE_BIN -p (timeout ${TIMEOUT_SEG}s, sob caffeinate -i)"
caffeinate -i -t "$TIMEOUT_SEG" \
  "$CLAUDE_BIN" -p "$(cat "$PROMPT_FILE")" "${PERM_ARGS[@]}" \
  > "$SAIDA" 2>&1
RC=$?
DUR=$(( $(date +%s) - INICIO_EPOCH ))
log "claude terminou rc=$RC em ${DUR}s"

echo "----- SAÍDA BRUTA DO CLAUDE ($SLUG) -----" >> "$LOG"
cat "$SAIDA" >> "$LOG"
echo "----- FIM DA SAÍDA BRUTA -----" >> "$LOG"

# ---- 5. extrair e validar a prova de execução -----------------------------
BLOCO="$(sed -n '/<<<UTMIFY-RESULT>>>/,/<<<FIM>>>/p' "$SAIDA" \
         | sed '1d;$d')"

if [ -z "$BLOCO" ]; then
  log "❌ FALHA: nenhum bloco <<<UTMIFY-RESULT>>> na saída. SEM PROVA = SEM SUCESSO."
  "$RAIZ/bin/notificar.sh" "$SLUG" "Rotina rodou mas não devolveu prova de execução"
  rm -f "$PROMPT_FILE" "$SAIDA"; exit 4
fi

# leitor de campo do JSON, tolerante a ausência de jq
campo() {
  local chave="$1" val=""
  if command -v python3 >/dev/null 2>&1; then
    val=$(printf '%s' "$BLOCO" | python3 -c '
import sys,json
try: d=json.load(sys.stdin)
except Exception: sys.exit(1)
v=d.get(sys.argv[1])
print("" if v is None else (json.dumps(v) if isinstance(v,(list,dict)) else v))' "$chave" 2>/dev/null)
  elif command -v node >/dev/null 2>&1; then
    val=$(printf '%s' "$BLOCO" | node -e '
let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const d=JSON.parse(s);const v=d[process.argv[1]];
console.log(v==null?"":(typeof v==="object"?JSON.stringify(v):v));}catch(e){process.exit(1)}})' "$chave" 2>/dev/null)
  fi
  printf '%s' "$val"
}

EXECUTOU=$(campo executou)
LOGIN_OK=$(campo login_ok)
NADA=$(campo nada_a_fazer)
CLIQUES=$(campo cliques_confirmados)
RESUMO=$(campo resumo)
PAUSADOS=$(campo pausados)
ORCAMENTOS=$(campo orcamentos)
FALHAS=$(campo falhas)

log "prova: executou=$EXECUTOU login_ok=$LOGIN_OK nada_a_fazer=$NADA cliques_confirmados=$CLIQUES"
[ -n "$PAUSADOS" ]   && log "pausados: $PAUSADOS"
[ -n "$ORCAMENTOS" ] && log "orçamentos: $ORCAMENTOS"
[ -n "$FALHAS" ]     && log "falhas relatadas: $FALHAS"
[ -n "$RESUMO" ]     && log "resumo: $RESUMO"

# ---- 6. veredito ----------------------------------------------------------
OK=0
if [ "$LOGIN_OK" = "false" ]; then
  log "❌ FALHA: Chrome não estava logado na UTMify."
elif [ "$EXECUTOU" = "true" ] && [ "${CLIQUES:-0}" -gt 0 ] 2>/dev/null; then
  log "✅ SUCESSO: $CLIQUES clique(s) confirmado(s) na UTMify."; OK=1
elif [ "$NADA" = "true" ]; then
  log "✅ OK: nada a fazer nesta janela (nenhum criativo bateu a régua)."; OK=1
else
  log "❌ FALHA: bloco presente mas sem clique confirmado e sem 'nada_a_fazer'."
fi

if [ "$OK" -eq 1 ]; then
  "$RAIZ/bin/heartbeat.sh" gravar "$SLUG" "${CLIQUES:-0}" "${NADA:-false}"
  log "heartbeat gravado."
else
  "$RAIZ/bin/notificar.sh" "$SLUG" "${RESUMO:-execução sem prova de clique}"
fi

rm -f "$PROMPT_FILE" "$SAIDA"
log "FIM da rotina (rc=$RC, veredito=$([ $OK -eq 1 ] && echo SUCESSO || echo FALHA))"
sep
exit $([ "$OK" -eq 1 ] && echo 0 || echo 1)
