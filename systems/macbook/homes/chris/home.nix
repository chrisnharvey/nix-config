{ config, pkgs, ... }:
{
  imports = [
    ../../../../homes/chris/common.nix
  ];

  programs.zsh = {
    initExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  home.packages = with pkgs; [

  ];
}
