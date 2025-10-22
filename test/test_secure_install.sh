#!/bin/sh

# =============================================================================
# Test: Secure Installation (Remove eval Security Risk)
# =============================================================================
#
# This test verifies that install.sh and uninstall.sh no longer use
# dangerous eval() of remote content, and instead load language files
# from the local filesystem.
#
# TDD approach:
# 1. These tests should FAIL initially (RED)
# 2. Implementation will make them PASS (GREEN)
# 3. Refactor with confidence
# =============================================================================

FAILED=0
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_pass() {
  printf "${GREEN}✅ (PASS)${NC} %s\n" "$1"
}

log_fail() {
  printf "${RED}❌ (FAIL)${NC} %s\n" "$1"
  FAILED=1
}

log_info() {
  printf "${YELLOW}ℹ️  (INFO)${NC} %s\n" "$1"
}

# =============================================================================
# Test 1: No eval in install.sh
# =============================================================================
test_no_eval_in_install() {
  log_info "Testing: install.sh should not contain 'eval \$LANG_CONTENT'"

  if grep -q 'eval.*LANG_CONTENT' "$PROJECT_ROOT/install.sh"; then
    log_fail "install.sh still contains dangerous eval statement"
    return 1
  fi

  log_pass "install.sh does not use eval for language loading"
  return 0
}

# =============================================================================
# Test 2: No eval in uninstall.sh
# =============================================================================
test_no_eval_in_uninstall() {
  log_info "Testing: uninstall.sh should not contain 'eval \$LANG_CONTENT'"

  if grep -q 'eval.*LANG_CONTENT' "$PROJECT_ROOT/uninstall.sh"; then
    log_fail "uninstall.sh still contains dangerous eval statement"
    return 1
  fi

  log_pass "uninstall.sh does not use eval for language loading"
  return 0
}

# =============================================================================
# Test 3: No remote URL download in install.sh
# =============================================================================
test_no_remote_lang_download_in_install() {
  log_info "Testing: install.sh should not download lang files from GitHub"

  if grep -q 'curl.*githubusercontent.*lang.*\.lang' "$PROJECT_ROOT/install.sh"; then
    log_fail "install.sh still downloads lang files from remote URL"
    return 1
  fi

  log_pass "install.sh does not download lang files remotely"
  return 0
}

# =============================================================================
# Test 4: No remote URL download in uninstall.sh
# =============================================================================
test_no_remote_lang_download_in_uninstall() {
  log_info "Testing: uninstall.sh should not download lang files from GitHub"

  if grep -q 'curl.*githubusercontent.*lang.*\.lang' "$PROJECT_ROOT/uninstall.sh"; then
    log_fail "uninstall.sh still downloads lang files from remote URL"
    return 1
  fi

  log_pass "uninstall.sh does not download lang files remotely"
  return 0
}

# =============================================================================
# Test 5: install.sh sources lang file from local filesystem
# =============================================================================
test_install_sources_local_lang() {
  log_info "Testing: install.sh should source lang file from local filesystem"

  # Should contain: . "$INSTALL_DIR/src/lang/..." or source command
  if ! grep -q '\. .*INSTALL_DIR.*lang.*\.lang' "$PROJECT_ROOT/install.sh" && \
     ! grep -q 'source.*INSTALL_DIR.*lang.*\.lang' "$PROJECT_ROOT/install.sh"; then
    log_fail "install.sh does not source lang file from local INSTALL_DIR"
    return 1
  fi

  log_pass "install.sh sources lang file from local filesystem"
  return 0
}

# =============================================================================
# Test 6: uninstall.sh sources lang file from local filesystem
# =============================================================================
test_uninstall_sources_local_lang() {
  log_info "Testing: uninstall.sh should source lang file from local filesystem"

  # uninstall.sh runs from ~/.direnv, so should load from HOME or current dir
  if ! grep -q '\. .*lang.*\.lang' "$PROJECT_ROOT/uninstall.sh" && \
     ! grep -q 'source.*lang.*\.lang' "$PROJECT_ROOT/uninstall.sh"; then
    log_fail "uninstall.sh does not source lang file from local filesystem"
    return 1
  fi

  log_pass "uninstall.sh sources lang file from local filesystem"
  return 0
}

# =============================================================================
# Test 7: Lang files exist in repository
# =============================================================================
test_lang_files_exist() {
  log_info "Testing: Language files should exist in src/lang/"

  if [ ! -f "$PROJECT_ROOT/src/lang/en.lang" ]; then
    log_fail "src/lang/en.lang does not exist"
    return 1
  fi

  if [ ! -f "$PROJECT_ROOT/src/lang/ko.lang" ]; then
    log_fail "src/lang/ko.lang does not exist"
    return 1
  fi

  log_pass "Language files exist in src/lang/"
  return 0
}

# =============================================================================
# Test 8: pack.sh includes src directory (which contains lang files)
# =============================================================================
test_pack_includes_src() {
  log_info "Testing: pack.sh should include src directory in tar.gz"

  if ! grep -q 'tar.*src' "$PROJECT_ROOT/pack.sh"; then
    log_fail "pack.sh does not include src directory in tar.gz"
    return 1
  fi

  log_pass "pack.sh includes src directory (with lang files)"
  return 0
}

# =============================================================================
# Test 9: Verify tar.gz would contain lang files (if dist exists)
# =============================================================================
test_tarball_contains_lang_files() {
  log_info "Testing: Generated tar.gz should contain lang files"

  # Find the latest tar.gz in dist/
  LATEST_TAR=$(find "$PROJECT_ROOT/dist" -name "direnv-*.tar.gz" 2>/dev/null | head -n 1)

  if [ -z "$LATEST_TAR" ]; then
    log_info "No tar.gz found in dist/ - skipping tarball content test"
    return 0
  fi

  # Check if lang files are in the tarball
  if ! tar -tzf "$LATEST_TAR" | grep -q 'src/lang/en.lang'; then
    log_fail "Tarball does not contain src/lang/en.lang"
    return 1
  fi

  if ! tar -tzf "$LATEST_TAR" | grep -q 'src/lang/ko.lang'; then
    log_fail "Tarball does not contain src/lang/ko.lang"
    return 1
  fi

  log_pass "Tarball contains language files"
  return 0
}

# =============================================================================
# Run all tests
# =============================================================================
echo ""
echo "=========================================="
echo "  Secure Installation Tests (TDD)"
echo "=========================================="
echo ""

test_no_eval_in_install
test_no_eval_in_uninstall
test_no_remote_lang_download_in_install
test_no_remote_lang_download_in_uninstall
test_install_sources_local_lang
test_uninstall_sources_local_lang
test_lang_files_exist
test_pack_includes_src
test_tarball_contains_lang_files

echo ""
echo "=========================================="
if [ "$FAILED" -eq 0 ]; then
  printf "${GREEN}✅ All tests passed!${NC}\n"
else
  printf "${RED}❌ Some tests failed!${NC}\n"
fi
echo "=========================================="
echo ""

# CI 환경에서만 실패 시 exit 1
if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
