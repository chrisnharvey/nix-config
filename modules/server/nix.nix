{ config, lib, pkgs, ... }:
{
  # Nix settings for server
  nix = {
    settings.experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
    ];

    gc = lib.mkDefault {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
