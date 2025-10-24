{
  config,
  pkgs,
  environment,
  ...
}:
{
  programs.niri = {
    enable = true;
  };

  security.soteria.enable = true;

  programs.file-roller.enable = true;

  services.accounts-daemon.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.evolution-data-server.enable = true;

  services.gvfs.enable = true;

  services.power-profiles-daemon.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gnome
    pkgs.xdg-desktop-portal-gtk
  ];

  environment.systemPackages = with pkgs; [
    bibata-cursors
    papirus-icon-theme
    sddm-astronaut
    xwayland-satellite
    gnome-online-accounts-gtk
    alacritty
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.ubuntu-sans
    nerd-fonts.ubuntu-mono
    nerd-fonts.noto
    adwaita-fonts
  ];

  fonts.enableDefaultPackages = true;

  services.gnome.gnome-keyring.enable = true;
}
