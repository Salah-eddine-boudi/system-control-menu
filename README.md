# 🖥️ System Control Menu

Interactive terminal-based menu to control Ubuntu system functions.



**JUNIA-ISEN - Linux Scripting Course Project**  
**February 2026**

---

## 👥 Team Members

| Name |
|------|
| **Salah Eddine Boudi** |
| **Mahmoud Ali El Sayed** |
| **Hekla Scheving** |

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

---

## 🛠️ Requirements

### System
- **OS:** Ubuntu 20.04 or later
- **Shell:** Bash 4.0+

### Dependencies
- `nmcli` - Network Manager
- `bluetoothctl` - Bluetooth control
- `pactl` - PulseAudio control
- `top`, `free`, `df` - System monitoring
- `wget` - Network speed test

---

## 📁 Project Structure
```
system-control-menu/
├── main.sh                 # Main entry point
├── lib/                    # Library modules
│   ├── ui.sh              # User interface
│   ├── utils.sh           # Utility functions
│   ├── wifi.sh            # WiFi management
│   ├── bluetooth.sh       # Bluetooth control
│   ├── audio.sh           # Audio control
│   ├── system.sh          # System info & power
│   ├── scheduler.sh       # Task scheduling
│   ├── network.sh         # Network tools
│   └── cleaner.sh         # System cleaner
├── logs/                   # Application logs
├── data/                   # Persistent data
└── README.md              # Documentation
```

---

## 🎓 Academic Context

- **Institution:** JUNIA-ISEN
- **Course:** Linux Scripting
- **Level:** Master 1 (M1)
- **Year:** 2025-2026

---

## 📸 Screenshots

### Main Menu
```
╔════════════════════════════════════╗
║   SYSTEM CONTROL MENU v1.0.0       ║
╚════════════════════════════════════╝

  ▶ 📡 WiFi Management
    🔵 Bluetooth Control
    🔊 Audio Control
    💻 System Information
    📊 System Monitor
    ⏰ Task Scheduler
    🌐 Network Tools
    🧹 System Cleaner
    ⚡ Power Management
    🚪 Exit
```

---

## 📄 License

Educational Project - JUNIA-ISEN  
Not for commercial use.

---

## 📧 Contact

**GitHub:** [@Salah-eddine-boudi](https://github.com/Salah-eddine-boudi)  
**Repository:** [system-control-menu](https://github.com/Salah-eddine-boudi/system-control-menu)

---

⭐ **If you found this project useful, please give it a star!**

📚 **Academic Project** | 🎓 **JUNIA-ISEN M1** | 💻 **Linux Scripting 2026**
