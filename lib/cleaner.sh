#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

cleaner_menu() {
    while true; do
        display_header "🧹 System Cleaner"
        echo "  1. Analyze System"
        echo "  2. Clean System"
        echo "  0. Back to main menu"
        echo ""
        echo "════════════════════════════════════"
        
        read -p "Enter your choice [0-2]: " choice
        
        case $choice in
            1) analyze_system ;;
            2) clean_system ;;
            0) return ;;
            *)
                display_error "Invalid choice"
                pause_screen
                ;;
        esac
    done
}

analyze_system() {
    clear
    echo "========================================"
    echo "      ANALYZING SYSTEM"
    echo "========================================"
    echo ""
    
    display_info "Scanning directories..."
    echo ""
    
    # Temp files
    if [ -d /tmp ]; then
        temp_size=$(du -sh /tmp 2>/dev/null | awk '{print $1}')
        echo "  Temp files:      $temp_size"
    fi
    
    # APT cache
    if [ -d /var/cache/apt ]; then
        apt_size=$(du -sh /var/cache/apt 2>/dev/null | awk '{print $1}')
        echo "  APT cache:       $apt_size"
    fi
    
    # Thumbnails
    if [ -d "$HOME/.cache/thumbnails" ]; then
        thumb_size=$(du -sh "$HOME/.cache/thumbnails" 2>/dev/null | awk '{print $1}')
        echo "  Thumbnails:      $thumb_size"
    fi
    
    # Trash
    if [ -d "$HOME/.local/share/Trash" ]; then
        trash_size=$(du -sh "$HOME/.local/share/Trash" 2>/dev/null | awk '{print $1}')
        echo "  Trash:           $trash_size"
    fi
    
    echo ""
    display_success "Analysis complete"
    log_message "INFO" "System analysis completed"
    
    echo ""
    pause_screen
}

clean_system() {
    clear
    echo "========================================"
    echo "      CLEAN SYSTEM"
    echo "========================================"
    echo ""
    
    read -p "Clean temporary files? (y/n): " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        display_info "Cancelled"
        echo ""
        pause_screen
        return
    fi
    
    echo ""
    display_info "Cleaning system..."
    echo ""
    
    # Clean thumbnails
    if [ -d "$HOME/.cache/thumbnails" ]; then
        rm -rf "$HOME/.cache/thumbnails/"*
        echo "✓ Thumbnails cleaned"
    fi
    
    # Clean trash
    if [ -d "$HOME/.local/share/Trash/files" ]; then
        rm -rf "$HOME/.local/share/Trash/files/"*
        echo "✓ Trash emptied"
    fi
    
    # Clean user temp
    rm -rf /tmp/tmp.* 2>/dev/null
    echo "✓ Temp files cleaned"
    
    echo ""
    display_success "System cleaned"
    log_message "INFO" "System cleaned successfully"
    
    echo ""
    pause_screen
}
