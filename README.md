# Chris's NixOS Configuration

A comprehensive NixOS configuration using Nix Flakes, managing multiple systems with different desktop environments, a Steam Deck, and a home server setup.

**📚 Documentation:**
- [Quick Reference](QUICKREF.md) - Common tasks and module reference
- [Contributing Guide](CONTRIBUTING.md) - How to add systems and modify modules
- [Example Configuration](EXAMPLE-new-system.nix) - Template for new systems

## 🖥️ Systems

### Laptops
- **dell-laptop** - Primary development laptop running Niri window manager
- **rose-laptop** - Laptop with GNOME desktop environment

### Gaming
- **steamdeck** - Valve Steam Deck with Jovian NixOS, supporting both GNOME and Niri desktop environments

### Server
- **server** - Home server with NFS, Samba, Docker, ZFS, and various services

### macOS
- **macbook** - Basic macOS configuration with nix-darwin

## 🏠 Desktop Environments

The repository supports multiple desktop environments:

- **GNOME** - Full GNOME desktop with custom extensions and settings
- **Hyprland** - Wayland compositor with Waybar and custom keybindings  
- **Niri** - Scrollable-tiling Wayland compositor
- **KDE Plasma** - Plasma 6 desktop environment

## 📁 Repository Structure

```
├── modules/                # Shared configuration modules
│   ├── common/             # Common settings for all systems
│   │   ├── default.nix     # Imports all common modules
│   │   ├── development.nix # Android/development tools
│   │   ├── flatpak.nix     # Flatpak configuration
│   │   ├── hardware.nix    # Bluetooth, audio, firmware
│   │   ├── locale.nix      # UK locale and timezone
│   │   ├── networking.nix  # Network manager, Tailscale, Avahi
│   │   ├── nix.nix         # Nix settings, gc, unfree
│   │   ├── packages.nix    # Common system packages
│   │   ├── printing.nix    # CUPS and scanner support
│   │   ├── shell.nix       # Zsh and GnuPG
│   │   └── virtualization.nix # Docker and libvirt
│   ├── hardware/
│   │   └── laptop.nix      # Laptop-specific settings
│   └── users/
│       └── chris.nix       # Chris user account
├── systems/                # System-specific configurations
│   ├── dell-laptop/        # Primary laptop with Niri
│   │   ├── homes/chris/    # Home Manager config for this system
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── rose-laptop/        # Laptop with GNOME
│   ├── steamdeck/          # Steam Deck configuration
│   ├── server/             # Home server
│   └── macbook/            # macOS system
├── homes/chris/            # Shared Home Manager configurations
├── desktops/               # Desktop environment modules
│   ├── gnome.nix           # GNOME desktop
│   ├── hyprland.nix        # Hyprland compositor
│   ├── niri.nix            # Niri compositor
│   ├── plasma.nix          # KDE Plasma desktop
│   └── ly.nix              # Ly display manager
├── flake.nix               # Main flake configuration
└── flake.lock              # Locked dependency versions
```

## 🧩 Module System

The configuration is now organized into reusable modules for easier management:

### Common Modules (`modules/common/`)
These modules provide shared configuration across all systems:

- **default.nix** - Imports all common modules for convenience
- **nix.nix** - Nix daemon settings, garbage collection, unfree packages
- **locale.nix** - UK locale, timezone, and console keymap
- **networking.nix** - NetworkManager, Avahi, Tailscale VPN
- **hardware.nix** - Bluetooth, PipeWire audio, firmware updates
- **printing.nix** - CUPS printing and scanner support
- **shell.nix** - Zsh shell and GnuPG agent
- **packages.nix** - Common system packages (htop, gnupg, etc.)
- **flatpak.nix** - Flatpak support and common applications
- **virtualization.nix** - Docker and libvirt/KVM
- **development.nix** - Android development tools and libraries

### Hardware Modules (`modules/hardware/`)
Hardware-specific profiles:

- **laptop.nix** - Power management, TPM2, quiet boot, hibernation support

### User Modules (`modules/users/`)
User account definitions:

- **chris.nix** - Chris user account with groups and settings

### Using Modules

System configurations simply import the modules they need:

```nix
{
  imports = [
    ../../modules/common         # All common settings
    ../../modules/hardware/laptop.nix
    ../../modules/users/chris.nix
    ./hardware-configuration.nix
  ];
}
```

This approach eliminates duplication and makes it easy to add new systems.

## 🚀 Quick Start

### Fresh Installation

