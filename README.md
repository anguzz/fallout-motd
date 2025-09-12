# fallout-motd


A Fallout-themed Message of the Day for **Debian 12 / Proxmox VE 8.x** hosts.  

This project reimagines the classic [FalconStats](https://github.com/Heholord/FalconStats) concept with a **Pip-Boy aesthetic** bright green CRT ASCII art, Vault-Tec branding, and modular system stats.


### Overview
- Fallout / Pip-Boy style ASCII headers  
- Modular stat scripts (`uptime`, `memory`, `vms`, `storage`, etc.)  
- Built for modern **Debian 12 + Proxmox VE 8.x**  
- Easy install via `update-motd.d` symlinks  
- Configurable via `config.json` (enable/disable modules)  
- GitHub-ready with MIT license, changelog, and screenshots  

### Setup

- Github setup

```bash
apt install -y git
git clone https://github.com/anguzz/fallout-motd.git
cd fallout-motd
./install.sh 
```
 
 - tarball setup
 
 ```bash
curl -L https://github.com/anguzz/fallout-motd/archive/refs/heads/main.tar.gz -o fallout-motd.tar.gz
tar -xzf fallout-motd.tar.gz
mv fallout-motd-main fallout-motd
cd fallout-motd
./install.sh install
```

## Project structure
```
fallout-motd/
├── main.sh             # main entry script (runs all modules)
├── config.json              # toggle stats/modules
├── scripts/                # scripts
│   ├── uptime.sh
│   ├── memory.sh
│   ├── vms.sh
│   ├── storage.sh
│   └── quorum.sh
├── install.sh               # initial setup symlinks in /etc/update-motd
├── examples/                
├── README.md
├── LICENSE (MIT)
└── CHANGELOG.md
```

##  Planned Modules 
- **cpu.sh** → CPU usage 
- **network.sh** → Interfaces, IPs, and traffic stats  
- **zpool.sh** → ZFS pool health and capacity  
- **docker.sh** → Running Docker containers and statuses  
- **services.sh** → Systemd service health checks  
- **ssl.sh** → SSL/TLS certificate expiry info  
- **apc.sh** → APC UPS battery/line status  
- **custom.sh** → Example user-defined module 