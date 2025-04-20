# KDE Manager

A comprehensive shell script tool for managing KDE Plasma 6.2 on CachyOS (Arch-based systems).

## Features

- Re-install KDE Plasma 6.2 (fresh install)
- Soft and hard restart options for KDE Plasma
- Wayland restart/redraw functionality
- KDE logs viewing and exporting
- Theme and configuration management
- KWin management (restart, effects, configuration)
- Kvantum theme management
- Session management (save/restore sessions)
- Full backup and restore capabilities
- Cleanup and diagnostics tools
- Common KDE issue fixes

## Project Structure

```
kde-man/
├── install.sh             # Installation script
├── kde-man.sh         # Main executable
├── modules/
│   ├── core.sh           # Core functions and variables
│   ├── restart.sh        # Plasma restart functions
│   ├── logs.sh           # Log management functions
│   ├── theme.sh          # Theme management functions
│   ├── kwin.sh           # KWin management functions
│   ├── kvantum.sh        # Kvantum management functions
│   ├── session.sh        # Session management functions
│   ├── backup.sh         # Backup and restore functions
│   └── cleanup.sh        # Cleanup and diagnostics functions
├── config/
│   └── settings.conf     # Configuration file
└── README.md             # This file
```

## Installation

### Prerequisites

- CachyOS or Arch-based Linux distribution
- KDE Plasma 6.2
- Root privileges (for installation)

### Installation Steps

1. Clone the repository (or just download the install.sh file)
   ```bash
   git clone https://github.com/eraxe/kde-man.git
   cd kde-man
   ```

2. Run the installer:
   ```bash
   sudo ./install.sh install
   ```

The installer will:
- Install all necessary dependencies
- Set up the application in `/opt/kde-man`
- Create a symbolic link at `/usr/local/bin/kde-man`
- Create a desktop entry for easy access

## Usage

After installation, you can run KDE Manager in several ways:

1. From terminal:
   ```bash
   kde-man
   ```

2. From the application menu: Search for "KDE Manager"

### Menu Options

1. **Re-install KDE Plasma 6.2**: Perform a fresh installation of KDE Plasma
2. **Soft Restart KDE Plasma**: Restart plasmashell and KWin without killing all processes
3. **Hard Restart KDE Plasma**: Force restart all KDE components
4. **Wayland Restart/Redraw**: Restart the Wayland compositor (if using Wayland)
5. **View/Export KDE Logs**: Access and export various KDE logs
6. **Theme and Configuration Management**: Manage themes, icons, and appearance settings
7. **KWin Management**: Control the window manager and desktop effects
8. **Kvantum Management**: Manage Kvantum themes
9. **Session Management**: Save and restore KDE sessions
10. **Backup/Restore KDE Configuration**: Create and restore configuration backups
11. **Cleanup and Diagnostics**: Clean temporary files and run diagnostics

## Updating

To update KDE Manager to the latest version:

```bash
sudo ./install.sh update
```

## Uninstallation

To remove KDE Manager:

```bash
sudo ./install.sh remove
```

Note: This will not remove the dependencies that were installed.

## Configuration

The configuration file is located at `/opt/kde-man/config/settings.conf`. You can customize various settings including:

- Backup directory locations
- Logging preferences
- Default behaviors

## Contributing

Contributions are welcome! Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue on the GitHub/

## Author

Arash Abolhasani

## Version

2.0 - Modular Edition
