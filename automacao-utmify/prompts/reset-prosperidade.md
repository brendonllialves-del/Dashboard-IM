# RESET DE ORÇAMENTO — PROSPERIDADE → R$ 300

> ⚠️ **Este job vem DESABILITADO na instalação.** Ele roda depois da ativação das
> 23:30 e sobrescreve os orçamentos calculados pela fórmula. Veja a seção 6 do
> REGRAS. Só ligue depois de decidir qual das duas rotinas manda no orçamento
> de Prosperidade.

Resetar o orçamento diário de **todas** as campanhas com `prosperidade` no nome
para **R$ 300** (aceitável até ~R$ 310), na UTMify, pelo navegador.

1. Filtrar por `nameContainsCampaign=prosperidade`, `level=campaign`, `status=any`.
2. Ler com `LER()` e listar as que estão fora de R$ 300–310.
3. Selecionar → "Alterar orçamento" → native setter → `input`/`change` → "Publicar".
4. **Recarregar e reler a coluna 6** para confirmar. Toast não conta.

Termine com o bloco `<<<UTMIFY-RESULT>>>`.
