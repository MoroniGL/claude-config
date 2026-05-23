# Sincroniza alteracoes do PC para este repo (chame antes de commitar)
# Uso: ./scripts/sync-from-claude.ps1 [-SourceBin <path>]

param(
    [string]$SourceBin = (Join-Path $HOME ".local\bin")
)

$ErrorActionPreference = "Stop"

$RepoRoot   = Split-Path -Parent $PSScriptRoot
$ClaudeHome = Join-Path $HOME ".claude"

Write-Host "==> Sincronizando para o repo" -ForegroundColor Cyan
Write-Host "    Global : $ClaudeHome"
Write-Host "    Projeto: $SourceBin"

# ===== Globais =====
Write-Host ""
Write-Host "==> [Global] -> raiz" -ForegroundColor Cyan

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

$pluginsDst = Join-Path $RepoRoot "plugins"
if (-not (Test-Path $pluginsDst)) {
    New-Item -ItemType Directory -Path $pluginsDst -Force | Out-Null
}
foreach ($p in @("installed_plugins.json", "known_marketplaces.json")) {
    $src = Join-Path $ClaudeHome "plugins\$p"
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $pluginsDst $p) -Force
        Write-Host "  + plugins/$p"
    }
}

# ===== Projeto =====
if (Test-Path $SourceBin) {
    Write-Host ""
    Write-Host "==> [Projeto] -> local-bin/" -ForegroundColor Cyan

    $localBinDst = Join-Path $RepoRoot "local-bin"
    if (-not (Test-Path $localBinDst)) {
        New-Item -ItemType Directory -Path $localBinDst -Force | Out-Null
    }

    foreach ($file in @("CLAUDE.md", "AGENTS.md", "MIGRATION.md", ".mcp.json", "skills-lock.json")) {
        $src = Join-Path $SourceBin $file
        if (Test-Path $src) {
            Copy-Item $src (Join-Path $localBinDst $file) -Force
            Write-Host "  + $file"
        }
    }

    # .claude: so copia subpastas seguras (ignora worktrees, memory.db, etc.)
    $claudeSrc = Join-Path $SourceBin ".claude"
    $claudeDst = Join-Path $localBinDst ".claude"
    if (Test-Path $claudeSrc) {
        if (Test-Path $claudeDst) { Remove-Item $claudeDst -Recurse -Force }
        New-Item -ItemType Directory -Path $claudeDst -Force | Out-Null
        foreach ($sub in @("agents", "commands", "helpers", "skills", "settings.json", "settings.local.json")) {
            $itemSrc = Join-Path $claudeSrc $sub
            if (Test-Path $itemSrc) {
                Copy-Item $itemSrc $claudeDst -Recurse -Force
            }
        }
        Write-Host "  + .claude/"
    }

    # .codex e .agents copiam inteiros
    foreach ($dir in @(".codex", ".agents")) {
        $src = Join-Path $SourceBin $dir
        $dst = Join-Path $localBinDst $dir
        if (Test-Path $src) {
            if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
            New-Item -ItemType Directory -Path $dst -Force | Out-Null
            Copy-Item "$src\*" $dst -Recurse -Force
            Write-Host "  + $dir/"
        }
    }
}

Write-Host ""
Write-Host "==> Pronto. Use 'git status' para revisar e commitar." -ForegroundColor Green
