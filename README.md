# IM Digital · Dashboard Operacional

Dashboard unificada da operação Prosperidade FB.
Arquitetura: HTML estático na Vercel + Google Sheets como banco de dados.

## 📁 Estrutura do projeto

```
imdigital/
├── public/                    ← arquivos servidos pelo Vercel
│   ├── index.html            ← landing/home da dashboard
│   ├── teste-ads/            ← Creative Lab v8 (subidas + acervo)
│   ├── dashboard/            ← Dashboard unificada (em construção)
│   └── analise-fb/           ← Análise Facebook (em construção)
├── api/                       ← endpoints serverless (Vercel)
│   ├── sheets-read.js        ← lê dados do Google Sheets
│   └── sheets-write.js       ← escreve dados no Google Sheets
├── scripts/                   ← Google Apps Script
│   └── google-apps-script.js ← cola isso no script.google.com
├── docs/                      ← tutoriais
│   ├── 01-setup-github.md
│   ├── 02-setup-vercel.md
│   ├── 03-setup-google-sheets.md
│   └── 04-deploy.md
├── vercel.json               ← config do Vercel
├── package.json              ← deps mínimas
└── README.md                 ← esse arquivo
```

## 🚀 Setup rápido

1. Lê o tutorial em `docs/01-setup-github.md` → cria repositório
2. Lê o tutorial em `docs/02-setup-vercel.md` → conecta Vercel
3. Lê o tutorial em `docs/03-setup-google-sheets.md` → cria a planilha-banco
4. Lê o tutorial em `docs/04-deploy.md` → faz primeiro deploy

Tempo total: ~30 minutos.

## 🔄 Como atualizar

```bash
# Editar arquivos localmente
# Commit + push
git add .
git commit -m "descrição da mudança"
git push

# Vercel detecta automaticamente e re-deploya em ~30s
```

---
— IM Digital · Operação Prosperidade FB
