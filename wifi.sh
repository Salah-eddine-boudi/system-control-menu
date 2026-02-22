#!/bin/bash

wifi_menu() {
    while true; do
        display_header "📡 WiFi Management"
        echo "  1. List available networks"
        echo "  2. Connect to network"
        echo "  3. Disconnect from current network"
        echo "  4. Show WiFi status"
        echo "  5. Enable WiFi"
        echo "  6. Disable WiFi"
        echo "  0. Back to main menu"
        echo ""
        echo "════════════════════════════════════"
        
        read -p "Enter your choice [0-6]: " choice
        
        case $choice in
            1) wifi_list_networks ;;
            2) wifi_connect_network ;;
            3) wifi_disconnect ;;
            4) wifi_show_status ;;
            5) wifi_enable ;;
            6) wifi_disable ;;
            0) return ;;
            *)
                display_error "Invalid choice"
                pause_screen
                ;;
        esac
    done
}

wifi_list_networks() {
    echo ""
    display_info "TODO: Person 2 will implement network listing"
    echo ""
    echo "Hint: Use 'nmcli device wifi list'"
    pause_screen
}

wifi_connect_network() {
    echo ""
    display_info "TODO: Person 2 will implement WiFi connection"
    echo ""
    echo "Hint: Use 'nmcli device wifi connect SSID password PASSWORD'"
    pause_screen
}

wifi_disconnect() {
    echo ""
    display_info "TODO: Person 2 will implement WiFi disconnection"
    echo ""
    echo "Hint: Use 'nmcli device disconnect wlan0'"
    pause_screen
}

wifi_show_status() {
    echo ""
    display_info "TODO: Person 2 will implement status display"
    echo ""
    echo "Hint: Use 'nmcli connection show --active'"
    pause_screen
}

wifi_enable() {
    echo ""
    display_info "TODO: Person 2 will implement WiFi enable"
    echo ""
    echo "Hint: Use 'nmcli radio wifi on'"
    pause_screen
}

wifi_disable() {
    echo ""
    display_info "TODO: Person 2 will implement WiFi disable"
    echo ""
    echo "Hint: Use 'nmcli radio wifi off'"
    pause_screen
}
