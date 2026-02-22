#!/bin/bash


get_bt_power() {
    bluetoothctl show | grep "Powered: yes" > /dev/null
    if [ $? -eq 0 ]; then echo "ON"; else echo "OFF"; fi
}

show_bt_menu() {
    local selected=$1
    local power=$(get_bt_power)
    
    # Icons change based on power status
    local power_icon="⚪"
    if [ "$power" == "ON" ]; then power_icon="🟢"; fi

    local items=("Power On" "Power Off" "Scan for Devices" "Back to Main Menu")
    
    clear
    echo "╔════════════════════════════════════╗"
    echo "║       BLUETOOTH CONTROLS           ║"
    echo "╚════════════════════════════════════╝"
    echo "   Power Status: $power_icon $power"
    echo ""

    for i in "${!items[@]}"; do
        if [ $i -eq $selected ]; then
            echo "  ▶ ${items[$i]}"
        else
            echo "    ${items[$i]}"
        fi
    done
}

# A simple scanner function
scan_devices() {
    clear
    echo "Scanning for 5 seconds..."
    # Run scan asynchronously for 5 seconds
    bluetoothctl scan on > /dev/null 2>&1 &
    local pid=$!
    sleep 5
    kill $pid 2>/dev/null
    
    echo "--- Found Devices ---"
    bluetoothctl devices
    echo ""
    echo "Press any key to return..."
    read -n 1
}

bluetooth_menu() {
    local selected=0
    local num_items=4

    while true; do
        show_bt_menu $selected
        
        read -rsn1 key
        if [ "$key" = $'\x1b' ]; then
            read -rsn2 key
            case "$key" in
                '[A') 
                    ((selected--))
                    if [ $selected -lt 0 ]; then selected=$((num_items - 1)); fi
                    ;;
                '[B') 
                    ((selected++))
                    if [ $selected -ge $num_items ]; then selected=0; fi
                    ;;
            esac
        elif [ "$key" = "" ]; then
            case $selected in
                0) bluetoothctl power on > /dev/null ;;
                1) bluetoothctl power off > /dev/null ;;
                2) scan_devices ;;
                3) return 0 ;;
            esac
        fi
    done
}
