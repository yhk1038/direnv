# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Agent Common Rules

### **🚨 Required: Follow Agent Workflow 🚨**

**All agents must follow the [Agent Workflow](.claude/agent-workflow.md) before starting any task.**

**Core Principles**:
1. **Proactive Responsibility**: Agents automatically check and guide workflow even if users forget
2. **Task Documentation First**: Always check `.claude/tasks/` for task definitions before starting work
3. **Follow Branching Strategy**: Create and manage branches according to [Branching Strategy](.claude/branching-strategy.md)
4. **Handle User Exceptions**: Gently re-guide when users want to skip workflow, encourage minimum compliance
5. **Workflow Changes Restricted**: Workflow changes only on `main` branch after discussion

**Detailed Documentation**:
- [Agent Workflow](.claude/agent-workflow.md) - Task startup process, user exception handling
- [Branching Strategy](.claude/branching-strategy.md) - Branch creation, PR, merge rules
- [Task Documentation Guide](.claude/tasks/README.md) - Task document creation and management
- [Commit Guidelines](.claude/commit-guidelines.md) - Git commit rules

### Tool Usage

**Do Not Use**:
- **JetBrains MCP**: This project does not use JetBrains IDE integration
- **Playwright MCP**: This project does not involve browser automation or web UI
- **UI Component Tools**: This is a CLI tool without graphical interface

**Available for Use**:
- Standard shell development tools
- Text editors and file manipulation tools
- Git command line tools

### Communication and Multilingual Support

#### Personal Settings

Each developer can create `.claude/settings.local.json` to configure preferred language and style:

```json
{
  "communication": {
    "language": "ko",  // or "en", "ja", etc.
    "style": "casual"  // or "formal"
  }
}
```

Agents read this setting and communicate in the specified language. See [settings.local.json.example](.claude/settings.local.json.example) for template.

#### Documentation Language

- **Shared Documents** (workflows, branching strategy, etc.): Written in English
- **Personal Task Documents**: Writer's preferred language allowed (in `.claude/tasks/personal/`)
- **Commit Messages**: English (Conventional Commits)
- **PR Descriptions**: English recommended, complex content can be supplemented in native language

This approach ensures:
- ✅ **Open Source Friendly**: Core documents in English for all contributors
- ✅ **Personal Customization**: Communicate with agents in your preferred language
- ✅ **Flexibility**: Work-in-progress tasks can be in any language
- ✅ **Consistency**: Workflow and branching strategy are language-agnostic

---

## 프로젝트 개요

**Direnv Light**는 디렉토리별 환경 변수와 설정을 자동으로 로드/언로드하는 경량 셸 확장 프로그램입니다. 사용자가 `.envrc` 또는 `.profile` 파일이 있는 디렉토리에 진입하면 자동으로 환경이 적용되고, 디렉토리를 나가면 이전 상태로 복원됩니다.

**주요 특징:**
- 원본 direnv와 달리 `export`뿐만 아니라 `alias`, `function` 등 일반 셸 스크립팅을 지원
- 순수 POSIX 셸 스크립트로 작성되어 bash, zsh, ksh 등 다양한 셸 환경 지원
- 다국어 지원 (영어, 한국어, 일본어)

---

## 필수 명령어

### 개발 및 테스트
```bash
# 테스트 실행
make test

# 또는 직접 실행
sh test/test_load_current_dir_env.sh
```

### 로컬 설치 (개발/디버깅용)
```bash
# 개발 버전을 로컬에 직접 설치
cp -r ./src ~/.direnv/

# 또는 install.sh로 설치 테스트
sh install.sh

# 설치 후 환경 적용
de  # alias de=". $HOME/.direnv/src/init.sh"
```

### 릴리즈
```bash
# 릴리즈 생성 (태그 푸시 후 GitHub Actions가 자동으로 배포)
make release VERSION=v0.1.2

# 또는 직접 실행
./release.sh v0.1.2
```

