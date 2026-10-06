#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
STAMP="$(date +%Y%m%d-%H%M%S)"

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

case "$(uname -s)" in
  Linux|Darwin) ;;
  *) die "This installer supports Linux and macOS." ;;
esac

if ! command -v opencode >/dev/null 2>&1; then
  command -v curl >/dev/null 2>&1 || die "curl is required to install OpenCode."
  log "Installing OpenCode V2"
  curl -fsSL https://opencode.ai/v2/install | bash
fi

mkdir -p "$CONFIG_DIR"

link_config() {
  local name="$1"
  local source_file="$DOTFILES_DIR/opencode/$name"
  local destination="$CONFIG_DIR/$name"
  local backup count

  [[ -e "$source_file" ]] || die "Missing $source_file"
  if [[ -L "$destination" && "$(readlink "$destination")" == "$source_file" ]]; then
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
  ln -s "$source_file" "$destination"
  log "Linked $name"
}

for name in opencode.jsonc cli.json tui.jsonc skills plugins herdr-opencode herdr-tui-session.js; do
  link_config "$name"
done

# package.json is managed locally so npm can update it without editing dotfiles.
if [[ ! -e "$CONFIG_DIR/package.json" ]]; then
  cp "$DOTFILES_DIR/opencode/package.json" "$CONFIG_DIR/package.json"
  log "Copied package.json (install optional dependencies locally if needed)"
fi

log "OpenCode config ready at $CONFIG_DIR"
log "MCP tools need npx and uvx; sign in to providers and OAuth MCP servers separately"
