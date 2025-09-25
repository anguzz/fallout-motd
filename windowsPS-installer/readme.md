# Fallout MOTD for Windows PowerShell & Windows Terminal

Bring a retro **Vault-Tec style MOTD** (Message of the Day) to your PowerShell sessions.
The included `install.ps1` script installs a custom banner plus system stats like uptime, memory, CPU, disk usage, and network info.

---

## Installation

Run the provided script:

```powershell
.\install.ps1
```

What it does:

* Writes the Fallout MOTD banner + stats to your PowerShell profile (`$PROFILE`).
* Ensures the profile is saved as **UTF-8** for proper ASCII rendering.
* Displays a confirmation message once installed.

After installation, the MOTD will display automatically every time you open PowerShell or Windows Terminal.

---

## Example Output

```plaintext
       ___  _      __               ____ ___  ___  ___
      / _ \(_)__  / /  ___  __ __  |_  // _ \/ _ \/ _ \
     / ___/ / _ \/ _ \/ _ \/ // / _/_ </ // / // / // /
    /_/  /_/ .__/_.__/\___/\_, / /____/\___/\___/\___/
          /_/             /___/
Vault-Tec Terminal System

Uptime   : 00d 04h 35m
Memory   : 1.88 GB free
Disk C:  : 220.36 GB used / 253.82 GB free / 474.18 GB total
CPU      : 16.9%% used across 14 cores
Net      : Ethernet 2 192.168.1.10
Traffic  : 239.33 KB/sec
Hostname : Pipboy-3000
Loading personal and system profiles took 8568ms.
```

---

## Profile Location

The MOTD is written to your PowerShell profile:

```plaintext
C:\Users\<username>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

If the file doesn’t exist, the script will create it.
Confirm your active profile path with:

```powershell
Split-Path $PROFILE
```

---

## OneDrive Redirection

If **OneDrive Known Folder Redirection** is enabled, your profile may live under OneDrive:

```plaintext
C:\Users\<username>\OneDrive - <Organization>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

The plus side is the Fallout MOTD will follow you to any device you sign into with OneDrive.

 [Microsoft Docs on KFR](https://learn.microsoft.com/en-us/sharepoint/redirect-known-folders)

---

## Optional: Windows Terminal Customization

You can further tweak the look of Windows Terminal via `settings.json`:

```plaintext
C:\Users\<username>\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

Example (fonts + opacity):

```json
"profiles": {
  "defaults": {
    "font": { "face": "Consolas", "size": 12.5 },
    "opacity": 80
  }
}
```

