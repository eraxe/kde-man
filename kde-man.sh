#!/bin/bash

# KDE Plasma 6.2 Management Tool for CachyOS (Arch-based)
# Version: 2.0 - Modular Edition
# Author: System Administrator

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
if [ -f "$SCRIPT_DIR/config/settings.conf" ]; then
    source "$SCRIPT_DIR/config/settings.conf"
fi

# Load modules
source "$SCRIPT_DIR/modules/core.sh"
source "$SCRIPT_DIR/modules/restart.sh"
source "$SCRIPT_DIR/modules/logs.sh"
source "$SCRIPT_DIR/modules/theme.sh"
source "$SCRIPT_DIR/modules/kwin.sh"
source "$SCRIPT_DIR/modules/kvantum.sh"
source "$SCRIPT_DIR/modules/session.sh"
source "$SCRIPT_DIR/modules/backup.sh"
source "$SCRIPT_DIR/modules/cleanup.sh"

# Function to display the main menu
main_menu() {
    clear
    echo -e "${BLUE}=== KDE Plasma 6.2 Management Tool for CachyOS ===${NC}"
    echo "1. Re-install KDE Plasma 6.2 (Fresh Install)"
    echo "2. Soft Restart KDE Plasma"
    echo "3. Hard Restart KDE Plasma"
    echo "4. Wayland Restart/Redraw"
    echo "5. View/Export KDE Logs"
    echo "6. Theme and Configuration Management"
    echo "7. KWin Management"
    echo "8. Kvantum Management"
    echo "9. Session Management"
    echo "10. Backup/Restore KDE Configuration"
    echo "11. Cleanup and Diagnostics"
    echo "q. Quit"
    echo
    read -p "Select an option: " choice
    
    case $choice in
        1) reinstall_kde ;;
        2) soft_restart_kde ;;
        3) hard_restart_kde ;;
        4) wayland_restart ;;
        5) kde_logs_menu ;;
        6) theme_management_menu ;;
        7) kwin_management_menu ;;
        8) kvantum_management_menu ;;
        9) session_management_menu ;;
        10) backup_restore_menu ;;
        11) cleanup_diagnostics_menu ;;
        q) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2 ;;
    esac
    
    main_menu
}

# Start the script
main_menu
