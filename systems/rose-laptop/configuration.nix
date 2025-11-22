# Rose Laptop NixOS Configuration
# Laptop with GNOME desktop environment

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
    ./filesystems.nix

    # Desktop environment
    ../../desktops/gnome.nix
  ];

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    flake = "github:chrisnharvey/nix-config";
    dates = "15:00";
  };

  # Laptop-specific power management
  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.suspendKey = "suspend-then-hibernate";
  services.logind.powerKey = "hibernate";

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=1h
  '';

  # Boot configuration
  boot.resumeDevice = "/dev/mapper/ROOT";
  boot.kernelParams = [
    "quiet"
    "udev.log_level=0"
    "resume_offset=12363008"
  ];
  boot.blacklistedKernelModules = [
    "intel_hid"
    "psmouse"
  ];

  # Networking
  networking.hostId = "a3b2929e";
  networking.hostName = "rose-laptop";

  # Snapper for BTRFS snapshots
  services.snapper.configs.root = {
    SUBVOLUME = "/";
  };

  services.snapper.configs.home = {
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    SUBVOLUME = "/home";
  };

  # Additional user
  users.users.rose = {
    isNormalUser = true;
    description = "Rose";
  };

  # System-specific packages
  environment.systemPackages = with pkgs; [
    msedit
    nextcloud-client
    freeoffice
  ];

  # Steam gaming
  programs.steam.enable = true;

  # Waydroid
  virtualisation.waydroid.enable = true;

  # SSH
  services.openssh.enable = true;

  system.stateVersion = "24.11";
}
