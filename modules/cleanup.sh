#!/bin/bash

# Cleanup module for KDE Manager
# Contains functions for cleanup and diagnostics

# Cleanup and diagnostics menu
cleanup_diagnostics_menu() {
    clear
    echo -e "${BLUE}=== Cleanup and Diagnostics ===${NC}"
    echo "1. Run KDE Diagnostics"
    echo "2. Clean Unused Files"
    echo "3. Check KDE Health"
    echo "4. Fix Common Issues"
    echo "5. Back to Main Menu"
    echo
    read -p "Select an option: " diag_choice
    
    case $diag_choice in
        1) run_kde_diagnostics ;;
        2) clean_unused_files ;;
        3) check_kde_health ;;
        4) fix_common_issues ;;
        5) return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 2; cleanup_diagnostics_menu ;;
    esac
    
    cleanup_diagnostics_menu
}

# Run KDE diagnostics
run_kde_diagnostics() {
    echo -e "${BLUE}Running KDE diagnostics...${NC}"
    
    # Check system status
    echo -e "${BLUE}System information:${NC}"
    uname -a
    echo
    
    # Check KDE version
    echo -e "${BLUE}KDE Plasma version:${NC}"
    plasmashell --version
    echo
    
    # Check session type
    echo -e "${BLUE}Session type:${NC}"
    echo $XDG_SESSION_TYPE
    echo
    
    # Check KWin status
    echo -e "${BLUE}KWin status:${NC}"
    if command_exists qdbus; then
        qdbus org.kde.KWin /KWin supportInformation | head -20
    else
        echo -e "${YELLOW}qdbus not available. Install qt5-tools for detailed information.${NC}"
    fi
    echo
    
    # Check running processes
    echo -e "${BLUE}KDE processes:${NC}"
    ps aux | grep -i kde | head -10
    echo
    
    read -p "Press Enter to continue..."
}

# Clean unused files
clean_unused_files() {
    echo -e "${BLUE}Cleaning unused files...${NC}"
    
    # Clean thumbnail cache
    rm -rf ~/.cache/thumbnails/*
    
    # Clean temporary files
    rm -rf ~/.cache/plasma*
    
    # Clean orphaned desktop files
    rm -f ~/.local/share/applications/*.desktop_
    
    echo -e "${GREEN}Cleanup completed successfully!${NC}"
    read -p "Press Enter to continue..."
}

# Check KDE health
check_kde_health() {
    echo -e "${BLUE}Checking KDE health...${NC}"
    
    # Check for common issues
    if systemctl --user is-failed plasma-plasmashell.service > /dev/null 2>&1; then
        echo -e "${RED}Plasma shell service is failing${NC}"
    else
        echo -e "${GREEN}Plasma shell service is healthy${NC}"
    fi
    
    # Check for display issues
    if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
        echo -e "${RED}No display environment detected${NC}"
    else
        echo -e "${GREEN}Display environment is properly set${NC}"
    fi
    
    # Check for Qt issues
    if [ -z "$QT_QPA_PLATFORM" ]; then
        echo -e "${YELLOW}QT_QPA_PLATFORM not set (this is usually fine)${NC}"
    else
        echo -e "${GREEN}QT_QPA_PLATFORM: $QT_QPA_PLATFORM${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

# Fix common issues menu
fix_common_issues() {
    echo -e "${BLUE}Fixing common KDE issues...${NC}"
    echo "1. Fix black screen"
    echo "2. Fix no icons"
    echo "3. Fix no desktop panel"
    echo "4. Fix slow performance"
    echo "5. Back"
    echo
    read -p "Select an option: " fix_choice
    
    case $fix_choice in
        1) fix_black_screen ;;
        2) fix_no_icons ;;
        3) fix_no_panel ;;
        4) fix_slow_performance ;;
        5) return ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    
    fix_common_issues
}

# Fix black screen
fix_black_screen() {
    echo -e "${BLUE}Fixing black screen issue...${NC}"
    
    # Reset compositor settings
    kwriteconfig5 --file kwinrc --group Compositing --key Enabled true
    kwriteconfig5 --file kwinrc --group Compositing --key Backend OpenGL
    
    # Restart compositor
    if command_exists qdbus; then
        qdbus org.kde.KWin /Compositor resume
    else
        pkill -f kwin && kwin_x11 --replace &
    fi
    
    echo -e "${GREEN}Fix applied!${NC}"
    read -p "Press Enter to continue..."
}

# Fix no icons
fix_no_icons() {
    echo -e "${BLUE}Fixing no icons issue...${NC}"
    
    # Update icon cache
    if command_exists gtk-update-icon-cache; then
        gtk-update-icon-cache -f ~/.local/share/icons/*
        gtk-update-icon-cache -f /usr/share/icons/*
    fi
    
    # Reset icon theme
    kwriteconfig5 --file kdeglobals --group Icons --key Theme breeze
    
    echo -e "${GREEN}Fix applied!${NC}"
    read -p "Press Enter to continue..."
}

# Fix no panel
fix_no_panel() {
    echo -e "${BLUE}Fixing no desktop panel issue...${NC}"
    
    # Kill and restart plasmashell
    kquitapp5 plasmashell
    sleep 2
    kstart5 plasmashell
    
    echo -e "${GREEN}Fix applied!${NC}"
    read -p "Press Enter to continue..."
}

# Fix slow performance
fix_slow_performance() {
    echo -e "${BLUE}Fixing slow performance issue...${NC}"
    
    # Disable compositor effects
    if command_exists qdbus; then
        qdbus org.kde.KWin /Effects activeEffectsChanged false
    else
        kwriteconfig5 --file kwinrc --group Compositing --key Enabled false
        pkill -f kwin && kwin_x11 --replace &
    fi
    
    # Clear cache
    rm -rf ~/.cache/plasmashell*
    rm -rf ~/.cache/kwin*
    
    # Lower animation speed
    kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor 0.5
    
    echo -e "${GREEN}Fix applied!${NC}"
    read -p "Press Enter to continue..."
}
