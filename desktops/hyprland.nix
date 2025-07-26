{ config, pkgs, ... }:
{
    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];

    environment.systemPackages = with pkgs; [
      bibata-cursors
      papirus-icon-theme
    ];

    services.blueman.enable = true;

    fonts.packages = with pkgs; [ nerd-fonts.ubuntu-sans nerd-fonts.ubuntu-mono nerd-fonts.noto ];

    fonts.enableDefaultPackages = true;
}
