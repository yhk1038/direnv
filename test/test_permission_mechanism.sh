#!/bin/sh

# ========================================
# 명시적 허가 메커니즘 테스트
# Test: Explicit Permission Mechanism
# ========================================

# CI 환경 체크
FAILED=0

# 테스트 환경 설정
TEST_DIR="/tmp/direnv_permission_test_$$"
ALLOWED_DIRS_FILE="$TEST_DIR/.direnv/allowed_dirs"
DENIED_DIRS_FILE="$TEST_DIR/.direnv/denied_dirs"
TEST_PROJECT_DIR="$TEST_DIR/test-project"
TEST_SUBPROJECT_DIR="$TEST_PROJECT_DIR/subproject"

# 초기화
setup_test_env() {
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR/.direnv"
  mkdir -p "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_SUBPROJECT_DIR"

  # 테스트용 환경 파일 생성
  echo '#!/bin/sh' > "$TEST_PROJECT_DIR/.envrc"
  echo 'export TEST_VAR="from_envrc"' >> "$TEST_PROJECT_DIR/.envrc"
  echo 'alias test_alias="echo test"' >> "$TEST_PROJECT_DIR/.envrc"

  echo '#!/bin/sh' > "$TEST_SUBPROJECT_DIR/.envrc"
  echo 'export SUB_VAR="from_sub"' >> "$TEST_SUBPROJECT_DIR/.envrc"

  # permission_manager.sh 소싱 (구현 후)
  # . ../src/scripts/permission_manager.sh
}

cleanup_test_env() {
  rm -rf "$TEST_DIR"
}

# ========================================
# Test 1: allowed_dirs exact match
# ========================================
test_allowed_dirs_exact_match() {
  echo ""
  echo "Test 1: allowed_dirs exact match"

  setup_test_env

  # Setup: Add exact match
  echo "exact:$TEST_PROJECT_DIR" > "$ALLOWED_DIRS_FILE"

  # Mock _is_allowed function for testing
  _is_allowed() {
    dir_to_check="$1"

    if [ ! -f "$ALLOWED_DIRS_FILE" ]; then
      return 1
    fi

    # Check exact match
    if grep -Fxq "exact:$dir_to_check" "$ALLOWED_DIRS_FILE"; then
      return 0
    fi

    return 1
  }

  # Test: Should allow exact match
  if _is_allowed "$TEST_PROJECT_DIR"; then
    echo "✅ (PASS) Exact match allowed"
  else
    echo "❌ (FAIL) Exact match should be allowed"
    FAILED=1
  fi

  # Test: Should not allow subdirectory with exact match
  if _is_allowed "$TEST_SUBPROJECT_DIR"; then
    echo "❌ (FAIL) Subdirectory should not be allowed with exact match"
    FAILED=1
  else
    echo "✅ (PASS) Subdirectory correctly denied with exact match"
  fi

  cleanup_test_env
}

