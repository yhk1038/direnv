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
> alias de=". $HOME/.direnv/src/init.sh"
> ```
>
> `de` 별칭을 사용하면 필요할 때 수동으로 direnv를 재로드할 수 있습니다 (설정 변경 후 등).

---

## 📂 설치 구성

설치 후 `~/.direnv/` 디렉토리에는 다음 파일들이 포함됩니다:

- `init.sh`: 초기 환경 로더
- `directory_changed_hook.sh`: 디렉토리 이동 후 환경 반응
- `load_current_dir_env.sh`: `.envrc` 또는 `.profile` 로드
- `unload_current_dir_env.sh`: 환경 정리
- `install.sh`: 설치 스크립트 자체 포함

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

# 2. 셸 설정 파일(.bashrc, .zshrc 등)을 편집하여 다음 라인들 제거:
[ -f ~/.direnv/src/init.sh ] && source ~/.direnv/src/init.sh
alias de=". $HOME/.direnv/src/init.sh"
```

---

## 📋 릴리즈 노트

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

