#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG="$HOME/.config/nvim"
STAMP="$(date +%Y%m%d-%H%M%S)"

log() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
die() { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

OS="$(uname -s)"

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    die "Homebrew installation completed, but brew was not found. Restart your shell and run this installer again."
  fi
}

install_macos_dependencies() {
  install_homebrew

  if ! xcode-select -p >/dev/null 2>&1; then
    die "Xcode Command Line Tools are required. Run 'xcode-select --install', finish the installation, then run this script again."
  fi

  log "Installing macOS dependencies"
  brew update
  brew install git curl ripgrep fd fzf python node go ruby shellcheck

  # Homebrew's Ruby is intentionally used instead of macOS's system Ruby.
  export PATH="$(brew --prefix ruby)/bin:$PATH"
}

install_linux_dependencies() {
  [[ -f /etc/os-release ]] || die "Cannot detect operating system."
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || die "This installer supports Ubuntu on Linux. Detected: ${ID:-unknown}."
  require_command sudo

  local arch
  arch="$(dpkg --print-architecture)"
  case "$arch" in
    amd64|arm64) ;;
    *) die "Unsupported architecture: $arch" ;;
  esac

  log "Installing Ubuntu system dependencies"
  sudo apt-get update
  sudo apt-get install -y software-properties-common git curl ca-certificates unzip tar gzip ripgrep fd-find fzf build-essential python3 python3-venv python3-pip ruby ruby-dev nodejs npm golang-go shellcheck
}

install_latest_neovim_linux() {
  local arch="$1"
  local nvim_arch
  local tmp_dir="/tmp/nvim-install-$$"
  local archive
  local install_dir

  case "$arch" in
    amd64) nvim_arch="x86_64" ;;
    arm64) nvim_arch="arm64" ;;
    *) die "Unsupported architecture: $arch" ;;
  esac

  archive="nvim-linux-${nvim_arch}.tar.gz"
  install_dir="/opt/nvim-linux-${nvim_arch}"

  log "Installing latest stable Neovim"
  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"

  curl -fL --retry 3 --retry-delay 2 \
    "https://github.com/neovim/neovim/releases/latest/download/${archive}" \
    -o "$tmp_dir/$archive"

  sudo rm -rf "$install_dir"
  sudo tar -C /opt -xzf "$tmp_dir/$archive"
  sudo ln -sfn "$install_dir/bin/nvim" /usr/local/bin/nvim
  rm -rf "$tmp_dir"
}

install_neovim_macos() {
  if command -v nvim >/dev/null 2>&1; then
    return
  fi

  log "Installing Neovim"
  brew install neovim
}

install_ruby_lsp() {
  log "Installing Ruby LSP"
  gem install --no-document ruby-lsp
}

backup_and_link_config() {
  log "Backing up existing Neovim configuration"
  if [[ -e "$NVIM_CONFIG" && ! -L "$NVIM_CONFIG" ]]; then
    local backup="$HOME/.config/nvim.backup.$STAMP"
    mv "$NVIM_CONFIG" "$backup"
    echo "Backup: $backup"
  elif [[ -L "$NVIM_CONFIG" ]]; then
    rm "$NVIM_CONFIG"
  fi

  mkdir -p "$HOME/.config"
  ln -sfn "$DOTFILES_DIR/nvim" "$NVIM_CONFIG"
}

bootstrap_neovim() {
  log "Bootstrapping plugins"
  nvim --headless "+Lazy! sync" +qa

  log "Verifying required plugins"
  nvim --headless \
    '+lua assert(pcall(require, "neotest-rspec"), "neotest-rspec failed to load")' \
    +qa

  log "Installing Mason tooling"
  nvim --headless "+MasonToolsInstallSync" +qa
}

final_checks() {
  log "Final checks"
  echo "Neovim: $(nvim --version | head -1)"
  echo "Config:  $NVIM_CONFIG -> $DOTFILES_DIR/nvim"
  echo "Ruby:    $(ruby --version | cut -d' ' -f2-)"
  echo "Node:    $(node --version)"
  echo "Python:  $(python3 --version)"
  echo "Go:      $(go version | cut -d' ' -f3-)"
  echo
  nvim --headless "+checkhealth" +qa >/dev/null 2>&1 || true
  echo "Neovim installation complete. Start with: nvim"
}

case "$OS" in
  Darwin)
    install_macos_dependencies
    install_neovim_macos
    ;;
  Linux)
    install_linux_dependencies
    if ! command -v nvim >/dev/null 2>&1; then
      install_latest_neovim_linux "$(dpkg --print-architecture)"
    fi
    ;;
  *)
    die "Unsupported operating system: $OS. Supported: Linux (Ubuntu) and macOS."
    ;;
esac

install_ruby_lsp
backup_and_link_config

# Telescope's native fzf extension needs a compiler; fd is named fdfind on Ubuntu.
if [[ "$OS" == "Linux" ]] && ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
  export PATH="$HOME/.local/bin:$PATH"
fi

bootstrap_neovim
final_checks
