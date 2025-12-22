{ config, pkgs, ... }:
{
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

  programs.gnome-disks.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.ddterm
    gnomeExtensions.appindicator
    gnomeExtensions.hibernate-status-button
    gnomeExtensions.tailscale-qs
    gnomeExtensions.caffeine
    gnomeExtensions.privacy-settings-menu
    gnomeExtensions.wiggle
    gnomeExtensions.quick-settings-audio-panel
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.pip-on-top
    gnomeExtensions.blur-my-shell
    gnomeExtensions.media-controls
    gnomeExtensions.gtk4-desktop-icons-ng-ding
    gnomeExtensions.removable-drive-menu
  ];

  environment.gnome.excludePackages = (
    with pkgs;
    [
      atomix # puzzle game
      cheese # webcam tool
      epiphany # web browser
      evince # document viewer
      geary # email reader
      gedit # text editor
      gnome-characters
      gnome-calendar
      gnome-music
      gnome-photos
      gnome-terminal
      gnome-tour
      hitori # sudoku game
      iagno # go game
      tali # poker game
      totem # video player
      gnome-weather
      gnome-contacts
      gnome-clocks
      gnome-maps
      gnome-calculator
      simple-scan
      snapshot
      gnome-shell-extensions
    ]
  );
}
