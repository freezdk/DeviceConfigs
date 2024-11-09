# Enable TLS 1.2 for secure connections
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Function to install Chocolatey if not installed
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } else {
        Write-Host "Chocolatey is already installed."
    }
}

# Install Chocolatey if not installed
Install-Chocolatey

# Function to upgrade or install an application using Chocolatey
function Install-Or-Upgrade ($app) {
    if (Is-Installed $app.id) {
        Write-Host "$($app.id) is already installed. Attempting upgrade..."
        choco upgrade $app.id -y --ignore-checksums
    } else {
        Write-Host "Installing $($app.id)..."
        choco install $app.id -y --ignore-checksums
    }
    Write-Host "$($app.id) installation or upgrade complete."
}

# Function to check if an application is installed using Chocolatey
function Is-Installed ($appId) {
    $installedApps = choco list --local-only
    return $installedApps -like "*$appId*"
}

# Function to check if a web-downloaded app is installed by checking paths and registry
function Is-ApplicationInstalled {
    param (
        [string]$path,
        [string]$regPath
    )
    if (Test-Path $path) {
        return $true
    } elseif (Test-Path $regPath) {
        return $true
    }
    return $false
}

# Function to download and run external installers
function Download-And-Run-Installer {
    param (
        [string]$url,
        [string]$fileName,
        [string]$appPath,
        [string]$regPath
    )
    # Check if the application is already installed
    if (Is-ApplicationInstalled -path $appPath -regPath $regPath) {
        Write-Host "$fileName is already installed. Skipping download."
    } else {
        # Download and run the installer
        $filePath = "$env:TEMP\$fileName"
        if (Test-Path $filePath) { Remove-Item $filePath -Force }
        
        try {
            Write-Host "Downloading $fileName..."
            Invoke-WebRequest -Uri $url -OutFile $filePath
            Write-Host "$fileName downloaded successfully. Running installer..."
            Start-Process -FilePath $filePath -Wait
        } catch {
            Write-Host "Failed to download or run $fileName : $($_.Exception.Message)"
        }
    }
}

# Detect and list all available GPUs
$gpus = Get-WmiObject Win32_VideoController
$gpuNames = $gpus | ForEach-Object { $_.Name }
Write-Host "Detected GPU(s):"
foreach ($gpu in $gpuNames) {
    Write-Host "- $gpu"
}

# Determine if AMD or NVIDIA software should be installed based on detected GPUs
$amdDetected = $gpuNames -match "AMD"
$nvidiaDetected = $gpuNames -match "NVIDIA"

# Initialize empty arrays for optional components
$devTools = @()
$chocoGamingCommands = @()
$chocoCommands = @()

# Prompt user for Dark Mode preference
$darkModePreference = Read-Host "Would you like to enable Dark Mode? (Y/n)"
$darkModePreference = $darkModePreference[0].ToString().ToLower()

# Prompt user for gaming PC and Dev Tools installation confirmation
$confirmation = Read-Host "Is this a gaming PC? (Y/n)"
$confirmationChar = $confirmation[0].ToString().ToLower()
$devToolsPreference = Read-Host "Would you like to install development tools? (Y/n)"
$devToolsPreference = $devToolsPreference[0].ToString().ToLower()

# Prompt user for 1Password and SteelSeries software installation
$install1Pass = Read-Host "Install 1Password manager? (Y/n)"
$install1PassChar = $install1Pass[0].ToString().ToLower()
$installSteel = Read-Host "Install SteelSeries software manager? (Y/n)"
$installSteelChar = $installSteel[0].ToString().ToLower()

if ($darkModePreference -eq 'y') {
    Write-Host "Enabling Dark Mode..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
    Write-Host "Dark Mode enabled. Please restart open applications to see the change."
} else {
    Write-Host "Dark Mode will not be enabled."
}
# Add development tools if requested
if ($devToolsPreference -eq 'y') {
    Write-Host "Adding development tools to installation list..."
    $devTools = @(
        @{ id = "visualstudiocode" },
        @{ id = "git" },
        @{ id = "python" },
        @{ id = "nodejs" },
        @{ id = "docker-desktop" },
        @{ id = "powershell" },
        @{ id = "javaruntime" },
        @{ id = "dotnet-sdk" }
    )
}

# Add gaming platforms if user confirms
if ($confirmationChar -eq 'y') {
    Write-Host "Adding gaming platforms to installation list..."
    $chocoGamingCommands = @(
        @{ id = "steam" },
        @{ id = "epicgameslauncher" }
    )

    # Download and run installers for game launchers
    Download-And-Run-Installer -url "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe" `
        -fileName "EAappInstaller.exe" `
        -appPath "C:\Program Files\Electronic Arts\EA Desktop" `
        -regPath "HKLM:\Software\Electronic Arts\EA Desktop"
    
    Download-And-Run-Installer -url "https://ubi.li/4vxt9" `
        -fileName "UbisoftConnectInstaller.exe" `
        -appPath "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher" `
        -regPath "HKLM:\Software\Ubisoft\Launcher"
    
    Download-And-Run-Installer -url "https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe" `
        -fileName "Rockstar-Games-Launcher.exe" `
        -appPath "C:\Program Files\Rockstar Games\Launcher" `
        -regPath "HKLM:\Software\Rockstar Games\Launcher"
    
    Download-And-Run-Installer -url "https://www.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe" `
        -fileName "BattleNetSetup.exe" `
        -appPath "C:\Program Files (x86)\Battle.net" `
        -regPath "HKLM:\Software\Blizzard Entertainment\Battle.net"
    
    Write-Host "Gaming platforms added to installation list."
}

# Install AMD Adrenalin if an AMD GPU is detected and Adrenalin is not already installed
if ($amdDetected -and -not (Is-AMDAdrenalinInstalled)) {
    Open-AMDDownloadPage
} else {
    Write-Host "AMD Adrenalin is already installed or no AMD GPU detected. Skipping installation."
}

# Install NVIDIA GeForce Experience if an NVIDIA GPU is detected
if ($nvidiaDetected) {
    Write-Host "NVIDIA GPU detected! Preparing to install NVIDIA GeForce Experience."
    if (-not (Is-Installed "nvidia-geforce-experience")) {
        $nvidiaInstall = @{ id = "nvidia-geforce-experience" }
        Install-Or-Upgrade $nvidiaInstall
    } else {
        Write-Host "NVIDIA GeForce Experience is already installed. Skipping installation."
    }
} else {
    Write-Host "No NVIDIA GPU detected. Skipping NVIDIA GeForce Experience installation."
}

# Define non-gaming specific utility apps
$chocoUtilCommands = @(
    @{ id = "7zip" },
    @{ id = "hwinfo" },
    @{ id = "firefox" },
    @{ id = "notepadplusplus" },
    @{ id = "totalcommander" },
    @{ id = "vlc" },
    @{ id = "speedtest" },
    @{ id = "telegram" },
    @{ id = "discord" }
)

# Conditionally add 1Password and SteelSeries based on user preference
if ($install1PassChar -eq 'y') {
    $chocoCommands += @{ id = "1password" }
}
if ($installSteelChar -eq 'y') {
    $chocoCommands += @{ id = "steelseries-gg" }
}

# Combine all lists into $chocoCommands
$chocoCommands += $chocoUtilCommands + $chocoGamingCommands + $devTools
Write-Host "Combined all installation commands into chocoCommands array."

# Execute each Chocolatey command only if the application is not already installed, otherwise upgrade
foreach ($app in $chocoCommands) {
    Install-Or-Upgrade $app
    Write-Host "$($app.id) installation or upgrade completed."
}

Write-Host "Installation process complete."
