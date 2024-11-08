# Check for NVIDIA GPU
$nvidiaPresent = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
if ($nvidiaPresent) {
Write-Host "Nvidia Gpu detected!"
}

# Prompt user for confirmation
$confirmation = Read-Host "Is this a gaming PC? (Y/n)"
$confirmationChar = $confirmation[0]

# Prompt user for confirmation
$1pass = Read-Host "Install 1Password manager? (Y/n)"
$1passChar = $1pass[0]

$steel = Read-Host "Install SteelSeries software manager? (Y/n)"
$steelChar = $steel[0]


# If user confirms, install the gaming platforms using winget
if ($confirmationChar.Equals('y', [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Host "Installing applications silently..."

    # List of specific winget commands to install gaming platforms
    $wingetGamingCommands = @(
        { winget install --id=Valve.Steam -e --silent },
        { winget install --id=EpicGames.EpicGamesLauncher -e --silent },
        { winget install --id=ElectronicArts.EADesktop -e --silent },
        { winget install --id=Ubisoft.Connect -e --silent },
        { winget install --id=Blizzard.BattleNet -e --silent --location "C:\Program Files\Battle.net\" }
    )

    # Download Rockstar Games launcher
    $rockstarUrl = "https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe"
    $downloadPath = "c:\windows\temp\Rockstar-Games-Launcher.exe" # Make sure the directory exists or specify another path
    
    Invoke-WebRequest -Uri $rockstarUrl -OutFile $downloadPath
    
    # Run Battle.net installer
    # Note: Rockstar stinker til silent installer. Så det må du selv fixe....
    Start-Process -FilePath $downloadPath
    
    Write-Host "All gaming platforms added to Install script!"
}
else {
    Write-Host "Okay, no gaming platforms will be installed."
}

# Install non-gamingspecific apps
$wingetUtilCommands = @(
    { winget install --id=7zip.7zip -e --silent },
    { winget install --id=REALiX.HWiNFO -e --silent },
    { winget install --id=Mozilla.Firefox -e --silent },
    { winget install --id=Notepad++.Notepad++ -e --silent },
    { winget install --id=Ghisler.TotalCommander -e --silent },
    { winget install --id=VideoLAN.VLC -e --silent },
    { winget install --id=Ookla.Speedtest.Desktop -e --silent },
    { winget install --id=Telegram.TelegramDesktop -e --silent },
    { winget install --id=Discord.Discord -e --silent }
    )
    
    # combine winget lists
    $wingetCommands = $wingetUtilCommands + $wingetGamingCommands
    
    # Add Nvidia GeForce Experience installation if an NVIDIA GPU is detected
    if ($nvidiaPresent) {
        $wingetCommands += { winget install --id=Nvidia.GeForceExperience -e --silent }
    }
    if ($1passChar.Equals('y', [System.StringComparison]::OrdinalIgnoreCase)) {
        $wingetCommands += { winget install --id=AgileBits.1Password -e --silent }
    }
    if ($steelChar.Equals('y', [System.StringComparison]::OrdinalIgnoreCase)) {
        $wingetCommands += { winget install --id=SteelSeries.GG -e --silent }  
    }

# Execute each winget command
foreach ($command in $wingetCommands) {
    Write-Host "Executing $command..."
    & $command
    Write-Host "Command executed silently!"
}


