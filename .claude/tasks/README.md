# Task Documentation Guide
# 작업 문서 관리 가이드

**Last Updated**: 2025-10-22

---

## Overview

This directory (`.claude/tasks/`) is where **all tasks** for the project are documented.

**Purpose**:
- Preserve task planning and design as documentation
- Share task details and facilitate collaboration
- Record project history and technical decisions
- Provide reference information for agents before starting work

---

## Directory Structure

```
.claude/tasks/
├── README.md           # This file (task documentation guide)
├── template.md         # Task document template
│
├── personal/           # Personal tasks (gitignored, any language)
│   ├── .gitkeep
│   └── ... (your personal notes and drafts)
│
├── 01-add-japanese-support.md
├── 02-improve-performance.md
└── ... (shared tasks, written in English)
```

### Shared vs Personal Tasks

**Shared Tasks** (committed to Git, written in English):
- Tasks that contribute to the project
- Collaborative work visible to all contributors
- Located directly in `.claude/tasks/`

**Personal Tasks** (gitignored, any language allowed):
- Personal experiments, drafts, notes
- Work-in-progress ideas not ready to share
- Located in `.claude/tasks/personal/`
- When ready to share, translate to English and move to shared area

---

## File Naming Convention

### Shared Tasks

```
XX-task-name-brief-description.md

Rules:
- XX: Two-digit number (01, 02, 03, ...)
- task-name: Concise and clear English words
- lowercase only
- words separated by hyphens (-)
- Maximum 4-5 words recommended

Examples:
✅ 01-add-japanese-lang-support.md
✅ 02-improve-env-loading-speed.md
✅ 03-fix-alias-backup-bug.md
✅ 15-add-multilanguage-docs.md

❌ japanese_support.md (underscore)
❌ JapaneseLanguageSupport.md (uppercase)
❌ 1-japanese.md (single digit)
❌ add-full-japanese-language-support-with-tests.md (too long)
```

### Personal Tasks

```
任意の名前.md (no restrictions)

Rules:
- No prefix numbers required
- Any language allowed (Korean, Japanese, etc.)
- Any naming convention you prefer

Examples:
✅ draft-caching-idea.md
✅ 실험적-기능-아이디어.md
✅ パフォーマンス改善メモ.md
```

---

## Creating Task Documents

### Using the Template

All shared task documents should be based on [`template.md`](template.md).

```bash
# 1. Copy template
cp .claude/tasks/template.md .claude/tasks/XX-task-name.md

# 2. Fill in the content
# - Task name, ID, assignee, etc.
# - Task overview, goals, scope
# - Technical approach
# - Related files

# 3. Commit (to main branch)
git add .claude/tasks/XX-task-name.md
git commit -m "docs: add task document for [task name]"
git push origin main
```

---

## Required Sections in Task Documents

### 1. Meta Information

```markdown
# [Task Name]

**Task ID**: `task-XX`
**Assignee**: [Developer Name] (Claude Code)
**Start Date**: YYYY-MM-DD
**Completion Date**: (TBD) or YYYY-MM-DD
**Status**: 🟡 In Progress | 🟢 Complete | 🔴 On Hold | ⚪ Planned
```

**Important**: The assignee should be the **actual developer's name**, not "Claude".

### 2. Task Overview

```markdown
## 📋 Task Overview

### Goal
[What you want to achieve with this task]

### Background
[Why this task is needed]

### Scope
**Included**:
- [ ] [Feature 1]
- [ ] [Feature 2]

**Excluded**:
- [What is not covered in this task]
```

### 3. Design and Approach

```markdown
## 💡 Design and Approach

### Initial Ideas
[Brainstorming, initial concepts]

### Technical Approach
[Technologies/patterns to use]

### Related Files
[Scripts and files to modify]

### Expected Issues
[Potential problems and solutions]
```

### 4. Progress Log

```markdown
## 📝 Progress Log

### YYYY-MM-DD
- [What was done]
- [Problems encountered]
- [Solutions applied]
```

**Important**: Update **daily or at major milestones** while working.

### 5. Technical Decisions

```markdown
## 🔧 Technical Decisions

### Decision 1: [Title]
- **Date**: YYYY-MM-DD
- **Problem**: [What problem]
- **Options**:
  1. [Option A]
  2. [Option B]
- **Decision**: [Chosen option]
- **Reason**: [Why chosen]
```

### 6. Related Files

```markdown
## 📁 Related Files

### Created Files
- [ ] `src/scripts/...` - [Description]

### Modified Files
- [ ] `src/init.sh` - [What changed]
```

### 7. Completion Checklist

```markdown
## ✅ Completion Checklist

### Feature Implementation
- [ ] [Feature 1]
- [ ] [Feature 2]

### Code Quality
- [ ] make test passes
- [ ] POSIX compatibility verified

### Testing
- [ ] Local environment tested

### Documentation
- [ ] This document updated

### Commits
- [ ] Separated by semantic units
- [ ] Commit convention followed
```

