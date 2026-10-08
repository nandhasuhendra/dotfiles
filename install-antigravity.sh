#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$DOTFILES_DIR/antigravity/agents"
CONFIG_DIR="$HOME/.gemini/config/agents"
STAMP="$(date +%Y%m%d-%H%M%S)"

link_file() {
  local source="$1" destination="$2" backup count
  mkdir -p "$(dirname "$destination")"
  if [[ -L "$destination" && "$(readlink "$destination")" == "$source" ]]; then
    printf 'Already linked: %s\n' "$destination"
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
    printf 'Backed up: %s\n' "$backup"
  fi
  ln -s "$source" "$destination"
  printf 'Linked: %s\n' "$destination"
}

for source in "$AGENTS_DIR"/*/agent.md; do
  [[ -f "$source" ]] || { printf 'No agents found in %s\n' "$AGENTS_DIR" >&2; exit 1; }
  name="$(basename "$(dirname "$source")")"
  link_file "$source" "$CONFIG_DIR/$name/agent.md"
done
