#!/bin/bash
# E2E (End-to-End) Workflow Tests
# Tests complete user workflows from start to finish

# Setup isolated test environment
TEST_DIR=$(mktemp -d)
HOME_BACKUP="$HOME"
export HOME="$TEST_DIR"
mkdir -p "$HOME/.direnv/src/scripts"
mkdir -p "$HOME/.direnv/tmp"

# Copy source files
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cp -r "$SCRIPT_DIR/src/"* "$HOME/.direnv/src/"

FAILED=0

echo "========================================"
echo "E2E Workflow Tests"
echo "========================================"
echo ""

# ============================================
# WORKFLOW 1: Basic directory environment flow
# ============================================
echo "📋 WORKFLOW 1: Basic directory environment flow"
echo "   (project A → project B → home → project A)"
echo ""

# Create test projects
PROJECT_A="$HOME/project_a"
PROJECT_B="$HOME/project_b"
mkdir -p "$PROJECT_A" "$PROJECT_B"

cat > "$PROJECT_A/.envrc" << 'EOF'
export PROJECT_NAME="Project A"
export API_KEY="key_a_12345"
alias build="echo 'Building A...'"
EOF

cat > "$PROJECT_B/.envrc" << 'EOF'
export PROJECT_NAME="Project B"
export API_KEY="key_b_67890"
alias build="echo 'Building B...'"
EOF

# Initialize direnv
. "$HOME/.direnv/src/init.sh"

# Step 1: Enter project A
echo "  Step 1: cd project_a"
cd "$PROJECT_A"
if [ "$PROJECT_NAME" = "Project A" ] && [ "$API_KEY" = "key_a_12345" ]; then
  echo "    ✓ Project A environment loaded"
else
  echo "    ✗ Project A environment should be loaded"
  FAILED=1
fi

# Step 2: Switch to project B
echo "  Step 2: cd project_b"
cd "$PROJECT_B"
if [ "$PROJECT_NAME" = "Project B" ] && [ "$API_KEY" = "key_b_67890" ]; then
  echo "    ✓ Project B environment loaded (A unloaded)"
else
  echo "    ✗ Project B environment should be loaded"
  FAILED=1
fi

# Step 3: Go to home
echo "  Step 3: cd ~ (home)"
cd "$HOME"
if [ -z "$PROJECT_NAME" ] && [ -z "$API_KEY" ]; then
  echo "    ✓ All project environments unloaded"
else
  echo "    ✗ Environments should be unloaded at home"
  FAILED=1
fi

# Step 4: Return to project A
echo "  Step 4: cd project_a (return)"
cd "$PROJECT_A"
if [ "$PROJECT_NAME" = "Project A" ]; then
  echo "    ✓ Project A environment reloaded"
else
  echo "    ✗ Project A environment should be reloaded"
  FAILED=1
fi

echo ""

# ============================================
# WORKFLOW 2: Disable during work, then enable
# ============================================
echo "📋 WORKFLOW 2: Disable/Enable during work session"
echo ""

# Start in project A (should already be there)
echo "  Step 1: Working in project A (environment loaded)"
if [ "$PROJECT_NAME" = "Project A" ]; then
  echo "    ✓ In project A with environment"
else
  echo "    ✗ Should be in project A"
  FAILED=1
fi

# Disable direnv
echo "  Step 2: de disable"
de disable >/dev/null 2>&1
if [ -z "$PROJECT_NAME" ] && [ "$DIRENV_DISABLED" = "1" ]; then
  echo "    ✓ Direnv disabled, environment unloaded"
else
  echo "    ✗ Should be disabled with no environment"
  FAILED=1
fi

# Switch projects while disabled
echo "  Step 3: cd project_b (while disabled)"
cd "$PROJECT_B"
if [ -z "$PROJECT_NAME" ]; then
  echo "    ✓ No environment loaded (disabled)"
else
  echo "    ✗ Environment should not load when disabled"
  FAILED=1
fi

# Re-enable direnv
echo "  Step 4: de enable"
de enable >/dev/null 2>&1
if [ "$PROJECT_NAME" = "Project B" ]; then
  echo "    ✓ Direnv enabled, current directory environment loaded"
else
  echo "    ✗ Should load current directory environment on enable"
  FAILED=1
fi

echo ""

# ============================================
# WORKFLOW 3: Nested directory navigation
# ============================================
echo "📋 WORKFLOW 3: Nested directory with .envrc in parent"
echo ""

# Create nested structure
PARENT_PROJECT="$HOME/parent_project"
CHILD_DIR="$PARENT_PROJECT/src/components"
mkdir -p "$CHILD_DIR"

