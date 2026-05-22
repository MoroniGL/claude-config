#!/usr/bin/env bash
# Sincroniza alteracoes de ~/.claude para este repo (chame antes de commitar)
# Uso: bash scripts/sync-from-claude.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_HOME="$HOME/.claude"

echo "==> Copiando $CLAUDE_HOME -> $REPO_ROOT"

for f in CLAUDE.md settings.json; do
  if [ -f "$CLAUDE_HOME/$f" ]; then
    cp "$CLAUDE_HOME/$f" "$REPO_ROOT/$f"
    echo "  + $f"
  fi
done

for d in skills plans; do
  if [ -d "$CLAUDE_HOME/$d" ]; then
    rm -rf "$REPO_ROOT/$d"
    mkdir -p "$REPO_ROOT/$d"
    cp -r "$CLAUDE_HOME/$d/." "$REPO_ROOT/$d/"
    echo "  + $d/"
  fi
done

for p in installed_plugins.json known_marketplaces.json; do
  if [ -f "$CLAUDE_HOME/plugins/$p" ]; then
    cp "$CLAUDE_HOME/plugins/$p" "$REPO_ROOT/plugins/$p"
    echo "  + plugins/$p"
  fi
done

echo ""
echo "==> Pronto. Use 'git status' para revisar e commitar."
