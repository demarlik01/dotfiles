#!/bin/bash
# Claude Code / Codex 플러그인을 선언 파일 기준으로 idempotent하게 설치한다.
#
# 선언 파일 (이 디렉토리):
#   claude-marketplaces.txt                   Claude 서드파티 마켓플레이스 (name source)
#   claude-plugins.txt / codex-plugins.txt   설치할 플러그인 (name@marketplace)
#
# setup.sh와는 분리되어 있다 — claude/codex CLI를 설치한 뒤 필요할 때 직접 실행한다.
set -uo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

# 주석(#)과 빈 줄을 걸러 유효한 항목만 출력
read_entries() {
  local file="$1"
  [ -f "$file" ] || return 0
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$file" | grep -v '^[[:space:]]*$'
}

# ----------------------------------------
# Claude Code
# ----------------------------------------
if command -v claude &>/dev/null; then
  echo ">> Claude Code 플러그인 설정 중..."

  configured_claude_marketplaces="$(claude plugin marketplace list --json 2>/dev/null || true)"
  while IFS=' ' read -r marketplace_name marketplace_source extra; do
    [ -z "$marketplace_name" ] && continue
    if [ -z "$marketplace_source" ] || [ -n "$extra" ]; then
      echo "   ! 잘못된 마켓플레이스 선언: $marketplace_name $marketplace_source $extra"
      continue
    fi
    if printf '%s\n' "$configured_claude_marketplaces" | grep -qF "\"name\": \"$marketplace_name\""; then
      echo "   = 이미 추가된 마켓플레이스: $marketplace_name"
    else
      echo "   + 마켓플레이스 추가: $marketplace_name ($marketplace_source)"
      claude plugin marketplace add "$marketplace_source" \
        || echo "     마켓플레이스 추가 실패: $marketplace_name"
    fi
  done < <(read_entries "$DIR/claude-marketplaces.txt")

  installed_claude="$(claude plugin list 2>/dev/null)"
  while IFS= read -r plugin; do
    [ -z "$plugin" ] && continue
    if printf '%s\n' "$installed_claude" | grep -qF "$plugin"; then
      echo "   = 이미 설치됨: $plugin"
    else
      echo "   + 설치: $plugin"
      claude plugin install "$plugin" --scope user || echo "     설치 실패: $plugin"
    fi
  done < <(read_entries "$DIR/claude-plugins.txt")
else
  echo ">> claude CLI 없음 — Claude 플러그인 건너뜀"
fi

# ----------------------------------------
# 공용 에이전트 CLI 도구
# ----------------------------------------
# 브라우저 자동화는 MCP 서버 대신 CLI로 제공한다 — 어느 에이전트든 셸로 호출할 수
# 있고, 안 쓰는 세션의 컨텍스트를 차지하지 않는다.
if command -v npm &>/dev/null; then
  if command -v playwright-cli &>/dev/null; then
    echo ">> 이미 설치됨: @playwright/cli"
  else
    echo ">> @playwright/cli 설치 중..."
    npm install -g @playwright/cli@latest || echo "   설치 실패: @playwright/cli"
  fi

  # 번들 스킬(사용법 문서)을 ~/.claude/skills/playwright-cli 에 복사한다.
  # 스킬 내용이 CLI 버전에 종속되므로 매번 실행해 덮어써서 동기화한다.
  if command -v playwright-cli &>/dev/null; then
    playwright-cli install --skills --global || echo "   스킬 설치 실패: playwright-cli"
    # Codex는 ~/.codex/skills 를 읽으므로 같은 스킬을 심볼릭 링크로 공유
    mkdir -p ~/.codex/skills
    ln -sfn ~/.claude/skills/playwright-cli ~/.codex/skills/playwright-cli
  fi
else
  echo ">> npm 없음 — @playwright/cli 건너뜀"
fi

# ----------------------------------------
# Codex
# ----------------------------------------
if command -v codex &>/dev/null; then
  echo ">> Codex 플러그인 설정 중..."
  installed_codex="$(codex plugin list 2>/dev/null)"
  while IFS= read -r plugin; do
    [ -z "$plugin" ] && continue
    # 플러그인 컬럼이 "name@marketplace ... installed" 형태인 행을 찾는다
    if printf '%s\n' "$installed_codex" | grep -qE "^${plugin}[[:space:]].*installed"; then
      echo "   = 이미 설치됨: $plugin"
    else
      echo "   + 설치: $plugin"
      codex plugin add "$plugin" || echo "     설치 실패: $plugin"
    fi
  done < <(read_entries "$DIR/codex-plugins.txt")
else
  echo ">> codex CLI 없음 — Codex 플러그인 건너뜀"
fi

echo ">> AI 플러그인 설정 완료"
