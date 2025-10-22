# Configuration Examples Documentation

**Task ID**: `task-02`
**Assignee**: (TBD)
**Start Date**: (TBD)
**Completion Date**: (TBD)
**Status**: ⚪ Planned

---

## 📋 Task Overview

### Goal
Provide a comprehensive collection of practical `.envrc` and `.profile` configuration examples for common use cases.

### Background
Users need real-world examples to understand how to configure direnv for their specific projects and workflows.

### Scope
**Included**:
- [ ] Basic environment variable examples
- [ ] Alias configuration examples
- [ ] Function definition examples
- [ ] Project-specific configuration examples
- [ ] Multi-project workspace examples

**Excluded**:
- Company-specific or proprietary configurations
- Security-sensitive examples (secrets management covered separately)

---

## 💡 Design and Approach

### Example Categories

1. **Basic Environment Variables**
```bash
# Simple variable
export PROJECT_NAME="my-project"

# Path modifications
export PATH="$HOME/.local/bin:$PATH"

# Conditional variables
if [ -f ".env.local" ]; then
  export LOCAL_CONFIG="enabled"
fi
```

2. **Development Tool Configurations**
```bash
# Node.js project
export NODE_ENV="development"
export npm_config_prefix="$HOME/.npm-global"

# Python project
export PYTHONPATH="$PWD/src:$PYTHONPATH"
export VIRTUAL_ENV="$PWD/venv"

# Go project
export GOPATH="$PWD"
export PATH="$GOPATH/bin:$PATH"
```

3. **Useful Aliases**
```bash
# Project shortcuts
alias run="npm start"
alias test="npm test"
alias build="npm run build"

# Docker shortcuts
alias dc="docker-compose"
alias dcu="docker-compose up"
alias dcd="docker-compose down"
```

4. **Utility Functions**
```bash
# Project initialization helper
init_project() {
  echo "Initializing project environment..."
  # setup commands
}

# Cleanup helper
cleanup() {
  echo "Cleaning up temporary files..."
  rm -rf ./tmp/*
}
```

### Documentation Structure

```
docs/examples/
├── basic/
│   ├── simple-variables.envrc
│   ├── path-modifications.envrc
│   └── conditional-loading.envrc
├── languages/
│   ├── nodejs.envrc
│   ├── python.envrc
│   ├── go.envrc
│   └── rust.envrc
├── tools/
│   ├── docker.envrc
│   ├── aws.envrc
│   └── kubernetes.envrc
└── workflows/
    ├── multi-project.envrc
    └── team-development.envrc
```

### Related Files

**Created Files**:
- [ ] `docs/examples/` directory structure
- [ ] Example `.envrc` files for each category
- [ ] `docs/EXAMPLES.md` - Index and explanation of examples

**Modified Files**:
- [ ] `README.md` - Add link to examples

---

## ✅ Completion Checklist

### Examples Creation
- [ ] Basic examples (5+ examples)
- [ ] Language-specific examples (4+ languages)
- [ ] Tool-specific examples (5+ tools)
- [ ] Workflow examples (3+ scenarios)

### Documentation
- [ ] Each example includes explanation
- [ ] Usage instructions provided
- [ ] Expected output documented

### Code Quality
- [ ] All examples tested
- [ ] POSIX compatibility verified
- [ ] No security-sensitive data

### Final Steps
- [ ] Create examples directory structure
- [ ] Write index documentation
- [ ] Link from main README
- [ ] Mark TODO.md item as complete

---

**Last Updated**: (TBD)
