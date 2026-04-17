#!/bin/sh
#
# Tests for PATH safety during unload
#
# BUG: When .envrc exports PATH, unload does `unset PATH` before calling
# external commands (rm, etc.), causing "command not found" errors and
# leaving residual backup files.
#
# These tests verify:
# 1. External commands work during unload even when PATH was exported in .envrc
# 2. All backup files are cleaned up (no residual files)
# 3. Cross-project contamination doesn't occur from residual files
#

FAILED=0
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Source all required scripts
. "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
. "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
. "$SCRIPT_DIR/src/scripts/directory_changed_hook.sh"

# Save original cd
_original_cd() {
  command cd "$@"
}

# Override cd with hook
cd() {
  _original_cd "$@" || return
  [ "$OLDPWD" != "$PWD" ] && _directory_changed_hook
}

###############################################################################
# Test 1: Unload produces no errors when .envrc exports PATH
###############################################################################
test_unload_no_errors_with_path_export() {
  printf "\n  TEST 1: Unload produces no errors when .envrc exports PATH\n"

  mkdir -p ~/.direnv/tmp
  rm -f ~/.direnv/tmp/*

  TEST_DIR="$HOME/tmp/direnv-test-path-$$"
  mkdir -p "$TEST_DIR"
  _original_cd "$TEST_DIR"

  # .envrc that exports PATH (like cocomate)
  cat > .envrc <<'ENVRC'
export MY_CUSTOM_VAR="hello"
export PATH="/some/custom/path:$PATH"
ENVRC

  _load_current_dir_env

  # Capture ALL output (stdout + stderr) from unload
  ERROR_OUTPUT=$(_unload_current_dir_env 2>&1)

  if echo "$ERROR_OUTPUT" | grep -q "command not found"; then
    printf "  ❌ FAIL: 'command not found' error during unload\n"
    printf "    Output: %s\n" "$ERROR_OUTPUT"
    FAILED=1
  else
    printf "  ✅ PASS: No 'command not found' errors\n"
  fi

  # Cleanup
  _original_cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 2: All backup files are cleaned up after unload with PATH export
###############################################################################
test_no_residual_files_with_path_export() {
  printf "\n  TEST 2: All backup files cleaned up after unload (PATH export case)\n"

  mkdir -p ~/.direnv/tmp
  rm -f ~/.direnv/tmp/*

  TEST_DIR="$HOME/tmp/direnv-test-path-$$"
  mkdir -p "$TEST_DIR"
  _original_cd "$TEST_DIR"

  cat > .envrc <<'ENVRC'
export PATH="/some/custom/path:$PATH"
alias my_test_alias='echo test'
ENVRC

  _load_current_dir_env

  # Verify backups were created
  if [ ! -f ~/.direnv/tmp/original_environment_aliases ] || \
     [ ! -f ~/.direnv/tmp/original_environment_variables ]; then
    printf "  ❌ FAIL: Backup files not created (setup issue)\n"
    FAILED=1
    _original_cd; rm -rf "$TEST_DIR"; rm -f ~/.direnv/tmp/*
    return
  fi

  # Unload (suppress output for this test)
  _unload_current_dir_env 2>/dev/null

  # Check: ALL tmp files should be gone
  RESIDUAL=$(ls ~/.direnv/tmp/ 2>/dev/null | wc -l | tr -d ' ')
  if [ "$RESIDUAL" != "0" ]; then
    printf "  ❌ FAIL: Residual files remain after unload\n"
    ls -la ~/.direnv/tmp/ | sed 's/^/    /'
    FAILED=1
  else
    printf "  ✅ PASS: All backup files cleaned up\n"
  fi

  # Cleanup
  _original_cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 3: PATH is fully restored after unload
###############################################################################
test_path_restored_after_unload() {
  printf "\n  TEST 3: PATH is fully restored after unload\n"

  mkdir -p ~/.direnv/tmp
  rm -f ~/.direnv/tmp/*

  TEST_DIR="$HOME/tmp/direnv-test-path-$$"
  mkdir -p "$TEST_DIR"
  _original_cd "$TEST_DIR"

  # Save original PATH before any load
  ORIGINAL_PATH="$PATH"

  cat > .envrc <<'ENVRC'
export PATH="/some/custom/path:$PATH"
ENVRC

  _load_current_dir_env
  _unload_current_dir_env 2>/dev/null

  if [ "$PATH" = "$ORIGINAL_PATH" ]; then
    printf "  ✅ PASS: PATH restored to original value\n"
  else
    printf "  ❌ FAIL: PATH not restored\n"
    printf "    Expected length: %s\n" "${#ORIGINAL_PATH}"
    printf "    Actual length:   %s\n" "${#PATH}"
    FAILED=1
  fi

  # Cleanup
  _original_cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 4: cd from envrc-dir to subdirectory produces no errors
###############################################################################
test_cd_to_subdir_no_errors() {
  printf "\n  TEST 4: cd from .envrc dir to subdirectory produces no errors\n"

  mkdir -p ~/.direnv/tmp
  rm -f ~/.direnv/tmp/*

  TEST_DIR="$HOME/tmp/direnv-test-path-$$"
  SUBDIR="$TEST_DIR/subdir"
  mkdir -p "$SUBDIR"

  _original_cd "$TEST_DIR"

  cat > .envrc <<'ENVRC'
export PATH="/some/custom/path:$PATH"
export MY_VAR="hello"
alias my_alias='echo test'
ENVRC

  _load_current_dir_env

  # cd to subdirectory (no .envrc) — simulates "cd api"
  ERROR_OUTPUT=$(cd "$SUBDIR" 2>&1)

  if echo "$ERROR_OUTPUT" | grep -q "command not found"; then
    printf "  ❌ FAIL: 'command not found' error during cd to subdir\n"
    printf "    Output: %s\n" "$ERROR_OUTPUT"
    FAILED=1
  else
    printf "  ✅ PASS: No errors when cd to subdirectory\n"
  fi

  # Cleanup
  _original_cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
  unset MY_VAR
}

###############################################################################
# Test 5: No cross-project contamination from residual files
###############################################################################
test_no_cross_project_contamination() {
  printf "\n  TEST 5: No cross-project contamination from residual backup files\n"

  mkdir -p ~/.direnv/tmp
  rm -f ~/.direnv/tmp/*

  # Project A (exports PATH)
  PROJECT_A="$HOME/tmp/direnv-test-projA-$$"
  PROJECT_A_SUB="$PROJECT_A/api"
  mkdir -p "$PROJECT_A_SUB"

  # Project B (no PATH export)
  PROJECT_B="$HOME/tmp/direnv-test-projB-$$"
  PROJECT_B_SUB="$PROJECT_B/backend"
  mkdir -p "$PROJECT_B_SUB"

  # Project A .envrc
  cat > "$PROJECT_A/.envrc" <<'ENVRC'
export PATH="/project-a/bin:$PATH"
alias proj_a_alias='echo projA'
ENVRC

  # Project B .envrc
  cat > "$PROJECT_B/.envrc" <<'ENVRC'
export PROJ_B_VAR="projB"
alias proj_b_alias='echo projB'
ENVRC

  # Simulate: enter project A → cd to subdir (triggers unload)
  _original_cd "$PROJECT_A"
  _load_current_dir_env
  cd "$PROJECT_A_SUB" 2>/dev/null

  # Now enter project B
  cd "$PROJECT_B" 2>/dev/null

  # Verify project B's alias is loaded
  if alias proj_b_alias 2>/dev/null | grep -q "projB"; then
    printf "  ✅ PASS: Project B alias loaded correctly\n"
  else
    printf "  ❌ FAIL: Project B alias not loaded\n"
    FAILED=1
  fi

  # cd to project B subdir (unload project B)
  cd "$PROJECT_B_SUB" 2>/dev/null

  # Verify project B's alias is properly restored (not project A's)
  # After unload, proj_b_alias should NOT exist (it was from .envrc)
  # But the original aliases from before project B should be restored
  if alias proj_a_alias 2>/dev/null | grep -q "projA"; then
    printf "  ❌ FAIL: Project A alias leaked into Project B's restore\n"
    FAILED=1
  else
    printf "  ✅ PASS: No cross-project alias contamination\n"
  fi

  # Cleanup
  _original_cd
  rm -rf "$PROJECT_A" "$PROJECT_B"
  rm -f ~/.direnv/tmp/*
  unset PROJ_B_VAR
  unalias proj_a_alias 2>/dev/null
  unalias proj_b_alias 2>/dev/null
}

###############################################################################
# Main Execution
###############################################################################

echo "========================================"
echo "PATH Safety During Unload Tests"
echo "========================================"
echo ""
echo "Testing that unload works safely when .envrc exports PATH"

test_unload_no_errors_with_path_export
test_no_residual_files_with_path_export
test_path_restored_after_unload
test_cd_to_subdir_no_errors
test_no_cross_project_contamination

echo ""
echo "========================================"
if [ "$FAILED" -eq 0 ]; then
  printf "✅ All PATH safety tests passed!\n"
else
  printf "❌ Some PATH safety tests failed.\n"
fi
echo "========================================"

# CI mode: exit with failure code
if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
