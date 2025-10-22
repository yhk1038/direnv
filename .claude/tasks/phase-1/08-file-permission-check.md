# File Permission Check

**Task ID**: `task-08`
**Assignee**: (TBD)
**Start Date**: (TBD)
**Completion Date**: (TBD)
**Status**: ⚪ Planned

---

## 🔗 Task Relationships

**Parent Task**: None - Phase 1 task
**Child Tasks**: None
**Related Tasks**:
- [07-security-guidelines.md](07-security-guidelines.md) - Documents security best practices
- [backlog/sensitive-info-handling.md](../backlog/sensitive-info-handling.md) - Related security feature

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/file-permission-check`
**PR Link**: (Update after task completion)

---

## 📋 Task Overview

### Goal
Implement automated checks for .envrc file permissions and ownership to warn users about potentially insecure configurations before executing code.

### Background
Security risks with .envrc files:
- World-writable .envrc files can be modified by attackers
- Files owned by other users may contain malicious code
- Overly permissive permissions violate security best practices

direnv should detect and warn about these conditions before execution.

### Scope
**Included**:
- [ ] Check file ownership (must match current user or root)
- [ ] Check file permissions (warn if world-writable)
- [ ] Recommend proper permissions (600 or 644)
- [ ] Clear warning messages with remediation steps
- [ ] Optional strict mode to refuse insecure files

**Excluded**:
- ACL (Access Control List) checking (complex, platform-specific)
- SELinux/AppArmor integration
- Content scanning for secrets (covered in backlog)

---

## 💡 Design and Approach

### Initial Ideas
Check sequence before loading .envrc:
1. Verify file exists and is readable
2. Check ownership: `stat` or `ls -l` output
3. Check permissions: world-writable (o+w) is dangerous
4. Issue warnings or block execution based on findings

Warning levels:
- **ERROR**: File owned by different user → refuse to load
- **WARNING**: World-writable → warn but allow if already approved
- **INFO**: Recommended permissions → suggest chmod 600

### Technical Approach
- Add checks in `src/load.sh` or similar
- Use POSIX-compliant commands (`stat`, `ls`, `test`)
- Parse file ownership and permissions portably
- Integrate with existing `direnv allow` mechanism
- Provide clear remediation commands

### Related Files
- `src/load.sh` - Add permission checks before execution
- `src/init.sh` - May need early initialization checks

### Expected Issues
- Platform differences in `stat` command (macOS vs GNU/Linux)
- Parsing owner/permission output portably
- Balancing security with usability
- Handling symlinks and special files

---

## 📝 Progress Log

(To be filled during implementation)

---

## 🔧 Technical Decisions

(To be filled during implementation)

---

## 📁 Related Files

### Created Files
- [ ] `src/lib/security-check.sh` - Security check functions (optional)

### Modified Files
- [ ] `src/load.sh` - Add permission checks
- [ ] Error message functions - Add security warnings

---

## 🐛 Issues and Solutions

(To be filled during implementation)

---

## ✅ Completion Checklist

### Feature Implementation
- [ ] Ownership check implemented
- [ ] Permission check implemented
- [ ] Warning messages implemented
- [ ] Remediation suggestions provided
- [ ] Optional strict mode added

### Code Quality
- [ ] `make test` passes
- [ ] POSIX compatibility verified
- [ ] No shellcheck warnings
- [ ] Works on macOS and Linux

### Testing
- [ ] Test with various ownership scenarios
- [ ] Test with various permission scenarios
- [ ] Test warning messages are clear
- [ ] Test remediation commands work
- [ ] Edge cases handled (symlinks, etc.)

### Documentation
- [ ] Security checks documented
- [ ] User guide updated
- [ ] Error messages reference security guidelines
- [ ] Comments added to check logic

### Commits
- [ ] Commits separated by semantic units
- [ ] Commit message convention followed
- [ ] Final `git status` checked

---

## 🔗 References

- [POSIX File Permissions](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#tag_04_06)
- [stat command portability](https://stackoverflow.com/questions/3743793/portable-way-to-get-file-information-stat-in-bash)
- [Commit Guidelines](../../commit-guidelines.md)

---

## 📌 Notes

- Must be POSIX-compliant (no bash-isms)
- `stat` command syntax differs between macOS and GNU/Linux
- May need to use `ls -l` parsing for maximum portability
- Consider performance impact of additional checks

---

## 🔧 Implementation Details (Draft)

### Ownership Check
```sh
# POSIX-compliant ownership check
file_owner=$(ls -ld "$envrc_file" | awk '{print $3}')
current_user=$(whoami)

if [ "$file_owner" != "$current_user" ] && [ "$file_owner" != "root" ]; then
    error "Security: .envrc is owned by $file_owner, not $current_user"
fi
```

### Permission Check
```sh
# Check for world-writable
perms=$(ls -l "$envrc_file" | cut -c1-10)
if echo "$perms" | grep -q '........w.'; then
    warning "Security: .envrc is world-writable"
    warning "Recommended: chmod 600 $envrc_file"
fi
```

### Recommended Permissions
- **600** (rw------): Most secure, only owner can read/write
- **644** (rw-r--r--): Acceptable if file doesn't contain secrets
- **Avoid**: 666, 777, or any world-writable permission

---

**Last Updated**: 2025-10-22
