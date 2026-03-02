#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

TASKS_FILE="$SCRIPT_DIR/data/scheduled_tasks.txt"
REMINDERS_FILE="$SCRIPT_DIR/data/reminders.txt"

mkdir -p "$SCRIPT_DIR/data"

scheduler_menu() {
    while true; do
        display_header "⏰ Task Scheduler"
        echo "  1. View Scheduled Tasks"
        echo "  2. Schedule Shutdown"
        echo "  3. Set Reminder"
        echo "  4. Cancel Shutdown"
        echo "  5. View Reminders"
        echo "  6. Clear All Reminders"
        echo "  0. Back to main menu"
        echo ""
        echo "════════════════════════════════════"
        
        read -p "Enter your choice [0-6]: " choice
        
        case $choice in
            1) view_scheduled_tasks ;;
            2) schedule_shutdown ;;
            3) set_reminder ;;
            4) cancel_shutdown ;;
            5) view_reminders ;;
            6) clear_reminders ;;
            0) return ;;
            *)
                display_error "Invalid choice"
                pause_screen
                ;;
        esac
    done
}

schedule_shutdown() {
    clear
    display_header "SCHEDULE SHUTDOWN"
    
    echo "Choose shutdown time:"
    echo "  1. In 15 seconds (test)"
    echo "  2. In 6 minutes"
    echo "  3. In 15 minutes"
    echo "  4. Custom time (minutes)"
    echo "  0. Cancel"
    echo ""
    
    read -p "Enter choice: " choice
    
    use_seconds=0
    case $choice in
        1) seconds=15; use_seconds=1 ;;
        2) minutes=6 ;;
        3) minutes=15 ;;
        4) read -p "Enter minutes: " minutes ;;
        0) return ;;
        *) display_error "Invalid choice"; pause_screen; return 1 ;;
    esac
    
    if [ "$use_seconds" = "1" ]; then
        time_str="15 seconds"
        exec_cmd="sudo shutdown -h +0 'Shutdown in 15s' & sleep 15" 
    else
        time_str="$minutes minutes"
        exec_cmd="sudo shutdown -h +$minutes"
    fi

    read -p "Confirm shutdown in $time_str? (y/n): " confirm
    if [[ "$confirm" =~ ^[yY]$ ]]; then
        eval $exec_cmd
        display_success "Shutdown scheduled in $time_str"
    else
        display_info "Cancelled"
    fi
    pause_screen
}

cancel_shutdown() {
    clear
    display_header "CANCEL SHUTDOWN"
    sudo shutdown -c 2>/dev/null
    if [ $? -eq 0 ]; then
        display_success "L'arrêt du système a été annulé avec succès."
        log_message "INFO" "Shutdown cancelled"
    else
        display_error "Échec de l'annulation ou aucun arrêt programmé."
    fi
    pause_screen
}

set_reminder() {
    clear
    display_header "SET REMINDER"
    
    read -p "Enter reminder message: " message
    [ -z "$message" ] && { display_error "Empty message"; pause_screen; return 1; }
    
    echo "Trigger in:"
    echo "  1. 15 seconds (test)"
    echo "  2. 6 minutes"
    echo "  3. 15 minutes"
    echo "  4. Custom (minutes)"
    
    read -p "Choice: " rchoice
    
    use_seconds=0
    case $rchoice in
        1) seconds=15; use_seconds=1 ;;
        2) minutes=6 ;;
        3) minutes=15 ;;
        4) read -p "Minutes: " minutes ;;
        *) return 1 ;;
    esac

    timestamp=$(date +%s)
    if [ "$use_seconds" = "1" ]; then
        delay=$seconds
        trigger_time=$((timestamp + seconds))
    else
        delay=$((minutes * 60))
        trigger_time=$((timestamp + delay))
    fi

    echo "$(date -d @$trigger_time '+%Y-%m-%d %H:%M:%S')|$message" >> "$REMINDERS_FILE"

    (
        sleep $delay
        notify-send "⏰ Reminder" "$message" 2>/dev/null || echo "REMINDER: $message"
    ) &

    display_success "Reminder set for $(date -d @$trigger_time '+%H:%M:%S')"
    pause_screen
}

view_reminders() {
    clear
    display_header "CURRENT REMINDERS"
    if [ ! -s "$REMINDERS_FILE" ]; then
        display_info "No reminders set."
    else
        printf "%-20s | %s\n" "Execution Time" "Message"
        echo "----------------------------------------------------"
        cat "$REMINDERS_FILE" | while IFS='|' read -r time msg; do
            printf "%-20s | %s\n" "$time" "$msg"
        done
    fi
    echo ""
    pause_screen
}

clear_reminders() {
    > "$REMINDERS_FILE"
    display_success "Reminders cleared!"
    pause_screen
}

view_scheduled_tasks() {
    clear
    display_header "SYSTÈME & TÂCHES PLANIFIÉES"

    echo "--- Statut de l'extinction ---"
    if [ -f /run/systemd/shutdown/scheduled ] || pgrep -x "shutdown" > /dev/null; then
        display_warning "⚠️ Un arrêt du système est programmé !"
        echo "Pour annuler : sudo shutdown -c"
    else
        display_info "✅ Aucun arrêt système programmé."
    fi

    echo ""
    echo "--- File d'attente des tâches (atq) ---"
    if check_command_exists "atq"; then
        at_jobs=$(atq 2>/dev/null)
        if [ -n "$at_jobs" ]; then
            echo "$at_jobs" | sort -k2
        else
            echo "Aucune tâche 'at' détectée."
        fi
    fi

    echo ""
    echo "--- Rappels enregistrés (Fichier) ---"
    if [ -s "$REMINDERS_FILE" ]; then
        printf "%-20s | %s\n" "Heure prévue" "Message"
        echo "----------------------------------------------------"
        cat "$REMINDERS_FILE"
    else
        echo "Aucun rappel dans le fichier."
    fi
    pause_screen
}
