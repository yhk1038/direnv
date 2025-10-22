#!/bin/sh
#
# Comprehensive tests for backup/restore mechanism
#
# This test suite verifies the critical backup and restore functionality
# that preserves the user's original environment before loading direnv.
#
# CRITICAL: Incorrect backup/restore can corrupt the user's shell environment!
#

FAILED=0
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

###############################################################################
# Test 1: Backup file creation check
###############################################################################
test_backup_creation() {
  printf "\n✅ TEST 1: Backup files are created on first load\n"

  # Create test environment under HOME (required by direnv)
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"

  # Create .envrc
  echo "export TEST=1" > .envrc

  # Clean any existing backups
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
  rm -f ~/.direnv/tmp/current_env_file

  # Source and run load function
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Check if backup files were created
  if [ ! -f ~/.direnv/tmp/original_environment_aliases ]; then
    printf "  ❌ FAIL: Alias backup file not created\n"
    FAILED=1
  else
    printf "  ✓ Alias backup file created\n"
  fi

  if [ ! -f ~/.direnv/tmp/original_environment_variables ]; then
    printf "  ❌ FAIL: Variable backup file not created\n"
    FAILED=1
  else
    printf "  ✓ Variable backup file created\n"
  fi

  if [ ! -f ~/.direnv/tmp/current_env_file ]; then
    printf "  ❌ FAIL: Current env file not created\n"
    FAILED=1
  else
    printf "  ✓ Current env file created\n"
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/current_env_file
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
}

###############################################################################
# Test 2: Backup is NOT recreated if already exists (CRITICAL!)
###############################################################################
test_backup_not_recreated() {
  printf "\n✅ TEST 2: Backup files are NOT recreated on second load (CRITICAL)\n"

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"

  # Clean any existing backups
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
  rm -f ~/.direnv/tmp/current_env_file

  # Create initial backup files with known content
  echo "# INITIAL BACKUP - DO NOT MODIFY" > ~/.direnv/tmp/original_environment_aliases
  echo "# INITIAL BACKUP - DO NOT MODIFY" > ~/.direnv/tmp/original_environment_variables

  # Get modification time
  if [ "$(uname)" = "Darwin" ]; then
    BEFORE_ALIAS=$(stat -f %m ~/.direnv/tmp/original_environment_aliases)
    BEFORE_VAR=$(stat -f %m ~/.direnv/tmp/original_environment_variables)
  else
    BEFORE_ALIAS=$(stat -c %Y ~/.direnv/tmp/original_environment_aliases)
    BEFORE_VAR=$(stat -c %Y ~/.direnv/tmp/original_environment_variables)
  fi

  # Create .envrc and load
  cd "$TEST_DIR"
  echo "export TEST=1" > .envrc

  sleep 1  # Ensure time difference if file is recreated

  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Check modification time again
  if [ "$(uname)" = "Darwin" ]; then
    AFTER_ALIAS=$(stat -f %m ~/.direnv/tmp/original_environment_aliases)
    AFTER_VAR=$(stat -f %m ~/.direnv/tmp/original_environment_variables)
  else
    AFTER_ALIAS=$(stat -c %Y ~/.direnv/tmp/original_environment_aliases)
    AFTER_VAR=$(stat -c %Y ~/.direnv/tmp/original_environment_variables)
  fi

  if [ "$BEFORE_ALIAS" != "$AFTER_ALIAS" ]; then
    printf "  ❌ FAIL: Alias backup was recreated (mtime changed)\n"
    printf "    Before: %s, After: %s\n" "$BEFORE_ALIAS" "$AFTER_ALIAS"
    FAILED=1
  else
    printf "  ✓ Alias backup NOT recreated (mtime unchanged)\n"
  fi

  if [ "$BEFORE_VAR" != "$AFTER_VAR" ]; then
    printf "  ❌ FAIL: Variable backup was recreated (mtime changed)\n"
    printf "    Before: %s, After: %s\n" "$BEFORE_VAR" "$AFTER_VAR"
    FAILED=1
  else
    printf "  ✓ Variable backup NOT recreated (mtime unchanged)\n"
  fi

  # Check content is preserved
  if ! grep -q "INITIAL BACKUP" ~/.direnv/tmp/original_environment_aliases; then
    printf "  ❌ FAIL: Alias backup content was overwritten\n"
    FAILED=1
  else
    printf "  ✓ Alias backup content preserved\n"
  fi

  if ! grep -q "INITIAL BACKUP" ~/.direnv/tmp/original_environment_variables; then
    printf "  ❌ FAIL: Variable backup content was overwritten\n"
    FAILED=1
  else
    printf "  ✓ Variable backup content preserved\n"
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/current_env_file
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
}

###############################################################################
# Test 3: Alias format in backup
###############################################################################
test_alias_format() {
  printf "\n✅ TEST 3: Alias format in backup file\n"

  # Clean any existing backups
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
  rm -f ~/.direnv/tmp/current_env_file

  # Create test alias
  alias test_alias='echo "hello"'

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"
  echo "export TEST=1" > .envrc

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Check backup format
  if [ ! -f ~/.direnv/tmp/original_environment_aliases ]; then
    printf "  ❌ FAIL: Backup file not created\n"
    FAILED=1
  else
    # Check all lines start with "alias "
    NON_ALIAS=$(grep -v "^alias " ~/.direnv/tmp/original_environment_aliases | grep -v "^$" | wc -l)
    if [ "$NON_ALIAS" -gt 0 ]; then
      printf "  ❌ FAIL: Found %s lines not starting with 'alias '\n" "$NON_ALIAS"
      FAILED=1
    else
      printf "  ✓ All alias lines start with 'alias '\n"
    fi
  fi

  # Cleanup
  unalias test_alias 2>/dev/null
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/current_env_file
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
}

