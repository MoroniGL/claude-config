# Migração — Claude + Projetos

Guia passo-a-passo pra rodar este setup em outra máquina.

## O que este repo contém

```
.claude/         Config do Claude Code (agentes, comandos, skills, settings)
.agents/skills/  47 skills extras (sparc, swarm, ui-ux-pro-max, v3-*, etc)
.codex/          Config do Codex (config.toml + hooks.json)
CLAUDE.md        Instruções globais pro Claude Code
AGENTS.md        Instruções globais pro Codex
skills-lock.json Lock das versões de skills instaladas

# Projetos referenciados (cada um tem seu próprio repo):
.claude/worktrees/<id>/   git worktrees apontando pra repos externos
src/<projeto>/            código de projetos diversos
```

## Setup em máquina nova

### 1. Clonar este repo
```bash
git clone https://github.com/MoroniGL/claude.git ~/.local/bin
cd ~/.local/bin
```

### 2. Configurar variáveis de ambiente
Criar `.env` na raiz com as chaves (NUNCA commitar):
```bash
# Discord
DISCORD_BOT_TOKEN=...

# (outras conforme necessário)
```

### 3. Instalar Claude Code CLI
```bash
# Conforme docs oficiais Anthropic:
# https://docs.claude.com/claude-code
```

### 4. Clonar projetos via worktree (opcional, se for trabalhar neles)

**Fir3 — Biolink:**
```bash
cd ~/.local/bin
git clone https://github.com/MoroniGL/fir3-project.git fir3-project-source
git -C fir3-project-source worktree add ../.claude/worktrees/frosty-lichterman-fc24d1/tmp-fir3 main
```

Ou só clonar direto:
```bash
git clone https://github.com/MoroniGL/fir3-project.git
cd fir3-project
npm install
```

### 5. Configurar Vercel CLI (pra deploys)
```bash
npm i -g vercel
vercel login
cd <projeto>/
vercel link  # liga ao projeto na Vercel
vercel env pull .env.production --environment=production
```

### 6. Configurar MongoDB Atlas (pro Fir3)
1. Cluster `Fir3BioDB` no Atlas em São Paulo (sa-east-1)
2. Tier M10 (Dedicated)
3. IP allowlist: `0.0.0.0/0`
4. Connection string vai em `MONGODB_URI` no Vercel

## Estrutura dos skills

```
.agents/skills/<nome-da-skill>/
  SKILL.md              # frontmatter + instruções
  references/*.md       # docs auxiliares
  scripts/*.py          # scripts auxiliares (opcional)
  data/*.csv            # data dos skills (ui-ux-pro-max)
```

Skills instalados auto-carregam quando Claude Code inicia, conforme `skills-lock.json`.

## O que NÃO está aqui (sigilo + dependências)

- `.env` — credenciais
- `node_modules/` — dependências (npm install em cada projeto)
- `.next/`, `.vercel/`, `dist/`, `build/` — build outputs
- `.claude/worktrees/` — gitignorado (cada worktree é repo separado)

## Projetos referenciados (repos próprios)

| Projeto | Repo |
|---|---|
| Fir3 Bio-Link | https://github.com/MoroniGL/fir3-project |
| Demais bots | repos próprios em https://github.com/MoroniGL |

Use `git worktree add` se quiser trabalhar dentro deste mono-repo com cada projeto, ou só clonar separado.
