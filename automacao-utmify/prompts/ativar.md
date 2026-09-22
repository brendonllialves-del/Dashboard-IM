# ROTINA DAS 23:30 — ATIVAR OS MELHORES CRIATIVOS

Única rotina do dia autorizada a **ativar**. Roda no Mac do Brandon com o Chrome
logado na UTMify.

## 1. Selecionar quem entra

Critério do Brandon: **ROI ≥ 3,5** no **painel-fb** (ROI nominal), janela de
**7 dias**. ROI abaixo de 3,5 não entra, por melhor que pareça em outra janela.

## 2. Filtros que bloqueiam ativação — checar um por um

- Nome contém **`REJEITADO`** → ❌ nunca ativa.
- Status **`DISAPPROVED`** no Facebook → ❌ nunca ativa.
- **`CAMUFLAGEM` / `CAMUFLADO` → ✅ PODE ativar.** Não confunda com REJEITADO.
- 🇷🇴 **ROMÊNIA: NÃO ATIVAR NADA HOJE.** Ordem explícita do Brandon em 25/08.
  A Romênia fica 100 % pausada até ele mandar o contrário, no dia, por escrito.
  Se algum criativo 🇷🇴 passar no ROI, **liste no relatório e não clique**.

## 3. Ativar o criativo E a campanha dele

Ativar só o criativo não adianta se a campanha está pausada. Ative os dois.

## 4. Calcular o orçamento da campanha

```
orçamento = CPA médio do criativo (7 d, em US$) × 3 × nº de criativos ativos na campanha
```

Exemplo do Brandon: CPA US$ 20 → 20 × 3 = US$ 60 por criativo.
Campanha com 3 criativos ativos → 60 × 3 = **US$ 180**.

Faixa esperada: **US$ 100 a US$ 300**. Se cair muito fora, confira a conta antes
de publicar e registre a estranheza no relatório.

### Tetos — estourou, usa o teto

| Oferta | Teto |
|---|---|
| 🇷🇴 Romênia | R$ 1.500 *(não se aplica hoje — Romênia não ativa)* |
| 🇧🇬 Bulgária | R$ 2.000 |
| 🇺🇸 Prosperidade | US$ 300 |
| 🇮🇹 Prosperita | US$ 300 |

Câmbio para converter: US$ 1 = R$ 5,19.

## 5. Publicar e CONFERIR

Selecionar linhas → **"Ativar"** → depois **"Alterar orçamento"** → native setter
no `input[name=budget]` → eventos `input` e `change` → **"Publicar"**.

Depois de cada lote: **recarregue e releia** o switch e o valor do orçamento
(coluna 6). O toast mente. Só conte em `cliques_confirmados` o que você releu.

## 6. Relatório

Por campanha ativada: nome completo + CP, criativos ativados um por linha com
ROI de 7 d e CPA, a conta do orçamento mostrada (`CPA × 3 × nº = US$ X`), o
orçamento publicado e o teto aplicado se houve. Bloco separado para o que ficou
de fora e por quê (REJEITADO, DISAPPROVED, Romênia).

Termine com o bloco `<<<UTMIFY-RESULT>>>`.
