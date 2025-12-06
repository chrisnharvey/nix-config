# MacBook NixOS Configuration
# Development MacBook running Niri window manager

{ config, pkgs, ... }:

{
  imports = [
    # Common modules
    ../../modules/common
    ../../modules/hardware/laptop.nix
    ../../modules/users/chris.nix
    ../../modules/common/printing.nix

    # Hardware configuration
    ./hardware-configuration.nix
    #./filesystems.nix

    # Desktop environment
    ../../desktops/niri.nix
    ../../desktops/ly.nix
  ];

  boot.loader.timeout = 3;

  # Asahi Linux hardware support (not required if building with --impure)
  # hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  # hardware.asahi.extractPeripheralFirmware = false;

  # Nix configuration - Walker binary cache for faster builds
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://walker.cachix.org"
    "https://nixos-apple-silicon.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
    "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
  ];

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    flake = "github:chrisnharvey/nix-config";
    dates = "20:00";
  };
  systemd.services.nixos-upgrade.unitConfig.ConditionACPower = true;

  # Networking
  networking.hostId = "3fa9c2d1";
  networking.hostName = "macbook-nixos";

  # Keybase
  services.keybase.enable = true;
  services.kbfs.enable = true;

  # Firewall
  networking.firewall.allowedTCPPorts = [
    8081 # Expo
  ];

  system.stateVersion = "24.11";
}
