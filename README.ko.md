# 🌀 Direnv Light

![GitHub release (latest by date)](https://img.shields.io/github/v/release/yhk1038/direnv?style=flat-square)

[한국어 README](./README.ko.md)\
[English README](./README.md)

디렉토리별 환경 설정을 자동으로 로드/해제하는 경량 셸 확장 도구입니다.\
`.envrc`, `.profile` 파일을 기반으로 현재 디렉토리에 진입하면 환경 설정을 자동으로 적용하고, 디렉토리를 벗어나면 원래 상태로 복원합니다.

## ❗ 기존 direnv 의 한계는?

[direnv](https://github.com/direnv/direnv)는 매우 널리 사용되며 생태계의 기초를 이루는 프로젝트처럼 보이지만, 다음과 같은 단점이 있습니다:

1. **환경변수만 지원**: .envrc 파일 내에서 export 중심의 환경변수만 다룰 수 있으며, 일반적인 shell 확장 기능 (alias, function 등)은 공식적으로 지원되지 않습니다.
2. **프로젝트 유지 관리 부족**: 현재는 이슈나 PR에 대한 활동이 매우 낮고, 사실상 더 이상 적극적으로 관리되지 않는 것으로 보입니다.
3. **현실적인 불편함**: 다양한 프로젝트를 자주 넘나드는 개발자라면, 환경 설정을 더 자유롭게 구성할 수 있는 방법이 필요합니다. 기존 direnv는 이러한 실질적인 요구를 충족시키기에 부족할 수 있습니다.

---

## 🚀 Getting Started

아래 명령어 한 줄로 설치하세요:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/yhk1038/direnv/main/install.sh)"
```

설치가 완료되면, **새로운 터미널 세션에서 direnv가 자동으로 활성화**됩니다.

> 설치 스크립트가 셸 설정 파일(`.bashrc`, `.zshrc` 등)에 다음을 추가합니다:
> ```bash
> [ -f ~/.direnv/src/init.sh ] && source ~/.direnv/src/init.sh
> ```
>
> `de` 명령어는 초기화 후 사용할 수 있습니다. `de --help`로 사용 가능한 명령어를 확인하세요.

---

## 📂 설치 구성

설치 후 `~/.direnv/` 디렉토리에는 다음 파일들이 포함됩니다:

```
~/.direnv/
├── src/
│   ├── init.sh                          # 진입점 (초기화)
│   ├── VERSION                          # 현재 버전
│   ├── lang/
│   │   ├── en.lang                      # 영어 메시지
│   │   └── ko.lang                      # 한국어 메시지
│   └── scripts/
│       ├── detect-language.sh           # 로케일 기반 언어 감지
│       ├── load_current_dir_env.sh      # .envrc 또는 .profile 로드
│       ├── unload_current_dir_env.sh    # 환경 해제 및 복원
│       ├── directory_changed_hook.sh    # 디렉토리 변경 훅
│       └── de_command.sh               # de 명령어 (CLI 인터페이스)
├── tmp/                                 # 런타임 상태 파일
└── uninstall.sh                         # 제거 스크립트
```

---

## 🛠 명령어

`de` 명령어로 direnv를 관리할 수 있습니다:

| 명령어 | 설명 |
|--------|------|
| `de` | direnv 재초기화 (설정 다시 로드) |
| `de init [file]` | 현재 디렉토리에 `.envrc` (또는 `.profile`) 생성 |
| `de update` | 최신 버전으로 업데이트 |
| `de update <version>` | 특정 버전으로 업데이트 (예: `de update v0.8.0`) |
| `de versions` | 사용 가능한 버전 목록 표시 |
| `de --version` | 현재 버전 표시 |
| `de disable` | direnv 비활성화 (디렉토리 훅 끄기) |
| `de enable` | direnv 활성화 (디렉토리 훅 켜기) |
| `de status` | 현재 direnv 상태 표시 |
| `de uninstall` | direnv 제거 |
| `de --help` | 도움말 표시 |

**기타 별칭:**

| 별칭 | 설명 |
|------|------|
| `dl` | 현재 로딩된 환경 파일 내용 출력 |
| `df` | 임시 파일 정리 (`~/.direnv/tmp/*`) |

---

## 🧪 예시

```bash
# .envrc 또는 .profile 파일 예시
export PROJECT_ENV=dev
alias run="npm start"
```

디렉토리에 진입하면 위 환경이 자동으로 적용되고, 빠져나오면 해제됩니다.

---

## ✅ 지원 셸

- `bash`
- `zsh`
- `ksh`
- 기타 POSIX 호환 셸 (`sh`, `dash` 등)

---

## 🧹 제거 방법

direnv를 제거하려면 언인스톨 스크립트를 실행하세요:

```sh
sh ~/.direnv/uninstall.sh
```

또는 원격에서 직접 실행:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/yhk1038/direnv/main/uninstall.sh)"
```

언인스톨 스크립트가 수행하는 작업:
- 사용자 확인 요청
- 셸 설정 파일 백업 생성 (예: `.bashrc.backup.20251022_205030`)
- 셸 설정 파일에서 direnv 초기화 라인 제거
- `~/.direnv` 디렉토리 삭제

**수동 제거** (스크립트를 사용하지 않는 경우):

```sh
# 1. 디렉토리 제거
rm -rf ~/.direnv

# 2. 셸 설정 파일(.bashrc, .zshrc 등)을 편집하여 다음 라인 제거:
[ -f ~/.direnv/src/init.sh ] && source ~/.direnv/src/init.sh
```

---

## 📋 릴리즈 노트

### v0.8.x (2025-10-24)

**새로운 기능**:
- 설치 스크립트에서 `eval` 보안 위험 제거, 직접 파일 소싱 방식으로 변경
- `de` CLI 명령어 추가 (서브커맨드: `init`, `update`, `versions`, `disable`, `enable`, `status`, `uninstall`)
- `de init`으로 `.envrc`/`.profile` 생성 시 `.gitignore` 자동 연동
- `de disable`/`de enable`으로 세션별 direnv 토글 기능 추가
- 신규 설치 검증 테스트 추가

**버그 수정**:
- 서브셸에서 함수 존재 여부 확인으로 훅 에러 방지
- 설치/제거 시 레거시 `alias de=` 제거 (함수로 대체)
- zsh에서 함수 정의와 충돌하는 `unalias de` 문제 수정
- 언로드 스크립트에서 빈 grep 결과 에러 수정
- 모든 테스트 파일에서 `~/.direnv/tmp` 디렉토리 존재 보장
- 디렉토리 훅 테스트에서 POSIX 호환 `cd` 사용

### v0.7.1 (2025-10-23)

**버그 수정**:
- 이전 디렉토리로 돌아올 때 환경이 다시 로드되지 않는 치명적인 버그 수정
  - 문제: PWD와 OLDPWD가 백업되고 복원되어 디렉토리 상태가 손상됨
  - 영향: A → B → A 패턴의 디렉토리 이동 시 환경변수가 올바르게 재로드되지 않음
  - 해결: PWD와 OLDPWD를 환경변수 백업에서 제외 (셸 내부 상태)
  - 테스트: 모든 디렉토리 변경 훅 테스트 통과 (TEST 5 & TEST 6 수정)

### v0.7.0 (2025-10-23)

**새로운 기능**:
- 포괄적인 회귀 테스트 추가 (총 23개 테스트)
  - 백업/복원 메커니즘 테스트 (7개)
  - 환경 언로딩 테스트 (9개)
  - 디렉토리 변경 훅 테스트 (7개)
- Makefile 업데이트로 `make test`로 모든 테스트 실행 가능

**버그 수정**:
- 환경 언로딩의 치명적인 서브셸 문제 수정
  - 문제: 디렉토리를 나갈 때 새로 추가된 alias와 환경변수가 실제로 제거되지 않음
  - 영향: 프로젝트 간 전환 시 환경 오염 발생
- 환경변수 백업 시 특수문자 처리 문제 수정
  - 문제: 특수문자가 포함된 값으로 인해 복원 실패
  - 영향: "Failed to restore environment variables" 경고 제거

**문서**:
- 회귀 테스트를 위한 상세한 작업 문서 추가
- 테스트 인프라 업데이트

[모든 릴리즈 보기](https://github.com/yhk1038/direnv/releases)

---

## 📄 라이선스

MIT License © [yhk1038](https://github.com/yhk1038)

