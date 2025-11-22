# Quick Reference Guide

## Common Tasks

### Switch to a configuration
```bash
sudo nixos-rebuild switch --flake .#dell-laptop
sudo nixos-rebuild switch --flake .#rose-laptop
sudo nixos-rebuild switch --flake .#steamdeck
sudo nixos-rebuild switch --flake .#server
```

### Update flake inputs
```bash
nix flake update
```

### Build without switching
```bash
sudo nixos-rebuild build --flake .#dell-laptop
```

### Check flake configuration
```bash
nix flake check
```

## Module Reference

### Common Modules (auto-included via `modules/common`)

| Module | Purpose | Key Settings |
|--------|---------|--------------|
| `nix.nix` | Nix daemon config | Experimental features, GC, unfree |
| `locale.nix` | Locale settings | UK timezone, en_GB locale |
| `networking.nix` | Network services | NetworkManager, Tailscale, Avahi |
| `hardware.nix` | Hardware support | Bluetooth, PipeWire, firmware updates |
| `printing.nix` | Printing/scanning | CUPS, HP printer, scanner support |
| `shell.nix` | Shell setup | Zsh, GnuPG agent |
| `packages.nix` | Common packages | htop, gnupg, unrar, etc. |
| `flatpak.nix` | Flatpak apps | Common applications, Wayland defaults |
| `virtualization.nix` | Containers/VMs | Docker, libvirt |
| `development.nix` | Dev tools | Android Studio libraries, nix-ld |

### Hardware Modules

| Module | Purpose |
|--------|---------|
| `laptop.nix` | Laptop-specific settings (power management, TPM2, hibernation) |

### User Modules

| Module | Purpose |
|--------|---------|
| `chris.nix` | Chris user account with standard groups |

## System-Specific Configurations

### Dell Laptop
- **Desktop:** Niri compositor
- **Special:** Walker app launcher cache, fingerprint reader
- **Power:** Hibernate on lid close, suspend-then-hibernate

### Rose Laptop  
- **Desktop:** GNOME
- **Special:** Snapper for BTRFS snapshots, Waydroid
- **Users:** chris, rose

### Steam Deck
- **Desktop:** GNOME + Niri (dual)
- **Special:** Jovian NixOS, Decky Loader, Steam gaming mode
- **Users:** chris (uid 1000), deck (uid 2000)

### Server
- **Use:** Home server
- **Special:** ZFS, NFS, Samba, Docker on ZFS
- **Monitoring:** Telegraf

## File Locations

### System Configurations
```
systems/<system>/configuration.nix
systems/<system>/hardware-configuration.nix
systems/<system>/homes/chris/home.nix
```

### Shared Modules
```
modules/common/*.nix
modules/hardware/*.nix
modules/users/*.nix
```

### Desktop Environments
```
desktops/gnome.nix
desktops/niri.nix
desktops/hyprland.nix
desktops/plasma.nix
```

### Shared Home Manager Configs
```
homes/chris/common.nix
homes/chris/desktop.nix
homes/chris/niri.nix
homes/chris/gnome.nix
```

## Overriding Module Defaults

Most module settings use `lib.mkDefault`, so you can override them in your system config:

```nix
# Override timezone from modules/common/locale.nix
time.timeZone = "America/New_York";

# Override Tailscale operator from modules/common/networking.nix
services.tailscale.extraUpFlags = [ "--operator=different-user" ];

# Disable auto-updates from modules/common/nix.nix
nix.gc.automatic = false;
```

## Adding New Systems

See `CONTRIBUTING.md` and `EXAMPLE-new-system.nix` for detailed instructions.

Quick version:
1. Create `systems/new-system/`
2. Generate `hardware-configuration.nix`
3. Create minimal `configuration.nix` importing modules
4. Create `homes/chris/home.nix`
5. Add to `flake.nix`