**릴리즈 프로세스**:
1. [VERSION](VERSION) 파일 업데이트
2. Git 태그 생성 및 푸시
3. GitHub Actions가 자동으로 tar.gz와 zip 파일 생성하여 릴리즈에 첨부

---

## Git 커밋 규칙

이 프로젝트는 **Conventional Commits 기반의 영어 커밋 메시지**를 사용합니다.

### 커밋 타입

| 타입 | 사용 시점 | 예시 |
|------|----------|------|
| `feat:` | 새로운 기능 추가 | `feat: add 'df' alias to clean up tmp directory files` |
| `fix:` | 버그 수정 | `fix: prevent env loading when in home directory` |
| `test:` | 테스트 추가/수정 | `test: Add first test` |
| `ci:` | CI/CD 설정 변경 | `ci: add GitHub Actions workflow for testing` |
| `chore:` | 기타 변경 | `chore: suppress error output when restoring env vars` |
| `docs:` | 문서 변경 | `docs: update README with installation steps` |

**간단한 업데이트**는 타입 없이 작성 가능: `Update ko.lang`, `Remove deprecated comments`

### 작성 규칙

- 영어로 작성
- 소문자로 시작 (첫 글자를 대문자로 하지 않음)
- 명령형 동사 사용 (add, fix, update)
- 마침표(.)를 붙이지 않음
- 50자 이내로 간결하게

**상세 규칙**: [.claude/commit-guidelines.md](.claude/commit-guidelines.md) 참고

### 커밋 후 동작

**중요**: 커밋 완료 후 **자동으로 푸시하지 않습니다**.

- ✅ 커밋 완료 후 사용자에게 푸시 여부를 물어봅니다
- ✅ 사용자가 "예" 또는 "푸시"라고 답하면 푸시 진행
- ✅ 사용자가 "아니오" 또는 "나중에"라고 답하면 푸시하지 않음

**예시**:
```
"커밋이 완료되었습니다.
변경사항을 원격 저장소에 푸시하시겠습니까?

푸시하려면 '예' 또는 '푸시'라고 답변해주세요.
나중에 하려면 '아니오' 또는 '나중에'라고 답변해주세요."
```

---

## 커밋 전 체크리스트

새로운 기능이나 수정사항을 커밋하기 전에 반드시 확인하세요:

```markdown
[ ] 테스트 실행 (`make test`) - 모든 테스트 통과 확인
[ ] POSIX 호환성 준수 - bash/zsh 전용 문법 사용 안 함
[ ] 커밋 메시지가 영어로 작성되었는지 확인
[ ] 커밋 타입이 적절한지 확인 (중요한 변경은 타입 필수)
[ ] 설명이 명확하고 간결한지 확인 (50자 이내)
[ ] 에러 처리 - 예상치 못한 상황에 대한 에러 메시지 추가
[ ] 다국어 지원 - 새 메시지 추가 시 모든 .lang 파일 업데이트
[ ] 임시 파일 경로 일관성 - CURRENT_ENV_FILE 등의 경로가 일치하는지 확인
```

---

## 핵심 아키텍처

### 디렉토리 구조
```
~/.direnv/
├── src/
│   ├── init.sh                         # 진입점
│   ├── lang/                           # 다국어 메시지 파일
│   ├── scripts/
│   │   ├── detect-language.sh          # 로케일 기반 언어 감지
│   │   ├── load_current_dir_env.sh     # 환경 로딩 로직
│   │   ├── unload_current_dir_env.sh   # 환경 복원 로직
│   │   └── directory_changed_hook.sh   # cd 훅
│   └── tmp/                            # 런타임 상태 파일
│       ├── current_env_file            # 현재 로딩된 환경 파일 복사본
│       ├── original_environment_aliases # 원본 alias 백업
│       └── original_environment_variables # 원본 환경변수 백업
```

### 핵심 동작 흐름

1. **초기화** ([src/init.sh](src/init.sh)):
   - 모든 스크립트 함수를 소싱
   - `cd` 명령어를 오버라이드하여 디렉토리 변경 감지
   - 현재 디렉토리에 환경 파일이 있으면 즉시 로드

