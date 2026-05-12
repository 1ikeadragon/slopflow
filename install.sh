#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="${SLOPFLOW_BACKUP_ROOT:-$HOME/.slopflow-backups/$STAMP}"
LEGACY_SKILLS=("security-review")

usage() {
  cat <<'USAGE'
Usage: ./install.sh [--dry-run] [--claude-only|--codex-only]

Installs:
  Claude: ~/.claude/CLAUDE.md and ~/.claude/skills/<skill>/SKILL.md
  Codex:  ~/.codex/AGENTS.md and ~/.codex/skills/<skill>/SKILL.md

Existing prompt files and same-named skills are backed up under ~/.slopflow-backups/<timestamp>/.
Old in-place skill backups named *.bak.* are also archived there so they are not loaded as skills.

Environment overrides:
  CLAUDE_HOME=/custom/.claude
  CODEX_HOME=/custom/.codex
  SLOPFLOW_BACKUP_ROOT=/custom/backup/path
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
    local backup="$BACKUP_ROOT$path"
    run mkdir -p "$(dirname "$backup")"
    run rm -rf "$backup"
    run cp -a "$path" "$backup"
  fi
}

archive_stale_skill_backups() {
  local skills_root="$1"
  local label="$2"
  local stale

  for stale in "$skills_root"/*.bak.*; do
    [ -e "$stale" ] || [ -L "$stale" ] || continue
    local archive="$BACKUP_ROOT/stale-skill-backups/$label/$(basename "$stale")"
    run mkdir -p "$(dirname "$archive")"
    run rm -rf "$archive"
    run mv "$stale" "$archive"
  done
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
  local label="$2"
  local skill
  local legacy

  archive_stale_skill_backups "$skills_root" "$label"

  for legacy in "${LEGACY_SKILLS[@]}"; do
    if [ -e "$skills_root/$legacy" ] || [ -L "$skills_root/$legacy" ]; then
      backup_path "$skills_root/$legacy"
      run rm -rf "$skills_root/$legacy"
    fi
  done

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
  install_skills_to "$CLAUDE_HOME/skills" "claude"
fi

if [ "$INSTALL_CODEX" -eq 1 ]; then
  install_file "$ROOT_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md"
  install_skills_to "$CODEX_HOME/skills" "codex"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run complete."
else
  echo "Installed slopflow."
  echo "Backups, when needed, were written under: $BACKUP_ROOT"
fi
