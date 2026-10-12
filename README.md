# APOD Wallpaper

Automatically set your Windows desktop background to NASA's [Astronomy Picture of the Day](https://science.nasa.gov/apod/) (APOD), every day.

Each run, the script:

- Grabs today's APOD from NASA's public feed (no API key or account needed)
- Saves the full-resolution image to `Pictures\APOD\APOD-YYYY-MM-DD.jpg`
- Sets it as your desktop wallpaper
- Creates/updates a desktop shortcut, **Astronomy Picture of the Day**, that opens the article explaining the image

If the day's APOD is a video instead of an image, the script does nothing and tries again on the next run.

---

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 (built into Windows; nothing to install)
- An internet connection
- **No administrator rights needed.** Everything runs as your own user account.

---

## Setup (about 5 minutes)

### 1. Download the files

**Option A – ZIP (easiest):** On this GitHub page, click the green **Code** button, then **Download ZIP**.

**Option B – Git:**
```powershell
git clone https://github.com/<your-username>/apod-wallpaper.git
```

### 2. Put the folder somewhere permanent

The scheduled task points at the folder's exact location, so **don't run it from your Downloads folder** if you tend to clean that out. A good spot:

```
C:\Users\<you>\Scripts\apod-wallpaper
```

If you downloaded the ZIP, right-click it → **Extract All…** and choose that location.

### 3. Open PowerShell in that folder

Open the folder in File Explorer, click the address bar, type `powershell`, and press **Enter**. A PowerShell window opens already pointed at the right folder.

> Use a normal (not "Run as administrator") window. The task needs to be created under your own account, since wallpaper is a per-user setting.

### 4. Allow the scripts to run

Windows blocks scripts downloaded from the internet by default. Run these two lines:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Get-ChildItem *.ps1 | Unblock-File
```

- The first line only applies to **this one PowerShell window**. It doesn't change any system setting and goes away when you close the window.
- The second line removes the "downloaded from the internet" flag from these scripts only.

### 5. Test it once

```powershell
.\Set-APODWallpaper.ps1
```

Your wallpaper should change to today's APOD within a few seconds, and the shortcut should appear on your desktop. If it doesn't, see [Troubleshooting](#troubleshooting) before going further.

### 6. Schedule it to run every day

```powershell
.\Install-APODTask.ps1
```

This creates a Windows scheduled task called **APOD Wallpaper** that runs:

- **Every day at 9:00 AM**, and
- **Each time you sign in** (one minute after sign-in, so the network has time to connect)

If your PC is off or asleep at 9:00 AM, the task runs as soon as possible afterward.

To pick a different time:
```powershell
.\Install-APODTask.ps1 -Time '7:30AM'
```

You can re-run the installer at any time to change the schedule; it replaces the existing task.

**That's it.** You can close the PowerShell window.

---

## What gets created

| Item | Location |
|------|----------|
| Downloaded images | `%USERPROFILE%\Pictures\APOD\` |
| Desktop shortcut | `Desktop\Astronomy Picture of the Day.url` |
| Scheduled task | Task Scheduler Library → **APOD Wallpaper** |

> **Heads-up on disk space:** images are kept, not replaced, so the folder grows by roughly 1–15 MB per day (a few GB per year). Clear it out occasionally, or see [Cleaning up old images](#cleaning-up-old-images).

---

## Uninstall

From the project folder (repeat step 4 first if it's a new PowerShell window):

```powershell
.\Uninstall-APODTask.ps1
```

This removes the scheduled task. To also delete the desktop shortcut and every downloaded image:

```powershell
.\Uninstall-APODTask.ps1 -RemoveFiles
```

Your current wallpaper stays as it is; change it in **Settings → Personalization → Background** if you want something else. Then delete the project folder.

---

## Troubleshooting

**"…cannot be loaded because running scripts is disabled on this system"**
You skipped step 4, or opened a new PowerShell window. Run the two lines in step 4 again.

**The script ran but the wallpaper didn't change**
- Check **Settings → Personalization → Background**. If it's set to **Windows Spotlight** or **Slideshow**, Windows may override the image. Set it to **Picture**.
- On work or school computers, the wallpaper is often locked by your organization's policy. The script can't override that.

**It works when I run it by hand but not on schedule**
Open **Task Scheduler**, find **APOD Wallpaper**, and check the **Last Run Result** column and the **History** tab. You can also right-click the task → **Run** to test it. Make sure the project folder hasn't been moved or renamed since you ran the installer; if it has, re-run `Install-APODTask.ps1` from the new location.

**A PowerShell window flashes briefly each morning**
That's expected. Windows briefly shows the console before hiding it.

**The wallpaper is blurry/low-resolution on some days**
Some APOD entries (usually videos or animations) are labeled as images in NASA's feed but only provide a small preview picture. It'll be back to normal the next day.

---

## Cleaning up old images

To delete downloaded images older than 30 days, run this in PowerShell:

```powershell
Get-ChildItem "$([Environment]::GetFolderPath('MyPictures'))\APOD" -Filter 'APOD-*' |
    Where-Object LastWriteTime -lt (Get-Date).AddDays(-30) |
    Remove-Item
```

---

## How it works

The script calls NASA's public APOD feed at `https://science.nasa.gov/wp-json/wp/v2/apod-basic`, which returns recent APOD entries as JSON (newest first). It takes the first entry and uses:

- `media_type` to skip non-image days
- `hdurl` to download the full-resolution image
- `url` for the desktop shortcut to the article
- `date` to name the saved file

The wallpaper is set through the Windows `SystemParametersInfo` API, the same mechanism the Settings app uses.

---

## Image credits

APOD images are **not** all public domain. Many are copyrighted by the photographers who created them, and each day's credit is listed on the APOD article (the desktop shortcut opens it). This project only downloads the daily image for personal use as a wallpaper; please don't redistribute images without checking their credit and license. See NASA's [About APOD](https://science.nasa.gov/apod/about-apod/) page for details.

This project is not affiliated with or endorsed by NASA.

---

## License

The scripts in this repository are released under the [MIT License](LICENSE).
