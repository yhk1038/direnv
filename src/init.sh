#!/bin/sh

. ~/.direnv/scripts/load_current_dir_env.sh
. ~/.direnv/scripts/unload_current_dir_env.sh
. ~/.direnv/scripts/directory_changed_hook.sh

# tmp 디렉토리가 없다면 생성합니다.
if [ ! -d ~/.direnv/tmp ]; then
  mkdir ~/.direnv/tmp
fi

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

#source ~/.direnv/src/load_current_dir_env.sh
#source ~/.direnv/src/unload_current_dir_env.sh
#source ~/.direnv/src/directory_changed_hook.sh
#
#if [ ! -d ~/.direnv/tmp ]; then
#  mkdir ~/.direnv/tmp
#fi
#
#_load_current_dir_env
#
#cd() {
#  builtin cd "$@" || return
#  [ "$OLDPWD" = "$PWD" ] || _directory_changed_hook
#}
