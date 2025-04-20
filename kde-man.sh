#!/bin/bash

# KDE Plasma 6.2 Management Tool for CachyOS (Arch-based)
# Version: 2.1 - Enhanced Modular Edition
# Author: System Administrator

# Get the real directory where the script is located, even if called through a symlink
# This resolves the real script location even when called through a symlink
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Print debug information
echo "Script is being executed from: $SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to verify module structure and permissions
verify_modules() {
    echo -e "${BLUE}Verifying modules and permissions...${NC}"

    # Required directories and modules
    local required_modules=("core.sh" "restart.sh" "logs.sh" "theme.sh" "kwin.sh"
                          "kvantum.sh" "session.sh" "backup.sh" "cleanup.sh")
    local missing_modules=()

    # Check modules directory
    if [ ! -d "$SCRIPT_DIR/modules" ]; then
        echo -e "${RED}Error: Modules directory not found!${NC}"
        echo -e "${YELLOW}Expected at: $SCRIPT_DIR/modules${NC}"
        echo -e "${YELLOW}Creating modules directory...${NC}"
        mkdir -p "$SCRIPT_DIR/modules" || {
            echo -e "${RED}Failed to create modules directory. Do you have write permissions?${NC}"
            return 1
        }
    else
        echo -e "${GREEN}Modules directory found at: $SCRIPT_DIR/modules${NC}"
    fi

    # Check config directory
    if [ ! -d "$SCRIPT_DIR/config" ]; then
        echo -e "${RED}Error: Config directory not found!${NC}"
        echo -e "${YELLOW}Expected at: $SCRIPT_DIR/config${NC}"
        echo -e "${YELLOW}Creating config directory...${NC}"
        mkdir -p "$SCRIPT_DIR/config" || {
            echo -e "${RED}Failed to create config directory. Do you have write permissions?${NC}"
            return 1
        }
    else
        echo -e "${GREEN}Config directory found at: $SCRIPT_DIR/config${NC}"
    fi

    # Check for required modules
    for module in "${required_modules[@]}"; do
        if [ ! -f "$SCRIPT_DIR/modules/$module" ]; then
            echo -e "${RED}Error: Required module $module not found!${NC}"
            echo -e "${YELLOW}Expected at: $SCRIPT_DIR/modules/$module${NC}"
            missing_modules+=("$module")
        else
            echo -e "${GREEN}Found module: $module${NC}"
            # Fix permissions for each module
            if [ ! -x "$SCRIPT_DIR/modules/$module" ]; then
                echo -e "${YELLOW}Fixing permissions for $module...${NC}"
                chmod +x "$SCRIPT_DIR/modules/$module" || {
                    echo -e "${RED}Failed to set executable permission for $module. Do you have write permissions?${NC}"
                }
            fi
        fi
    done

    # Check for configuration file
    if [ ! -f "$SCRIPT_DIR/config/settings.conf" ]; then
        echo -e "${YELLOW}Warning: Configuration file not found!${NC}"
        echo -e "${YELLOW}Expected at: $SCRIPT_DIR/config/settings.conf${NC}"
        echo -e "${YELLOW}Creating default configuration...${NC}"

        # Create default configuration - fixed heredoc
        cat > "$SCRIPT_DIR/config/settings.conf" << 'ENDCONFIG'
# KDE Manager Configuration File

# Application settings
APP_VERSION="2.1"
APP_NAME="KDE Manager"
APP_AUTHOR="System Administrator"

# Directory settings
BACKUP_ROOT_DIR="$HOME/.kde-man-backups"
LOG_ROOT_DIR="$HOME/.kde-man-logs"
TEMP_DIR="/tmp/kde-man"

# Default behavior
AUTO_BACKUP_BEFORE_REINSTALL=true
CLEANUP_TEMP_ON_EXIT=true
MAX_BACKUP_AGE_DAYS=30

# Colors (override if needed)
#RED='\033[0;31m'
#GREEN='\033[0;32m'
#YELLOW='\033[1;33m'
#BLUE='\033[0;34m'
#NC='\033[0m'

# Features
ENABLE_EXPERIMENTAL_FEATURES=false
ENABLE_DETAILED_LOGGING=false
ENDCONFIG

        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to create settings.conf. Do you have write permissions?${NC}"
        fi
    else
        echo -e "${GREEN}Configuration file found at: $SCRIPT_DIR/config/settings.conf${NC}"
    fi

    # Report missing modules
    if [ ${#missing_modules[@]} -gt 0 ]; then
        echo -e "${RED}Missing modules: ${missing_modules[*]}${NC}"
        echo -e "${YELLOW}Please run the installer: sudo $SCRIPT_DIR/install.sh install${NC}"
        return 1
    fi

    echo -e "${GREEN}Module verification completed successfully!${NC}"
    return 0
}

# Load configuration with error handling
load_configuration() {
    echo -e "${BLUE}Loading configuration...${NC}"

    if [ -f "$SCRIPT_DIR/config/settings.conf" ]; then
        source "$SCRIPT_DIR/config/settings.conf"
        echo -e "${GREEN}Configuration loaded successfully!${NC}"
    else
        echo -e "${YELLOW}Warning: Configuration file not found, using defaults${NC}"

        # Set default values
        BACKUP_ROOT_DIR="$HOME/.kde-man-backups"
        LOG_ROOT_DIR="$HOME/.kde-man-logs"
        TEMP_DIR="/tmp/kde-man"
        AUTO_BACKUP_BEFORE_REINSTALL=true
        CLEANUP_TEMP_ON_EXIT=true
        MAX_BACKUP_AGE_DAYS=30
        ENABLE_EXPERIMENTAL_FEATURES=false
        ENABLE_DETAILED_LOGGING=false
    fi

    # Create necessary directories
    mkdir -p "$BACKUP_ROOT_DIR"
    mkdir -p "$LOG_ROOT_DIR"
    mkdir -p "$TEMP_DIR"
}

# Load modules with error handling
load_modules() {
    echo -e "${BLUE}Loading modules...${NC}"

    # First load core module as it contains essential functions
    local core_module="$SCRIPT_DIR/modules/core.sh"
    if [ -f "$core_module" ]; then
        echo -e "${BLUE}Loading core module...${NC}"
        source "$core_module"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to load core module!${NC}"
            return 1
        fi
    else
        echo -e "${RED}Error: Core module not found!${NC}"
        return 1
    fi

    # Then load all other modules
    for module in "$SCRIPT_DIR/modules/"*.sh; do
        if [[ "$module" != "$core_module" ]]; then
            local module_name=$(basename "$module")
            echo -e "${BLUE}Loading module: $module_name...${NC}"
            source "$module"
            if [ $? -ne 0 ]; then
                echo -e "${RED}Error: Failed to load module $module_name!${NC}"
            fi
        fi
    done

    echo -e "${GREEN}All modules loaded!${NC}"
    return 0
}

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
        q)
           echo "Cleaning up before exit..."
           if [ "$CLEANUP_TEMP_ON_EXIT" = true ]; then
               rm -rf "$TEMP_DIR"/*
           fi
           echo "Exiting...";
           exit 0
           ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2 ;;
    esac

    main_menu
}

# Function to display error and exit
error_exit() {
    echo -e "${RED}Fatal Error: $1${NC}" >&2
    echo "Please run the installer to fix this issue:"
    echo "sudo $SCRIPT_DIR/install.sh verify"
    exit 1
}

# Start the script with error handling
echo -e "${BLUE}Starting KDE Manager v2.1...${NC}"

# Verify modules and permissions
verify_modules || error_exit "Module verification failed"

# Load configuration
load_configuration || error_exit "Failed to load configuration"

# Load modules
load_modules || error_exit "Failed to load modules"

# Final check for critical functions
if ! type reinstall_kde > /dev/null 2>&1 || ! type soft_restart_kde > /dev/null 2>&1; then
    error_exit "Critical functions not available"
fi

# Start the main menu
main_menu