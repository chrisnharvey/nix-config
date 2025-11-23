# Steam Deck NixOS Configuration
# Valve Steam Deck with Jovian NixOS, supporting GNOME and Niri

{ config, pkgs, ... }:

{
  imports = [
    # Common modules (most apply here too)
    ../../modules/common
    ../../modules/users/chris.nix
    ../../modules/common/printing.nix

    # Hardware configuration
    ./hardware-configuration.nix

    # Desktop environments
    ./gnome.nix
    ../../desktops/niri.nix
  ];

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    flake = "github:chrisnharvey/nix-config";
    dates = "03:00";
    allowReboot = true;
  };

  systemd.timers.nixos-upgrade.timerConfig.WakeSystem = true;
  systemd.services.nixos-upgrade.unitConfig.ConditionACPower = true;

  # Jovian (Steam Deck) configuration
  programs.steam.enable = true;
  programs.steam.extest.enable = true;
  jovian.steam.user = "deck";
  jovian.steam.enable = true;
  jovian.steam.autoStart = false;
  jovian.devices.steamdeck.enable = true;
  jovian.decky-loader.enable = true;
  jovian.decky-loader.user = "deck";

  # Boot configuration - Steam Deck OLED plymouth
  boot.plymouth.enable = true;
  boot.plymouth.theme = "steamos";
  boot.plymouth.themePackages = [
    (pkgs.steamdeck-hw-theme.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        # Replace steamos.png with steamos-galileo.png
        if [ -f $out/share/plymouth/themes/steamos/steamos-galileo.png ]; then
          rm -f $out/share/plymouth/themes/steamos/steamos.png
          cp $out/share/plymouth/themes/steamos/steamos-galileo.png $out/share/plymouth/themes/steamos/steamos.png
        fi
      '';
    }))
  ];
  boot.loader.timeout = 0;
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelModules = [ "ecryptfs" ];
  boot.kernelParams = [
    "quiet"
    "udev.log_level=0"
  ];

  # Networking
  networking.hostName = "steamdeck";

  # Keybase
  services.keybase.enable = true;
  services.kbfs.enable = true;

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

  # User accounts - deck user for gaming mode
  users.users.chris.uid = 1000;
  
  users.users.deck = {
    uid = 2000;
    isNormalUser = true;
    description = "Gaming Mode";
    extraGroups = [ "networkmanager" ];
  };

  # System-specific packages
  environment.systemPackages = with pkgs; [
    ecryptfs
    bindfs
    msedit
    pciutils
    inxi
    glances
  ];

  # Firefox
  programs.firefox.enable = true;

  # SSH
  services.openssh.enable = true;
  services.openssh.openFirewall = true;

  system.stateVersion = "25.05";
}
