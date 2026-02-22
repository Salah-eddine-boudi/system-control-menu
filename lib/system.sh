#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

system_menu() {
    while true; do
        display_header "💻 System Information"
        echo "  1. CPU Usage"
        echo "  2. Memory Usage"
        echo "  3. Disk Usage"
        echo "  4. Network Info"
        echo "  0. Back to main menu"
        echo ""
        echo "════════════════════════════════════"
        
        read -p "Enter your choice [0-4]: " choice
        
        case $choice in
            1) system_cpu_usage ;;
            2) system_memory_usage ;;
            3) system_disk_usage ;;
            4) system_network_info ;;
            0) return ;;
            *)
                display_error "Invalid choice"
                pause_screen
                ;;
        esac
    done
}

power_menu() {
    while true; do
        display_header "⚡ Power Management"
        echo "  1. Shutdown"
        echo "  2. Reboot"
        echo "  3. Suspend"
        echo "  0. Back to main menu"
        echo ""
        echo "════════════════════════════════════"
        
        read -p "Enter your choice [0-3]: " choice
        
        case $choice in
            1) power_shutdown ;;
            2) power_reboot ;;
            3) power_suspend ;;
            0) return ;;
            *)
                display_error "Invalid choice"
                pause_screen
                ;;
        esac
    done
}

system_cpu_usage() {
    clear
    echo "╔════════════════════════════════════╗"
    echo "║       CPU USAGE INFORMATION        ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
    if check_command_exists "top"; then
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
        
        echo "┌────────────────────────────────────┐"
        echo "│ Overall CPU Usage                  │"
        echo "├────────────────────────────────────┤"
        printf "│ %-35s│\n" " Usage: ${cpu_usage}%"
        echo "└────────────────────────────────────┘"
        echo ""
        
        cpu_cores=$(nproc)
        echo "┌────────────────────────────────────┐"
        echo "│ CPU Information                    │"
        echo "├────────────────────────────────────┤"
        printf "│ %-35s│\n" " CPU Cores: $cpu_cores"
        
        if [ -f /proc/cpuinfo ]; then
            cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')
            printf "│ %-35s│\n" " Model: ${cpu_model:0:30}..."
        fi
        echo "└────────────────────────────────────┘"
        echo ""
        
        echo "┌────────────────────────────────────────────────────────────────────┐"
        echo "│ TOP 5 CPU-CONSUMING PROCESSES                                      │"
        echo "├─────┬──────────────────────────────────────────┬──────────┬────────┤"
        echo "│ PID │ COMMAND                                  │ CPU%     │ MEM%   │"
        echo "├─────┼──────────────────────────────────────────┼──────────┼────────┤"
        
        ps aux --sort=-%cpu | awk 'NR>1 && NR<=6 {printf "│ %-4s│ %-41s│ %-9s│ %-7s│\n", $2, substr($11,1,41), $3"%", $4"%"}'
        
        echo "└─────┴──────────────────────────────────────────┴──────────┴────────┘"
    else
        display_error "top command not found"
    fi
    
    echo ""
    pause_screen
}

