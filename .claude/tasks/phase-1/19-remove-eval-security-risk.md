# Remove eval Security Risk from Install Scripts

**Task ID**: `task-19`
**Assignee**: Yonghyun Kim (Freddy) (Claude Code)
**Start Date**: 2025-10-23
**Completion Date**: 2025-10-23
**Status**: 🟢 Complete

---

## 🔗 Task Relationships

**Parent Task**: None - Phase 1 security task
**Child Tasks**: None
**Related Tasks**:
- [08-file-permission-check.md](08-file-permission-check.md) - Another security enhancement
- [07-security-guidelines.md](07-security-guidelines.md) - Security documentation

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/remove-eval-security-risk`
**PR Link**: (Update after task completion)

---

## 📋 Task Overview

### Goal
Remove the dangerous `eval` of remote content in install.sh and uninstall.sh, replacing it with safe local file loading.

### Background
**Current security vulnerability**:
```sh
# install.sh:23-28 and uninstall.sh:22-28
LANG_CONTENT=$(curl -fsSL "$LANG_URL")
eval "$LANG_CONTENT"
```

**Risks**:
1. **Remote Code Execution**: If GitHub is compromised or DNS hijacked, arbitrary code can be executed
2. **No Integrity Verification**: No checksums or signatures
3. **Network Dependency**: Installation fails if GitHub is unreachable
4. **Trust Model Issue**: Users must trust the network path completely

### Scope
**Included**:
- [x] Include language files (en.lang, ko.lang) in release tar.gz
- [x] Modify install.sh to load from local extracted files
- [x] Modify uninstall.sh to load from local extracted files
- [x] Write tests to verify secure loading
- [x] Fallback mechanism if language file missing
- [x] Update release process to include lang files

**Excluded**:
- Removing eval from other scripts (none exist)
- Adding new languages (ja.lang can be added later)

---

## 💡 Design and Approach

### Initial Ideas

**Chosen approach: Include lang files in tar.gz**
1. Modify pack.sh to include src/lang/ in the archive
2. Install.sh extracts tar.gz → lang files are already there
3. Source lang files directly from local filesystem
4. No remote download needed

### Technical Approach

**Before** (insecure):
```sh
# Download and eval remote content
LANG_CONTENT=$(curl -fsSL "$LANG_URL")
eval "$LANG_CONTENT"
```

**After** (secure):
```sh
# Load from extracted local files
LANG_FILE="$INSTALL_DIR/src/lang/${LANG_CODE}.lang"
if [ -f "$LANG_FILE" ]; then
  . "$LANG_FILE"
else
  # Fallback to English
  . "$INSTALL_DIR/src/lang/en.lang"
