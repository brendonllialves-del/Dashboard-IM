# Pacote painel-fb · Subidas v2 (não publicado)

Trabalho feito no repositório **painel-fb**, guardado aqui para não disparar deploy de preview da Vercel no painel-fb.

- `HANDOFF.html` / `HANDOFF.md` — instruções completas para revisar, aplicar e publicar.
- `painel-fb-subidas-v2.bundle` — branch `claude/subidas-cloakup-vturb` (1 commit sobre `main` 30cd98b; o hash está em `COMMIT.txt`).
- `painel-fb-subidas-v2.patch` — o mesmo commit em `git format-patch` (aplica com `git am`).
- `pendencias-conhecidas.json` — o que depende de revisão humana nos dados reais embutidos.
- `evidencias/` — prints e relatório da validação local (41/41).

```bash
# dentro do clone do painel-fb
git bundle verify /caminho/painel-fb-subidas-v2.bundle
git fetch /caminho/painel-fb-subidas-v2.bundle claude/subidas-cloakup-vturb:claude/subidas-cloakup-vturb
```
