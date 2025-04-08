#Requires -Version 5.1
# Check if running as Administrator, needed for WinRM config and potentially Winget/Pip global installs
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script needs to be run as Administrator to configure WinRM and potentially install software system-wide."
    Write-Warning "Attempting to continue, but some steps might fail (especially WinRM setup)."
    # We'll try user installs and hope WinRM was pre-configured or user handles it manually if this fails.
    # Consider adding: Start-Process powershell -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""; exit
    # But relaunching automatically within chezmoi might be complex.
}

Write-Host "Starting Windows setup script..."

# --- Ensure Python is Installed ---
$pythonExe = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonExe) {
    Write-Host "Python not found in PATH. Attempting to install using winget..."
    try {
        # Ensure winget is available
        Get-Command winget -ErrorAction Stop | Out-Null
        Write-Host "Installing Python 3 via winget..."
        # Accept agreements non-interactively
        winget install --id Python.Python.3 --exact --accept-package-agreements --accept-source-agreements --silent
        Write-Host "Python installation via winget attempted. Please ensure it's added to your PATH."
        Write-Host "You might need to restart your terminal/session after this script finishes for PATH changes to take effect."
        # Add a small delay or check mechanism if needed, PATH changes might not be immediate
        Start-Sleep -Seconds 5
    } catch {
        Write-Error "Winget command failed or winget is not available. Cannot automatically install Python. Please install Python 3 manually and ensure it's in your PATH."
        exit 1
    }
} else {
    Write-Host "Python found: $($pythonExe.Source)"
}

# --- Ensure Pip is Available and Install Ansible ---
$pipExe = Get-Command pip -ErrorAction SilentlyContinue
if (-not $pipExe) {
    # Sometimes pip isn't directly in PATH even if Python is. Try python -m pip
     Write-Host "Pip command not found directly in PATH. Trying 'python -m pip'."
     try {
        python -m pip --version | Out-Null
        $pipCommand = "python -m pip"
     } catch {
         Write-Error "Cannot find pip. Ensure Python installation includes pip and it's accessible."
         exit 1
     }
} else {
    $pipCommand = "pip"
}

# Check for Ansible
$ansibleExe = Get-Command ansible -ErrorAction SilentlyContinue
if (-not $ansibleExe) {
    Write-Host "Ansible not found. Attempting to install using $pipCommand..."
    try {
        # Use --user for potentially non-admin scenarios, though some parts need admin later.
        Invoke-Expression "$pipCommand install --user ansible"
        Write-Host "Ansible installation attempted."
        # PATH might need updating for user installs - C:\Users\<user>\AppData\Roaming\Python\Python3X\Scripts
        # We'll rely on ansible-galaxy call below potentially finding it via Python's path knowledge
    } catch {
        Write-Error "Failed to install Ansible using $pipCommand. Error: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Host "Ansible found."
}

# --- Install Ansible Collections ---
# This might require ansible command to be findable AFTER pip install.
# Re-check path or hope the environment picks it up.
Write-Host "Ensuring required Ansible collections are installed..."
try {
    # Try invoking ansible-galaxy directly. If it fails, try python -m ansible_galaxy
    Write-Host "Attempting: ansible-galaxy collection install community.general community.windows"
    ansible-galaxy collection install community.general community.windows | Out-Null
    Write-Host "Collections installed via ansible-galaxy."
} catch {
    Write-Warning "ansible-galaxy command failed directly. Trying 'python -m ansible_galaxy'..."
    try {
         Write-Host "Attempting: python -m ansible_galaxy collection install community.general community.windows"
         python -m ansible_galaxy collection install community.general community.windows | Out-Null
         Write-Host "Collections installed via python -m ansible_galaxy."
    } catch {
        Write-Error "Failed to install Ansible collections. Error: $($_.Exception.Message)"
        # Decide if this is fatal. For now, we'll continue, but playbook will fail.
    }
}


# --- Configure WinRM for Local Ansible ---
# Requires Administrator privileges
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Configuring WinRM for local Ansible execution (requires Administrator)..."

    # 1. Check PSRemoting state
    $psRemotingEnabled = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" -Name "EnablePSRemoting" -ErrorAction SilentlyContinue
    if ($psRemotingEnabled -ne 1) {
         Write-Host "PSRemoting not fully enabled via registry, running Enable-PSRemoting..."
         # Enable-PSRemoting does quickconfig, starts service, sets firewall rules
         Enable-PSRemoting -Force -SkipNetworkProfileCheck
    } else {
         Write-Host "PSRemoting appears enabled via registry, ensuring service state and basic auth..."
         # Even if registry key is set, ensure service is running and auth is set
         winrm quickconfig -q # Ensures listener is present, service started
    }

    # 2. Ensure Basic Auth and AllowUnencrypted (for local loopback)
    try {
        Write-Host "Setting WinRM Basic Auth = true"
        winrm set winrm/config/service/auth '@{Basic="true"}' | Out-Null
        Write-Host "Setting WinRM AllowUnencrypted = true (Needed for localhost connection without Kerberos/HTTPS)"
        winrm set winrm/config/service '@{AllowUnencrypted="true"}' | Out-Null
        Write-Host "WinRM configuration complete."
    } catch {
        Write-Error "Failed to configure WinRM settings (Auth/Unencrypted). Error: $($_.Exception.Message)"
        # This might prevent local Ansible playbook execution
    }
} else {
     Write-Warning "Not running as Administrator. Skipping automatic WinRM configuration."
     Write-Warning "Local Ansible playbook execution might fail if WinRM is not configured manually."
}

Write-Host "Windows setup script finished." 