# Detailed Error Messages

**Task ID**: `task-05`
**Assignee**: (TBD)
**Start Date**: (TBD)
**Completion Date**: (TBD)
**Status**: ⚪ Planned

---

## 🔗 Task Relationships

**Parent Task**: None - Phase 1 task
**Child Tasks**: None
**Related Tasks**:
- [06-troubleshooting-guide.md](06-troubleshooting-guide.md) - Error messages should reference troubleshooting guide

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/detailed-error-messages`
**PR Link**: (Update after task completion)

---

## 📋 Task Overview

### Goal
Improve error messages throughout direnv to be more informative, actionable, and user-friendly, helping users quickly understand and resolve issues.

### Background
Current error messages may be:
- Too generic ("Error loading .envrc")
- Missing context (which file, which line)
- Not actionable (no suggestions for fixing)
- Inconsistent in format

Better error messages improve user experience and reduce support burden.

### Scope
**Included**:
- [ ] Audit existing error messages
- [ ] Add context to error messages (file path, line number, operation)
- [ ] Provide actionable suggestions where possible
- [ ] Standardize error message format
- [ ] Include exit codes for different error types

**Excluded**:
- Debug logging system (covered in backlog/debugging-logging-system.md)
- Error handling logic changes (only message improvements)
- Localization (English only)

---

## 💡 Design and Approach

### Initial Ideas
Error message format:
```
direnv: ERROR: [Component] [What went wrong]
  File: /path/to/.envrc:42
  Reason: [Detailed explanation]
  Suggestion: [How to fix]
```

Example:
```
direnv: ERROR: Failed to load .envrc
  File: /home/user/project/.envrc:15
  Reason: Permission denied (file owned by different user)
  Suggestion: Run 'direnv allow' or check file ownership
```

### Technical Approach
1. Audit all error messages in codebase
2. Create consistent error message functions
3. Add context variables to error sites
4. Define exit code standards
5. Update error messages throughout codebase

### Related Files
- `src/init.sh` - Main initialization errors
- `src/load.sh` - Loading errors
- `src/unload.sh` - Unloading errors
- All scripts in `src/` directory

### Expected Issues
- Maintaining POSIX compliance while adding formatted output
- Keeping messages concise yet informative
- Avoiding information disclosure (e.g., sensitive env var values)

---

## 📝 Progress Log

(To be filled during implementation)

---

## 🔧 Technical Decisions

(To be filled during implementation)

---

## 📁 Related Files

### Created Files
- [ ] `src/lib/error.sh` - Error message helper functions (optional)

### Modified Files
- [ ] `src/init.sh` - Improved error messages
- [ ] `src/load.sh` - Improved error messages
- [ ] `src/unload.sh` - Improved error messages
- [ ] Other scripts in `src/` as needed

---

## 🐛 Issues and Solutions

(To be filled during implementation)

---

## ✅ Completion Checklist

### Feature Implementation
- [ ] Error message audit completed
- [ ] Error message format standardized
- [ ] Context added to all error messages
- [ ] Actionable suggestions included where possible
- [ ] Exit codes documented

### Code Quality
- [ ] `make test` passes
- [ ] POSIX compatibility verified
- [ ] No shellcheck warnings
- [ ] Error messages don't expose sensitive information

### Testing
- [ ] Error messages tested in various failure scenarios
- [ ] Error messages are clear and helpful
- [ ] Exit codes are consistent

### Documentation
- [ ] Error messages documented
- [ ] Exit codes documented
- [ ] Troubleshooting guide updated (task-06)

### Commits
- [ ] Commits separated by semantic units
- [ ] Commit message convention followed
- [ ] Final `git status` checked

---

## 🔗 References

- [Good Error Messages Guide](https://www.nngroup.com/articles/error-message-guidelines/)
- [POSIX Exit Codes](https://tldp.org/LDP/abs/html/exitcodes.html)
- [Commit Guidelines](../../commit-guidelines.md)

---

## 📌 Notes

- Balance between detail and brevity
- Consider color output (may be task-17 dependency)
- Should coordinate with troubleshooting guide (task-06)

---

**Last Updated**: 2025-10-22
