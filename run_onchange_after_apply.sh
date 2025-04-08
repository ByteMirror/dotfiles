#!/bin/sh

# This script is intended for Unix-like systems (macOS, Linux)
# It runs after chezmoi apply changes files.

set -e

# Determine the source directory
# Use CHEZMOI_SOURCE_DIR if set (when run by chezmoi), otherwise use script location
if [ -n "$CHEZMOI_SOURCE_DIR" ]; then
  SCRIPT_DIR="$CHEZMOI_SOURCE_DIR"
  echo "(onchange_after script) Using CHEZMOI_SOURCE_DIR: $SCRIPT_DIR"
else
  # Fallback for manual execution: Get script's own directory
  SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
  echo "(onchange_after script) CHEZMOI_SOURCE_DIR not set, using script directory: $SCRIPT_DIR"
fi

# Define base paths
ANSIBLE_DIR="$SCRIPT_DIR/ansible"
INVENTORY="$ANSIBLE_DIR/inventory.ini"

# Determine OS and select playbook
OS_NAME=$(uname)
PLAYBOOK_FILE=""
if [ "$OS_NAME" = "Darwin" ]; then
    PLAYBOOK_FILE="macos.yml"
elif [ "$OS_NAME" = "Linux" ]; then
    PLAYBOOK_FILE="linux.yml"
else
    echo "(onchange_after script) Warning: Unsupported OS '$OS_NAME' for Ansible playbook execution. Skipping." >&2
    exit 0 # Exit cleanly for unsupported OS
fi

PLAYBOOK="$ANSIBLE_DIR/$PLAYBOOK_FILE"

echo "(onchange_after script) Detected OS: $OS_NAME. Checking for playbook: $PLAYBOOK"

if [ -d "$ANSIBLE_DIR" ] && [ -f "$PLAYBOOK" ]; then
  echo "(onchange_after script) Found playbook. Running Ansible playbook for $OS_NAME..."

  # Check if ansible-playbook command exists in PATH
  if command -v ansible-playbook >/dev/null 2>&1; then
    echo "(onchange_after script) Using 'ansible-playbook' command from PATH..."
    # Execute playbook directly
    if ! ansible-playbook "$PLAYBOOK" -i "$INVENTORY"; then
        PLAYBOOK_EXIT_CODE=$?
        echo "(onchange_after script) Error: Ansible playbook '$PLAYBOOK_FILE' failed with exit code $PLAYBOOK_EXIT_CODE." >&2
        exit $PLAYBOOK_EXIT_CODE # Exit with the playbook's error code
    else
        echo "(onchange_after script) Ansible playbook '$PLAYBOOK_FILE' finished successfully."
        exit 0
    fi
  else
    echo "(onchange_after script) Error: 'ansible-playbook' command not found in PATH." >&2
    echo "(onchange_after script) Ensure Ansible is installed correctly (e.g., via Homebrew or pip)." >&2
    exit 1 # Exit with an error if command not found
  fi
else
  echo "(onchange_after script) Warning: Ansible directory '$ANSIBLE_DIR' or playbook '$PLAYBOOK' not found. Skipping Ansible run." >&2
  exit 0 # Exit cleanly if playbook isn't found
fi 