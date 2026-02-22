#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

show_network_menu() {
    local selected=$1
    local items=("Test Internet Speed" "Ping Test" "Show IP Address" "Test Connection" "Back to Main Menu")
    
    clear
    echo "╔════════════════════════════════════╗"
    echo "║        NETWORK TOOLS               ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
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

network_menu() {
    local selected=0
    local num_items=5
    
    while true; do
        show_network_menu $selected
        
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
            case $selected in
                0) speed_test ;;
                1) ping_test ;;
                2) show_ip ;;
                3) test_connection ;;
                4) return 0 ;;
            esac
        fi
    done
}

speed_test() {
    clear
    echo "========================================"
    echo "      NETWORK SPEED TEST"
    echo "========================================"
    echo ""
    
    # Check Internet connection first
    display_info "Checking Internet connection..."
    
    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        echo ""
        display_error "No Internet connection detected!"
        echo ""
        echo "Please check:"
        echo "  ✗ WiFi is disabled"
        echo "  ✗ Network cable unplugged"
        echo "  ✗ Router is offline"
        echo ""
        log_message "ERROR" "Speed test failed: No Internet connection"
        pause_screen
        return 1
    fi
    
    display_success "Connection detected"
    echo ""
    
    # File size selection menu
    show_size_menu
}

show_size_menu() {
    local selected=0
    local num_items=3
    
    while true; do
        clear
        echo "========================================"
        echo "   SELECT TEST FILE SIZE"
        echo "========================================"
        echo ""
        
        local items=("50 MB  (Recommended)" "100 MB (More accurate)" "200 MB (Very accurate)")
        
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
            case $selected in
                0)
                    run_speed_test "http://speedtest.ftp.otenet.gr/files/test50Mb.db" "50"
                    return
                    ;;
                1)
                    run_speed_test "http://speedtest.ftp.otenet.gr/files/test100Mb.db" "100"
                    return
                    ;;
                2)
                    run_speed_test "http://ipv4.download.thinkbroadband.com/200MB.zip" "200"
                    return
                    ;;
            esac
        fi
    done
}

run_speed_test() {
    local test_url=$1
    local size_mb=$2
    
    # Setup cleanup trap (automatic cleanup on exit/interrupt)
    trap 'cleanup_speedtest' EXIT INT TERM
    
    clear
    echo "========================================"
    echo "      DOWNLOADING TEST FILE"
    echo "========================================"
    echo ""
    
    display_info "File size: ${size_mb}MB"
    display_info "Starting download..."
    echo ""
    
    start=$(date +%s)
    
    wget --progress=bar:force -O /tmp/speedtest.tmp "$test_url" 2>&1 | \
    grep --line-buffered "%" | \
    while IFS= read -r line; do
        echo -ne "\r$line"
    done
    
    end=$(date +%s)
    duration=$((end - start))
    
    echo ""
    echo ""
    
    if [ -f /tmp/speedtest.tmp ]; then
        file_size=$(stat -c%s /tmp/speedtest.tmp)
        
        echo "========== RESULTS =========="
        echo ""
        
        if [ $duration -gt 0 ]; then
            speed_kbs=$((file_size / duration / 1024))
            speed_mbps=$((speed_kbs * 8 / 1024))
            avg_speed=$((size_mb / duration))
            
            printf "  Download Speed:  %d KB/s\n" "$speed_kbs"
            printf "  Speed (Mbps):    %d Mbps\n" "$speed_mbps"
            printf "  Average:         %d MB/s\n" "$avg_speed"
            printf "  File Size:       %d MB\n" "$size_mb"
            printf "  Duration:        %d seconds\n" "$duration"
            echo ""
            
            if [ $speed_mbps -gt 50 ]; then
                display_success "Excellent! (Fiber/High-speed)"
            elif [ $speed_mbps -gt 20 ]; then
                display_success "Very good (Good broadband)"
            elif [ $speed_mbps -gt 10 ]; then
                display_info "Good (Standard broadband)"
            elif [ $speed_mbps -gt 5 ]; then
                display_warning "Average (Basic broadband)"
            else
                display_warning "Slow (Consider upgrade)"
            fi
            
            log_message "INFO" "Speed test (${size_mb}MB): $speed_kbs KB/s"
        else
            display_success "Download extremely fast!"
        fi
        
        echo ""
        echo "============================="
    else
        display_error "Download failed or interrupted"
        log_message "ERROR" "Speed test failed"
    fi
    
    echo ""
    pause_screen
}

