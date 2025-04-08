# PowerShell script to run Ansible playbook after Chezmoi applies changes

$ErrorActionPreference = "Stop"

$AnsibleDir = Join-Path $env:CHEZMOI_SOURCE_DIR "ansible"
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
        python -m ansible_playbook $PlaybookFile -i $InventoryFile
        $exitCode = $LASTEXITCODE
        Write-Host "Ansible playbook finished with exit code: $exitCode"
        # Optionally check exit code
        # if ($exitCode -ne 0) {
        #     Write-Error "Ansible playbook failed with exit code $exitCode"
        #     exit $exitCode # Propagate error
        # }
    } catch {
        Write-Error "Failed to execute Ansible playbook. Error: $($_.Exception.Message)"
        # Check if python command was the issue
        if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
            Write-Error "'python' command not found. Ensure Python is installed and in PATH."
        }
        exit 1 # Indicate failure
    }
} else {
    Write-Warning "Ansible directory '$AnsibleDir' or playbook '$PlaybookFile' not found in chezmoi source directory. Skipping Ansible run."
}

Write-Host "onchange_after script finished." 