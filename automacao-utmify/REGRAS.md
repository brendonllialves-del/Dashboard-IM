# REGRAS — fonte única de verdade da automação UTMify

> Tudo aqui vem das ordens do Brandon em 25/08/2026 (mensagem de voz).
> Onde esta tabela conflita com prompt antigo de trigger ou com brief escrito
> anterior, **esta tabela vence**. Os prompts em `prompts/` e os triggers da
> nuvem devem apontar para cá, nunca duplicar régua.

---

## 1. Ofertas

| Oferta | Bandeira | Código | Moeda | Fonte de vendas |
|---|---|---|---|---|
| ED COD Romênia | 🇷🇴 | `cod` | RON | painel-fb / LightFunnels |
| ED COD Bulgária | 🇧🇬 | `bul` | EUR | painel-fb / LightFunnels |
| Prosperidade | 🇺🇸 | `pro` | USD | UTMify |
| Prosperita | 🇮🇹 | `pri` | EUR/USD | UTMify |

## 2. Câmbio e taxa de entrega

- US$ 1 = R$ 5,19 · RON 1 = R$ 1,12 · EUR 1 = R$ 5,88
- **Taxa de entrega COD — ATUALIZADA EM 25/08/2026:**
  - 🇷🇴 **Romênia = 35 %**
  - 🇧🇬 **Bulgária = 70 %**
- `ROAS real = ROAS nominal × taxa de entrega`
- Breakeven nominal: 🇷🇴 **2,86** · 🇧🇬 **1,43**
- `CPA em US$ = gastoBRL ÷ vendas ÷ 5,19`

> ⚠️ Valores antigos que NÃO valem mais: 28,8 % (brief escrito de 25/08) e
> 40 %/50 % (triggers criados em 22–23/08). Ambos foram substituídos.

---

## 3. Grade de horários (horário de Brasília)

| Hora BRT | Rotina | Pausa? | Pode subir orçamento? |
|---|---|---|---|
| 06:00 | varredura | ✅ | ✅ todas as ofertas |
| 08:00 | varredura | ✅ | ✅ todas as ofertas |
| 12:00 | varredura | ✅ | ❌ |
| 15:00 | varredura | ✅ | ❌ |
| 17:00 | varredura | ✅ | ⚠️ só 🇺🇸 Prosperidade |
| 18:30 | varredura | ✅ | ⚠️ só 🇺🇸 Prosperidade |
| 20:00 | varredura | ✅ | ⚠️ só 🇺🇸 Prosperidade |
| 21:30 | varredura | ✅ | ❌ |
| 22:30 | varredura | ✅ | ❌ |
| 23:30 | **ativação** | ❌ | ✅ define orçamento pela fórmula |

### Regra do orçamento por horário

- **Antes do meio-dia (06:00 e 08:00):** pode subir em **todas** as ofertas.
- **A partir do meio-dia:** **não sobe orçamento em nenhuma oferta.**
- **Exceção 🇺🇸 Prosperidade, janela 16:00–20:00** (atinge as varreduras de
  17:00, 18:30 e 20:00): pode subir **30 %** — Prosperidade entrega melhor à
  noite. Condição: **teve venda na janela OU o CPA está dentro da régua.**
  Não basta ter venda; se o CPA estourou, não sobe.
- A varredura das **15:00 fica de fora** da exceção (janela começa às 16:00).
- A exceção vale **só para Prosperidade**. 🇮🇹 Prosperita não sobe depois do
  meio-dia. *(Brandon citou só "Prosperidade" — confirmar se Prosperita entra.)*

### Quanto subir

Escalonado pela qualidade da campanha, **nunca acima de 30 %**:

| Campanha | Aumento |
|---|---|
| Muito boa (CPA folgado, ROAS real forte) | **30 %** |
| Boa | **20 %** |
| Na zona, mas positiva | **10 %** |
| Ruim / CPA estourado | **0 % — não sobe** |

