# Function to check if an application is installed using winget
function Is-Installed ($appId) {
    $installedApps = winget list
    return $installedApps -match $appId
}

# Initialize empty arrays for optional components
$devTools = @()
$wingetGamingCommands = @()

# Check for NVIDIA GPU
$nvidiaPresent = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
if ($nvidiaPresent) {
    Write-Host "Nvidia GPU detected!"
} else {
    Write-Host "No Nvidia GPU detected!"
}

# Detect and list all available GPUs
$gpus = Get-WmiObject Win32_VideoController
if ($gpus) {
    Write-Host "Detected GPU(s):"
    foreach ($gpu in $gpus) {
        Write-Host "- $($gpu.Name)"
    }
} else {
    Write-Host "No GPU detected!"
}

# Prompt user for Dark Mode preference
$darkModePreference = Read-Host "Would you like to enable Dark Mode? (Y/n)"
$darkModePreference = $darkModePreference[0].ToString().ToLower()

# Check user input and set Dark Mode if 'Y' or 'y' is selected
if ($darkModePreference -eq 'y') {
    # Enable Dark Mode for System
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
    
    # Enable Dark Mode for Apps
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
    
    Write-Host "Dark Mode has been enabled for both system and apps. Please restart any open applications to see the change."
} else {
    Write-Host "Dark Mode will not be enabled."
}

# Prompt user for confirmation
$confirmation = Read-Host "Is this a gaming PC? (Y/n)"
$confirmationChar = $confirmation[0].ToString().ToLower()

# Prompt user for Dev Tools installation preference
$devToolsPreference = Read-Host "Would you like to install development tools? (Y/n)"
$devToolsPreference = $devToolsPreference[0].ToString().ToLower()

# Check user input and populate Dev Tools array if 'Y' or 'y' is selected
if ($devToolsPreference -eq 'y') {
    Write-Host "Adding development tools to installation list..."
    $devTools = @(
        @{ id = "Microsoft.VisualStudioCode"; command = { winget install --id=Microsoft.VisualStudioCode -e --silent } },
        @{ id = "Git.Git"; command = { winget install --id=Git.Git -e --silent } },
        @{ id = "Python.Python.3"; command = { winget install --id=Python.Python.3 -e --silent } },
        @{ id = "NodeJS.NodeJS"; command = { winget install --id=NodeJS.NodeJS -e --silent } },
        @{ id = "Docker.DockerDesktop"; command = { winget install --id=Docker.DockerDesktop -e --silent } },
        @{ id = "Microsoft.PowerShell"; command = { winget install --id=Microsoft.PowerShell -e --silent } },
        @{ id = "Oracle.JavaRuntimeEnvironment"; command = { winget install --id=Oracle.JavaRuntimeEnvironment -e --silent } }
    )
}

# Prompt user for 1Password and SteelSeries software installation
$install1Pass = Read-Host "Install 1Password manager? (Y/n)"
$install1PassChar = $install1Pass[0].ToString().ToLower()

$installSteel = Read-Host "Install SteelSeries software manager? (Y/n)"
$installSteelChar = $installSteel[0].ToString().ToLower()

# If user confirms, populate the gaming platforms array
if ($confirmationChar -eq 'y') {
    Write-Host "Adding gaming platforms to installation list..."
    $wingetGamingCommands = @(
        @{ id = "Valve.Steam"; command = { winget install --id=Valve.Steam -e --silent } },
        @{ id = "EpicGames.EpicGamesLauncher"; command = { winget install --id=EpicGames.EpicGamesLauncher -e --silent } },
        @{ id = "ElectronicArts.EADesktop"; command = { winget install --id=ElectronicArts.EADesktop -e --silent } },
        @{ id = "Ubisoft.Connect"; command = { winget install --id=Ubisoft.Connect -e --silent } },
        @{ id = "Blizzard.BattleNet"; command = { winget install --id=Blizzard.BattleNet -e --silent --location "C:\Program Files\Battle.net\" } }
    )
}

# Define non-gaming specific utility apps
$wingetUtilCommands = @(
    @{ id = "7zip.7zip"; command = { winget install --id=7zip.7zip -e --silent } },
    @{ id = "REALiX.HWiNFO"; command = { winget install --id=REALiX.HWiNFO -e --silent } },
    @{ id = "Mozilla.Firefox"; command = { winget install --id=Mozilla.Firefox -e --silent } },
    @{ id = "Notepad++.Notepad++"; command = { winget install --id=Notepad++.Notepad++ -e --silent } },
    @{ id = "Ghisler.TotalCommander"; command = { winget install --id=Ghisler.TotalCommander -e --silent } },
    @{ id = "VideoLAN.VLC"; command = { winget install --id=VideoLAN.VLC -e --silent } },
    @{ id = "Ookla.Speedtest.Desktop"; command = { winget install --id=Ookla.Speedtest.Desktop -e --silent } },
    @{ id = "Telegram.TelegramDesktop"; command = { winget install --id=Telegram.TelegramDesktop -e --silent } },
    @{ id = "Discord.Discord"; command = { winget install --id=Discord.Discord -e --silent } }
)

# Combine all lists
$wingetCommands = $wingetUtilCommands + $wingetGamingCommands + $devTools

# Conditionally add 1Password and SteelSeries based on user preference
if ($install1PassChar -eq 'y') {
    $wingetCommands += @{ id = "AgileBits.1Password"; command = { winget install --id=AgileBits.1Password -e --silent } }
}
if ($installSteelChar -eq 'y') {
    $wingetCommands += @{ id = "SteelSeries.GG"; command = { winget install --id=SteelSeries.GG -e --silent } }
}
if ($nvidiaPresent) {
    $wingetCommands += @{ id = "Nvidia.GeForceExperience"; command = { winget install --id=Nvidia.GeForceExperience -e --silent } }
}

# Execute each winget command only if the application is not already installed
foreach ($app in $wingetCommands) {
    if (-not (Is-Installed $app.id)) {
        Write-Host "Installing $($app.id)..."
        & $app.command
        Write-Host "$($app.id) installed."
    } else {
        Write-Host "$($app.id) is already installed. Skipping..."
    }
}

Read-Host "Installation has finished, press any key to close..."
