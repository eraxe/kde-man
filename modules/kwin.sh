#!/bin/bash

# KWin module for KDE Manager
# Contains functions for managing KWin window manager

# KWin management menu
kwin_management_menu() {
    clear
    echo -e "${BLUE}=== KWin Management ===${NC}"
    echo "1. Restart KWin"
    echo "2. Enable/Disable Desktop Effects"
    echo "3. Reset KWin Configuration"
    echo "4. View KWin Status"
    echo "5. Back to Main Menu"
    echo
    read -p "Select an option: " kwin_choice
    
    case $kwin_choice in
        1) restart_kwin ;;
        2) manage_desktop_effects ;;
        3) reset_kwin_config ;;
        4) view_kwin_status ;;
        5) return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2; kwin_management_menu ;;
    esac
    
    kwin_management_menu
}

# Restart KWin
restart_kwin() {
    echo -e "${BLUE}Restarting KWin...${NC}"
    
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        kwin_wayland --replace &
    else
        kwin_x11 --replace &
    fi
    
    echo -e "${GREEN}KWin restarted successfully!${NC}"
    read -p "Press Enter to continue..."
}

# Manage desktop effects
manage_desktop_effects() {
    echo -e "${BLUE}Managing desktop effects...${NC}"
    echo "1. Enable Desktop Effects"
    echo "2. Disable Desktop Effects"
    echo "3. Back"
    echo
    read -p "Select an option: " effects_choice
    
    case $effects_choice in
        1) if command_exists qdbus; then
               qdbus org.kde.KWin /Effects activeEffectsChanged true
           else
               kwriteconfig5 --file kwinrc --group Compositing --key Enabled true
               pkill -f kwin && kwin_x11 --replace &
           fi
           echo -e "${GREEN}Desktop effects enabled${NC}" ;;
        2) if command_exists qdbus; then
               qdbus org.kde.KWin /Effects activeEffectsChanged false
           else
               kwriteconfig5 --file kwinrc --group Compositing --key Enabled false
               pkill -f kwin && kwin_x11 --replace &
           fi
           echo -e "${GREEN}Desktop effects disabled${NC}" ;;
        3) return ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press Enter to continue..."
}

# Reset KWin configuration
reset_kwin_config() {
    echo -e "${YELLOW}This will reset KWin configuration to default.${NC}"
    read -p "Continue? (y/n): " confirm
    
    if [[ $confirm == [yY] ]]; then
        echo -e "${BLUE}Resetting KWin configuration...${NC}"
        
        kwriteconfig5 --file kwinrc --group Compositing --key Enabled true
        kwriteconfig5 --file kwinrc --group Compositing --key Backend OpenGL
        
        # Kill kwin to apply changes
        pkill -f kwin
        sleep 1
        if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
            kwin_wayland --replace &
        else
            kwin_x11 --replace &
        fi
        
        echo -e "${GREEN}KWin configuration reset successfully!${NC}"
    fi
    read -p "Press Enter to continue..."
}

# View KWin status
view_kwin_status() {
    echo -e "${BLUE}KWin Status:${NC}"
    if command_exists qdbus; then
        qdbus org.kde.KWin /KWin supportInformation | less
    else
        echo -e "${YELLOW}qdbus not available. Install qt5-tools to view detailed KWin status.${NC}"
        echo -e "${BLUE}Basic KWin process info:${NC}"
        ps aux | grep -i kwin | grep -v grep
    fi
    read -p "Press Enter to continue..."
}
