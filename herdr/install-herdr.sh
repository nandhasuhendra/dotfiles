#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/herdr"
STAMP="$(date +%Y%m%d-%H%M%S)"

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

case "$(uname -s)" in
  Linux|Darwin) ;;
  *) die "This installer supports Linux and macOS." ;;
esac

if ! command -v herdr >/dev/null 2>&1; then
  command -v curl >/dev/null 2>&1 || die "curl is required to install Herdr."
  log "Installing Herdr"
  curl -fsSL https://herdr.dev/install.sh | sh
fi

mkdir -p "$CONFIG_DIR"
source_file="$DOTFILES_DIR/herdr/config.toml"
destination="$CONFIG_DIR/config.toml"
[[ -f "$source_file" ]] || die "Missing $source_file"

if [[ -L "$destination" && "$(readlink "$destination")" == "$source_file" ]]; then
  log "Herdr config already linked"
else
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
  ln -s "$source_file" "$destination"
  log "Linked $destination"
fi

if command -v herdr >/dev/null 2>&1; then
  if herdr server reload-config >/dev/null 2>&1; then
    log "Reloaded Herdr configuration"
  else
    log "Config ready; restart Herdr to apply it (no running server to reload)"
  fi
else
  log "Herdr was installed but is not on PATH yet. Restart your shell before launching it."
fi
