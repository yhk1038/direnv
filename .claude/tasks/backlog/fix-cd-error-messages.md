# Fix: CD Error Messages on Directory Change

**Task ID**: `fix-cd-error-01`
**Assignee**: Yonghyun Kim (Freddy) (Claude Code)
**Start Date**: 2025-10-22
**Completion Date**: (TBD)
**Status**: 🟡 In Progress

---

## 🔗 Task Relationships

**Parent Task**: None - Bug fix task
**Child Tasks**: None

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/fix-cd-error-messages`
**PR Link**: (Update after task completion)

---

## 📋 Task Overview

### Goal
Fix error console output when changing directories (`cd`) in direnv by suppressing non-critical error messages and adding debug mode for troubleshooting.

### Background
**Bug Report**: When using `cd` to change directories, unwanted error messages are displayed to the user. This happens in all cases except when moving from a non-applicable folder (without `.envrc` or `.profile`) to an applicable folder (with `.envrc` or `.profile`).

**Affected Scenarios**:
- ✅ Non-applicable → Applicable: No error (works correctly)
- ❌ Applicable → Applicable: Error messages appear
- ❌ Applicable → Non-applicable: Error messages appear
- ❌ Non-applicable → Non-applicable: Error messages appear

**Root Cause**: In [src/scripts/unload_current_dir_env.sh](../../src/scripts/unload_current_dir_env.sh#L11-L18), `unalias` and `unset` commands output error messages when trying to remove aliases/variables that no longer exist.

### Scope
**Included**:
- [ ] Add `DIRENV_DEBUG` environment variable support for debugging
- [ ] Suppress error messages from `unalias` and `unset` in normal mode
- [ ] Keep error messages visible in debug mode
- [ ] Test all directory change patterns

**Excluded**:
- Comprehensive debugging/logging system (already in backlog/debugging-logging-system.md)
- Error message format improvements (already in phase-1/05-detailed-error-messages.md)

---

## 💡 Design and Approach

### Bug Analysis

**Error Location**: [src/scripts/unload_current_dir_env.sh](../../src/scripts/unload_current_dir_env.sh)

```sh
# Line 11-13: Removing aliases
grep '^alias ' "$CURRENT_ENV_FILE" | sed 's/^alias //' | while IFS='=' read name value; do
  unalias "$name"  # ⚠️ Error output when alias doesn't exist
done

# Line 16-18: Removing environment variables
grep '^export ' "$CURRENT_ENV_FILE" | sed 's/^export //' | while IFS='=' read name value; do
  unset "$name"  # ⚠️ Error output when variable doesn't exist
done
```

**Why Errors Occur**:
1. `CURRENT_ENV_FILE` exists (indicates environment was loaded)
2. But aliases/variables may have been already removed
3. Attempting to `unalias`/`unset` non-existent items triggers error messages

**State Inconsistency Scenarios**:
- User manually unalias/unset
- Multiple directory changes
- Other scripts modifying the environment
- Previous unload partially succeeded

### Solution Approach

**Decision: Option A (Error Suppression) + Debug Mode**

After discussion, we chose **Option A** over **Option B**:

#### Option A: Error Suppression (✅ Chosen)
```sh
unalias "$name" 2>/dev/null
unset "$name" 2>/dev/null
```

**Pros**:
- Simple and quick
- `unalias`/`unset` are idempotent operations (removing non-existent items is not an error, just "already completed")
- Better user experience (no noise)

**Cons**:
- Hides the underlying state inconsistency

#### Option B: State Management Improvement (❌ Rejected)
```sh
if alias "$name" >/dev/null 2>&1; then
  unalias "$name"
fi
```

**Pros**:
- Prevents state inconsistency

**Cons**:
- More complex code
- Difficult to track state perfectly in POSIX shell environment
- Users can still modify environment externally

### Technical Decisions Rationale

**Why Option A is appropriate**:

1. **Idempotency**: `unalias`/`unset` should be idempotent operations
   - Removing something that's already gone is "already completed", not an error

2. **POSIX Shell Limitations**: Perfect state tracking is difficult
   - Users can manually `unalias` something
   - Other scripts can change the environment
   - Backup files may be out of sync with actual state

3. **User Experience**: Error messages create confusion
   - Users see errors and think "something went wrong"
   - In reality, it's normal operation with harmless noise

4. **Debug Mode**: Add `DIRENV_DEBUG=1` for troubleshooting
   - Normal mode: Silent operation (errors suppressed)
   - Debug mode: Verbose output (errors visible)
   - Best of both worlds

### Debug Mode Implementation

```sh
# Check if debug mode is enabled
if [ "$DIRENV_DEBUG" = "1" ]; then
  # Don't suppress errors in debug mode
  unalias "$name"
  unset "$name"
