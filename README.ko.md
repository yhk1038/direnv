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

설치가 완료되면, 셸 재시작 또는 다음 명령으로 설정을 적용할 수 있습니다:

```sh
de
```

> 위 명령은 `alias de=". $HOME/.direnv/init.sh"` 를 통해 등록됩니다.

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

```sh
rm -rf ~/.direnv
unalias de
```

그리고 `.bashrc`, `.zshrc` 등에서 등록된 `alias de=...` 라인이 남아 있다면 필요에 따라 수동으로 제거할 수 있습니다.

---

## 📄 라이선스

MIT License © [yhk1038](https://github.com/yhk1038)

