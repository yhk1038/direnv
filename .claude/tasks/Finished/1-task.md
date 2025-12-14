# Add Uninstall Script

**Task ID**: `task-uninstall-script`
**Assignee**: Yonghyun Kim (Freddy) (Claude Code)
**Start Date**: 2025-10-22
**Completion Date**: 2025-10-22
**Status**: 🟢 Complete

---

## 🔗 Task Relationships

**Parent Task**: (None - top-level task)
**Child Tasks**: (None)

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/add-uninstall-script`
**PR Link**: https://github.com/yhk1038/direnv/pull/1 (Merged)

---

## 📋 Task Overview

### Goal
Create a clean and user-friendly uninstall script that removes direnv completely from the system, including:
- Shell configuration file cleanup
- Directory removal
- Multilingual support

### Background
Currently, users must manually:
1. Remove `~/.direnv` directory
2. Edit their shell rc files to remove direnv initialization lines
3. Remove the `de` alias

This is error-prone and leaves configuration fragments behind. An automated uninstall script will improve user experience.

### Scope
**Included**:
- [x] Create `uninstall.sh` script in project root
- [x] Auto-detect user's shell configuration file (.bashrc, .zshrc, etc.)
- [x] Remove direnv initialization lines from shell rc file
- [x] Create backup of shell rc file before modification
- [x] Remove `~/.direnv` directory
- [x] Add multilingual support (en, ko)
- [x] Add confirmation prompt before uninstalling
- [x] Update install.sh to download uninstall.sh to ~/.direnv/
- [x] Update documentation (CLAUDE.md, README.md, README.ko.md)

**Excluded**:
- Automatic backup restoration (user can manually restore from .backup file)
- Interactive selection of what to remove (all-or-nothing approach)

---

## 💡 Design and Approach

### Initial Ideas

**Uninstall Script Flow**:
1. Detect language (same as install.sh)
2. Load language messages
3. Show confirmation prompt
4. Detect shell rc file
5. Create backup of rc file
6. Remove direnv lines from rc file
7. Remove ~/.direnv directory
8. Show completion message

### Technical Approach

**File Structure**:
```
/uninstall.sh              # Standalone uninstall script
~/.direnv/uninstall.sh     # Copy installed by install.sh
```

**Language Support**:
- Reuse language detection logic from install.sh
- Add new message variables to src/lang/en.lang and src/lang/ko.lang

**Shell RC File Modification**:
```bash
# Lines to remove:
[ -f ~/.direnv/src/init.sh ] && source ~/.direnv/src/init.sh
alias de=". $HOME/.direnv/src/init.sh"
```

**Safety Features**:
- Create `.bashrc.backup` (or equivalent) before modification
- Show confirmation prompt before deletion
- Handle errors gracefully

### Related Files

**Created Files**:
- `uninstall.sh` - Main uninstall script

**Modified Files**:
- `src/lang/en.lang` - Add uninstall messages
- `src/lang/ko.lang` - Add uninstall messages
- `install.sh` - Download and save uninstall.sh to ~/.direnv/
- `CLAUDE.md` - Add uninstall documentation
- `README.md` - Update uninstall section
- `README.ko.md` - Update uninstall section

### Expected Issues

**Issue 1**: Different shell rc file formats
- **Solution**: Use same detection logic as install.sh

**Issue 2**: User might have modified direnv initialization lines
- **Solution**: Use flexible grep pattern matching

**Issue 3**: Multiple direnv installations
- **Solution**: Remove all matching lines, not just the first occurrence

---

## 📝 Progress Log

### 2025-10-22
- Created task document and planned implementation approach
- Created feature branch `feat/add-uninstall-script`
- Implemented uninstall.sh script with language detection and confirmation
- Added uninstall messages to src/lang/en.lang and src/lang/ko.lang
- Updated install.sh to download uninstall.sh during installation
- Updated documentation (CLAUDE.md, README.md, README.ko.md)
- Created PR #1 and merged to main
- Task completed successfully

---

## 🔧 Technical Decisions

### Decision 1: Uninstall Script Location
- **Date**: 2025-10-22
- **Problem**: Where should uninstall.sh be located?
- **Options**:
  1. Project root only (user downloads from GitHub)
  2. Installed to ~/.direnv/ during installation
  3. Both locations
- **Decision**: Both locations (Option 3)
- **Reason**:
  - Project root: Available for users who cloned the repo
  - ~/.direnv/: Convenient for installed users (run `sh ~/.direnv/uninstall.sh`)

### Decision 2: Confirmation Prompt
- **Date**: 2025-10-22
- **Problem**: Should we prompt user before uninstalling?
- **Options**:
  1. No prompt, uninstall immediately
  2. Prompt with y/N default
  3. Add --force flag for non-interactive mode
- **Decision**: Prompt with y/N default (Option 2)
- **Reason**: Safety first - prevent accidental uninstalls

### Decision 3: Backup Strategy
- **Date**: 2025-10-22
- **Problem**: Should we backup shell rc file?
- **Options**:
  1. No backup
  2. Create .backup file
  3. Ask user if they want backup
- **Decision**: Always create .backup file (Option 2)
- **Reason**: Safety - user can restore if something goes wrong

---

## 📁 Related Files

### Created Files
- [x] `uninstall.sh` - Main uninstall script

### Modified Files
- [x] `src/lang/en.lang` - Add uninstall messages
- [x] `src/lang/ko.lang` - Add uninstall messages
- [x] `install.sh` - Download uninstall.sh to ~/.direnv/
- [x] `CLAUDE.md` - Update uninstall documentation
- [x] `README.md` - Update uninstall section
- [x] `README.ko.md` - Update uninstall section

---

## ✅ Completion Checklist

### Feature Implementation
- [x] uninstall.sh script created
- [x] Language detection implemented
- [x] Shell rc file detection implemented
- [x] Backup creation implemented
- [x] Line removal logic implemented
- [x] Directory removal implemented
- [x] Confirmation prompt added
- [x] install.sh updated to include uninstall.sh

### Code Quality
- [x] `make test` passes (existing tests)
- [x] POSIX compatibility verified
- [x] Error handling added

### Testing
- [x] Script structure validated
- [x] Language messages verified
- [x] install.sh integration verified

### Documentation
- [x] Progress log updated
- [x] CLAUDE.md updated
- [x] README.md updated
- [x] README.ko.md updated

### Commits
- [x] Commits separated by semantic units
- [x] Commit convention followed
- [x] Final git status checked

---

## 🔗 References

- [install.sh](../../install.sh) - Reference for language detection and shell detection
- [Branching Strategy](../.claude/branching-strategy.md)
- [Commit Guidelines](../.claude/commit-guidelines.md)

---

## 📌 Notes

- Keep uninstall.sh simple and focused
- Mirror install.sh structure for consistency
- Prioritize safety over convenience

---

**Last Updated**: 2025-10-22

---

## 🎉 Completion Summary

Successfully implemented a clean uninstall script that provides:
- User-friendly confirmation prompt to prevent accidental removal
- Automatic shell configuration file detection and backup
- Safe removal of direnv initialization lines
- Complete cleanup of ~/.direnv directory
- Multilingual support (English and Korean)

The feature is now available to users via:
```bash
sh ~/.direnv/uninstall.sh
```

Or remotely:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/yhk1038/direnv/main/uninstall.sh)"
```

This significantly improves the user experience for those who need to remove direnv from their system.
