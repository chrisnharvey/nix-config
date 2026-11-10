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
    ../../../../homes/chris/tools.nix
  ];

  home.packages = with pkgs; [
    ghostty
  ];
}
