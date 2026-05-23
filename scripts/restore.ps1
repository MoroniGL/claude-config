# Restore das configs do Claude Code no Windows
# Uso: ./scripts/restore.ps1 [-TargetBin <path>]
#
# Restaura:
#   - ~/.claude/             (CLAUDE.md, settings.json, skills/, plans/, plugins/*.json)
#   - <TargetBin>/           (configs do projeto: .claude/, .codex/, .agents/, .mcp.json, CLAUDE.md, AGENTS.md, ...)
#
# Por padrao TargetBin = $HOME\.local\bin (ajuste com -TargetBin)

param(
    [string]$TargetBin = (Join-Path $HOME ".local\bin")
)

$ErrorActionPreference = "Stop"

$RepoRoot   = Split-Path -Parent $PSScriptRoot
$ClaudeHome = Join-Path $HOME ".claude"

Write-Host "==> Restaurando configs do Claude Code" -ForegroundColor Cyan
Write-Host "    Global : $ClaudeHome"
Write-Host "    Projeto: $TargetBin"

# Garante diretorios
foreach ($d in @($ClaudeHome, $TargetBin)) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
        Write-Host "  + criado $d"
    }
}

# ===== PARTE 1: configs globais (~/.claude/) =====
Write-Host ""
Write-Host "==> [Global] ~/.claude/" -ForegroundColor Cyan

foreach ($file in @("CLAUDE.md", "settings.json")) {
    $src = Join-Path $RepoRoot $file
    $dst = Join-Path $ClaudeHome $file
    if (Test-Path $src) {
        Copy-Item $src $dst -Force
        Write-Host "  + $file"
    }
}

foreach ($dir in @("skills", "plans")) {
    $src = Join-Path $RepoRoot $dir
    $dst = Join-Path $ClaudeHome $dir
    if (Test-Path $src) {
        if (-not (Test-Path $dst)) {
            New-Item -ItemType Directory -Path $dst -Force | Out-Null
        }
        Copy-Item "$src\*" $dst -Recurse -Force
        Write-Host "  + $dir/"
    }
}

# Plugins manifestos (instalacao real vem depois)
$pluginsTarget = Join-Path $ClaudeHome "plugins"
if (-not (Test-Path $pluginsTarget)) {
    New-Item -ItemType Directory -Path $pluginsTarget -Force | Out-Null
}
foreach ($p in @("installed_plugins.json", "known_marketplaces.json")) {
    $src = Join-Path $RepoRoot "plugins\$p"
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $pluginsTarget $p) -Force
        Write-Host "  + plugins/$p"
    }
}

# ===== PARTE 2: configs do projeto (~/.local/bin/) =====
$localBinSrc = Join-Path $RepoRoot "local-bin"
if (Test-Path $localBinSrc) {
    Write-Host ""
    Write-Host "==> [Projeto] $TargetBin" -ForegroundColor Cyan

    # Arquivos raiz
    foreach ($file in @("CLAUDE.md", "AGENTS.md", "MIGRATION.md", ".mcp.json", "skills-lock.json")) {
        $src = Join-Path $localBinSrc $file
        $dst = Join-Path $TargetBin $file
        if (Test-Path $src) {
            Copy-Item $src $dst -Force
            Write-Host "  + $file"
        }
    }

    # Diretorios (.claude, .codex, .agents)
    foreach ($dir in @(".claude", ".codex", ".agents")) {
        $src = Join-Path $localBinSrc $dir
        $dst = Join-Path $TargetBin $dir
        if (Test-Path $src) {
            if (-not (Test-Path $dst)) {
                New-Item -ItemType Directory -Path $dst -Force | Out-Null
            }
            Copy-Item "$src\*" $dst -Recurse -Force
            Write-Host "  + $dir/"
        }
    }
}

# ===== PARTE 3: marketplaces e plugins =====
$pluginsJson = Join-Path $RepoRoot "plugins\installed_plugins.json"
$marketsJson = Join-Path $RepoRoot "plugins\known_marketplaces.json"

$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
    Write-Host ""
    Write-Host "AVISO: comando 'claude' nao encontrado. Instale o Claude Code antes de restaurar plugins." -ForegroundColor Yellow
    Write-Host "Plugins esperados estao em $pluginsJson"
    Write-Host ""
    Write-Host "==> Pronto (sem plugins)." -ForegroundColor Green
    exit 0
}

if (Test-Path $marketsJson) {
    Write-Host ""
    Write-Host "==> [Plugins] Adicionando marketplaces" -ForegroundColor Cyan
    $markets = Get-Content $marketsJson -Raw | ConvertFrom-Json
    foreach ($name in $markets.PSObject.Properties.Name) {
        $repo = $markets.$name.source.repo
        Write-Host "  + $name ($repo)"
        try { claude plugin marketplace add $repo 2>&1 | Out-Null } catch {}
    }
}

if (Test-Path $pluginsJson) {
    Write-Host ""
    Write-Host "==> [Plugins] Instalando" -ForegroundColor Cyan
    $plugins = (Get-Content $pluginsJson -Raw | ConvertFrom-Json).plugins
    foreach ($pluginId in $plugins.PSObject.Properties.Name) {
        Write-Host "  + $pluginId"
        try { claude plugin install $pluginId 2>&1 | Out-Null } catch {}
    }
}

Write-Host ""
Write-Host "==> Pronto." -ForegroundColor Green
Write-Host "   Proximos passos:"
Write-Host "   1. claude login              # autenticar"
Write-Host "   2. claude --version          # conferir instalacao"
