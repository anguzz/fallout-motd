
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}


$motd = @'
function Show-MOTD {
    Clear-Host
    Write-Host @"
       ___  _      __               ____ ___  ___  ___ 
      / _ \(_)__  / /  ___  __ __  |_  // _ \/ _ \/ _ \
     / ___/ / _ \/ _ \/ _ \/ // / _/_ </ // / // / // /
    /_/  /_/ .__/_.__/\___/\_, / /____/\___/\___/\___/ 
          /_/             /___/                        
"@ -ForegroundColor Green
    Write-Host "Vault-Tec Terminal System" -ForegroundColor Green
    Write-Host ""

    Write-Host "Loading Terminal..." -ForegroundColor Green

    # One-time CIM fetch
    $os   = Get-CimInstance Win32_OperatingSystem
    $cpu  = Get-CimInstance Win32_Processor
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $cs   = Get-CimInstance Win32_ComputerSystem

    # Uptime
    $upt = (Get-Date) - $os.LastBootUpTime
    Write-Host ("Uptime   : {0:dd}d {0:hh}h {0:mm}m" -f $upt) -ForegroundColor Green

    # Memory (no Get-Counter)
    $memFree  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $memTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $memUsed  = $memTotal - $memFree
    Write-Host ("Memory   : {0:N2} GB used / {1:N2} GB free / {2:N2} GB total" -f $memUsed,$memFree,$memTotal) -ForegroundColor Green

    # Disk C:
    $free  = [math]::Round($disk.FreeSpace / 1GB, 2)
    $total = [math]::Round($disk.Size / 1GB, 2)
    $used  = $total - $free
    Write-Host ("Disk C:  : {0:N2} GB used / {1:N2} GB free / {2:N2} GB total" -f $used,$free,$total) -ForegroundColor Green

    # CPU load & cores
    $cpuLoad  = ($cpu | Measure-Object -Property LoadPercentage -Average).Average
    $cpuCores = ($cpu | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
    Write-Host ("CPU      : {0:N1}%% used across {1} cores" -f $cpuLoad,$cpuCores) -ForegroundColor Green

    # Network addresses
    $adapters = Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp,Manual |
                Where-Object { $_.IPAddress -ne "127.0.0.1" }
    foreach ($a in $adapters) {
        Write-Host ("Net      : {0} {1}" -f $a.InterfaceAlias,$a.IPAddress) -ForegroundColor Green
    }

    # Hostname
    Write-Host ("Hostname : $env:COMPUTERNAME") -ForegroundColor Green
}

# Auto-run MOTD at shell startup
Show-MOTD
'@

# set $PROFILE
Set-Content -Path $PROFILE -Value $motd -Force -Encoding UTF8

Write-Host " Fallout MOTD installed into $PROFILE (UTF-8 enforced)" -ForegroundColor Green
