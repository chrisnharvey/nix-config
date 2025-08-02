{ config, pkgs, environment, ... }:
{ 
    programs.niri = {
        enable = true;
    };

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.displayManager.sddm.package = pkgs.kdePackages.sddm;
    services.displayManager.sddm.theme = "sddm-astronaut-theme";
    services.displayManager.sddm.extraPackages = with pkgs; [
        sddm-astronaut
    ];

    services.power-profiles-daemon.enable = true;

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gnome
    ];

    environment.systemPackages = with pkgs; [
      bibata-cursors
      papirus-icon-theme
      sddm-astronaut
      swayidle
      swaylock-effects
      alacritty
      xwayland-satellite
    ];

    services.blueman.enable = true;

    fonts.packages = with pkgs; [ nerd-fonts.ubuntu-sans nerd-fonts.ubuntu-mono nerd-fonts.noto ];

    fonts.enableDefaultPackages = true;
}
