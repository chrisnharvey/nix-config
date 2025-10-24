{ config, pkgs, ... }:
{
  imports = [
    ./backup.nix
    ../../../../homes/chris/common.nix
    # ../../homes/chris/gnome.nix
    # ../../homes/chris/hyprland.nix
    ./niri.nix
  ];
}
