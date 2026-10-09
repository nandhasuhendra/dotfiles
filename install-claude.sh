#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

case "$(uname -s)" in
  Linux|Darwin) ;;
  *) die "This installer supports Linux and macOS." ;;
esac

mkdir -p "$CONFIG_DIR"

link_config() {
  local name="$1"
  local source_path="$DOTFILES_DIR/claude/$name"
  local destination="$CONFIG_DIR/$name"
  local backup count

  [[ -e "$source_path" ]] || die "Missing $source_path"
  if [[ -L "$destination" && "$(readlink "$destination")" == "$source_path" ]]; then
    log "$name already linked"
    return
  fi

  if [[ -e "$destination" || -L "$destination" ]]; then
    backup="$destination.backup.$STAMP"
    count=1
    while [[ -e "$backup" || -L "$backup" ]]; do
      backup="$destination.backup.$STAMP.$count"
      ((count += 1))
    done
    mv "$destination" "$backup"
    log "Backed up $destination to $backup"
  fi
  ln -s "$source_path" "$destination"
  log "Linked $name -> $destination"
}

for item in agents commands skills templates; do
  link_config "$item"
done

log "Claude Code configuration ready at $CONFIG_DIR"
if ! command -v claude >/dev/null 2>&1; then
  log "claude is not on PATH yet; install Claude Code before launching it"
fi
