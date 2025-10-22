#!/bin/sh
#
# Comprehensive tests for directory changed hook
#
# This test suite verifies that direnv properly detects directory changes
# and triggers environment reload at the right time.
#
# CRITICAL: Hook must work reliably for automatic environment switching!
#

FAILED=0
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Source all required scripts
. "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
. "$SCRIPT_DIR/src/scripts/unload_current_dir_env.sh"
. "$SCRIPT_DIR/src/scripts/directory_changed_hook.sh"

# Override cd to use our hook (simulating init.sh behavior)
cd() {
  builtin cd "$@" || return
  [ "$OLDPWD" != "$PWD" ] && _directory_changed_hook
}

###############################################################################
# Test 1: Hook triggers when directory actually changes
###############################################################################
test_hook_triggers_on_change() {
  printf "\n✅ TEST 1: Hook triggers when directory changes\n"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create two test directories
  TEST_DIR1="$HOME/tmp/direnv-test-$$-dir1"
  TEST_DIR2="$HOME/tmp/direnv-test-$$-dir2"
  mkdir -p "$TEST_DIR1" "$TEST_DIR2"

  # Create .envrc in dir1
  echo "export DIR1_VAR='dir1'" > "$TEST_DIR1/.envrc"

  # Go to dir1
  builtin cd "$TEST_DIR1"
  _load_current_dir_env

  # Verify dir1 env is loaded
  if [ "$DIR1_VAR" = "dir1" ]; then
    printf "  ✓ DIR1 environment loaded\n"
  else
    printf "  ❌ FAIL: DIR1 environment not loaded\n"
    FAILED=1
  fi

  # Create .envrc in dir2
  echo "export DIR2_VAR='dir2'" > "$TEST_DIR2/.envrc"

  # Change to dir2 (should trigger hook)
  cd "$TEST_DIR2"

  # Verify dir1 env is unloaded and dir2 env is loaded
  if [ -z "$DIR1_VAR" ]; then
    printf "  ✓ DIR1 environment unloaded\n"
  else
    printf "  ❌ FAIL: DIR1 environment not unloaded (value: %s)\n" "$DIR1_VAR"
    FAILED=1
  fi

  if [ "$DIR2_VAR" = "dir2" ]; then
    printf "  ✓ DIR2 environment loaded\n"
  else
    printf "  ❌ FAIL: DIR2 environment not loaded\n"
    FAILED=1
  fi

  # Cleanup
  builtin cd
  rm -rf "$TEST_DIR1" "$TEST_DIR2"
  rm -f ~/.direnv/tmp/*
  unset DIR1_VAR DIR2_VAR
}

###############################################################################
# Test 2: Hook does NOT trigger for same directory (cd .)
###############################################################################
test_hook_not_trigger_same_dir() {
  printf "\n✅ TEST 2: Hook does NOT trigger for same directory (cd .)\n"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create test directory
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"

  # Create .envrc
  echo "export TEST_VAR='original'" > "$TEST_DIR/.envrc"

  # Go to test dir
  builtin cd "$TEST_DIR"
  _load_current_dir_env

  # Verify env is loaded
  if [ "$TEST_VAR" = "original" ]; then
    printf "  ✓ Environment loaded initially\n"
  else
    printf "  ❌ FAIL: Environment not loaded\n"
    FAILED=1
  fi

  # Record backup file mtime
  if [ "$(uname)" = "Darwin" ]; then
    BEFORE_MTIME=$(stat -f %m ~/.direnv/tmp/original_environment_variables 2>/dev/null || echo "0")
  else
    BEFORE_MTIME=$(stat -c %Y ~/.direnv/tmp/original_environment_variables 2>/dev/null || echo "0")
  fi

  # cd . (same directory - should not trigger hook due to OLDPWD == PWD check)
  cd .

  # Check if backup was recreated (it shouldn't be)
  if [ "$(uname)" = "Darwin" ]; then
    AFTER_MTIME=$(stat -f %m ~/.direnv/tmp/original_environment_variables 2>/dev/null || echo "0")
  else
    AFTER_MTIME=$(stat -c %Y ~/.direnv/tmp/original_environment_variables 2>/dev/null || echo "0")
  fi

  if [ "$BEFORE_MTIME" = "$AFTER_MTIME" ]; then
    printf "  ✓ Hook did not trigger (backup unchanged)\n"
  else
    printf "  ❌ FAIL: Hook was triggered (backup was modified)\n"
    FAILED=1
  fi

  # Verify env is still active
  if [ "$TEST_VAR" = "original" ]; then
    printf "  ✓ Environment still active\n"
  else
    printf "  ❌ FAIL: Environment was unloaded\n"
    FAILED=1
  fi

  # Cleanup
  builtin cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
  unset TEST_VAR
}

###############################################################################
# Test 3: Unload → Load sequence order
###############################################################################
test_unload_load_sequence() {
  printf "\n✅ TEST 3: Unload happens before Load (correct sequence)\n"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create two test directories
  TEST_DIR1="$HOME/tmp/direnv-test-$$-seq1"
  TEST_DIR2="$HOME/tmp/direnv-test-$$-seq2"
  mkdir -p "$TEST_DIR1" "$TEST_DIR2"

  # Create .envrc with same variable name but different values
  echo "export SHARED_VAR='dir1_value'" > "$TEST_DIR1/.envrc"
  echo "export SHARED_VAR='dir2_value'" > "$TEST_DIR2/.envrc"

  # Go to dir1
  builtin cd "$TEST_DIR1"
  _load_current_dir_env

  if [ "$SHARED_VAR" = "dir1_value" ]; then
    printf "  ✓ DIR1 value loaded\n"
  else
    printf "  ❌ FAIL: DIR1 value not loaded (value: %s)\n" "$SHARED_VAR"
    FAILED=1
  fi

  # Change to dir2
  cd "$TEST_DIR2"

  # If unload happens before load, we should see dir2_value
  # If load happens before unload, we might see dir1_value or undefined behavior
  if [ "$SHARED_VAR" = "dir2_value" ]; then
    printf "  ✓ DIR2 value loaded (correct sequence: unload → load)\n"
  else
    printf "  ❌ FAIL: Incorrect value (expected dir2_value, got: %s)\n" "$SHARED_VAR"
    printf "    This suggests incorrect sequence or incomplete unload\n"
    FAILED=1
  fi

  # Cleanup
  builtin cd
  rm -rf "$TEST_DIR1" "$TEST_DIR2"
  rm -f ~/.direnv/tmp/*
  unset SHARED_VAR
}

###############################################################################
# Test 4: Consecutive directory changes (A → B → C)
###############################################################################
test_consecutive_changes() {
  printf "\n✅ TEST 4: Consecutive directory changes (A → B → C)\n"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create three test directories
  TEST_DIR_A="$HOME/tmp/direnv-test-$$-A"
  TEST_DIR_B="$HOME/tmp/direnv-test-$$-B"
  TEST_DIR_C="$HOME/tmp/direnv-test-$$-C"
  mkdir -p "$TEST_DIR_A" "$TEST_DIR_B" "$TEST_DIR_C"

  # Create .envrc in each
  echo "export DIR_VAR='A'" > "$TEST_DIR_A/.envrc"
  echo "export DIR_VAR='B'" > "$TEST_DIR_B/.envrc"
  echo "export DIR_VAR='C'" > "$TEST_DIR_C/.envrc"

  # A
  builtin cd "$TEST_DIR_A"
  _load_current_dir_env

  if [ "$DIR_VAR" = "A" ]; then
    printf "  ✓ A loaded\n"
  else
    printf "  ❌ FAIL: A not loaded\n"
    FAILED=1
  fi

  # A → B
  cd "$TEST_DIR_B"

  if [ "$DIR_VAR" = "B" ]; then
    printf "  ✓ B loaded (A unloaded)\n"
  else
    printf "  ❌ FAIL: B not loaded correctly\n"
    FAILED=1
  fi

  # B → C
  cd "$TEST_DIR_C"

  if [ "$DIR_VAR" = "C" ]; then
    printf "  ✓ C loaded (B unloaded)\n"
  else
    printf "  ❌ FAIL: C not loaded correctly\n"
    FAILED=1
  fi

  # Cleanup
  builtin cd
  rm -rf "$TEST_DIR_A" "$TEST_DIR_B" "$TEST_DIR_C"
  rm -f ~/.direnv/tmp/*
  unset DIR_VAR
}

###############################################################################
# Test 5: Return to previous directory (A → B → A)
###############################################################################
test_return_to_previous() {
  printf "\n✅ TEST 5: Return to previous directory (A → B → A)\n"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create two test directories
  TEST_DIR_A="$HOME/tmp/direnv-test-$$-return-A"
  TEST_DIR_B="$HOME/tmp/direnv-test-$$-return-B"
  mkdir -p "$TEST_DIR_A" "$TEST_DIR_B"

  # Create .envrc in each
  echo "export DIR_VAR='A'" > "$TEST_DIR_A/.envrc"
  echo "export DIR_VAR='B'" > "$TEST_DIR_B/.envrc"

  # A
  builtin cd "$TEST_DIR_A"
  _load_current_dir_env

  if [ "$DIR_VAR" = "A" ]; then
    printf "  ✓ A loaded initially\n"
  else
    printf "  ❌ FAIL: A not loaded\n"
    FAILED=1
  fi

  # A → B
  cd "$TEST_DIR_B"

  if [ "$DIR_VAR" = "B" ]; then
    printf "  ✓ B loaded\n"
  else
    printf "  ❌ FAIL: B not loaded\n"
    FAILED=1
  fi

  # B → A (return)
  cd "$TEST_DIR_A"

  if [ "$DIR_VAR" = "A" ]; then
    printf "  ✓ A loaded again (B unloaded)\n"
  else
    printf "  ❌ FAIL: A not loaded on return (value: %s)\n" "$DIR_VAR"
    FAILED=1
  fi

  # Cleanup
  builtin cd
  rm -rf "$TEST_DIR_A" "$TEST_DIR_B"
  rm -f ~/.direnv/tmp/*
  unset DIR_VAR
}

###############################################################################
# Test 6: Move from env dir → home → env dir
###############################################################################
test_home_in_between() {
  printf "\n✅ TEST 6: Move from env dir → home → env dir again\n"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create test directory
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"

  # Create .envrc
  echo "export TEST_VAR='test'" > "$TEST_DIR/.envrc"

  # Go to test dir
  builtin cd "$TEST_DIR"
  _load_current_dir_env

  if [ "$TEST_VAR" = "test" ]; then
    printf "  ✓ Environment loaded in test dir\n"
  else
    printf "  ❌ FAIL: Environment not loaded\n"
    FAILED=1
  fi

  # Go to home (should unload)
  cd "$HOME"

  if [ -z "$TEST_VAR" ]; then
    printf "  ✓ Environment unloaded at home\n"
  else
    printf "  ❌ FAIL: Environment not unloaded (value: %s)\n" "$TEST_VAR"
    FAILED=1
  fi

  # Return to test dir (should load again)
  cd "$TEST_DIR"

  if [ "$TEST_VAR" = "test" ]; then
    printf "  ✓ Environment reloaded\n"
  else
    printf "  ❌ FAIL: Environment not reloaded\n"
    FAILED=1
  fi

  # Cleanup
  builtin cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/*
  unset TEST_VAR
}

###############################################################################
# Test 7: cd to directory without .envrc
###############################################################################
test_no_envrc_directory() {
  printf "\n✅ TEST 7: cd to directory without .envrc (unload only)\n"

  # Clean backups
  rm -f ~/.direnv/tmp/*

  # Create two directories (one with .envrc, one without)
  TEST_DIR_WITH="$HOME/tmp/direnv-test-$$-with"
  TEST_DIR_WITHOUT="$HOME/tmp/direnv-test-$$-without"
  mkdir -p "$TEST_DIR_WITH" "$TEST_DIR_WITHOUT"

  # Create .envrc only in first dir
  echo "export TEST_VAR='test'" > "$TEST_DIR_WITH/.envrc"

  # Go to dir with .envrc
  builtin cd "$TEST_DIR_WITH"
  _load_current_dir_env

  if [ "$TEST_VAR" = "test" ]; then
    printf "  ✓ Environment loaded\n"
  else
    printf "  ❌ FAIL: Environment not loaded\n"
    FAILED=1
  fi

  # Go to dir without .envrc (should unload)
  cd "$TEST_DIR_WITHOUT"

  if [ -z "$TEST_VAR" ]; then
    printf "  ✓ Environment unloaded in dir without .envrc\n"
  else
    printf "  ❌ FAIL: Environment not unloaded (value: %s)\n" "$TEST_VAR"
    FAILED=1
  fi

  # Verify no current_env_file exists
  if [ ! -f ~/.direnv/tmp/current_env_file ]; then
    printf "  ✓ No current env file (clean state)\n"
  else
    printf "  ❌ FAIL: Current env file still exists\n"
    FAILED=1
  fi

  # Cleanup
  builtin cd
  rm -rf "$TEST_DIR_WITH" "$TEST_DIR_WITHOUT"
  rm -f ~/.direnv/tmp/*
  unset TEST_VAR
}

###############################################################################
# Main Execution
###############################################################################

echo "========================================"
echo "Directory Changed Hook Tests"
echo "========================================"
echo ""
echo "Testing directory change detection and hook behavior"
echo ""

test_hook_triggers_on_change
test_hook_not_trigger_same_dir
test_unload_load_sequence
test_consecutive_changes
test_return_to_previous
test_home_in_between
test_no_envrc_directory

echo ""
echo "========================================"
if [ "$FAILED" -eq 0 ]; then
  printf "✅ All directory changed hook tests passed!\n"
else
  printf "❌ Some directory changed hook tests failed.\n"
fi
echo "========================================"

# CI mode: exit with failure code
if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