1. Clone this repository:
```bash
git clone https://github.com/chrisnharvey/nix-config.git
cd nix-config
```

2. Build and switch to a configuration:
```bash
# For NixOS systems
sudo nixos-rebuild switch --flake .#<system-name>

# For macOS
darwin-rebuild switch --flake .#Chriss-MacBook-Pro

# For Home Manager only
home-manager switch --flake .#chris
```

### Available System Configurations

- `dell-laptop` - Development laptop with Niri WM
- `rose-laptop` - Laptop with GNOME DE
- `steamdeck` - Valve Steam Deck with Jovian NixOS
- `server` - Home server configuration
- `Chriss-MacBook-Pro` - macOS configuration

## 🎮 Steam Deck Configuration

The Steam Deck configuration includes:

### Jovian NixOS Integration
- **Jovian NixOS** - Optimized NixOS for Steam Deck hardware
- **Steam** with extest support for controller input
- **Decky Loader** - Plugin loader for Steam Deck UI
- Steam Deck specific hardware support and optimizations

### Desktop Options
- **GNOME** - Full desktop environment for general computing
- **Niri** - Scrollable-tiling compositor for productivity

### System Management
- **Automatic updates** - Daily system updates at 3 AM
- **Plymouth** - Boot splash screen
- **Auto-upgrade** - Boot into updated system automatically

## 🛠️ Server Features

The server configuration includes:

### Storage & Backup
- **ZFS** pools with automatic snapshots via Sanoid
- **Duplicacy Web** for cloud backups
- Custom `start-homelab.sh` script for ZFS mounting

### File Sharing
- **NFS** server for network file access
- **Samba/SMB** shares for Windows compatibility
- **Syncthing** for file synchronization

### Virtualization & Containers
- **Docker** with ZFS storage driver
- **libvirt/KVM** for virtual machines
- **Home Assistant** VM auto-start

### Monitoring
- **Telegraf** metrics collection
- **Prometheus** exporters (optional)
- System monitoring for ZFS, processes, and hardware

### Network Services
- **Tailscale** VPN integration
- **Avahi** for service discovery
- VLAN support (VLAN 40, 50)

## 🏡 Home Manager

Personal configurations in `homes/chris/` include:

### Common Tools
- **Zsh** with Oh My Zsh, Starship prompt
- **Git** with GPG signing
- **Go**, **PHP**, **Node.js** development environments
- **Docker** aliases and utilities

### Desktop-Specific
- **GNOME** - Extensions, theming, and custom settings
- **Hyprland** - Waybar, window rules, keybindings
- **Niri** - Waybar, power management, screenshots

### Applications
- **VSCode** / **Cursor** for development
- **Zen Browser** as default web browser
- **VLC** for media playback
- **Flatpak** applications via declarative configuration

## 🔧 Key Features

### Automatic Updates
- Daily flake updates via GitHub Actions
- System auto-upgrade configured per machine
- Nix garbage collection to manage disk usage

### Security
- **TPM2** support on laptops
- **GPG** key management
- **Tailscale** for secure remote access
- **Fingerprint** authentication on supported hardware

### Power Management
- **Suspend-then-hibernate** for laptops
- **Power profiles daemon** integration
- **UPower** for battery management

### Development Environment
- **Nix development shell** support
- **Container** development with Docker
- **Multiple language** toolchains (Go, PHP, Node.js)
- **Git** workflow optimization
- **VSCode/Cursor** integration
- **IntelliJ IDEA Ultimate** support

## 📦 Nix Configuration

### Versions & Channels
- **NixOS 25.05** (stable) - Used for server
- **nixpkgs-unstable** - Used for desktops and Steam Deck
- **Home Manager** - Both stable (release-25.05) and custom unstable fork
- **nix-darwin** - For macOS configuration

### Key Flake Inputs
- **nix-flatpak** - Declarative Flatpak management
- **walker** - Application launcher
- **jovian** - Steam Deck optimizations via Chaotic Nyx
- **zfs-multi-mount** - ZFS mounting utilities
- **DankMaterialShell** - Custom GNOME greeter

## 🔄 Continuous Integration

GitHub Actions automatically:
- Updates `flake.lock` daily
- Checks flake validity on PRs and updates
- Maintains dependency freshness

### Server Management
```bash
# Start homelab services
sudo start-homelab
```

### Development
```bash
# Enter development shell
nix develop

# Update flake inputs
nix flake update

# Check flake configuration
nix flake check
```