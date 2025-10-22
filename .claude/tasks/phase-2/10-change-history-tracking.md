# Environment Variable Change History Tracking

**Task ID**: `task-10`
**Assignee**: (TBD)
**Start Date**: (TBD)
**Completion Date**: (TBD)
**Status**: ⚪ Planned

---

## 🔗 Task Relationships

**Parent Task**: None - Phase 2 task
**Child Tasks**: None

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/change-history-tracking`
**PR Link**: (Update after task completion)

---

## 📋 Task Overview

### Goal
Implement a system to track environment variable changes made by direnv, allowing users to view history, diff changes, and rollback to previous states.

### Background
Users may want to:
- See what environment variables changed when entering a directory
- Compare current environment with previous state
- Rollback problematic environment changes
- Debug environment-related issues

### Scope
**Included**:
- [ ] Track env var changes (added, modified, removed)
- [ ] Store change history in tmp directory
- [ ] Command to view change history
- [ ] Command to show diff between states
- [ ] Command to rollback to previous state

**Excluded**:
- Long-term history storage (only recent changes)
- Change synchronization across sessions
- GUI or visual diff tools

---

## 💡 Design and Approach

### Technical Approach
- Store snapshots in `$DIRENV_TMP_DIR/history/`
- Track timestamp, directory, and variable changes
- Implement commands: `direnv history`, `direnv diff`, `direnv rollback`
- Use POSIX-compliant storage format

### Related Files
- `src/load.sh` - Capture changes
- `src/history.sh` - History management (new)
- `$DIRENV_TMP_DIR/` - History storage

---

## ✅ Completion Checklist

- [ ] Change tracking implemented
- [ ] History storage implemented
- [ ] `direnv history` command
- [ ] `direnv diff` command
- [ ] `direnv rollback` command
- [ ] Tests added
- [ ] Documentation updated

---

**Last Updated**: 2025-10-22
