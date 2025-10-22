{ config, pkgs, ... }:
{
  imports = [
    ../../../../homes/chris/niri.nix
  ];

  home.file.".config/niri/config.kdl".enable = true;
  home.file.".config/niri/config.kdl".source = ./config/niri/config.kdl;
}
