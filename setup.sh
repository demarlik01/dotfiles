#!/bin/bash
set -e

# Homebrew 6부터 설치 확인(ask mode)이 기본이라 brew install마다 y/n을 물어본다.
# 모든 brew 명령을 비대화형으로 실행 (brew install -y 와 동일, 구버전 brew에서도 무해).
export HOMEBREW_NO_ASK=1

echo "=== dotfiles setup for macOS ==="

# ----------------------------------------
# 1. Homebrew
# ----------------------------------------
if ! command -v brew &>/dev/null; then
  echo ">> Installing Homebrew..."
  # NONINTERACTIVE=1: RETURN 확인 없이 설치 (공식 무인 설치 방식).
  # 이 모드에서는 installer가 sudo에게 비밀번호를 물어볼 수 없으므로 미리 1회 캐싱해둔다.
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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
echo ">> Installing stow, tree, ripgrep, fd, tig, gh..."
brew install stow tree ripgrep fd tig gh

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

# Mason uses npm to install pyright and several web LSP servers.
echo ">> Installing Node.js LTS with mise..."
mise use --global --yes node@lts

# ----------------------------------------
# 8. tmux
# ----------------------------------------
echo ">> Installing tmux..."
brew install tmux

# ----------------------------------------
# 9. Stow packages
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

# tmux
stow -R --no-folding -v tmux

# ----------------------------------------
# 10. ~/.zshrc 설정
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
