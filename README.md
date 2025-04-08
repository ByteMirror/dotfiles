# ByteMirror Dotfiles

Managed by [Chezmoi](https://chezmoi.io).

## How to sync Chezmoi on new Device

```bash
chezmoi init --apply --verbose https://github.com/ByteMirror/dotfiles.git
```

## Package Management with Ansible

This setup integrates Ansible to manage application installations across different operating systems directly when you run `chezmoi apply` after initial setup.

**IMPORTANT**: Ansible is **NOT** installed automatically. See Prerequisites below.

1.  **Manual Prerequisite Installation**: You must install Ansible and its dependencies manually on **any** new machine before running `chezmoi init --apply` for the first time.
2.  **Automatic Package Installation (on `chezmoi apply`)**: After Chezmoi has applied your dotfiles (including the Ansible configuration), subsequent runs of `chezmoi apply` (or the first run of `chezmoi init --apply`) will trigger platform-specific scripts (`run_onchange_after_*`) that execute the Ansible playbook (`ansible/install_packages.yml`). This playbook installs applications defined in `ansible/vars/packages.yml`.
3.  **Configuration**: To add or remove packages, simply edit the lists within `ansible/vars/packages.yml` and run `chezmoi apply`.

### Prerequisites (Manual Setup Required on ALL Platforms)

Before running `chezmoi init --apply` for the first time on any machine:

*   **General**: Git, common system tools (like `curl`, `sh`).
*   **Ansible**: You must manually install Ansible.
    *   **macOS/Linux**: The recommended method is often via your system package manager or `pip`:
        *   `brew install ansible` (macOS)
        *   `sudo apt update && sudo apt install ansible` (Debian/Ubuntu)
        *   `sudo dnf install ansible` (Fedora)
        *   `pip install --user ansible` (Fallback/Other)
        Verify with `ansible --version`.
    *   **Windows**: Follow these steps:
        1.  **Install Python 3**: From [python.org](https://www.python.org/downloads/windows/), ensuring "Add python.exe to PATH" is checked.
        2.  **Install Ansible**: Run `pip install --user ansible` in PowerShell/CMD. Verify with `ansible --version` in a new terminal (add Python Scripts to PATH if needed).
*   **Ansible Collections**: Install required collections on **all** platforms:
    ```bash
    ansible-galaxy collection install community.general community.windows
    ```
*   **Platform Specifics**:
    *   **Linux - Espanso AppImage**: Requires `wget`.
    *   **Linux - Flatpak**: Requires Flatpak installed and configured (e.g., Flathub remote).
    *   **Windows - WinRM**: Configure WinRM for local Ansible by running the following in an **Administrator** PowerShell:
        ```powershell
        winrm quickconfig -q
        winrm set winrm/config/service/auth @{Basic="true"}
        winrm set winrm/config/service @{AllowUnencrypted="true"}
        ```
    *   **Windows - Package Managers**: Ensure Winget, Chocolatey, Scoop are installed if you use them in the playbook.

Once prerequisites are met, `chezmoi init --apply ...` will set up dotfiles and run the Ansible playbook for package installation. 