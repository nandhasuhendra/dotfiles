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

# Link custom commands rule
mkdir -p "$HOME/.gemini/config/rules"
link_file "$DOTFILES_DIR/antigravity/rules/custom-commands.md" "$HOME/.gemini/config/rules/custom-commands.md"

# Link custom commands plugin
mkdir -p "$HOME/.gemini/config/plugins"
link_file "$DOTFILES_DIR/antigravity/plugins/custom-commands" "$HOME/.gemini/config/plugins/custom-commands"

# Ensure custom-commands is registered in plugins.json
PLUGINS_JSON="$HOME/.gemini/config/plugins.json"
if [[ -f "$PLUGINS_JSON" ]]; then
  if ! grep -q '"custom-commands"' "$PLUGINS_JSON"; then
    node -e '
      const fs = require("fs");
      const p = process.argv[1];
      const data = JSON.parse(fs.readFileSync(p, "utf8"));
      if (!data.plugins.includes("custom-commands")) {
        data.plugins.push("custom-commands");
        fs.writeFileSync(p, JSON.stringify(data, null, 2) + "\n");
      }
    ' "$PLUGINS_JSON" 2>/dev/null || true
  fi
fi

# Ensure custom-commands rule is included in GEMINI.md
GEMINI_MD="$HOME/.gemini/config/GEMINI.md"
if [[ -f "$GEMINI_MD" ]]; then
  if ! grep -q 'custom-commands.md' "$GEMINI_MD"; then
    sed -i '/antigravity-rtk-rules.md/a @~/.gemini/config/rules/custom-commands.md' "$GEMINI_MD" 2>/dev/null || \
    printf '\n@~/.gemini/config/rules/custom-commands.md\n' >> "$GEMINI_MD"
  fi
fi
