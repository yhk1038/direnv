#!/bin/sh
#
# Comprehensive tests for environment unloading mechanism
#
# This test suite verifies that direnv properly unloads environment
# and restores the original state when leaving a directory.
#
# CRITICAL: Incomplete unloading can pollute the user's shell environment!
#

FAILED=0
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

###############################################################################
# Test 1: Aliases from .envrc are removed
###############################################################################
test_alias_removal() {
  printf "\n✅ TEST 1: Aliases defined in .envrc are removed on unload\n"

  # Ensure ~/.direnv/tmp directory exists (required for tests)
  mkdir -p ~/.direnv/tmp

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create .envrc with alias
  echo "alias test_project_alias='echo project'" > .envrc

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Verify alias is set
  if alias test_project_alias 2>/dev/null | grep -q "test_project_alias"; then
    printf "  ✓ Alias was loaded\n"
  else
    printf "  ❌ FAIL: Alias was not loaded (setup issue)\n"
    FAILED=1
  fi

  # Unload
  . "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
  _unload_current_dir_env

  # Verify alias is removed
  if alias test_project_alias 2>/dev/null | grep -q "test_project_alias"; then
    printf "  ❌ FAIL: Alias was not removed\n"
    FAILED=1
  else
    printf "  ✓ Alias was removed\n"
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 2: Environment variables from .envrc are removed
###############################################################################
test_env_var_removal() {
  printf "\n✅ TEST 2: Environment variables defined in .envrc are removed on unload\n"

  # Ensure ~/.direnv/tmp directory exists (required for tests)
  mkdir -p ~/.direnv/tmp

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create .envrc with env var
  echo "export TEST_PROJECT_VAR='project_value'" > .envrc

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Verify env var is set
  if [ "$TEST_PROJECT_VAR" = "project_value" ]; then
    printf "  ✓ Environment variable was loaded\n"
  else
    printf "  ❌ FAIL: Environment variable was not loaded (setup issue)\n"
    FAILED=1
  fi

  # Unload
  . "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
  _unload_current_dir_env

  # Verify env var is removed
  if [ -z "$TEST_PROJECT_VAR" ]; then
    printf "  ✓ Environment variable was removed\n"
  else
    printf "  ❌ FAIL: Environment variable was not removed (value: %s)\n" "$TEST_PROJECT_VAR"
    FAILED=1
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 3: Original aliases are restored
###############################################################################
test_alias_restoration() {
  printf "\n✅ TEST 3: Original aliases are restored on unload\n"

  # Ensure ~/.direnv/tmp directory exists (required for tests)
  mkdir -p ~/.direnv/tmp

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Set original alias
  alias original_test_alias='echo original'

  # Create .envrc with different alias
  echo "alias original_test_alias='echo project'" > .envrc

  # Load (this backs up original_test_alias)
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Verify project alias is active
  if alias original_test_alias 2>/dev/null | grep -q "project"; then
    printf "  ✓ Project alias was loaded\n"
  else
    printf "  ❌ FAIL: Project alias was not loaded (setup issue)\n"
    FAILED=1
  fi

  # Unload
  . "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
  _unload_current_dir_env

  # Verify original alias is restored
  if alias original_test_alias 2>/dev/null | grep -q "original"; then
    printf "  ✓ Original alias was restored\n"
  else
    printf "  ❌ FAIL: Original alias was not restored\n"
    alias original_test_alias 2>&1 | sed 's/^/    /'
    FAILED=1
  fi

  # Cleanup
  unalias original_test_alias 2>/dev/null
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 4: Original environment variables are restored
###############################################################################
test_env_var_restoration() {
  printf "\n✅ TEST 4: Original environment variables are restored on unload\n"

  # Ensure ~/.direnv/tmp directory exists (required for tests)
  mkdir -p ~/.direnv/tmp

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Set original env var
  export ORIGINAL_TEST_VAR='original_value'

  # Create .envrc with different value
  echo "export ORIGINAL_TEST_VAR='project_value'" > .envrc

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Verify project value is active
  if [ "$ORIGINAL_TEST_VAR" = "project_value" ]; then
    printf "  ✓ Project value was loaded\n"
  else
    printf "  ❌ FAIL: Project value was not loaded (value: %s)\n" "$ORIGINAL_TEST_VAR"
    FAILED=1
  fi

  # Unload
  . "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
  _unload_current_dir_env

  # Verify original value is restored
  if [ "$ORIGINAL_TEST_VAR" = "original_value" ]; then
    printf "  ✓ Original value was restored\n"
  else
    printf "  ❌ FAIL: Original value was not restored (value: %s)\n" "$ORIGINAL_TEST_VAR"
    FAILED=1
  fi

  # Cleanup
  unset ORIGINAL_TEST_VAR
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 5: Backup files are deleted after successful restore
###############################################################################
test_backup_cleanup() {
  printf "\n✅ TEST 5: Backup files are deleted after successful restore\n"

  # Ensure ~/.direnv/tmp directory exists (required for tests)
  mkdir -p ~/.direnv/tmp

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create .envrc
  echo "export TEST=1" > .envrc
  echo "alias test_alias='echo test'" >> .envrc

  # Load (creates backups)
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Verify backups exist
  if [ -f ~/.direnv/tmp/original_environment_aliases ] && \
     [ -f ~/.direnv/tmp/original_environment_variables ]; then
    printf "  ✓ Backup files were created\n"
  else
    printf "  ❌ FAIL: Backup files were not created (setup issue)\n"
    FAILED=1
  fi

  # Unload
  . "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
  _unload_current_dir_env

  # Verify backups are deleted
  if [ ! -f ~/.direnv/tmp/original_environment_aliases ] && \
     [ ! -f ~/.direnv/tmp/original_environment_variables ]; then
    printf "  ✓ Backup files were deleted after restore\n"
  else
    printf "  ❌ FAIL: Backup files were not deleted\n"
    ls -la ~/.direnv/tmp/ | sed 's/^/    /'
    FAILED=1
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 6: Current env file is deleted on unload
###############################################################################
test_current_env_cleanup() {
  printf "\n✅ TEST 6: Current env file is deleted on unload\n"

  # Ensure ~/.direnv/tmp directory exists (required for tests)
  mkdir -p ~/.direnv/tmp

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create .envrc
  echo "export TEST=1" > .envrc

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Verify current env file exists
  if [ -f ~/.direnv/tmp/current_env_file ]; then
    printf "  ✓ Current env file was created\n"
  else
    printf "  ❌ FAIL: Current env file was not created (setup issue)\n"
    FAILED=1
  fi

  # Unload
  . "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
  _unload_current_dir_env

  # Verify current env file is deleted
  if [ ! -f ~/.direnv/tmp/current_env_file ]; then
    printf "  ✓ Current env file was deleted\n"
  else
    printf "  ❌ FAIL: Current env file was not deleted\n"
    FAILED=1
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 7: No error output in normal mode (2>/dev/null)
###############################################################################
test_error_suppression() {
  printf "\n✅ TEST 7: Error output is suppressed in normal mode\n"

  # Ensure ~/.direnv/tmp directory exists (required for tests)
  mkdir -p ~/.direnv/tmp

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create .envrc
  echo "export TEST=1" > .envrc

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Unload without DIRENV_DEBUG (should produce no error output)
  . "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
  ERROR_OUTPUT=$(_unload_current_dir_env 2>&1)

  # Check error suppression (should have no stderr output from unalias/unset)
  if [ -z "$ERROR_OUTPUT" ] || ! echo "$ERROR_OUTPUT" | grep -q "not found"; then
    printf "  ✓ Errors are suppressed in normal mode\n"
  else
    printf "  ❌ FAIL: Error output not suppressed\n"
    printf "    Output: %s\n" "$ERROR_OUTPUT"
    FAILED=1
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 8: Unload does nothing when no env is loaded
###############################################################################
test_no_env_loaded() {
  printf "\n✅ TEST 8: Unload does nothing gracefully when no env is loaded\n"

  # Ensure ~/.direnv/tmp directory exists (required for tests)
  mkdir -p ~/.direnv/tmp

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Unload without any env loaded
  . "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
  ERROR_OUTPUT=$(_unload_current_dir_env 2>&1)

  # Should complete without error
  if [ $? -eq 0 ]; then
    printf "  ✓ Unload completes successfully when no env loaded\n"
  else
    printf "  ❌ FAIL: Unload failed when no env loaded\n"
    printf "    Output: %s\n" "$ERROR_OUTPUT"
    FAILED=1
  fi

  # Cleanup
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Test 9: Multiple aliases and variables are all handled
###############################################################################
test_multiple_items() {
  printf "\n✅ TEST 9: Multiple aliases and variables are all handled correctly\n"

  # Ensure ~/.direnv/tmp directory exists (required for tests)
  mkdir -p ~/.direnv/tmp

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create .envrc with multiple items
  cat > .envrc <<'EOF'
export VAR1='value1'
export VAR2='value2'
export VAR3='value3'
alias alias1='echo alias1'
alias alias2='echo alias2'
alias alias3='echo alias3'
EOF

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Verify all are loaded
  LOADED_COUNT=0
  [ "$VAR1" = "value1" ] && LOADED_COUNT=$((LOADED_COUNT + 1))
  [ "$VAR2" = "value2" ] && LOADED_COUNT=$((LOADED_COUNT + 1))
  [ "$VAR3" = "value3" ] && LOADED_COUNT=$((LOADED_COUNT + 1))

  if [ "$LOADED_COUNT" -eq 3 ]; then
    printf "  ✓ All 3 variables were loaded\n"
  else
    printf "  ❌ FAIL: Only %s/3 variables were loaded\n" "$LOADED_COUNT"
    FAILED=1
  fi

  # Unload
  . "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
  _unload_current_dir_env

  # Verify all are unloaded
  UNLOADED_COUNT=0
  [ -z "$VAR1" ] && UNLOADED_COUNT=$((UNLOADED_COUNT + 1))
  [ -z "$VAR2" ] && UNLOADED_COUNT=$((UNLOADED_COUNT + 1))
  [ -z "$VAR3" ] && UNLOADED_COUNT=$((UNLOADED_COUNT + 1))

  if [ "$UNLOADED_COUNT" -eq 3 ]; then
    printf "  ✓ All 3 variables were unloaded\n"
  else
    printf "  ❌ FAIL: Only %s/3 variables were unloaded\n" "$UNLOADED_COUNT"
    FAILED=1
  fi

  # Check aliases (harder to count, just check they're gone)
  ALIAS_FOUND=0
  alias alias1 2>/dev/null && ALIAS_FOUND=1
  alias alias2 2>/dev/null && ALIAS_FOUND=1
  alias alias3 2>/dev/null && ALIAS_FOUND=1

  if [ "$ALIAS_FOUND" -eq 0 ]; then
    printf "  ✓ All aliases were unloaded\n"
  else
    printf "  ❌ FAIL: Some aliases were not unloaded\n"
    FAILED=1
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
}

###############################################################################
# Main Execution
###############################################################################

echo "========================================"
echo "Environment Unloading Tests"
echo "========================================"
echo ""
echo "Testing environment unloading and restoration"
echo ""

test_alias_removal
test_env_var_removal
test_alias_restoration
test_env_var_restoration
test_backup_cleanup
test_current_env_cleanup
test_error_suppression
test_no_env_loaded
test_multiple_items

echo ""
echo "========================================"
if [ "$FAILED" -eq 0 ]; then
  printf "✅ All environment unloading tests passed!\n"
else
  printf "❌ Some environment unloading tests failed.\n"
fi
echo "========================================"

# CI mode: exit with failure code
if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
