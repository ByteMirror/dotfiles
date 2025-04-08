# PowerShell script to manually run the Ansible package playbook

$ErrorActionPreference = "Stop"

# Assuming this script is run from the Chezmoi source directory root
$AnsibleDir = Join-Path $PSScriptRoot "ansible"
$PlaybookFile = Join-Path $AnsibleDir "install_packages.yml"
$InventoryFile = Join-Path $AnsibleDir "inventory.ini"

Write-Host "Checking for Ansible playbook: $PlaybookFile"

if ((Test-Path $AnsibleDir -PathType Container) -and (Test-Path $PlaybookFile -PathType Leaf)) {
    Write-Host "Found playbook. Running Ansible playbook to install/update packages..."

    # Use python -m ansible_playbook to bypass potential wrapper script issues
    try {
        # Ensure python is callable
        Get-Command python -ErrorAction Stop | Out-Null
        Write-Host "Executing: python -m ansible_playbook $PlaybookFile -i $InventoryFile"
        # Execute and pass through output/errors
        python -m ansible_playbook $PlaybookFile -i $InventoryFile
        $exitCode = $LASTEXITCODE
        Write-Host "Ansible playbook finished with exit code: $exitCode"
        exit $exitCode # Exit with Ansible's exit code
    } catch {
        Write-Error "Failed to execute Ansible playbook. Error: $($_.Exception.Message)"
        # Check if python command was the issue
        if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
            Write-Error "'python' command not found. Ensure Python is installed and in PATH."
        }
        exit 1 # Indicate failure
    }
} else {
    Write-Error "Ansible directory '$AnsibleDir' or playbook '$PlaybookFile' not found relative to script location. Ensure you run this from the Chezmoi source root."
    exit 1
} 