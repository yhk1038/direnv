# [Task Name]

**Task ID**: `task-XX`
**Assignee**: [Name] (Claude Code)
**Start Date**: YYYY-MM-DD
**Completion Date**: (TBD)
**Status**: 🟡 In Progress | 🟢 Complete | 🔴 On Hold | ⚪ Planned

> **Assignee Recording Rules**:
> - **Principle**: Record the **actual developer's name**, not "Claude"
> - Developer requests and Claude Code writes: `Developer Name (Claude Code)`
> - Developer works directly: `Developer Name`
> - **Examples**:
>   - `Yonghyun Kim (Claude Code)` ✅
>   - `김용현 (Claude Code)` ✅
>   - `Claude Code` ❌
>
> **Agent Guide**:
> - Infer developer name from `git config user.name`, `whoami`, `$HOME`, etc.
> - If ambiguous, confirm with user and remember during session

---

## 🔗 Task Relationships

**Parent Task**: (None - top-level task) or [Parent Task Document Link](../XX-parent-task.md)
**Child Tasks**:
- (None) or
- [Subtask 1](../YY-subtask-1.md)
- [Subtask 2](../ZZ-subtask-2.md)

---

## 🌿 Branch Information

**Parent Branch**: `main` (top-level task) or `feat/parent-task` (subtask)
**Current Branch**: `feat/[task-name]` or `feat/[parent-task]/[subtask-name]`
**PR Link**: (Update after task completion)

> **Branching Strategy**:
> - Top-level task: Commit planning doc to `main` → Create `feat/task-name` branch
> - Subtask: Work on parent branch, create `feat/parent-task/subtask-name` if needed
> - Details in [Branching Strategy Document](../branching-strategy.md)

---

## 📋 Task Overview

### Goal
[Briefly describe what you want to achieve with this task]

### Background
[Why this task is needed, what problem it solves]

### Scope
**Included**:
- [ ] [Feature to implement 1]
- [ ] [Feature to implement 2]

**Excluded**:
- [What is not covered in this task]

---

## 💡 Design and Approach

### Initial Ideas
[Brainstorming before starting, initial concepts]

### Technical Approach
[Which technologies/patterns to use]

### Related Files
[Scripts and files to modify or create]

### Expected Issues
[Potential problems and planned solutions]

---

## 📝 Progress Log

### YYYY-MM-DD
- [What was done]
- [Problems encountered]
- [How they were solved]

### YYYY-MM-DD
- [Continue logging]

---

## 🔧 Technical Decisions

### Decision 1: [Title]
- **Date**: YYYY-MM-DD
- **Problem**: [What problem existed]
- **Options**:
  1. [Option A]
  2. [Option B]
- **Decision**: [Chosen option]
- **Reason**: [Why this choice was made]

---

## 📁 Related Files

### Created Files
- [ ] `src/scripts/...` - [Description]
- [ ] `src/lang/...` - [Description]

### Modified Files
- [ ] `src/init.sh` - [What changed]
- [ ] `install.sh` - [What changed]

---

## 🐛 Issues and Solutions

### Issue 1: [Title]
- **Date**: YYYY-MM-DD
- **Symptom**: [What problem occurred]
- **Cause**: [Why it happened]
- **Solution**: [How it was solved]
- **Reference**: [Related links, commits, etc.]

---

## ✅ Completion Checklist

### Feature Implementation
- [ ] [Feature 1 complete]
- [ ] [Feature 2 complete]

### Code Quality
- [ ] `make test` passes
- [ ] POSIX compatibility verified
- [ ] No shellcheck warnings (if applicable)
- [ ] Comments added (where necessary)

### Testing
- [ ] Local environment tested
- [ ] Edge cases handled
- [ ] Error cases tested

### Documentation
- [ ] This document's progress log updated
- [ ] README updated (if user-facing changes)
- [ ] Comments added to complex logic

### Commits
- [ ] Separated by semantic units
- [ ] Commit message convention followed
- [ ] Final `git status` checked

---

## 🔗 References

- [Related issues/tickets]
- [Referenced documents]
- [Related commits]

---

## 📌 Notes

[Free-form notes]

---

**Last Updated**: YYYY-MM-DD
