{ config, pkgs, ... }:
{
  imports =
    [
      ../../homes/chris/common.nix
      ../../homes/chris/desktop.nix
      # ../../homes/chris/hyprland.nix
      ../../homes/chris/niri.nix
    ];
}
