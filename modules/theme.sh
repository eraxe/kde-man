#!/bin/bash

# Theme module for KDE Manager
# Contains functions for managing KDE themes and appearance

# Theme and configuration management menu
theme_management_menu() {
    clear
    echo -e "${BLUE}=== Theme and Configuration Management ===${NC}"
    echo "1. Reset KDE Theme to Default"
    echo "2. Backup Current Theme Settings"
    echo "3. Restore Theme Settings"
    echo "4. Fix Icon Theme Issues"
    echo "5. Clear Cache"
    echo "6. Back to Main Menu"
    echo
    read -p "Select an option: " theme_choice
    
    case $theme_choice in
        1) reset_kde_theme ;;
        2) backup_theme_settings ;;
        3) restore_theme_settings ;;
        4) fix_icon_theme ;;
        5) clear_cache ;;
        6) return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2; theme_management_menu ;;
    esac
    
    theme_management_menu
}

# Function to reset KDE theme to default
reset_kde_theme() {
    echo -e "${BLUE}Resetting KDE theme to default...${NC}"
    
    # Reset theme settings
    lookandfeeltool -a org.kde.breeze.desktop
    
    echo -e "${GREEN}Theme reset completed!${NC}"
    echo -e "${YELLOW}You may need to restart Plasma for all changes to take effect.${NC}"
    read -p "Press Enter to continue..."
}

# Backup theme settings
backup_theme_settings() {
    local theme_backup="$BACKUP_DIR/theme-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$theme_backup"
    
    echo -e "${BLUE}Backing up theme settings to $theme_backup...${NC}"
    
    cp -r ~/.config/kdeglobals "$theme_backup/"
    cp -r ~/.config/plasma-org.kde.plasma.desktop-appletsrc "$theme_backup/"
    cp -r ~/.local/share/color-schemes "$theme_backup/" 2>/dev/null
    cp -r ~/.local/share/plasma/look-and-feel "$theme_backup/" 2>/dev/null
    
    echo -e "${GREEN}Theme settings backed up successfully!${NC}"
    read -p "Press Enter to continue..."
}

# Restore theme settings
restore_theme_settings() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}No backup directory found${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${BLUE}Available theme backups:${NC}"
    ls -d "$BACKUP_DIR"/theme-* 2>/dev/null
    
    read -p "Enter backup folder name to restore (or press Enter to cancel): " backup_name
    if [ ! -z "$backup_name" ] && [ -d "$BACKUP_DIR/$backup_name" ]; then
        echo -e "${BLUE}Restoring theme settings from $backup_name...${NC}"
        
        cp -rf "$BACKUP_DIR/$backup_name"/* ~/.config/
        cp -rf "$BACKUP_DIR/$backup_name"/color-schemes ~/.local/share/ 2>/dev/null
        cp -rf "$BACKUP_DIR/$backup_name"/look-and-feel ~/.local/share/plasma/ 2>/dev/null
        
        echo -e "${GREEN}Theme settings restored successfully!${NC}"
        echo -e "${YELLOW}Please restart Plasma for changes to take effect.${NC}"
    fi
    read -p "Press Enter to continue..."
}

# Fix icon theme issues
fix_icon_theme() {
    echo -e "${BLUE}Fixing icon theme issues...${NC}"
    
    # Rebuild icon cache
    if command_exists gtk-update-icon-cache; then
        gtk-update-icon-cache -f ~/.local/share/icons/* 2>/dev/null
        gtk-update-icon-cache -f /usr/share/icons/* 2>/dev/null
    else
        echo -e "${YELLOW}gtk-update-icon-cache not found. Install gtk-update-icon-cache for full functionality.${NC}"
    fi
    
    # Update the icon cache
    if command_exists update-desktop-database; then
        update-desktop-database ~/.local/share/applications
    else
        echo -e "${YELLOW}update-desktop-database not found. Install desktop-file-utils for full functionality.${NC}"
    fi
    
    echo -e "${GREEN}Icon theme fix completed!${NC}"
    read -p "Press Enter to continue..."
}

# Clear cache
clear_cache() {
    echo -e "${BLUE}Clearing KDE cache...${NC}"
    
    rm -rf ~/.cache/plasmashell*
    rm -rf ~/.cache/kwin*
    rm -rf ~/.cache/icon-cache.kcache
    
    echo -e "${GREEN}Cache cleared successfully!${NC}"
    read -p "Press Enter to continue..."
}
