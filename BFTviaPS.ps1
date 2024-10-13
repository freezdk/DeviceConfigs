# Prompt user for confirmation
$confirmation = Read-Host "Is this a gaming PC? (yes/no)"

# If user confirms, install the gaming platforms using winget
if ($confirmation -eq 'yes') {
    Write-Host "Installing applications silently..."

    # List of specific winget commands to install gaming platforms
    $wingetCommands = @(
        { winget install --id=Valve.Steam -e --silent },
        { winget install --id=EpicGames.EpicGamesLauncher -e --silent },
        { winget install --id=ElectronicArts.EADesktop -e --silent },
        { winget install --id=Ubisoft.Connect -e --silent },
        { winget install --id=Blizzard.BattleNet -e --silent --location "C:\Program Files\Battle.net\" }
        { winget install --id=7zip.7zip -e --silent }
        { winget install --id=REALiX.HWiNFO -e --silent }
        { winget install --id=Mozilla.Firefox -e --silent }
        { winget install --id=Notepad++.Notepad++ -e --silent }
        { winget install --id=SteelSeries.GG -e --silent }
        { winget install --id=Ghisler.TotalCommander -e --silent }
        { winget install --id=VideoLAN.VLC -e --silent }
        { winget install --id=Ookla.Speedtest.Desktop -e --silent }
        { winget install --id=AgileBits.1Password -e --silent }
        { winget install --id=Corsair.iCUE.5 -e --silent }
        { winget install --id=Nvidia.GeForceExperience -e --silent }
        { winget install --id=Telegram.TelegramDesktop -e --silent }
        { winget install --id=Discord.Discord -e --silent }
        { winget install --id=Spotify.Spotify -e --silent }
    )

    # Execute each winget command
    foreach ($command in $wingetCommands) {
        Write-Host "Executing $command..."
        & $command
        Write-Host "Command executed silently!"
    }

 # Download Rockstar Games launcher
    $rockstarUrl = "https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe"
    $downloadPath = "c:\windows\temp\Rockstar-Games-Launcher.exe" # Make sure the directory exists or specify another path
    
    Invoke-WebRequest -Uri $rockstarUrl -OutFile $downloadPath
    
    # Run Battle.net installer
    # Note: Rockstar stinker til silent installer. Så det må du selv fixe....
    Start-Process -FilePath $downloadPath

    Write-Host "All gaming platforms installed!"
}
else {
    Write-Host "Okay, no gaming platforms will be installed."
}
