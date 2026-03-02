#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

bt_cmd() {
    timeout 3s bluetoothctl "$@" 2>&1
}

bt_has_controller() {
    local out
    out="$(bt_cmd list)"
    if [ -z "$out" ] || ! echo "$out" | grep -qi "Controller"; then
        echo "NO_CONTROLLER"
        return 1
    fi
    echo "OK"
    return 0
}

display_bt_solutions() {
    display_error "Aucun contrôleur Bluetooth détecté"
    echo "--------------------------------------------------"
    echo "Solutions possibles :"
    echo " 1. Si vous êtes sur VM (VMware/VirtualBox) :"
    echo "    - Connectez une clé USB Bluetooth externe."
    echo "    - Allez dans le menu 'Périphériques amovibles'."
    echo "    - Sélectionnez votre clé et cliquez sur 'Connecter'."
    echo " 2. Si vous êtes sur PC physique :"
    echo "    - Vérifiez que le Bluetooth est activé dans le BIOS."
    echo "    - Lancez l'option 'Restart Service' du menu."
    echo "--------------------------------------------------"
}

bt_power_state() {
    local out
    out="$(bt_cmd show)"
    if echo "$out" | grep -qi "Powered: yes"; then
        echo "ON"
    else
        echo "OFF"
    fi
}

show_bt_status_screen() {
    clear
    display_header "Bluetooth Status"
    local ctrl_status="$(bt_has_controller)"
    echo "Service Status: $(systemctl is-active bluetooth 2>/dev/null)"
    echo ""
    if [ "$ctrl_status" = "OK" ]; then
        display_success "Contrôleur prêt"
        echo "Power State: $(bt_power_state)"
        echo ""
        bt_cmd show | sed 's/^/  /'
    else
        display_bt_solutions
    fi
    echo ""
    pause_screen
}

restart_bt_service() {
    clear
    display_header "Restart Bluetooth Service"
    display_info "Redémarrage du service..."
    if sudo systemctl restart bluetooth 2>/dev/null; then
        display_success "Service redémarré avec succès"
    else
        display_error "Erreur lors du redémarrage"
    fi
    pause_screen
}

scan_devices() {
    clear
    display_header "Scan Bluetooth Devices"
    if [ "$(bt_has_controller)" != "OK" ]; then
        display_bt_solutions
        pause_screen
        return 0
    fi
    display_info "Activation du Bluetooth..."
    bt_cmd power on >/dev/null 2>&1
    echo ""
    display_info "Recherche en cours (6s)..."
    bt_cmd scan on >/dev/null 2>&1 &
    local scan_pid=$!
    sleep 6
    kill $scan_pid 2>/dev/null
    bt_cmd scan off >/dev/null 2>&1
    echo ""
    echo "Appareils trouvés :"
    echo "-------------------"
    local devices=$(bt_cmd devices)
    if [ -n "$devices" ]; then
        echo "$devices"
    else
        echo "  Aucun appareil trouvé"
    fi
    echo ""
    pause_screen
}

power_on_bt() {
    clear
    display_header "Power On Bluetooth"
    if [ "$(bt_has_controller)" != "OK" ]; then
        display_bt_solutions
        pause_screen
        return 1
    fi
    if bt_cmd power on >/dev/null 2>&1; then
        display_success "Bluetooth activé"
    else
        display_error "Échec de l'activation"
    fi
    pause_screen
}

power_off_bt() {
    clear
    display_header "Power Off Bluetooth"
    if [ "$(bt_has_controller)" != "OK" ]; then
        display_bt_solutions
        pause_screen
        return 1
    fi
    if bt_cmd power off >/dev/null 2>&1; then
        display_success "Bluetooth désactivé"
    else
        display_error "Échec de la désactivation"
    fi
    pause_screen
}

show_bt_menu() {
    local selected=$1
    clear
    echo "╔════════════════════════════════════╗"
    echo "║        BLUETOOTH CONTROL           ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    local svc="$(systemctl is-active bluetooth 2>/dev/null)"
    local ctrl_status="$(bt_has_controller)"
    echo "Service: $svc"
    if [ "$ctrl_status" = "OK" ]; then
        echo "Controller: OK | Power: $(bt_power_state)"
    else
        echo "Controller: ABSENT (Vérifiez votre clé USB)"
    fi
    echo ""
    local items=("Power On" "Power Off" "Scan for Devices" "Show Status" "Restart Service" "Back to Main Menu")
    for i in "${!items[@]}"; do
        if [ $i -eq $selected ]; then
            echo "  ▶ ${items[$i]}"
        else
            echo "    ${items[$i]}"
        fi
    done
    echo ""
    echo "════════════════════════════════════"
    echo "Utilisez ↑/↓ et Entrée pour valider"
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
                '[A') ((selected--)); [ $selected -lt 0 ] && selected=$((num_items - 1)) ;;
                '[B') ((selected++)); [ $selected -ge $num_items ] && selected=0 ;;
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
