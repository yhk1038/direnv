# Security Guidelines

**Task ID**: `task-07`
**Assignee**: (TBD)
**Start Date**: (TBD)
**Completion Date**: (TBD)
**Status**: ⚪ Planned

---

## 🔗 Task Relationships

**Parent Task**: None - Phase 1 task
**Child Tasks**: None
**Related Tasks**:
- [08-file-permission-check.md](08-file-permission-check.md) - Implements some security measures
- [backlog/sensitive-info-handling.md](../backlog/sensitive-info-handling.md) - Related to security

---

## 🌿 Branch Information

**Parent Branch**: `main`
**Current Branch**: `feat/security-guidelines`
**PR Link**: (Update after task completion)

---

## 📋 Task Overview

### Goal
Create comprehensive security guidelines for direnv users and contributors to help prevent common security issues when using directory-based environment management.

### Background
direnv executes code from .envrc files when entering directories, which poses security risks:
- Malicious .envrc files in untrusted directories
- Accidental exposure of sensitive credentials
- Permission and ownership vulnerabilities
- Path injection attacks
- Command injection through environment variables

Users need clear guidelines to use direnv securely.

### Scope
**Included**:
- [ ] Security best practices for .envrc files
- [ ] Guidelines for storing sensitive information
- [ ] File permission recommendations
- [ ] Code review guidelines for .envrc files
- [ ] Common security pitfalls and how to avoid them
- [ ] Security checklist for users

**Excluded**:
- Implementation of security features (covered in task-08 and backlog tasks)
- Automated security scanning (potential future task)
- Compliance/regulatory guidance

---

## 💡 Design and Approach

### Initial Ideas
Document structure:
1. Security model overview
2. Threat model (what attacks are possible)
3. Best practices for users
4. Best practices for .envrc authors
5. Security checklist
6. Incident response (what to do if compromised)

Key topics:
- Never execute .envrc from untrusted sources without review
- Use `direnv allow` deliberately, not automatically
- Don't store secrets in .envrc (use secret management tools)
- File permission recommendations
- Git considerations (.envrc in version control)

### Technical Approach
- Create `SECURITY.md` in repository root (GitHub standard)
- Clear, actionable guidance with examples
- Link from README and other relevant docs
- Include real-world scenarios and examples

### Related Files
- `README.md` - Link to security guidelines
- `.envrc` examples - Security considerations

### Expected Issues
- Balancing security with usability
- Keeping guidelines practical and actionable
- Covering diverse use cases and threat models

---

## 📝 Progress Log

(To be filled during implementation)

---

## 🔧 Technical Decisions

(To be filled during implementation)

---

## 📁 Related Files

### Created Files
- [ ] `SECURITY.md` - Main security guidelines document

### Modified Files
- [ ] `README.md` - Link to security guidelines
- [ ] `docs/` - Add security section (if applicable)

---

## 🐛 Issues and Solutions

(To be filled during implementation)

---

## ✅ Completion Checklist

### Feature Implementation
- [ ] Threat model documented
- [ ] Best practices written
- [ ] Security checklist created
- [ ] Examples and scenarios included
- [ ] Incident response guidance added

### Code Quality
- [ ] All examples tested
- [ ] Links verified
- [ ] Formatting consistent
- [ ] Technically accurate

### Testing
- [ ] Reviewed by security-conscious users (if possible)
- [ ] Examples verified
- [ ] Recommendations are practical

### Documentation
- [ ] Clear and accessible to non-security experts
- [ ] Actionable recommendations
- [ ] Linked from README
- [ ] Cross-references to related docs

### Commits
- [ ] Commits separated by semantic units
- [ ] Commit message convention followed
- [ ] Final `git status` checked

---

## 🔗 References

- [GitHub Security Policy Template](https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- Existing direnv security features (e.g., `direnv allow`)
- [Commit Guidelines](../../commit-guidelines.md)

---

## 📌 Notes

- Security is a critical concern for direnv due to code execution model
- Balance paranoia with practical usability
- Consider different threat models (personal dev machine vs shared server)
- Update as new security issues are discovered

---

## 📋 Topics to Cover (Draft)

1. **Security Model**
   - How direnv executes code
   - Trust model with `direnv allow`
   - Threat scenarios

2. **Best Practices**
   - Review .envrc before allowing
   - File permissions (600 or 644)
   - File ownership verification
   - Never auto-allow untrusted directories

3. **Sensitive Information**
   - Don't hardcode secrets in .envrc
   - Use external secret management
   - Git considerations (.gitignore patterns)
   - Environment variable visibility

4. **Common Pitfalls**
   - Command injection via env vars
   - Path manipulation attacks
   - Malicious .envrc in cloned repos
   - Overly permissive .envrc files

5. **Security Checklist**
   - [ ] Review .envrc content before `direnv allow`
   - [ ] Verify file ownership
   - [ ] Check file permissions
   - [ ] Avoid hardcoded secrets
   - [ ] Use version control carefully

6. **Incident Response**
   - What to do if malicious .envrc executed
   - How to audit env var changes
   - Recovery steps

---

**Last Updated**: 2025-10-22
