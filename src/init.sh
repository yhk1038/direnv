#!/bin/sh

. ~/.direnv/src/scripts/detect-language.sh
. ~/.direnv/src/scripts/load_current_dir_env.sh
. ~/.direnv/src/scripts/unload_current_dir_env.sh
. ~/.direnv/src/scripts/directory_changed_hook.sh
. ~/.direnv/src/scripts/de_command.sh

# tmp 디렉토리가 없다면 생성합니다.
if [ ! -d ~/.direnv/tmp ]; then
  mkdir ~/.direnv/tmp
fi

# tmp 디렉토리 내부 파일을 모두 삭제하는 alias 추가
alias df='rm -f ~/.direnv/tmp/*'

# 디렉토리 진입 시 환경설정 적용
_load_current_dir_env

# cd 명령어 후 디렉토리 변경 감지 시 후크 실행
cd() {
  builtin cd "$@" || return
  [ "$OLDPWD" != "$PWD" ] && _directory_changed_hook
}

# directory_changed_hook.sh
# 디렉토리가 변경되었을 때 환경을 재적용합니다.
_directory_changed_hook() {
  # 기존에 로딩되어있는 환경파일이 있다면 등록해제 합니다.
  _unload_current_dir_env

  # 만약 도착한 경로에도 환경파일이 있다면 등록합니다.
  _load_current_dir_env
}
