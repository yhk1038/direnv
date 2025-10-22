# Additional File Format Support

**Task ID**: `task-09`
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
**Current Branch**: `feat/additional-file-formats`
**PR Link**: (Update after task completion)

---

## 📋 Task Overview

### Goal
Add support for loading environment variables from additional file formats (.env, YAML, JSON) while maintaining backward compatibility with existing .envrc files.

### Background
Users often have environment configuration in various formats:
- `.env` files (common in many frameworks)
- YAML configuration files
- JSON configuration files

Supporting these formats would:
- Reduce need to convert existing configs
- Improve interoperability with other tools
- Maintain single source of truth

### Scope
**Included**:
- [ ] .env file format support (KEY=value syntax)
- [ ] YAML format support (using portable YAML parser)
- [ ] JSON format support (using portable JSON parser)
- [ ] Automatic format detection
- [ ] Documentation and examples

**Excluded**:
- TOML or other formats (can be added later)
- Complex YAML/JSON nesting (flat key-value only)
- Format conversion tools (out of scope)

---

## 💡 Design and Approach

### Initial Ideas
1. Extend direnv to check for `.env`, `.envrc.yaml`, `.envrc.json` in addition to `.envrc`
2. Parse and convert to environment variables
3. Maintain precedence: `.envrc` > `.env` > `.envrc.yaml` > `.envrc.json`
4. Use POSIX-compliant parsers (may need to bundle simple parsers)

### Technical Approach
- Create parser functions for each format
- .env: Simple line-by-line parsing
- YAML: May need lightweight YAML parser (or Python/Ruby if available)
- JSON: Use `jq` if available, or fallback parser
- Maintain POSIX compatibility
- Add tests for each format

### Related Files
- `src/load.sh` - Extend to support multiple formats
- `src/parsers/` - New directory for format parsers
- `test/` - Add format-specific tests

### Expected Issues
- YAML/JSON parsing in pure POSIX shell is complex
- Dependencies (jq, yq) may not be available
- Maintaining security with new formats
- Performance impact of parsing

---

## 📝 Progress Log

(To be filled during implementation)

---

## 🔧 Technical Decisions

### Decision 1: Parsing Strategy
- **Options**:
  1. Require external tools (jq, yq)
  2. Bundle pure shell parsers
  3. Hybrid approach (prefer external, fallback to bundled)
- **Decision**: (TBD during implementation)

---

## 📁 Related Files

### Created Files
- [ ] `src/parsers/env-parser.sh` - .env file parser
- [ ] `src/parsers/yaml-parser.sh` - YAML parser
- [ ] `src/parsers/json-parser.sh` - JSON parser
- [ ] `test/formats.sh` - Format-specific tests
- [ ] `docs/FILE-FORMATS.md` - Format documentation

### Modified Files
- [ ] `src/load.sh` - Add format detection and loading
- [ ] `README.md` - Document format support

---

## 🐛 Issues and Solutions

(To be filled during implementation)

---

## ✅ Completion Checklist

### Feature Implementation
- [ ] .env format parser implemented
- [ ] YAML format parser implemented
- [ ] JSON format parser implemented
- [ ] Format auto-detection implemented
- [ ] Precedence rules implemented

### Code Quality
- [ ] `make test` passes
- [ ] POSIX compatibility verified
- [ ] No shellcheck warnings
- [ ] Security considerations addressed

### Testing
- [ ] Each format tested independently
- [ ] Format precedence tested
- [ ] Edge cases handled (malformed files)
- [ ] Performance acceptable

### Documentation
- [ ] Format support documented
- [ ] Examples for each format provided
- [ ] Migration guide from .envrc
- [ ] Security considerations documented

### Commits
- [ ] Commits separated by semantic units
- [ ] Commit message convention followed
- [ ] Final `git status` checked

---

## 🔗 References

- [.env file format spec](https://github.com/motdotla/dotenv)
- [YAML Specification](https://yaml.org/spec/)
- [JSON Specification](https://www.json.org/)
- [jq manual](https://stedolan.github.io/jq/manual/)
- [Commit Guidelines](../../commit-guidelines.md)

---

## 📌 Notes

- Start with .env format (simplest, most common)
- YAML/JSON may require external dependencies or complex parsers
- Consider security implications of each format
- Performance impact should be minimal

---

## 📋 Format Examples (Draft)

### .env Format
```
DATABASE_URL=postgres://localhost/mydb
API_KEY=secret123
DEBUG=true
```

### YAML Format (.envrc.yaml)
```yaml
DATABASE_URL: postgres://localhost/mydb
API_KEY: secret123
DEBUG: true
```

### JSON Format (.envrc.json)
```json
{
  "DATABASE_URL": "postgres://localhost/mydb",
  "API_KEY": "secret123",
  "DEBUG": "true"
}
```

---

**Last Updated**: 2025-10-22
