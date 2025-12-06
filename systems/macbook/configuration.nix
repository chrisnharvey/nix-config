{ self, pkgs, ... }:

{
  system.primaryUser = "chris";

  environment.systemPackages = with pkgs; [
    pkgs.htop
  ];

  homebrew.enable = true;

  homebrew.brews = [
    "gnupg"
  ];

  homebrew.casks = [
    "keybase"
    "zen"
    "intellij-idea"
    "docker-desktop"
    "obsidian"
  ];

  users.users.chris = {
    home = "/Users/chris";
    shell = pkgs.zsh;
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

}
