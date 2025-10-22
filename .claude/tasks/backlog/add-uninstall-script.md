# Add Uninstall Script

**Task ID**: `task-uninstall-script`
**Assignee**: Yonghyun Kim (Freddy) (Claude Code)
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
**Current Branch**: `feat/add-uninstall-script`
**PR Link**: (Update after task completion)

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
- Created task document
- Planned implementation approach
- Created feature branch `feat/add-uninstall-script`
- Ready to implement

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
- [ ] `uninstall.sh` - Main uninstall script

### Modified Files
- [ ] `src/lang/en.lang` - Add uninstall messages
- [ ] `src/lang/ko.lang` - Add uninstall messages
- [ ] `install.sh` - Download uninstall.sh to ~/.direnv/
- [ ] `CLAUDE.md` - Update uninstall documentation
- [ ] `README.md` - Update uninstall section
- [ ] `README.ko.md` - Update uninstall section

---

## ✅ Completion Checklist

### Feature Implementation
- [ ] uninstall.sh script created
- [ ] Language detection implemented
- [ ] Shell rc file detection implemented
- [ ] Backup creation implemented
- [ ] Line removal logic implemented
- [ ] Directory removal implemented
- [ ] Confirmation prompt added
- [ ] install.sh updated to include uninstall.sh

### Code Quality
- [ ] `make test` passes
- [ ] POSIX compatibility verified
- [ ] No shellcheck warnings
- [ ] Error handling added

### Testing
- [ ] Manual test: Run uninstall.sh
- [ ] Verify shell rc file cleaned correctly
- [ ] Verify backup file created
- [ ] Verify ~/.direnv removed
- [ ] Test with different shells (bash, zsh)
- [ ] Test cancellation prompt

### Documentation
- [ ] Progress log updated
- [ ] CLAUDE.md updated
- [ ] README.md updated
- [ ] README.ko.md updated

### Commits
- [ ] Commits separated by semantic units
- [ ] Commit convention followed
- [ ] Final git status checked

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