system_memory_usage() {
    clear
    echo "╔════════════════════════════════════╗"
    echo "║      MEMORY USAGE INFORMATION      ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
    if check_command_exists "free"; then
        total=$(free -h | awk 'NR==2{print $2}')
        used=$(free -h | awk 'NR==2{print $3}')
        free_mem=$(free -h | awk 'NR==2{print $4}')
        available=$(free -h | awk 'NR==2{print $7}')
        
        total_mb=$(free -m | awk 'NR==2{print $2}')
        used_mb=$(free -m | awk 'NR==2{print $3}')
        percentage=$((used_mb * 100 / total_mb))
        
        echo "┌────────────────────────────────────┐"
        echo "│ RAM Usage                          │"
        echo "├────────────────────────────────────┤"
        printf "│ %-35s│\n" " Total:     $total"
        printf "│ %-35s│\n" " Used:      $used ($percentage%)"
        printf "│ %-35s│\n" " Free:      $free_mem"
        printf "│ %-35s│\n" " Available: $available"
        echo "└────────────────────────────────────┘"
        echo ""
        
        bar_length=30
        filled=$((percentage * bar_length / 100))
        empty=$((bar_length - filled))
        
        echo "Memory Usage Bar:"
        printf "["
        for ((i=0; i<filled; i++)); do printf "="; done
        for ((i=0; i<empty; i++)); do printf " "; done
        printf "] %d%%\n" $percentage
        echo ""
        
        swap_total=$(free -h | awk 'NR==3{print $2}')
        swap_used=$(free -h | awk 'NR==3{print $3}')
        
        if [ "$swap_total" != "0B" ]; then
            echo "┌────────────────────────────────────┐"
            echo "│ SWAP Usage                         │"
            echo "├────────────────────────────────────┤"
            printf "│ %-35s│\n" " Total: $swap_total"
            printf "│ %-35s│\n" " Used:  $swap_used"
            echo "└────────────────────────────────────┘"
            echo ""
        fi
        
        echo "┌────────────────────────────────────────────────────────────────────┐"
        echo "│ TOP 5 MEMORY-CONSUMING PROCESSES                                   │"
        echo "├─────┬──────────────────────────────────────────┬──────────┬────────┤"
        echo "│ PID │ COMMAND                                  │ MEM%     │ RSS    │"
        echo "├─────┼──────────────────────────────────────────┼──────────┼────────┤"
        
        ps aux --sort=-%mem | awk 'NR>1 && NR<=6 {printf "│ %-4s│ %-41s│ %-9s│ %-7s│\n", $2, substr($11,1,41), $4"%", $6}'
        
        echo "└─────┴──────────────────────────────────────────┴──────────┴────────┘"
    else
        display_error "free command not found"
    fi
    
    echo ""
    pause_screen
}

system_disk_usage() {
    clear
    echo "╔════════════════════════════════════╗"
    echo "║       DISK USAGE INFORMATION       ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
    if check_command_exists "df"; then
        echo "┌────────────────────────────────────────────────────────────────────────────┐"
        echo "│ MOUNTED FILESYSTEMS                                                        │"
        echo "├─────────────────────┬──────────┬──────────┬──────────┬────────┬───────────┤"
        echo "│ Filesystem          │ Size     │ Used     │ Avail    │ Use%   │ Mounted   │"
        echo "├─────────────────────┼──────────┼──────────┼──────────┼────────┼───────────┤"
        
        df -h | grep -vE "tmpfs|loop|udev" | awk 'NR>1 {
            printf "│ %-20s│ %-9s│ %-9s│ %-9s│ %-7s│ %-10s│\n", 
            substr($1,1,20), $2, $3, $4, $5, substr($6,1,10)
        }'
        
        echo "└─────────────────────┴──────────┴──────────┴──────────┴────────┴───────────┘"
        echo ""
        
        echo "Disk Usage Summary:"
        total_size=$(df -h --total 2>/dev/null | grep total | awk '{print $2}')
        total_used=$(df -h --total 2>/dev/null | grep total | awk '{print $3}')
        total_avail=$(df -h --total 2>/dev/null | grep total | awk '{print $4}')
        total_percent=$(df -h --total 2>/dev/null | grep total | awk '{print $5}')
        
        if [ -n "$total_size" ]; then
            echo "  Total Size:      $total_size"
            echo "  Total Used:      $total_used"
            echo "  Total Available: $total_avail"
            echo "  Usage:           $total_percent"
            echo ""
            
            percent_num=$(echo $total_percent | sed 's/%//')
            bar_length=30
            filled=$((percent_num * bar_length / 100))
            empty=$((bar_length - filled))
            
            printf "Disk Usage Bar: ["
            for ((i=0; i<filled; i++)); do printf "="; done
            for ((i=0; i<empty; i++)); do printf " "; done
            printf "] %s\n" "$total_percent"
        fi
        
    else
        display_error "df command not found"
    fi
    
    echo ""
    pause_screen
}

