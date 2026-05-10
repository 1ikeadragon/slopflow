#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
STAMP="$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<'USAGE'
Usage: ./install.sh [--dry-run] [--claude-only|--codex-only]

Installs:
  Claude: ~/.claude/CLAUDE.md and ~/.claude/skills/<skill>/SKILL.md
  Codex:  ~/.codex/AGENTS.md and ~/.codex/skills/<skill>/SKILL.md

Existing prompt files and same-named skills are backed up with a .bak.<timestamp> suffix.

Environment overrides:
  CLAUDE_HOME=/custom/.claude
  CODEX_HOME=/custom/.codex
USAGE
}

DRY_RUN=0
INSTALL_CLAUDE=1
INSTALL_CODEX=1

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=1
      ;;
    --claude-only)
      INSTALL_CODEX=0
      ;;
    --codex-only)
      INSTALL_CLAUDE=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] %q' "$1"
    shift
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
  else
    "$@"
  fi
}

backup_path() {
  local path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    run cp -a "$path" "$path.bak.$STAMP"
  fi
}

install_file() {
  local src="$1"
  local dest="$2"
  run mkdir -p "$(dirname "$dest")"
  backup_path "$dest"
  run rm -f "$dest"
  run cp "$src" "$dest"
}

install_skill_dir() {
  local src="$1"
  local skills_root="$2"
  local name
  name="$(basename "$src")"
  local dest="$skills_root/$name"

  run mkdir -p "$skills_root"
  backup_path "$dest"
  run rm -rf "$dest"
  run cp -R "$src" "$dest"
}

install_skills_to() {
  local skills_root="$1"
  local skill

  for skill in "$ROOT_DIR"/skills/*; do
    [ -d "$skill" ] || continue
    [ -f "$skill/SKILL.md" ] || {
      echo "Skipping $skill: missing SKILL.md" >&2
      continue
    }
    install_skill_dir "$skill" "$skills_root"
  done
}

if [ ! -f "$ROOT_DIR/AGENTS.md" ] || [ ! -f "$ROOT_DIR/CLAUDE.md" ] || [ ! -d "$ROOT_DIR/skills" ]; then
  echo "install.sh must be run from a complete slopflow checkout." >&2
  exit 1
fi

if [ "$INSTALL_CLAUDE" -eq 1 ]; then
  install_file "$ROOT_DIR/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
  install_skills_to "$CLAUDE_HOME/skills"
fi

if [ "$INSTALL_CODEX" -eq 1 ]; then
  install_file "$ROOT_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md"
  install_skills_to "$CODEX_HOME/skills"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run complete."
else
  echo "Installed slopflow."
  echo "Backups, when needed, used suffix: .bak.$STAMP"
fi
