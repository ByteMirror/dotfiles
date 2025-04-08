# ByteMirror Dotfiles

Managed by [Chezmoi](https://chezmoi.io).

## How to sync Chezmoi on new Device

```bash
chezmoi init --apply --verbose https://github.com/ByteMirror/dotfiles.git
```

## Package Management with Ansible

This setup integrates Ansible to manage application installations across different operating systems directly when you run `chezmoi init --apply` or `chezmoi apply`.

1. **** **Automatic Ansible Installation**: The `chezmoi init --apply` command will automatically attempt to install Ansible if it's not found using common package managers (Homebrew, apt, dnf, pacman, zypper, pip).
2.  **Automatic Package Installation**: After Ansible is ready, it runs a playbook (`ansible/install_packages.yml`) which installs applications defined in `ansible/vars/packages.yml` based on the detected OS and available package managers (Homebrew, Apt, DNF, Flatpak, Winget, Scoop, Chocolatey).
3.  **Configuration**: To add or remove packages, simply edit the lists within `ansible/vars/packages.yml` and run `chezmoi apply`.

### Prerequisites

*   **General**: Common system tools like `curl`, `git`, `sh`.
*   **macOS**: The setup script will attempt to install Homebrew if it's not found using the official script. If Homebrew installation fails or is unavailable, it will fall back to trying `pip` to install Ansible. Ensure `curl` is available for the Homebrew install attempt.
*   **Linux**: A common package manager (`apt`, `dnf`, `pacman`, `zypper`) or `pip`/`pip3` is needed for automatic Ansible installation via the included script.
    *   For Espanso AppImage: `wget`, systemd (optional, for service).
    *   For Flatpak: Flatpak needs to be installed and configured (e.g., `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`).
*   **Windows (Manual Setup Required)**: The automatic setup script does not support Windows. Before running `chezmoi init` or `chezmoi update`, you must manually ensure the following prerequisites are met:
    1.  **Install Python 3**: Download and install the latest Python 3 from [python.org](https://www.python.org/downloads/windows/). **Ensure you check the box "Add python.exe to PATH" during installation.**
    2.  **Install Ansible**: Open PowerShell or Command Prompt and run:
        ```powershell
        pip install --user ansible
        ```
        Verify the installation by opening a **new** terminal window and running `ansible --version`. If the command is not found, manually add the Python user scripts directory (e.g., `C:\Users\<YourUsername>\AppData\Roaming\Python\Python3X\Scripts`) to your user `Path` environment variable and try again in a new terminal.
    3.  **Install Ansible Windows Collections**: Run the following in PowerShell/CMD:
        ```powershell
        ansible-galaxy collection install community.general community.windows
        ```
    4.  **Configure WinRM for Local Ansible**: Run the following commands in an **Administrator** PowerShell prompt:
        ```powershell
        winrm quickconfig -q
        winrm set winrm/config/service/auth @{Basic="true"}
        winrm set winrm/config/service @{AllowUnencrypted="true"} # Needed for local connection
        # Optional: Consider firewall rule if running remote playbooks later
        # New-NetFirewallRule -Name "WinRM (HTTP-In)" -DisplayName "WinRM (HTTP-In)" -Profile Any -LocalPort 5985 -Protocol TCP
        ```
    5.  **Install Required Package Managers**: Ensure any package managers you intend to use via Ansible (Winget, Chocolatey, Scoop) are installed.

Once these steps are completed, you can run `chezmoi init --apply --verbose https://github.com/ByteMirror/dotfiles.git` or `chezmoi update`. 