system_network_info() {
    clear
    echo "╔════════════════════════════════════╗"
    echo "║     NETWORK INFORMATION            ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    
    if check_command_exists "ip"; then
        echo "┌────────────────────────────────────────────────────────────────┐"
        echo "│ NETWORK INTERFACES                                             │"
        echo "├───────────────┬────────────────────────────────────────────────┤"
        echo "│ Interface     │ IP Address / Status                            │"
        echo "├───────────────┼────────────────────────────────────────────────┤"
        
        ip -brief addr show | grep -v "lo" | while read iface status addr rest; do
            printf "│ %-14s│ %-47s│\n" "$iface" "$addr ($status)"
        done
        
        echo "└───────────────┴────────────────────────────────────────────────┘"
        echo ""
        
        if check_command_exists "nmcli"; then
            active_conn=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null)
            
            if [ -n "$active_conn" ]; then
                echo "┌────────────────────────────────────┐"
                echo "│ Active Connections                 │"
                echo "├────────────────────────────────────┤"
                
                echo "$active_conn" | while IFS=: read name type; do
                    printf "│ %-35s│\n" " $name ($type)"
                done
                
                echo "└────────────────────────────────────┘"
                echo ""
            fi
        fi
        
        default_route=$(ip route | grep default | awk '{print $3}')
        if [ -n "$default_route" ]; then
            echo "Gateway: $default_route"
        fi
        
        if check_command_exists "hostname"; then
            hostname=$(hostname)
            echo "Hostname: $hostname"
        fi
        
    elif check_command_exists "ifconfig"; then
        ifconfig | grep -v "lo" | grep "inet " | awk '{print "  " $2}'
    else
        display_error "Neither ip nor ifconfig found"
    fi
    
    echo ""
    pause_screen
}

power_shutdown() {
    echo ""
    display_warning "SHUTDOWN SYSTEM"
    echo ""
    read -p "Are you sure you want to shutdown? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        display_info "Shutting down in 10 seconds... Press Ctrl+C to cancel"
        log_message "WARNING" "System shutdown initiated"
        sleep 10
        
        if check_command_exists "systemctl"; then
            systemctl poweroff
        elif check_command_exists "shutdown"; then
            shutdown -h now
        else
            display_error "Neither systemctl nor shutdown found"
        fi
    else
        display_info "Shutdown cancelled"
    fi
    
    echo ""
    pause_screen
}

power_reboot() {
    echo ""
    display_warning "REBOOT SYSTEM"
    echo ""
    read -p "Are you sure you want to reboot? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        display_info "Rebooting in 10 seconds... Press Ctrl+C to cancel"
        log_message "WARNING" "System reboot initiated"
        sleep 10
        
        if check_command_exists "systemctl"; then
            systemctl reboot
        elif check_command_exists "shutdown"; then
            shutdown -r now
        else
            display_error "Neither systemctl nor shutdown found"
        fi
    else
        display_info "Reboot cancelled"
    fi
    
    echo ""
    pause_screen
}

power_suspend() {
    echo ""
    display_info "SUSPEND SYSTEM"
    echo ""
    read -p "Are you sure you want to suspend? (y/n): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        display_info "Suspending system..."
        log_message "INFO" "System suspend initiated"
        
        if check_command_exists "systemctl"; then
            systemctl suspend
        else
            display_error "systemctl command not found"
        fi
    else
        display_info "Suspend cancelled"
    fi
    
    echo ""
    pause_screen
}

