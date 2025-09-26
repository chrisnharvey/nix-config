{ config, lib, pkgs, android-nixpkgs, ... }:
{
  imports = [
    ../../homes/chris/common.nix
    # ../../homes/chris/gnome.nix
    # ../../homes/chris/hyprland.nix
    ../../homes/chris/niri.nix
    android-nixpkgs.hmModule

    {
      config = {
        android-sdk.enable = true;

        # Optional; default path is "~/.local/share/android".
        android-sdk.path = "${config.home.homeDirectory}/.android/sdk";

        android-sdk.packages = sdk: with sdk; [
          build-tools-34-0-0
          cmdline-tools-latest
          emulator
          platform-tools
          platforms-android-34
          sources-android-34
          ndk-25-2-9519653  # NDK for native development
          
          # System images for emulator
          system-images-android-34-google-apis-x86-64
        ];
      };
    }
  ];
}
