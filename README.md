# 🌀 Direnv Light

![GitHub release (latest by date)](https://img.shields.io/github/v/release/yhk1038/direnv?style=flat-square)

[한국어 README](./README.ko.md)\
[English README](./README.md)

A lightweight shell extension that automatically loads and unloads environment variables based on the current directory.\
When you enter a directory with a `.envrc` or `.profile`, it applies the environment settings; when you leave, it reverts to the previous state.

---

## ❗ Why not original direnv?

While [direnv](https://github.com/direnv/direnv) is a popular and foundational tool in many developer setups, it has a few limitations and concerns:

1. **Limited to environment variables**: Only supports `.envrc`-style syntax focused on `export` statements. Common shell features like `alias`, `function`, and other scripting logic are not officially supported.
2. **Project inactivity**: Though widely used, the project shows signs of being no longer actively maintained, with low activity in issues and pull requests.
3. **Real-world need**: Developers who frequently switch between multiple project environments often need more flexible shell configuration than what `direnv` provides.

---

## 🚀 Getting Started

Install with a single command:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/yhk1038/direnv/main/install.sh)"
```

After installation, **direnv will be automatically activated** when you open a new terminal session.

> The installer adds the following to your shell configuration file (`.bashrc`, `.zshrc`, etc.):
> ```bash
> [ -f ~/.direnv/src/init.sh ] && source ~/.direnv/src/init.sh
> ```
>
> The `de` command is available after initialization. Run `de --help` to see all available commands.

---

## 📂 Installed Files

After installation, the following files will be located under `~/.direnv/`:

```
~/.direnv/
├── src/
│   ├── init.sh                          # Entry point (initialization)
│   ├── VERSION                          # Current version
│   ├── lang/
│   │   ├── en.lang                      # English messages
│   │   └── ko.lang                      # Korean messages
│   └── scripts/
│       ├── detect-language.sh           # Locale-based language detection
│       ├── load_current_dir_env.sh      # Load .envrc or .profile
│       ├── unload_current_dir_env.sh    # Unload and restore environment
│       ├── directory_changed_hook.sh    # Directory change hook
│       └── de_command.sh               # de command (CLI interface)
├── tmp/                                 # Runtime state files
└── uninstall.sh                         # Uninstall script
```

---

## 🛠 Commands

The `de` command provides a CLI interface for managing direnv:

| Command | Description |
|---------|-------------|
| `de` | Reinitialize direnv (reload configuration) |
| `de init [file]` | Create `.envrc` (or `.profile`) in current directory |
| `de update` | Update to the latest version |
| `de update <version>` | Update to a specific version (e.g., `de update v0.8.0`) |
| `de versions` | Show available versions |
| `de --version` | Show current version |
| `de disable` | Disable direnv (turn off directory hooks) |
| `de enable` | Enable direnv (turn on directory hooks) |
| `de status` | Show current direnv status |
| `de uninstall` | Uninstall direnv |
| `de --help` | Show help message |

**Other aliases:**

| Alias | Description |
|-------|-------------|
| `dl` | Show contents of currently loaded env file |
| `df` | Clean up temporary files (`~/.direnv/tmp/*`) |

---

## 🧪 Example

```bash
# Example .envrc or .profile file
export PROJECT_ENV=dev
alias run="npm start"
```

When you enter the directory, the environment is loaded automatically, and it's cleaned up when you leave.

---

## ✅ Supported Shells

- `bash`
- `zsh`
- `ksh`
- Other POSIX-compatible shells (`sh`, `dash`, etc.)

---

## 🧹 Uninstall

To uninstall direnv, simply run the uninstall script:

```sh
sh ~/.direnv/uninstall.sh
```

Or run directly from the remote:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/yhk1038/direnv/main/uninstall.sh)"
```

The uninstall script will:
- Ask for confirmation
- Backup your shell configuration file (e.g., `.bashrc.backup.20251022_205030`)
- Remove direnv initialization lines from your shell configuration
- Delete the `~/.direnv` directory

**Manual uninstall** (if you prefer not to use the script):

```sh
# 1. Remove the directory
rm -rf ~/.direnv

# 2. Edit your shell rc file (.bashrc, .zshrc, etc.) and remove this line:
[ -f ~/.direnv/src/init.sh ] && source ~/.direnv/src/init.sh
```

---

## 📋 Release Notes

### v0.8.x (2025-10-24)

**New Features**:
- Removed `eval` security risk from install scripts, using direct file sourcing instead
- Added `de` CLI command with subcommands: `init`, `update`, `versions`, `disable`, `enable`, `status`, `uninstall`
- Added `de init` to create `.envrc`/`.profile` with automatic `.gitignore` integration
- Added `de disable`/`de enable` to toggle direnv on/off per session
- Added fresh installation verification test

**Bug Fixes**:
- Fixed hook error in subshells by checking function existence before calling
- Removed legacy `alias de=` from shell config during install/uninstall (replaced with function)
- Fixed `unalias de` conflict with zsh function definition
- Fixed empty grep results causing errors in unload script
- Ensured `~/.direnv/tmp` directory exists in all test files
- Used POSIX-compatible `cd` in directory hook tests

### v0.7.1 (2025-10-23)

**Bug Fixes**:
- Fixed critical directory switching bug where environment failed to reload when returning to a previous directory
  - Problem: PWD and OLDPWD were backed up and restored, causing directory state corruption
  - Impact: Environment variables were not reloaded correctly in A → B → A navigation patterns
  - Solution: Excluded PWD and OLDPWD from environment variable backup (shell internal state)
  - Tests: All directory changed hook tests now pass (TEST 5 & TEST 6 fixed)

### v0.7.0 (2025-10-23)

**New Features**:
- Added comprehensive regression test suite (23 tests)
  - Backup/restore mechanism tests (7 tests)
  - Environment unloading tests (9 tests)
  - Directory changed hook tests (7 tests)
- Updated Makefile to run all test files with `make test`

**Bug Fixes**:
- Fixed critical subshell issue in environment unloading
  - Problem: New aliases and variables were not actually removed when leaving directories
  - Impact: Environment pollution when switching between projects
- Fixed special character handling in environment variable backup
  - Problem: Values with special characters caused restore failures
  - Impact: Eliminated "Failed to restore environment variables" warnings

**Documentation**:
- Added comprehensive task documentation for regression testing
- Updated test infrastructure

[View all releases](https://github.com/yhk1038/direnv/releases)

---

## 📄 License

MIT License © [yhk1038](https://github.com/yhk1038)