2. **환경 로딩** ([src/scripts/load_current_dir_env.sh](src/scripts/load_current_dir_env.sh)):
   - 홈 디렉토리 자체는 제외 (`$HOME != $PWD`)
   - 홈 디렉토리 하위만 허용 (`$HOME/*`)
   - `.envrc` 또는 `.profile` 파일 존재 시:
     - 기존 alias와 환경변수를 백업 파일로 저장
     - 환경 파일을 소싱하여 적용
     - `~/.direnv/tmp/current_env_file`에 복사본 저장

3. **환경 언로딩** ([src/scripts/unload_current_dir_env.sh](src/scripts/unload_current_dir_env.sh)):
   - 현재 로딩된 환경 파일의 alias와 환경변수 제거
   - 백업해둔 원본 상태 복원
   - 모든 임시 파일 삭제

4. **디렉토리 변경 훅**:
   - `OLDPWD != PWD` 체크로 실제 변경 감지
   - 이전 환경 언로드 → 새 환경 로드 순서로 실행

---

## 코드 작성 규칙

### 1. POSIX 호환성 엄수

**가장 중요한 규칙**: 이 프로젝트는 순수 POSIX sh로 작성되어야 합니다.

❌ **절대 사용 금지**:
- `local` 키워드 (POSIX sh에 없음)
- 배열 (`arr=(1 2 3)`)
- `[[` 조건문 (대신 `[` 사용)
- `$(())` 산술 연산 (필요 시 `expr` 사용)
- `function` 키워드 (대신 `func_name() { ... }` 형식)
- bash/zsh 전용 문법 (`&>`, `|&`, `<<<` 등)

✅ **사용해야 할 것**:
- `[` 조건문
- 개행으로 구분된 문자열 (배열 대신)
- 함수 내 변수는 전역으로 선언
- `case` 문으로 패턴 매칭
- `while IFS= read` 루프

### 2. 서브셸 주의

- 파이프(`|`)는 서브셸을 생성하므로 변수 할당이 유지되지 않음
- 루프에서 변수 변경이 필요하면 리디렉션 사용:
  ```bash
  # ❌ 잘못된 예 (서브셸)
  cat file | while read line; do
    count=$((count + 1))  # count는 서브셸에서만 증가
  done

  # ✅ 올바른 예 (현재 셸)
  while read line; do
    count=$((count + 1))
  done < file
  ```

### 3. 에러 처리

- 중요한 명령어는 에러 체크 추가:
  ```bash
  if ! some_command; then
    echo "[direnv] ⚠️ Failed to ..." >&2
    return 1
  fi
  ```
- 사용자에게 혼란을 줄 수 있는 에러는 `2>/dev/null`로 억제

### 4. 다국어 지원

새 메시지 추가 시:
1. [src/lang/](src/lang/)의 **모든** 언어 파일에 동일 변수명으로 추가
2. 변수명은 `MSG_` 접두사 사용 (예: `MSG_STEP_DOWNLOAD`)
3. [install.sh](install.sh)에서 `eval`로 로드되므로 문법 주의

---

## 새 스크립트 추가 시 체크리스트

새로운 스크립트 파일을 추가할 때:

```markdown
[ ] [src/init.sh](src/init.sh)에 소싱 추가 (`. ~/.direnv/src/scripts/새스크립트.sh`)
[ ] 함수명은 `_`로 시작 (예: `_my_function`)
[ ] POSIX 호환성 검증 (`shellcheck` 실행 권장)
[ ] 필요한 경우 [test/](test/)에 테스트 케이스 추가
[ ] README 업데이트 (사용자에게 영향이 있는 경우)
```

---

## 테스트 작성 가이드

### 기존 테스트 구조

[test/test_load_current_dir_env.sh](test/test_load_current_dir_env.sh)는 다음을 테스트합니다:
- 홈 디렉토리 자체는 환경 로딩 차단
- 홈 디렉토리 하위는 환경 로딩 허용
- 홈 디렉토리 외부는 환경 로딩 차단

