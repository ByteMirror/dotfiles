# ByteMirror Dotfiles

Managed by [Chezmoi](https://chezmoi.io).

## How to sync Chezmoi on new Device

```bash
chezmoi init --apply --verbose https://github.com/ByteMirror/dotfiles.git
```

## Package Management with Ansible

This setup integrates Ansible to manage application installations across different operating systems directly when you run `chezmoi init --apply` or `chezmoi apply`.

1.  **Automatic Ansible Installation**: The `chezmoi init --apply` command will automatically attempt to install Ansible if it's not found using common package managers (Homebrew, apt, dnf, pacman, zypper, pip).
2.  **Automatic Package Installation**: After Ansible is ready, it runs a playbook (`ansible/install_packages.yml`) which installs applications defined in `ansible/vars/packages.yml` based on the detected OS and available package managers (Homebrew, Apt, DNF, Flatpak, Winget, Scoop, Chocolatey).
3.  **Configuration**: To add or remove packages, simply edit the lists within `ansible/vars/packages.yml` and run `chezmoi apply`.

### Prerequisites

*   **General**: Common system tools like `curl`, `git`, `sh`.
*   **macOS**: The setup script will attempt to install Homebrew if it's not found using the official script. If Homebrew installation fails or is unavailable, it will fall back to trying `pip` to install Ansible. Ensure `curl` is available for the Homebrew install attempt.
*   **Linux**: A common package manager (`apt`, `dnf`, `pacman`, `zypper`) or `pip`/`pip3` is needed for automatic Ansible installation.
    *   For Espanso AppImage: `wget`, systemd (optional, for service).
    *   For Flatpak: Flatpak needs to be installed and configured (e.g., `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`).
*   **Windows**: 
    *   Ansible needs to be installed (e.g., via `pip install ansible` or WSL).
    *   Python must be installed.
    *   WinRM (Windows Remote Management) needs to be configured for Ansible to connect locally. Run the following in an **administrator** PowerShell prompt:
        ```powershell
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Install-Module -Name psrp -Repository PSGallery -Force
        winrm quickconfig -q
        winrm set winrm/config/service/auth @{Basic="true"}
        winrm set winrm/config/service @{AllowUnencrypted="true"} # Use with caution, only for local connection
        # Consider firewall rules if needed: New-NetFirewallRule -Name "WinRM (HTTP-In)" -DisplayName "WinRM (HTTP-In)" -Profile Any -LocalPort 5985 -Protocol TCP
        ```
    *   The relevant package managers (Chocolatey, Scoop, Winget) must be installed if you intend to use them in the playbook. 