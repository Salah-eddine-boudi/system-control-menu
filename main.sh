#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/wifi.sh"
source "$SCRIPT_DIR/lib/bluetooth.sh"
source "$SCRIPT_DIR/lib/audio.sh"
source "$SCRIPT_DIR/lib/system.sh"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/scheduler.sh"
source "$SCRIPT_DIR/lib/network.sh"
source "$SCRIPT_DIR/lib/cleaner.sh"
source "$SCRIPT_DIR/lib/password.sh"
source "$SCRIPT_DIR/lib/theme.sh"

readonly VERSION="1.0.0"
readonly LOG_FILE="$SCRIPT_DIR/logs/system-menu.log"

mkdir -p "$SCRIPT_DIR/logs"

show_menu() {
    local selected=$1
    
   local items=("WiFi Management" "Bluetooth Control" "Audio Control" 
             "System Information" "System Monitor" "Task Scheduler" 
             "Network Tools" "System Cleaner" "Power Management" 
             "Password Generator" "Theme Customization" "Exit")

local icons=("📡" "🔵" "🔊" "💻" "📊" "⏰" "🌐" "🧹" "⚡" "🔐" "🎨" "🚪")
    
    clear
    
    echo "╔════════════════════════════════════╗"
    echo "║   SYSTEM CONTROL MENU v$VERSION    ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
    for i in "${!items[@]}"; do
        if [ $i -eq $selected ]; then
            echo "  ▶ ${icons[$i]} ${items[$i]}"
        else
            echo "    ${icons[$i]} ${items[$i]}"
        fi
    done
    
    echo ""
    echo "════════════════════════════════════"
    echo "Use ↑/↓ arrows to navigate, Enter to select"
}

main() {
    log_message "INFO" "System Control Menu started"
    
    if [ ! -f /etc/os-release ]; then
        echo "Warning: This script is designed for Linux systems"
    fi
    
    local selected=0
    local num_items=12
    
    while true; do
        show_menu $selected
        
        read -rsn1 key
        
        if [ "$key" = $'\x1b' ]; then
            read -rsn2 key
            
            case "$key" in
                '[A')
                    selected=$((selected - 1))
                    if [ $selected -lt 0 ]; then
                        selected=$((num_items - 1))
                    fi
                    ;;
                '[B')
                    selected=$((selected + 1))
                    if [ $selected -ge $num_items ]; then
                        selected=0
                    fi
                    ;;
            esac
        elif [ "$key" = "" ]; then
            case $selected in
    0) wifi_menu ;;
    1) bluetooth_menu ;;
    2) audio_menu ;;
    3) system_menu ;;
    4) system_monitor_dashboard ;;
    5) scheduler_menu ;;
    6) network_menu ;;
    7) cleaner_menu ;;
    8) power_menu ;;
    9) password_menu ;;
    10) theme_menu ;;
    11)
        clear
        echo "Thank you for using System Control Menu!"
        log_message "INFO" "System Control Menu exited normally"
        exit 0
        ;;
esac
        fi
    done
}

main "$@"
