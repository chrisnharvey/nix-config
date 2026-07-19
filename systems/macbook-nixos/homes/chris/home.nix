{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.homeModules.default
    ../../../../homes/chris/backup.nix
    ../../../../homes/chris/common.nix
    # ../../homes/chris/gnome.nix
    # ../../homes/chris/hyprland.nix
    ./niri.nix
  ];

  programs.borgmatic.backups.home.location.repositories = [
    "ssh://chris@192.168.10.9/data/data/files/Backups/macbook-nixos"
  ];

  home.packages = with pkgs; [
    esptool
  ];
}
