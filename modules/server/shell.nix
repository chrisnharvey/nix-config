{ config, lib, pkgs, ... }:
{
  # Shell configuration for server
  programs.zsh.enable = lib.mkDefault true;
  users.defaultUserShell = lib.mkDefault pkgs.zsh;
}
