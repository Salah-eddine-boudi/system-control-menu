#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

bt_cmd() {
    timeout 2s bluetoothctl "$@" 2>&1
}

bt_has_controller() {
    local out
    out="$(bt_cmd show)"
    
    if [ -z "$out" ]; then
        echo "NO_OUTPUT"
        return 1
    fi
    
    echo "$out" | grep -qi "No default controller available"
    if [ $? -eq 0 ]; then
        echo "NO_CONTROLLER"
        return 1
    fi
    
    echo "OK"
    return 0
}

bt_power_state() {
    local out
    out="$(bt_cmd show)"
    
    echo "$out" | grep -qi "Powered: yes"
    if [ $? -eq 0 ]; then
        echo "ON"
    else
        echo "OFF"
    fi
}

show_bt_status_screen() {
    clear
    display_header "Bluetooth Status"
    
    local ctrl
    ctrl="$(bt_has_controller)"
    
    echo "Service Status: $(systemctl is-active bluetooth 2>/dev/null)"
    echo ""
    
    if [ "$ctrl" = "OK" ]; then
        display_success "Controller Available"
        echo "Power State: $(bt_power_state)"
        echo ""
        echo "Controller Details:"
        bt_cmd show | sed 's/^/  /'
    elif [ "$ctrl" = "NO_CONTROLLER" ]; then
        display_error "Controller Not Available"
        echo ""
        display_warning "VirtualBox/VMware does not expose Bluetooth hardware"
        display_info "You need a USB Bluetooth adapter with passthrough"
    else
        display_warning "bluetoothctl produced no output"
        echo ""
        display_info "Try: sudo systemctl restart bluetooth"
    fi
    
    echo ""
    pause_screen
}

restart_bt_service() {
    clear
    display_header "Restart Bluetooth Service"
    
    display_info "Restarting bluetooth.service..."
    echo ""
    
    if sudo systemctl restart bluetooth 2>/dev/null; then
        display_success "Bluetooth service restarted"
    else
        display_error "Failed to restart bluetooth service"
        display_info "You may need sudo privileges"
    fi
    
    echo ""
    pause_screen
}

scan_devices() {
    clear
    display_header "Scan Bluetooth Devices"
    
    local ctrl
    ctrl="$(bt_has_controller)"
    
    if [ "$ctrl" != "OK" ]; then
        display_error "Cannot scan: No Bluetooth controller"
        echo ""
        display_info "Reason: No Bluetooth hardware in VM"
        echo ""
        pause_screen
        return 0
    fi
    
    display_info "Powering on Bluetooth..."
    bt_cmd power on >/dev/null 2>&1 || true
    
    echo ""
    display_info "Scanning for 6 seconds..."
    bt_cmd scan on >/dev/null 2>&1
    sleep 6
    bt_cmd scan off >/dev/null 2>&1
    
    echo ""
    echo "Discovered Devices:"
    echo "-------------------"
    bt_cmd devices || echo "  No devices found"
    
    echo ""
    pause_screen
}

power_on_bt() {
    clear
    display_header "Power On Bluetooth"
    
    local ctrl
    ctrl="$(bt_has_controller)"
    
    if [ "$ctrl" != "OK" ]; then
        display_error "No Bluetooth controller available"
        echo ""
        pause_screen
        return 1
    fi
    
    display_info "Powering on Bluetooth..."
    
    if bt_cmd power on >/dev/null 2>&1; then
        display_success "Bluetooth powered on"
        log_message "INFO" "Bluetooth powered on"
    else
        display_error "Failed to power on Bluetooth"
        log_message "ERROR" "Failed to power on Bluetooth"
    fi
    
    echo ""
    pause_screen
}

power_off_bt() {
    clear
    display_header "Power Off Bluetooth"
    
    local ctrl
    ctrl="$(bt_has_controller)"
    
    if [ "$ctrl" != "OK" ]; then
        display_error "No Bluetooth controller available"
        echo ""
        pause_screen
        return 1
    fi
    
    display_info "Powering off Bluetooth..."
    
    if bt_cmd power off >/dev/null 2>&1; then
        display_success "Bluetooth powered off"
        log_message "INFO" "Bluetooth powered off"
    else
        display_error "Failed to power off Bluetooth"
        log_message "ERROR" "Failed to power off Bluetooth"
    fi
    
    echo ""
    pause_screen
}

show_bt_menu() {
    local selected=$1
    
    clear
    echo "╔════════════════════════════════════╗"
    echo "║       BLUETOOTH CONTROL            ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
    local svc
    svc="$(systemctl is-active bluetooth 2>/dev/null)"
    echo "Service: $svc"
    
    local ctrl
    ctrl="$(bt_has_controller)"
    
    if [ "$ctrl" = "OK" ]; then
        echo "Controller: Available | Power: $(bt_power_state)"
    elif [ "$ctrl" = "NO_CONTROLLER" ]; then
        echo "Controller: Not available (VM limitation)"
    else
        echo "Controller: No response"
    fi
    
    echo ""
    
    local items=(
        "Power On"
        "Power Off"
        "Scan for Devices"
        "Show Status"
        "Restart Service"
        "Back to Main Menu"
    )
    
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

bluetooth_menu() {
    local selected=0
    local num_items=6
    
    while true; do
        show_bt_menu "$selected"
        
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
            case "$selected" in
                0) power_on_bt ;;
                1) power_off_bt ;;
                2) scan_devices ;;
                3) show_bt_status_screen ;;
                4) restart_bt_service ;;
                5) return 0 ;;
            esac
        fi
    done
}
