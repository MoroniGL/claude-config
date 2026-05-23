#!/usr/bin/env bash
# Sincroniza alteracoes do PC para este repo (chame antes de commitar)
# Uso: bash scripts/sync-from-claude.sh [SOURCE_BIN]
#
# Copia:
#   - ~/.claude/             -> raiz do repo
#   - <SOURCE_BIN>/          -> local-bin/ do repo
#
# Por padrao SOURCE_BIN = $HOME/.local/bin

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_HOME="$HOME/.claude"
SOURCE_BIN="${1:-$HOME/.local/bin}"

echo "==> Sincronizando para o repo"
echo "    Global : $CLAUDE_HOME"
echo "    Projeto: $SOURCE_BIN"

# ===== Globais =====
echo
echo "==> [Global] -> raiz"

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

mkdir -p "$REPO_ROOT/plugins"
for p in installed_plugins.json known_marketplaces.json; do
  if [ -f "$CLAUDE_HOME/plugins/$p" ]; then
    cp "$CLAUDE_HOME/plugins/$p" "$REPO_ROOT/plugins/$p"
    echo "  + plugins/$p"
  fi
done

# ===== Projeto =====
if [ -d "$SOURCE_BIN" ]; then
  echo
  echo "==> [Projeto] -> local-bin/"

  mkdir -p "$REPO_ROOT/local-bin"

  for f in CLAUDE.md AGENTS.md MIGRATION.md .mcp.json skills-lock.json; do
    if [ -f "$SOURCE_BIN/$f" ]; then
      cp "$SOURCE_BIN/$f" "$REPO_ROOT/local-bin/$f"
      echo "  + $f"
    fi
  done

  for d in .claude .codex .agents; do
    if [ -d "$SOURCE_BIN/$d" ]; then
      rm -rf "$REPO_ROOT/local-bin/$d"
      mkdir -p "$REPO_ROOT/local-bin/$d"
      # .claude tem subpastas grandes para ignorar (worktrees, memory.db)
      if [ "$d" = ".claude" ]; then
        for sub in agents commands helpers skills settings.json settings.local.json; do
          if [ -e "$SOURCE_BIN/$d/$sub" ]; then
            cp -r "$SOURCE_BIN/$d/$sub" "$REPO_ROOT/local-bin/$d/"
          fi
        done
      else
        cp -r "$SOURCE_BIN/$d/." "$REPO_ROOT/local-bin/$d/"
      fi
      echo "  + $d/"
    fi
  done
fi

echo
echo "==> Pronto. Use 'git status' para revisar e commitar."
