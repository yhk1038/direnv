#!/bin/sh

CURRENT_ENV_FILE=~/.direnv/tmp/current_env_file
ORIGINAL_ALIASES_FILE=~/.direnv/tmp/original_environment_aliases
ORIGINAL_VARIABLE_FILE=~/.direnv/tmp/original_environment_variables

# 현재 적용된 디렉토리 환경설정을 해제하는 함수입니다.
_unload_current_dir_env() {
  if [ -e "$CURRENT_ENV_FILE" ]; then
    # alias 를 제거
    grep '^alias ' "$CURRENT_ENV_FILE" | sed 's/^alias //' | while IFS='=' read name value; do
      unalias "$name"
    done

    # 환경변수를 제거
    grep '^export ' "$CURRENT_ENV_FILE" | sed 's/^export //' | while IFS='=' read name value; do
      unset "$name"
    done

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
