#!/usr/bin/env bash
# Restore das configs do Claude Code (Linux/macOS/Git Bash)
# Uso: bash scripts/restore.sh [TARGET_BIN]
#
# Restaura:
#   - ~/.claude/             (CLAUDE.md, settings.json, skills/, plans/, plugins/*.json)
#   - <TARGET_BIN>/          (configs do projeto: .claude/, .codex/, .agents/, .mcp.json, CLAUDE.md, ...)
#
# Por padrao TARGET_BIN = $HOME/.local/bin

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_HOME="$HOME/.claude"
TARGET_BIN="${1:-$HOME/.local/bin}"

echo "==> Restaurando configs do Claude Code"
echo "    Global : $CLAUDE_HOME"
echo "    Projeto: $TARGET_BIN"

mkdir -p "$CLAUDE_HOME" "$TARGET_BIN"

# ===== PARTE 1: configs globais (~/.claude/) =====
echo
echo "==> [Global] ~/.claude/"

for f in CLAUDE.md settings.json; do
  if [ -f "$REPO_ROOT/$f" ]; then
    cp "$REPO_ROOT/$f" "$CLAUDE_HOME/$f"
    echo "  + $f"
  fi
done

for d in skills plans; do
  if [ -d "$REPO_ROOT/$d" ]; then
    mkdir -p "$CLAUDE_HOME/$d"
    cp -r "$REPO_ROOT/$d/." "$CLAUDE_HOME/$d/"
    echo "  + $d/"
  fi
done

mkdir -p "$CLAUDE_HOME/plugins"
for p in installed_plugins.json known_marketplaces.json; do
  if [ -f "$REPO_ROOT/plugins/$p" ]; then
    cp "$REPO_ROOT/plugins/$p" "$CLAUDE_HOME/plugins/$p"
    echo "  + plugins/$p"
  fi
done

# ===== PARTE 2: configs do projeto =====
if [ -d "$REPO_ROOT/local-bin" ]; then
  echo
  echo "==> [Projeto] $TARGET_BIN"

  for f in CLAUDE.md AGENTS.md MIGRATION.md .mcp.json skills-lock.json; do
    if [ -f "$REPO_ROOT/local-bin/$f" ]; then
      cp "$REPO_ROOT/local-bin/$f" "$TARGET_BIN/$f"
      echo "  + $f"
    fi
  done

  for d in .claude .codex .agents; do
    if [ -d "$REPO_ROOT/local-bin/$d" ]; then
      mkdir -p "$TARGET_BIN/$d"
      cp -r "$REPO_ROOT/local-bin/$d/." "$TARGET_BIN/$d/"
      echo "  + $d/"
    fi
  done
fi

# ===== PARTE 3: marketplaces e plugins =====
if ! command -v claude >/dev/null 2>&1; then
  echo
  echo "AVISO: comando 'claude' nao encontrado. Instale o Claude Code antes de restaurar plugins."
  echo
  echo "==> Pronto (sem plugins)."
  exit 0
fi

MARKETS="$REPO_ROOT/plugins/known_marketplaces.json"
PLUGINS="$REPO_ROOT/plugins/installed_plugins.json"

if [ -f "$MARKETS" ] && command -v python3 >/dev/null 2>&1; then
  echo
  echo "==> [Plugins] Adicionando marketplaces"
  python3 -c "
import json, subprocess
d = json.load(open('$MARKETS'))
for name, meta in d.items():
    repo = meta.get('source', {}).get('repo')
    if repo:
        print(f'  + {name} ({repo})')
        subprocess.run(['claude', 'plugin', 'marketplace', 'add', repo], check=False, capture_output=True)
"
fi

if [ -f "$PLUGINS" ] && command -v python3 >/dev/null 2>&1; then
  echo
  echo "==> [Plugins] Instalando"
  python3 -c "
import json, subprocess
d = json.load(open('$PLUGINS'))
for plugin_id in d.get('plugins', {}).keys():
    print(f'  + {plugin_id}')
    subprocess.run(['claude', 'plugin', 'install', plugin_id], check=False, capture_output=True)
"
fi

echo
echo "==> Pronto."
echo "   Proximos passos:"
echo "   1. claude login              # autenticar"
echo "   2. claude --version          # conferir instalacao"
