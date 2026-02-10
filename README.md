# System Control

Interactive terminal menu to control Ubuntu system functions.

## Team Members
- **Salah Eddine Boudi** - Team Lead + Core Infrastructure
- **Person 2** - Network & Connectivity Specialist  
- **Person 3** - System & Audio Specialist

## Features
- WiFi Management
- Bluetooth Control
- Audio Control
- System Information
- Power Management

## Installation
```bash
git clone https://github.com/VOTRE_USERNAME/system-control-menu.git
cd system-control-menu
chmod +x main.sh
```

## Usage
```bash
./main.sh
```

## Requirements
- Ubuntu 20.04 or later
- nmcli (Network Manager)
- bluetoothctl
- pactl (PulseAudio)

## Project Structure
```
├── main.sh              # Main entry point
├── lib/                 # Library modules
│   ├── ui.sh           # User interface
│   ├── wifi.sh         # WiFi management
│   ├── bluetooth.sh    # Bluetooth control
│   ├── audio.sh        # Audio control
│   ├── system.sh       # System info & power
│   └── utils.sh        # Utility functions
├── config/              # Configuration files
├── logs/                # Log files
└── tests/               # Test scripts
```

## Development

Project for JUNIA - Linux Scripting Course
Date: February 2026
