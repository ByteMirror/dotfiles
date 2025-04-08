#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.

# Check if Ansible is installed
if command -v ansible >/dev/null 2>&1; then
    echo "Ansible is already installed."
else
    echo "Ansible not found. Attempting to install..."

    # --- Installation for macOS --- #
    if [ "$(uname)" = "Darwin" ]; then
        # Check for Homebrew and install if missing
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew not found. Attempting to install Homebrew..."
            # Attempt non-interactive install
            if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                 echo "Homebrew installed successfully."
                 # Add brew to path for this script's context if needed (might be necessary)
                 # This location might vary based on Apple Silicon vs Intel
                 if [ -x "/opt/homebrew/bin/brew" ]; then
                     eval "$(/opt/homebrew/bin/brew shellenv)"
                 elif [ -x "/usr/local/bin/brew" ]; then
                     eval "$(/usr/local/bin/brew shellenv)"
                 fi
            else
                 echo "Homebrew installation failed. Please install Homebrew manually (https://brew.sh/)."
                 # Fall through to pip check below
            fi
        fi

        # Try installing Ansible with Homebrew if available
        if command -v brew >/dev/null 2>&1; then
            echo "Installing Ansible using Homebrew..."
            brew install ansible
        else
            # Fallback to pip if Homebrew isn't available/install failed
            echo "Homebrew not available. Trying pip..."
            if command -v pip3 >/dev/null 2>&1; then
                 echo "Trying to install Ansible using pip3..."
                 pip3 install --user ansible
            elif command -v pip >/dev/null 2>&1; then
                 echo "Trying to install Ansible using pip..."
                 pip install --user ansible
            else
                 echo "pip/pip3 not found. Cannot install Ansible automatically."
                 exit 1
            fi
        fi
    # --- Installation for Linux --- #
    elif [ "$(uname)" = "Linux" ]; then
        if command -v apt-get >/dev/null 2>&1; then
            echo "Installing Ansible using apt..."
            sudo apt-get update
            sudo apt-get install -y ansible
        elif command -v dnf >/dev/null 2>&1; then
            echo "Installing Ansible using dnf..."
            sudo dnf install -y ansible
        elif command -v pacman >/dev/null 2>&1; then
            echo "Installing Ansible using pacman..."
            sudo pacman -Sy --noconfirm ansible
         elif command -v zypper >/dev/null 2>&1; then
            echo "Installing Ansible using zypper..."
            sudo zypper install -y ansible
        else
            echo "Common Linux package manager (apt, dnf, pacman, zypper) not found."
             # As a fallback, try pip
            if command -v pip3 >/dev/null 2>&1; then
                 echo "Trying to install Ansible using pip3..."
                 pip3 install --user ansible
            elif command -v pip >/dev/null 2>&1; then
                 echo "Trying to install Ansible using pip..."
                 pip install --user ansible
            else
                 echo "pip/pip3 not found. Cannot install Ansible automatically."
                 exit 1
            fi
        fi
    else
        echo "Unsupported operating system: $(uname)"
        exit 1
    fi

    # Verify installation
    if ! command -v ansible >/dev/null 2>&1; then
        echo "Ansible installation failed."
        exit 1
    fi
    echo "Ansible installed successfully."
fi

# Ensure required Ansible collections are installed
echo "Ensuring required Ansible collections are installed..."
ansible-galaxy collection install community.general community.windows

echo "Ansible setup complete." 