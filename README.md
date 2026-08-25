# dotfiles

macOS 개발 환경 설정 모음집. [GNU Stow](https://www.gnu.org/software/stow/)로 심볼릭 링크를 관리합니다. ([stow 사용법](docs/stow.md) | [단축키 모음](docs/shortcuts.md) | [mise 사용법](docs/mise.md))

## 포함된 설정

| 패키지 | 설명 | 대상 경로 |
|--------|------|----------|
| ghostty | 터미널 에뮬레이터 설정 (테마, 폰트, 키바인드) | `~/.config/ghostty/config` |
| nvim | Neovim 설정 (lazy.nvim, neo-tree, telescope, treesitter, LSP) | `~/.config/nvim/` |
| zsh | Zsh 공통 설정 (zimfw, alias) | `~/.zsh_common`, `~/.zimrc` |
| starship | 프롬프트 테마 | `~/.config/starship.toml` |
| tmux | 터미널 멀티플렉서 설정 (마우스, Ghostty 연동) | `~/.tmux.conf` |
| ai-plugins | Claude Code / Codex 플러그인 선언 + Codex 스킬 + 설치 스크립트 | (CLI 설정에 직접 설치) |

## 설치

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh`가 하는 일:
1. Homebrew 설치 (없으면)
2. Nerd Fonts (Hack) 설치
3. GNU Stow, tree, ripgrep, fd, tig 설치
4. Ghostty 설치
5. Neovim 설치
6. Zimfw, Starship 설치
7. mise 설치 및 Node.js LTS 글로벌 버전 설정 (Mason의 npm 기반 LSP용)
8. tmux 설치
9. stow로 설정 파일 심볼릭 링크 생성
10. `~/.zshrc` 생성 (없으면) 및 `source ~/.zsh_common` 추가

> AI 플러그인(Claude Code / Codex)은 `setup.sh`에 포함되지 않습니다. 필요할 때 수동으로 실행하세요 (아래 참고).

## AI 플러그인 (Claude Code / Codex)

`ai-plugins/`의 선언 파일을 기준으로 플러그인을 idempotent하게 설치하고,
저장소에서 관리하는 Codex 스킬을 `~/.agents/skills/`에 심볼릭 링크로 연결합니다.
`setup.sh`와는 분리되어 있으니 **필요할 때 수동으로** 실행하세요.
설정 파일(`~/.claude/settings.json`, `~/.codex/config.toml`)은 도구가 직접 갱신하고
머신 종속 절대경로가 섞여 있어 stow 대상에서 제외했고, 대신 "설치할 목록"만 선언합니다.
서드파티 Claude 마켓플레이스도 선언할 수 있으며, 플러그인보다 먼저 추가됩니다.

| 파일 | 내용 |
|------|------|
| `claude-marketplaces.txt` | Claude 서드파티 마켓플레이스 (`name source`) |
| `claude-plugins.txt` / `codex-plugins.txt` | 설치할 플러그인 (`name@marketplace`) |
| `skills/codex/*/SKILL.md` | Codex에서 사용할 로컬 스킬 |

```bash
# claude/codex CLI가 설치된 상태에서 실행
./ai-plugins/install.sh
```

빌트인 마켓플레이스의 새 플러그인은 해당 `*-plugins.txt`에 한 줄 추가합니다.
서드파티 Claude 플러그인은 `claude-marketplaces.txt`에 마켓플레이스를 먼저 선언하고
`claude-plugins.txt`에 플러그인을 추가한 뒤 위 스크립트를 재실행합니다.
로컬 Codex 스킬은 `ai-plugins/skills/codex/<name>/SKILL.md`에 추가하고 위 스크립트를 재실행합니다.
스킬 소스는 실행 주체별로 나눈니다. 예를 들어 Codex가 Claude를 호출하는 스킬은
`skills/codex/`에 둡니다.

## 개별 패키지 적용/해제

```bash
cd ~/dotfiles

# 적용
stow --no-folding ghostty

# 해제
stow -D ghostty
```

## 구조

```
~/dotfiles/
├── setup.sh              # 초기 셋업 스크립트
├── ghostty/
│   └── .config/
│       └── ghostty/
│           └── config        # ghostty 설정
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua      # neovim 진입점 + lazy.nvim bootstrap
│           ├── lua/
│           │   ├── config/
│           │   │   └── options.lua  # 기본 옵션
│           │   └── plugins/
│           │       ├── neo-tree.lua     # 파일 트리
│           │       ├── telescope.lua    # 퍼지 파인더
│           │       ├── treesitter.lua   # 구문 하이라이팅
│           │       └── lsp.lua          # LSP (mason + lspconfig)
│           └── after/
│               └── ftplugin/
│                   └── python.lua   # python ts=4
├── zsh/
│   ├── .zsh_common           # 공통 설정 (zimfw, alias, 환경변수)
│   └── .zimrc                # zimfw 플러그인 목록
├── starship/
│   └── .config/
│       └── starship.toml     # 프롬프트 테마 설정
├── tmux/
│   └── .tmux.conf            # tmux 설정 (마우스, Ghostty 연동)
├── docs/
│   ├── stow.md              # stow 사용법
│   ├── shortcuts.md         # neovim 단축키 모음
│   └── mise.md              # mise 사용법
└── README.md
```
