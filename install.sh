#!/bin/bash

# Enhanced KDE Manager Installer Script
# Version: 2.1
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

# Required directories and files
REQUIRED_DIRS=("modules" "config")
REQUIRED_MODULES=("core.sh" "restart.sh" "logs.sh" "theme.sh" "kwin.sh" "kvantum.sh" "session.sh" "backup.sh" "cleanup.sh")
REQUIRED_CONFIG=("settings.conf")

# Function to display usage
usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  install     Install KDE Manager"
    echo "  update      Update KDE Manager to latest version"
    echo "  remove      Remove KDE Manager"
    echo "  verify      Verify installation and fix permissions"
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

# Function to validate directory structure
validate_directory_structure() {
    local base_dir="$1"
    local missing_dirs=()
    local missing_files=()

    echo -e "${BLUE}Validating directory structure...${NC}"

    # Check required directories
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ ! -d "$base_dir/$dir" ]; then
            echo -e "${YELLOW}Missing directory: $dir${NC}"
            missing_dirs+=("$dir")
            mkdir -p "$base_dir/$dir"
            echo -e "${GREEN}Created directory: $base_dir/$dir${NC}"
        else
            echo -e "${GREEN}Directory exists: $base_dir/$dir${NC}"
        fi
    done

    # Check required modules
    for module in "${REQUIRED_MODULES[@]}"; do
        if [ ! -f "$base_dir/modules/$module" ]; then
            echo -e "${RED}Missing module: modules/$module${NC}"
            missing_files+=("modules/$module")
        else
            echo -e "${GREEN}Module exists: $base_dir/modules/$module${NC}"
        fi
    done

    # Check required config files
    for config in "${REQUIRED_CONFIG[@]}"; do
        if [ ! -f "$base_dir/config/$config" ]; then
            echo -e "${YELLOW}Missing config: config/$config${NC}"
            missing_files+=("config/$config")
        else
            echo -e "${GREEN}Config exists: $base_dir/config/$config${NC}"
        fi
    done

    # Check main executable
    if [ ! -f "$base_dir/kde-man.sh" ]; then
        echo -e "${RED}Missing main executable: kde-man.sh${NC}"
        missing_files+=("kde-man.sh")
    else
        echo -e "${GREEN}Main executable exists: $base_dir/kde-man.sh${NC}"
    fi

    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${YELLOW}Warning: Missing files detected${NC}"
        return 1
    fi

    return 0
}

