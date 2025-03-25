{ config, pkgs, ... }:
{
    home.packages = with pkgs; [
      vscode
      jetbrains.goland
      jetbrains.phpstorm
      jetbrains.datagrip
    ];
}
