#!/bin/bash

# Logs module for KDE Manager
# Contains functions for managing KDE logs

# KDE logs menu
kde_logs_menu() {
    clear
    echo -e "${BLUE}=== KDE Logs Management ===${NC}"
    echo "1. View KDE System Logs"
    echo "2. View KWin Logs"
    echo "3. View Plasma Shell Logs"
    echo "4. Export All KDE Logs"
    echo "5. View Recent Crash Reports"
    echo "6. Back to Main Menu"
    echo
    read -p "Select an option: " log_choice
    
    case $log_choice in
        1) journalctl --user -u plasma* | less ;;
        2) journalctl --user -u kwin* | less ;;
        3) journalctl --user -u plasmashell | less ;;
        4) export_kde_logs ;;
        5) view_crash_reports ;;
        6) return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2; kde_logs_menu ;;
    esac
    
    kde_logs_menu
}

# Function to export KDE logs
export_kde_logs() {
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local export_dir="$LOG_DIR/export-$timestamp"
    mkdir -p "$export_dir"
    
    echo -e "${BLUE}Exporting KDE logs to $export_dir...${NC}"
    
    # Export system logs
    journalctl --user -u plasma* > "$export_dir/plasma-logs.txt"
    journalctl --user -u kwin* > "$export_dir/kwin-logs.txt"
    journalctl --user -u plasmashell > "$export_dir/plasmashell-logs.txt"
    
    # Export recent crashes
    if [ -d "$HOME/.cache/drkonqi/crashes" ]; then
        cp -r "$HOME/.cache/drkonqi/crashes" "$export_dir/"
    fi
    
    # Export systemd user logs
    systemctl --user status plasma-plasmashell.service > "$export_dir/plasma-service-status.txt"
    systemctl --user status kwin.service > "$export_dir/kwin-service-status.txt" 2>/dev/null
    
    # Create archive
    tar -czf "$LOG_DIR/kde-logs-$timestamp.tar.gz" -C "$export_dir" .
    rm -rf "$export_dir"
    
    echo -e "${GREEN}Logs exported to: $LOG_DIR/kde-logs-$timestamp.tar.gz${NC}"
    read -p "Press Enter to continue..."
}

# Function to view crash reports
view_crash_reports() {
    if [ -d "$HOME/.cache/drkonqi/crashes" ]; then
        echo -e "${BLUE}Recent crash reports:${NC}"
        ls -la "$HOME/.cache/drkonqi/crashes"
        echo
        read -p "Enter filename to view (or press Enter to cancel): " filename
        if [ ! -z "$filename" ] && [ -f "$HOME/.cache/drkonqi/crashes/$filename" ]; then
            less "$HOME/.cache/drkonqi/crashes/$filename"
        fi
    else
        echo -e "${YELLOW}No crash reports found${NC}"
    fi
    read -p "Press Enter to continue..."
}