### 새 테스트 추가 방법

1. `test/` 디렉토리에 `test_기능명.sh` 파일 생성
2. 다음 구조 사용:
   ```bash
   #!/bin/sh
   FAILED=0

   # 테스트 함수
   test_something() {
     if [ condition ]; then
       echo "✅ (PASS) ..."
     else
       echo "❌ (FAIL) ..."
       FAILED=1
     fi
   }

   # 테스트 실행
   test_something

   # CI 환경에서만 실패 시 exit 1
   if [ "$CI" = "true" ]; then
     exit "$FAILED"
   else
     exit 0
   fi
   ```
3. [Makefile](Makefile)의 `test` 타겟에 추가

---

## 중요한 구현 세부사항

### 1. 백업/복원 메커니즘

- `~/.direnv/tmp/` 아래의 파일들이 환경 상태 추적
- **백업 파일이 존재하면 새 백업을 생성하지 않음** (최초 상태 보존)
- 복원 시 에러가 발생하면 백업 파일을 보존하고 경고 메시지 출력

**중요**: 임시 파일 경로 변수가 여러 스크립트에서 동일하게 사용됨
- `CURRENT_ENV_FILE`
- `ORIGINAL_ALIASES_FILE`
- `ORIGINAL_VARIABLE_FILE`

경로 변경 시 모든 스크립트에서 동기화 필요!

### 2. 보안 고려사항

- 환경 파일(`.envrc`, `.profile`)을 신뢰하여 `source`하므로, 사용자가 직접 작성한 파일만 사용해야 함
- 홈 디렉토리 외부(`/tmp`, `/var` 등)에서는 로딩하지 않음
- 이는 의도적인 보안 제한 사항

### 3. 다국어 메시지 처리

- [install.sh](install.sh#L9-17)에서 `locale` 명령으로 `LANG` 감지
- 지원되지 않는 언어는 `en`으로 fallback
- 언어 파일은 GitHub raw URL에서 `curl`로 가져와 `eval`로 실행

---

## GitHub Actions

### 릴리즈 워크플로우 ([.github/workflows/release.yml](.github/workflows/release.yml))
- `v*` 태그 푸시 시 자동 트리거
- `src/` 디렉토리를 tar.gz와 zip으로 압축
- GitHub Release 생성 및 파일 첨부

### 테스트 워크플로우 ([.github/workflows/test.yml](.github/workflows/test.yml))
- main 브랜치 푸시 및 PR 시 실행
- `CI=true make test` 명령으로 테스트 실행

---

## 유용한 별칭 (Aliases)

설치 후 사용자 환경에 자동으로 추가되는 별칭:

- `de`: direnv 초기화 (`. $HOME/.direnv/src/init.sh`)
- `dl`: 현재 로딩된 환경 파일 내용 출력
- `df`: `~/.direnv/tmp/*` 임시 파일 모두 삭제 (debug/cleanup용)

---

## 디버깅 팁

### 문제: 환경이 로딩되지 않음

1. 현재 디렉토리 확인:
   ```bash
   echo $PWD
   echo $HOME
   ```
2. 환경 파일 존재 확인:
   ```bash
   ls -la .envrc .profile
   ```
3. 임시 파일 상태 확인:
   ```bash
   ls -la ~/.direnv/tmp/
   cat ~/.direnv/tmp/current_env_file  # 현재 로딩된 환경 파일
   ```

### 문제: 이전 환경이 복원되지 않음

1. 백업 파일 확인:
   ```bash
   cat ~/.direnv/tmp/original_environment_aliases
   cat ~/.direnv/tmp/original_environment_variables
   ```
2. 에러 메시지 확인 (복원 실패 시 경고 메시지 출력)

### 임시 파일 정리

```bash
df  # alias df='rm -f ~/.direnv/tmp/*'
```

---

## 관련 문서

- [README.md](README.md) - 프로젝트 소개 및 설치 가이드
- [README.ko.md](README.ko.md) - 한국어 README
- [TODO.md](TODO.md) - 향후 계획 및 개선 사항
