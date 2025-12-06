{ config, pkgs, ... }:
{
  imports = [
    ../../../../homes/chris/niri.nix
  ];

  home.file.".config/niri/config.kdl".enable = true;
  home.file.".config/niri/config.kdl".text = builtins.readFile ./config/niri/config.kdl;

  home.file.".config/niri/common.kdl".enable = true;
  home.file.".config/niri/common.kdl".text =
    builtins.readFile ../../../../homes/chris/config/niri/common.kdl;
}