fi
```

### TDD Approach

**Test 1: Verify lang files included in tar.gz**
```sh
test_lang_files_in_tarball() {
  tar -tzf direnv-*.tar.gz | grep -q "src/lang/en.lang"
  tar -tzf direnv-*.tar.gz | grep -q "src/lang/ko.lang"
}
```

**Test 2: Install without network (lang files available)**
```sh
test_install_without_network() {
  # Disconnect network simulation
  # Run install.sh
  # Verify lang variables loaded
}
```

**Test 3: No eval in install scripts**
```sh
test_no_eval_in_install() {
  ! grep "eval.*LANG_CONTENT" install.sh
}
```

### Related Files
- `install.sh` - Remove eval, load from local
- `uninstall.sh` - Remove eval, load from local
- `pack.sh` - Include lang files in tar.gz
- `release.sh` - Verify pack.sh includes lang files
- `.github/workflows/release.yml` - Update if needed

### Expected Issues

**Issue 1: Chicken-and-egg problem in install.sh**
- Problem: Lang files are inside tar.gz, but we need messages before extraction
- Solution: Use hardcoded minimal messages before extraction, load lang after extraction

**Issue 2: uninstall.sh runs from ~/.direnv**
- Problem: Lang files already available at ~/.direnv/src/lang/
- Solution: Load from installed location, with fallback

---

## 📝 Progress Log

### 2025-10-23 - Task Started & Completed (TDD)
- ✅ Created task document following workflow
- ✅ Analyzed security vulnerability in install.sh:23-28 and uninstall.sh:22-28
- ✅ Decided on approach: include lang files in tar.gz
- ✅ TDD RED phase: Wrote 9 failing tests in test/test_secure_install.sh
- ✅ TDD GREEN phase: Implemented solution
  - Modified install.sh to load lang from extracted files
  - Modified uninstall.sh to load lang from installed location
  - Added fallback messages for missing lang files
- ✅ All tests passing (existing + new security tests)
- ✅ Added new test to Makefile test suite
- ✅ Task completed in single day using TDD methodology

**Key Implementation Details**:
1. install.sh uses hardcoded English messages before extraction
2. After extraction, loads appropriate lang file from $INSTALL_DIR/src/lang/
3. uninstall.sh loads from ~/.direnv/src/lang/ with fallback
4. pack.sh already includes src/ directory (no changes needed)

---

## 🔧 Technical Decisions

### Decision 1: Include lang files in tar.gz vs hardcoding
- **Date**: 2025-10-23
- **Problem**: How to eliminate eval without losing i18n support
- **Options**:
  1. Include lang files in tar.gz (chosen)
  2. Hardcode all messages in install.sh
  3. Keep eval but add checksum verification
- **Decision**: Option 1 - Include in tar.gz
- **Reason**:
  - Most secure (no remote code execution)
  - Maintains clean i18n structure
  - No network dependency
  - Minimal complexity increase
  - Tar.gz size increase negligible (~2KB)

### Decision 2: Timing of lang file loading
- **Date**: 2025-10-23
- **Problem**: install.sh needs messages before tar.gz extraction
- **Options**:
  1. Hardcode minimal messages, load full lang after extraction
  2. Extract lang files first, then full extraction
  3. Inline all messages before extraction
- **Decision**: Option 1
- **Reason**:
  - Simple and clear
  - Only critical early messages hardcoded
  - Full i18n after extraction
  - No double extraction needed

---

## 📁 Related Files

### Created Files
- [x] `test/test_secure_install.sh` - Tests for secure installation

### Modified Files
- [x] `install.sh` - Remove eval, load from local filesystem
- [x] `uninstall.sh` - Remove eval, load from local filesystem
- [x] `Makefile` - Added new test to test suite
- [ ] `pack.sh` - No changes needed (already includes src/)
- [ ] `release.sh` - No changes needed

---

## 🐛 Issues and Solutions

(To be filled during implementation)

---

## ✅ Completion Checklist

### Feature Implementation
- [x] pack.sh includes src/lang/ in tar.gz (already included)
- [x] install.sh loads lang from extracted files
- [x] uninstall.sh loads lang from installed location
- [x] No eval statements in install/uninstall scripts
- [x] Fallback to English if lang file missing
- [x] Error handling for missing lang files

### Code Quality
- [x] `make test` passes (all 6 test suites passing)
- [x] New test file created and passing (9 tests)
- [x] POSIX compatibility verified
- [x] No shellcheck warnings
- [x] grep confirms no eval in scripts

### Testing
- [x] Test: lang files verified in src/
- [x] Test: no eval in install.sh
- [x] Test: no eval in uninstall.sh
- [x] Test: install sources local lang files
- [x] Test: uninstall sources local lang files

### Documentation
- [x] Progress log updated
- [x] Technical decisions recorded
- [x] Comments added to changed code
- [ ] CLAUDE.md updated (not needed for this change)

### Commits
- [x] Commits separated by semantic units (3 commits)
- [x] Commit message convention followed
- [x] Final `git status` checked

---

## 🔗 References

- [Personal task ideas](../personal/향후-개선-아이디어.md#4-installsh의-eval-제거-⭐⭐⭐) - Original security concern
- [OWASP - Code Injection](https://owasp.org/www-community/attacks/Code_Injection)
- [ShellCheck SC2294](https://www.shellcheck.net/wiki/SC2294) - eval security

---

## 📌 Notes

**Critical security improvement**:
- This change eliminates a **HIGH severity** security vulnerability
- Users will no longer execute arbitrary remote code during installation
- Network failures won't block installation
- More resilient and secure by design

**Testing philosophy**:
- TDD approach: write tests first
- Tests should fail initially
- Implementation makes tests pass
- Refactor with confidence

---

**Last Updated**: 2025-10-23
