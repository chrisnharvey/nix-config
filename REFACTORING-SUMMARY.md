# Refactoring Summary

## Before vs After

### Before: Duplicated Configuration

Each system configuration contained ~200-400 lines with significant duplication:

```
systems/dell-laptop/configuration.nix     (420 lines)
  - Locale settings (UK timezone, en_GB)
  - Network configuration (NetworkManager, Tailscale, Avahi)
  - Hardware (Bluetooth, PipeWire, firmware)
  - Printing (CUPS, HP printer, scanner)
  - Flatpak apps and overrides
  - Shell (Zsh, GnuPG)
  - Virtualization (Docker, libvirt)
  - Development tools
  - User account definitions
  - System-specific settings

systems/rose-laptop/configuration.nix     (237 lines)
  - [Same locale settings duplicated]
  - [Same network configuration duplicated]
  - [Same hardware settings duplicated]
  - [Same printing setup duplicated]
  - [Same flatpak setup duplicated]
  - ...

systems/steamdeck/configuration.nix       (433 lines)
  - [Same settings duplicated again]
  - ...
```

**Problems:**
- ❌ Lots of duplicated configuration
- ❌ Hard to maintain consistency across systems
- ❌ Changes needed in multiple places
- ❌ Difficult to see what's unique to each system
- ❌ Adding new systems meant copying ~300 lines

### After: Modular Configuration

Shared settings extracted to reusable modules:

```
modules/
├── common/                           # Shared across all systems
│   ├── default.nix                   # Imports all common modules
│   ├── locale.nix                    # UK timezone, en_GB locale
│   ├── networking.nix                # NetworkManager, Tailscale, Avahi
│   ├── hardware.nix                  # Bluetooth, PipeWire, firmware
│   ├── printing.nix                  # CUPS, HP printer, scanner
│   ├── flatpak.nix                   # Flatpak apps and overrides
│   ├── shell.nix                     # Zsh, GnuPG
│   ├── virtualization.nix            # Docker, libvirt
│   ├── development.nix               # Android dev tools
│   ├── packages.nix                  # Common packages
│   └── nix.nix                       # Nix daemon settings
├── hardware/
│   └── laptop.nix                    # Laptop-specific settings
└── users/
    └── chris.nix                     # User account

systems/dell-laptop/configuration.nix (120 lines) ⬇️ 71% reduction
  imports = [
    ../../modules/common              # All shared settings
    ../../modules/hardware/laptop.nix
    ../../modules/users/chris.nix
    ./hardware-configuration.nix
    ../../desktops/niri.nix
  ]
  # Only dell-laptop specific settings here!

systems/rose-laptop/configuration.nix (93 lines) ⬇️ 61% reduction
  imports = [
    ../../modules/common              # Reuse same shared settings
    ../../modules/hardware/laptop.nix
    ../../modules/users/chris.nix
    ./hardware-configuration.nix
    ../../desktops/gnome.nix
  ]
  # Only rose-laptop specific settings!

systems/steamdeck/configuration.nix   (100 lines) ⬇️ 77% reduction
  imports = [
    ../../modules/common              # Reuse same shared settings
    ../../modules/users/chris.nix
    ./hardware-configuration.nix
    ../../desktops/niri.nix
  ]
  # Only steamdeck specific settings!
```

**Benefits:**
- ✅ Minimal duplication
- ✅ Easy to maintain consistency
- ✅ Change once, apply everywhere
- ✅ Clear what's unique to each system
- ✅ New systems need only ~50-100 lines

## Code Reduction Statistics

| System | Before | After | Reduction |
|--------|--------|-------|-----------|
| dell-laptop | 420 lines | 120 lines | **71%** |
| rose-laptop | 237 lines | 93 lines | **61%** |
| steamdeck | 433 lines | 100 lines | **77%** |

**Total shared configuration extracted:** ~300 lines moved to reusable modules

## Path Standardization

### Before
```
systems/dell-laptop/homes/chris/home.nix      ✓ Consistent
systems/rose-laptop/home.nix                  ✗ Inconsistent
systems/server/home.nix                       ✗ Inconsistent
systems/steamdeck/homes/chris/home.nix        ✓ Consistent
```

### After
```
systems/dell-laptop/homes/chris/home.nix      ✓
systems/rose-laptop/homes/chris/home.nix      ✓
systems/server/homes/chris/home.nix           ✓
systems/steamdeck/homes/chris/home.nix        ✓
```

All home-manager configurations now follow the same pattern!

## Adding a New System

### Before (Complex)
1. Copy existing system config (~300-400 lines)
2. Find and replace hostname in multiple places
3. Find and replace network IDs
4. Change desktop environment imports
5. Remove/modify hardware-specific settings
6. Hope you didn't miss any duplicated config
7. Update flake.nix

### After (Simple)
1. Create directory: `systems/new-system/`
2. Generate hardware config: `nixos-generate-config`
3. Create minimal config (~50-100 lines):
   ```nix
   {
     imports = [
       ../../modules/common
       ../../modules/hardware/laptop.nix
       ../../modules/users/chris.nix
       ./hardware-configuration.nix
       ../../desktops/gnome.nix
     ];
     networking.hostName = "new-system";
     system.stateVersion = "24.11";
   }
   ```
4. Create home config: `homes/chris/home.nix` (import common)
5. Update flake.nix

## Maintainability Improvements

### Updating Common Settings

**Before:** Change in 3+ places
```bash
# Need to update in dell-laptop, rose-laptop, steamdeck configs
vim systems/dell-laptop/configuration.nix    # Add setting
vim systems/rose-laptop/configuration.nix    # Add same setting
vim systems/steamdeck/configuration.nix      # Add same setting again
```

**After:** Change in 1 place
```bash
# Update once in the module
vim modules/common/networking.nix            # Add setting - done!
```

### Consistency

**Before:** Easy to have drift between systems
- Different Tailscale settings
- Different Flatpak overrides
- Different package lists
- Different locale settings

**After:** Guaranteed consistency
- All systems use same base configuration
- Overrides are explicit and visible
- No hidden differences

## Migration Path

This refactoring was done carefully:
1. ✅ Created modules with all common settings
2. ✅ Used `lib.mkDefault` to allow overrides
3. ✅ Refactored system configs to use modules
4. ✅ Standardized paths
5. ✅ Updated documentation
6. ✅ Cleaned up backup files

No functionality was removed - only reorganized for better maintainability!