else
  # Suppress errors in normal mode
  unalias "$name" 2>/dev/null
  unset "$name" 2>/dev/null
fi
```

### Related Files
- [src/scripts/unload_current_dir_env.sh](../../src/scripts/unload_current_dir_env.sh) - Main fix location
- [mock-directories/](../../mock-directories/) - Test fixtures

### Expected Issues
- None (simple change)

---

## 📝 Progress Log

### 2025-10-22
- Bug reported by user
- Investigated root cause in unload_current_dir_env.sh
- Discussed solution approaches (Option A vs Option B)
- Decided on Option A (error suppression) + debug mode
- Documented design decisions and rationale
- Created task document

---

## 🔧 Technical Decisions

### Decision 1: Error Suppression vs State Management
- **Date**: 2025-10-22
- **Problem**: `unalias`/`unset` commands output errors when items don't exist
- **Options**:
  1. **Option A**: Suppress errors with `2>/dev/null` + add debug mode
  2. **Option B**: Check existence before removal (`if alias "$name"; then unalias "$name"; fi`)
- **Decision**: Option A (error suppression) + debug mode
- **Reason**:
  - `unalias`/`unset` are idempotent operations
  - Perfect state tracking is difficult in POSIX shell
  - Better user experience (no unnecessary error noise)
  - Debug mode provides visibility when needed
  - Simpler code, easier to maintain

### Decision 2: Debug Mode Implementation
- **Date**: 2025-10-22
- **Problem**: Need visibility for troubleshooting while keeping normal operation clean
- **Options**:
  1. Always suppress errors
  2. Add `DIRENV_DEBUG=1` environment variable
  3. Add verbose flag to commands
- **Decision**: `DIRENV_DEBUG=1` environment variable
- **Reason**:
  - Simple to use (`DIRENV_DEBUG=1 cd some-dir`)
  - Consistent with common conventions (DEBUG, VERBOSE env vars)
  - Can be set globally for entire session
  - Foundation for future comprehensive logging system (backlog/debugging-logging-system.md)

---

## 📁 Related Files

### Created Files
- [ ] This task document

### Modified Files
- [ ] [src/scripts/unload_current_dir_env.sh](../../src/scripts/unload_current_dir_env.sh) - Add debug mode and error suppression

---

## 🐛 Issues and Solutions

### Issue 1: CD Error Messages
- **Date**: 2025-10-22
- **Symptom**: Error messages appear when changing directories in most cases
- **Cause**: `unalias` and `unset` output errors when items don't exist
- **Solution**: Suppress errors in normal mode, show in debug mode
- **Reference**: This task document

---

## ✅ Completion Checklist

### Feature Implementation
- [ ] Debug mode (`DIRENV_DEBUG=1`) implemented
- [ ] Error suppression in normal mode (`2>/dev/null`)
- [ ] Error visibility in debug mode

### Code Quality
- [ ] `make test` passes
- [ ] POSIX compatibility verified
- [ ] No unintended side effects

### Testing
- [ ] Tested: Non-applicable → Applicable (should still work)
- [ ] Tested: Applicable → Applicable (errors should be suppressed)
- [ ] Tested: Applicable → Non-applicable (errors should be suppressed)
- [ ] Tested: Non-applicable → Non-applicable (errors should be suppressed)
- [ ] Tested: Debug mode (`DIRENV_DEBUG=1`) shows errors
- [ ] All existing tests pass (`make test`)

### Documentation
- [ ] This document's progress log updated
- [ ] README updated (if needed - probably not for this small fix)
- [ ] Comments added explaining debug mode

### Commits
- [ ] Task document committed to main
- [ ] Code changes committed with conventional commit message
- [ ] Final `git status` checked

---

## 🔗 References

- [unload_current_dir_env.sh](../../src/scripts/unload_current_dir_env.sh) - File to be modified
- [debugging-logging-system.md](./debugging-logging-system.md) - Future comprehensive logging system
- [mock-directories/](../../mock-directories/) - Test fixtures

---

## 📌 Notes

**Why this is a quick fix**:
- Only ~2 lines need to change in unload_current_dir_env.sh
- Debug mode check can be simple conditional
- Tests already exist in mock-directories/

**Future Improvements** (not in this task):
- Comprehensive logging system (see backlog/debugging-logging-system.md)
- Better state tracking (if needed based on user feedback)
- Performance profiling with debug mode

**User Impact**:
- ✅ Cleaner console output during normal use
- ✅ Still able to debug issues with `DIRENV_DEBUG=1`
- ✅ No behavior change, only error message visibility

---

**Last Updated**: 2025-10-22
