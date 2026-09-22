## Fontes de dados

**⚠️ Nunca use `WebFetch` nesses endpoints — devolve cache velho.**
Puxe sempre por `fetch()` de dentro do Chrome (aba do domínio `app.utmify.com.br`,
via `javascript_tool`), com cache-buster `&z=` + `Math.random()`.

- 🇷🇴 🇧🇬 varredura compacta (texto puro):
  `https://painel-fb.vercel.app/api/campanhas-live?fonte=varredura&refresh=1&z=<aleatório>`
  - `C|oferta|cid8|status|orcRS|janelas...|nome`
  - `A|cid8|aid8|status|janelas...|nome`
  - janela = `w:gastoBRL,ic,vendas,fatLocal`, `w` ∈ `h`(hoje) `o`(ontem) `a`(anteontem) `3`(3d) `7`(7d)
  - `cod` = 🇷🇴 · `bul` = 🇧🇬
- 🇺🇸 🇮🇹 (JSON):
  `https://painel-fb.vercel.app/api/campanhas-live?fonte=pro&refresh=1&z=<aleatório>`
  - `dias["AAAA-MM-DD"].pro` e `.pri`; por campanha: `n` `st` `sst` `orc` `g`(USD)
    `gbrl` `ic` `v` `fat` `cl` `pv` `im` `ads[]`
- Exporte os dados do `javascript_tool` em fatias de **texto plano ≤ 850 chars**.

### Três armadilhas confirmadas na prática

1. `WebFetch` devolve **cache velho** desses endpoints. Sempre `fetch()` no navegador com `&z=`.
2. O campo **`pv` do painel é SEMPRE 0.** Não serve para conferir visualização de VSL —
   para isso use a coluna **VIS. DE PÁG.** da UTMify (índice 14).
3. **O campo `st` do painel MENTE sobre status.** Em 24/08 mostrou 11 campanhas 🇺🇸 como
   ACTIVE quando na UTMify ao vivo **todas as 19 estavam pausadas**.
   **Status só vale se lido do switch da UTMify ao vivo.**

## UTMify — mecânica de execução

Dashboard `669065844d9e4e3220837eec`. URL com filtro (nunca carregar a lista sem filtro — trava):

```
https://app.utmify.com.br/dashboards/669065844d9e4e3220837eec/campanhas/?level=campaign|ad&dateOption=today|lastSevenDays&nameContainsCampaign=<txt>&nameContainsAd=<txt>&status=any&adAccount=all&products=null
```

Índices das colunas de cada `<tr>` do `tbody`:

| idx | Coluna | | idx | Coluna |
|---|---|---|---|---|
| 0 | checkbox | | 10 | ROI |
| 1 | **switch de status** | | 11 | IMPRESSÕES |
| 2 | nome | | 12 | CLIQUES |
| 3 | VENDAS | | 13 | CPC |
| 4 | CPA | | **14** | **VIS. DE PÁG.** |
| 5 | BID CAP | | 15 | CPM |
| 6 | ORÇAMENTO | | 16 | CTR |
| 7 | GASTOS | | 17 | IC |
| 8 | FATURAMENTO | | 18 | CPI |
| 9 | LUCRO | | | |

### Helpers JS (redefinir após CADA navegação)

```javascript
window.LER=()=>[...document.querySelectorAll('tbody tr')].map((r,i)=>{const t=r.querySelectorAll('td');const n=t[2].innerText.replace(/\s+/g,' ');return i+') '+(t[1].querySelector('input').checked?'ON ':'off ')+n.split('|')[0].replace('[FB]','').trim()+' '+((n.match(/CP\d+/)||[''])[0])+' orc '+t[6].innerText.replace(/\s+/g,' ');}).join('\n');

window.SEL=async(idx)=>{const p=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'checked').set;document.querySelectorAll('tbody tr').forEach(r=>{const c=r.querySelectorAll('td')[0].querySelector('input');if(c&&c.checked){p.call(c,false);c.dispatchEvent(new Event('click',{bubbles:true}));c.dispatchEvent(new Event('change',{bubbles:true}));}});await new Promise(x=>setTimeout(x,1200));for(const i of idx){const c=document.querySelectorAll('tbody tr')[i].querySelectorAll('td')[0].querySelector('input');p.call(c,true);c.dispatchEvent(new Event('click',{bubbles:true}));c.dispatchEvent(new Event('change',{bubbles:true}));await new Promise(x=>setTimeout(x,900));}return 'sel';};

window.GO=async(v)=>{[...document.querySelectorAll('button')].find(x=>x.innerText.trim()===v).click();await new Promise(x=>setTimeout(x,8000));return window.LER();};
```

Orçamento: selecionar linhas → clicar **"Alterar orçamento"** → setar `input[name=budget]`
pelo *native setter* → disparar `input` e `change` → clicar **"Publicar"**.

### Armadilhas da UTMify

- **O aviso de sucesso da UTMify MENTE.** Sempre **recarregar a página e reler o switch**
  antes de dizer que executou. Se não virar em 2 tentativas, PARE e reporte para pausa
  manual no Gerenciador da Meta.
- **Contas com escrita quebrada a nível de anúncio:** `Sofia jones c1` ❌ e
  `Bianca Moore 4` ❌ — o clique em Desativar não muda nada. `Barbara 2` ✅ funciona
  (testado 23/08). Nessas contas quebradas, **agir na campanha, não no anúncio**.
- **`nameContainsCampaign` não aplica a nível de anúncio.** Filtrar por `nameContainsAd`
  e confirmar a conta pelo campo `ca` dentro do `selectedAds` da URL antes de agir.
- Em checkbox/switch, usar dispatch sintético **sem** chamar `.click()` junto (senão alterna duas vezes).
- Evitar `setTimeout` longo atravessando navegação — **o CDP dá timeout em 45 s**. Quebrar em passos curtos.
- Aba em segundo plano > 5 min sofre throttling: renavegue a cada lote.

## Contrato de saída — OBRIGATÓRIO

Termine SEMPRE a resposta com este bloco, exatamente neste formato. O wrapper
`rodar-rotina.sh` lê este bloco para decidir se a execução foi real. **Sem bloco,
a rotina é marcada como FALHA e o Brandon é notificado — mesmo que você tenha
escrito um relatório lindo.**

```
<<<UTMIFY-RESULT>>>
{
  "executou": true,
  "login_ok": true,
  "nada_a_fazer": false,
  "cliques_confirmados": 3,
  "pausados": ["Nome do criativo · CP0001", "..."],
  "orcamentos": ["Campanha X: US$ 120 -> US$ 156 (+30%)"],
  "falhas": ["Nome · motivo pelo qual não pegou"],
  "resumo": "uma linha"
}
<<<FIM>>>
```

Regras do bloco, sem exceção:

- `cliques_confirmados` = quantidade de alterações que você **releu na UTMify depois de
  recarregar a página** e confirmou que mudaram de estado. **Toast de sucesso não conta.**
- Se não havia nada a pausar nem a subir, use `"nada_a_fazer": true` e `cliques_confirmados: 0`.
  Isso é sucesso legítimo.
- Se o Chrome não estava logado na UTMify, use `"login_ok": false`.
- **NUNCA** escreva `executou: true` com clique que você não releu.
  Prefira reportar falha a reportar sucesso falso — essa é a regra mais importante
  desta operação inteira.
