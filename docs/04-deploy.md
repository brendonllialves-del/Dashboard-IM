# 04 — Deploy + Workflow Diário

## Como fazer mudanças no site

Sempre que você ou eu fizer mudança em qualquer arquivo:

```bash
# Na pasta do projeto
cd ~/Desktop/imdigital-dashboard

# Ver o que mudou
git status

# Adicionar mudanças
git add .

# Commit com mensagem descritiva
git commit -m "adicionei filtros novos no dashboard"

# Subir
git push
```

Em ~30 segundos a Vercel re-deploya automático. Vai testar na URL.

## Domínios e URLs

A Vercel te dá uma URL padrão tipo `imdigital-dashboard-xxx.vercel.app`. Cada rota:

- `/` → Landing/home
- `/teste-ads` → Creative Lab v8
- `/dashboard` → Dashboard unificada
- `/analise-fb` → Análise Facebook

## Permissões da equipe

**Pra equipe usar o site (Caíque, Matheus, Iury):**
- Não precisa de login
- Só compartilha a URL e eles acessam direto
- Edições deles salvam no Sheets compartilhado
- Opcional: configurar autenticação simples depois

**Pra equipe NÃO BAGUNÇAR a planilha-banco:**
- Compartilha o Google Sheets só com você (ou no máximo com 1 backup)
- Eles editam pelo site, não pela planilha
- Você fica como admin

## Backup

Google Sheets já tem versionamento automático. Pra ver histórico:
- Na planilha: `Arquivo > Histórico de versões > Ver histórico`
- Pode reverter qualquer alteração

Se quiser backup extra:
- Manualmente: `Arquivo > Fazer download > Excel`
- Frequência: semanal já basta

## Quando der problema

1. **Site não carrega** → Vercel > Deployments > olha se o último deu erro
2. **Edição não salva** → confere se a URL do Sheets tá certa em Settings > Environment Variables
3. **Página em branco** → abre console do navegador (F12) e me manda o erro

## Workflow do dia-a-dia

```
Manhã (você ou eu):
  1. Roda extensão pra puxar dados de ontem
  2. Cola no chat aqui
  3. Eu te entrego o briefing "o que subir hoje"

Durante o dia (equipe):
  - Sobem criativos, marcam status no site
  - Tudo salvo automaticamente no Sheets

Final do dia:
  - Tudo registrado pra análise
  - Pronto pro briefing de amanhã
```

✅ **Pronto, tá rodando.**
