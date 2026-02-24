#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

readonly LOG_FILE="$SCRIPT_DIR/logs/system-menu.log"
readonly ERROR_LOG="$SCRIPT_DIR/logs/errors.log"

mkdir -p "$SCRIPT_DIR/logs"
mkdir -p "$SCRIPT_DIR/data"

log_message() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    touch "$LOG_FILE" 2>/dev/null
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    if [ "$level" = "ERROR" ]; then
        echo "[$timestamp] [ERROR] $message" >> "$ERROR_LOG"
    fi
}

check_command_exists() {
    local cmd="$1"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

check_multiple_commands() {
    local missing=()
    
    for cmd in "$@"; do
        if ! check_command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing commands:"
        for cmd in "${missing[@]}"; do
            echo "  - $cmd"
        done
        return 1
    fi
    
    return 0
}

is_root() {
    [ "$EUID" -eq 0 ]
}

require_sudo() {
    if [ "$EUID" -ne 0 ]; then
        display_error "This operation requires sudo privileges"
        display_info "Please run with: sudo $0"
        return 1
    fi
    return 0
}

validate_yes_no() {
    local input="$1"
    
    case "$input" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        [Nn]|[Nn][Oo])
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

is_number() {
    local input="$1"
    
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

is_empty() {
    local input="$1"
    
    if [ -z "$input" ]; then
        return 0
    else
        return 1
    fi
}

check_file_exists() {
    local file="$1"
    
    if [ -f "$file" ]; then
        return 0
    else
        return 1
    fi
}

check_dir_exists() {
    local dir="$1"
    
    if [ -d "$dir" ]; then
        return 0
    else
        return 1
    fi
}

pause_screen() {
    echo ""
    read -p "Press Enter to continue..." dummy
}

confirm_action() {
    local prompt="$1"
    local response
    
    read -p "$prompt (y/n): " response
    
    if validate_yes_no "$response"; then
        return 0
    else
        return 1
    fi
}

get_timestamp() {
    date '+%Y-%m-%d_%H-%M-%S'
}

get_date() {
    date '+%Y-%m-%d'
}

cleanup_temp_files() {
    log_message "INFO" "Cleaning temporary files"
    
    rm -f "$SCRIPT_DIR"/*.tmp 2>/dev/null
    rm -f "$SCRIPT_DIR"/data/*.tmp 2>/dev/null
    
    find "$SCRIPT_DIR/logs" -type f -name "*.log" -mtime +7 -delete 2>/dev/null
    
    log_message "INFO" "Cleanup completed"
}
