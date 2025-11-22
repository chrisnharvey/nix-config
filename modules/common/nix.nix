{ config, lib, ... }:
{
  # Common Nix settings
  nix = {
    settings.experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
    ];

    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "daily";
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
