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
  if [ -f ~/.direnv/VERSION ]; then
    cat ~/.direnv/VERSION
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
  echo "$RELEASES" | _de_parse_versions | while IFS= read -r version; do
    if [ "$version" = "$CURRENT_VERSION" ]; then
      printf "  %s (current)\n" "$version"
    elif [ "$version" = "$LATEST_VERSION" ]; then
      printf "  %s (latest)\n" "$version"
    else
      printf "  %s\n" "$version"
    fi
  done
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
  VERSION="$1"
  INSTALL_URL="https://raw.githubusercontent.com/yhk1038/direnv/main/install.sh"

  # Download and execute install.sh with VERSION environment variable
  if command -v curl >/dev/null 2>&1; then
    if VERSION="$VERSION" sh -c "$(curl -fsSL "$INSTALL_URL")" 2>/dev/null; then
      printf "$MSG_DE_UPDATE_COMPLETE\n" "$VERSION"
      # Reinitialize direnv
      . ~/.direnv/src/init.sh
      return 0
    fi
  elif command -v wget >/dev/null 2>&1; then
    if VERSION="$VERSION" sh -c "$(wget -qO- "$INSTALL_URL")" 2>/dev/null; then
      printf "$MSG_DE_UPDATE_COMPLETE\n" "$VERSION"
      # Reinitialize direnv
      . ~/.direnv/src/init.sh
      return 0
    fi
  fi

  printf "$MSG_DE_UPDATE_FAILED\n"
  return 1
}

# Show help message
_de_show_help() {
  printf "%s\n\n" "$MSG_DE_HELP_USAGE"
  printf "%s\n" "$MSG_DE_HELP_COMMANDS"
  printf "%s\n" "$MSG_DE_HELP_CMD_NONE"
  printf "%s\n" "$MSG_DE_HELP_CMD_UPDATE"
  printf "%s\n" "$MSG_DE_HELP_CMD_UPDATE_VER"
  printf "%s\n" "$MSG_DE_HELP_CMD_VERSIONS"
  printf "%s\n" "$MSG_DE_HELP_CMD_HELP"
}
