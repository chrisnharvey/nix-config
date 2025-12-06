{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Common system packages
  environment.systemPackages = with pkgs; [
    htop
    btop
    powertop
    glances
    git
    tmux
    gnupg
    unrar
    unzip
    killall
    sshfs-fuse
  ];
}
