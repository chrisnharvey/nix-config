{ config, pkgs, ... }:
{
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

  programs.gnome-disks.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-software
    gnomeExtensions.ddterm
    gnomeExtensions.appindicator
    gnomeExtensions.tailscale-qs
    gnomeExtensions.caffeine
    gnomeExtensions.privacy-settings-menu
    gnomeExtensions.wiggle
    gnomeExtensions.quick-settings-audio-panel
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.pip-on-top
    gnomeExtensions.blur-my-shell
    gnomeExtensions.media-controls
  ];
}
