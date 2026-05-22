# Sincroniza alteracoes de ~/.claude para este repo (chame antes de commitar)
# Uso: ./scripts/sync-from-claude.ps1

$ErrorActionPreference = "Stop"

$RepoRoot   = Split-Path -Parent $PSScriptRoot
$ClaudeHome = Join-Path $HOME ".claude"

Write-Host "==> Copiando $ClaudeHome -> $RepoRoot" -ForegroundColor Cyan

foreach ($file in @("CLAUDE.md", "settings.json")) {
    $src = Join-Path $ClaudeHome $file
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $RepoRoot $file) -Force
        Write-Host "  + $file"
    }
}

foreach ($dir in @("skills", "plans")) {
    $src = Join-Path $ClaudeHome $dir
    $dst = Join-Path $RepoRoot $dir
    if (Test-Path $src) {
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        New-Item -ItemType Directory -Path $dst -Force | Out-Null
        Copy-Item "$src\*" $dst -Recurse -Force
        Write-Host "  + $dir/"
    }
}

foreach ($p in @("installed_plugins.json", "known_marketplaces.json")) {
    $src = Join-Path $ClaudeHome "plugins\$p"
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $RepoRoot "plugins\$p") -Force
        Write-Host "  + plugins/$p"
    }
}

Write-Host ""
Write-Host "==> Pronto. Use 'git status' para revisar e commitar." -ForegroundColor Green
