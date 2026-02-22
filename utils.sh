#!/bin/bash

log_message() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    touch "$LOG_FILE" 2>/dev/null
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

check_command_exists() {
    local cmd="$1"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
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

is_root() {
    [ "$EUID" -eq 0 ]
}
