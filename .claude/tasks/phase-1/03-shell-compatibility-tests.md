# Shell Compatibility Tests

**Task ID**: `task-03`
**Assignee**: (TBD)
**Start Date**: (TBD)
**Completion Date**: (TBD)
**Status**: ⚪ Planned

---

## 🔗 Task Relationships

**Parent Task**: None - Phase 1 task
**Child Tasks**: None

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/shell-compatibility-tests`
**PR Link**: (Update after task completion)

---

## 📋 Task Overview

### Goal
Add comprehensive compatibility tests for various shell environments (bash, zsh, ksh) to ensure direnv works correctly across different shells while maintaining POSIX compliance.

### Background
direnv is designed to work across multiple shell environments. Currently, test coverage for shell-specific behaviors may be incomplete. We need systematic tests to verify:
- Basic functionality works in all supported shells
- POSIX compliance is maintained
- Shell-specific edge cases are handled
- No bash/zsh-isms leak into the codebase

### Scope
**Included**:
- [ ] bash compatibility test suite
- [ ] zsh compatibility test suite
- [ ] ksh compatibility test suite
- [ ] Test framework for running tests across multiple shells
- [ ] CI integration for multi-shell testing

**Excluded**:
- Fish shell tests (different syntax, may need separate approach)
- Performance testing (covered in task-05)
- Interactive shell features

---

## 💡 Design and Approach

### Initial Ideas
1. Extend existing test framework in `test/` directory
2. Create shell-specific test files or parameterize existing tests
3. Use container or VM-based testing for consistent environments
4. Test critical paths: init, load, unload, allow, deny

### Technical Approach
- Leverage existing `test/` directory structure
- Use POSIX-compliant test patterns
- Test matrix: [bash, zsh, ksh] × [test cases]
- Ensure tests can run in CI environment

### Related Files
- `test/` - Existing test directory
- `Makefile` - Test execution targets
- `.github/workflows/` - CI configuration (if exists)

### Expected Issues
- Shell availability in CI environment
- Subtle differences in shell behavior (e.g., array handling, string operations)
- POSIX vs shell-specific features detection

---

## 📝 Progress Log

(To be filled during implementation)

---

## 🔧 Technical Decisions

(To be filled during implementation)

---

## 📁 Related Files

### Created Files
- [ ] `test/bash-compat.sh` - bash-specific tests
- [ ] `test/zsh-compat.sh` - zsh-specific tests
- [ ] `test/ksh-compat.sh` - ksh-specific tests
- [ ] `test/multi-shell-runner.sh` - Test runner for multiple shells

### Modified Files
- [ ] `Makefile` - Add multi-shell test targets
- [ ] `test/README.md` - Document new test structure (if exists)

---

## 🐛 Issues and Solutions

(To be filled during implementation)

---

## ✅ Completion Checklist

### Feature Implementation
- [ ] bash test suite implemented
- [ ] zsh test suite implemented
- [ ] ksh test suite implemented
- [ ] Multi-shell test runner created

### Code Quality
- [ ] All tests pass in bash
- [ ] All tests pass in zsh
- [ ] All tests pass in ksh
- [ ] POSIX compatibility verified
- [ ] No shellcheck warnings

### Testing
- [ ] Tests run successfully in local environment
- [ ] Tests run successfully in CI
- [ ] Edge cases covered
- [ ] Error cases tested

### Documentation
- [ ] Test documentation updated
- [ ] README updated with new test instructions
- [ ] Comments added to complex test logic

### Commits
- [ ] Commits separated by semantic units
- [ ] Commit message convention followed
- [ ] Final `git status` checked

---

## 🔗 References

- [POSIX Shell Specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- Existing `test/` directory structure
- [Commit Guidelines](../../commit-guidelines.md)

---

## 📌 Notes

- This task is foundational for ensuring cross-shell compatibility
- Should be coordinated with task-04 (edge case tests) to avoid duplication
- Consider using Docker for consistent shell environments in CI

---

**Last Updated**: 2025-10-22
