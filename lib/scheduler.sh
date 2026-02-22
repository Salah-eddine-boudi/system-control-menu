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

view_scheduled_tasks() {
    clear
    echo "========================================"
    echo "      SCHEDULED TASKS"
    echo "========================================"
    echo ""
    
    # Check if shutdown is scheduled
    if pgrep -x "shutdown" > /dev/null 2>&1; then
        display_warning "System shutdown is currently scheduled"
        echo ""
        echo "To cancel: sudo shutdown -c"
    else
        display_info "No shutdown scheduled"
    fi
    
    echo ""
    echo "Current System Schedule:"
    echo "----------------------------------------"
    
    # Show at jobs if available
    if check_command_exists "atq"; then
        at_jobs=$(atq 2>/dev/null)
        if [ -n "$at_jobs" ]; then
            echo "$at_jobs"
        else
            echo "No scheduled at jobs"
        fi
    else
        echo "at command not available"
    fi
    
    echo ""
    pause_screen
}

schedule_shutdown() {
    clear
    echo "========================================"
    echo "      SCHEDULE SHUTDOWN"
    echo "========================================"
    echo ""
    
    echo "Choose shutdown time:"
    echo "  1. In 15 seconds (test)"
    echo "  2. In 5 minutes"
    echo "  3. In 30 minutes"
    echo "  4. In 1 hour"
    echo "  5. Custom time (minutes)"
    echo "  0. Cancel"
    echo ""
    
    read -p "Enter choice: " choice
    
    case $choice in
        1) 
            seconds=15
            minutes=0
            use_seconds=1
            ;;
        2) minutes=5 ;;
        3) minutes=30 ;;
        4) minutes=60 ;;
        5)
            read -p "Enter minutes: " minutes
            if [ -z "$minutes" ]; then
                display_error "No time entered"
                pause_screen
                return 1
            fi
            ;;
        0) return ;;
        *)
            display_error "Invalid choice"
            pause_screen
            return 1
            ;;
    esac
    
    echo ""
    
    if [ "$use_seconds" = "1" ]; then
        echo "Scheduling shutdown in $seconds seconds (TEST MODE)"
    else
        echo "Scheduling shutdown in $minutes minutes"
    fi
    echo ""
    
    read -p "Confirm? (y/n): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        if [ "$use_seconds" = "1" ]; then
            # For testing: use seconds
            sudo shutdown -h +0 "Scheduled shutdown - TEST" 2>/dev/null &
            sleep 1
            sudo shutdown -c 2>/dev/null
            sudo shutdown -h $(date -d "+15 seconds" "+%H:%M") "Scheduled shutdown" 2>/dev/null
        else
            # Normal: use minutes
            sudo shutdown -h +$minutes "Scheduled shutdown" 2>/dev/null
        fi
        
        if [ $? -eq 0 ]; then
            display_success "Shutdown scheduled"
            log_message "INFO" "Shutdown scheduled"
        else
            display_error "Failed to schedule shutdown"
            echo "You may need sudo privileges"
        fi
    else
        display_info "Cancelled"
    fi
    
    echo ""
    pause_screen
}

set_reminder() {
    clear
    echo "========================================"
    echo "      SET REMINDER"
    echo "========================================"
    echo ""
    
    read -p "Enter reminder message: " message
    
    if [ -z "$message" ]; then
        display_error "Message cannot be empty"
        pause_screen
        return 1
    fi
    
    echo ""
    echo "When should the reminder trigger?"
    echo "  1. In 15 seconds (test)"
    echo "  2. In 5 minutes"
    echo "  3. In 15 minutes"
    echo "  4. In 30 minutes"
    echo "  5. In 1 hour"
    echo "  6. Custom (minutes)"
    echo ""
    
    read -p "Enter choice: " choice
    
    case $choice in
        1)
            seconds=15
            minutes=0
            use_seconds=1
            ;;
        2) minutes=5 ;;
        3) minutes=15 ;;
        4) minutes=30 ;;
        5) minutes=60 ;;
        6)
            read -p "Enter minutes: " minutes
            if [ -z "$minutes" ]; then
                display_error "No time entered"
                pause_screen
                return 1
            fi
            ;;
        *)
            display_error "Invalid choice"
            pause_screen
            return 1
            ;;
    esac
    
    echo ""
    
    if [ "$use_seconds" = "1" ]; then
        echo "Reminder will trigger in $seconds seconds (TEST MODE)"
    else
        echo "Reminder will trigger in $minutes minutes"
    fi
    echo ""
    
    read -p "Confirm? (y/n): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        timestamp=$(date +%s)
        
        if [ "$use_seconds" = "1" ]; then
            trigger_time=$((timestamp + seconds))
            sleep_time=$seconds
        else
            trigger_time=$((timestamp + minutes * 60))
            sleep_time=$((minutes * 60))
        fi
        
        echo "$trigger_time|$message" >> "$REMINDERS_FILE"
        
        display_success "Reminder set!"
        log_message "INFO" "Reminder set: $message"
        
        # Background notification
        (
            sleep $sleep_time
            notify-send "⏰ Reminder" "$message" 2>/dev/null || \
            echo "[$(date)] REMINDER: $message" >> "$SCRIPT_DIR/logs/reminders.log"
        ) &
        
        echo ""
        if [ "$use_seconds" = "1" ]; then
            echo "Reminder will appear in $seconds seconds"
        else
            echo "Reminder will appear in $minutes minutes"
        fi
    else
        display_info "Cancelled"
    fi
    
    echo ""
    pause_screen
}
```

---

## 🎨 RÉSULTAT

### Menu Shutdown:
```
========================================
      SCHEDULE SHUTDOWN
========================================

Choose shutdown time:
  1. In 15 seconds (test)      ← NOUVEAU
  2. In 5 minutes
  3. In 30 minutes
  4. In 1 hour
  5. Custom time (minutes)
  0. Cancel

Enter choice: 1

Scheduling shutdown in 15 seconds (TEST MODE)

Confirm? (y/n): y
✅ Shutdown scheduled

Press Enter to continue...
```

### Menu Reminder:
```
========================================
      SET REMINDER
========================================

Enter reminder message: Test reminder

When should the reminder trigger?
  1. In 15 seconds (test)      ← NOUVEAU
  2. In 5 minutes
  3. In 15 minutes
  4. In 30 minutes
  5. In 1 hour
  6. Custom (minutes)

Enter choice: 1

Reminder will trigger in 15 seconds (TEST MODE)

Confirm? (y/n): y
✅ Reminder set!

Reminder will appear in 15 seconds

Press Enter to continue...