Não subir campanha que **não está gastando o orçamento atual** — não faz
efeito. Reportar isso em vez de mexer.

---

## 4. Régua de PAUSA — vale para as 4 ofertas

Aplicada por **criativo** (e por campanha, quando a conta não aceita escrita a
nível de anúncio). Avaliada sobre o gasto de **HOJE**.

| Situação | Ação |
|---|---|
| Gasto ≥ R$ 200 **e** 0 vendas | ⏸️ **PAUSAR** (sem hesitar) |
| Gasto ≥ R$ 180 **e** 0 IC **e** 0 vendas | ⏸️ **PAUSAR** (sem hesitar) |
| Gasto R$ 180–200 **e** 0 vendas (com IC) | ⏸️ **PAUSAR** |
| Campanha com gasto ≥ R$ 400 hoje e 0 vendas | ⏸️ **PAUSAR a campanha** |
| VIS. DE PÁG. < 20 % dos cliques | ⏸️ **PAUSAR já** — página/VSL quebrada |
| Gasto < R$ 180 | 🟢 deixar rodar |

Regras de apoio:

- **De tarde e à noite a entrega piora, não melhora.** Bateu a régua, pausa —
  não esperar melhorar.
- **Venda salva a janela em que ela está** — mas só se o CPA dela couber na
  régua. CPA alto com 1 venda **não** salva.
- **Campanha nova do gestor** (R$ 0 de gasto ontem **e** hoje): não pausar, não
  subir, não mexer. Só reportar.
- **Nunca desfazer** alteração feita pelo Brandon ou pelo gestor Matheus.
  Divergência se **reporta**, não se reverte.
- Não tocar em **BID CAP**, e nunca usar bidcap como explicação de nada.

---

## 5. Ativação — rotina das 23:30

Só esta rotina ativa. Nenhuma varredura ativa nada, nunca.

### Quem entra

- Criativo com **ROI ≥ 3,5** (ROI nominal do **painel-fb**), últimos 7 dias.
- Ativar o criativo **e a campanha dele**.

### Quem NUNCA entra

- Nome contém **`REJEITADO`** → nunca ativa.
- Status **`DISAPPROVED`** no Facebook → nunca ativa.
- **`CAMUFLAGEM` / `CAMUFLADO` PODE** ser ativado — não confundir com rejeitado.
- 🇷🇴 **Romênia fica 100 % pausada.** Não ativar nada de Romênia sem ordem
  explícita do Brandon, dada no dia.

### Fórmula do orçamento da campanha

```
orçamento da campanha = CPA médio do criativo (7 d, em US$) × 3 × nº de criativos ativos
```

Exemplo dado pelo Brandon: CPA US$ 20 → 20 × 3 = US$ 60 por criativo.
Com 3 criativos ativos → 60 × 3 = **US$ 180** de orçamento da campanha.

Faixa esperada na prática: **US$ 100 a US$ 300**.

### Tetos por campanha (estourou, usa o teto)

| Oferta | Teto |
|---|---|
| 🇷🇴 Romênia | **R$ 1.500** |
| 🇧🇬 Bulgária | **R$ 2.000** |
| 🇺🇸 Prosperidade | **US$ 300** |
| 🇮🇹 Prosperita | **US$ 300** |

---

## 6. Conflito conhecido, aguardando decisão

O brief escrito pedia **reset dos orçamentos de Prosperidade para R$ 300 às
23:45**. Isso roda **15 minutos depois** da ativação das 23:30 e **destrói** os
orçamentos que a fórmula acabou de calcular (US$ 100–300 ≈ R$ 519–1.557 → todos
viram R$ 300).

Por isso o job `reset-prosperidade` é instalado **DESABILITADO**. Para ligar:
`./bin/ctl.sh on reset-prosperidade`. Antes de ligar, decidir qual das duas
manda no orçamento de Prosperidade.
