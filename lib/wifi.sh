#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

wifi_show_menu() {
    local selected=$1
    local items=("Enable Network" "Disable Network" "Show Network Info" "Back to Main Menu")
    
    clear
    echo "╔════════════════════════════════════╗"
    echo "║       NETWORK MANAGEMENT           ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
    for i in "${!items[@]}"; do
        if [ $i -eq $selected ]; then
            echo "  ▶ ${items[$i]}"
        else
            echo "    ${items[$i]}"
        fi
    done
    
    echo ""
    echo "════════════════════════════════════"
    echo "Use ↑/↓ arrows, Enter to select"
}

wifi_menu() {
    local selected=0
    local num_items=4
    
    while true; do
        wifi_show_menu $selected
        
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
                0) network_on ;;
                1) network_off ;;
                2) network_info ;;
                3) return 0 ;;
            esac
        fi
    done
}

network_on() {
    clear
    echo "========================================"
    echo "         ENABLE NETWORK"
    echo "========================================"
    echo ""
    
    if ! check_command_exists "nmcli"; then
        display_error "nmcli not found"
        display_info "Install with: sudo apt install network-manager"
        echo ""
        pause_screen
        return 1
    fi
    
    display_info "Current network interfaces:"
    echo ""
    nmcli device status
    echo ""
    
    read -p "Enter interface name (e.g., ens33, eth0): " interface
    
    if is_empty "$interface"; then
        display_error "No interface specified"
        echo ""
        pause_screen
        return 1
    fi
    
    echo ""
    display_info "Enabling $interface..."
    
    nmcli device connect "$interface" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        sleep 2
        display_success "Network enabled on $interface"
        
        echo ""
        display_info "Connection details:"
        echo ""
        nmcli device show "$interface" 2>/dev/null | grep "IP4.ADDRESS" | head -1
        
        log_message "INFO" "Network enabled on $interface"
    else
        display_error "Failed to enable $interface"
        display_info "Check if interface name is correct"
        log_message "ERROR" "Failed to enable $interface"
    fi
    
    echo ""
    pause_screen
}

network_off() {
    clear
    echo "========================================"
    echo "        DISABLE NETWORK"
    echo "========================================"
    echo ""
    
    if ! check_command_exists "nmcli"; then
        display_error "nmcli not found"
        display_info "Install with: sudo apt install network-manager"
        echo ""
        pause_screen
        return 1
    fi
    
    display_info "Current network interfaces:"
    echo ""
    nmcli device status
    echo ""
    
    read -p "Enter interface name (e.g., ens33, eth0): " interface
    
    if is_empty "$interface"; then
        display_error "No interface specified"
        echo ""
        pause_screen
        return 1
    fi
    
    echo ""
    display_warning "This will disconnect $interface"
    read -p "Continue? (y/n): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo ""
        display_info "Disabling $interface..."
        
        nmcli device disconnect "$interface" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            display_success "Network disabled on $interface"
            log_message "INFO" "Network disabled on $interface"
        else
            display_error "Failed to disable $interface"
            display_info "Check if interface is connected"
            log_message "ERROR" "Failed to disable $interface"
        fi
    else
        display_info "Cancelled"
    fi
    
    echo ""
    pause_screen
}

network_info() {
    clear
    echo "========================================"
    echo "       NETWORK INFORMATION"
    echo "========================================"
    echo ""
    
    if ! check_command_exists "nmcli"; then
        display_error "nmcli not found"
        echo ""
        pause_screen
        return 1
    fi
    
    display_info "Network Interfaces and Status:"
    echo ""
    nmcli device status
    
    echo ""
    echo "========================================"
    
    if check_command_exists "ip"; then
        echo ""
        display_info "IP Addresses:"
        echo ""
        ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print "  " $2 " on " $NF}'
        
        echo ""
        echo "========================================"
        echo ""
        
        display_info "Default Gateway:"
        echo ""
        gateway=$(ip route | grep default | awk '{print $3}')
        if [ -n "$gateway" ]; then
            echo "  $gateway"
        else
            echo "  No gateway configured"
        fi
    fi
    
    echo ""
    echo "========================================"
    echo ""
    
    display_info "Active Connections:"
    echo ""
    nmcli connection show --active 2>/dev/null
    
    echo ""
    pause_screen
}
