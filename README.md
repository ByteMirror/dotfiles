# ByteMirror Dotfiles

Managed by [Chezmoi](https://chezmoi.io).

## How to Use

1.  **Prerequisites**: Ensure `git` and `curl` are installed on the new system.
2.  **Initialize Chezmoi**: On a new **macOS or Linux** machine, run:
    ```bash
    chezmoi init --apply --verbose https://github.com/ByteMirror/dotfiles.git
    ```
    This command will:
    *   Clone the repository.
    *   Run a setup script (`run_once_before_setup.sh`) that attempts to:
        *   Install `zsh`, `git`, `curl` (if missing) using the system package manager.
        *   Install Oh My Zsh.
        *   Install the Powerlevel10k theme.
        *   Install Ansible (if missing) using the system package manager or pip.
        *   Install the required Ansible collection (`community.general`).
    *   Apply your managed dotfiles (including `.zshrc`, `.p10k.zsh`, etc.).
    *   Run the Ansible playbook (`run_onchange_after_apply.sh`) to install applications defined in `ansible/vars/packages.yml`.
3.  **Apply Changes/Updates**: Running `chezmoi apply -v` or `chezmoi update -v` later will apply dotfile changes and re-run the Ansible playbook if changes occurred.
4.  **Manual Application Sync**: Use `pkg sync` (defined in `.zshrc`) to run the Ansible playbook on demand.

**Note:** This setup is primarily designed for macOS and Linux. On Windows, only dotfile synchronization via `chezmoi apply` is supported; automated setup and package management are disabled.

## Package Management (macOS/Linux Only)

*   Applications are managed via Ansible, configured in `ansible/vars/packages.yml`.
*   Run `pkg sync` to manually trigger an application update/installation check.
*   Ansible also runs automatically after `chezmoi apply` modifies files.

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