cat > "$PARENT_PROJECT/.envrc" << 'EOF'
export PARENT_VAR="parent_value"
EOF

# Enter parent project
echo "  Step 1: cd parent_project"
cd "$PARENT_PROJECT"
if [ "$PARENT_VAR" = "parent_value" ]; then
  echo "    ✓ Parent environment loaded"
else
  echo "    ✗ Parent environment should be loaded"
  FAILED=1
fi

# Enter child directory (no .envrc there)
echo "  Step 2: cd src/components (child without .envrc)"
cd "$CHILD_DIR"
if [ -z "$PARENT_VAR" ]; then
  echo "    ✓ Environment unloaded in child (expected behavior)"
else
  echo "    ✗ Environment should be unloaded (no .envrc in child)"
  FAILED=1
fi

# Return to parent
echo "  Step 3: cd ../.. (return to parent)"
cd "$PARENT_PROJECT"
if [ "$PARENT_VAR" = "parent_value" ]; then
  echo "    ✓ Parent environment reloaded"
else
  echo "    ✗ Parent environment should be reloaded"
  FAILED=1
fi

echo ""

# ============================================
# WORKFLOW 4: de init creates proper files
# ============================================
echo "📋 WORKFLOW 4: de init workflow"
echo ""

NEW_PROJECT="$HOME/new_project"
mkdir -p "$NEW_PROJECT"
cd "$NEW_PROJECT"

# Initialize git repo for .gitignore test
git init -q 2>/dev/null

echo "  Step 1: de init (create .envrc)"
de init >/dev/null 2>&1
if [ -f ".envrc" ]; then
  echo "    ✓ .envrc created"
else
  echo "    ✗ .envrc should be created"
  FAILED=1
fi

if [ -f ".gitignore" ] && grep -q ".envrc" .gitignore 2>/dev/null; then
  echo "    ✓ .envrc added to .gitignore"
else
  echo "    ✗ .envrc should be in .gitignore"
  FAILED=1
fi

echo ""

# ============================================
# WORKFLOW 5: de status shows correct state
# ============================================
echo "📋 WORKFLOW 5: de status accuracy"
echo ""

cd "$PROJECT_A"
_load_current_dir_env  # Ensure environment is loaded

echo "  Step 1: de status when enabled with loaded env"
STATUS=$(de status 2>&1)
if echo "$STATUS" | grep -q "enabled"; then
  echo "    ✓ Shows enabled status"
else
  echo "    ✗ Should show enabled"
  FAILED=1
fi

echo "  Step 2: de disable && de status"
de disable >/dev/null 2>&1
STATUS=$(de status 2>&1)
if echo "$STATUS" | grep -q "disabled"; then
  echo "    ✓ Shows disabled status"
else
  echo "    ✗ Should show disabled"
  FAILED=1
fi

# Re-enable for cleanup
de enable >/dev/null 2>&1

echo ""

# ============================================
# WORKFLOW 6: Complex alias and function handling
# ============================================
echo "📋 WORKFLOW 6: Complex shell features"
echo ""

COMPLEX_PROJECT="$HOME/complex_project"
mkdir -p "$COMPLEX_PROJECT"

cat > "$COMPLEX_PROJECT/.envrc" << 'EOF'
export COMPLEX_VAR="complex_value"
alias ll="ls -la"
alias grep="grep --color=auto"
my_function() {
  echo "Function output: $1"
}
EOF

echo "  Step 1: cd complex_project"
cd "$COMPLEX_PROJECT"
if [ "$COMPLEX_VAR" = "complex_value" ]; then
  echo "    ✓ Complex environment loaded"
else
  echo "    ✗ Complex environment should be loaded"
  FAILED=1
fi

# Test function exists
if type my_function >/dev/null 2>&1; then
  echo "    ✓ Function defined"
else
  echo "    ✗ Function should be defined"
  FAILED=1
fi

echo "  Step 2: cd ~ (unload complex environment)"
cd "$HOME"
if [ -z "$COMPLEX_VAR" ]; then
  echo "    ✓ Complex variables unloaded"
else
  echo "    ✗ Variables should be unloaded"
  FAILED=1
fi

echo ""

# ============================================
# Cleanup
# ============================================
unset PROJECT_NAME API_KEY PARENT_VAR COMPLEX_VAR
unset DIRENV_DISABLED
export HOME="$HOME_BACKUP"
rm -rf "$TEST_DIR"

echo "========================================"
if [ "$FAILED" = "0" ]; then
  echo "✅ All E2E workflow tests passed!"
else
  echo "❌ Some E2E workflow tests failed!"
fi
echo "========================================"

if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
