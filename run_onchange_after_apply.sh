#!/bin/sh

# This script is intended for Unix-like systems (macOS, Linux)
# It runs after chezmoi apply changes files.

set -e

# Get source dir from environment variable set by chezmoi
if [ -z "$CHEZMOI_SOURCE_DIR" ]; then
  echo "(onchange_after script) Error: CHEZMOI_SOURCE_DIR environment variable not set." >&2
  exit 1
fi

ANSIBLE_DIR="$CHEZMOI_SOURCE_DIR/ansible"
PLAYBOOK="$ANSIBLE_DIR/install_packages.yml"
INVENTORY="$ANSIBLE_DIR/inventory.ini"

echo "(onchange_after script) Checking for Ansible playbook: $PLAYBOOK"

if [ -d "$ANSIBLE_DIR" ] && [ -f "$PLAYBOOK" ]; then
  echo "(onchange_after script) Found playbook. Running Ansible playbook to install/update packages..."

  # Check if ansible-playbook command exists in PATH
  if command -v ansible-playbook >/dev/null 2>&1; then
    echo "(onchange_after script) Using 'ansible-playbook' command from PATH..."
    # Execute playbook directly
    if ! ansible-playbook "$PLAYBOOK" -i "$INVENTORY"; then
        PLAYBOOK_EXIT_CODE=$?
        echo "(onchange_after script) Error: Ansible playbook failed with exit code $PLAYBOOK_EXIT_CODE." >&2
        exit $PLAYBOOK_EXIT_CODE # Exit with the playbook's error code
    else
        echo "(onchange_after script) Ansible playbook finished successfully."
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