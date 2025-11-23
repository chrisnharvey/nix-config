# Architecture Overview

## Configuration Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        flake.nix                             │
│  Defines all system configurations and dependencies         │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ├─► NixOS System Configurations
                  │
    ┌─────────────┼─────────────┬─────────────┬─────────────┐
    │             │             │             │             │
    ▼             ▼             ▼             ▼             ▼
┌────────┐  ┌────────────┐  ┌──────────┐  ┌────────┐  ┌────────┐
│ dell-  │  │ rose-      │  │ steam-   │  │ server │  │ mac-   │
│ laptop │  │ laptop     │  │ deck     │  │        │  │ book   │
└───┬────┘  └─────┬──────┘  └─────┬────┘  └────┬───┘  └────┬───┘
    │             │               │            │           │
    │  Each system configuration imports:     │           │
    │             │               │            │           │
    └─────────────┴───────────────┴────────────┴───────────┘
                              │
            ┌─────────────────┼─────────────────┐
            │                 │                 │
            ▼                 ▼                 ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │   Modules    │  │   Hardware   │  │   Desktops   │
    │  (Common)    │  │    Config    │  │ (DE/WM)      │
    └──────────────┘  └──────────────┘  └──────────────┘
```

## Module Architecture

```
modules/
│
├── common/              # Shared base configuration
│   ├── default.nix      ─┐
│   │                     │ All common modules
│   ├── locale.nix       ─┤ imported here for
│   ├── networking.nix   ─┤ convenience
│   ├── hardware.nix     ─┤
│   ├── printing.nix     ─┤
│   ├── shell.nix        ─┤
│   ├── packages.nix     ─┤
│   ├── flatpak.nix      ─┤
│   ├── virtualization.nix┤
│   ├── development.nix  ─┤
│   └── nix.nix          ─┘
│
├── hardware/            # Hardware-specific profiles
│   └── laptop.nix       → Power mgmt, TPM2, hibernation
│
└── users/               # User account definitions
    └── chris.nix        → Main user account
```

## System Configuration Pattern

Each system follows this pattern:

```nix
# systems/<system-name>/configuration.nix
{
  imports = [
    # 1. Common base (all shared settings)
    ../../modules/common
    
    # 2. Hardware profile (if applicable)
    ../../modules/hardware/laptop.nix
    
    # 3. User accounts
    ../../modules/users/chris.nix
    
    # 4. Optional: Additional modules
    ../../modules/common/printing.nix
    
    # 5. Hardware configuration (generated)
    ./hardware-configuration.nix
    
    # 6. Desktop environment
    ../../desktops/niri.nix
  ];
  
  # Only system-specific settings here
  networking.hostName = "unique-name";
  # ... unique configuration only ...
}
```

## Home Manager Integration

```
systems/<system-name>/
├── configuration.nix         # System config (imports modules)
├── hardware-configuration.nix # Generated hardware config
└── homes/chris/
    └── home.nix              # Home Manager config
        │
        └─► imports: ../../homes/chris/common.nix
                     ../../homes/chris/desktop.nix
```

## Configuration Layers

```
┌─────────────────────────────────────────────────┐
│  System-Specific Configuration                  │
│  - Hostname, network IDs                        │
│  - Hardware-specific quirks                     │
│  - System-unique packages                       │
└─────────────────┬───────────────────────────────┘
                  │ overrides
┌─────────────────▼───────────────────────────────┐
│  Hardware Profile (laptop.nix)                  │
│  - Power management                             │
│  - TPM2, hibernation                            │
│  - Boot configuration                           │
└─────────────────┬───────────────────────────────┘
                  │ uses
┌─────────────────▼───────────────────────────────┐
│  Common Modules (modules/common/)               │
│  - Locale, timezone                             │
│  - Networking stack                             │
│  - Hardware support (Bluetooth, audio)          │
│  - Applications (Flatpak)                       │
│  - Development tools                            │
│  - Nix configuration                            │
└─────────────────────────────────────────────────┘
```

## Override Mechanism

Modules use `lib.mkDefault` allowing system-specific overrides:

```nix
# In module (low priority)
time.timeZone = lib.mkDefault "Europe/London";

# In system config (high priority - wins)
time.timeZone = "America/New_York";
```

## Benefits of This Architecture

### 1. **Single Source of Truth**
Common settings defined once in modules

### 2. **Clear Separation**
- **Modules**: What's shared
- **Systems**: What's unique
- **Hardware profiles**: Hardware-specific concerns

### 3. **Easy to Extend**
Adding a new system requires minimal code

### 4. **Maintainable**
Changes to common settings affect all systems automatically

### 5. **Override-Friendly**
Systems can override module defaults when needed

## Real-World Example

### Adding Neovim to All Systems

**Before modular structure:**
```bash
# Edit 4+ configuration files
vim systems/dell-laptop/configuration.nix
vim systems/rose-laptop/configuration.nix
vim systems/steamdeck/configuration.nix
vim systems/server/configuration.nix
```

**With modular structure:**
```bash
# Edit 1 file
vim modules/common/packages.nix

# Add to systemPackages list:
environment.systemPackages = with pkgs; lib.mkDefault [
  htop
  gnupg
  neovim  # ← Add here, done!
];
```

### Creating a New Laptop Configuration

**Before:**
1. Copy existing config (~400 lines)
2. Find/replace hostname
3. Change desktop imports
4. Update network settings
5. Remove/modify 50+ lines
6. Cross fingers

**With modules:**
```nix
{
  imports = [
    ../../modules/common
    ../../modules/hardware/laptop.nix
    ../../modules/users/chris.nix
    ./hardware-configuration.nix
    ../../desktops/hyprland.nix
  ];
  networking.hostName = "new-laptop";
  system.stateVersion = "24.11";
}
```
Done in ~20 lines!

## Configuration Discovery

To understand what a system gets, trace the imports:

```
dell-laptop/configuration.nix
  └─ modules/common/default.nix
      ├─ locale.nix      → UK timezone, en_GB
      ├─ networking.nix  → NetworkManager, Tailscale
      ├─ hardware.nix    → Bluetooth, PipeWire
      ├─ printing.nix    → CUPS, scanner
      ├─ shell.nix       → Zsh, GnuPG
      ├─ packages.nix    → htop, gnupg, unrar
      ├─ flatpak.nix     → Flatpak apps
      ├─ virtualization.nix → Docker, libvirt
      ├─ development.nix → Android tools
      └─ nix.nix         → Nix settings
  └─ modules/hardware/laptop.nix
      ├─ Power management
      ├─ TPM2 support
      └─ Hibernation
  └─ modules/users/chris.nix
      └─ User account + groups
  └─ desktops/niri.nix
      └─ Niri window manager
```

All in 11 lines of imports!
