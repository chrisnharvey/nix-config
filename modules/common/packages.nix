{ config, lib, pkgs, ... }:
{
  # Common system packages
  environment.systemPackages = with pkgs; lib.mkDefault [
    htop
    gnupg
    unrar
    unzip
    killall
    sshfs-fuse
  ];
}
