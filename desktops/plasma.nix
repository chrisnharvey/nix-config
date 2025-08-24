{ config, pkgs, ... }:
{
  # Disable the X11 windowing system.
  services.xserver.enable = false;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  security.pam.services.login.fprintAuth = false;
  security.pam.services.kde.fprintAuth = false;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

  environment.systemPackages = with pkgs; [
    kdePackages.sddm-kcm
    kdePackages.discover
    kdePackages.partitionmanager
    kdePackages.spectacle
  ];
}
