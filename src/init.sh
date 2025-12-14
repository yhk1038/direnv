#!/bin/sh

# Source scripts with error handling
_direnv_source() {
  if [ -f "$1" ]; then
    . "$1"
  else
    echo "[direnv] ⚠️  Missing file: $1" >&2
  fi
}

_direnv_source ~/.direnv/src/scripts/detect-language.sh
_direnv_source ~/.direnv/src/scripts/load_current_dir_env.sh
_direnv_source ~/.direnv/src/scripts/unload_current_dir_env.sh
_direnv_source ~/.direnv/src/scripts/directory_changed_hook.sh
_direnv_source ~/.direnv/src/scripts/de_command.sh

# Fallback: define _directory_changed_hook if not defined (prevents "command not found")
if ! type _directory_changed_hook >/dev/null 2>&1; then
  _directory_changed_hook() {
    _unload_current_dir_env 2>/dev/null
    _load_current_dir_env 2>/dev/null
  }
fi

# tmp 디렉토리가 없다면 생성합니다.
if [ ! -d ~/.direnv/tmp ]; then
  mkdir ~/.direnv/tmp
fi

# tmp 디렉토리 내부 파일을 모두 삭제하는 alias 추가
alias df='rm -f ~/.direnv/tmp/*'

# 비활성화 상태가 아닐 때만 환경 로딩 및 훅 설정
if [ "$DIRENV_DISABLED" != "1" ]; then
  # 디렉토리 진입 시 환경설정 적용
  _load_current_dir_env

  # cd 명령어 후 디렉토리 변경 감지 시 후크 실행
  cd() {
    builtin cd "$@" || return
    [ "$OLDPWD" != "$PWD" ] && _directory_changed_hook
  }
else
  # 비활성화 상태에서는 기본 cd만 사용
  cd() {
    builtin cd "$@"
  }
fi
