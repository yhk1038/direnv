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
> alias de=". $HOME/.direnv/src/init.sh"
> ```
>
> The `de` alias allows you to manually reload direnv if needed (e.g., after configuration changes).

---

## 📂 Installed Files

After installation, the following files will be located under `~/.direnv/`:

- `init.sh`: Initializes the environment hook
- `directory_changed_hook.sh`: Detects directory changes
- `load_current_dir_env.sh`: Loads `.envrc` or `.profile` if present
- `unload_current_dir_env.sh`: Clears previous environment variables
- `install.sh`: The installer script itself

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

# 2. Edit your shell rc file (.bashrc, .zshrc, etc.) and remove these lines:
[ -f ~/.direnv/src/init.sh ] && source ~/.direnv/src/init.sh
alias de=". $HOME/.direnv/src/init.sh"
```

---

## 📋 Release Notes

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

