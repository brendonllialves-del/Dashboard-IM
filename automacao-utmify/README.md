# Automação UTMify — agendamento que executa de verdade

Resolve o problema de as skills de tráfego pago rodarem por agendamento e
**não clicarem em nada**.

## Por que quebrou

A tarefa agendada roda **numa sessão nova na nuvem**. Essa sessão não tem o
Chrome do Brandon, logo não tem `mcp__claude-in-chrome__*`, logo não clica.
Ela lê os dados por HTTP e monta o relatório — por isso *parecia* que rodou.
Falhou assim em 22, 23 e 24/08.

E o prompt do trigger `trig_01GrcUso5Ab31VPkdSJFft1u` **mandava fazer exatamente
isso**: a seção 6 dele dizia "se não conseguir executar, mande o relatório
mesmo assim". A rotina cumpriu o que estava escrito. Não foi bug de
infraestrutura — foi o prompt aceitando a falha em silêncio.

## O desenho

| Camada | O que é | Estado |
|---|---|---|
| **1** | `launchd` no Mac roda `claude -p` headless com o MCP do Chrome carregado | ✅ pronto, falta instalar |
| **2** | Triggers da nuvem reescritos para não mentirem quando não conseguem executar | ✅ aplicado |
| **3** | Falar com a API da UTMify direto, sem navegador | ⚠️ roteiro pronto, captura pendente |
| **4** | Watchdog 20 min depois de cada rotina, avisa se não rodou | ✅ pronto |

## Instalar (no Mac)

```bash
cd ~/caminho/para/Dashboard-IM/automacao-utmify
./install.sh
sudo pmset -c sleep 0 && sudo pmset -c displaysleep 5   # precisa da sua senha
```

## Usar

```bash
./bin/ctl.sh status                    # tudo: horário, se está carregada, último heartbeat
./bin/ctl.sh testar varredura-0600     # roda AGORA, de verdade
./bin/ctl.sh agendar-teste 3 varredura-1200   # dispara daqui a 3 min (teste real)
./bin/ctl.sh off varredura-1500        # desliga uma rotina
./bin/ctl.sh on  varredura-1500        # religa
./bin/ctl.sh log                       # log de hoje
./bin/ctl.sh heartbeat                 # heartbeat.json
tail -f ~/Library/Logs/claude-utmify/$(date +%F).log
```

## Grade instalada

| Hora | Rotina | Pausa | Sobe orçamento |
|---|---|---|---|
| 06:00 | varredura | ✅ | ✅ todas |
| 08:00 | varredura | ✅ | ✅ todas |
| 12:00 | varredura | ✅ | ❌ |
| 15:00 | varredura | ✅ | ❌ |
| 17:00 | varredura | ✅ | ⚠️ só Prosperidade |
| 18:30 | varredura | ✅ | ⚠️ só Prosperidade |
| 20:00 | varredura | ✅ | ⚠️ só Prosperidade |
| 21:30 | varredura | ✅ | ❌ |
| 22:30 | varredura | ✅ | ❌ |
| 23:30 | **ativação** | ❌ | ✅ pela fórmula |
| 23:45 | reset Prosperidade | — | ⏸️ **desabilitado**, ver REGRAS §6 |

Cada rotina tem um watchdog 20 min depois.

## Como o "nunca reportar sucesso sem clicar" é garantido

`bin/rodar-rotina.sh` não confia no texto da execução. Ele exige um bloco
`<<<UTMIFY-RESULT>>>` com JSON no fim da saída e só grava heartbeat de sucesso se:

- `executou: true` **e** `cliques_confirmados > 0` — e o prompt define clique
  confirmado como *"recarreguei a página e reli o switch"*, nunca o toast; **ou**
- `nada_a_fazer: true` — nenhum criativo bateu a régua, sucesso legítimo.

Qualquer outra coisa — bloco ausente, `login_ok: false`, JSON quebrado, timeout,
Chrome fechado — é **FALHA**: sem heartbeat, notificação na hora e linha no
arquivo do Desktop. O watchdog fecha o cerco 20 min depois.

## Arquivos

```
REGRAS.md                 fonte única de verdade (réguas, horários, câmbio, tetos)
install.sh / uninstall.sh instalador idempotente
bin/rodar-rotina.sh       wrapper: caffeinate + claude -p + validação da prova
bin/preflight.sh          Chrome de pé? MCP registrado? senão aborta
bin/heartbeat.sh          grava/lê heartbeat.json
bin/watchdog.sh           camada 4
bin/notificar.sh          osascript + ~/Desktop/⚠️ ROTINA-UTMIFY-FALHOU.txt
bin/ctl.sh                on/off/testar/status/log
prompts/                  o que cada rotina executa
camada3-api/              roteiro de captura + cliente sem navegador (esqueleto)
```

Logs: `~/Library/Logs/claude-utmify/AAAA-MM-DD.log` · heartbeat:
`~/Library/Logs/claude-utmify/heartbeat.json` · config: `~/.claude-utmify.conf` (chmod 600).

## Pendências que dependem de você

1. `sudo pmset -c sleep 0 && sudo pmset -c displaysleep 5`
2. Confirmar que o MCP `claude-in-chrome` está registrado **no Claude Code do
   terminal** (`claude mcp list`) — não basta estar no app.
3. Confirmar qual **perfil do Chrome** está logado na UTMify, se houver mais de um.
4. Chrome nos **Itens de Início de Sessão**
   (Ajustes → Geral → Itens de Início de Sessão → +).
5. Decidir o conflito 23:30 × 23:45 (REGRAS §6).
6. Rodar a captura da Camada 3 (`camada3-api/CAPTURA.md`).
