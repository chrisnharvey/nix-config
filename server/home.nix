{ config, pkgs, ... }:
{
  imports =
    [
      ../common/home.nix
    ];

  programs.zsh.enableAutosuggestions = true;
}
