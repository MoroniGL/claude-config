# claude-config

Backup completo das configs, skills, hooks, agents e plugins do Claude Code para sincronizar entre PCs.

## O que tem aqui

```
claude-config/
├── CLAUDE.md                       # Instrucoes globais (~/.claude/CLAUDE.md)
├── settings.json                   # Permissoes, plugins ativos, voz, idioma
├── skills/                         # Skills locais globais (4 skills)
│   ├── create-carousel/
│   ├── graphify/
│   ├── remotion-best-practices/
│   └── website-builder-setup/
├── plans/                          # Planos salvos pelo /plan
├── plugins/
│   ├── installed_plugins.json      # Plugins instalados (versoes + commits)
│   └── known_marketplaces.json     # Marketplaces configurados
├── local-bin/                      # Configs do projeto (~/.local/bin/)
│   ├── CLAUDE.md                   # Instrucoes do projeto (RuFlo V3)
│   ├── AGENTS.md                   # Definicoes de agents (~6.8KB)
│   ├── MIGRATION.md                # Guia de migracao
│   ├── .mcp.json                   # MCP servers (claude-flow)
│   ├── skills-lock.json            # Lockfile das skills
│   ├── .claude/                    # ~/.local/bin/.claude/
│   │   ├── settings.json           # Hooks, statusLine, claude-flow config
│   │   ├── settings.local.json     # Permissoes locais
│   │   ├── agents/                 # 60+ agents customizados
│   │   ├── commands/               # Slash commands customizados
│   │   ├── helpers/                # hook-handler.cjs, statusline.cjs, etc.
│   │   └── skills/                 # ~22 skills do projeto
│   ├── .codex/                     # config.toml + hooks.json
│   └── .agents/                    # Skills do .agents (browser, github, sparc, swarm...)
└── scripts/
    ├── restore.ps1                 # Restore no Windows (PowerShell)
    ├── restore.sh                  # Restore no Linux/macOS/Git Bash
    ├── sync-from-claude.ps1        # Atualiza repo a partir do PC (Windows)
    └── sync-from-claude.sh         # Atualiza repo a partir do PC (Unix)
```

## O que NAO entra (por seguranca/tamanho)

**Secrets:**
- `.credentials.json` — token da Anthropic (faz login com `claude login` no outro PC)
- `.env`, `.env.*`, `*credentials*`, `*secret*`, `*.key`, `*.pem`

**Estado local:**
- `projects/`, `sessions/`, `history.jsonl`, `shell-snapshots/`
- `cache/`, `paste-cache/`, `file-history/`, `telemetry/`
- `backups/`, `chrome/`, `downloads/`, `ide/`, `session-env/`

**Volumoso (reinstalado pelos scripts):**
- `plugins/cache/` e `plugins/marketplaces/` (~1.1GB - restaurado via `claude plugin install`)
- `local-bin/.claude/worktrees/` (~1.5GB de worktrees temporarios)
- `local-bin/.claude/memory.db` (banco local)

**Projetos pessoais** (NAO sao parte do Claude Code):
- `local-bin/melo-bot/`, `local-bin/melo-site/`, `local-bin/coffee-ad/`, etc.

## Como restaurar em outro PC

### 1. Pre-requisitos

- Claude Code instalado: https://claude.com/download
- Git instalado
- Node.js (para reinstalar plugins via `claude plugin`)
- Python 3 (para o script .sh restaurar plugins; opcional)

### 2. Clonar e rodar restore

**Windows (PowerShell):**
```powershell
cd $HOME
git clone https://github.com/MoroniGL/claude-config.git
cd claude-config
./scripts/restore.ps1
```

Opcional - especificar pasta diferente para o projeto:
```powershell
./scripts/restore.ps1 -TargetBin "D:\projetos\meu-bin"
```

**Linux / macOS / Git Bash:**
```bash
cd ~
git clone https://github.com/MoroniGL/claude-config.git
cd claude-config
bash scripts/restore.sh
# ou com pasta customizada:
bash scripts/restore.sh ~/dev/my-bin
```

O script:
1. Copia configs globais para `~/.claude/` (CLAUDE.md, settings.json, skills/, plans/, plugins/*.json)
2. Copia configs do projeto para `~/.local/bin/` (ou path customizado)
3. Reinstala marketplaces e plugins via `claude plugin install`
4. NAO sobrescreve credenciais (`claude login` faz isso)

### 3. Login

```bash
claude login
```

## Como atualizar o backup (no PC original)

Quando voce mudar configs, skills, hooks ou instalar/remover plugins:

**Windows:**
```powershell
cd ~\claude-config
./scripts/sync-from-claude.ps1
git add .
git commit -m "atualiza configs"
git push
```

**Linux/macOS/Git Bash:**
```bash
cd ~/claude-config
bash scripts/sync-from-claude.sh
git add .
git commit -m "atualiza configs"
git push
```

## Plugins instalados

Em `plugins/installed_plugins.json`:

- `ui-ux-pro-max@nextlevelbuilder-ui-ux-pro-max-skill` (v2.5.0)
- `superpowers@claude-plugins-official` (v5.0.7)
- `vercel@claude-plugins-official` (v0.40.0)
- `marketing-skills@marketingskills`

Marketplaces em `plugins/known_marketplaces.json`:

- `anthropics/claude-plugins-official`
- `nextlevelbuilder/ui-ux-pro-max-skill`
- `coreyhaines31/marketingskills`

## Hooks do projeto

Configurados em `local-bin/.claude/settings.json` (RuFlo V3):

- **PreToolUse / PostToolUse** — Bash, Write, Edit, MultiEdit
- **UserPromptSubmit** — routing inteligente via hook-handler.cjs
- **SessionStart / SessionEnd** — restore + import memory
- **PreCompact** — manual e auto
- **SubagentStart / SubagentStop** — coordenacao
- **Stop / Notification** — sync de memoria

Helpers em `local-bin/.claude/helpers/`:
- `hook-handler.cjs`
- `auto-memory-hook.mjs`
- `statusline.cjs`

## Tamanho do backup

- Total: ~6MB (sem cache de plugins e sem worktrees)
- Plugins reinstalados no destino: ~1.1GB
