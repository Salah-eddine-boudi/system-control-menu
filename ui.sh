#!/bin/bash

display_header() {
    local title="$1"
    clear
    echo "╔════════════════════════════════════╗"
    echo "║  $title"
    echo "╚════════════════════════════════════╝"
    echo ""
}

pause_screen() {
    echo ""
    read -p "Press Enter to continue..." 
}

display_success() {
    echo "✅ $1"
}

display_error() {
    echo "❌ ERROR: $1"
}

display_warning() {
    echo "⚠️  WARNING: $1"
}

display_info() {
    echo "ℹ️  $1"
}