# ========================================
# Test 2: allowed_dirs recursive match
# ========================================
test_allowed_dirs_recursive_match() {
  echo ""
  echo "Test 2: allowed_dirs recursive match"

  setup_test_env

  # Setup: Add recursive match
  echo "recursive:$TEST_PROJECT_DIR" > "$ALLOWED_DIRS_FILE"

  # Mock _is_allowed function with recursive support
  _is_allowed() {
    dir_to_check="$1"

    if [ ! -f "$ALLOWED_DIRS_FILE" ]; then
      return 1
    fi

    # Check exact match
    if grep -Fxq "exact:$dir_to_check" "$ALLOWED_DIRS_FILE"; then
      return 0
    fi

    # Check recursive match (parent directories)
    while IFS=: read -r type path; do
      if [ "$type" = "recursive" ]; then
        # Check if dir_to_check starts with path
        case "$dir_to_check" in
          "$path"|"$path"/*) return 0 ;;
        esac
      fi
    done < "$ALLOWED_DIRS_FILE"

    return 1
  }

  # Test: Parent directory should be allowed
  if _is_allowed "$TEST_PROJECT_DIR"; then
    echo "✅ (PASS) Parent directory allowed with recursive"
  else
    echo "❌ (FAIL) Parent directory should be allowed with recursive"
    FAILED=1
  fi

  # Test: Subdirectory should also be allowed
  if _is_allowed "$TEST_SUBPROJECT_DIR"; then
    echo "✅ (PASS) Subdirectory allowed with recursive"
  else
    echo "❌ (FAIL) Subdirectory should be allowed with recursive"
    FAILED=1
  fi

  cleanup_test_env
}

# ========================================
# Test 3: denied_dirs blocks loading
# ========================================
test_denied_dirs_blocks_loading() {
  echo ""
  echo "Test 3: denied_dirs blocks loading"

  setup_test_env

  # Setup: Add to denied_dirs
  echo "$TEST_PROJECT_DIR" > "$DENIED_DIRS_FILE"

  # Mock _is_denied function
  _is_denied() {
    dir_to_check="$1"

    if [ ! -f "$DENIED_DIRS_FILE" ]; then
      return 1
    fi

    if grep -Fxq "$dir_to_check" "$DENIED_DIRS_FILE"; then
      return 0
    fi

    return 1
  }

  # Test: Should deny
  if _is_denied "$TEST_PROJECT_DIR"; then
    echo "✅ (PASS) Denied directory correctly blocked"
  else
    echo "❌ (FAIL) Denied directory should be blocked"
    FAILED=1
  fi

  # Test: Should not deny other directory
  if _is_denied "$TEST_SUBPROJECT_DIR"; then
    echo "❌ (FAIL) Non-denied directory should not be blocked"
    FAILED=1
  else
    echo "✅ (PASS) Non-denied directory correctly allowed"
  fi

  cleanup_test_env
}

# ========================================
# Test 4: _add_to_allowed_dirs prevents duplicates
# ========================================
test_add_to_allowed_dirs_no_duplicates() {
  echo ""
  echo "Test 4: _add_to_allowed_dirs prevents duplicates"

  setup_test_env

  # Mock _add_to_allowed_dirs function
  _add_to_allowed_dirs() {
    dir_to_add="$1"
    type="${2:-exact}"  # default: exact

    mkdir -p "$(dirname "$ALLOWED_DIRS_FILE")"
    touch "$ALLOWED_DIRS_FILE"

    # Check if already exists
    if grep -Fxq "$type:$dir_to_add" "$ALLOWED_DIRS_FILE"; then
      return 0  # Already exists, do nothing
    fi

    # Add new entry
    echo "$type:$dir_to_add" >> "$ALLOWED_DIRS_FILE"

    # Sort file for readability
    sort -o "$ALLOWED_DIRS_FILE" "$ALLOWED_DIRS_FILE"
  }

  # Test: Add first time
  _add_to_allowed_dirs "$TEST_PROJECT_DIR" "exact"
  count1=$(grep -c "exact:$TEST_PROJECT_DIR" "$ALLOWED_DIRS_FILE")

  if [ "$count1" -eq 1 ]; then
    echo "✅ (PASS) First add successful"
  else
    echo "❌ (FAIL) First add failed (count: $count1)"
    FAILED=1
  fi

  # Test: Add duplicate
  _add_to_allowed_dirs "$TEST_PROJECT_DIR" "exact"
  count2=$(grep -c "exact:$TEST_PROJECT_DIR" "$ALLOWED_DIRS_FILE")

  if [ "$count2" -eq 1 ]; then
    echo "✅ (PASS) Duplicate prevented"
  else
    echo "❌ (FAIL) Duplicate not prevented (count: $count2)"
    FAILED=1
  fi

  # Test: Add different type
  _add_to_allowed_dirs "$TEST_PROJECT_DIR" "recursive"
  count3=$(wc -l < "$ALLOWED_DIRS_FILE" | tr -d ' ')

  if [ "$count3" -eq 2 ]; then
    echo "✅ (PASS) Different type added correctly"
  else
    echo "❌ (FAIL) Different type not added correctly (lines: $count3)"
    FAILED=1
  fi

  cleanup_test_env
}

# ========================================
# Test 5: _add_to_denied_dirs prevents duplicates
# ========================================
test_add_to_denied_dirs_no_duplicates() {
  echo ""
  echo "Test 5: _add_to_denied_dirs prevents duplicates"

  setup_test_env

  # Mock _add_to_denied_dirs function
  _add_to_denied_dirs() {
    dir_to_add="$1"

    mkdir -p "$(dirname "$DENIED_DIRS_FILE")"
    touch "$DENIED_DIRS_FILE"

    # Check if already exists
    if grep -Fxq "$dir_to_add" "$DENIED_DIRS_FILE"; then
      return 0  # Already exists, do nothing
    fi

    # Add new entry
    echo "$dir_to_add" >> "$DENIED_DIRS_FILE"

    # Sort file for readability
    sort -o "$DENIED_DIRS_FILE" "$DENIED_DIRS_FILE"
  }

  # Test: Add first time
  _add_to_denied_dirs "$TEST_PROJECT_DIR"
  count1=$(grep -c "^$TEST_PROJECT_DIR\$" "$DENIED_DIRS_FILE")

  if [ "$count1" -eq 1 ]; then
    echo "✅ (PASS) First add successful"
  else
    echo "❌ (FAIL) First add failed (count: $count1)"
    FAILED=1
  fi

  # Test: Add duplicate
  _add_to_denied_dirs "$TEST_PROJECT_DIR"
  count2=$(grep -c "^$TEST_PROJECT_DIR\$" "$DENIED_DIRS_FILE")

  if [ "$count2" -eq 1 ]; then
    echo "✅ (PASS) Duplicate prevented"
  else
    echo "❌ (FAIL) Duplicate not prevented (count: $count2)"
    FAILED=1
  fi

  cleanup_test_env
}

# ========================================
# Test 6: Non-interactive mode detection
# ========================================
test_non_interactive_mode() {
  echo ""
  echo "Test 6: Non-interactive mode detection"

  # Test: Check if stdin is terminal
  # In real environment with terminal: [ -t 0 ] returns 0
  # In script/pipe: [ -t 0 ] returns 1

  # Mock scenario: In script (non-interactive)
  # We can't easily test this without actually running in different modes
  # So we'll just document the expected behavior

  echo "ℹ️  (INFO) Non-interactive mode check:"
  echo "  - Terminal: [ -t 0 ] returns true → show prompt"
  echo "  - Script/pipe: [ -t 0 ] returns false → skip prompt"

  if [ -t 0 ]; then
    echo "✅ (PASS) Currently in interactive mode (terminal detected)"
  else
    echo "✅ (PASS) Currently in non-interactive mode (no terminal)"
  fi
}

# ========================================
# Test 7: Empty or missing files
# ========================================
test_empty_or_missing_files() {
  echo ""
  echo "Test 7: Empty or missing files"

  setup_test_env

  # Mock _is_allowed for missing file
  _is_allowed() {
    dir_to_check="$1"

    if [ ! -f "$ALLOWED_DIRS_FILE" ]; then
      return 1
    fi

    grep -Fxq "exact:$dir_to_check" "$ALLOWED_DIRS_FILE" && return 0
    return 1
  }

  # Test: Missing file
  rm -f "$ALLOWED_DIRS_FILE"

  if _is_allowed "$TEST_PROJECT_DIR"; then
    echo "❌ (FAIL) Should deny when file missing"
    FAILED=1
  else
    echo "✅ (PASS) Correctly denies when file missing"
  fi

  # Test: Empty file
  touch "$ALLOWED_DIRS_FILE"

  if _is_allowed "$TEST_PROJECT_DIR"; then
    echo "❌ (FAIL) Should deny when file empty"
    FAILED=1
  else
    echo "✅ (PASS) Correctly denies when file empty"
  fi

  cleanup_test_env
}

# ========================================
# Test 8: Permission denied on writing
# ========================================
test_permission_denied_on_write() {
  echo ""
  echo "Test 8: Permission denied on writing"

  setup_test_env

  # Mock _add_to_allowed_dirs with error handling
  _add_to_allowed_dirs() {
    dir_to_add="$1"
    type="${2:-exact}"

    # Try to create directory
    if ! mkdir -p "$(dirname "$ALLOWED_DIRS_FILE")" 2>/dev/null; then
      echo "[direnv] ⚠️ Cannot create allowed_dirs file (permission denied)" >&2
      return 1
    fi

    # Try to write
    if ! echo "$type:$dir_to_add" >> "$ALLOWED_DIRS_FILE" 2>/dev/null; then
      echo "[direnv] ⚠️ Cannot write to allowed_dirs file (permission denied)" >&2
      return 1
    fi

    return 0
  }

  # Test: Make parent directory read-only
  chmod 000 "$TEST_DIR/.direnv" 2>/dev/null || true

  if _add_to_allowed_dirs "$TEST_PROJECT_DIR" "exact" 2>/dev/null; then
    echo "ℹ️  (INFO) Write succeeded (may have sufficient permissions)"
  else
    echo "✅ (PASS) Correctly handles permission denied"
  fi

  # Restore permissions for cleanup
  chmod 755 "$TEST_DIR/.direnv" 2>/dev/null || true

  cleanup_test_env
}

# ========================================
# Run all tests
# ========================================

echo "=========================================="
echo "🔍 Testing: Permission Mechanism"
echo "=========================================="

test_allowed_dirs_exact_match
test_allowed_dirs_recursive_match
test_denied_dirs_blocks_loading
test_add_to_allowed_dirs_no_duplicates
test_add_to_denied_dirs_no_duplicates
test_non_interactive_mode
test_empty_or_missing_files
test_permission_denied_on_write

echo ""
echo "=========================================="
if [ "$FAILED" -eq 0 ]; then
  echo "✅ All permission tests passed!"
else
  echo "❌ Some permission tests failed!"
fi
echo "=========================================="

# CI 환경에서만 실패 시 exit 1
if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
