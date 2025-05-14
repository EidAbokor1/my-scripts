#!/usr/bin/env bash

TMP_DIR="/tmp"
BACKUP_DIR="/backup"
ERROR_LOG="/var/log/syslog"
OUTPUT_LOG="errors.log"
BACKUP_FILE="${BACKUP_DIR}/etc_backup_$(date +%Y%m%d%H%M%S).tar.gz"

# Check to see backup directory exists
mkdir -p "$BACKUP_DIR"

#File Cleanup
cleanup_files() {
    echo "Cleaning up files older than 7 days in $TMP_DIR..."
    find "$TMP_DIR" -type f -mtime +7 -exec rm -v {} \; | tee deleted_files.log
    echo "File cleanup complete."
}

#System Monitoring
system_monitoring() {
    echo "System Monitoring Information:"
    echo "--------------------------------"
    echo "CPU Usage:"
    top -bn1 | grep "%Cpu" | awk '{print $2 + $4"%"}'
    echo "Memory Usage:"
    free -h
    echo "Disk Usage:"
    df -h
    echo "--------------------------------"
}

# Log Parsing
log_parsing() {
    echo "Parsing logs for errors..."
    grep -i "error" "$ERROR_LOG" > "$OUTPUT_LOG"
    echo "Errors saved to $OUTPUT_LOG."
}

#Backup Automation
backup_etc() {
    echo "Creating a backup of /etc directory..."
    tar -czf "$BACKUP_FILE" /etc
    echo "Backup saved to $BACKUP_FILE."
}

# Error handling
error_handling() {
    echo "An error occurred. Please check the input and try again."
}

# Menu interface
menu() {
    while true; do
        echo "\nSystem Maintenance Script"
        echo "--------------------------"
        echo "1. File Cleanup"
        echo "2. System Monitoring"
        echo "3. Log Parsing"
        echo "4. Backup Automation"
        echo "5. Exit"
        echo -n "Select an option [1-5]: "
        read -r choice
        case $choice in
            1) cleanup_files ;;
            2) system_monitoring ;;
            3) log_parsing ;;
            4) backup_etc ;;
            5) echo "Exiting script. Goodbye!"; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

# Main
menu