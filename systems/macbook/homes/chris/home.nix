{ config, pkgs, ... }:
{
  imports = [
    ../../../../homes/chris/common.nix
  ];

  programs.zsh = {
    initExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  home.sessionVariables = {
    ANDROID_HOME = "${config.home.homeDirectory}/Library/Android/sdk";
  };

  home.sessionPath = [
    "/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home/bin"
    "${config.home.homeDirectory}/Library/Android/sdk/platform-tools"
    "${config.home.homeDirectory}/Library/Android/sdk/emulator"
    "${config.home.homeDirectory}/Library/Android/sdk/cmdline-tools/latest/bin"
  ];

  home.packages = with pkgs; [

  ];
}