###############################################################################
# Test 4: Environment variable export format
###############################################################################
test_env_var_format() {
  printf "\n✅ TEST 4: Environment variable export format\n"

  # Clean any existing backups
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
  rm -f ~/.direnv/tmp/current_env_file

  # Create test environment
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"
  echo "export TEST=1" > .envrc

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Check backup format
  if [ ! -f ~/.direnv/tmp/original_environment_variables ]; then
    printf "  ❌ FAIL: Backup file not created\n"
    FAILED=1
  else
    # Check most lines start with "export "
    TOTAL=$(grep -c "=" ~/.direnv/tmp/original_environment_variables 2>/dev/null || echo "0")
    EXPORTS=$(grep -c "^export " ~/.direnv/tmp/original_environment_variables 2>/dev/null || echo "0")

    if [ "$EXPORTS" -gt 0 ]; then
      printf "  ✓ Found %s export lines (total lines with =: %s)\n" "$EXPORTS" "$TOTAL"
    else
      printf "  ❌ FAIL: No export lines found\n"
      FAILED=1
    fi
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/current_env_file
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
}

###############################################################################
# Test 5: Current env file copy
###############################################################################
test_current_env_copy() {
  printf "\n✅ TEST 5: Current environment file is copied correctly\n"

  # Clean any existing backups
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
  rm -f ~/.direnv/tmp/current_env_file

  # Create test environment with known content
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"
  cat > .envrc <<'EOF'
# Test environment file
export PROJECT_VAR='test_value'
alias project_alias='echo project'
EOF

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Check current env file
  if [ ! -f ~/.direnv/tmp/current_env_file ]; then
    printf "  ❌ FAIL: Current env file not created\n"
    FAILED=1
  else
    if grep -q "PROJECT_VAR" ~/.direnv/tmp/current_env_file && \
       grep -q "project_alias" ~/.direnv/tmp/current_env_file; then
      printf "  ✓ Current env file has correct content\n"
    else
      printf "  ❌ FAIL: Current env file content is incorrect\n"
      FAILED=1
    fi
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/current_env_file
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
}

###############################################################################
# Test 6: .envrc vs .profile priority
###############################################################################
test_file_priority() {
  printf "\n✅ TEST 6: File priority when both .envrc and .profile exist\n"

  # Clean any existing backups
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
  rm -f ~/.direnv/tmp/current_env_file

  # Create test environment with both files
  TEST_DIR="$HOME/tmp/direnv-test-$$"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"
  echo "export FROM_ENVRC='envrc'" > .envrc
  echo "export FROM_PROFILE='profile'" > .profile

  # Load
  . "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"
  _load_current_dir_env

  # Check which file was loaded (last one wins, which is .profile)
  if [ -f ~/.direnv/tmp/current_env_file ]; then
    if grep -q "FROM_PROFILE" ~/.direnv/tmp/current_env_file; then
      printf "  ✓ .profile was loaded (correct priority)\n"
    else
      printf "  ❌ FAIL: .profile was not loaded\n"
      FAILED=1
    fi
  else
    printf "  ❌ FAIL: No env file was loaded\n"
    FAILED=1
  fi

  # Cleanup
  cd
  rm -rf "$TEST_DIR"
  rm -f ~/.direnv/tmp/current_env_file
  rm -f ~/.direnv/tmp/original_environment_aliases
  rm -f ~/.direnv/tmp/original_environment_variables
}

###############################################################################
# Test 7: Code uses redirection, not pipe (POSIX, no subshell)
###############################################################################
test_no_subshell() {
  printf "\n✅ TEST 7: Implementation uses redirection (not pipe) to avoid subshell\n"

  # Check source code for correct pattern
  if grep -q 'done > "\$ORIGINAL_ALIASES_FILE"' "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"; then
    printf "  ✓ Alias backup uses redirection syntax\n"
  else
    printf "  ❌ FAIL: Alias backup doesn't use redirection\n"
    FAILED=1
  fi

  if grep -q 'done > "\$ORIGINAL_VARIABLE_FILE"' "$SCRIPT_DIR/src/scripts/load_current_dir_env.sh"; then
    printf "  ✓ Variable backup uses redirection syntax\n"
  else
    printf "  ❌ FAIL: Variable backup doesn't use redirection\n"
    FAILED=1
  fi
}

###############################################################################
# Main Execution
###############################################################################

echo "========================================"
echo "Backup/Restore Mechanism Tests"
echo "========================================"
echo ""
echo "Testing critical backup and restore functionality"
echo ""

test_backup_creation
test_backup_not_recreated
test_alias_format
test_env_var_format
test_current_env_copy
test_file_priority
test_no_subshell

echo ""
echo "========================================"
if [ "$FAILED" -eq 0 ]; then
  printf "✅ All backup/restore tests passed!\n"
else
  printf "❌ Some backup/restore tests failed.\n"
fi
echo "========================================"

# CI mode: exit with failure code
if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
