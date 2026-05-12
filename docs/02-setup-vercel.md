# 02 — Setup Vercel

Tempo estimado: 3 minutos

## Pré-requisito
- Conta Vercel (você já tem)
- Repositório GitHub criado (passo 01 concluído)

## Passos

### 1. Importar projeto

1. Vai em https://vercel.com/new
2. Clica em **Import Git Repository**
3. Se for primeira vez, autoriza Vercel a acessar tua conta GitHub
4. Encontra `imdigital-dashboard` na lista e clica em **Import**

### 2. Configurar projeto

Na tela "Configure Project":

- **Framework Preset:** Other
- **Root Directory:** `./` (deixa como está)
- **Build and Output Settings:**
  - Build Command: deixa **vazio**
  - Output Directory: `public`
  - Install Command: deixa **vazio**

NÃO mexe em **Environment Variables** ainda — vamos adicionar depois.

### 3. Deploy

Clica em **Deploy**.

Vercel vai pegar os arquivos, fazer o build (que é rápido porque é só HTML), e em ~30 segundos te dá uma URL tipo:

```
https://imdigital-dashboard-abc123.vercel.app
```

### 4. Testar

Acessa a URL. Vai abrir uma página inicial dizendo "IM Digital Dashboard — em construção". É essa.

### 5. Domínio customizado (opcional, pode pular agora)

Se quiser usar um domínio próprio depois:

1. Settings > Domains
2. Adiciona o domínio (ex: `dashboard.suamarca.com`)
3. Vercel te dá o registro DNS pra apontar
4. Pronto

✅ **Próximo passo:** `docs/03-setup-google-sheets.md`

## ⚠️ Importante

A partir de agora, **todo `git push`** que você fizer pro repositório vai automaticamente disparar um deploy novo no Vercel. Não precisa fazer nada manual.
