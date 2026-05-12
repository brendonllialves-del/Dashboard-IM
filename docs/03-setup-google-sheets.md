# 03 — Setup Google Sheets como Banco

Tempo estimado: 10 minutos

## Por que Google Sheets?

- ✅ Grátis e ilimitado pro nosso uso
- ✅ Você já tá logado no Google
- ✅ Equipe pode editar pelo site OU direto na planilha
- ✅ Backup automático (Google guarda histórico de TODA edição)
- ✅ Zero código de backend, zero manutenção

## Passos

### 1. Criar a planilha

1. Vai em https://sheets.google.com
2. Clica no `+` (em branco)
3. Renomeia pra `IM Digital · Banco de Dados`

### 2. Criar as abas (sheets)

Na parte de baixo, onde tem "Página1", clica no `+` pra adicionar mais. Cria essas abas:

- `criativos`
- `campanhas`
- `subidas`
- `historico_dia`
- `config`

### 3. Configurar cabeçalhos

#### Aba `criativos`

Linha 1, da coluna A até L:

```
id | nome | link_drive | plataforma | conta_destino | status | data_adicionado | atualizado_em | observacoes | tag | rodando_em | criado_por
```

#### Aba `campanhas`

```
id | nome_completo | conta | plataforma | tipo_otimizacao | bidcap_costcap_value | estrutura | criativo_principal | cp_id | rt_id | status | criado_em
```

#### Aba `subidas`

```
id | criativo_id | campanha_id | data_subida | quem_subiu | status | observacoes
```

#### Aba `historico_dia`

```
data | vendas | ic | cpic | gasto | faturamento | lucro | roi | cliques | cpc | cpm | ctr | hook | hold_rate
```

#### Aba `config`

Linha 1: `chave | valor`
Linhas seguintes (você preenche):
```
ultima_atualizacao | (vazio)
versao | 1.0
```

### 4. Instalar o Google Apps Script

O Apps Script é o que faz a "API" da planilha — permite que o site leia e escreva nela.

1. Na planilha, vai em **Extensões > Apps Script**
2. Vai abrir um editor de código novo
3. **Apaga** o `function myFunction() { ... }` que tá lá
4. Abre o arquivo `scripts/google-apps-script.js` do pacote
5. Copia TODO o conteúdo
6. Cola no editor do Apps Script
7. Clica no ícone de **disquete** pra salvar
8. Renomeia o projeto pra `IM Digital API`

### 5. Publicar como Web App

1. No Apps Script, clica em **Implantar > Nova implantação**
2. **Tipo:** Aplicativo da Web
3. **Descrição:** API IM Digital v1
4. **Executar como:** Eu (seu email)
5. **Quem pode acessar:** Qualquer pessoa
6. Clica em **Implantar**
7. **Autoriza** quando pedir (vai pedir login Google + Avançado > Confiar)
8. Vai aparecer uma URL tipo:
   ```
   https://script.google.com/macros/s/AKfycby.../exec
   ```
9. **COPIA essa URL** — é o "endereço" do banco

### 6. Configurar a URL no Vercel

1. Volta no Vercel > teu projeto > Settings > Environment Variables
2. Adiciona:
   - **Name:** `SHEETS_API_URL`
   - **Value:** a URL que você copiou no passo anterior
   - **Environment:** marca todas (Production, Preview, Development)
3. **Save**
4. Vai em Deployments > clica nos 3 pontos do último deploy > Redeploy

### 7. Testar

Abre a URL do site Vercel. Vai numa aba do Creative Lab e tenta editar algo. Recarrega a página em outra aba/dispositivo. Se a edição persistiu, **funcionou.**

✅ **Próximo passo:** `docs/04-deploy.md`

## 🔧 Troubleshooting

**Erro "Authorization required"** — O Apps Script precisa ser publicado como "Qualquer pessoa". Refaz o passo 5.

**Site não salva** — Confere se a URL no Vercel tá correta. Faz Redeploy depois de adicionar.

**Erro CORS** — O Apps Script já tá configurado pra resolver isso. Se persistir, me avisa.
