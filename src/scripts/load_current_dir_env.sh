#!/bin/sh

# Permission manager 소싱 (독립 실행 시 필요)
if [ -f ~/.direnv/src/scripts/permission_manager.sh ]; then
  . ~/.direnv/src/scripts/permission_manager.sh
fi

CURRENT_ENV_FILE=~/.direnv/tmp/current_env_file
ORIGINAL_ALIASES_FILE=~/.direnv/tmp/original_environment_aliases
ORIGINAL_VARIABLE_FILE=~/.direnv/tmp/original_environment_variables

# 현재 디렉토리의 환경 설정 파일을 로딩하는 함수입니다.
_load_current_dir_env() {
  loadable=false

  # 현재 디렉토리가 홈 디렉토리인 경우 로딩 중단
  if [ "$PWD" = "$HOME" ]; then
    return 0
  fi

  # 홈 디렉토리 하위가 아니면 로딩 중단
  case "$PWD" in
    "$HOME"/*) ;;  # 통과
    *) return 0 ;; # 홈 밖 → 중단
  esac

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
    ### 명시적 허가 확인 (DIRENV_SKIP_PERMISSION_CHECK=1로 비활성화 가능)
    ###

    if [ "$DIRENV_SKIP_PERMISSION_CHECK" != "1" ]; then
      # 1. denied_dirs 확인
      if _is_denied "$PWD"; then
        # 거부된 디렉토리: 조용히 스킵
        return 0
      fi

      # 2. allowed_dirs 확인
      if ! _is_allowed "$PWD"; then
        # 3. 대화형 프롬프트 (터미널인 경우만)
        if [ -t 0 ]; then
          if ! _prompt_allow_directory "$PWD" "$PWD/$ENV_FILE"; then
            # 사용자가 거부 또는 스킵
            return 0
          fi
        else
          # 비대화형 모드: 조용히 스킵
          return 0
        fi
      fi
    fi

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
      # 값을 작은따옴표로 감싸서 특수문자 문제 방지
      # PWD와 OLDPWD는 제외 (셸 내부 상태이므로 백업/복원하면 안 됨)
      printenv | while IFS='=' read -r name value; do
        # PWD와 OLDPWD 제외
        case "$name" in
          PWD|OLDPWD) continue ;;
        esac

        # 값에 작은따옴표가 있으면 이스케이프 처리
        escaped_value=$(printf '%s' "$value" | sed "s/'/'\\\\''/g")
        case "$name" in
          [a-zA-Z]*) printf "export %s='%s'\n" "$name" "$escaped_value" ;;
          *)
            if [ -z "$value" ]; then
              echo "$name"
            else
              printf "export %s='%s'\n" "$name" "$escaped_value"
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
    alias dl="[ -f \"$CURRENT_ENV_FILE\" ] && cat \"$CURRENT_ENV_FILE\" || printf \"\033[1;32m[direnv]\033[0m 🚫 No environment file is defined for this directory.\n\""
    loadable=false
    ENV_FILE=""
  fi
}
