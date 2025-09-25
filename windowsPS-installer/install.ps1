# Fallout MOTD content
$motd = @'
Write-Host @"
       ___  _      __               ____ ___  ___  ___ 
      / _ \(_)__  / /  ___  __ __  |_  // _ \/ _ \/ _ \
     / ___/ / _ \/ _ \/ _ \/ // / _/_ </ // / // / // /
    /_/  /_/ .__/_.__/\___/\_, / /____/\___/\___/\___/ 
          /_/             /___/                        
"@ -ForegroundColor Green
Write-Host ("Vault-Tec Terminal System") -ForegroundColor Green 
Write-Host ""

# Example stats
$boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$uptime = (Get-Date) - $boot
Write-Host ("Uptime   : {0:dd}d {0:hh}h {0:mm}m" -f $uptime) -ForegroundColor Green

$memFree = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue/1024
Write-Host ("Memory   : {0:N2} GB free" -f $memFree) -ForegroundColor Green

$drive = Get-PSDrive -Name C
$free  = [math]::Round($drive.Free/1GB,2)
$total = [math]::Round($drive.Used/1GB + $free,2)
$used  = $total - $free
Write-Host ("Disk C:  : {0:N2} GB used / {1:N2} GB free / {2:N2} GB total" -f $used,$free,$total) -ForegroundColor Green

$cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$cpuCores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
Write-Host ("CPU      : {0:N1}%% used across {1} cores" -f $cpuLoad,$cpuCores) -ForegroundColor Green

$adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.*" -and $_.IPAddress -ne "127.0.0.1" }
foreach ($a in $adapters) {
    Write-Host ("Net      : {0} {1}" -f $a.InterfaceAlias, $a.IPAddress) -ForegroundColor Green
}

$net = Get-Counter '\Network Interface(*)\Bytes Total/sec'
$rxTx = [math]::Round(($net.CounterSamples.CookedValue | Measure-Object -Sum).Sum /1KB,2)
Write-Host ("Traffic  : {0} KB/sec" -f $rxTx) -ForegroundColor Green

Write-Host ("Hostname : $env:COMPUTERNAME") -ForegroundColor Green
'@

Set-Content -Path $PROFILE -Value $motd -Force -Encoding UTF8
Write-Host " Fallout MOTD installed into $PROFILE (UTF-8 enforced)" -ForegroundColor Green
