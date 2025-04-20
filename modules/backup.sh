#!/bin/bash

# Backup module for KDE Manager
# Contains functions for backing up and restoring KDE configuration

# Backup/Restore menu
backup_restore_menu() {
    clear
    echo -e "${BLUE}=== Backup/Restore KDE Configuration ===${NC}"
    echo "1. Backup KDE Configuration"
    echo "2. Restore KDE Configuration"
    echo "3. View Available Backups"
    echo "4. Back to Main Menu"
    echo
    read -p "Select an option: " backup_choice
    
    case $backup_choice in
        1) backup_kde_config ;;
        2) restore_kde_config ;;
        3) view_available_backups ;;
        4) return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2; backup_restore_menu ;;
    esac
    
    backup_restore_menu
}

# Backup KDE configuration
backup_kde_config() {
    mkdir -p "$BACKUP_DIR"
    echo -e "${BLUE}Backing up KDE configuration to $BACKUP_DIR...${NC}"
    
    # Backup important KDE configuration directories
    cp -r ~/.config/plasma* "$BACKUP_DIR/"
    cp -r ~/.config/kde* "$BACKUP_DIR/"
    cp -r ~/.config/kwin* "$BACKUP_DIR/"
    cp -r ~/.config/kglobalshortcutsrc "$BACKUP_DIR/"
    cp -r ~/.local/share/plasma* "$BACKUP_DIR/"
    cp -r ~/.local/share/kwin "$BACKUP_DIR/"
    
    # Create a compressed archive
    tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
    
    echo -e "${GREEN}Backup completed successfully!${NC}"
    echo -e "Backup saved to: $BACKUP_DIR.tar.gz"
    read -p "Press Enter to continue..."
}

# Restore KDE configuration
restore_kde_config() {
    echo -e "${BLUE}Available backups:${NC}"
    ls -la ~/.kde-backup-*.tar.gz 2>/dev/null
    
    read -p "Enter backup filename to restore (without .tar.gz): " backup_name
    if [ -f "$HOME/$backup_name.tar.gz" ]; then
        echo -e "${YELLOW}WARNING: This will overwrite your current KDE configuration${NC}"
        read -p "Continue? (y/n): " confirm
        
        if [[ $confirm == [yY] ]]; then
            echo -e "${BLUE}Restoring KDE configuration from $backup_name...${NC}"
            
            # Extract the backup
            tar -xzf "$HOME/$backup_name.tar.gz" -C "$HOME"
            
            # Restore files
            cp -rf "$HOME/$backup_name"/* ~/.config/
            cp -rf "$HOME/$backup_name"/plasma* ~/.local/share/
            
            echo -e "${GREEN}Restore completed successfully!${NC}"
            echo -e "${YELLOW}Please log out and log back in for changes to take effect.${NC}"
        fi
    else
        echo -e "${RED}Backup file not found${NC}"
    fi
    read -p "Press Enter to continue..."
}

# View available backups
view_available_backups() {
    echo -e "${BLUE}Available KDE configuration backups:${NC}"
    ls -la ~/.kde-backup-*.tar.gz 2>/dev/null
    echo
    echo -e "${BLUE}Available session backups:${NC}"
    ls -d ~/.kde-backup-*/session-* 2>/dev/null
    echo
    echo -e "${BLUE}Available theme backups:${NC}"
    ls -d ~/.kde-backup-*/theme-* 2>/dev/null
    echo
    read -p "Press Enter to continue..."
}
