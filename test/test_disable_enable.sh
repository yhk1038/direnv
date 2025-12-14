#!/bin/bash
# Test disable/enable functionality
# Note: Uses bash because 'builtin cd' requires bash/zsh

# Setup
TEST_DIR=$(mktemp -d)
HOME_BACKUP="$HOME"
export HOME="$TEST_DIR"
mkdir -p "$HOME/.direnv/src/scripts"
mkdir -p "$HOME/.direnv/tmp"

# Copy source files
cp -r "$(dirname "$0")/../src/"* "$HOME/.direnv/src/"

# Create test directory with .envrc
TEST_PROJECT="$HOME/test_project"
mkdir -p "$TEST_PROJECT"
echo 'export TEST_DISABLE_VAR="loaded"' > "$TEST_PROJECT/.envrc"

# Initialize
. "$HOME/.direnv/src/init.sh"

FAILED=0

echo "========================================"
echo "Disable/Enable Tests"
echo "========================================"
echo ""

# TEST 1: de status shows enabled by default
echo "📝 TEST 1: de status shows enabled by default"
STATUS_OUTPUT=$(de status 2>&1)
if echo "$STATUS_OUTPUT" | grep -q "enabled"; then
  echo "  ✓ Status shows enabled"
else
  echo "  ✗ Status should show enabled"
  FAILED=1
fi

# TEST 2: de disable unloads environment and sets flag
echo ""
echo "📝 TEST 2: de disable unloads environment"
builtin cd "$TEST_PROJECT" 2>/dev/null || cd "$TEST_PROJECT"
_load_current_dir_env
if [ "$TEST_DISABLE_VAR" = "loaded" ]; then
  echo "  ✓ Environment loaded before disable"
else
  echo "  ✗ Environment should be loaded before disable"
  FAILED=1
fi

de disable >/dev/null 2>&1

if [ "$DIRENV_DISABLED" = "1" ]; then
  echo "  ✓ DIRENV_DISABLED flag set"
else
  echo "  ✗ DIRENV_DISABLED flag should be set"
  FAILED=1
fi

if [ -z "$TEST_DISABLE_VAR" ]; then
  echo "  ✓ Environment unloaded after disable"
else
  echo "  ✗ Environment should be unloaded (TEST_DISABLE_VAR=$TEST_DISABLE_VAR)"
  FAILED=1
fi

# TEST 3: de status shows disabled after de disable
echo ""
echo "📝 TEST 3: de status shows disabled"
STATUS_OUTPUT=$(de status 2>&1)
if echo "$STATUS_OUTPUT" | grep -q "disabled"; then
  echo "  ✓ Status shows disabled"
else
  echo "  ✗ Status should show disabled"
  FAILED=1
fi

# TEST 4: cd doesn't trigger hooks when disabled
echo ""
echo "📝 TEST 4: cd doesn't trigger hooks when disabled"
builtin cd "$HOME" 2>/dev/null || cd "$HOME"
builtin cd "$TEST_PROJECT" 2>/dev/null || cd "$TEST_PROJECT"

if [ -z "$TEST_DISABLE_VAR" ]; then
  echo "  ✓ Environment not loaded when disabled"
else
  echo "  ✗ Environment should not load when disabled"
  FAILED=1
fi

# TEST 5: de enable restores hooks and loads environment
echo ""
echo "📝 TEST 5: de enable restores functionality"
de enable >/dev/null 2>&1

if [ -z "$DIRENV_DISABLED" ] || [ "$DIRENV_DISABLED" != "1" ]; then
  echo "  ✓ DIRENV_DISABLED flag cleared"
else
  echo "  ✗ DIRENV_DISABLED flag should be cleared"
  FAILED=1
fi

if [ "$TEST_DISABLE_VAR" = "loaded" ]; then
  echo "  ✓ Environment loaded after enable"
else
  echo "  ✗ Environment should be loaded after enable"
  FAILED=1
fi

# TEST 6: de disable when already disabled
echo ""
echo "📝 TEST 6: de disable when already disabled shows warning"
de disable >/dev/null 2>&1
DISABLE_OUTPUT=$(de disable 2>&1)
if echo "$DISABLE_OUTPUT" | grep -q "already"; then
  echo "  ✓ Shows already disabled message"
else
  echo "  ✗ Should show already disabled message"
  FAILED=1
fi

# TEST 7: de enable when already enabled
echo ""
echo "📝 TEST 7: de enable when already enabled shows warning"
de enable >/dev/null 2>&1
ENABLE_OUTPUT=$(de enable 2>&1)
if echo "$ENABLE_OUTPUT" | grep -q "already"; then
  echo "  ✓ Shows already enabled message"
else
  echo "  ✗ Should show already enabled message"
  FAILED=1
fi

# Cleanup
unset TEST_DISABLE_VAR
unset DIRENV_DISABLED
export HOME="$HOME_BACKUP"
rm -rf "$TEST_DIR"

echo ""
echo "========================================"
if [ "$FAILED" = "0" ]; then
  echo "✅ All disable/enable tests passed!"
else
  echo "❌ Some disable/enable tests failed!"
fi
echo "========================================"

if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
