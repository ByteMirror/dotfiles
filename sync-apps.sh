#!/bin/sh

set -e

# Assuming this script is run from the Chezmoi source directory root
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ANSIBLE_DIR="$SCRIPT_DIR/ansible"
PLAYBOOK="$ANSIBLE_DIR/install_packages.yml"
INVENTORY="$ANSIBLE_DIR/inventory.ini"

echo "Checking for Ansible playbook: $PLAYBOOK"

if [ -d "$ANSIBLE_DIR" ] && [ -f "$PLAYBOOK" ]; then
  echo "Found playbook. Running Ansible playbook to install/update packages..."

  # Use python -m ansible_playbook to bypass potential wrapper script issues
  PYTHON_CMD=""
  if command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
  elif command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
  fi

  if [ -n "$PYTHON_CMD" ]; then
    echo "Using '$PYTHON_CMD -m ansible_playbook' to run the playbook..."
    # Execute and exit with Ansible's exit code
    "$PYTHON_CMD" -m ansible_playbook "$PLAYBOOK" -i "$INVENTORY"
    exit $?
  else
    echo "Error: python or python3 command not found in PATH. Cannot run Ansible playbook."
    exit 1
  fi
else
  echo "Error: Ansible directory '$ANSIBLE_DIR' or playbook '$PLAYBOOK' not found relative to script location. Ensure you run this from the Chezmoi source root."
  exit 1
fi 