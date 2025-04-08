#!/bin/sh

set -e

# Ensure we are in the chezmoi source directory where the ansible subdir exists
if [ -d "ansible" ] && [ -f "ansible/install_packages.yml" ]; then
  echo "Running Ansible playbook to install/update packages..."
  ansible-playbook ansible/install_packages.yml -i ansible/inventory.ini
  echo "Ansible playbook finished."
else
  echo "Ansible directory or playbook not found in chezmoi source directory. Skipping Ansible run."
  # This might happen during the very first run if chezmoi hasn't checked out the files yet
fi 