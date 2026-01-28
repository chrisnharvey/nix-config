{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.homeModules.default
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
