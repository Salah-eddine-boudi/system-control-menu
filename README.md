# 🖥️ System Control Menu

Interactive terminal-based menu to control Ubuntu system functions.

![Menu Screenshot](https://via.placeholder.com/600x400?text=System+Control+Menu)

**JUNIA-ISEN - Linux Scripting Course Project**  
**February 2026**

---

## 👥 Team Members

**JUNIA-ISEN M1 - Linux Scripting Course (2025-2026)**

- 👨‍💻 **Salah Eddine Boudi**
- 👨‍💻 **Mahmoud Ali El Sayed**
- 👨‍💻 **Hekla Scheving**

---

## ✨ Features

### Network & Connectivity
- 📡 **WiFi Management** - Enable/disable network interfaces
- 🌐 **Network Tools** - Speed test, ping, connection diagnostics
- 🔵 **Bluetooth Control** - Bluetooth device management

### System Monitoring
- 💻 **System Information** - CPU, Memory, Disk, Network stats
- 📊 **System Monitor** - Real-time dashboard with auto-refresh
- 🧹 **System Cleaner** - Clean temporary files and cache

### Automation & Power
- ⏰ **Task Scheduler** - Schedule shutdowns and reminders
- ⚡ **Power Management** - Shutdown, reboot, suspend

### Media
- 🔊 **Audio Control** - Volume control and audio settings

---

## 🚀 Installation
```bash
# Clone the repository
git clone https://github.com/Salah-eddine-boudi/system-control-menu.git

# Navigate to project directory
cd system-control-menu

# Make main script executable
chmod +x main.sh
```

---

## 📖 Usage

### Start the menu
```bash
./main.sh
```

### Navigation
- Use **↑/↓ arrow keys** to navigate
- Press **Enter** to select
- Use **number keys** in sub-menus

### Example: Network Speed Test
```bash
./main.sh → Network Tools → Test Internet Speed
Select file size: 100 MB
✅ Download Speed: 1234 KB/s (9 Mbps)
```

---

## 🛠️ Requirements

### System
- **OS:** Ubuntu 20.04 or later (tested on 24.04)
- **Shell:** Bash 4.0+

### Dependencies
- `nmcli` - Network Manager (pre-installed on Ubuntu)
- `bluetoothctl` - Bluetooth control
- `pactl` - PulseAudio control
- `top`, `free`, `df` - System monitoring (standard utilities)
- `wget` - For network speed test

### Install missing dependencies (if needed)
```bash
sudo apt update
sudo apt install network-manager pulseaudio-utils wget
```

---

## 📁 Project Structure
```
system-control-menu/
├── main.sh                 # Main entry point with navigation
├── lib/                    # Library modules
│   ├── ui.sh              # User interface functions
│   ├── utils.sh           # Utility functions and logging
│   ├── wifi.sh            # WiFi/Network management
│   ├── bluetooth.sh       # Bluetooth control
│   ├── audio.sh           # Audio control
│   ├── system.sh          # System info, monitoring & power
│   ├── scheduler.sh       # Task scheduling
│   ├── network.sh         # Network tools (speed test, ping)
│   └── cleaner.sh         # System cleaning utilities
├── logs/                   # Application logs
│   └── system-menu.log
├── data/                   # Persistent data
│   ├── scheduled_tasks.txt
│   └── reminders.txt
└── README.md              # This file
```

---
## 🧪 Testing

### Manual Testing
```bash
# Test all features
./main.sh

## 📄 License

Educational Project - JUNIA-ISEN  
Not for commercial use.

---


# 🙏 Acknowledgments

- JUNIA-ISEN Faculty - Linux Scripting Course
- Course materials and documentation
- Team collaboration and peer learning
- Open source community

---

## 📧 Contact

**Team Lead:** Salah Eddine Boudi  
**GitHub:** [@Salah-eddine-boudi](https://github.com/Salah-eddine-boudi)  
**Institution:** JUNIA-ISEN  
**Project Repository:** [system-control-menu](https://github.com/Salah-eddine-boudi/system-control-menu)

---



📚 **Academic Project** | 🎓 **JUNIA-ISEN M1** | 💻 **Linux Scripting 2026**

