#!/bin/sh

# ========================================
# Permission Manager
# 명시적 허가 메커니즘
# ========================================

# 파일 경로
DIRENV_ALLOWED_DIRS="$HOME/.direnv/allowed_dirs"
DIRENV_DENIED_DIRS="$HOME/.direnv/denied_dirs"

# 메모리 캐시 (세션 동안 유지)
DIRENV_ALLOWED_CACHE=""
DIRENV_DENIED_CACHE=""

# ========================================
# _is_allowed: 디렉토리가 허가되었는지 확인
# ========================================
_is_allowed() {
  dir_to_check="$1"

  # 캐시 초기화 (첫 호출 시)
  if [ -z "$DIRENV_ALLOWED_CACHE" ] && [ -f "$DIRENV_ALLOWED_DIRS" ]; then
    DIRENV_ALLOWED_CACHE="$(cat "$DIRENV_ALLOWED_DIRS" 2>/dev/null)"
  fi

  # 파일이 없거나 빈 경우
  if [ -z "$DIRENV_ALLOWED_CACHE" ]; then
    return 1
  fi

  # Exact match 확인
  if echo "$DIRENV_ALLOWED_CACHE" | grep -Fxq "exact:$dir_to_check"; then
    return 0
  fi

  # Recursive match 확인 (상위 디렉토리)
  while IFS=: read -r type path; do
    if [ "$type" = "recursive" ]; then
      # dir_to_check이 path로 시작하는지 확인
      case "$dir_to_check" in
        "$path"|"$path"/*)
          return 0
          ;;
      esac
    fi
  done <<EOF
$DIRENV_ALLOWED_CACHE
EOF

  return 1
}

# ========================================
# _is_denied: 디렉토리가 거부되었는지 확인
# ========================================
_is_denied() {
  dir_to_check="$1"

  # 캐시 초기화 (첫 호출 시)
  if [ -z "$DIRENV_DENIED_CACHE" ] && [ -f "$DIRENV_DENIED_DIRS" ]; then
    DIRENV_DENIED_CACHE="$(cat "$DIRENV_DENIED_DIRS" 2>/dev/null)"
  fi

  # 파일이 없거나 빈 경우
  if [ -z "$DIRENV_DENIED_CACHE" ]; then
    return 1
  fi

  # Exact match 확인
  if echo "$DIRENV_DENIED_CACHE" | grep -Fxq "$dir_to_check"; then
    return 0
  fi

  return 1
}

# ========================================
# _add_to_allowed_dirs: allowed_dirs에 디렉토리 추가
# ========================================
_add_to_allowed_dirs() {
  dir_to_add="$1"
  type="${2:-exact}"  # default: exact

  # 디렉토리 생성
  if ! mkdir -p "$(dirname "$DIRENV_ALLOWED_DIRS")" 2>/dev/null; then
    echo "[direnv] ⚠️ Cannot create allowed_dirs file (permission denied)" >&2
    return 1
  fi

  # 파일 생성 (없으면)
  touch "$DIRENV_ALLOWED_DIRS" 2>/dev/null || {
    echo "[direnv] ⚠️ Cannot create allowed_dirs file (permission denied)" >&2
    return 1
  }

  # 중복 확인
  if grep -Fxq "$type:$dir_to_add" "$DIRENV_ALLOWED_DIRS" 2>/dev/null; then
    return 0  # Already exists
  fi

  # 추가
  if ! echo "$type:$dir_to_add" >> "$DIRENV_ALLOWED_DIRS" 2>/dev/null; then
    echo "[direnv] ⚠️ Cannot write to allowed_dirs file (permission denied)" >&2
    return 1
  fi

  # 정렬
  sort -o "$DIRENV_ALLOWED_DIRS" "$DIRENV_ALLOWED_DIRS" 2>/dev/null || true

  # 캐시 무효화 (다음 호출 시 다시 로드)
  DIRENV_ALLOWED_CACHE=""

  return 0
}

# ========================================
# _add_to_denied_dirs: denied_dirs에 디렉토리 추가
# ========================================
_add_to_denied_dirs() {
  dir_to_add="$1"

  # 디렉토리 생성
  if ! mkdir -p "$(dirname "$DIRENV_DENIED_DIRS")" 2>/dev/null; then
    echo "[direnv] ⚠️ Cannot create denied_dirs file (permission denied)" >&2
    return 1
  fi

  # 파일 생성 (없으면)
  touch "$DIRENV_DENIED_DIRS" 2>/dev/null || {
    echo "[direnv] ⚠️ Cannot create denied_dirs file (permission denied)" >&2
    return 1
  }

  # 중복 확인
  if grep -Fxq "$dir_to_add" "$DIRENV_DENIED_DIRS" 2>/dev/null; then
    return 0  # Already exists
  fi

  # 추가
  if ! echo "$dir_to_add" >> "$DIRENV_DENIED_DIRS" 2>/dev/null; then
    echo "[direnv] ⚠️ Cannot write to denied_dirs file (permission denied)" >&2
    return 1
  fi

  # 정렬
  sort -o "$DIRENV_DENIED_DIRS" "$DIRENV_DENIED_DIRS" 2>/dev/null || true

  # 캐시 무효화
  DIRENV_DENIED_CACHE=""

  return 0
}

# ========================================
# _prompt_allow_directory: 대화형 허가 프롬프트
# ========================================
_prompt_allow_directory() {
  current_dir="$1"
  env_file="$2"

  # 비대화형 모드 체크
  if [ ! -t 0 ]; then
    # stdin이 터미널이 아님 (스크립트 내부에서 실행)
    return 1
  fi

  # 프롬프트 표시
  echo ""
  echo "⚠️  Direnv configuration detected but not approved yet."
  echo "📄 File: $env_file"
  echo ""

  # POSIX select 사용
  PS3="Select an option (1-5): "
  select choice in \
    "Allow and load (this directory only)" \
    "Allow permanently (all subdirectories)" \
    "View file content first" \
    "Deny (don't ask again)" \
    "Skip (ask again next time)"; do

    case "$choice" in
      "Allow and load"*)
        _add_to_allowed_dirs "$current_dir" "exact"
        echo "✅ Directory approved (exact match): $current_dir"
        return 0
        ;;
      "Allow permanently"*)
        _add_to_allowed_dirs "$current_dir" "recursive"
        echo "✅ Directory approved (including subdirectories): $current_dir"
        return 0
        ;;
      "View file content"*)
        echo ""
        echo "--- File content: $env_file ---"
        cat "$env_file" 2>/dev/null || echo "❌ Cannot read file"
        echo "--- End of file ---"
        echo ""
        echo "Press Enter to return to menu..."
        read dummy
        # Recursive call to show menu again
        _prompt_allow_directory "$current_dir" "$env_file"
        return $?
        ;;
      "Deny"*)
        _add_to_denied_dirs "$current_dir"
        echo "🚫 Directory permanently denied: $current_dir"
        return 1
        ;;
      "Skip"*)
        echo "⏭️  Skipped. Will ask again next time."
        return 1
        ;;
      *)
        echo "❌ Invalid option. Please select 1-5."
        ;;
    esac
  done
}
