# Dell Laptop NixOS Configuration
# Primary development laptop running Niri window manager

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
    ../../desktops/niri.nix
    ../../desktops/niri-greeter.nix
  ];

  # Nix configuration - Walker binary cache for faster builds
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://walker.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
  ];

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    flake = "github:chrisnharvey/nix-config";
    dates = "20:00";
  };
  systemd.services.nixos-upgrade.unitConfig.ConditionACPower = true;

  # Laptop-specific power management
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleSuspendKey = "suspend-then-hibernate";
  services.logind.settings.Login.HandlePowerKey = "hibernate";

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=1h
  '';

  # Boot configuration
  boot.resumeDevice = "/dev/mapper/ROOT";
  boot.kernelModules = [ "ecryptfs" ];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [
    "quiet"
    "i915.enable_psr=0"
    "udev.log_level=0"
    "resume_offset=12376136"
  ];
  boot.blacklistedKernelModules = [
    "intel_hid"
    "psmouse"
  ];

  # Networking
  networking.hostId = "98e54f8e";
  networking.hostName = "dell-laptop";

  # Keybase
  services.keybase.enable = true;
  services.kbfs.enable = true;

  # Fingerprint reader
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-broadcom;
  security.pam.services.login.fprintAuth = false;

  # AirPlay support in PipeWire
  services.pipewire.extraConfig.pipewire = {
    "10-airplay" = {
      "context.modules" = [
        {
          name = "libpipewire-module-raop-discover";
        }
      ];
    };
  };

  # Additional user
  users.users.hope = {
    isNormalUser = true;
    description = "Hope";
  };

  # System-specific packages
  environment.systemPackages = with pkgs; [
    ecryptfs
    msedit
    pciutils
    inxi
    glances
    esptool
  ];

  # Steam gaming
  programs.steam.enable = true;

  # Firewall
  networking.firewall.allowedTCPPorts = [
    8081 # Expo
  ];

  system.stateVersion = "24.11";
}
