#!/bin/bash

# KDE Manager Installer Script
# Version: 2.0
# Author: Arash Abolhasani (eraxe on github)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation settings
INSTALL_DIR="/opt/kde-man"
BIN_LINK="/usr/local/bin/kde-man"
DESKTOP_FILE="/usr/share/applications/kde-man.desktop"
REPO_URL="https://github.com/eraxe/kde-man.git"
TEMP_DIR="/tmp/kde-man-install-$(date +%s)"

# Function to display usage
usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  install     Install KDE Manager"
    echo "  update      Update KDE Manager to latest version"
    echo "  remove      Remove KDE Manager"
    echo "  help        Display this help message"
    exit 1
}

# Check if the script is running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run as root (use sudo)${NC}"
        exit 1
    fi
}

# Function to check if a package is installed
is_installed() {
    pacman -Qi "$1" &> /dev/null
    return $?
}

# Function to install packages
install_package() {
    if ! is_installed "$1"; then
        echo -e "${BLUE}Installing $1...${NC}"
        pacman -S "$1" --noconfirm
    else
        echo -e "${GREEN}$1 is already installed${NC}"
    fi
}

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}Installing dependencies...${NC}"
    
    # Update package database
    pacman -Sy
    
    # Core dependencies
    local deps=(
        "qt5-tools"               # For qdbus
        "kde-cli-tools"           # For kquitapp5, kstart5
        "plasma-workspace"        # For KDE base tools
        "kwin"                    # For window management
        "plasma-desktop"          # For desktop components
        "plasma-integration"      # For Qt integration
        "kvantum"                 # For Kvantum themes
        "kvantum-qt5"            # Qt5 support for Kvantum
        "gtk-update-icon-cache"  # For icon cache updates
        "desktop-file-utils"     # For desktop file updates
        "xdg-utils"              # For XDG utilities
        "plasma-systemmonitor"    # For system monitoring
        "kscreen"                 # For display management
    )
    
    # Optional but recommended packages
    local optional_deps=(
        "kvantum-theme-materia"
        "kvantum-theme-arc"
        "kvantum-theme-adapta"
        "plasma-wayland-session"  # Wayland support
        "sddm"                    # Display manager
    )
    
    # Install core dependencies
    for dep in "${deps[@]}"; do
        install_package "$dep"
    done
    
    # Install optional dependencies
    for dep in "${optional_deps[@]}"; do
        install_package "$dep"
    done
}

# Function to download and install KDE Manager
install_kde_manager() {
    echo -e "${BLUE}Installing KDE Manager...${NC}"
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # If there's a git repository
    if [ -d ".git" ]; then
        # If we're in a git repository, copy files directly
        echo -e "${BLUE}Installing from local repository...${NC}"
        cp -r ./* "$INSTALL_DIR/"
    elif [ ! -z "$REPO_URL" ]; then
        # Clone from repository
        echo -e "${BLUE}Cloning from repository...${NC}"
        git clone "$REPO_URL" "$TEMP_DIR"
        cp -r "$TEMP_DIR"/* "$INSTALL_DIR/"
        rm -rf "$TEMP_DIR"
    else
        # Create directory structure
        mkdir -p "$INSTALL_DIR/modules"
        mkdir -p "$INSTALL_DIR/config"
        
        # If no repository, copy files from current directory
        if [ -f "kde-man.sh" ]; then
            cp kde-man.sh "$INSTALL_DIR/"
        fi
        
        # Copy modules
        if [ -d "modules" ]; then
            cp modules/*.sh "$INSTALL_DIR/modules/"
        fi
        
        # Copy config
        if [ -d "config" ] && [ -f "config/settings.conf" ]; then
            cp config/settings.conf "$INSTALL_DIR/config/"
        fi
    fi
    
    # Make main script executable
    chmod +x "$INSTALL_DIR/kde-man.sh"
    
    # Create symbolic link
    ln -sf "$INSTALL_DIR/kde-man.sh" "$BIN_LINK"
    
    # Create desktop entry
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=KDE Manager
Comment=Manage KDE Plasma configuration and settings
Exec=kde-man
Icon=preferences-desktop-plasma
Terminal=true
Type=Application
Categories=System;Settings;
EOF
    
    # Update desktop database
    update-desktop-database
    
    echo -e "${GREEN}KDE Manager installed successfully!${NC}"
}

# Function to update KDE Manager
update_kde_manager() {
    echo -e "${BLUE}Updating KDE Manager...${NC}"
    
    # Backup current installation
    local backup_dir="/tmp/kde-man-backup-$(date +%s)"
    mkdir -p "$backup_dir"
    cp -r "$INSTALL_DIR"/* "$backup_dir/"
    
    # Update from repository
    if [ ! -z "$REPO_URL" ]; then
        echo -e "${BLUE}Pulling latest changes from repository...${NC}"
        git clone "$REPO_URL" "$TEMP_DIR"
        rm -rf "$INSTALL_DIR"/*
        cp -r "$TEMP_DIR"/* "$INSTALL_DIR/"
        rm -rf "$TEMP_DIR"
    else
        echo -e "${YELLOW}No repository URL defined. Please update manually.${NC}"
        return 1
    fi
    
    # Preserve configuration
    if [ -f "$backup_dir/config/settings.conf" ]; then
        cp "$backup_dir/config/settings.conf" "$INSTALL_DIR/config/"
    fi
    
    # Make main script executable
    chmod +x "$INSTALL_DIR/kde-man.sh"
    
    echo -e "${GREEN}KDE Manager updated successfully!${NC}"
}

# Function to remove KDE Manager
remove_kde_manager() {
    echo -e "${YELLOW}Removing KDE Manager...${NC}"
    
    # Remove installation directory
    rm -rf "$INSTALL_DIR"
    
    # Remove symbolic link
    rm -f "$BIN_LINK"
    
    # Remove desktop entry
    rm -f "$DESKTOP_FILE"
    
    # Update desktop database
    update-desktop-database
    
    echo -e "${GREEN}KDE Manager removed successfully!${NC}"
    echo -e "${YELLOW}Note: Dependencies were not removed.${NC}"
}

# Main function
main() {
    check_root
    
    case "$1" in
        install)
            echo -e "${BLUE}Installing KDE Manager...${NC}"
            install_dependencies
            install_kde_manager
            echo -e "${GREEN}Installation complete!${NC}"
            echo -e "You can now run KDE Manager using: ${BLUE}kde-man${NC}"
            ;;
        update)
            echo -e "${BLUE}Updating KDE Manager...${NC}"
            update_kde_manager
            ;;
        remove)
            echo -e "${RED}Removing KDE Manager...${NC}"
            read -p "Are you sure you want to remove KDE Manager? (y/n): " confirm
            if [[ $confirm == [yY] ]]; then
                remove_kde_manager
            else
                echo -e "${YELLOW}Removal cancelled.${NC}"
            fi
            ;;
        help|*)
            usage
            ;;
    esac
}

# Run main function
main "$@"
