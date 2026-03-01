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

### Security & Customization
- 🔐 **Password Generator** - Generate and save secure passwords
- 🎨 **Theme Customization** - Choose from 5 different themes

### File Management
- 🔍 **File Finder** - Search files by name, extension, or size _(COMING SOON)_

---

## 🆕 Latest Updates

### Version 1.0.0 (February 2026)

**New Modules Added:**

#### 🔐 Password Generator
- Generate secure random passwords (8-32 characters)
- Include numbers and symbols options
- Save passwords with labels and usernames
- View all saved passwords
- Delete all passwords option

#### 🎨 Theme Customization
- 5 theme options available
- Save theme preference
- View current active theme
- Themes: Default (Blue), Dark, Matrix (Green), Purple, Ocean (Cyan)

#### 🔍 File Finder _(In Development)_
- Search files by name
- Search by file extension
- Search by file size
- Find recent files (last 7 days)
- Open found files with default application

**Currently: 12 modules functional, 1 in development**

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
- `find` - File search utility
- `xdg-open` - Default file opener

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
│   ├── cleaner.sh         # System cleaner
│   ├── password.sh        # Password generator
│   ├── theme.sh           # Theme customization
│   └── finder.sh          # File finder (in development)
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
    🔐 Password Generator
    🎨 Theme Customization
    🔍 File Finder
    🚪 Exit

════════════════════════════════════
Use ↑/↓ arrows to navigate, Enter to select
```

### Password Generator
```
╔════════════════════════════════════╗
║      PASSWORD GENERATOR            ║
╚════════════════════════════════════╝

Last generated: (none)

  ▶ Generate Password
    Save Last Password
    View Saved Passwords
    Delete All Passwords
    Back to Main Menu
```

### Theme Customization
```
╔════════════════════════════════════╗
║      THEME CUSTOMIZATION           ║
╚════════════════════════════════════╝

Current Theme: Matrix (Green)

  ▶ Default Theme (Blue)
    Dark Theme (White)
    Matrix Theme (Green)
    Purple Theme
    Ocean Theme (Cyan)
    Preview Theme Colors
    Back to Main Menu
```

### File Finder _(Coming Soon)_
```
╔════════════════════════════════════╗
║         FILE FINDER                ║
╚════════════════════════════════════╝

  ▶ Search by Name
    Search by Extension
    Search by Size
    Find Recent Files
    Back to Main Menu
```

---

## 🗓️ Roadmap

### ✅ Completed
- WiFi Management
- Bluetooth Control
- Audio Control
- System Information
- System Monitor
- Task Scheduler
- Network Tools
- System Cleaner
- Power Management
- Password Generator
- Theme Customization
- File Finder

### 🚧 In Progress


### 📋 Planned
- Backup Manager
- Process Manager

---

## 📄 License

Educational Project - JUNIA-ISEN  


---
## 👨‍🏫 Course Instructor

**Pierre CAPIOD**  
*Linux Scripting - JUNIA-ISEN M1 (2025-2026)*  
📧 pierre.capiod@junia.com


---
## 📧 Contact

**GitHub:** [@Salah-eddine-boudi](https://github.com/Salah-eddine-boudi)  
**Repository:** [system-control-menu](https://github.com/Salah-eddine-boudi/system-control-menu)


---



📚 **Academic Project** | 🎓 **JUNIA-ISEN M1** | 💻 **Linux Scripting 2026**s
