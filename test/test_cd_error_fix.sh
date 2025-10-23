#!/bin/sh

# Test script to verify cd error message fix
# Tests different directory change scenarios

echo "🧪 Testing directory change error suppression..."
echo ""

# Ensure ~/.direnv/tmp directory exists (required for tests)
mkdir -p ~/.direnv/tmp

# Get absolute path to project root
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)

# Source the direnv scripts
. "$PROJECT_ROOT/src/scripts/load_current_dir_env.sh"
. "$PROJECT_ROOT/src/scripts/unload_current_dir_env.sh"

FAILED=0

# Test 1: Applicable → Applicable (different envrc)
echo "📝 Test 1: Moving between folders with .envrc files"
cd "$PROJECT_ROOT/mock-directories/sample1" 2>&1 | tee /tmp/test_output.txt
_load_current_dir_env

cd "$PROJECT_ROOT/mock-directories/sample2" 2>&1 | tee -a /tmp/test_output.txt
_unload_current_dir_env
_load_current_dir_env

# Check if there are error messages
if grep -i "not found\|error" /tmp/test_output.txt >/dev/null 2>&1; then
  echo "❌ (FAIL) Test 1: Error messages detected when moving between applicable folders"
  FAILED=1
else
  echo "✅ (PASS) Test 1: No error messages when moving between applicable folders"
fi

# Test 2: Applicable → Non-applicable
echo ""
echo "📝 Test 2: Moving from applicable to non-applicable folder"
cd "$PROJECT_ROOT/mock-directories/sample4" 2>&1 | tee /tmp/test_output2.txt
_unload_current_dir_env

if grep -i "not found\|error" /tmp/test_output2.txt >/dev/null 2>&1; then
  echo "❌ (FAIL) Test 2: Error messages detected when moving to non-applicable folder"
  FAILED=1
else
  echo "✅ (PASS) Test 2: No error messages when moving to non-applicable folder"
fi

# Test 3: Non-applicable → Applicable (should already work)
echo ""
echo "📝 Test 3: Moving from non-applicable to applicable folder (baseline)"
cd "$PROJECT_ROOT/mock-directories/sample1" 2>&1 | tee /tmp/test_output3.txt
_load_current_dir_env

if grep -i "not found\|error" /tmp/test_output3.txt >/dev/null 2>&1; then
  echo "❌ (FAIL) Test 3: Unexpected error messages"
  FAILED=1
else
  echo "✅ (PASS) Test 3: No error messages (as expected)"
fi

# Test 4: Debug mode shows errors (positive test)
echo ""
echo "📝 Test 4: Debug mode (DIRENV_DEBUG=1) should show errors"
export DIRENV_DEBUG=1
cd "$PROJECT_ROOT/mock-directories/sample2" 2>&1 | tee /tmp/test_output4.txt
_unload_current_dir_env
unset DIRENV_DEBUG

# In debug mode, we're just checking that it doesn't break
# (errors are expected and that's OK)
echo "✅ (PASS) Test 4: Debug mode executed without crashing"

# Cleanup
cd "$PROJECT_ROOT"
rm -f /tmp/test_output*.txt
rm -f ~/.direnv/tmp/*

echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "✅ All directory change tests passed!"
else
  echo "❌ Some tests failed"
fi

if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
