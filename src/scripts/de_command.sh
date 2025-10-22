#!/bin/sh
# de_command.sh
# Enhanced de command with subcommand support

# Main de function
de() {
  case "$1" in
    "")
      # No arguments: reinitialize direnv (existing behavior)
      . ~/.direnv/src/init.sh
      ;;
    update)
      # Update direnv to latest or specific version
      if [ -n "$2" ]; then
        _de_update_version "$2"
      else
        _de_update_latest
      fi
      ;;
    versions)
      # Show available versions
      _de_show_versions
      ;;
    --version|-v)
      # Show current version
      _de_show_version
      ;;
    uninstall)
      # Uninstall direnv
      _de_uninstall
      ;;
    init)
      # Initialize environment file in current directory
      if [ -n "$2" ]; then
        _de_init "$2"
      else
        _de_init ".envrc"
      fi
      ;;
    --help|-h|help)
      # Show help message
      _de_show_help
      ;;
    *)
      echo "Unknown command: $1"
      echo "Run 'de --help' for usage."
      return 1
      ;;
  esac
}

# Helper function: Get current version
_de_get_current_version() {
  if [ -f ~/.direnv/src/VERSION ]; then
    cat ~/.direnv/src/VERSION
  else
    echo "unknown"
  fi
}

# Helper function: Fetch releases from GitHub API
_de_fetch_releases() {
  GITHUB_API_URL="https://api.github.com/repos/yhk1038/direnv/releases"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$GITHUB_API_URL" 2>/dev/null
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$GITHUB_API_URL" 2>/dev/null
  else
    return 1
  fi
}

# Helper function: Parse version list from API response
_de_parse_versions() {
  # Extract tag_name from JSON response
  # POSIX-compliant way without jq
  grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | \
    sed 's/"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/'
}

# Helper function: Get latest version
_de_get_latest_version() {
  _de_fetch_releases | _de_parse_versions | head -n 1
}

# Helper function: Check if version exists
_de_version_exists() {
  TARGET_VERSION="$1"
  VERSIONS=$(_de_fetch_releases | _de_parse_versions)

  # Check if target version is in the list
  echo "$VERSIONS" | grep -qx "$TARGET_VERSION"
}

# Show available versions
_de_show_versions() {
  printf "$MSG_DE_FETCHING_VERSIONS\n"

  RELEASES=$(_de_fetch_releases)
  if [ -z "$RELEASES" ]; then
    printf "$MSG_DE_NETWORK_ERROR\n"
    return 1
  fi

  CURRENT_VERSION=$(_de_get_current_version)
  LATEST_VERSION=$(echo "$RELEASES" | _de_parse_versions | head -n 1)

  printf "\n$MSG_DE_CURRENT_VERSION\n" "$CURRENT_VERSION"
  printf "$MSG_DE_LATEST_VERSION\n" "$LATEST_VERSION"
  printf "\n$MSG_DE_AVAILABLE_VERSIONS\n"

  # Display all versions with markers
  # Use process substitution to avoid subshell issues
  while IFS= read -r version; do
    if [ "$version" = "$CURRENT_VERSION" ]; then
      printf "  %s (current)\n" "$version"
    elif [ "$version" = "$LATEST_VERSION" ]; then
      printf "  %s (latest)\n" "$version"
    else
      printf "  %s\n" "$version"
    fi
  done <<EOF
$(echo "$RELEASES" | _de_parse_versions)
EOF
}

# Update to latest version
_de_update_latest() {
  printf "$MSG_DE_UPDATE_TO_LATEST\n"

  LATEST_VERSION=$(_de_get_latest_version)
  if [ -z "$LATEST_VERSION" ]; then
    printf "$MSG_DE_NETWORK_ERROR\n"
    return 1
  fi

  _de_perform_update "$LATEST_VERSION"
}

# Update to specific version
_de_update_version() {
  TARGET_VERSION="$1"

  # Ensure version starts with 'v'
  case "$TARGET_VERSION" in
    v*) ;;
    *) TARGET_VERSION="v$TARGET_VERSION" ;;
  esac

  printf "$MSG_DE_UPDATE_TO_VERSION\n" "$TARGET_VERSION"

  # Check if version exists
  if ! _de_version_exists "$TARGET_VERSION"; then
    printf "$MSG_DE_VERSION_NOT_FOUND\n" "$TARGET_VERSION"
    return 1
  fi

  _de_perform_update "$TARGET_VERSION"
}

# Perform the actual update
_de_perform_update() {
  TARGET_VERSION="$1"
  INSTALL_URL="https://raw.githubusercontent.com/yhk1038/direnv/main/install.sh"
  TMP_INSTALL_SCRIPT="/tmp/direnv-install-$$.sh"

  # Download install.sh to a temporary file
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$INSTALL_URL" -o "$TMP_INSTALL_SCRIPT" 2>/dev/null || {
      printf "$MSG_DE_UPDATE_FAILED\n"
      return 1
    }
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TMP_INSTALL_SCRIPT" "$INSTALL_URL" 2>/dev/null || {
      printf "$MSG_DE_UPDATE_FAILED\n"
      return 1
    }
  else
    printf "$MSG_DE_UPDATE_FAILED\n"
    return 1
  fi

  # Execute with VERSION environment variable
  if VERSION="$TARGET_VERSION" sh "$TMP_INSTALL_SCRIPT"; then
    rm -f "$TMP_INSTALL_SCRIPT"
    printf "$MSG_DE_UPDATE_COMPLETE\n" "$TARGET_VERSION"
    # Reinitialize direnv
    . ~/.direnv/src/init.sh
    return 0
  else
    rm -f "$TMP_INSTALL_SCRIPT"
    printf "$MSG_DE_UPDATE_FAILED\n"
    return 1
  fi
}

