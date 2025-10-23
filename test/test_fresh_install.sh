#!/bin/sh
# Test fresh installation and basic functionality

FAILED=0

# Test 1: Check if direnv is installed
test_direnv_installed() {
  if [ -d "$HOME/.direnv" ]; then
    echo "✅ (PASS) direnv directory exists"
  else
    echo "❌ (FAIL) direnv directory not found"
    FAILED=1
  fi
}

# Test 2: Check if init.sh exists
test_init_file_exists() {
  if [ -f "$HOME/.direnv/src/init.sh" ]; then
    echo "✅ (PASS) init.sh exists"
  else
    echo "❌ (FAIL) init.sh not found"
    FAILED=1
  fi
}

# Test 3: Check if shell config was updated
test_shell_config_updated() {
  # Check all common shell config files
  FOUND=0
  for config in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ -f "$config" ] && grep -q "direnv/src/init\.sh" "$config"; then
      FOUND=1
      break
    fi
  done

  if [ "$FOUND" -eq 1 ]; then
    echo "✅ (PASS) Shell config has direnv initialization"
  else
    echo "❌ (FAIL) Shell config missing direnv initialization"
    FAILED=1
  fi
}

# Test 4: Check if direnv functions work after sourcing
test_direnv_functions() {
  # Source init.sh
  if ! . "$HOME/.direnv/src/init.sh" 2>/dev/null; then
    echo "❌ (FAIL) Failed to source init.sh"
    FAILED=1
    return
  fi

  # Check if _load_current_dir_env function exists
  if command -v _load_current_dir_env >/dev/null 2>&1; then
    echo "✅ (PASS) direnv functions are loaded"
  else
    echo "❌ (FAIL) direnv functions not available"
    FAILED=1
  fi
}

# Test 5: Test auto-loading in subdirectory
test_auto_loading() {
  # Create test directory under HOME
  TEST_DIR="$HOME/.direnv-test-$$"
  mkdir -p "$TEST_DIR"

  # Create .envrc file
  cat > "$TEST_DIR/.envrc" <<'EOF'
export TEST_VAR="direnv_works"
EOF

  # Source init.sh in a subshell to avoid polluting current environment
  (
    . "$HOME/.direnv/src/init.sh" 2>/dev/null
    cd "$TEST_DIR"

    if [ "$TEST_VAR" = "direnv_works" ]; then
      echo "✅ (PASS) Environment auto-loaded in subdirectory"
      exit 0
    else
      echo "❌ (FAIL) Environment not loaded (TEST_VAR='$TEST_VAR')"
      exit 1
    fi
  )

  if [ $? -ne 0 ]; then
    FAILED=1
  fi

  # Cleanup
  rm -rf "$TEST_DIR"
}

# Test 6: Test that HOME itself is not loaded
test_home_not_loaded() {
  # Create .envrc in HOME (backup if exists)
  if [ -f "$HOME/.envrc" ]; then
    mv "$HOME/.envrc" "$HOME/.envrc.backup.$$"
  fi

  cat > "$HOME/.envrc" <<'EOF'
export HOME_TEST_VAR="should_not_load"
EOF

  # Source init.sh and check
  (
    . "$HOME/.direnv/src/init.sh" 2>/dev/null

    if [ -z "$HOME_TEST_VAR" ]; then
      echo "✅ (PASS) HOME directory .envrc not loaded (as expected)"
      exit 0
    else
      echo "❌ (FAIL) HOME directory .envrc was loaded (should not happen)"
      exit 1
    fi
  )

  if [ $? -ne 0 ]; then
    FAILED=1
  fi

  # Cleanup
  rm "$HOME/.envrc"
  if [ -f "$HOME/.envrc.backup.$$" ]; then
    mv "$HOME/.envrc.backup.$$" "$HOME/.envrc"
  fi
}

echo "=== Testing Fresh Installation ==="
echo ""

test_direnv_installed
test_init_file_exists
test_shell_config_updated
test_direnv_functions
test_auto_loading
test_home_not_loaded

echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "✅ All installation tests passed"
else
  echo "❌ Some installation tests failed"
fi

# CI 환경에서만 실패 시 exit 1
if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