---

## Searching Task Documents

Agents search for task documents using these methods:

### Search All Task Documents

```bash
# Using Glob tool
Glob: .claude/tasks/**/*.md
```

### Search In-Progress Tasks

```bash
# Using Grep tool
Grep: "Status.*In Progress" in .claude/tasks/**/*.md
```

### Search by Keyword

```bash
# Search for specific keywords
Grep: "Japanese" in .claude/tasks/**/*.md
Grep: "performance" in .claude/tasks/**/*.md
```

---

## Document Update Rules

### When to Update?

- ✅ When starting the task (meta info, goals)
- ✅ When making technical decisions
- ✅ When encountering and solving issues
- ✅ At major milestone completions
- ✅ When completing the task (checklist, completion date)

### Document Update Commit Rules

Document updates should be **committed separately from code**:

```bash
# Good: Document-only commit
git add .claude/tasks/01-japanese-support.md
git commit -m "docs: update progress log for Japanese language support"

# Bad: Code and document together
git add .claude/tasks/01-japanese-support.md src/lang/ja.lang
git commit -m "feat: add Japanese support with documentation"
```

See [commit-guidelines.md](commit-guidelines.md) for detailed commit rules.

---

## Task Status Management

### Task Status

- ⚪ **Planned**: Not started yet
- 🟡 **In Progress**: Currently working
- 🔴 **On Hold**: Temporarily paused
- 🟢 **Complete**: Task finished

### Status Change Points

```markdown
⚪ Planned → 🟡 In Progress
  - When starting the task
  - Update start date field

🟡 In Progress → 🔴 On Hold
  - When blocker occurs and work stops
  - Document reason for hold

🔴 On Hold → 🟡 In Progress
  - When blocker is resolved and work resumes

🟡 In Progress → 🟢 Complete
  - When all checklist items are completed
  - Update completion date field
```

---

## Agent Guide

### Pre-Task Checklist

When a user requests a task, agents should:

1. **Search task documents**:
   ```bash
   Glob: .claude/tasks/**/*.md
   ```

2. **Check for related task document**:
   - Is there a document matching the requested task?
   - If yes, read and review the document

3. **Inform the user**:
   ```
   "This task is already defined in [filename].
    I will review the planning document and proceed."
   ```

4. **If no document exists**:
   ```
   "This task is not yet documented.
    I will create a planning document first."
   ```

### Creating New Task Documents

When agents create a new task document:

1. **Use template**:
   ```bash
   Read: .claude/tasks/template.md
   ```

2. **Place in appropriate location**:
   ```
   .claude/tasks/XX-task-name.md
   ```

3. **Confirm developer name**:
   ```bash
   git config user.name
   whoami
   ```

4. **Commit after writing**:
   ```bash
   git add .claude/tasks/XX-task-name.md
   git commit -m "docs: add task document for [task name]"
   ```

### Updating Documents During Work

Agents should update documents when:

- ✅ Major progress is made
- ✅ Technical decisions are made
- ✅ Issues are found and resolved
- ✅ Task is completed

Update with **separate commit**:
```bash
git add .claude/tasks/XX-task-name.md
git commit -m "docs: [task name] - [update description]"
```

---

## FAQ

### Q1: When do we write task documents?

**A**: **Before** starting the task.

- Top-level task: Plan on main branch → Write document → Commit → Create feature branch
- Subtask: Write document on parent branch (can be skipped for simple tasks)

### Q2: Who writes the task documents?

**A**:
- **Agent writes**: In most cases, the agent automatically writes it
- **Developer writes directly**: For complex planning requirements

The assignee field should record the actual **developer's name**.

### Q3: Do we delete documents when tasks are completed?

**A**: No, **never delete them**.

Completed task documents:
- Preserved as project history
- Reference material for similar future tasks
- Record of technical decisions

Change status to 🟢 Complete and record completion date.

### Q4: Can I write personal task documents in my native language?

**A**: Yes! Personal tasks in `.claude/tasks/personal/` can be written in any language:

- Korean: `개인-작업-메모.md`
- Japanese: `個人的なタスク.md`
- English: `personal-draft.md`

These are gitignored. When ready to share, translate to English and move to shared area.

---

## Related Documents

- [Agent Workflow](../agent-workflow.md) - Overall work process
- [Branching Strategy](../branching-strategy.md) - Branch management rules
- [Task Document Template](template.md) - Document template
- [Commit Guidelines](../commit-guidelines.md) - Git commit rules

---

## Change History

- **2025-10-22**: Adapted for direnv project with personal/shared structure
- **2025-10-20**: Initial draft from onoffhub-frontend

---

**Task documentation is at the core of collaboration. All developers and agents should write and update task documents diligently.**
