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
echo ">> Installing Nerd Fonts (Hack, D2Coding)..."
brew install --cask font-hack-nerd-font font-d2coding-nerd-font

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
# 7. mise (runtime version manager)
# ----------------------------------------
echo ">> Installing mise..."
brew install mise

# ----------------------------------------
# 8. Stow packages
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

# ----------------------------------------
# 9. ~/.zshrc 설정
# ----------------------------------------
ZSHRC_LINE='source ~/.zsh_common'
if [ ! -f ~/.zshrc ]; then
  echo ">> Creating ~/.zshrc..."
  echo "$ZSHRC_LINE" > ~/.zshrc
elif ! grep -qF "$ZSHRC_LINE" ~/.zshrc; then
  echo ">> Adding source line to ~/.zshrc..."
  echo "" >> ~/.zshrc
  echo "$ZSHRC_LINE" >> ~/.zshrc
else
  echo ">> ~/.zshrc already configured"
fi

echo ""
echo "=== Done! ==="
echo "Restart your terminal to apply changes."
