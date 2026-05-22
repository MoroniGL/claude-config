# Restore das configs do Claude Code no Windows
# Uso: ./scripts/restore.ps1

$ErrorActionPreference = "Stop"

$RepoRoot   = Split-Path -Parent $PSScriptRoot
$ClaudeHome = Join-Path $HOME ".claude"

Write-Host "==> Restaurando configs do Claude Code em $ClaudeHome" -ForegroundColor Cyan

# Garante que ~/.claude existe
if (-not (Test-Path $ClaudeHome)) {
    New-Item -ItemType Directory -Path $ClaudeHome -Force | Out-Null
    Write-Host "  + criado $ClaudeHome"
}

# 1) Arquivos raiz (CLAUDE.md, settings.json)
foreach ($file in @("CLAUDE.md", "settings.json")) {
    $src = Join-Path $RepoRoot $file
    $dst = Join-Path $ClaudeHome $file
    if (Test-Path $src) {
        Copy-Item $src $dst -Force
        Write-Host "  + $file"
    }
}

# 2) Skills, plans (diretorios inteiros)
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

# 3) Reinstalar marketplaces e plugins
$pluginsJson = Join-Path $RepoRoot "plugins\installed_plugins.json"
$marketsJson = Join-Path $RepoRoot "plugins\known_marketplaces.json"

$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
    Write-Host ""
    Write-Host "AVISO: comando 'claude' nao encontrado. Instale o Claude Code antes de restaurar plugins." -ForegroundColor Yellow
    Write-Host "Plugins esperados estao em $pluginsJson"
    exit 0
}

if (Test-Path $marketsJson) {
    Write-Host ""
    Write-Host "==> Adicionando marketplaces" -ForegroundColor Cyan
    $markets = Get-Content $marketsJson -Raw | ConvertFrom-Json
    foreach ($name in $markets.PSObject.Properties.Name) {
        $repo = $markets.$name.source.repo
        Write-Host "  + $name ($repo)"
        try { claude plugin marketplace add $repo 2>&1 | Out-Null } catch {}
    }
}

if (Test-Path $pluginsJson) {
    Write-Host ""
    Write-Host "==> Instalando plugins" -ForegroundColor Cyan
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
