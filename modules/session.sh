#!/bin/bash

# Session module for KDE Manager
# Contains functions for managing KDE sessions

# Session management menu
session_management_menu() {
    clear
    echo -e "${BLUE}=== Session Management ===${NC}"
    echo "1. Save Current Session"
    echo "2. Restore Session"
    echo "3. Clear Session Data"
    echo "4. Switch between X11/Wayland"
    echo "5. Back to Main Menu"
    echo
    read -p "Select an option: " session_choice
    
    case $session_choice in
        1) save_current_session ;;
        2) restore_session ;;
        3) clear_session_data ;;
        4) switch_session_type ;;
        5) return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2; session_management_menu ;;
    esac
    
    session_management_menu
}

# Save current session
save_current_session() {
    local session_backup="$BACKUP_DIR/session-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$session_backup"
    
    echo -e "${BLUE}Saving current session to $session_backup...${NC}"
    
    cp -r ~/.config/ksmserverrc "$session_backup/"
    cp -r ~/.config/session "$session_backup/" 2>/dev/null
    
    echo -e "${GREEN}Session saved successfully!${NC}"
    read -p "Press Enter to continue..."
}

# Restore session
restore_session() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}No backup directory found${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${BLUE}Available session backups:${NC}"
    ls -d "$BACKUP_DIR"/session-* 2>/dev/null
    
    read -p "Enter backup folder name to restore (or press Enter to cancel): " backup_name
    if [ ! -z "$backup_name" ] && [ -d "$BACKUP_DIR/$backup_name" ]; then
        echo -e "${BLUE}Restoring session from $backup_name...${NC}"
        
        cp -rf "$BACKUP_DIR/$backup_name"/* ~/.config/
        
        echo -e "${GREEN}Session restored successfully!${NC}"
        echo -e "${YELLOW}Please restart Plasma for changes to take effect.${NC}"
    fi
    read -p "Press Enter to continue..."
}

# Clear session data
clear_session_data() {
    echo -e "${YELLOW}This will clear all session data.${NC}"
    read -p "Continue? (y/n): " confirm
    
    if [[ $confirm == [yY] ]]; then
        echo -e "${BLUE}Clearing session data...${NC}"
        
        rm -rf ~/.config/session
        rm -f ~/.config/ksmserverrc
        
        echo -e "${GREEN}Session data cleared successfully!${NC}"
    fi
    read -p "Press Enter to continue..."
}

# Switch between X11/Wayland
switch_session_type() {
    echo -e "${BLUE}Current session type: $XDG_SESSION_TYPE${NC}"
    echo -e "${YELLOW}To switch session type, you need to log out and select the other option at login.${NC}"
    echo -e "This requires manual intervention at the login screen."
    read -p "Press Enter to continue..."
}
