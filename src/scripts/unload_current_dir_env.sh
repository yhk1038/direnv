#!/bin/sh

CURRENT_ENV_FILE=~/.direnv/tmp/current_env_file
ORIGINAL_ALIASES_FILE=~/.direnv/tmp/original_environment_aliases
ORIGINAL_VARIABLE_FILE=~/.direnv/tmp/original_environment_variables

# 현재 적용된 디렉토리 환경설정을 해제하는 함수입니다.
_unload_current_dir_env() {
  if [ -e "$CURRENT_ENV_FILE" ]; then
    # alias 를 제거
    # Debug 모드가 아닌 경우 에러 메시지를 억제합니다 (이미 제거된 alias에 대한 에러 방지)
    # 리디렉션 사용으로 서브셸 문제 방지
    # grep이 결과를 찾지 못해도 계속 진행 (|| true)
    ALIASES=$(grep '^alias ' "$CURRENT_ENV_FILE" 2>/dev/null | sed 's/^alias //' || true)
    if [ -n "$ALIASES" ]; then
      while IFS='=' read name value; do
        if [ -n "$name" ]; then
          if [ "$DIRENV_DEBUG" = "1" ]; then
            unalias "$name"
          else
            unalias "$name" 2>/dev/null
          fi
        fi
      done <<EOF
$ALIASES
EOF
    fi

    # 환경변수를 제거
    # Debug 모드가 아닌 경우 에러 메시지를 억제합니다 (이미 제거된 변수에 대한 에러 방지)
    # 리디렉션 사용으로 서브셸 문제 방지
    # grep이 결과를 찾지 못해도 계속 진행 (|| true)
    EXPORTS=$(grep '^export ' "$CURRENT_ENV_FILE" 2>/dev/null | sed 's/^export //' || true)
    if [ -n "$EXPORTS" ]; then
      while IFS='=' read name value; do
        if [ -n "$name" ]; then
          if [ "$DIRENV_DEBUG" = "1" ]; then
            unset "$name"
          else
            unset "$name" 2>/dev/null
          fi
        fi
      done <<EOF
$EXPORTS
EOF
    fi

    # 백업해둔 alias 를 적용 후 성공시 백업파일 제거
    if [ -f "$ORIGINAL_ALIASES_FILE" ]; then
      if . "$ORIGINAL_ALIASES_FILE" 2>/dev/null; then
        rm -f "$ORIGINAL_ALIASES_FILE"
      else
        echo "[direnv] ⚠️ Failed to restore aliases. File kept at: $ORIGINAL_ALIASES_FILE"
      fi
    fi

    # 백업해둔 환경변수 적용 후 성공시 백업파일 제거
    if [ -f "$ORIGINAL_VARIABLE_FILE" ]; then
      if . "$ORIGINAL_VARIABLE_FILE" 2>/dev/null; then
        rm -f "$ORIGINAL_VARIABLE_FILE"
      else
        echo "[direnv] ⚠️ Failed to restore environment variables. File kept at: $ORIGINAL_VARIABLE_FILE"
      fi
    fi

    # current_env_file 제거
    rm -f "$CURRENT_ENV_FILE"
  fi
}
