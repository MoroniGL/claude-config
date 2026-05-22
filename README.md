# claude-config

Backup das minhas configs, skills e lista de plugins do Claude Code para sincronizar entre PCs.

## O que tem aqui

```
claude-config/
├── CLAUDE.md                       # Instrucoes globais (~/.claude/CLAUDE.md)
├── settings.json                   # Permissoes, plugins ativos, voz, idioma
├── skills/                         # Skills locais (4 skills)
│   ├── create-carousel/
│   ├── graphify/
│   ├── remotion-best-practices/
│   └── website-builder-setup/
├── plans/                          # Planos salvos pelo /plan
├── plugins/
│   ├── installed_plugins.json      # Plugins instalados (versoes + commits)
│   └── known_marketplaces.json     # Marketplaces configurados
└── scripts/
    ├── restore.ps1                 # Restore no Windows (PowerShell)
    └── restore.sh                  # Restore no Linux/macOS/Git Bash
```

## O que NAO entra (por seguranca)

- `.credentials.json` — token da Anthropic (faz login com `claude login` no outro PC)
- `projects/`, `sessions/`, `history.jsonl` — transcripts e estado privado
- `plugins/cache/`, `plugins/marketplaces/` — sao baixados de novo no restore
- `backups/` — backups de `.claude.json` com estado de projetos

## Como restaurar em outro PC

### 1. Pre-requisitos no novo PC

- Claude Code instalado (`https://claude.com/download`)
- Git instalado
- Node.js (para reinstalar plugins via `claude plugin`)

### 2. Clonar e rodar restore

**Windows (PowerShell):**
```powershell
cd $HOME
git clone https://github.com/MoroniGL/claude-config.git
cd claude-config
./scripts/restore.ps1
```

**Linux / macOS / Git Bash:**
```bash
cd ~
git clone https://github.com/MoroniGL/claude-config.git
cd claude-config
bash scripts/restore.sh
```

O script:
1. Copia `CLAUDE.md`, `settings.json`, `skills/`, `plans/` para `~/.claude/`
2. Reinstala marketplaces e plugins listados em `plugins/*.json`
3. NAO sobrescreve credenciais (`claude login` faz isso)

### 3. Login

```bash
claude login
```

## Como atualizar o backup (no PC original)

Quando voce mudar uma config/skill e quiser sincronizar:

```bash
cd ~/claude-config
bash scripts/sync-from-claude.sh   # ou ./scripts/sync-from-claude.ps1
git add .
git commit -m "atualiza configs"
git push
```

## Plugins instalados (referencia)

Listados em `plugins/installed_plugins.json`:

- `ui-ux-pro-max@nextlevelbuilder-ui-ux-pro-max-skill`
- `superpowers@claude-plugins-official`
- `vercel@claude-plugins-official`
- `marketing-skills@marketingskills`

Marketplaces em `plugins/known_marketplaces.json`:

- `anthropics/claude-plugins-official`
- `nextlevelbuilder/ui-ux-pro-max-skill`
- `coreyhaines31/marketingskills`
