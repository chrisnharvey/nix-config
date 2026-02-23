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

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.packages = with pkgs; [

  ];
}
