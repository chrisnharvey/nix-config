# Chris's NixOS Configuration

A comprehensive NixOS configuration using Nix Flakes, managing multiple systems with different desktop environments and a home server setup.

## 🖥️ Systems

### Laptops
- **dell-laptop** - Primary development laptop running Niri window manager
- **rose-laptop** - My daughters's laptop with GNOME desktop environment

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
├── systems/           # System-specific configurations
│   ├── dell-laptop/   # Primary laptop
│   ├── rose-laptop/   # My daughters's laptop  
│   ├── server/        # Home server
│   └── macbook/       # macOS system
├── homes/chris/       # Home Manager configurations
├── desktops/          # Desktop environment modules
├── flake.nix          # Main flake configuration
└── flake.lock         # Locked dependency versions
```

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
- `server` - Home server configuration
- `Chriss-MacBook-Pro` - macOS configuration

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