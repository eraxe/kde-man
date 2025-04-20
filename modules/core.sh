#!/bin/bash

# Core module for KDE Manager
# Contains basic functions and variables used across modules

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
VERSION="2.0"
BACKUP_DIR="$HOME/.kde-backup-$(date +%Y%m%d-%H%M%S)"
LOG_DIR="$HOME/.kde-logs"

# Create necessary directories
mkdir -p "$LOG_DIR"

# Check if the script is running as root
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}Please don't run this script as root. Use sudo when required.${NC}"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if we're running on KDE
check_kde_environment() {
    if [ -z "$KDE_FULL_SESSION" ]; then
        echo -e "${YELLOW}Warning: Not running in a KDE session${NC}"
        read -p "Continue anyway? (y/n): " confirm
        if [[ $confirm != [yY] ]]; then
            exit 0
        fi
    fi
}

# Check system compatibility
check_system_compatibility() {
    if ! grep -qi "CachyOS\|Arch" /etc/os-release; then
        echo -e "${YELLOW}Warning: This script is designed for CachyOS/Arch Linux${NC}"
        read -p "Continue anyway? (y/n): " confirm
        if [[ $confirm != [yY] ]]; then
            exit 0
        fi
    fi
}

# Check dependencies
check_dependencies() {
    local deps=("kquitapp5" "kstart5" "kwriteconfig5" "kwin_x11" "plasmashell")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}Missing dependencies: ${missing[*]}${NC}"
        echo -e "${YELLOW}Please run the installer to install missing dependencies${NC}"
        exit 1
    fi
}

# Initialize
check_not_root
check_kde_environment
check_system_compatibility
check_dependencies
