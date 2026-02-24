#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

THEME_FILE="$SCRIPT_DIR/data/current_theme.txt"

get_current_theme() {
    if [ -f "$THEME_FILE" ]; then
        cat "$THEME_FILE"
    else
        echo "Default (Blue)"
    fi
}

save_theme() {
    local theme_name="$1"
    mkdir -p "$SCRIPT_DIR/data"
    echo "$theme_name" > "$THEME_FILE"
}

show_theme_menu() {
    local selected=$1
    local current_theme=$(get_current_theme)
    
    clear
    echo "╔════════════════════════════════════╗"
    echo "║      THEME CUSTOMIZATION           ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    echo "Current Theme: $current_theme"
    echo ""
    
    local items=(
        "Default Theme (Blue)"
        "Dark Theme (Black/White)"
        "Matrix Theme (Green)"
        "Purple Theme"
        "Ocean Theme (Cyan)"
        "View Current Theme"
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

apply_theme() {
    local theme_id=$1
    local theme_name=""
    
    clear
    display_header "Apply Theme"
    
    echo ""
    
    case $theme_id in
        1)
            theme_name="Default (Blue)"
            display_info "Applying Default Theme (Blue)..."
            echo ""
            echo "Colors: Blue headers, standard text"
            ;;
        2)
            theme_name="Dark (Black/White)"
            display_info "Applying Dark Theme..."
            echo ""
            echo "Colors: Black background, white text"
            ;;
        3)
            theme_name="Matrix (Green)"
            display_info "Applying Matrix Theme (Green)..."
            echo ""
            echo "Colors: Green matrix-style"
            ;;
        4)
            theme_name="Purple"
            display_info "Applying Purple Theme..."
            echo ""
            echo "Colors: Purple accents"
            ;;
        5)
            theme_name="Ocean (Cyan)"
            display_info "Applying Ocean Theme..."
            echo ""
            echo "Colors: Cyan/blue ocean colors"
            ;;
    esac
    
    save_theme "$theme_name"
    
    echo ""
    display_success "Theme saved: $theme_name"
    echo ""
    display_info "Theme saved to: data/current_theme.txt"
    display_warning "Note: Full color support requires terminal configuration"
    
    log_message "INFO" "Theme changed to: $theme_name"
    
    echo ""
    pause_screen
}

view_current_theme() {
    clear
    display_header "Current Theme Information"
    
    echo ""
    
    local current_theme=$(get_current_theme)
    
    echo "Active Theme: $current_theme"
    echo ""
    echo "Theme file location:"
    echo "  $THEME_FILE"
    echo ""
    
    if [ -f "$THEME_FILE" ]; then
        echo "Theme file contents:"
        cat "$THEME_FILE"
    else
        echo "No theme file found (using default)"
    fi
    
    echo ""
    echo "════════════════════════════════════"
    echo ""
    
    pause_screen
}

theme_menu() {
    local selected=0
    local num_items=7
    
    while true; do
        show_theme_menu "$selected"
        
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
                0) apply_theme 1 ;;
                1) apply_theme 2 ;;
                2) apply_theme 3 ;;
                3) apply_theme 4 ;;
                4) apply_theme 5 ;;
                5) view_current_theme ;;
                6) return 0 ;;
            esac
        fi
    done
}
