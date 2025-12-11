# MacBook NixOS Configuration
# Development MacBook running Niri window manager

{ config, pkgs, ... }:

{
  imports = [
    # Common modules
    ../../modules/common
    ../../modules/hardware/macbook-asahi.nix
    ../../modules/users/chris.nix
    ../../modules/common/printing.nix

    # Hardware configuration
    ./hardware-configuration.nix
    #./filesystems.nix

    # Desktop environment
    ../../desktops/niri.nix
    ../../desktops/ly.nix
  ];

  # Asahi Linux hardware support (not required if building with --impure)
  # hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  # hardware.asahi.extractPeripheralFirmware = false;

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