# Show current version
_de_show_version() {
  CURRENT_VERSION=$(_de_get_current_version)
  printf "direnv %s\n" "$CURRENT_VERSION"
}

# Uninstall direnv
_de_uninstall() {
  # Check if uninstall.sh exists
  if [ -f ~/.direnv/uninstall.sh ]; then
    sh ~/.direnv/uninstall.sh
  else
    echo "⚠️  Uninstall script not found at ~/.direnv/uninstall.sh"
    echo "Please download and run it manually:"
    echo ""
    echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/yhk1038/direnv/main/uninstall.sh)\""
    return 1
  fi
}

# Show help message
_de_show_help() {
  printf "%s\n\n" "$MSG_DE_HELP_USAGE"
  printf "%s\n" "$MSG_DE_HELP_COMMANDS"
  printf "%s\n" "$MSG_DE_HELP_CMD_NONE"
  printf "%s\n" "$MSG_DE_HELP_CMD_INIT"
  printf "%s\n" "$MSG_DE_HELP_CMD_INIT_FILE"
  printf "%s\n" "$MSG_DE_HELP_CMD_UPDATE"
  printf "%s\n" "$MSG_DE_HELP_CMD_UPDATE_VER"
  printf "%s\n" "$MSG_DE_HELP_CMD_VERSIONS"
  printf "%s\n" "$MSG_DE_HELP_CMD_VERSION"
  printf "%s\n" "$MSG_DE_HELP_CMD_UNINSTALL"
  printf "%s\n" "$MSG_DE_HELP_CMD_HELP"
  printf "\n%s\n" "$MSG_DE_HELP_OTHER_COMMANDS"
  printf "%s\n" "$MSG_DE_HELP_CMD_DL"
  printf "%s\n" "$MSG_DE_HELP_CMD_DF"
}

# Initialize environment file in current directory
_de_init() {
  ENV_FILE_NAME="$1"

  # Define allowed environment files
  ALLOWED_FILES=".envrc .profile"

  # Check if the provided file is in the allowed list
  FILE_ALLOWED=false
  for allowed in $ALLOWED_FILES; do
    if [ "$ENV_FILE_NAME" = "$allowed" ]; then
      FILE_ALLOWED=true
      break
    fi
  done

  if [ "$FILE_ALLOWED" = "false" ]; then
    printf "$MSG_DE_INIT_INVALID_FILE\n" "$ENV_FILE_NAME"
    printf "$MSG_DE_INIT_ALLOWED_FILES\n"
    for allowed in $ALLOWED_FILES; do
      printf "  - %s\n" "$allowed"
    done
    return 1
  fi

  # Check if file already exists
  if [ -e "./$ENV_FILE_NAME" ]; then
    printf "$MSG_DE_INIT_FILE_EXISTS\n" "$ENV_FILE_NAME"
    return 1
  fi

  # Create the environment file with a header comment
  cat > "./$ENV_FILE_NAME" <<'EOF'
# Direnv environment file
# This file will be automatically loaded when you enter this directory
# and unloaded when you leave it.
#
# You can define:
# - Environment variables: export MY_VAR="value"
# - Aliases: alias ll="ls -la"
# - Functions: my_function() { echo "Hello"; }

EOF

  if [ ! -e "./$ENV_FILE_NAME" ]; then
    printf "$MSG_DE_INIT_CREATE_FAILED\n" "$ENV_FILE_NAME"
    return 1
  fi

  printf "$MSG_DE_INIT_CREATED\n" "$ENV_FILE_NAME"

  # Check if we're in a git repository
  if git rev-parse --git-dir >/dev/null 2>&1; then
    GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

    if [ -n "$GIT_ROOT" ]; then
      GITIGNORE_FILE="$GIT_ROOT/.gitignore"

      # Check if the env file is already in .gitignore
      if [ -f "$GITIGNORE_FILE" ]; then
        if grep -qx "$ENV_FILE_NAME" "$GITIGNORE_FILE" 2>/dev/null; then
          # Already in .gitignore, do nothing
          :
        else
          # Add to .gitignore with a comment
          printf "\n# Direnv environment file (auto-added by de init)\n%s\n" "$ENV_FILE_NAME" >> "$GITIGNORE_FILE"
          printf "$MSG_DE_INIT_ADDED_TO_GITIGNORE\n" "$ENV_FILE_NAME"
        fi
      else
        # Create .gitignore with the env file
        printf "# Direnv environment file (auto-added by de init)\n%s\n" "$ENV_FILE_NAME" > "$GITIGNORE_FILE"
        printf "$MSG_DE_INIT_ADDED_TO_GITIGNORE\n" "$ENV_FILE_NAME"
      fi
    fi
  fi

  return 0
}
