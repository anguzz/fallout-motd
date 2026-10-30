#requires -Version 5.1
param(
    [string]$ProfilePath = $PROFILE,
    [switch]$Uninstall
)
$ErrorActionPreference = 'Stop'

$profileDir = Split-Path $ProfilePath -Parent
$motdPath   = Join-Path $profileDir 'Fallout-MOTD.ps1'
$startTag   = '# >>> Fallout MOTD >>>'
$endTag     = '# <<< Fallout MOTD <<<'
$blockRegex = '(?s)\r?\n?' + [regex]::Escape($startTag) + '.*?' + [regex]::Escape($endTag) + '\r?\n?'

New-Item -Path $profileDir -ItemType Directory -Force | Out-Null

# Back up the existing profile before touching it
$existing = ''
if (Test-Path $ProfilePath) {
    Copy-Item $ProfilePath "$ProfilePath.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
    $existing = Get-Content $ProfilePath -Raw
    if ($null -eq $existing) { $existing = '' }
}

# Strip any previous install (new-style block, or the old version that overwrote the whole profile)
$existing = [regex]::Replace($existing, $blockRegex, "`r`n")
if ($existing -match 'function Show-MOTD' -and $existing -match 'Vault-Tec Terminal System') {
    Write-Host ' Legacy MOTD profile detected - replacing it (backup saved).' -ForegroundColor Yellow
    $existing = ''
}

if ($Uninstall) {
    Set-Content -Path $ProfilePath -Value $existing.Trim() -Encoding UTF8
    Remove-Item $motdPath -ErrorAction SilentlyContinue
    Write-Host ' Fallout MOTD removed.' -ForegroundColor Green
    return
}

$motd = @'
function Show-MOTD {
    [CmdletBinding()]
    param(
        [switch]$NoClear,   # keep previous console output
        [switch]$Animate    # retro line-by-line "boot" effect
    )

    $g  = 'Green'
    $dg = 'DarkGreen'
    if (-not $NoClear) { Clear-Host }

    $banner = @(
        '   ___  _      __               ____ ___  ___  ___ '
        '  / _ \(_)__  / /  ___  __ __  |_  // _ \/ _ \/ _ \'
        ' / ___/ / _ \/ _ \/ _ \/ // / _/_ </ // / // / // /'
        '/_/  /_/ .__/_.__/\___/\_, / /____/\___/\___/\___/ '
        '      /_/             /___/                        '
    )
    foreach ($l in $banner) {
        Write-Host $l -ForegroundColor $g
        if ($Animate) { Start-Sleep -Milliseconds 40 }
    }
    Write-Host ''
    Write-Host '  VAULT-TEC TERMINAL SYSTEM  //  ROBCO INDUSTRIES (TM) TERMLINK' -ForegroundColor $g
    Write-Host ('  ' + ('=' * 64)) -ForegroundColor $dg

    function Get-Bar([double]$Pct, [int]$Width = 20) {
        $Pct = [math]::Max(0, [math]::Min(100, $Pct))
        $n   = [int][math]::Round($Pct / 100 * $Width)
        '[' + ('#' * $n) + ('.' * ($Width - $n)) + ']'
    }
    function Write-Stat([string]$Label, [string]$Value, $Pct = $null) {
        Write-Host ('  {0,-9}: ' -f $Label) -ForegroundColor $dg -NoNewline
        if ($null -ne $Pct) {
            $c = if ($Pct -ge 90) { 'Red' } elseif ($Pct -ge 75) { 'Yellow' } else { $g }
            Write-Host ('{0} {1,3:N0}%  ' -f (Get-Bar $Pct), $Pct) -ForegroundColor $c -NoNewline
        }
        Write-Host $Value -ForegroundColor $g
        if ($Animate) { Start-Sleep -Milliseconds 25 }
    }

    try {
        $os    = Get-CimInstance Win32_OperatingSystem
        $cpu   = @(Get-CimInstance Win32_Processor)
        $disks = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3'

        Write-Stat 'Dweller' ("{0}\{1} @ {2}" -f $env:USERDOMAIN, $env:USERNAME, $env:COMPUTERNAME)
        Write-Stat 'OS'      ("{0} (build {1})" -f ($os.Caption -replace '^Microsoft\s+'), $os.BuildNumber)
        Write-Stat 'Shell'   ("PowerShell {0} {1}" -f $PSVersionTable.PSVersion, $PSVersionTable.PSEdition)

        $upt = (Get-Date) - $os.LastBootUpTime
        Write-Stat 'Uptime'  ("{0}d {1}h {2}m" -f $upt.Days, $upt.Hours, $upt.Minutes)

        $load  = ($cpu | Measure-Object LoadPercentage -Average).Average
        $cores = ($cpu | Measure-Object NumberOfLogicalProcessors -Sum).Sum
        Write-Stat 'CPU' ("{0} threads - {1}" -f $cores, ($cpu[0].Name -replace '\s+', ' ').Trim()) $load

        $memTotal = $os.TotalVisibleMemorySize / 1MB   # KB -> GB
        $memUsed  = $memTotal - ($os.FreePhysicalMemory / 1MB)
        Write-Stat 'Memory' ("{0:N1} / {1:N1} GB" -f $memUsed, $memTotal) ($memUsed / $memTotal * 100)

        foreach ($d in $disks) {
            if (-not $d.Size) { continue }
            $used = ($d.Size - $d.FreeSpace) / 1GB
            $tot  = $d.Size / 1GB
            Write-Stat "Disk $($d.DeviceID)" ("{0:N0} / {1:N0} GB" -f $used, $tot) ($used / $tot * 100)
        }

        if (Get-Command Get-NetIPAddress -ErrorAction SilentlyContinue) {
            Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -ErrorAction SilentlyContinue |
                Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
                ForEach-Object { Write-Stat 'Net' ("{0} ({1})" -f $_.IPAddress, $_.InterfaceAlias) }
        }
    }
    catch {
        Write-Host "  [!] Diagnostics offline: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Write-Stat 'Date' (Get-Date -Format 'dddd, MMM d yyyy  HH:mm')
    Write-Host ('  ' + ('=' * 64)) -ForegroundColor $dg
    Write-Host ''
}
Set-Alias -Name motd -Value Show-MOTD
'@

Set-Content -Path $motdPath -Value $motd -Encoding UTF8

$block = @"
$startTag
`$falloutMotd = Join-Path `$PSScriptRoot 'Fallout-MOTD.ps1'
if (Test-Path `$falloutMotd) {
    . `$falloutMotd
    # Only show in interactive consoles (skip scripts, -NonInteractive, VS Code, CI) - set `$env:NO_MOTD=1 to disable
    if (`$Host.Name -eq 'ConsoleHost' -and [Environment]::UserInteractive -and -not `$env:NO_MOTD -and
        -not ([Environment]::GetCommandLineArgs() -match '^-NonI')) { Show-MOTD }
}
Remove-Variable falloutMotd -ErrorAction SilentlyContinue
$endTag
"@

Set-Content -Path $ProfilePath -Value ($existing.TrimEnd() + "`r`n`r`n" + $block).TrimStart() -Encoding UTF8

Write-Host " Fallout MOTD installed: $motdPath" -ForegroundColor Green
Write-Host " Hooked into profile:    $ProfilePath  (run 'motd' anytime, or 'motd -Animate')" -ForegroundColor Green
