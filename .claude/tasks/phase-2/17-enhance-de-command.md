# Enhance `de` Command with Subcommands

**Task ID**: `task-17`
**Assignee**: Yonghyun Kim (Claude Code)
**Start Date**: 2025-10-22
**Completion Date**: (TBD)
**Status**: 🟡 In Progress

---

## 🔗 Task Relationships

**Parent Task**: (None - top-level task)
**Child Tasks**: (None)

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/enhance-de-command`
**PR Link**: (Update after task completion)

---

## 📋 Task Overview

### Goal
Transform the `de` alias into a full-featured function that supports subcommands for version management and information display.

### Background
Currently, `de` is a simple alias that only reinitializes direnv:
```bash
alias de=". $HOME/.direnv/src/init.sh"
```

Users need a more convenient way to:
- Update direnv to the latest or specific version
- Check available versions
- See current and latest version info

### Scope
**Included**:
- [x] Convert `de` alias to function
- [x] Implement `de` (no args) - reinitialize direnv (existing behavior)
- [x] Implement `de update` - update to latest version
- [x] Implement `de update <version>` - update to specific version
- [x] Implement `de versions` - list available versions
- [x] Implement `de --help` - show help message
- [x] Update install.sh to use function instead of alias
- [x] Add multilingual support for new messages

**Excluded**:
- Version rollback functionality
- Auto-update on startup
- Update notifications

---

## 💡 Design and Approach

### Initial Ideas
1. Create a new script `src/scripts/de_command.sh` containing the `de()` function
2. Use `case` statement to handle subcommands
3. Leverage GitHub API to fetch version information
4. Reuse install.sh for update functionality

### Technical Approach
- **Subcommand Parsing**: Use POSIX-compliant `case` statement
- **Version Management**: Read current version from `VERSION` file, fetch releases from GitHub API
- **Update Mechanism**: Download and execute install.sh with specific version
- **Error Handling**: Graceful fallback when network unavailable

### Related Files
- `src/scripts/de_command.sh` (new) - Main de() function implementation
- `src/init.sh` - Source de_command.sh
- `install.sh` - Update RC file generation logic
- `src/lang/*.lang` - Add new message strings

### Expected Issues
1. **GitHub API rate limiting**: Add error handling for API failures
2. **Network dependency**: Provide clear error messages when offline
3. **POSIX compatibility**: Avoid bash-specific features (arrays, [[, etc.)
4. **Version parsing**: Handle various version formats (v0.1.0, 0.1.0)

---

## 📝 Progress Log

### 2025-10-22
- Task document created and committed to main
- Starting implementation of de_command.sh

---

## 🔧 Technical Decisions

### Decision 1: Function vs Alias
- **Date**: 2025-10-22
- **Problem**: Alias cannot handle arguments, need subcommand support
- **Options**:
  1. Keep alias and create separate commands (de-update, de-versions)
  2. Convert to function to support subcommands
- **Decision**: Convert to function
- **Reason**: More user-friendly, follows common CLI patterns (git, npm, etc.)

### Decision 2: Update Implementation
- **Date**: 2025-10-22
- **Problem**: How to implement version update functionality
- **Options**:
  1. Manually download and extract files
  2. Reuse install.sh script
- **Decision**: Reuse install.sh with version parameter
- **Reason**: DRY principle, leverage existing tested logic

### Decision 3: Version Information Source
- **Date**: 2025-10-22
- **Problem**: Where to fetch version information
- **Options**:
  1. Maintain separate version list file
  2. Query GitHub API releases
- **Decision**: Query GitHub API
- **Reason**: Single source of truth, always up-to-date

---

## 📁 Related Files

### Created Files
- [x] `src/scripts/de_command.sh` - Main de() function with subcommand handlers

### Modified Files
- [x] `src/init.sh` - Source de_command.sh instead of defining alias
- [x] `install.sh` - Update RC file generation to source de function
- [x] `src/lang/en.lang` - Add new messages
- [x] `src/lang/ko.lang` - Add new messages
- [x] `src/lang/ja.lang` - Add new messages

---

## 🐛 Issues and Solutions

(To be filled during implementation)

---

## ✅ Completion Checklist

### Feature Implementation
- [ ] `de` (no args) works - reinitializes direnv
- [ ] `de update` works - updates to latest version
- [ ] `de update v0.4.0` works - updates to specific version
- [ ] `de versions` works - shows version list with current/latest markers
- [ ] `de --help` works - displays help message
- [ ] Error handling for network failures
- [ ] Error handling for invalid versions

### Code Quality
- [ ] `make test` passes
- [ ] POSIX compatibility verified (no bash-specific syntax)
- [ ] No shellcheck warnings
- [ ] Comments added to complex logic

### Testing
- [ ] Local installation tested
- [ ] All subcommands tested manually
- [ ] Network failure scenarios tested
- [ ] Edge cases handled (invalid version, API unavailable)

### Documentation
- [ ] This document's progress log updated
- [ ] Technical decisions recorded
- [ ] README updated with new `de` usage
- [ ] Comments added to de_command.sh

### Commits
- [ ] Task document committed to main
- [ ] Feature commits separated by semantic units
- [ ] Commit message convention followed
- [ ] Final `git status` checked

---

## 🔗 References

- GitHub API Releases: https://api.github.com/repos/yhk1038/direnv/releases
- Install script: https://raw.githubusercontent.com/yhk1038/direnv/main/install.sh

---

## 📌 Notes

- User requested full autonomy for implementation
- Must ensure robust error handling and POSIX compliance
- Focus on safety and reliability

---

**Last Updated**: 2025-10-22
