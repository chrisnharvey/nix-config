{ config, lib, pkgs, ... }:
{
  # Networking configuration for server
  networking.networkmanager.enable = lib.mkDefault true;

  # Avahi for service discovery
  services.avahi = lib.mkDefault {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # OpenSSH
  services.openssh.enable = lib.mkDefault true;

  # Tailscale in packages for easy VPN access
  environment.systemPackages = with pkgs; lib.mkDefault [
    tailscale
  ];
}
