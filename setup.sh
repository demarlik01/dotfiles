#!/bin/bash
set -e

echo "=== dotfiles setup for macOS ==="

# ----------------------------------------
# 1. Homebrew
# ----------------------------------------
if ! command -v brew &>/dev/null; then
  echo ">> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon path setup
  if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo ">> Homebrew already installed"
fi

# ----------------------------------------
# 2. Nerd Fonts (Hack)
# ----------------------------------------
echo ">> Installing Nerd Fonts (Hack)..."
brew install --cask font-hack-nerd-font

# ----------------------------------------
# 3. GNU Stow
# ----------------------------------------
echo ">> Installing stow, tree, ripgrep, fd, tig..."
brew install stow tree ripgrep fd tig

# ----------------------------------------
# 4. Ghostty
# ----------------------------------------
if ! command -v ghostty &>/dev/null && [ ! -d "/Applications/Ghostty.app" ]; then
  echo ">> Installing Ghostty..."
  brew install --cask ghostty
else
  echo ">> Ghostty already installed"
fi

# ----------------------------------------
# 5. Neovim
# ----------------------------------------
echo ">> Installing Neovim..."
brew install neovim

# ----------------------------------------
# 6. Zimfw
# ----------------------------------------
echo ">> Installing zimfw, starship..."
brew install --formula zimfw
brew install starship

# ----------------------------------------
# 7. Stow packages
# ----------------------------------------
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

echo ">> Applying dotfiles with stow..."

# ghostty
stow -R --no-folding -v ghostty

# nvim
stow -R --no-folding -v nvim

# zsh
stow -R --no-folding -v zsh

# starship
stow -R --no-folding -v starship

echo ""
echo "=== Done! ==="
echo "Add 'source ~/.zsh_common' to your ~/.zshrc"
echo "Restart your terminal to apply changes."
