{
  config,
  lib,
  pkgs,
  ...
}:
{
  # AppImage support
  programs.appimage.enable = lib.mkDefault true;
  programs.appimage.binfmt = lib.mkDefault true;
}
