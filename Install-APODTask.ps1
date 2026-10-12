<#
.SYNOPSIS
    Schedules Set-APODWallpaper.ps1 to run daily and at sign-in.
.DESCRIPTION
    Registers a Windows scheduled task, under the current user's account, that runs
    Set-APODWallpaper.ps1 every day at the chosen time and one minute after each sign-in.
    If the PC is off or asleep at the scheduled time, the task runs as soon as possible afterward.
    Re-running this script replaces the existing task, so it can be used to change the time.
    Does not require administrator rights.
.PARAMETER Time
    Time of day to run, e.g. '9:00AM' or '18:30'. Defaults to 9:00 AM.
.PARAMETER TaskName
    Name of the scheduled task. Defaults to 'APOD Wallpaper'.
.EXAMPLE
    .\Install-APODTask.ps1
.EXAMPLE
    .\Install-APODTask.ps1 -Time '7:30AM'
.NOTES
    Author: Brad Zabitosky
    Date:   2026-10-12
#>
[CmdletBinding()]
param(
    [string]$Time = '9:00AM',
    [string]$TaskName = 'APOD Wallpaper'
)

$ErrorActionPreference = 'Stop'

$ScriptPath = Join-Path $PSScriptRoot 'Set-APODWallpaper.ps1'
if (-not (Test-Path -Path $ScriptPath -PathType Leaf)) {
    throw "Could not find '$ScriptPath'. Run this installer from the same folder as Set-APODWallpaper.ps1."
}

# Remove the "downloaded from the internet" flag so the task isn't blocked
Unblock-File -Path $ScriptPath

# Current user, e.g. DESKTOP-ABC\brad or AzureAD\BradZ
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$Action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""

$DailyTrigger = New-ScheduledTaskTrigger -Daily -At $Time
$LogonTrigger = New-ScheduledTaskTrigger -AtLogOn -User $CurrentUser
$LogonTrigger.Delay = 'PT1M'   # wait 1 minute after sign-in so the network is up

$Settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10)

# Interactive = runs only while the user is signed in (required to change their wallpaper)
$Principal = New-ScheduledTaskPrincipal -UserId $CurrentUser -LogonType Interactive -RunLevel Limited

Register-ScheduledTask `
    -TaskName $TaskName `
    -Description 'Sets the desktop wallpaper to NASA''s Astronomy Picture of the Day.' `
    -Action $Action `
    -Trigger $DailyTrigger, $LogonTrigger `
    -Settings $Settings `
    -Principal $Principal `
    -Force | Out-Null

$NextRun = (Get-ScheduledTaskInfo -TaskName $TaskName).NextRunTime
Write-Host "Scheduled task '$TaskName' created for $CurrentUser." -ForegroundColor Green
Write-Host "Runs daily at $Time and at each sign-in. Next scheduled run: $NextRun"
Write-Host "To test it now:  Start-ScheduledTask -TaskName '$TaskName'"
