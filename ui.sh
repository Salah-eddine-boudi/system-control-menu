#!/bin/bash

readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

display_header() {
    local title="$1"
    clear
    echo "╔════════════════════════════════════╗"
    printf "║      %-30s║\n" "$title"
    echo "╚════════════════════════════════════╝"
    echo ""
}

pause_screen() {
    echo ""
    read -p "Press Enter to continue..." dummy
}

display_success() {
    echo -e "${COLOR_GREEN}✅ SUCCESS: $1${COLOR_RESET}"
}

display_error() {
    echo -e "${COLOR_RED}❌ ERROR: $1${COLOR_RESET}"
}

display_warning() {
    echo -e "${COLOR_YELLOW}⚠️  WARNING: $1${COLOR_RESET}"
}

display_info() {
    echo -e "${COLOR_BLUE}ℹ️  INFO: $1${COLOR_RESET}"
}

