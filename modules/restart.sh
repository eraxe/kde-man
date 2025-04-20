#!/bin/bash

# Restart module for KDE Manager
# Contains functions for restarting KDE components

# Function to re-install KDE Plasma (fresh install)
reinstall_kde() {
    echo -e "${YELLOW}WARNING: This will perform a fresh install of KDE Plasma 6.2${NC}"
    echo -e "${YELLOW}Your current configuration will be backed up first.${NC}"
    read -p "Continue? (y/n): " confirm
    
    if [[ $confirm == [yY] ]]; then
        # Backup current configuration
        backup_kde_config
        
        echo -e "${BLUE}Removing current KDE Plasma installation...${NC}"
        
        # Stop KDE services
        systemctl --user stop plasma*
        
        # Remove KDE packages
        sudo pacman -Rns plasma-meta plasma-desktop kde-applications-meta --noconfirm
        
        # Remove orphaned packages
        sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true
        
        echo -e "${BLUE}Installing fresh KDE Plasma 6.2...${NC}"
        sudo pacman -Sy
        sudo pacman -S plasma-meta plasma-desktop kde-applications-meta qt5-tools --noconfirm
        
        # Install additional KDE tools
        sudo pacman -S kvantum kvantum-qt5 kwin-scripts --noconfirm
        
        echo -e "${GREEN}Fresh installation completed!${NC}"
        echo -e "${YELLOW}Please log out and log back in to complete the installation.${NC}"
        
        read -p "Press Enter to continue..."
    fi
}

# Function for soft restart of KDE Plasma
soft_restart_kde() {
    echo -e "${BLUE}Performing soft restart of KDE Plasma...${NC}"
    
    # Restart plasmashell
    kquitapp5 plasmashell || killall plasmashell
    sleep 2
    kstart5 plasmashell &
    
    # Restart KWin
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        if command_exists qdbus; then
            qdbus org.kde.KWin /KWin replace || kwin_wayland --replace &
        else
            kwin_wayland --replace &
        fi
    else
        # For X11
        kwin_x11 --replace &
    fi
    
    echo -e "${GREEN}Soft restart completed!${NC}"
    read -p "Press Enter to continue..."
}

# Function for hard restart of KDE Plasma
hard_restart_kde() {
    echo -e "${YELLOW}WARNING: This will perform a hard restart of KDE Plasma${NC}"
    read -p "Continue? (y/n): " confirm
    
    if [[ $confirm == [yY] ]]; then
        echo -e "${BLUE}Performing hard restart of KDE Plasma...${NC}"
        
        # Kill all KDE processes
        pkill -f /usr/bin/plasmashell
        pkill -f /usr/bin/kwin
        pkill -f /usr/bin/kded5
        pkill -f /usr/bin/kglobalaccel5
        
        # Wait for processes to terminate
        sleep 3
        
        # Restart core services
        kded5 &
        kglobalaccel5 &
        
        # Restart KWin based on session type
        if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
            kwin_wayland --replace &
        else
            kwin_x11 --replace &
        fi
        
        # Restart plasmashell
        kstart5 plasmashell &
        
        echo -e "${GREEN}Hard restart completed!${NC}"
        read -p "Press Enter to continue..."
    fi
}

# Function to restart Wayland
wayland_restart() {
    if [[ "$XDG_SESSION_TYPE" != "wayland" ]]; then
        echo -e "${RED}You are not running a Wayland session${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${BLUE}Restarting Wayland compositor...${NC}"
    
    # Force redraw
    if command_exists qdbus; then
        qdbus org.kde.KWin /KWin replace || kwin_wayland --replace &
    else
        kwin_wayland --replace &
    fi
    
    echo -e "${GREEN}Wayland restart completed!${NC}"
    read -p "Press Enter to continue..."
}
