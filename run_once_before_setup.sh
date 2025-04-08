#!/bin/sh

# This script runs once before setup on Unix-like systems.

# --- OS Check --- #
# Exit immediately if running on a Windows-like system
if [ -n "$OS" ] && [ "$OS" = "Windows_NT" ]; then exit 0; fi
if command -v uname >/dev/null 2>&1; then
    case "$(uname -s)" in CYGWIN*|MINGW*|MSYS*|Windows_NT) exit 0 ;; esac
fi
# --- End OS Check --- #

set -e # Exit on first error

# --- Helper: Check/Install Package --- #
# Usage: ensure_pkg <package_name>
ensure_pkg() {
    pkg_name=$1
    if command -v "$pkg_name" >/dev/null 2>&1; then
        echo "(run_once script) Prerequisite '$pkg_name' already installed."
        return 0
    fi
    echo "(run_once script) Prerequisite '$pkg_name' not found. Attempting install..."
    if [ "$(uname)" = "Darwin" ]; then
        if command -v brew >/dev/null 2>&1; then
             echo "(run_once script) Installing '$pkg_name' using Homebrew..."
             brew install "$pkg_name"
        else
             echo "(run_once script) Error: Homebrew not found, cannot install '$pkg_name'. Please install Homebrew." >&2
             return 1 # Indicate failure
        fi
    elif [ "$(uname)" = "Linux" ]; then
         if command -v apt-get >/dev/null 2>&1; then 
             # Run update separately, warn on failure but continue
             echo "(run_once script) Running apt-get update..."
             if ! sudo apt-get update; then
                 echo "(run_once script) Warning: apt-get update failed. Attempting to install '$pkg_name' anyway..." >&2
             fi
             echo "(run_once script) Installing '$pkg_name' using apt-get..."
             sudo apt-get install -y "$pkg_name"
         elif command -v dnf >/dev/null 2>&1; then 
             # Similar logic for dnf if needed - dnf update might be less prone to this exact error
             echo "(run_once script) Installing '$pkg_name' using dnf..."
             sudo dnf install -y "$pkg_name"
         elif command -v pacman >/dev/null 2>&1; then 
             echo "(run_once script) Updating pacman DB and installing '$pkg_name'..."
             sudo pacman -Sy --noconfirm "$pkg_name" # -Syu might be too broad here
         elif command -v zypper >/dev/null 2>&1; then 
             echo "(run_once script) Installing '$pkg_name' using zypper..."
             sudo zypper install -y "$pkg_name"
         else
             echo "(run_once script) Error: Cannot determine Linux package manager to install '$pkg_name'." >&2
             return 1 # Indicate failure
         fi
    else
        echo "(run_once script) Error: Unsupported OS for automatic '$pkg_name' installation." >&2
        return 1 # Indicate failure
    fi
    # Verify after install attempt
    if ! command -v "$pkg_name" >/dev/null 2>&1; then
         echo "(run_once script) Error: Installation of '$pkg_name' failed or command not found after install." >&2
         return 1
    fi
    echo "(run_once script) Prerequisite '$pkg_name' installed successfully."
}

# --- Install Prerequisites (Zsh, Git, Curl) --- #
echo "(run_once script) Checking prerequisites..."
ensure_pkg zsh || exit 1 # Exit script if Zsh install fails
ensure_pkg git || exit 1 # Exit script if Git install fails
ensure_pkg curl || exit 1 # Exit script if Curl install fails
echo "(run_once script) Prerequisites checked/installed."

# --- Install Oh My Zsh --- #
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "(run_once script) Installing Oh My Zsh..."
    # Use --unattended to prevent prompts, --keep-zshrc to prevent overwriting chezmoi's version,
    # and --skip-chsh to avoid trying to change the default shell.
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh
    echo "(run_once script) Oh My Zsh installed."
else
    echo "(run_once script) Oh My Zsh already found, skipping installation."
fi

# --- Install Powerlevel10k Theme --- #
P10K_DIR="${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "(run_once script) Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    echo "(run_once script) Powerlevel10k theme installed."
else
    echo "(run_once script) Powerlevel10k theme already found, skipping installation."
fi

# --- Install/Setup Ansible (Existing Logic) --- #
echo "(run_once script) Checking Ansible installation..."
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