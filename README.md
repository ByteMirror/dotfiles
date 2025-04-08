# ByteMirror Dotfiles

Managed by [Chezmoi](https://chezmoi.io).

## How to Use

1.  **Install Prerequisites**: Manually install Git, Chezmoi, Python 3, Ansible, required Ansible Collections, and configure WinRM (Windows only). See the Prerequisites section below.
2.  **Initialize Chezmoi**: On a new machine, run:
    ```bash
    chezmoi init --apply --verbose https://github.com/ByteMirror/dotfiles.git
    ```
    This clones the repository and applies your dotfiles.
3.  **Sync Dotfiles**: To apply changes to dotfiles pulled from the repo later, run:
    ```bash
    chezmoi apply -v
    ```
4.  **Sync Applications/Packages**: To manually run the Ansible playbook and install/update applications defined in `ansible/vars/packages.yml`, navigate to your Chezmoi source directory (`chezmoi cd`) and run the appropriate script:
    *   **Windows**: `powershell ./sync-apps.ps1`
    *   **macOS/Linux**: `sh ./sync-apps.sh` or `./sync-apps.sh` (if executable)

## Package Management with Ansible

This setup uses Ansible to manage application installations, but it is **run manually**, separate from the `chezmoi apply` command for dotfiles.

*   **Manual Trigger**: Use the `sync-apps.ps1` (Windows) or `sync-apps.sh` (Unix) scripts in the root of the source directory to run the Ansible playbook (`ansible/install_packages.yml`).
*   **Configuration**: Define packages to install/manage in `ansible/vars/packages.yml`.

### Prerequisites (Manual Setup Required on ALL Platforms)

Before running `chezmoi init --apply` or `sync-apps.*` for the first time:

*   **General**: Git, Chezmoi, Python 3, common system tools (like `curl`, `sh`).
*   **Ansible**: Manually install Ansible (e.g., via `pip install --user ansible`). Verify with `ansible --version`.
*   **Ansible Collections**: Install required collections: `ansible-galaxy collection install community.general community.windows`.
*   **Platform Specifics**: (Ensure Python is in PATH, configure WinRM on Windows, install necessary Linux tools like `wget`/Flatpak, install Windows package managers like Winget/Choco/Scoop if used in the playbook - refer to detailed manual setup steps in previous README versions or documentation if needed).

Once prerequisites are met, `chezmoi init --apply ...` will set up dotfiles, and you can run the `sync-apps.*` scripts to manage packages. 