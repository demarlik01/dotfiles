# mise 사용법

## mise란?

[mise](https://mise.jdx.dev/)는 개발 도구 버전 관리자다.
nvm, pyenv, sdkman 등을 하나로 통합해서, 프로젝트별로 Node.js, Python, Java 등의 버전을 관리한다.
도구 버전 외에 환경 변수, 태스크 실행도 지원한다.

## 핵심 개념

프로젝트 디렉토리에 `mise.toml` (또는 `.mise.toml`, `.tool-versions`) 파일을 두면,
해당 디렉토리에 진입할 때 자동으로 지정된 버전의 도구가 활성화된다.

```
~/my-project/mise.toml
→ cd ~/my-project 하면 node 22, python 3.12 자동 적용
→ cd ~ 하면 글로벌 버전으로 복귀
```

설정 파일 위치:
- **프로젝트**: `mise.toml` (프로젝트 루트)
- **글로벌**: `~/.config/mise/config.toml`

## 자주 쓰는 명령어

### 도구 설치 및 활성화

```bash
# 도구 설치 + mise.toml에 버전 기록
mise use node@22
mise use python@3.12
mise use java@21

# 글로벌 기본 버전 설정 (~/.config/mise/config.toml에 기록)
mise use --global node@22
```

### 특정 버전으로 바로 실행

```bash
# mise.toml 없이 특정 버전으로 실행
mise exec node@20 -- node -v
mise exec python@3.11 -- python script.py

# 줄여서
mise x node@20 -- node -v
```

### 설치된 도구 확인

```bash
# 현재 활성화된 도구 목록
mise ls

# 특정 도구만
mise ls node
```

### 도구 설치/삭제

```bash
# 버전만 설치 (mise.toml에 기록하지 않음)
mise install node@20

# 설치된 버전 삭제
mise uninstall node@20

# 안 쓰는 버전 정리
mise prune
```

### 사용 가능한 버전 확인

```bash
# 설치 가능한 버전 목록
mise ls-remote node

# 최신 버전 확인
mise latest node
```

### 업데이트

```bash
# 설치된 도구 중 업데이트 가능한 것 확인
mise outdated

# 도구 업그레이드
mise upgrade node
```

## 프로젝트별 설정

프로젝트 루트에서 `mise use`를 실행하면 `mise.toml`이 생성된다.

```bash
cd ~/my-project
mise use node@22
mise use python@3.12
```

생성된 `mise.toml`:

```toml
[tools]
node = "22"
python = "3.12"
```

팀원이 이 파일을 받으면 `mise install`만 실행하면 동일한 환경이 구성된다.

```bash
git clone <repo>
cd <repo>
mise install   # mise.toml에 명시된 도구 전부 설치
```

## npm, pipx 등 패키지 매니저 도구 설치

core 도구 외에 npm, pipx 등의 백엔드도 지원한다.

```bash
# npm 패키지를 글로벌 도구로 설치
mise use --global npm:@anthropic-ai/claude-code

# pipx 패키지
mise use --global pipx:black
```

## 환경 변수

`mise.toml`에서 프로젝트별 환경 변수도 관리할 수 있다.

```toml
[env]
NODE_ENV = "production"
DATABASE_URL = "postgres://localhost/mydb"
```

```bash
# CLI로 추가
mise set DATABASE_URL=postgres://localhost/mydb

# 제거
mise unset DATABASE_URL
```

## 태스크

`mise.toml`에 태스크를 정의하고 `mise run`으로 실행할 수 있다.

```toml
[tasks]
dev = "npm run dev"
test = "npm test"
lint = "eslint src/"
```

```bash
mise run dev
mise run test

# 줄여서
mise r dev
```

태스크 실행 전에 필요한 도구가 자동으로 설치된다.

## 기존 도구에서 마이그레이션

nvm, pyenv 등에서 관리하던 버전을 mise로 동기화할 수 있다.

```bash
# nvm에서 동기화
mise sync node --nvm

# pyenv에서 동기화
mise sync python --pyenv
```

## 문제 해결

```bash
# 설치 상태 점검
mise doctor
```

`mise doctor`는 설정, 경로, 플러그인 상태를 전부 점검해서 문제가 있으면 알려준다.

GitHub API 요청이 많으면 rate limit에 걸릴 수 있다. `GITHUB_TOKEN` 환경 변수를 설정하면 해결된다.
