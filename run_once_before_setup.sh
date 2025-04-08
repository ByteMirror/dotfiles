#!/bin/sh

# --- OS Check --- #
# Exit immediately if running on a Windows-like system where this script shouldn't run
if [ -n "$OS" ] && [ "$OS" = "Windows_NT" ]; then
    echo "Skipping Unix setup script on Windows (detected via \$OS variable)."
    exit 0
elif command -v uname >/dev/null 2>&1; then
    case "$(uname -s)" in
        CYGWIN*|MINGW*|MSYS*|Windows_NT)
            echo "Skipping Unix setup script on Windows (detected via uname)."
            exit 0
            ;;
    esac
fi
# --- End OS Check --- #

set -e # Exit immediately if a command exits with a non-zero status.

# Check if Ansible is installed
if command -v ansible >/dev/null 2>&1; then
    echo "(run_once script) Ansible is already installed."
else
    echo "(run_once script) Ansible not found. Attempting to install..."

    # --- Installation for macOS --- #
    if [ "$(uname)" = "Darwin" ]; then
        # Check for Homebrew and install if missing
        if ! command -v brew >/dev/null 2>&1; then
            echo "(run_once script) Homebrew not found. Attempting to install Homebrew..."
            if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                 echo "(run_once script) Homebrew installed successfully."
                 if [ -x "/opt/homebrew/bin/brew" ]; then
                     eval "$(/opt/homebrew/bin/brew shellenv)"
                 elif [ -x "/usr/local/bin/brew" ]; then
                     eval "$(/usr/local/bin/brew shellenv)"
                 fi
            else
                 echo "(run_once script) Homebrew installation failed. Please install Homebrew manually (https://brew.sh/)."
            fi
        fi

        # Try installing Ansible with Homebrew if available
        if command -v brew >/dev/null 2>&1; then
            echo "(run_once script) Installing Ansible using Homebrew..."
            brew install ansible
        else
            # Fallback to pip if Homebrew isn't available/install failed
            echo "(run_once script) Homebrew not available. Trying pip..."
            if command -v pip3 >/dev/null 2>&1; then
                 echo "(run_once script) Trying to install Ansible using pip3..."
                 pip3 install --user ansible
            elif command -v pip >/dev/null 2>&1; then
                 echo "(run_once script) Trying to install Ansible using pip..."
                 pip install --user ansible
            else
                 echo "(run_once script) pip/pip3 not found. Cannot install Ansible automatically." >&2
                 exit 1
            fi
        fi
    # --- Installation for Linux --- #
    elif [ "$(uname)" = "Linux" ]; then
        if command -v apt-get >/dev/null 2>&1; then
            echo "(run_once script) Installing Ansible using apt..."
            sudo apt-get update
            sudo apt-get install -y ansible
        elif command -v dnf >/dev/null 2>&1; then
            echo "(run_once script) Installing Ansible using dnf..."
            sudo dnf install -y ansible
        elif command -v pacman >/dev/null 2>&1; then
            echo "(run_once script) Installing Ansible using pacman..."
            sudo pacman -Sy --noconfirm ansible
         elif command -v zypper >/dev/null 2>&1; then
            echo "(run_once script) Installing Ansible using zypper..."
            sudo zypper install -y ansible
        else
            echo "(run_once script) Common Linux package manager (apt, dnf, pacman, zypper) not found."
            if command -v pip3 >/dev/null 2>&1; then
                 echo "(run_once script) Trying to install Ansible using pip3..."
                 pip3 install --user ansible
            elif command -v pip >/dev/null 2>&1; then
                 echo "(run_once script) Trying to install Ansible using pip..."
                 pip install --user ansible
            else
                 echo "(run_once script) pip/pip3 not found. Cannot install Ansible automatically." >&2
                 exit 1
            fi
        fi
    else
        echo "(run_once script) Unsupported operating system for automatic install: $(uname)" >&2
        # Continue without error, rely on manual install
    fi

    # Verify installation
    if ! command -v ansible >/dev/null 2>&1; then
        # Try finding via python -m
        PYTHON_CMD=""
        if command -v python >/dev/null 2>&1; then PYTHON_CMD="python"; 
        elif command -v python3 >/dev/null 2>&1; then PYTHON_CMD="python3"; fi
        if [ -n "$PYTHON_CMD" ] && "$PYTHON_CMD" -m ansible --version >/dev/null 2>&1; then
             echo "(run_once script) Ansible installed but not directly in PATH, verified via python -m."
        else 
            echo "(run_once script) Ansible installation appears to have failed." >&2
            exit 1
        fi
    else
         echo "(run_once script) Ansible installed successfully."
    fi
fi

# Ensure required Ansible collections are installed
echo "(run_once script) Ensuring required Ansible collections are installed..."

# Prioritize using the ansible-galaxy command directly if available
if command -v ansible-galaxy >/dev/null 2>&1; then
    echo "(run_once script) Using 'ansible-galaxy' command..."
    # Only install community.general now
    if ! ansible-galaxy collection install community.general; then
        echo "(run_once script) Warning: 'ansible-galaxy collection install community.general' command failed." >&2
    else
        echo "(run_once script) Ansible collection community.general installed/updated."
    fi
else
    # Fallback to python -m ansible_galaxy
    echo "(run_once script) 'ansible-galaxy' command not found, trying 'python -m ansible_galaxy'..."
    PYTHON_CMD=""
    if command -v python >/dev/null 2>&1; then PYTHON_CMD="python"; 
    elif command -v python3 >/dev/null 2>&1; then PYTHON_CMD="python3"; fi

    if [ -n "$PYTHON_CMD" ]; then
        # Only install community.general now
        if ! "$PYTHON_CMD" -m ansible_galaxy collection install community.general; then
            echo "(run_once script) Warning: Failed to install community.general using 'python -m ansible_galaxy'." >&2
        else
            echo "(run_once script) Ansible collection community.general installed/updated via python -m."
        fi
    else
        echo "(run_once script) Error: python/python3 not found, cannot install Ansible collections." >&2
        exit 1
    fi
fi

echo "(run_once script) Ansible setup check complete." 