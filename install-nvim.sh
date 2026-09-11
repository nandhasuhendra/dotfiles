#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG="$HOME/.config/nvim"
STAMP="$(date +%Y%m%d-%H%M%S)"

log() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
die() { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

[[ -f /etc/os-release ]] || die "Cannot detect operating system."
source /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || die "This installer supports Ubuntu only. Detected: ${ID:-unknown}."
command -v sudo >/dev/null || die "sudo is required."

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64|arm64) ;;
  *) die "Unsupported architecture: $ARCH" ;;
esac

log "Installing system dependencies"
sudo apt-get update
sudo apt-get install -y software-properties-common git curl ca-certificates unzip tar gzip ripgrep fd-find fzf build-essential python3 python3-venv python3-pip ruby ruby-dev nodejs npm golang-go shellcheck

if ! command -v nvim >/dev/null || ! nvim --version | head -1 | grep -q 'NVIM v0\.1[12]\|NVIM v0\.12'; then
  log "Installing current stable Neovim"
  sudo add-apt-repository -y ppa:neovim-ppa/stable
  sudo apt-get update
  sudo apt-get install -y neovim
fi

log "Backing up existing Neovim configuration"
if [[ -e "$NVIM_CONFIG" && ! -L "$NVIM_CONFIG" ]]; then
  BACKUP="$HOME/.config/nvim.backup.$STAMP"
  mv "$NVIM_CONFIG" "$BACKUP"
  echo "Backup: $BACKUP"
elif [[ -L "$NVIM_CONFIG" ]]; then
  rm "$NVIM_CONFIG"
fi

mkdir -p "$HOME/.config"
ln -sfn "$DOTFILES_DIR/nvim" "$NVIM_CONFIG"

# Telescope's native fzf extension needs a compiler; fd is named fdfind on Ubuntu.
if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

log "Bootstrapping plugins and language tooling"
nvim --headless "+Lazy! sync" +qa
nvim --headless "+MasonToolsInstallSync" +qa

log "Final checks"
echo "Neovim: $(nvim --version | head -1)"
echo "Config:  $NVIM_CONFIG -> $DOTFILES_DIR/nvim"
echo "Ruby:    $(ruby --version | cut -d' ' -f2-)"
echo "Node:    $(node --version)"
echo "Python:  $(python3 --version)"
echo "Go:      $(go version | cut -d' ' -f3-)"
echo
nvim --headless "+checkhealth" +qa >/dev/null 2>&1 || true

echo "Neovim v2 installation complete. Start with: nvim"