system_monitor_dashboard() {
    clear
    
    if ! check_command_exists "top" || ! check_command_exists "free"; then
        display_error "Required commands not found (top, free)"
        pause_screen
        return 1
    fi
    
    echo "Starting System Monitor Dashboard..."
    echo "Press Ctrl+C to exit"
    sleep 4
    
    while true; do
        clear
        
       
        echo "+========================================+"
        echo "|     SYSTEM MONITOR DASHBOARD           |"
        echo "+========================================+"
        echo ""
        
     
        current_time=$(date "+%Y-%m-%d %H:%M:%S")
        printf "  Time: %-30s\n" "$current_time"
        echo ""
        
        
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        cpu_int=${cpu_usage%.*}
        
    
        cpu_bar=$((cpu_int * 40 / 100))
        
        echo "+----------------------------------------+"
        echo "| CPU Usage                              |"
        echo "+----------------------------------------+"
        printf "| Usage: %-32s|\n" "${cpu_usage}%"
        printf "| "
        for ((i=0; i<cpu_bar; i++)); do printf "="; done
        for ((i=cpu_bar; i<40; i++)); do printf " "; done
        printf "|\n"
        echo "+----------------------------------------+"
        echo ""
        
        # RAM Usage
        mem_total=$(free -m | awk 'NR==2{print $2}')
        mem_used=$(free -m | awk 'NR==2{print $3}')
        mem_percent=$((mem_used * 100 / mem_total))
        
        mem_total_gb=$(free -h | grep Mem | awk '{print $2}')
        mem_used_gb=$(free -h | grep Mem | awk '{print $3}')
        
    
        mem_bar=$((mem_percent * 40 / 100))
        
        echo "+----------------------------------------+"
        echo "| Memory Usage                           |"
        echo "+----------------------------------------+"
        printf "| Used: %-33s|\n" "$mem_used_gb / $mem_total_gb"
        printf "| Percentage: %-28s|\n" "$mem_percent%"
        printf "| "
        for ((i=0; i<mem_bar; i++)); do printf "="; done
        for ((i=mem_bar; i<40; i++)); do printf " "; done
        printf "|\n"
        echo "+----------------------------------------+"
        echo ""
        
        # Disk Usage
        disk_info=$(df -h / | tail -1)
        disk_used=$(echo $disk_info | awk '{print $3}')
        disk_total=$(echo $disk_info | awk '{print $2}')
        disk_percent=$(echo $disk_info | awk '{print $5}' | sed 's/%//')
      
        disk_bar=$((disk_percent * 40 / 100))
        
        echo "+----------------------------------------+"
        echo "| Disk Usage (/)                         |"
        echo "+----------------------------------------+"
        printf "| Used: %-33s|\n" "$disk_used / $disk_total"
        printf "| Percentage: %-28s|\n" "$disk_percent%"
        printf "| "
        for ((i=0; i<disk_bar; i++)); do printf "="; done
        for ((i=disk_bar; i<40; i++)); do printf " "; done
        printf "|\n"
        echo "+----------------------------------------+"
        echo ""
        
    
        echo "+----------------------------------------+"
        echo "| System Information                     |"
        echo "+----------------------------------------+"
        
  
        uptime_info=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
        printf "| Uptime: %-31s|\n" "$uptime_info"
        
  
        load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ ]*//')
        printf "| Load:   %-31s|\n" "$load_avg"
        
      
        hostname=$(hostname)
        printf "| Host:   %-31s|\n" "$hostname"
        
        echo "+----------------------------------------+"
        echo ""
        
   
        echo "+----------------------------------------+"
        echo "| Top CPU Process                        |"
        echo "+----------------------------------------+"
        top_proc_name=$(ps aux --sort=-%cpu | awk 'NR==2 {print substr($11,1,25)}')
        top_proc_cpu=$(ps aux --sort=-%cpu | awk 'NR==2 {printf "%.1f%%", $3}')
        printf "| Process: %-30s|\n" "$top_proc_name"
        printf "| CPU:     %-30s|\n" "$top_proc_cpu"
        echo "+----------------------------------------+"
        echo ""
        
        
        echo "Refreshing in 3 seconds... (Ctrl+C to exit)"
        
        sleep 12
    done
}
