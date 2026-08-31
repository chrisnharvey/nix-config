{ config, pkgs, ... }:
{
  imports = [
    ../../../../homes/chris/common.nix
    ../../../../homes/chris/tools.nix
  ];

  home.packages = with pkgs; [
    ghostty
  ];
}
