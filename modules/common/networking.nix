{ config, lib, pkgs, ... }:
{
  # Enable networking
  networking.networkmanager.enable = lib.mkDefault true;

  # Avahi for service discovery
  services.avahi = {
    enable = lib.mkDefault true;
    publish = {
      enable = lib.mkDefault true;
      addresses = lib.mkDefault true;
      workstation = lib.mkDefault true;
    };
  };

  # Tailscale VPN
  services.tailscale.enable = lib.mkDefault true;
  services.tailscale.useRoutingFeatures = lib.mkDefault "client";
  services.tailscale.extraUpFlags = lib.mkDefault [
    "--operator=chris"
    "--accept-routes"
  ];
}
