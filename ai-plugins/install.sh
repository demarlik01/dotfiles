#!/bin/bash
# Claude Code / Codex 플러그인을 선언 파일 기준으로 idempotent하게 설치한다.
#
# 선언 파일 (이 디렉토리):
#   claude-plugins.txt / codex-plugins.txt   설치할 플러그인 (name@marketplace)
#
# 빌트인 마켓플레이스(claude-plugins-official, openai-curated 등)만 사용하므로
# 마켓플레이스 추가는 하지 않는다. 서드파티 마켓플레이스가 필요해지면
# `claude plugin marketplace add` / `codex plugin marketplace add` 를 여기에 추가하면 된다.
# 이 스크립트는 단독 실행도 되고, setup.sh 끝에서 호출되어도 된다.
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
