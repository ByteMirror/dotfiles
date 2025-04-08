#!/bin/sh

set -e

# Ensure we are in the chezmoi source directory where the ansible subdir exists
if [ -d "ansible" ] && [ -f "ansible/install_packages.yml" ]; then
  echo "Running Ansible playbook to install/update packages..."

  # Use python -m ansible_playbook to bypass potential wrapper script issues
  # Check for python or python3 command
  PYTHON_CMD=""
  if command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
  elif command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
  fi

  if [ -n "$PYTHON_CMD" ]; then
    echo "Using '$PYTHON_CMD -m ansible_playbook' to run the playbook..."
    "$PYTHON_CMD" -m ansible_playbook ansible/install_packages.yml -i ansible/inventory.ini
  else
    echo "Error: python or python3 command not found in PATH. Cannot run Ansible playbook."
    exit 1
  fi

  echo "Ansible playbook finished."
else
  echo "Ansible directory or playbook 'ansible/install_packages.yml' not found in chezmoi source directory. Skipping Ansible run."
  # This might happen during the very first run if chezmoi hasn't checked out the files yet
fi 