<#
.SYNOPSIS
    Removes the APOD Wallpaper scheduled task, and optionally the files it created.
.DESCRIPTION
    Unregisters the scheduled task created by Install-APODTask.ps1.
    With -RemoveFiles, also deletes the desktop shortcut and the Pictures\APOD folder.
    The current wallpaper is left as-is.
.PARAMETER TaskName
    Name of the scheduled task. Defaults to 'APOD Wallpaper'.
.PARAMETER RemoveFiles
    Also delete the desktop shortcut and all downloaded APOD images.
.EXAMPLE
    .\Uninstall-APODTask.ps1
.EXAMPLE
    .\Uninstall-APODTask.ps1 -RemoveFiles
.NOTES
    Author: Brad Zabitosky
    Date:   2026-10-12
#>
[CmdletBinding()]
param(
    [string]$TaskName = 'APOD Wallpaper',
    [switch]$RemoveFiles
)

$ErrorActionPreference = 'Stop'

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Removed scheduled task '$TaskName'." -ForegroundColor Green
}
else {
    Write-Host "Scheduled task '$TaskName' not found; nothing to remove."
}

if ($RemoveFiles) {
    $ShortcutPath   = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Astronomy Picture of the Day.url'
    $PicturesFolder = Join-Path ([Environment]::GetFolderPath('MyPictures')) 'APOD'

    if (Test-Path -Path $ShortcutPath) {
        Remove-Item -Path $ShortcutPath -Force
        Write-Host "Removed desktop shortcut."
    }

    if (Test-Path -Path $PicturesFolder) {
        Remove-Item -Path $PicturesFolder -Recurse -Force
        Write-Host "Removed downloaded images folder: $PicturesFolder"
    }
}

Write-Host "Your current wallpaper was not changed. Use Settings > Personalization > Background to pick a new one."
