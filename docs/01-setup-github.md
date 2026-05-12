# 01 — Setup GitHub

Tempo estimado: 5 minutos

## Pré-requisito
- Conta no GitHub (você já tem)
- Git instalado no Mac (já vem instalado)

## Passos

### 1. Criar repositório novo

1. Vai em https://github.com/new
2. **Nome:** `imdigital-dashboard` (ou outro que você preferir)
3. **Visibilidade:** Private (recomendado — só você vê o código)
4. **NÃO marca** "Add a README file" (a gente já tem)
5. Clica em **Create repository**

### 2. Conectar pasta local

Abre o Terminal do Mac e executa, **substituindo SEU_USUARIO**:

```bash
# Vai pra Desktop ou onde você quiser guardar o projeto
cd ~/Desktop

# Cria a pasta
mkdir imdigital-dashboard
cd imdigital-dashboard

# Inicializa Git
git init
git branch -M main

# Conecta com o repositório do GitHub
git remote add origin https://github.com/SEU_USUARIO/imdigital-dashboard.git
```

### 3. Copiar arquivos do pacote

1. Descompacta o ZIP que eu te entreguei
2. Copia TODOS os arquivos de dentro da pasta `imdigital/` pra dentro de `~/Desktop/imdigital-dashboard/`
3. No Terminal:

```bash
git add .
git commit -m "primeiro commit - estrutura base"
git push -u origin main
```

Se pedir login, usa um **Personal Access Token** do GitHub (não a senha):
1. Vai em https://github.com/settings/tokens
2. **Generate new token (classic)**
3. Marca **repo** completo
4. Gera, copia e usa como senha quando o git pedir

### 4. Confirmar

Volta no GitHub e atualiza a página do repositório. Os arquivos vão estar lá.

✅ **Próximo passo:** `docs/02-setup-vercel.md`
