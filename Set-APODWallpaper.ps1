   <#
   .SYNOPSIS
       Sets the desktop wallpaper to NASA's Astronomy Picture of the Day.
   .DESCRIPTION
       Uses the NASA Astronomy Picture of the Day (APOD) API to download that image, set it as the desktop wallpaper, and create/update a desktop shortcut that can look at the APOD article.
   .NOTES
       Author: Brad Zabitosky
       Date:   2026-10-12
   #>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$BaseUrl = "https://science.nasa.gov/wp-json/wp/v2/apod-basic"
$Response = Invoke-RestMethod -Method GET -Uri $BaseUrl
$Post = $Response[0]

$Date = $Post.date
$MediaType = $Post.media_type

$PicturesFolder = Join-Path ([Environment]::GetFolderPath('MyPictures')) "APOD"
$DesktopFolder = [Environment]::GetFolderPath('Desktop')
$ImagePath = Join-Path $PicturesFolder "APOD-$Date.jpg"
$ShortcutPath = "$DesktopFolder\Astronomy Picture of the Day.url"


########################################################
# Function to set desktop wallpaper to downloaded image
function Set-Wallpaper {
    Add-Type -TypeDefinition @"
    using System.Runtime.InteropServices;
    public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
# 0x14 = SPI_SETDESKWALLPAPER; 0x01 -bor 0x02 = save to profile + broadcast the change
[Wallpaper]::SystemParametersInfo(0x14, 0, $ImagePath, 0x01 -bor 0x02) | Out-Null
}
# Function to create desktop shortcut to URL of new APOD
function Set-DesktopShortcut {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$ShortcutPath")
    $Shortcut.TargetPath = $Post.url
    $Shortcut.Save()
}
########################################################


# Exits script if APOD is not an image
if ($MediaType -ne "image") {
    Write-Host "APOD is not an image, trying again tomorrow."
    exit
}

# Creates Users Pictures\APOD folder if it does not exist
if (-not (Test-Path -Path $PicturesFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $PicturesFolder | Out-Null
}

# Downloads Image from NASA
Invoke-WebRequest -Uri- UseBasicParsing $Post.hdurl -OutFile $ImagePath

Set-Wallpaper
Set-DesktopShortcut