#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

PASS_FILE="$SCRIPT_DIR/data/passwords.txt"
LAST_PASSWORD=""

gen_password() {
    local length="$1"
    local include_numbers="$2"
    local include_symbols="$3"
    
    local password=""
    local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    if [ "$include_numbers" = "yes" ]; then
        chars="${chars}0123456789"
    fi
    
    if [ "$include_symbols" = "yes" ]; then
        chars="${chars}!@#\$%^&*"
    fi
    
    local chars_length=${#chars}
    
    for ((i=0; i<length; i++)); do
        local random_index=$((RANDOM % chars_length))
        password="${password}${chars:$random_index:1}"
    done
    
    echo "$password"
}

save_password() {
    local label="$1"
    local username="$2"
    local password="$3"
    
    mkdir -p "$SCRIPT_DIR/data"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "$timestamp | $label | $username | $password" >> "$PASS_FILE"
    
    chmod 600 "$PASS_FILE"
}

view_passwords() {
    clear
    display_header "Saved Passwords"
    
    if [ ! -f "$PASS_FILE" ]; then
        display_info "No passwords saved yet"
        echo ""
        echo "Passwords will be saved here when you create your first one."
        echo ""
        pause_screen
        return 0
    fi
    
    echo ""
    echo "Saved Passwords:"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    if [ -s "$PASS_FILE" ]; then
        cat "$PASS_FILE"
    else
        echo "  (no passwords saved)"
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    pause_screen
}

delete_all_passwords() {
    clear
    display_header "Delete All Passwords"
    
    if [ ! -f "$PASS_FILE" ]; then
        display_info "No passwords to delete"
        echo ""
        pause_screen
        return 0
    fi
    
    echo ""
    display_warning "This will delete ALL saved passwords"
    echo ""
    
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        rm -f "$PASS_FILE"
        display_success "All passwords deleted"
        log_message "INFO" "Password file deleted"
    else
        display_info "Cancelled"
    fi
    
    echo ""
    pause_screen
}

show_password_menu() {
    local selected=$1
    
    clear
    echo "╔════════════════════════════════════╗"
    echo "║      PASSWORD GENERATOR            ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
    if [ -n "$LAST_PASSWORD" ]; then
        echo "Last generated: $LAST_PASSWORD"
    else
        echo "Last generated: (none)"
    fi
    
    echo ""
    
    local items=(
        "Generate Password"
        "Save Last Password"
        "View Saved Passwords"
        "Delete All Passwords"
        "Back to Main Menu"
    )
    
    for i in "${!items[@]}"; do
        if [ "$i" -eq "$selected" ]; then
            echo "  ▶ ${items[$i]}"
        else
            echo "    ${items[$i]}"
        fi
    done
    
    echo ""
    echo "════════════════════════════════════"
    echo "Use ↑/↓ arrows, Enter to select"
}

password_generate_flow() {
    clear
    display_header "Generate Password"
    
    local length inc_num inc_sym
    
    echo ""
    read -p "Password length (8-32): " length
    
    if ! [[ "$length" =~ ^[0-9]+$ ]]; then
        display_error "Length must be a number"
        echo ""
        pause_screen
        return 0
    fi
    
    if [ "$length" -lt 8 ] || [ "$length" -gt 32 ]; then
        display_error "Length must be between 8 and 32"
        echo ""
        pause_screen
        return 0
    fi
    
    echo ""
    read -p "Include numbers? (y/n): " inc_num
    read -p "Include symbols? (y/n): " inc_sym
    
    if [ "$inc_num" = "y" ] || [ "$inc_num" = "Y" ]; then
        inc_num="yes"
    else
        inc_num="no"
    fi
    
    if [ "$inc_sym" = "y" ] || [ "$inc_sym" = "Y" ]; then
        inc_sym="yes"
    else
        inc_sym="no"
    fi
    
    echo ""
    display_info "Generating password..."
    
    LAST_PASSWORD=$(gen_password "$length" "$inc_num" "$inc_sym")
    
    echo ""
    display_success "Password generated"
    echo ""
    echo "Your password:"
    echo "════════════════════════════════════"
    echo "$LAST_PASSWORD"
    echo "════════════════════════════════════"
    
    log_message "INFO" "Password generated (length: $length)"
    
    echo ""
    pause_screen
}

password_save_flow() {
    clear
    display_header "Save Password"
    
    if [ -z "$LAST_PASSWORD" ]; then
        display_error "No password generated yet"
        echo ""
        display_info "Generate a password first"
        echo ""
        pause_screen
        return 0
    fi
    
    local label username
    
    echo ""
    echo "Password to save: $LAST_PASSWORD"
    echo ""
    
    read -p "Label (e.g., Gmail, GitHub, Netflix): " label
    
    if [ -z "$label" ]; then
        display_error "Label cannot be empty"
        echo ""
        pause_screen
        return 0
    fi
    
    read -p "Username/Email: " username
    
    if [ -z "$username" ]; then
        display_error "Username cannot be empty"
        echo ""
        pause_screen
        return 0
    fi
    
    echo ""
    save_password "$label" "$username" "$LAST_PASSWORD"
    
    display_success "Password saved"
    log_message "INFO" "Password saved for $label"
    
    echo ""
    pause_screen
}

password_menu() {
    local selected=0
    local num_items=5
    
    while true; do
        show_password_menu "$selected"
        
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
                0) password_generate_flow ;;
                1) password_save_flow ;;
                2) view_passwords ;;
                3) delete_all_passwords ;;
                4) return 0 ;;
            esac
        fi
    done
}
