#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

finder_show_menu() {
    local selected=$1
    
    clear
    echo "╔════════════════════════════════════╗"
    echo "║         FILE FINDER                ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
    local items=(
        "Search by Name"
        "Search by Extension"
        "Search by Size"
        "Find Recent Files"
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

search_by_name() {
    clear
    display_header "Search by Name"
    
    echo ""
    read -p "Enter file name to search: " query
    
    if [ -z "$query" ]; then
        display_error "Search query cannot be empty"
        echo ""
        pause_screen
        return 0
    fi
    
    clear
    display_header "Search Results"
    
    echo ""
    display_info "Searching for: $query"
    echo ""
    echo "Please wait..."
    echo ""
    
    local results=()
    while IFS= read -r -d '' file; do
        results+=("$file")
    done < <(find "$HOME" -type f -iname "*$query*" 2>/dev/null -print0)
    
    clear
    display_header "Search Results"
    
    echo ""
    
    if [ "${#results[@]}" -eq 0 ]; then
        display_warning "No files found matching: $query"
    else
        display_success "Found ${#results[@]} file(s)"
        echo ""
        echo "Results:"
        echo "────────────────────────────────────"
        
        local count=0
        for file in "${results[@]}"; do
            count=$((count + 1))
            echo "$count. $file"
            
            if [ "$count" -ge 20 ]; then
                echo ""
                display_info "Showing first 20 results (total: ${#results[@]})"
                break
            fi
        done
        
        echo "────────────────────────────────────"
    fi
    
    log_message "INFO" "File search by name: $query (${#results[@]} results)"
    
    echo ""
    pause_screen
}

search_by_extension() {
    clear
    display_header "Search by Extension"
    
    echo ""
    echo "Common extensions: txt, pdf, jpg, png, mp3, mp4, zip"
    echo ""
    read -p "Enter file extension (without dot): " ext
    
    if [ -z "$ext" ]; then
        display_error "Extension cannot be empty"
        echo ""
        pause_screen
        return 0
    fi
    
    clear
    display_header "Search Results"
    
    echo ""
    display_info "Searching for *.$ext files..."
    echo ""
    echo "Please wait..."
    echo ""
    
    local results=()
    while IFS= read -r -d '' file; do
        results+=("$file")
    done < <(find "$HOME" -type f -iname "*.$ext" 2>/dev/null -print0)
    
    clear
    display_header "Search Results"
    
    echo ""
    
    if [ "${#results[@]}" -eq 0 ]; then
        display_warning "No .$ext files found"
    else
        display_success "Found ${#results[@]} .$ext file(s)"
        echo ""
        echo "Results:"
        echo "────────────────────────────────────"
        
        local count=0
        for file in "${results[@]}"; do
            count=$((count + 1))
            echo "$count. $file"
            
            if [ "$count" -ge 20 ]; then
                echo ""
                display_info "Showing first 20 results (total: ${#results[@]})"
                break
            fi
        done
        
        echo "────────────────────────────────────"
    fi
    
    log_message "INFO" "File search by extension: .$ext (${#results[@]} results)"
    
    echo ""
    pause_screen
}

search_by_size() {
    clear
    display_header "Search by Size"
    
    echo ""
    echo "Size options:"
    echo "  1. Small files (< 1MB)"
    echo "  2. Medium files (1MB - 10MB)"
    echo "  3. Large files (> 10MB)"
    echo ""
    read -p "Choose option [1-3]: " size_opt
    
    local size_param=""
    local size_desc=""
    
    case $size_opt in
        1)
            size_param="-size -1M"
            size_desc="< 1MB"
            ;;
        2)
            size_param="-size +1M -size -10M"
            size_desc="1MB - 10MB"
            ;;
        3)
            size_param="-size +10M"
            size_desc="> 10MB"
            ;;
        *)
            display_error "Invalid option"
            echo ""
            pause_screen
            return 0
            ;;
    esac
    
    clear
    display_header "Search Results"
    
    echo ""
    display_info "Searching for files $size_desc..."
    echo ""
    echo "Please wait..."
    echo ""
    
    local results=()
    while IFS= read -r -d '' file; do
        results+=("$file")
    done < <(find "$HOME" -type f $size_param 2>/dev/null -print0)
    
    clear
    display_header "Search Results"
    
    echo ""
    
    if [ "${#results[@]}" -eq 0 ]; then
        display_warning "No files found with size $size_desc"
    else
        display_success "Found ${#results[@]} file(s) with size $size_desc"
        echo ""
        echo "Results:"
        echo "────────────────────────────────────"
        
        local count=0
        for file in "${results[@]}"; do
            count=$((count + 1))
            local filesize=$(du -h "$file" 2>/dev/null | cut -f1)
            echo "$count. [$filesize] $file"
            
            if [ "$count" -ge 20 ]; then
                echo ""
                display_info "Showing first 20 results (total: ${#results[@]})"
                break
            fi
        done
        
        echo "────────────────────────────────────"
    fi
    
    log_message "INFO" "File search by size: $size_desc (${#results[@]} results)"
    
    echo ""
    pause_screen
}

find_recent_files() {
    clear
    display_header "Find Recent Files"
    
    echo ""
    display_info "Searching for files modified in last 7 days..."
    echo ""
    echo "Please wait..."
    echo ""
    
    local results=()
    while IFS= read -r -d '' file; do
        results+=("$file")
    done < <(find "$HOME" -type f -mtime -7 2>/dev/null -print0)
    
    clear
    display_header "Search Results"
    
    echo ""
    
    if [ "${#results[@]}" -eq 0 ]; then
        display_warning "No recently modified files found"
    else
        display_success "Found ${#results[@]} file(s) modified in last 7 days"
        echo ""
        echo "Results:"
        echo "────────────────────────────────────"
        
        local count=0
        for file in "${results[@]}"; do
            count=$((count + 1))
            local modtime=$(stat -c '%y' "$file" 2>/dev/null | cut -d'.' -f1)
            echo "$count. [$modtime] $file"
            
            if [ "$count" -ge 20 ]; then
                echo ""
                display_info "Showing first 20 results (total: ${#results[@]})"
                break
            fi
        done
        
        echo "────────────────────────────────────"
    fi
    
    log_message "INFO" "Recent files search (${#results[@]} results)"
    
    echo ""
    pause_screen
}

finder_menu() {
    local selected=0
    local num_items=5
    
    while true; do
        finder_show_menu "$selected"
        
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
                0) search_by_name ;;
                1) search_by_extension ;;
                2) search_by_size ;;
                3) find_recent_files ;;
                4) return 0 ;;
            esac
        fi
    done
}
