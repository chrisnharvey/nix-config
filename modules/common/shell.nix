{ config, lib, pkgs, ... }:
{
  # Shell configuration
  programs.zsh.enable = lib.mkDefault true;
  users.defaultUserShell = lib.mkDefault pkgs.zsh;

  # GnuPG agent
  programs.gnupg.agent = {
    enable = lib.mkDefault true;
    enableSSHSupport = lib.mkDefault true;
    pinentryPackage = lib.mkDefault pkgs.pinentry-qt;
  };
}
