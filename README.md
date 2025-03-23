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

After installation, restart your terminal or apply the environment with:

```sh
de
```

> This command is registered as an alias: `alias de=". $HOME/.direnv/init.sh"`

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

```sh
rm -rf ~/.direnv
unalias de
```

You may also manually remove the `alias de=...` line from your `.bashrc`, `.zshrc`, etc., if needed.

---

## 📄 License

MIT License © [yhk1038](https://github.com/yhk1038)