# Function to fix file permissions
fix_permissions() {
    local base_dir="$1"
    echo -e "${BLUE}Fixing file permissions...${NC}"

    # Make main script executable
    if [ -f "$base_dir/kde-man.sh" ]; then
        chmod +x "$base_dir/kde-man.sh"
        echo -e "${GREEN}Made executable: $base_dir/kde-man.sh${NC}"
    fi

    # Make all module scripts executable
    if [ -d "$base_dir/modules" ]; then
        chmod +x "$base_dir/modules"/*.sh
        echo -e "${GREEN}Made all modules executable${NC}"
    fi

    # Fix directory permissions
    chmod 755 "$base_dir"
    chmod 755 "$base_dir/modules"
    chmod 755 "$base_dir/config"
    echo -e "${GREEN}Directory permissions fixed${NC}"

    # Fix config file permissions
    if [ -d "$base_dir/config" ]; then
        chmod 644 "$base_dir/config"/*.conf
        echo -e "${GREEN}Config file permissions fixed${NC}"
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
        "kvantum-qt5"             # Qt5 support for Kvantum
        "gtk-update-icon-cache"   # For icon cache updates
        "desktop-file-utils"      # For desktop file updates
        "xdg-utils"               # For XDG utilities
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
    echo -e "${BLUE}Installing optional dependencies...${NC}"
    read -p "Install optional dependencies? (y/n): " install_optional
    if [[ $install_optional == [yY] ]]; then
        for dep in "${optional_deps[@]}"; do
            install_package "$dep"
        done
    fi
}

# Function to test module loading
test_module_loading() {
    local install_dir="$1"
    echo -e "${BLUE}Testing module loading...${NC}"

    # Create a temporary test script
    local test_script="/tmp/kde-man-test-$$.sh"
    cat > "$test_script" << EOF
#!/bin/bash

# Get the real directory of the script
SOURCE="\${BASH_SOURCE[0]}"
while [ -h "\$SOURCE" ]; do
  DIR="\$( cd -P "\$( dirname "\$SOURCE" )" && pwd )"
  SOURCE="\$(readlink "\$SOURCE")"
  [[ \$SOURCE != /* ]] && SOURCE="\$DIR/\$SOURCE"
done
SCRIPT_DIR="\$( cd -P "\$( dirname "\$SOURCE" )" && pwd )"

# Using the installation directory instead
SCRIPT_DIR="$install_dir"
echo "Testing module loading from \$SCRIPT_DIR"

# Source core module
if [ -f "\$SCRIPT_DIR/modules/core.sh" ]; then
    source "\$SCRIPT_DIR/modules/core.sh"
    echo "✅ Core module loaded successfully"
else
    echo "❌ Failed to load core module"
    exit 1
fi

# Test loading all modules
for module in "\$SCRIPT_DIR/modules/"*.sh; do
    if [ "\$module" != "\$SCRIPT_DIR/modules/core.sh" ]; then
        module_name=\$(basename "\$module")
        echo "Loading \$module_name..."
        source "\$module"
        if [ \$? -eq 0 ]; then
            echo "✅ \$module_name loaded successfully"
        else
            echo "❌ Failed to load \$module_name"
        fi
    fi
done

# Test key functions availability
functions=("reinstall_kde" "soft_restart_kde" "kde_logs_menu" "theme_management_menu"
           "kwin_management_menu" "kvantum_management_menu" "session_management_menu"
           "backup_restore_menu" "cleanup_diagnostics_menu")

for func in "\${functions[@]}"; do
    if type "\$func" >/dev/null 2>&1; then
        echo "✅ Function '\$func' is available"
    else
        echo "❌ Function '\$func' is NOT available"
    fi
done
EOF

    chmod +x "$test_script"
    bash "$test_script"
    rm -f "$test_script"
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

    # Modify the KDE Manager script to resolve symlinks correctly
    if [ -f "$INSTALL_DIR/kde-man.sh" ]; then
        # Backup the original script
        cp "$INSTALL_DIR/kde-man.sh" "$INSTALL_DIR/kde-man.sh.backup"

        # Update the script to handle symlinks
        sed -i '7,11s|SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE\[0\]}")" && pwd)"|# Get the real directory where the script is located, even if called through a symlink\nSOURCE="${BASH_SOURCE\[0\]}"\nwhile [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink\n  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"\n  SOURCE="$(readlink "$SOURCE")"\n  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located\ndone\nSCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"\n\n# Print debug information\necho "Script is being executed from: $SCRIPT_DIR"|' "$INSTALL_DIR/kde-man.sh"

        echo -e "${GREEN}Updated main script to handle symlinks correctly${NC}"
    fi

    # Validate directory structure and fix permissions
    validate_directory_structure "$INSTALL_DIR"
    fix_permissions "$INSTALL_DIR"

    # Create symbolic link
    ln -sf "$INSTALL_DIR/kde-man.sh" "$BIN_LINK"

    # Create desktop entry
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=KDE Manager
Comment=Manage KDE Plasma configuration and settings
Exec=$INSTALL_DIR/kde-man.sh
Icon=preferences-desktop-plasma
Terminal=true
Type=Application
Categories=System;Settings;
EOF

    # Update desktop database
    update-desktop-database

    # Test module loading
    test_module_loading "$INSTALL_DIR"

    echo -e "${GREEN}KDE Manager installed successfully!${NC}"
    echo -e "${YELLOW}You can run KDE Manager using:${NC}"
    echo -e "  1. ${GREEN}kde-man${NC} command"
    echo -e "  2. ${GREEN}$INSTALL_DIR/kde-man.sh${NC} directly"
}

# Function to verify installation and fix permissions
verify_installation() {
    echo -e "${BLUE}Verifying KDE Manager installation...${NC}"

    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${RED}KDE Manager is not installed at $INSTALL_DIR${NC}"
        read -p "Would you like to install it now? (y/n): " install_now
        if [[ $install_now == [yY] ]]; then
            install_kde_manager
        fi
        return
    fi

    # Validate directory structure
    validate_directory_structure "$INSTALL_DIR"

    # Fix permissions
    fix_permissions "$INSTALL_DIR"

    # Check if the script handles symlinks correctly
    if [ -f "$INSTALL_DIR/kde-man.sh" ]; then
        if ! grep -q "while \[ -h \"\$SOURCE\" \]" "$INSTALL_DIR/kde-man.sh"; then
            echo -e "${YELLOW}The main script does not handle symlinks correctly. Updating...${NC}"
            # Backup the original script
            cp "$INSTALL_DIR/kde-man.sh" "$INSTALL_DIR/kde-man.sh.backup"

            # Update the script to handle symlinks
            sed -i '7,11s|SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE\[0\]}")" && pwd)"|# Get the real directory where the script is located, even if called through a symlink\nSOURCE="${BASH_SOURCE\[0\]}"\nwhile [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink\n  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"\n  SOURCE="$(readlink "$SOURCE")"\n  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located\ndone\nSCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"\n\n# Print debug information\necho "Script is being executed from: $SCRIPT_DIR"|' "$INSTALL_DIR/kde-man.sh"

            echo -e "${GREEN}Updated main script to handle symlinks correctly${NC}"
        else
            echo -e "${GREEN}Main script already handles symlinks correctly${NC}"
        fi
    fi

    # Check symlink
    if [ ! -L "$BIN_LINK" ] || [ ! -e "$BIN_LINK" ]; then
        echo -e "${YELLOW}Symlink is missing or broken, recreating...${NC}"
        ln -sf "$INSTALL_DIR/kde-man.sh" "$BIN_LINK"
    else
        echo -e "${GREEN}Symlink is valid${NC}"
    fi

    # Check desktop file
    if [ ! -f "$DESKTOP_FILE" ]; then
        echo -e "${YELLOW}Desktop file is missing, recreating...${NC}"
        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=KDE Manager
Comment=Manage KDE Plasma configuration and settings
Exec=$INSTALL_DIR/kde-man.sh
Icon=preferences-desktop-plasma
Terminal=true
Type=Application
Categories=System;Settings;
EOF
        update-desktop-database
    else
        # Update desktop file to use direct path instead of the symlink
        sed -i "s|Exec=kde-man|Exec=$INSTALL_DIR/kde-man.sh|g" "$DESKTOP_FILE"
        update-desktop-database
        echo -e "${GREEN}Desktop file exists and has been updated${NC}"
    fi

    # Test module loading
    test_module_loading "$INSTALL_DIR"

    echo -e "${GREEN}Verification completed!${NC}"
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

    # Update the script to handle symlinks correctly
    if [ -f "$INSTALL_DIR/kde-man.sh" ]; then
        # Backup the original script
        cp "$INSTALL_DIR/kde-man.sh" "$INSTALL_DIR/kde-man.sh.backup"

        # Update the script to handle symlinks
        sed -i '7,11s|SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE\[0\]}")" && pwd)"|# Get the real directory where the script is located, even if called through a symlink\nSOURCE="${BASH_SOURCE\[0\]}"\nwhile [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink\n  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"\n  SOURCE="$(readlink "$SOURCE")"\n  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located\ndone\nSCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"\n\n# Print debug information\necho "Script is being executed from: $SCRIPT_DIR"|' "$INSTALL_DIR/kde-man.sh"

echo -e "${GREEN}Updated main script to handle symlinks correctly${NC}"
    fi

    # Validate directory structure and fix permissions
    validate_directory_structure "$INSTALL_DIR"
    fix_permissions "$INSTALL_DIR"

    # Update desktop file to use direct path
    if [ -f "$DESKTOP_FILE" ]; then
        sed -i "s|Exec=kde-man|Exec=$INSTALL_DIR/kde-man.sh|g" "$DESKTOP_FILE"
        update-desktop-database
    fi

    # Test module loading
    test_module_loading "$INSTALL_DIR"

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
            echo -e "Or directly with: ${BLUE}$INSTALL_DIR/kde-man.sh${NC}"
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
        verify)
            verify_installation
            ;;
        help|*)
            usage
            ;;
    esac
}

# Run main function
main "$@"