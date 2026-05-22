#!/usr/bin/env bash
# Restore das configs do Claude Code no Linux/macOS/Git Bash
# Uso: bash scripts/restore.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_HOME="$HOME/.claude"

echo "==> Restaurando configs do Claude Code em $CLAUDE_HOME"

mkdir -p "$CLAUDE_HOME"

# 1) Arquivos raiz
for f in CLAUDE.md settings.json; do
  if [ -f "$REPO_ROOT/$f" ]; then
    cp "$REPO_ROOT/$f" "$CLAUDE_HOME/$f"
    echo "  + $f"
  fi
done

# 2) Diretorios
for d in skills plans; do
  if [ -d "$REPO_ROOT/$d" ]; then
    mkdir -p "$CLAUDE_HOME/$d"
    cp -r "$REPO_ROOT/$d/." "$CLAUDE_HOME/$d/"
    echo "  + $d/"
  fi
done

# 3) Marketplaces + plugins
if ! command -v claude >/dev/null 2>&1; then
  echo ""
  echo "AVISO: comando 'claude' nao encontrado. Instale o Claude Code antes de restaurar plugins."
  echo "Plugins esperados: $REPO_ROOT/plugins/installed_plugins.json"
  exit 0
fi

MARKETS="$REPO_ROOT/plugins/known_marketplaces.json"
PLUGINS="$REPO_ROOT/plugins/installed_plugins.json"

if [ -f "$MARKETS" ] && command -v python3 >/dev/null 2>&1; then
  echo ""
  echo "==> Adicionando marketplaces"
  python3 -c "
import json, subprocess
d = json.load(open('$MARKETS'))
for name, meta in d.items():
    repo = meta.get('source', {}).get('repo')
    if repo:
        print(f'  + {name} ({repo})')
        subprocess.run(['claude', 'plugin', 'marketplace', 'add', repo], check=False)
"
fi

if [ -f "$PLUGINS" ] && command -v python3 >/dev/null 2>&1; then
  echo ""
  echo "==> Instalando plugins"
  python3 -c "
import json, subprocess
d = json.load(open('$PLUGINS'))
for plugin_id in d.get('plugins', {}).keys():
    print(f'  + {plugin_id}')
    subprocess.run(['claude', 'plugin', 'install', plugin_id], check=False)
"
fi

echo ""
echo "==> Pronto."
echo "   Proximos passos:"
echo "   1. claude login              # autenticar"
echo "   2. claude --version          # conferir instalacao"
