# Camada 3 — caminho sem navegador (investigação)

> **Status: NÃO IMPLEMENTADA.** Não dá para capturar o tráfego da UTMify de
> dentro de um container Linux sem Chrome logado. Este documento é o roteiro
> exato para capturar; `utmify-api.mjs` é o cliente com os buracos marcados
> `PREENCHER`. Rode a captura no Mac e o cliente fica funcional.

Se existir caminho por API, ele **mata o problema na raiz**: sem Chrome aberto,
sem Mac acordado, sem app do Claude rodando. Vale o esforço.

## Protocolo de captura

1. Chrome logado na UTMify, dashboard `669065844d9e4e3220837eec`.
2. DevTools (`⌥⌘I`) → aba **Network** → filtro **Fetch/XHR** → marque
   **Preserve log** → limpe com 🚫.
3. Execute **manualmente, uma de cada vez**, limpando o log entre elas:
   - **pausar uma campanha** (uma só, de preferência de teste)
   - **ativar um anúncio**
   - **alterar o orçamento de uma campanha**
4. Para cada requisição que **não** seja `GET` de leitura, clique nela e capture:

| O que | Onde no DevTools |
|---|---|
| Método + URL completa | aba *Headers* → *General* |
| Payload | aba *Payload* → **view source** (JSON cru) |
| Como a auth viaja | *Headers* → *Request Headers*: procure `Authorization: Bearer …`, `Cookie:`, `x-api-key`, `x-workspace-id` |
| Resposta de sucesso | aba *Response* |

5. Botão direito na requisição → **Copy → Copy as cURL** e cole num arquivo
   local **fora do git**. É o jeito mais fiel de registrar tudo.

## Perguntas que a captura precisa responder

- [ ] A escrita é REST (`PATCH /campaigns/:id`) ou GraphQL (um `POST /graphql` só)?
- [ ] A auth é **cookie de sessão** (então precisa renovar/manter sessão) ou
      **`Authorization: Bearer <JWT>`** (então dá para guardar o token)?
- [ ] Se for JWT: qual o `exp`? Existe refresh token? Onde ele mora
      (`localStorage`, cookie `httpOnly`)?
- [ ] O `adAccount` / `workspace` viaja no header, na URL ou no body?
- [ ] O status vem como boolean (`active: true`) ou enum (`"ACTIVE"`/`"PAUSED"`)?
- [ ] O orçamento vai em **centavos** ou em unidade? Em BRL ou na moeda da conta?
- [ ] A resposta de sucesso confirma o estado novo, ou só devolve `200 {ok:true}`?
      *(Se só devolver `ok`, o cliente precisa reler igual o navegador faz —
      a UTMify já provou que mente.)*

## 🔐 Credenciais — regra inegociável

**Nada de token em pasta versionada.** Duas opções:

```bash
# Keychain do macOS (preferido)
security add-generic-password -a "$USER" -s utmify-token -w '<TOKEN>'
security find-generic-password -a "$USER" -s utmify-token -w   # ler

# ou .env fora de qualquer repositório git
mkdir -p ~/.config/utmify && chmod 700 ~/.config/utmify
printf 'UTMIFY_TOKEN=<TOKEN>\n' > ~/.config/utmify/.env
chmod 600 ~/.config/utmify/.env
```

Este diretório do repositório **não deve** receber token nenhum.

## Se a auth for cookie de sessão

Aí a Camada 3 não elimina o navegador de verdade — só troca a dependência de
"Chrome com Claude clicando" por "Chrome com sessão válida". Ainda assim vale:
`fetch()` direto é ordens de magnitude mais rápido e confiável que clicar, e
não sofre timeout de CDP. Nesse caso o cliente lê o cookie do Chrome e reusa.
