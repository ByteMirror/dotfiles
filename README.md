# ByteMirror Dotfiles

Managed by [Chezmoi](https://chezmoi.io).

## How to Use

1.  **Initialize Chezmoi**: On a new machine, run:
    ```bash
    chezmoi init --apply --verbose https://github.com/ByteMirror/dotfiles.git
    ```
    *   **On macOS/Linux**: This attempts to automatically install Ansible (via Homebrew, apt, dnf, etc.) and required collections using the `run_once_before_setup.sh` script if Ansible is not found.
    *   **On Windows**: This only clones the repository and applies dotfiles. **No** automatic setup or package management is performed.
2.  **Apply Changes/Updates**: Running `chezmoi apply` or `chezmoi update` later will:
    *   Apply any dotfile changes.
    *   **On macOS/Linux**: Trigger the `run_onchange_after_apply.sh` script which executes the Ansible playbook (`ansible/install_packages.yml`) to install/update applications defined in `ansible/vars/packages.yml`.
    *   **On Windows**: Only apply dotfile changes.

## Package Management with Ansible (macOS/Linux Only)

This setup integrates Ansible to manage application installations automatically **only on macOS and Linux**.

*   **Automatic Trigger**: On macOS/Linux, Ansible runs automatically via `run_onchange_after_apply.sh` after `chezmoi apply` detects changes.
*   **Configuration**: Define packages to install/manage in `ansible/vars/packages.yml`. macOS uses `macos_brew_packages`, Linux uses `linux_apt_packages`, `linux_dnf_packages`, `linux_flatpak_packages`, and the Espanso AppImage task.

### Prerequisites

*   **General**: Git, common system tools (like `curl`, `sh`).
*   **macOS/Linux**: 
    *   Ideally, have Ansible pre-installed. If not, the `run_once_before_setup.sh` script will attempt installation using common package managers (Homebrew, apt, dnf, pacman, zypper) or pip.
    *   Requires Python 3.
    *   Requires `wget` for Espanso AppImage, Flatpak configured for Flatpak packages if used.
    *   Ansible Collections (`community.general`, `community.windows`) are installed automatically by the setup script.
*   **Windows**: 
    *   Only requires Git and Chezmoi for basic dotfile syncing.
    *   Ansible, Python, WinRM setup, etc., are **not** required for Chezmoi usage as package management is disabled on Windows in this configuration.

### Notes for Restricted Windows Environments

On systems with strict policies (like your work PC):
*   The `run_once_before_*` script won't run (correctly skipped via internal OS check).
*   The `run_onchange_after_apply_ansible.ps1` might still be blocked by Execution Policy. If so, Ansible won't run automatically.
*   In this case, only dotfiles will sync via `chezmoi apply`. You would need to manage applications manually or find alternative ways allowed by your policies. 