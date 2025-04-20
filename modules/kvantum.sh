#!/bin/bash

# Kvantum module for KDE Manager
# Contains functions for managing Kvantum theme engine

# Kvantum management menu
kvantum_management_menu() {
    clear
    echo -e "${BLUE}=== Kvantum Management ===${NC}"
    echo "1. Install Kvantum Themes"
    echo "2. Set Kvantum Theme"
    echo "3. Reset Kvantum Configuration"
    echo "4. Back to Main Menu"
    echo
    read -p "Select an option: " kvantum_choice
    
    case $kvantum_choice in
        1) install_kvantum_themes ;;
        2) set_kvantum_theme ;;
        3) reset_kvantum_config ;;
        4) return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2; kvantum_management_menu ;;
    esac
    
    kvantum_management_menu
}

# Install Kvantum themes
install_kvantum_themes() {
    echo -e "${BLUE}Installing additional Kvantum themes...${NC}"
    
    sudo pacman -S kvantum-theme-materia kvantum-theme-arc kvantum-theme-adapta --noconfirm
    
    echo -e "${GREEN}Kvantum themes installed successfully!${NC}"
    read -p "Press Enter to continue..."
}

# Set Kvantum theme
set_kvantum_theme() {
    echo -e "${BLUE}Opening Kvantum Manager...${NC}"
    if command_exists kvantummanager; then
        kvantummanager
    else
        echo -e "${RED}Kvantum Manager not installed. Please install kvantum package.${NC}"
    fi
    read -p "Press Enter to continue..."
}

# Reset Kvantum configuration
reset_kvantum_config() {
    echo -e "${BLUE}Resetting Kvantum configuration...${NC}"
    
    rm -rf ~/.config/Kvantum
    
    echo -e "${GREEN}Kvantum configuration reset successfully!${NC}"
    read -p "Press Enter to continue..."
}