# Cleanup function (called automatically)
cleanup_speedtest() {
    if [ -f /tmp/speedtest.tmp ]; then
        rm -f /tmp/speedtest.tmp
    fi
    trap - EXIT INT TERM
}

ping_test() {
    clear
    echo "========================================"
    echo "          PING TEST"
    echo "========================================"
    echo ""
    
    read -p "Enter host to ping (default: google.com): " host
    
    if [ -z "$host" ]; then
        host="google.com"
    fi
    
    echo ""
    display_info "Pinging $host (5 packets)..."
    echo ""
    
    ping -c 5 "$host"
    
    if [ $? -eq 0 ]; then
        echo ""
        display_success "Host is reachable"
        log_message "INFO" "Ping test to $host: Success"
    else
        echo ""
        display_error "Host unreachable"
        log_message "ERROR" "Ping test to $host: Failed"
    fi
    
    echo ""
    pause_screen
}

show_ip() {
    clear
    echo "========================================"
    echo "        IP ADDRESS INFO"
    echo "========================================"
    echo ""
    
    display_info "Local IP Address:"
    echo ""
    
    local_ips=$(ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print "  " $2}')
    
    if [ -n "$local_ips" ]; then
        echo "$local_ips"
    else
        echo "  No local IP found"
    fi
    
    echo ""
    display_info "Public IP Address:"
    echo ""
    
    public_ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
    
    if [ -n "$public_ip" ]; then
        echo "  $public_ip"
        log_message "INFO" "Public IP: $public_ip"
    else
        display_error "Could not fetch public IP"
        echo "  (Check Internet connection)"
    fi
    
    echo ""
    pause_screen
}

test_connection() {
    clear
    echo "========================================"
    echo "      CONNECTION TEST"
    echo "========================================"
    echo ""
    
    display_info "Testing connection..."
    echo ""
    
    local google_ok=0
    local dns_ok=0
    local gateway_ok=0
    
    # Test Google
    echo -n "Google.com:    "
    if ping -c 1 -W 3 google.com >/dev/null 2>&1; then
        echo "✓ OK"
        google_ok=1
    else
        echo "✗ Failed"
    fi
    
    # Test DNS
    echo -n "DNS (8.8.8.8): "
    if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
        echo "✓ OK"
        dns_ok=1
    else
        echo "✗ Failed"
    fi
    
    # Test Gateway
    gateway=$(ip route | grep default | awk '{print $3}')
    if [ -n "$gateway" ]; then
        echo -n "Gateway:       "
        if ping -c 1 -W 3 "$gateway" >/dev/null 2>&1; then
            echo "✓ OK ($gateway)"
            gateway_ok=1
        else
            echo "✗ Failed ($gateway)"
        fi
    else
        echo "Gateway:       ✗ Not found"
    fi
    
    echo ""
    
    # Summary
    if [ $google_ok -eq 1 ]; then
        display_success "Internet connection is working"
        log_message "INFO" "Connection test: All OK"
    elif [ $dns_ok -eq 1 ]; then
        display_warning "Internet reachable but DNS issues"
        log_message "WARNING" "Connection test: DNS issues"
    elif [ $gateway_ok -eq 1 ]; then
        display_warning "Gateway OK but no Internet"
        log_message "WARNING" "Connection test: No Internet"
    else
        display_error "No network connection"
        log_message "ERROR" "Connection test: No connection"
    fi
    
    echo ""
    pause_screen
}

