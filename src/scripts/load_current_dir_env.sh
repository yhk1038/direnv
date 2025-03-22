#!/bin/sh

CURRENT_ENV_FILE=~/.direnv/tmp/current_env_file
ORIGINAL_ALIASES_FILE=~/.direnv/tmp/original_environment_aliases
ORIGINAL_VARIABLE_FILE=~/.direnv/tmp/original_environment_variables

# 현재 디렉토리의 환경 설정 파일을 로딩하는 함수입니다.
_load_current_dir_env() {
  loadable=false

  # .envrc 또는 .profile 이 존재하는지 확인
  if [ -e ./.envrc ]; then
    loadable=true
    ENV_FILE=".envrc"
  fi

  if [ -e ./.profile ]; then
    loadable=true
    ENV_FILE=".profile"
  fi

  if [ "$loadable" = "true" ]; then
    ###
    ### 기존 환경설정을 백업
    ###

    # 백업이 아직 없다면, 기존의 alias 를 백업
    if [ ! -e "$ORIGINAL_ALIASES_FILE" ]; then
      alias | while read line; do
        # 첫 글자가 알파벳인지 확인
        first_char=$(printf "%s" "$line" | cut -c1)
        case "$first_char" in
          [a-zA-Z])
            case "$line" in
              *\'\'\'*) ;;  # 백슬래시가 식별되지 않는 "작은따옴표 + 작은따옴표 + 작은따옴표"가 포함된 경우는 무시
              alias\ *) printf "%s\n" "$line" ;;
              *)        printf "alias %s\n" "$line" ;;
            esac
            ;;
        esac
      done > "$ORIGINAL_ALIASES_FILE"
    fi

    # 백업이 아직 없다면, 기존의 환경변수를 백업
    if [ ! -e "$ORIGINAL_VARIABLE_FILE" ]; then
      # printenv 명령어로 현재 환경 변수들을 순회하여 파일에 직접 작성
      printenv | while IFS='=' read name value; do
        case "$name" in
          [a-zA-Z]*) echo "export $name=$value" ;;
          *)
            if [ -z "$value" ]; then
              echo "$name"
            else
              echo "export $name=$value"
            fi
            ;;
        esac
      done > "$ORIGINAL_VARIABLE_FILE"
    fi

    ###
    ### 현재 디렉토리의 환경설정을 적용
    ###
    . "./$ENV_FILE"

    # 현재 디렉토리의 환경설정을 tmp 에 업로드
    cp "./$ENV_FILE" "$CURRENT_ENV_FILE"
    alias dl="cat $CURRENT_ENV_FILE"
    loadable=false
    ENV_FILE=""
  fi
}

#CURRENT_ENV_FILE=~/.direnv/tmp/current_env_file
#ORIGINAL_ALIASES_FILE=~/.direnv/tmp/original_environment_aliases
#ORIGINAL_VARIABLE_FILE=~/.direnv/tmp/original_environment_variables
#
#function _load_current_dir_env() {
#  loadable=false
#
#  if [ -e ./.envrc ]; then
#    loadable=true
#    ENV_FILE=".envrc"
#  fi
#
#  if [ -e ./.profile ]; then
#    loadable=true
#    ENV_FILE=".profile"
#  fi
#
#  if [[ "$loadable" == "true" ]]; then
#    ###
#    ### 기존 환경설정을 백업
#    ###
#
#    # 백업이 아직 없다면, 기존의 alias 를 백업
#    if ! [ -e $ORIGINAL_ALIASES_FILE ]; then
#      alias | while read -r line; do
#        if [[ "${line:0:1}" =~ [a-zA-Z] ]]; then
#          if [[ "$line" == alias\ * ]]; then
#            echo "$line"
#          else
#            echo "alias $line"
#          fi
#        fi
#      done > $ORIGINAL_ALIASES_FILE
#    fi
#
#    # 백업이 아직 없다면, 기존의 환경변수를 백업
#    if ! [ -e $ORIGINAL_VARIABLE_FILE ]; then
#      # printenv 명령어로 현재 환경 변수들을 순회하여 파일에 직접 작성
#      printenv | while IFS='=' read -r name value
#      do
#          # 첫 번째 글자가 알파벳인지 체크
#          if [[ ! "$name" =~ ^[a-zA-Z] ]]; then
#              if [[ -z "$value" ]]; then
#                  echo "$name"
#              else
#                echo "export $name=$value"
#              fi
#              continue
#          fi
#
#          echo "export $name=$value"
#      done > $ORIGINAL_VARIABLE_FILE
#    fi
#
#    ###
#    ### 현재 디렉토리의 환경설정을 적용
#    ###
#    # 현재 디렉토리의 환경설정을 적용
#    source "./$ENV_FILE"
#
#    # 현재 디렉토리의 환경설정을 tmp 에 업로드
#    cp "./$ENV_FILE" "$CURRENT_ENV_FILE"
#    alias dl="cat $CURRENT_ENV_FILE"
#    loadable=false
#    ENV_FILE=""
#  fi
#}
