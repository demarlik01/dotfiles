# GNU Stow 사용법

## Stow란?

[GNU Stow](https://www.gnu.org/software/stow/)는 심볼릭 링크 관리 도구다.
패키지 폴더 안의 디렉토리 구조를 그대로 홈 디렉토리(`~`)에 심볼릭 링크로 미러링한다.

## 핵심 개념

패키지 폴더 안을 **홈 디렉토리라고 생각**하면 된다.

```
~/dotfiles/ghostty/.config/ghostty/config
                   ^^^^^^^^^^^^^^^^^^^^^^^^
                   이 부분이 ~ 기준 경로가 됨

stow ghostty 실행 →
~/.config/ghostty/config → ~/dotfiles/ghostty/.config/ghostty/config (symlink)
```

## 자주 쓰는 명령어

모든 명령은 `~/dotfiles` 디렉토리에서 실행한다.

```bash
cd ~/dotfiles
```

### 패키지 적용

```bash
stow --no-folding ghostty
```

`--no-folding` 옵션은 중간 디렉토리(`.config/` 등)를 실제 폴더로 만들고 최종 파일만 symlink으로 건다.
이 옵션 없이 하면 디렉토리 자체가 symlink이 될 수 있다.

### 패키지 해제

```bash
stow -D ghostty
```

심볼릭 링크만 제거한다. dotfiles 안의 원본 파일은 그대로 남는다.

### 재적용 (파일 추가 후)

```bash
stow -R --no-folding nvim
```

기존 링크를 정리하고 다시 건다. 패키지에 새 파일을 추가한 뒤에 사용한다.

### 전체 패키지 한번에 적용

```bash
stow --no-folding */
```

dotfiles 안의 모든 패키지를 한번에 적용한다.

## 패키지 추가하기

새로운 설정을 관리하고 싶으면:

1. dotfiles에 패키지 폴더를 만든다
2. 홈 디렉토리 기준 경로를 그대로 재현한다
3. 기존 파일을 옮기고 stow로 적용한다

```bash
# 예: zsh 설정 추가
mkdir -p ~/dotfiles/zsh
cp ~/.zshrc ~/dotfiles/zsh/.zshrc
rm ~/.zshrc
cd ~/dotfiles && stow --no-folding zsh
```

## 주의사항

- **충돌**: 대상 경로에 이미 실제 파일이 있으면 stow는 에러를 내고 중단한다. 기존 파일을 먼저 삭제하거나 백업해야 한다.
- **`--no-folding`**: 다른 앱의 설정이 `.config/` 아래에 있을 수 있으므로, dotfiles에서는 항상 이 옵션을 쓰는 것을 권장한다.
- **stow 대상 디렉토리**: 기본적으로 상위 디렉토리(`..`)를 대상으로 한다. `~/dotfiles`에서 실행하면 `~`가 대상이 된다.
